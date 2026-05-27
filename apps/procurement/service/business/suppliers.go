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
	"strings"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type SupplierBusiness interface {
	SaveSupplier(ctx context.Context, req *procurementv1.SupplierSaveRequest) (*procurementv1.Supplier, error)
	GetSupplier(ctx context.Context, id string) (*procurementv1.Supplier, error)
	SearchSuppliers(ctx context.Context, req *procurementv1.SupplierSearchRequest) ([]*procurementv1.Supplier, error)
	SaveSupplierItem(
		ctx context.Context,
		req *procurementv1.SupplierItemSaveRequest,
	) (*procurementv1.SupplierItem, error)
	SearchSupplierItems(
		ctx context.Context,
		req *procurementv1.SupplierItemSearchRequest,
	) ([]*procurementv1.SupplierItem, error)
}

func NewSupplierBusiness(
	_ context.Context,
	supplierRepo repository.SupplierRepository,
	supplierItemRepo repository.SupplierItemRepository,
) SupplierBusiness {
	return &supplierBusiness{
		supplierRepo:     supplierRepo,
		supplierItemRepo: supplierItemRepo,
	}
}

type supplierBusiness struct {
	supplierRepo     repository.SupplierRepository
	supplierItemRepo repository.SupplierItemRepository
}

func (sb *supplierBusiness) SaveSupplier(
	ctx context.Context,
	req *procurementv1.SupplierSaveRequest,
) (*procurementv1.Supplier, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier name is required"))
	}

	// Update existing supplier
	if req.GetId() != "" {
		return sb.updateSupplier(ctx, req, name)
	}

	// Create new supplier
	supplier := &models.Supplier{
		ProfileID:        req.GetProfileId(),
		Name:             name,
		SupplierType:     int32(req.GetSupplierType()),
		Status:           int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE),
		PaymentTermsDays: req.GetPaymentTermsDays(),
		Currency:         req.GetCurrency(),
		LeadTimeDays:     req.GetLeadTimeDays(),
		Rating:           int32(procurementv1.SupplierRating_SUPPLIER_RATING_UNRATED),
		Notes:            req.GetNotes(),
	}

	if createErr := sb.supplierRepo.Create(ctx, supplier); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return supplier.ToAPI(), nil
}

func (sb *supplierBusiness) updateSupplier(
	ctx context.Context,
	req *procurementv1.SupplierSaveRequest,
	name string,
) (*procurementv1.Supplier, error) {
	supplier, err := sb.supplierRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	supplier.Name = name
	supplier.ProfileID = req.GetProfileId()
	if req.GetSupplierType() != procurementv1.SupplierType_SUPPLIER_TYPE_UNSPECIFIED {
		supplier.SupplierType = int32(req.GetSupplierType())
	}
	if req.GetStatus() != procurementv1.SupplierStatus_SUPPLIER_STATUS_UNSPECIFIED {
		supplier.Status = int32(req.GetStatus())
	}
	supplier.PaymentTermsDays = req.GetPaymentTermsDays()
	supplier.Currency = req.GetCurrency()
	supplier.LeadTimeDays = req.GetLeadTimeDays()
	if req.GetRating() != procurementv1.SupplierRating_SUPPLIER_RATING_UNSPECIFIED {
		supplier.Rating = int32(req.GetRating())
	}
	supplier.Notes = req.GetNotes()

	_, updateErr := sb.supplierRepo.Update(ctx, supplier,
		"name", "profile_id", "supplier_type", "status",
		"payment_terms_days", "currency", "lead_time_days",
		"rating", "notes",
	)
	if updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}

	return supplier.ToAPI(), nil
}

func (sb *supplierBusiness) GetSupplier(ctx context.Context, id string) (*procurementv1.Supplier, error) {
	supplier, err := sb.supplierRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return supplier.ToAPI(), nil
}

func (sb *supplierBusiness) SearchSuppliers(
	ctx context.Context,
	req *procurementv1.SupplierSearchRequest,
) ([]*procurementv1.Supplier, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	var suppliers []*models.Supplier
	var err error

	switch {
	case req.GetStatus() != procurementv1.SupplierStatus_SUPPLIER_STATUS_UNSPECIFIED:
		suppliers, err = sb.supplierRepo.ListByStatus(ctx, int32(req.GetStatus()), limit, offset)
	case req.GetSupplierType() != procurementv1.SupplierType_SUPPLIER_TYPE_UNSPECIFIED:
		suppliers, err = sb.supplierRepo.ListByType(ctx, int32(req.GetSupplierType()), limit, offset)
	default:
		suppliers, err = sb.supplierRepo.ListByStatus(
			ctx,
			int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE),
			limit,
			offset,
		)
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.Supplier, 0, len(suppliers))
	for _, s := range suppliers {
		result = append(result, s.ToAPI())
	}
	return result, nil
}

func (sb *supplierBusiness) SaveSupplierItem(
	ctx context.Context,
	req *procurementv1.SupplierItemSaveRequest,
) (*procurementv1.SupplierItem, error) {
	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier_id is required"))
	}
	if req.GetInventoryItemId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("inventory_item_id is required"))
	}

	// Validate supplier exists
	_, supplierErr := sb.supplierRepo.GetByID(ctx, req.GetSupplierId())
	if supplierErr != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("supplier not found"))
	}

	currencyCode, priceUnits, priceNanos := models.MoneyFromProto(req.GetUnitPrice())

	// Update existing supplier item
	if req.GetId() != "" {
		item, err := sb.supplierItemRepo.GetByID(ctx, req.GetId())
		if err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}

		item.SupplierSKU = req.GetSupplierSku()
		item.CurrencyCode = currencyCode
		item.PriceUnits = priceUnits
		item.PriceNanos = priceNanos
		item.MinOrderQuantity = req.GetMinOrderQuantity()
		item.Unit = req.GetUnit()
		item.LeadTimeDays = req.GetLeadTimeDays()
		if req.GetStatus() != procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_UNSPECIFIED {
			item.Status = int32(req.GetStatus())
		}

		_, updateErr := sb.supplierItemRepo.Update(ctx, item,
			"supplier_sku", "currency_code", "price_units", "price_nanos",
			"min_order_quantity", "unit", "lead_time_days", "status",
		)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}

		return item.ToAPI(), nil
	}

	// Create new supplier item
	item := &models.SupplierItem{
		SupplierID:       req.GetSupplierId(),
		InventoryItemID:  req.GetInventoryItemId(),
		SupplierSKU:      req.GetSupplierSku(),
		CurrencyCode:     currencyCode,
		PriceUnits:       priceUnits,
		PriceNanos:       priceNanos,
		MinOrderQuantity: req.GetMinOrderQuantity(),
		Unit:             req.GetUnit(),
		LeadTimeDays:     req.GetLeadTimeDays(),
		Status:           int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE),
	}

	if createErr := sb.supplierItemRepo.Create(ctx, item); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return item.ToAPI(), nil
}

func (sb *supplierBusiness) SearchSupplierItems(
	ctx context.Context,
	req *procurementv1.SupplierItemSearchRequest,
) ([]*procurementv1.SupplierItem, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	var items []*models.SupplierItem
	var err error

	switch {
	case req.GetSupplierId() != "":
		items, err = sb.supplierItemRepo.ListBySupplierID(ctx, req.GetSupplierId(), limit, offset)
	case req.GetInventoryItemId() != "":
		items, err = sb.supplierItemRepo.ListByInventoryItemID(ctx, req.GetInventoryItemId())
	default:
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("supplier_id or inventory_item_id is required"),
		)
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.SupplierItem, 0, len(items))
	for _, si := range items {
		result = append(result, si.ToAPI())
	}
	return result, nil
}
