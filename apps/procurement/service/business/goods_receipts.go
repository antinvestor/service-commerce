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
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type GoodsReceiptBusiness interface {
	CreateGoodsReceipt(
		ctx context.Context,
		req *procurementv1.GoodsReceiptCreateRequest,
	) (*procurementv1.GoodsReceipt, error)
	GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error)
	SearchGoodsReceipts(
		ctx context.Context,
		req *procurementv1.GoodsReceiptSearchRequest,
	) ([]*procurementv1.GoodsReceipt, error)
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
	req *procurementv1.GoodsReceiptCreateRequest,
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

	po, poLineMap, err := grb.validateGoodsReceipt(ctx, req)
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
	}

	lines := buildReceiptLines(req.GetLines(), poLineMap)

	if createErr := grb.grRepo.CreateWithLines(ctx, gr, lines); createErr != nil {
		switch {
		case errors.Is(createErr, repository.ErrOverReceipt):
			return nil, connect.NewError(connect.CodeFailedPrecondition, createErr)
		case req.GetIdempotencyKey() != "" && data.ErrorIsDuplicateKey(createErr):
			existing, getErr := grb.grRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
			if getErr == nil {
				return existing.ToAPI(), nil
			}
			return nil, data.ErrorConvertToAPI(createErr)
		default:
			return nil, data.ErrorConvertToAPI(createErr)
		}
	}

	return grb.GetGoodsReceipt(ctx, gr.GetID())
}

// validateGoodsReceipt checks the PO state and validates all requested receipt lines.
func (grb *goodsReceiptBusiness) validateGoodsReceipt(
	ctx context.Context,
	req *procurementv1.GoodsReceiptCreateRequest,
) (*models.PurchaseOrder, map[string]*models.PurchaseOrderLine, error) {
	po, err := grb.poRepo.GetWithLines(ctx, req.GetPurchaseOrderId())
	if err != nil {
		return nil, nil, data.ErrorConvertToAPI(err)
	}

	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED) {
		return nil, nil, connect.NewError(
			connect.CodeFailedPrecondition,
			errors.New("cannot receive goods for a cancelled purchase order"),
		)
	}
	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED) {
		return nil, nil, connect.NewError(
			connect.CodeFailedPrecondition,
			errors.New("purchase order is already fully received"),
		)
	}
	if len(req.GetLines()) == 0 {
		return nil, nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("goods receipt must have at least one line"),
		)
	}

	poLineMap := make(map[string]*models.PurchaseOrderLine, len(po.Lines))
	for _, pol := range po.Lines {
		poLineMap[pol.GetID()] = pol
	}

	// Aggregate per PO line so a line listed twice is checked as a whole. The
	// repository re-checks under the row update, so this is advisory.
	requested := make(map[string]float64, len(req.GetLines()))
	for _, grLine := range req.GetLines() {
		if grLine.GetReceivedQuantity() <= 0 {
			return nil, nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("received quantity must be positive for PO line %s", grLine.GetPurchaseOrderLineId()))
		}
		pol, ok := poLineMap[grLine.GetPurchaseOrderLineId()]
		if !ok {
			return nil, nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("purchase order line %s not found in purchase order", grLine.GetPurchaseOrderLineId()))
		}
		if pol.Status == int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED) {
			return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("purchase order line %s is cancelled", grLine.GetPurchaseOrderLineId()))
		}
		requested[grLine.GetPurchaseOrderLineId()] += grLine.GetReceivedQuantity()
	}
	for lineID, qty := range requested {
		pol := poLineMap[lineID]
		remaining := pol.OrderedQuantity - pol.ReceivedQuantity
		if qty > remaining {
			return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("received quantity %.2f exceeds remaining quantity %.2f for PO line %s",
					qty, remaining, lineID))
		}
	}

	return po, poLineMap, nil
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

// buildReceiptLines maps request lines onto receipt line models. Accepted
// quantity equals received until an inspection step records rejections.
func buildReceiptLines(
	lines []*procurementv1.GoodsReceiptLineInput,
	poLineMap map[string]*models.PurchaseOrderLine,
) []*models.GoodsReceiptLine {
	out := make([]*models.GoodsReceiptLine, 0, len(lines))
	for _, grLine := range lines {
		pol := poLineMap[grLine.GetPurchaseOrderLineId()]

		var expiryDate *time.Time
		if grLine.GetExpiryDate() != nil {
			t := grLine.GetExpiryDate().AsTime()
			expiryDate = &t
		}

		out = append(out, &models.GoodsReceiptLine{
			PurchaseOrderLineID: grLine.GetPurchaseOrderLineId(),
			InventoryItemID:     pol.InventoryItemID,
			ReceivedQuantity:    grLine.GetReceivedQuantity(),
			AcceptedQuantity:    grLine.GetReceivedQuantity(),
			RejectedQuantity:    0,
			LotNumber:           grLine.GetLotNumber(),
			ExpiryDate:          expiryDate,
			Unit:                pol.Unit,
		})
	}
	return out
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

	switch {
	case req.GetPurchaseOrderId() != "":
		receipts, err = grb.grRepo.ListByPurchaseOrderID(ctx, req.GetPurchaseOrderId())
	case req.GetPropertyId() != "":
		receipts, err = grb.grRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	default:
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("purchase_order_id or property_id is required"),
		)
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
