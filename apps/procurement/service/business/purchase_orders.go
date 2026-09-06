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
	"math"
	"strings"
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

type PurchaseOrderBusiness interface {
	CreatePurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderCreateRequest,
	) (*procurementv1.PurchaseOrder, error)
	GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error)
	SearchPurchaseOrders(
		ctx context.Context,
		req *procurementv1.PurchaseOrderSearchRequest,
	) ([]*procurementv1.PurchaseOrder, error)
	SubmitPurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderSubmitRequest,
	) (*procurementv1.PurchaseOrder, error)
	CancelPurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderCancelRequest,
	) (*procurementv1.PurchaseOrder, error)
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
	req *procurementv1.PurchaseOrderCreateRequest,
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
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("purchase order must have at least one line"),
		)
	}

	// Build lines and compute total
	orderLines, totalCurrency, totalUnits, totalNanos, err := pob.buildPurchaseOrderLines(
		ctx, req.GetSupplierId(), req.GetLines(),
	)
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

	if createErr := pob.poRepo.CreateWithLines(ctx, po, orderLines); createErr != nil {
		if req.GetIdempotencyKey() != "" && data.ErrorIsDuplicateKey(createErr) {
			existing, getErr := pob.poRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
			if getErr == nil {
				return existing.ToAPI(), nil
			}
		}
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) GetPurchaseOrder(
	ctx context.Context,
	id string,
) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return po.ToAPI(), nil
}

func (pob *purchaseOrderBusiness) SearchPurchaseOrders(
	ctx context.Context,
	req *procurementv1.PurchaseOrderSearchRequest,
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

	switch {
	case req.GetPropertyId() != "":
		orders, err = pob.poRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	case req.GetSupplierId() != "":
		orders, err = pob.poRepo.ListBySupplierID(ctx, req.GetSupplierId(), limit, offset)
	case req.GetStatus() != procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_UNSPECIFIED:
		orders, err = pob.poRepo.ListByStatus(ctx, int32(req.GetStatus()), limit, offset)
	default:
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("property_id, supplier_id, or status filter is required"),
		)
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
	req *procurementv1.PurchaseOrderSubmitRequest,
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
	submittedBy := ""
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		if subjectID, subErr := claims.GetSubject(); subErr == nil {
			submittedBy = subjectID
		}
	}

	err = pob.poRepo.Transition(ctx, po.GetID(),
		int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT),
		int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED),
		map[string]any{"submitted_at": now, "submitted_by": submittedBy},
		0,
	)
	if err != nil {
		if errors.Is(err, repository.ErrPurchaseOrderStateChanged) {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				errors.New("only draft purchase orders can be submitted"))
		}
		return nil, data.ErrorConvertToAPI(err)
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) CancelPurchaseOrder(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCancelRequest,
) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	switch procurementv1.PurchaseOrderStatus(po.Status) {
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED:
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("cannot cancel a fully received purchase order"))
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED:
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("cannot cancel a partially received purchase order; receive or close remaining lines"))
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED:
		return po.ToAPI(), nil
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_UNSPECIFIED,
		procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT,
		procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED,
		procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CONFIRMED:
	default:
	}

	err = pob.poRepo.Transition(ctx, po.GetID(),
		po.Status,
		int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED),
		nil,
		int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED),
	)
	if err != nil {
		if errors.Is(err, repository.ErrPurchaseOrderStateChanged) {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				errors.New("purchase order changed; reload and retry"))
		}
		return nil, data.ErrorConvertToAPI(err)
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) buildPurchaseOrderLines(
	ctx context.Context,
	supplierID string,
	lines []*procurementv1.PurchaseOrderLineInput,
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
		if supplierItem.SupplierID != supplierID {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("supplier item %s does not belong to supplier %s", line.GetSupplierItemId(), supplierID))
		}
		if supplierItem.Status != int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE) {
			return nil, "", 0, 0, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("supplier item %s is not active", line.GetSupplierItemId()))
		}
		if supplierItem.MinOrderQuantity > 0 && line.GetOrderedQuantity() < supplierItem.MinOrderQuantity {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("supplier item %s requires a minimum order of %.2f",
					line.GetSupplierItemId(), supplierItem.MinOrderQuantity))
		}

		// Quantities may be fractional (e.g. 12.5 kg); compute in nanos and
		// round to the nearest nano so totals reconcile with supplier invoices.
		unitNanos := supplierItem.PriceUnits*nanosPerUnit + int64(supplierItem.PriceNanos)
		lineNanosTotal := int64(math.Round(float64(unitNanos) * line.GetOrderedQuantity()))
		lineTotalUnits := lineNanosTotal / nanosPerUnit
		lineTotalNanos := lineNanosTotal % nanosPerUnit

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

		// Accumulate total; all lines must share a currency.
		if totalCurrency == "" {
			totalCurrency = supplierItem.CurrencyCode
		} else if supplierItem.CurrencyCode != totalCurrency {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("supplier item %s is priced in %s but the order is in %s",
					line.GetSupplierItemId(), supplierItem.CurrencyCode, totalCurrency))
		}
		totalUnits += lineTotalUnits
		totalNanos += lineTotalNanos
		totalUnits += totalNanos / nanosPerUnit
		totalNanos %= nanosPerUnit
	}

	return orderLines, totalCurrency, totalUnits, int32(totalNanos), nil
}

// generatePONumber returns a globally unique, non-guessable order number.
func generatePONumber() string {
	return "PO-" + strings.ToUpper(util.IDString())
}
