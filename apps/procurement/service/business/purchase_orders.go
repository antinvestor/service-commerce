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
	"math/big"
	"strings"
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

type PurchaseOrderBusiness interface {
	CreatePurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderCreateRequest,
	) (*procurementv1.PurchaseOrder, error)
	GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error)
	SearchPurchaseOrders(
		ctx context.Context,
		req *procurementv1.PurchaseOrderSearchRequest,
	) ([]*procurementv1.PurchaseOrder, string, error)
	SubmitPurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderSubmitRequest,
	) (*procurementv1.PurchaseOrder, error)
	CancelPurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderCancelRequest,
	) (*procurementv1.PurchaseOrder, error)
	// ClosePurchaseOrder closes a partially received order short: what was
	// received stands and nothing more is accepted. Closing a closed order
	// returns it unchanged.
	ClosePurchaseOrder(
		ctx context.Context,
		req *procurementv1.PurchaseOrderCloseRequest,
	) (*procurementv1.PurchaseOrder, error)
}

// maxOrderLines bounds one purchase order.
const maxOrderLines = 200

func NewPurchaseOrderBusiness(
	_ context.Context,
	poRepo repository.PurchaseOrderRepository,
	polRepo repository.PurchaseOrderLineRepository,
	supplierRepo repository.SupplierRepository,
	supplierItemRepo repository.SupplierItemRepository,
) PurchaseOrderBusiness {
	return &purchaseOrderBusiness{
		poRepo:           poRepo,
		polRepo:          polRepo,
		supplierRepo:     supplierRepo,
		supplierItemRepo: supplierItemRepo,
	}
}

type purchaseOrderBusiness struct {
	poRepo           repository.PurchaseOrderRepository
	polRepo          repository.PurchaseOrderLineRepository
	supplierRepo     repository.SupplierRepository
	supplierItemRepo repository.SupplierItemRepository
}

func (pob *purchaseOrderBusiness) CreatePurchaseOrder(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCreateRequest,
) (*procurementv1.PurchaseOrder, error) {
	requestPrint := fingerprint(req)
	if replay, found, err := pob.replay(ctx, req, requestPrint); found || err != nil {
		return replay, err
	}

	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "supplier_id is required")
	}
	if req.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "property_id is required")
	}
	if len(req.GetLines()) == 0 || len(req.GetLines()) > maxOrderLines {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("a purchase order has between 1 and %d lines", maxOrderLines))
	}
	if err := pob.requireActiveSupplier(ctx, req.GetSupplierId()); err != nil {
		return nil, err
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
		RequestHash:          requestPrint,
	}

	if createErr := pob.poRepo.CreateWithLines(ctx, po, orderLines); createErr != nil {
		if req.GetIdempotencyKey() != "" && data.ErrorIsDuplicateKey(createErr) {
			existing, getErr := pob.poRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
			if getErr == nil {
				return replayedPurchaseOrder(existing, req, requestPrint)
			}
		}
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

// replay answers a request whose idempotency key already created an order.
func (pob *purchaseOrderBusiness) replay(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCreateRequest,
	requestPrint string,
) (*procurementv1.PurchaseOrder, bool, error) {
	if req.GetIdempotencyKey() == "" {
		return nil, false, nil
	}
	existing, err := pob.poRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return nil, false, nil
		}
		return nil, false, data.ErrorConvertToAPI(err)
	}
	po, err := replayedPurchaseOrder(existing, req, requestPrint)
	return po, true, err
}

// requireActiveSupplier refuses orders to a supplier that is missing,
// suspended or inactive.
func (pob *purchaseOrderBusiness) requireActiveSupplier(ctx context.Context, supplierID string) error {
	supplier, err := pob.supplierRepo.GetByID(ctx, supplierID)
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return connect.NewError(connect.CodeNotFound, "supplier not found")
		}
		return data.ErrorConvertToAPI(err)
	}
	if supplier.Status != int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE) {
		return connect.NewError(connect.CodeFailedPrecondition, "supplier is not active")
	}
	return nil
}

// replayedPurchaseOrder returns the order an idempotency key already created,
// only when the retry is the same request (property, supplier and lines); a
// key reused for anything else is refused rather than answered with another
// order.
func replayedPurchaseOrder(
	existing *models.PurchaseOrder,
	req *procurementv1.PurchaseOrderCreateRequest,
	requestPrint string,
) (*procurementv1.PurchaseOrder, error) {
	if existing.PropertyID != req.GetPropertyId() || existing.SupplierID != req.GetSupplierId() ||
		!samePrint(existing.RequestHash, requestPrint) {
		return nil, connect.NewError(connect.CodeAlreadyExists,
			"idempotency_key was already used for another purchase order")
	}
	return existing.ToAPI(), nil
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
) ([]*procurementv1.PurchaseOrder, string, error) {
	filter := repository.PurchaseOrderFilter{
		PropertyID: req.GetPropertyId(),
		SupplierID: req.GetSupplierId(),
		Status:     int32(req.GetStatus()),
	}
	if filter == (repository.PurchaseOrderFilter{}) {
		return nil, "", connect.NewError(connect.CodeInvalidArgument,
			"property_id, supplier_id, or status filter is required")
	}
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, "", err
	}
	orders, next, err := pob.poRepo.ListPage(ctx, filter, page)
	if err != nil {
		return nil, "", data.ErrorConvertToAPI(err)
	}
	result := make([]*procurementv1.PurchaseOrder, 0, len(orders))
	for _, o := range orders {
		result = append(result, o.ToAPI())
	}
	return result, repository.EncodePageKey(next), nil
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
			"only draft purchase orders can be submitted")
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
				"only draft purchase orders can be submitted")
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
			"cannot cancel a fully received purchase order")
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED:
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"cannot cancel a partially received purchase order; receive or close remaining lines")
	case procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CLOSED:
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"purchase order is closed")
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
				"purchase order changed; reload and retry")
		}
		return nil, data.ErrorConvertToAPI(err)
	}

	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) ClosePurchaseOrder(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCloseRequest,
) (*procurementv1.PurchaseOrder, error) {
	po, err := pob.poRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CLOSED) {
		return po.ToAPI(), nil
	}
	if po.Status != int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"only a partially received purchase order can be closed short; cancel one with nothing received")
	}
	if err = pob.poRepo.CloseShort(ctx, po.GetID()); err != nil {
		if errors.Is(err, repository.ErrPurchaseOrderStateChanged) {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				"purchase order changed; reload and retry")
		}
		return nil, data.ErrorConvertToAPI(err)
	}
	util.Log(ctx).WithFields(map[string]any{
		"purchase_order_id": po.GetID(), "reason": req.GetReason(),
	}).Info("purchase order closed short")
	return pob.GetPurchaseOrder(ctx, po.GetID())
}

func (pob *purchaseOrderBusiness) buildPurchaseOrderLines(
	ctx context.Context,
	supplierID string,
	lines []*procurementv1.PurchaseOrderLineInput,
) ([]*models.PurchaseOrderLine, string, int64, int32, error) {
	orderLines := make([]*models.PurchaseOrderLine, 0, len(lines))
	var totalCurrency string
	total := new(big.Int)

	for _, line := range lines {
		quantity, err := quantityArg("ordered_quantity", line.GetOrderedQuantity())
		if err != nil {
			return nil, "", 0, 0, err
		}
		if quantity <= 0 {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("ordered quantity must be positive for supplier item %s", line.GetSupplierItemId()))
		}

		supplierItem, err := pob.supplierItemRepo.GetByID(ctx, line.GetSupplierItemId())
		if err != nil {
			return nil, "", 0, 0, connect.NewError(connect.CodeNotFound,
				fmt.Sprintf("supplier item %s not found", line.GetSupplierItemId()))
		}
		if err = orderableItem(supplierItem, supplierID, quantity); err != nil {
			return nil, "", 0, 0, err
		}

		// All lines share a currency.
		if totalCurrency == "" {
			totalCurrency = supplierItem.CurrencyCode
		} else if supplierItem.CurrencyCode != totalCurrency {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("supplier item %s is priced in %s but the order is in %s",
					line.GetSupplierItemId(), supplierItem.CurrencyCode, totalCurrency))
		}
		// Exact arithmetic: quantity × price in nanos, rounded half up once
		// per line, summed without overflow and checked when converted.
		total.Add(total, lineTotal(supplierItem.PriceUnits, supplierItem.PriceNanos, quantity))

		orderLines = append(orderLines, &models.PurchaseOrderLine{
			SupplierItemID:   supplierItem.GetID(),
			InventoryItemID:  supplierItem.InventoryItemID,
			SupplyKind:       supplierItem.SupplyKind,
			ProductVariantID: supplierItem.ProductVariantID,
			OrderedQuantity:  quantity,
			CurrencyCode:     supplierItem.CurrencyCode,
			PriceUnits:       supplierItem.PriceUnits,
			PriceNanos:       supplierItem.PriceNanos,
			Unit:             supplierItem.Unit,
			Status:           int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_PENDING),
		})
	}

	units, nanos, err := moneyFromNanos(total)
	if err != nil {
		return nil, "", 0, 0, err
	}
	return orderLines, totalCurrency, units, nanos, nil
}

// orderableItem checks a supplier item can be ordered in quantity from
// supplierID.
func orderableItem(item *models.SupplierItem, supplierID string, quantity models.Quantity) error {
	switch {
	case item.SupplierID != supplierID:
		return connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("supplier item %s does not belong to supplier %s", item.GetID(), supplierID))
	case item.Status != int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE):
		return connect.NewError(connect.CodeFailedPrecondition,
			fmt.Sprintf("supplier item %s is not active", item.GetID()))
	case item.MinOrderQuantity > 0 && quantity < item.MinOrderQuantity:
		return connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("supplier item %s requires a minimum order of %s", item.GetID(), item.MinOrderQuantity))
	case item.SupplyKind == int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) && !quantity.IsWhole():
		return connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("supplier item %s is a product variant, ordered in whole units", item.GetID()))
	}
	return nil
}

// generatePONumber returns a globally unique, non-guessable order number.
func generatePONumber() string {
	return "PO-" + strings.ToUpper(util.IDString())
}
