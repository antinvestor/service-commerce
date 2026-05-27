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

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/security"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type GoodsReceiptBusiness interface {
	CreateGoodsReceipt(ctx context.Context, req *procurementv1.CreateGoodsReceiptRequest) (*procurementv1.GoodsReceipt, error)
	GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error)
	SearchGoodsReceipts(ctx context.Context, req *procurementv1.SearchGoodsReceiptsRequest) ([]*procurementv1.GoodsReceipt, error)
}

func NewGoodsReceiptBusiness(
	_ context.Context,
	grRepo repository.GoodsReceiptRepository,
	grlRepo repository.GoodsReceiptLineRepository,
	poRepo repository.PurchaseOrderRepository,
	polRepo repository.PurchaseOrderLineRepository,
) GoodsReceiptBusiness {
	return &goodsReceiptBusiness{
		grRepo:  grRepo,
		grlRepo: grlRepo,
		poRepo:  poRepo,
		polRepo: polRepo,
	}
}

type goodsReceiptBusiness struct {
	grRepo  repository.GoodsReceiptRepository
	grlRepo repository.GoodsReceiptLineRepository
	poRepo  repository.PurchaseOrderRepository
	polRepo repository.PurchaseOrderLineRepository
}

func (grb *goodsReceiptBusiness) CreateGoodsReceipt(
	ctx context.Context,
	req *procurementv1.CreateGoodsReceiptRequest,
) (*procurementv1.GoodsReceipt, error) {
	// Idempotency check
	if req.GetIdempotencyKey() != "" {
		existing, err := grb.grRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
		if err != nil && !frame.ErrorIsNotFound(err) {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	// Validate purchase order exists and is in a receivable state
	po, err := grb.poRepo.GetWithLines(ctx, req.GetPurchaseOrderId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot receive goods for a cancelled purchase order"))
	}
	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("purchase order is already fully received"))
	}

	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("goods receipt must have at least one line"))
	}

	// Build PO line map for validation
	poLineMap := make(map[string]*models.PurchaseOrderLine, len(po.Lines))
	for _, pol := range po.Lines {
		poLineMap[pol.GetID()] = pol
	}

	// Validate received quantities don't exceed remaining
	for _, grLine := range req.GetLines() {
		pol, ok := poLineMap[grLine.GetPurchaseOrderLineId()]
		if !ok {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("purchase order line %s not found in purchase order", grLine.GetPurchaseOrderLineId()))
		}

		remaining := pol.OrderedQuantity - pol.ReceivedQuantity
		if grLine.GetReceivedQuantity() > remaining {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("received quantity %.2f exceeds remaining quantity %.2f for PO line %s",
					grLine.GetReceivedQuantity(), remaining, grLine.GetPurchaseOrderLineId()))
		}
	}

	// Determine receiver
	receivedBy := ""
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if subjectID, subErr := claims.GetSubject(); subErr == nil && subjectID != "" {
			receivedBy = subjectID
		}
	}

	now := time.Now()
	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		idempotencyKey = fmt.Sprintf("GR-%d", now.UnixNano())
	}

	gr := &models.GoodsReceipt{
		PurchaseOrderID: req.GetPurchaseOrderId(),
		PropertyID:      po.PropertyID,
		ReceivedBy:      receivedBy,
		ReceivedAt:      &now,
		Status:          int32(procurementv1.GoodsReceiptStatus_GOODS_RECEIPT_STATUS_COMPLETED),
		Notes:           req.GetNotes(),
		IdempotencyKey:  idempotencyKey,
	}

	if createErr := grb.grRepo.Create(ctx, gr); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	// Create receipt lines and update PO line received quantities
	for _, grLine := range req.GetLines() {
		pol := poLineMap[grLine.GetPurchaseOrderLineId()]

		var expiryDate *time.Time
		if grLine.GetExpiryDate() != nil {
			t := grLine.GetExpiryDate().AsTime()
			expiryDate = &t
		}

		acceptedQty := grLine.GetAcceptedQuantity()
		if acceptedQty == 0 {
			acceptedQty = grLine.GetReceivedQuantity()
		}

		grlModel := &models.GoodsReceiptLine{
			GoodsReceiptID:      gr.GetID(),
			PurchaseOrderLineID: grLine.GetPurchaseOrderLineId(),
			InventoryItemID:     pol.InventoryItemID,
			ReceivedQuantity:    grLine.GetReceivedQuantity(),
			AcceptedQuantity:    acceptedQty,
			RejectedQuantity:    grLine.GetRejectedQuantity(),
			RejectionReason:     grLine.GetRejectionReason(),
			LotNumber:           grLine.GetLotNumber(),
			ExpiryDate:          expiryDate,
			Unit:                pol.Unit,
		}

		if lineErr := grb.grlRepo.Create(ctx, grlModel); lineErr != nil {
			return nil, data.ErrorConvertToAPI(lineErr)
		}

		// Update PO line received quantity
		pol.ReceivedQuantity += grLine.GetReceivedQuantity()
		if pol.ReceivedQuantity >= pol.OrderedQuantity {
			pol.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_RECEIVED)
		} else {
			pol.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED)
		}

		_, polErr := grb.polRepo.Update(ctx, pol, "received_quantity", "status")
		if polErr != nil {
			return nil, data.ErrorConvertToAPI(polErr)
		}
	}

	// Update PO status based on line statuses
	grb.updatePurchaseOrderStatus(ctx, po)

	return grb.GetGoodsReceipt(ctx, gr.GetID())
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
	req *procurementv1.SearchGoodsReceiptsRequest,
) ([]*procurementv1.GoodsReceipt, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	var receipts []*models.GoodsReceipt
	var err error

	if req.GetPurchaseOrderId() != "" {
		receipts, err = grb.grRepo.ListByPurchaseOrderID(ctx, req.GetPurchaseOrderId())
	} else if req.GetPropertyId() != "" {
		receipts, err = grb.grRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	} else {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("purchase_order_id or property_id is required"))
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.GoodsReceipt, 0, len(receipts))
	for _, r := range receipts {
		result = append(result, r.ToAPI())
	}
	return result, nil
}

// updatePurchaseOrderStatus checks all PO lines and transitions the PO to
// PARTIALLY_RECEIVED or RECEIVED as appropriate.
func (grb *goodsReceiptBusiness) updatePurchaseOrderStatus(ctx context.Context, po *models.PurchaseOrder) {
	// Re-fetch lines to get updated received quantities
	lines, err := grb.polRepo.ListByPurchaseOrderID(ctx, po.GetID())
	if err != nil {
		return
	}

	allReceived := true
	anyReceived := false
	for _, line := range lines {
		if line.Status == int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED) {
			continue
		}
		if line.ReceivedQuantity >= line.OrderedQuantity {
			anyReceived = true
		} else {
			allReceived = false
			if line.ReceivedQuantity > 0 {
				anyReceived = true
			}
		}
	}

	if allReceived {
		po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED)
	} else if anyReceived {
		po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED)
	}

	_, _ = grb.poRepo.Update(ctx, po, "status")
}
