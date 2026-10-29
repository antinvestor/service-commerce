// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package business

import (
	"context"
	"errors"
	"fmt"
	"time"
	"unicode/utf8"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

// ErrDeliveryRefused marks a destination's answer that retrying cannot
// change (unknown variant, another tenant's variant, a reused reference).
var ErrDeliveryRefused = errors.New("stock delivery refused")

// StockDestination is where resale goods land: commerce product variants.
type StockDestination interface {
	// ReceiveVariantStock adds quantity to the variant's stock once per
	// reference. A refusal wraps ErrDeliveryRefused; any other error may
	// succeed on retry.
	// The variant must belong to the receipt's tenant and partition.
	ReceiveVariantStock(
		ctx context.Context,
		tenantID, partitionID, variantID string,
		quantity int64,
		reference string,
	) error
}

// CommerceStockClient is the slice of the commerce API deliveries use.
type CommerceStockClient interface {
	ReceiveStock(context.Context, *commercev1.ReceiveStockRequest) (*commercev1.ReceiveStockResponse, error)
}

// NewCommerceStockDestination delivers through commerce's ReceiveStock, as
// the procurement service itself. A nil client yields nil (not configured):
// lines then stay pending.
func NewCommerceStockDestination(cli CommerceStockClient) StockDestination {
	if cli == nil {
		return nil
	}
	return &commerceStock{cli: cli}
}

type commerceStock struct {
	cli CommerceStockClient
}

func (c *commerceStock) ReceiveVariantStock(
	ctx context.Context,
	tenantID, partitionID, variantID string,
	quantity int64,
	reference string,
) error {
	_, err := c.cli.ReceiveStock(ctx, commercev1.ReceiveStockRequest_builder{
		VariantId:   variantID,
		Quantity:    quantity,
		Reference:   reference,
		TenantId:    tenantID,
		PartitionId: partitionID,
	}.Build())
	if err == nil {
		return nil
	}
	if refusal(connect.CodeOf(err)) {
		return fmt.Errorf("%w: %w", ErrDeliveryRefused, err)
	}
	return err
}

// MaterialReceipt is a raw material line put away in manufacturing
// inventory.
type MaterialReceipt struct {
	TenantID    string
	PartitionID string
	AccessID    string
	PropertyID  string
	ItemID      string
	LocationID  string
	LotNumber   string
	Quantity    float64
	// ReceiptID names the goods receipt the stock came in on.
	ReceiptID string
	// Reference names the line; the destination books it once.
	Reference string
}

// MaterialDestination is where raw materials land: manufacturing inventory.
type MaterialDestination interface {
	// ReceiveMaterial books receipt once per reference. A refusal wraps
	// ErrDeliveryRefused; any other error may succeed on retry.
	ReceiveMaterial(ctx context.Context, receipt MaterialReceipt) error
}

// ManufacturingStockClient is the slice of the manufacturing API material
// deliveries use.
type ManufacturingStockClient interface {
	RecordStockIn(
		context.Context,
		*manufacturingv1.RecordStockInRequest,
	) (*manufacturingv1.RecordStockInResponse, error)
}

// NewManufacturingMaterialDestination books raw materials through
// manufacturing's RecordStockIn, as the procurement service itself acting
// in the receipt's tenancy. A nil client yields nil (not configured): lines
// then stay pending.
func NewManufacturingMaterialDestination(cli ManufacturingStockClient) MaterialDestination {
	if cli == nil {
		return nil
	}
	return &manufacturingStock{cli: cli}
}

type manufacturingStock struct {
	cli ManufacturingStockClient
}

// materialReferenceType tells manufacturing where a stock-in came from.
const materialReferenceType = "procurement_goods_receipt"

func (m *manufacturingStock) ReceiveMaterial(ctx context.Context, receipt MaterialReceipt) error {
	inTenancy := util.SetTenancy(ctx, &security.AuthenticationClaims{
		TenantID:    receipt.TenantID,
		PartitionID: receipt.PartitionID,
		AccessID:    receipt.AccessID,
	})
	_, err := m.cli.RecordStockIn(inTenancy, manufacturingv1.RecordStockInRequest_builder{
		PropertyId:     receipt.PropertyID,
		ItemId:         receipt.ItemID,
		LocationId:     receipt.LocationID,
		LotId:          receipt.LotNumber,
		Quantity:       receipt.Quantity,
		ReferenceType:  materialReferenceType,
		ReferenceId:    receipt.ReceiptID,
		IdempotencyKey: receipt.Reference,
	}.Build())
	if err == nil {
		return nil
	}
	if refusal(connect.CodeOf(err)) {
		return fmt.Errorf("%w: %w", ErrDeliveryRefused, err)
	}
	return err
}

// refusal reports codes a destination answers with when the request itself
// is wrong; anything else (outage, timeout, credentials) may pass on retry.
func refusal(code connect.Code) bool {
	return code == connect.CodeInvalidArgument || code == connect.CodeNotFound ||
		code == connect.CodeAlreadyExists || code == connect.CodeFailedPrecondition ||
		code == connect.CodeOutOfRange
}

// stockReference names a receipt line at the destination, which receives it
// once.
func stockReference(line *models.GoodsReceiptLine) string {
	return "procurement:grl:" + line.GetID()
}

type deliveryOutcome int

const (
	outcomePending deliveryOutcome = iota
	outcomeDelivered
	outcomeFailed
)

// deliverLine pushes one pending line and records the outcome. It never
// fails the caller: whatever is not settled stays pending for the sweep.
func (grb *goodsReceiptBusiness) deliverLine(ctx context.Context, line *models.GoodsReceiptLine) deliveryOutcome {
	log := util.Log(ctx).WithField("goods_receipt_line_id", line.GetID())
	settle := func(status procurementv1.StockDeliveryStatus, note string, outcome deliveryOutcome) deliveryOutcome {
		if _, err := grb.grlRepo.SettleDelivery(ctx, line.GetID(), int32(status), note, time.Now()); err != nil {
			log.WithError(err).Error("could not record stock delivery; it will be retried")
			return outcomePending
		}
		return outcome
	}
	wait := func(note string) deliveryOutcome {
		if err := grb.grlRepo.RecordDeliveryAttempt(ctx, line.GetID(), note); err != nil {
			log.WithError(err).Error("could not record stock delivery attempt")
		}
		return outcomePending
	}

	var err error
	material := line.SupplyKind != int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT)
	quantity := line.AcceptedQuantity
	switch {
	case quantity == 0:
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			"nothing accepted", outcomeDelivered)
	case material && line.LocationID == "":
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING_TRANSFER,
			noteChooseLocation, outcomeFailed)
	case material && grb.materials == nil:
		return wait("manufacturing is not configured")
	case material:
		err = grb.materials.ReceiveMaterial(ctx, materialReceipt(line))
	case !quantity.IsWhole() || line.ProductVariantID == "":
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED,
			"a product variant receives whole units of a named variant", outcomeFailed)
	case grb.stock == nil:
		return wait("commerce is not configured")
	default:
		err = grb.stock.ReceiveVariantStock(
			ctx,
			line.TenantID,
			line.PartitionID,
			line.ProductVariantID,
			quantity.Units(),
			stockReference(line),
		)
	}
	switch {
	case err == nil:
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED, "", outcomeDelivered)
	case errors.Is(err, ErrDeliveryRefused):
		log.WithError(err).Warn("the destination refused received stock")
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED, err.Error(), outcomeFailed)
	default:
		log.WithError(err).Warn("stock delivery failed; it will be retried")
		return wait(err.Error())
	}
}

// materialReceipt describes a raw material line for manufacturing.
func materialReceipt(line *models.GoodsReceiptLine) MaterialReceipt {
	receipt := MaterialReceipt{
		TenantID:    line.TenantID,
		PartitionID: line.PartitionID,
		AccessID:    line.AccessID,
		ItemID:      line.InventoryItemID,
		LocationID:  line.LocationID,
		LotNumber:   line.LotNumber,
		Quantity:    line.AcceptedQuantity.Float(),
		ReceiptID:   line.GoodsReceiptID,
		Reference:   stockReference(line),
	}
	if line.GoodsReceipt != nil {
		receipt.PropertyID = line.GoodsReceipt.PropertyID
	}
	return receipt
}

func (grb *goodsReceiptBusiness) DeliverPending(ctx context.Context, limit int) (DeliverySummary, error) {
	switch {
	case limit <= 0:
		limit = defaultDeliverLimit
	case limit > maxDeliverLimit:
		limit = maxDeliverLimit
	}
	lines, err := grb.grlRepo.ListPendingDelivery(ctx, limit)
	if err != nil {
		return DeliverySummary{}, fmt.Errorf("list pending stock deliveries: %w", err)
	}
	var summary DeliverySummary
	for _, line := range lines {
		if ctx.Err() != nil {
			summary.Pending++
			continue
		}
		switch grb.deliverLine(ctx, line) {
		case outcomeDelivered:
			summary.Delivered++
		case outcomeFailed:
			summary.Failed++
		case outcomePending:
			summary.Pending++
		}
	}
	if len(lines) > 0 {
		util.Log(ctx).WithFields(map[string]any{
			"delivered": summary.Delivered, "pending": summary.Pending, "failed": summary.Failed,
		}).Info("procurement stock deliveries")
	}
	return summary, nil
}

// maxResolutionNote bounds the note staff leave on a resolved line.
const maxResolutionNote = 1000

func (grb *goodsReceiptBusiness) ResolveLine(
	ctx context.Context,
	req *procurementv1.GoodsReceiptLineResolveRequest,
) (*procurementv1.GoodsReceipt, error) {
	if req.GetGoodsReceiptId() == "" || req.GetLineId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "goods_receipt_id and line_id are required")
	}
	if utf8.RuneCountInString(req.GetNote()) > maxResolutionNote {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("note is at most %d characters", maxResolutionNote))
	}
	line, err := grb.grlRepo.GetInReceipt(ctx, req.GetGoodsReceiptId(), req.GetLineId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	switch req.GetResolution() {
	case procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY:
		err = grb.resolveBookedManually(ctx, line, req.GetNote())
	case procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_RETRY:
		err = grb.retryDelivery(ctx, line, req.GetLocationId(), req.GetNote())
	case procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_UNSPECIFIED:
		return nil, connect.NewError(connect.CodeInvalidArgument, "resolution is BOOKED_MANUALLY or RETRY")
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, "resolution is BOOKED_MANUALLY or RETRY")
	}
	if err != nil {
		return nil, err
	}
	return grb.GetGoodsReceipt(ctx, req.GetGoodsReceiptId())
}

// resolveBookedManually records that staff booked the line's stock by hand.
func (grb *goodsReceiptBusiness) resolveBookedManually(
	ctx context.Context,
	line *models.GoodsReceiptLine,
	note string,
) error {
	awaiting := []int32{
		int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING_TRANSFER),
		int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED),
	}
	ok, err := grb.grlRepo.Resolve(ctx, line.GetID(), awaiting, resolveReceivedBy(ctx), note, time.Now())
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	if !ok {
		return connect.NewError(connect.CodeFailedPrecondition,
			"only a line awaiting transfer or refused by its destination can be marked booked")
	}
	return nil
}

// retryDelivery puts a refused line, or a raw material waiting for a stock
// location, back in the queue and pushes it once now; whatever is not
// settled stays pending for the sweep.
func (grb *goodsReceiptBusiness) retryDelivery(
	ctx context.Context,
	line *models.GoodsReceiptLine,
	locationID, note string,
) error {
	from := []int32{int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED)}
	if line.SupplyKind == int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) {
		locationID = ""
	} else {
		if len(locationID) > maxReferenceID {
			return connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("location_id is at most %d characters", maxReferenceID))
		}
		if locationID == "" && line.LocationID == "" {
			return connect.NewError(connect.CodeInvalidArgument,
				"choose the stock location to book this raw material into")
		}
		from = append(from, int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING_TRANSFER))
	}
	if note == "" {
		note = "retry requested"
	}
	ok, err := grb.grlRepo.Requeue(ctx, line.GetID(), from, locationID, note)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	if !ok {
		return connect.NewError(connect.CodeFailedPrecondition,
			"only a line refused by its destination, or a raw material awaiting a location, can be retried")
	}
	line.DeliveryStatus = int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING)
	if locationID != "" {
		line.LocationID = locationID
	}
	grb.deliverLine(ctx, line)
	return nil
}
