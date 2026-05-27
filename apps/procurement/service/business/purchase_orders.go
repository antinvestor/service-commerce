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

type PurchaseOrderBusiness interface {
	CreatePurchaseOrder(ctx context.Context, req *procurementv1.CreatePurchaseOrderRequest) (*procurementv1.PurchaseOrder, error)
	GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error)
	SearchPurchaseOrders(ctx context.Context, req *procurementv1.SearchPurchaseOrdersRequest) ([]*procurementv1.PurchaseOrder, error)
	SubmitPurchaseOrder(ctx context.Context, req *procurementv1.SubmitPurchaseOrderRequest) (*procurementv1.PurchaseOrder, error)
	CancelPurchaseOrder(ctx context.Context, req *procurementv1.CancelPurchaseOrderRequest) (*procurementv1.PurchaseOrder, error)
}

func NewPurchaseOrderBusiness(
	_ context.Context,
	poRepo repository.PurchaseOrderRepository,
	polRepo repository.PurchaseOrderLineRepository,
	supplierItemRepo repository.SupplierItemRepository,
) PurchaseOrderBusiness {
	return &purchaseOrderBusiness{
		poRepo:           poRepo,
		polRepo:          polRepo,
		supplierItemRepo: supplierItemRepo,
	}
}

type purchaseOrderBusiness struct {
	poRepo           repository.PurchaseOrderRepository
	polRepo          repository.PurchaseOrderLineRepository
	supplierItemRepo repository.SupplierItemRepository
}

func (pob *purchaseOrderBusiness) CreatePurchaseOrder(
	ctx context.Context,
	req *procurementv1.CreatePurchaseOrderRequest,
) (*procurementv1.PurchaseOrder, error) {
	// Idempotency check
	if req.GetIdempotencyKey() != "" {
		existing, err := pob.poRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
		if err != nil && !frame.ErrorIsNotFound(err) {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier_id is required"))
	}
	if req.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("property_id is required"))
	}
	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("purchase order must have at least one line"))
	}

	// Build lines and compute total
	orderLines, totalCurrency, totalUnits, totalNanos, err := pob.buildPurchaseOrderLines(ctx, req.GetLines())
	if err != nil {
		return nil, err
	}

	orderNumber := generatePONumber()

	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		idempotencyKey = orderNumber
	}

	var expectedDelivery *time.Time
	if req.GetExpectedDeliveryDate() != nil {
		t := req.GetExpectedDeliveryDate().AsTime()
		expectedDelivery = &t
	}

	po := &models.PurchaseOrder{
		PropertyID:           req.GetPropertyId(),
		SupplierID:           req.GetSupplierId(),
		OrderNumber:          orderNumber,
		Status:               int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT),
		ExpectedDeliveryDate: expectedDelivery,
		TotalCurrencyCode:    totalCurrency,
		TotalUnits:           totalUnits,
		TotalNanos:           totalNanos,
		Notes:                req.GetNotes(),
		PlanID:               req.GetPlanId(),
		IdempotencyKey:       idempotencyKey,
	}

	if createErr := pob.poRepo.Create(ctx, po); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	// Create order lines
	for _, line := range orderLines {
		line.PurchaseOrderID = po.GetID()
		if lineErr := pob.polRepo.Create(ctx, line); lineErr != nil {
			return nil, data.ErrorConvertToAPI(lineErr)
		}
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return po.ToAPI(), nil
}

func (pob *purchaseOrderBusiness) SearchPurchaseOrders(
	ctx context.Context,
	req *procurementv1.SearchPurchaseOrdersRequest,
) ([]*procurementv1.PurchaseOrder, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	var orders []*models.PurchaseOrder
	var err error

	if req.GetPropertyId() != "" {
		orders, err = pob.poRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	} else if req.GetSupplierId() != "" {
		orders, err = pob.poRepo.ListBySupplierID(ctx, req.GetSupplierId(), limit, offset)
	} else if req.GetStatus() != procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_UNSPECIFIED {
		orders, err = pob.poRepo.ListByStatus(ctx, int32(req.GetStatus()), limit, offset)
	} else {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("property_id, supplier_id, or status filter is required"))
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.PurchaseOrder, 0, len(orders))
	for _, o := range orders {
		result = append(result, o.ToAPI())
	}
	return result, nil
}

func (pob *purchaseOrderBusiness) SubmitPurchaseOrder(
	ctx context.Context,
	req *procurementv1.SubmitPurchaseOrderRequest,
) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if po.Status != int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("only draft purchase orders can be submitted"))
	}

	now := time.Now()
	po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED)
	po.SubmittedAt = &now

	// Get submitter from claims
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if subjectID, subErr := claims.GetSubject(); subErr == nil && subjectID != "" {
			po.SubmittedBy = subjectID
		}
	}

	_, updateErr := pob.poRepo.Update(ctx, po, "status", "submitted_at", "submitted_by")
	if updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}

	return po.ToAPI(), nil
}

func (pob *purchaseOrderBusiness) CancelPurchaseOrder(
	ctx context.Context,
	req *procurementv1.CancelPurchaseOrderRequest,
) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("cannot cancel a fully received purchase order"))
	}

	po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED)

	_, updateErr := pob.poRepo.Update(ctx, po, "status")
	if updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}

	// Cancel all lines
	for _, line := range po.Lines {
		line.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED)
		_, lineErr := pob.polRepo.Update(ctx, line, "status")
		if lineErr != nil {
			return nil, data.ErrorConvertToAPI(lineErr)
		}
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) buildPurchaseOrderLines(
	ctx context.Context,
	lines []*procurementv1.CreatePurchaseOrderLine,
) ([]*models.PurchaseOrderLine, string, int64, int32, error) {
	const nanosPerUnit int64 = 1_000_000_000

	var orderLines []*models.PurchaseOrderLine
	var totalCurrency string
	var totalUnits int64
	var totalNanos int64

	for _, line := range lines {
		if line.GetOrderedQuantity() <= 0 {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("ordered quantity must be positive for supplier item %s", line.GetSupplierItemId()))
		}

		supplierItem, err := pob.supplierItemRepo.GetByID(ctx, line.GetSupplierItemId())
		if err != nil {
			return nil, "", 0, 0, connect.NewError(connect.CodeNotFound,
				fmt.Errorf("supplier item %s not found", line.GetSupplierItemId()))
		}

		// Compute line total: price * quantity (using int64 arithmetic)
		qty := int64(line.GetOrderedQuantity())
		lineTotalNanos := int64(supplierItem.PriceNanos) * qty
		lineTotalUnits := supplierItem.PriceUnits*qty + lineTotalNanos/nanosPerUnit
		lineTotalNanos %= nanosPerUnit

		orderLine := &models.PurchaseOrderLine{
			SupplierItemID:  supplierItem.GetID(),
			InventoryItemID: supplierItem.InventoryItemID,
			OrderedQuantity: line.GetOrderedQuantity(),
			CurrencyCode:    supplierItem.CurrencyCode,
			PriceUnits:      supplierItem.PriceUnits,
			PriceNanos:      supplierItem.PriceNanos,
			Unit:            supplierItem.Unit,
			Status:          int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_PENDING),
		}
		orderLines = append(orderLines, orderLine)

		// Accumulate total
		if totalCurrency == "" {
			totalCurrency = supplierItem.CurrencyCode
		}
		totalUnits += lineTotalUnits
		totalNanos += lineTotalNanos
		totalUnits += totalNanos / nanosPerUnit
		totalNanos %= nanosPerUnit
	}

	return orderLines, totalCurrency, totalUnits, int32(totalNanos), nil
}

func generatePONumber() string {
	return fmt.Sprintf("PO-%d", time.Now().UnixNano())
}
