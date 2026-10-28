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
	"fmt"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"golang.org/x/text/currency"

	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type SupplierBusiness interface {
	SaveSupplier(ctx context.Context, req *procurementv1.SupplierSaveRequest) (*procurementv1.Supplier, error)
	GetSupplier(ctx context.Context, id string) (*procurementv1.Supplier, error)
	SearchSuppliers(
		ctx context.Context,
		req *procurementv1.SupplierSearchRequest,
	) ([]*procurementv1.Supplier, string, error)
	SaveSupplierItem(
		ctx context.Context,
		req *procurementv1.SupplierItemSaveRequest,
	) (*procurementv1.SupplierItem, error)
	SearchSupplierItems(
		ctx context.Context,
		req *procurementv1.SupplierItemSearchRequest,
	) ([]*procurementv1.SupplierItem, string, error)
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
		return nil, connect.NewError(connect.CodeInvalidArgument, "supplier name is required")
	}
	if code := req.GetCurrency(); code != "" {
		if _, err := currency.ParseISO(code); err != nil || len(code) != 3 {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("currency %q is not an ISO 4217 code", code))
		}
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
) ([]*procurementv1.Supplier, string, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, "", err
	}
	filter := repository.SupplierFilter{
		Status:       int32(req.GetStatus()),
		SupplierType: int32(req.GetSupplierType()),
	}
	// With no filter at all the active suppliers are listed.
	if filter.Status == 0 && filter.SupplierType == 0 {
		filter.Status = int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE)
	}
	suppliers, next, err := sb.supplierRepo.ListPage(ctx, filter, page)
	if err != nil {
		return nil, "", data.ErrorConvertToAPI(err)
	}
	result := make([]*procurementv1.Supplier, 0, len(suppliers))
	for _, s := range suppliers {
		result = append(result, s.ToAPI())
	}
	return result, repository.EncodePageKey(next), nil
}

func (sb *supplierBusiness) SaveSupplierItem(
	ctx context.Context,
	req *procurementv1.SupplierItemSaveRequest,
) (*procurementv1.SupplierItem, error) {
	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "supplier_id is required")
	}
	if _, err := sb.supplierRepo.GetByID(ctx, req.GetSupplierId()); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "supplier not found")
	}
	currencyCode, priceUnits, priceNanos, err := unitPrice(req.GetUnitPrice())
	if err != nil {
		return nil, err
	}
	moq, err := quantityArg("min_order_quantity", req.GetMinOrderQuantity())
	if err != nil {
		return nil, err
	}

	if req.GetId() != "" {
		return sb.updateSupplierItem(ctx, req, currencyCode, priceUnits, priceNanos, moq)
	}

	kind, err := supplyTarget(req)
	if err != nil {
		return nil, err
	}
	if kind == procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT && !moq.IsWhole() {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"a product variant is bought in whole units; min_order_quantity must be whole")
	}
	item := &models.SupplierItem{
		SupplierID:       req.GetSupplierId(),
		InventoryItemID:  req.GetInventoryItemId(),
		SupplyKind:       int32(kind),
		ProductVariantID: req.GetProductVariantId(),
		SupplierSKU:      req.GetSupplierSku(),
		CurrencyCode:     currencyCode,
		PriceUnits:       priceUnits,
		PriceNanos:       priceNanos,
		MinOrderQuantity: moq,
		Unit:             req.GetUnit(),
		LeadTimeDays:     req.GetLeadTimeDays(),
		Status:           int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE),
	}
	if createErr := sb.supplierItemRepo.Create(ctx, item); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}
	return item.ToAPI(), nil
}

// supplyTarget checks that a new item names exactly what its kind supplies:
// an inventory item for a material (the default), a variant for resale.
func supplyTarget(req *procurementv1.SupplierItemSaveRequest) (procurementv1.SupplyKind, error) {
	switch req.GetSupplyKind() {
	case procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT:
		if req.GetProductVariantId() == "" || req.GetInventoryItemId() != "" {
			return 0, connect.NewError(connect.CodeInvalidArgument,
				"a product variant item needs product_variant_id and no inventory_item_id")
		}
		return procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, nil
	case procurementv1.SupplyKind_SUPPLY_KIND_UNSPECIFIED, procurementv1.SupplyKind_SUPPLY_KIND_MATERIAL:
		if req.GetInventoryItemId() == "" || req.GetProductVariantId() != "" {
			return 0, connect.NewError(connect.CodeInvalidArgument,
				"a material item needs inventory_item_id and no product_variant_id")
		}
		return procurementv1.SupplyKind_SUPPLY_KIND_MATERIAL, nil
	default:
		return 0, connect.NewError(connect.CodeInvalidArgument, "unknown supply_kind")
	}
}

// updateSupplierItem changes an item's terms. What it supplies is fixed at
// creation, since orders and receipts already point at it.
func (sb *supplierBusiness) updateSupplierItem(
	ctx context.Context,
	req *procurementv1.SupplierItemSaveRequest,
	currencyCode string,
	priceUnits int64,
	priceNanos int32,
	moq models.Quantity,
) (*procurementv1.SupplierItem, error) {
	item, err := sb.supplierItemRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if item.SupplierID != req.GetSupplierId() {
		return nil, connect.NewError(connect.CodeInvalidArgument, "supplier item belongs to another supplier")
	}
	if (req.GetInventoryItemId() != "" && req.GetInventoryItemId() != item.InventoryItemID) ||
		(req.GetProductVariantId() != "" && req.GetProductVariantId() != item.ProductVariantID) ||
		(req.GetSupplyKind() != procurementv1.SupplyKind_SUPPLY_KIND_UNSPECIFIED &&
			int32(req.GetSupplyKind()) != item.SupplyKind) {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"what a supplier item supplies cannot change; create another item")
	}
	if item.SupplyKind == int32(procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT) && !moq.IsWhole() {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"a product variant is bought in whole units; min_order_quantity must be whole")
	}

	item.SupplierSKU = req.GetSupplierSku()
	item.CurrencyCode = currencyCode
	item.PriceUnits = priceUnits
	item.PriceNanos = priceNanos
	item.MinOrderQuantity = moq
	item.Unit = req.GetUnit()
	item.LeadTimeDays = req.GetLeadTimeDays()
	if req.GetStatus() != procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_UNSPECIFIED {
		item.Status = int32(req.GetStatus())
	}
	if _, updateErr := sb.supplierItemRepo.Update(ctx, item,
		"supplier_sku", "currency_code", "price_units", "price_nanos",
		"min_order_quantity", "unit", "lead_time_days", "status",
	); updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}
	return item.ToAPI(), nil
}

func (sb *supplierBusiness) SearchSupplierItems(
	ctx context.Context,
	req *procurementv1.SupplierItemSearchRequest,
) ([]*procurementv1.SupplierItem, string, error) {
	if req.GetSupplierId() == "" && req.GetInventoryItemId() == "" {
		return nil, "", connect.NewError(connect.CodeInvalidArgument,
			"supplier_id or inventory_item_id is required")
	}
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, "", err
	}
	items, next, err := sb.supplierItemRepo.ListPage(ctx, repository.SupplierItemFilter{
		SupplierID: req.GetSupplierId(), InventoryItemID: req.GetInventoryItemId(),
	}, page)
	if err != nil {
		return nil, "", data.ErrorConvertToAPI(err)
	}
	result := make([]*procurementv1.SupplierItem, 0, len(items))
	for _, si := range items {
		result = append(result, si.ToAPI())
	}
	return result, repository.EncodePageKey(next), nil
}

// pageFromSearch reads the common search cursor; an undecodable page is an
// InvalidArgument and the limit is clamped by the repository.
func pageFromSearch(search *commonv1.SearchRequest) (repository.Page, error) {
	cursor := search.GetCursor()
	after, err := repository.DecodePageKey(cursor.GetPage())
	if err != nil {
		return repository.Page{}, connect.NewError(connect.CodeInvalidArgument, err.Error())
	}
	return repository.Page{Limit: int(cursor.GetLimit()), After: after}, nil
}
