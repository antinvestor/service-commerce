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

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
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
	ReceiveVariantStock(ctx context.Context, tenantID, variantID string, quantity int64, reference string) error
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
	tenantID, variantID string,
	quantity int64,
	reference string,
) error {
	_, err := c.cli.ReceiveStock(ctx, commercev1.ReceiveStockRequest_builder{
		VariantId: variantID,
		Quantity:  quantity,
		Reference: reference,
		TenantId:  tenantID,
	}.Build())
	if err == nil {
		return nil
	}
	if refusal(connect.CodeOf(err)) {
		return fmt.Errorf("%w: %w", ErrDeliveryRefused, err)
	}
	return err
}

// refusal reports codes commerce answers with when the request itself is
// wrong; anything else (outage, timeout, credentials) may pass on retry.
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

	quantity := line.AcceptedQuantity
	switch {
	case quantity == 0:
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			"nothing accepted", outcomeDelivered)
	case !quantity.IsWhole() || line.ProductVariantID == "":
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED,
			"a product variant receives whole units of a named variant", outcomeFailed)
	case grb.stock == nil:
		if err := grb.grlRepo.RecordDeliveryAttempt(ctx, line.GetID(), "commerce is not configured"); err != nil {
			log.WithError(err).Error("could not record stock delivery attempt")
		}
		return outcomePending
	}

	err := grb.stock.ReceiveVariantStock(ctx, line.TenantID, line.ProductVariantID, quantity.Units(),
		stockReference(line))
	switch {
	case err == nil:
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED, "", outcomeDelivered)
	case errors.Is(err, ErrDeliveryRefused):
		log.WithError(err).Warn("commerce refused received stock")
		return settle(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED, err.Error(), outcomeFailed)
	default:
		log.WithError(err).Warn("stock delivery failed; it will be retried")
		if recErr := grb.grlRepo.RecordDeliveryAttempt(ctx, line.GetID(), err.Error()); recErr != nil {
			log.WithError(recErr).Error("could not record stock delivery attempt")
		}
		return outcomePending
	}
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
		err = grb.retryDelivery(ctx, line, req.GetNote())
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

// retryDelivery puts a refused product variant line back in the queue and
// pushes it once now; whatever is not settled stays pending for the sweep.
func (grb *goodsReceiptBusiness) retryDelivery(ctx context.Context, line *models.GoodsReceiptLine, note string) error {
	if line.SupplyKind != int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) {
		return connect.NewError(connect.CodeFailedPrecondition,
			"only product variant lines are delivered automatically; book raw materials by hand")
	}
	if note == "" {
		note = "retry requested"
	}
	ok, err := grb.grlRepo.Requeue(ctx, line.GetID(), note)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	if !ok {
		return connect.NewError(connect.CodeFailedPrecondition, "only a line refused by its destination can be retried")
	}
	line.DeliveryStatus = int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING)
	grb.deliverLine(ctx, line)
	return nil
}
