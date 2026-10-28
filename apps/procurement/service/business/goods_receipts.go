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

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

const (
	// maxReceiptLines bounds one goods receipt.
	maxReceiptLines = 200
	// Delivery sweep bounds.
	defaultDeliverLimit = 100
	maxDeliverLimit     = 500
)

// DeliverySummary counts what one delivery sweep did.
type DeliverySummary struct {
	Delivered int32
	Pending   int32
	Failed    int32
}

type GoodsReceiptBusiness interface {
	// CreateGoodsReceipt records the receipt and, in the same transaction,
	// where each line's stock goes; after commit it pushes resale stock to
	// commerce. A push that fails stays pending for DeliverPending.
	CreateGoodsReceipt(
		ctx context.Context,
		req *procurementv1.GoodsReceiptCreateRequest,
	) (*procurementv1.GoodsReceipt, error)
	GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error)
	SearchGoodsReceipts(
		ctx context.Context,
		req *procurementv1.GoodsReceiptSearchRequest,
	) ([]*procurementv1.GoodsReceipt, string, error)
	// DeliverPending pushes up to limit lines still pending, least-tried
	// first. Every line lands at most once however often it runs.
	DeliverPending(ctx context.Context, limit int) (DeliverySummary, error)
}

func NewGoodsReceiptBusiness(
	_ context.Context,
	grRepo repository.GoodsReceiptRepository,
	grlRepo repository.GoodsReceiptLineRepository,
	poRepo repository.PurchaseOrderRepository,
	stock StockDestination,
) GoodsReceiptBusiness {
	return &goodsReceiptBusiness{
		grRepo:  grRepo,
		grlRepo: grlRepo,
		poRepo:  poRepo,
		stock:   stock,
	}
}

type goodsReceiptBusiness struct {
	grRepo  repository.GoodsReceiptRepository
	grlRepo repository.GoodsReceiptLineRepository
	poRepo  repository.PurchaseOrderRepository
	stock   StockDestination
}

func (grb *goodsReceiptBusiness) CreateGoodsReceipt(
	ctx context.Context,
	req *procurementv1.GoodsReceiptCreateRequest,
) (*procurementv1.GoodsReceipt, error) {
	requestPrint := fingerprint(req)
	// A replay returns the receipt only for the same request on the same
	// purchase order (and so the property the caller was authorised on).
	if req.GetIdempotencyKey() != "" {
		existing, err := grb.grRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return replayedReceipt(existing, req, requestPrint)
		}
		if err != nil && !frame.ErrorIsNotFound(err) {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	po, lines, err := grb.validateGoodsReceipt(ctx, req)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		idempotencyKey = util.IDString()
	}

	gr := &models.GoodsReceipt{
		PurchaseOrderID: req.GetPurchaseOrderId(),
		PropertyID:      po.PropertyID,
		ReceivedBy:      resolveReceivedBy(ctx),
		ReceivedAt:      &now,
		Status:          int32(procurementv1.GoodsReceiptStatus_GOODS_RECEIPT_STATUS_PENDING_INSPECTION),
		Notes:           req.GetNotes(),
		IdempotencyKey:  idempotencyKey,
		RequestHash:     requestPrint,
		StockLocationID: req.GetStockLocationId(),
	}

	if createErr := grb.grRepo.CreateWithLines(ctx, gr, lines); createErr != nil {
		switch {
		case errors.Is(createErr, repository.ErrOverReceipt):
			return nil, connect.NewError(connect.CodeFailedPrecondition, createErr.Error()).WithCause(createErr)
		case errors.Is(createErr, repository.ErrNotReceivable):
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				"purchase order is not open for receipts").WithCause(createErr)
		case req.GetIdempotencyKey() != "" && data.ErrorIsDuplicateKey(createErr):
			existing, getErr := grb.grRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
			if getErr == nil {
				return replayedReceipt(existing, req, requestPrint)
			}
			return nil, data.ErrorConvertToAPI(createErr)
		default:
			return nil, data.ErrorConvertToAPI(createErr)
		}
	}

	// The receipt is committed; pushing its stock is best effort here and
	// retried by DeliverPending.
	for _, line := range lines {
		if line.DeliveryStatus == int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING) {
			grb.deliverLine(ctx, line)
		}
	}

	return grb.GetGoodsReceipt(ctx, gr.GetID())
}

// replayedReceipt answers a repeated idempotency key with the receipt it
// created, provided the retry is the same request on the same order.
func replayedReceipt(
	existing *models.GoodsReceipt,
	req *procurementv1.GoodsReceiptCreateRequest,
	requestPrint string,
) (*procurementv1.GoodsReceipt, error) {
	if existing.PurchaseOrderID != req.GetPurchaseOrderId() || !samePrint(existing.RequestHash, requestPrint) {
		return nil, connect.NewError(connect.CodeAlreadyExists,
			"idempotency_key was already used for another goods receipt")
	}
	return existing.ToAPI(), nil
}

// receivable lists the order statuses goods may be received against; the
// repository checks it again under the order's lock.
func receivable(status int32) bool {
	return status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED) ||
		status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CONFIRMED) ||
		status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED)
}

// validateGoodsReceipt checks the order is open for receipts and builds the
// receipt lines.
func (grb *goodsReceiptBusiness) validateGoodsReceipt(
	ctx context.Context,
	req *procurementv1.GoodsReceiptCreateRequest,
) (*models.PurchaseOrder, []*models.GoodsReceiptLine, error) {
	po, err := grb.poRepo.GetWithLines(ctx, req.GetPurchaseOrderId())
	if err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}
	if !receivable(po.Status) {
		return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
			"goods are received only against a submitted, confirmed or partially received purchase order")
	}
	if len(req.GetLines()) == 0 || len(req.GetLines()) > maxReceiptLines {
		return nil, nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("a goods receipt has between 1 and %d lines", maxReceiptLines))
	}

	poLines := make(map[string]*models.PurchaseOrderLine, len(po.Lines))
	for _, pol := range po.Lines {
		poLines[pol.GetID()] = pol
	}

	// Aggregate per PO line so a line listed twice is checked as a whole. The
	// repository re-checks under the row update, so this is advisory.
	requested := make(map[string]models.Quantity, len(req.GetLines()))
	lines := make([]*models.GoodsReceiptLine, 0, len(req.GetLines()))
	for _, in := range req.GetLines() {
		pol, ok := poLines[in.GetPurchaseOrderLineId()]
		if !ok {
			return nil, nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("purchase order line %s not found in purchase order", in.GetPurchaseOrderLineId()))
		}
		quantity, qErr := quantityArg("received_quantity", in.GetReceivedQuantity())
		if qErr != nil {
			return nil, nil, qErr
		}
		if lineErr := receivableLine(pol, quantity); lineErr != nil {
			return nil, nil, lineErr
		}
		requested[pol.GetID()] += quantity
		lines = append(lines, receiptLine(in, pol, quantity))
	}
	for lineID, qty := range requested {
		pol := poLines[lineID]
		if remaining := pol.OrderedQuantity - pol.ReceivedQuantity; qty > remaining {
			return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Sprintf("received quantity %s exceeds remaining quantity %s for PO line %s",
					qty, remaining, lineID))
		}
	}
	return po, lines, nil
}

// receivableLine checks one requested quantity against its order line.
func receivableLine(pol *models.PurchaseOrderLine, quantity models.Quantity) error {
	switch {
	case quantity <= 0:
		return connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("received quantity must be positive for PO line %s", pol.GetID()))
	case pol.Status == int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED),
		pol.Status == int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CLOSED):
		return connect.NewError(connect.CodeFailedPrecondition,
			fmt.Sprintf("purchase order line %s is no longer open", pol.GetID()))
	case pol.SupplyKind == int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) && !quantity.IsWhole():
		return connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("PO line %s is a product variant, received in whole units", pol.GetID()))
	}
	return nil
}

// receiptLine maps a request line onto a receipt line. Accepted equals
// received until an inspection step records rejections. Resale stock waits
// to be pushed to commerce; raw materials wait for a transfer into
// manufacturing inventory, which takes no receipts from procurement yet.
func receiptLine(
	in *procurementv1.GoodsReceiptLineInput,
	pol *models.PurchaseOrderLine,
	quantity models.Quantity,
) *models.GoodsReceiptLine {
	var expiry *time.Time
	if in.GetExpiryDate() != nil {
		t := in.GetExpiryDate().AsTime()
		expiry = &t
	}
	line := &models.GoodsReceiptLine{
		PurchaseOrderLineID: pol.GetID(),
		InventoryItemID:     pol.InventoryItemID,
		SupplyKind:          pol.SupplyKind,
		ProductVariantID:    pol.ProductVariantID,
		ReceivedQuantity:    quantity,
		AcceptedQuantity:    quantity,
		LotNumber:           in.GetLotNumber(),
		ExpiryDate:          expiry,
		Unit:                pol.Unit,
	}
	if pol.SupplyKind == int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) {
		line.DeliveryStatus = int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING)
	} else {
		line.DeliveryStatus = int32(procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING_TRANSFER)
		line.DeliveryNote = "record this stock in manufacturing inventory; it does not accept procurement receipts yet"
	}
	return line
}

// resolveReceivedBy extracts the subject ID from the context claims.
func resolveReceivedBy(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	subjectID, err := claims.GetSubject()
	if err != nil || subjectID == "" {
		return ""
	}
	return subjectID
}

func (grb *goodsReceiptBusiness) GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error) {
	gr, err := grb.grRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return gr.ToAPI(), nil
}

func (grb *goodsReceiptBusiness) SearchGoodsReceipts(
	ctx context.Context,
	req *procurementv1.GoodsReceiptSearchRequest,
) ([]*procurementv1.GoodsReceipt, string, error) {
	if req.GetPurchaseOrderId() == "" && req.GetPropertyId() == "" {
		return nil, "", connect.NewError(connect.CodeInvalidArgument,
			"purchase_order_id or property_id is required")
	}
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, "", err
	}
	receipts, next, err := grb.grRepo.ListPage(ctx, repository.GoodsReceiptFilter{
		PurchaseOrderID: req.GetPurchaseOrderId(),
		PropertyID:      req.GetPropertyId(),
		Status:          int32(req.GetStatus()),
	}, page)
	if err != nil {
		return nil, "", data.ErrorConvertToAPI(err)
	}
	result := make([]*procurementv1.GoodsReceipt, 0, len(receipts))
	for _, r := range receipts {
		result = append(result, r.ToAPI())
	}
	return result, repository.EncodePageKey(next), nil
}
