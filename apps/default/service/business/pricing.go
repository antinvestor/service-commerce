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
	"math"
	"sort"
	"time"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/security"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// PricingBusiness defines pricing management operations.
type PricingBusiness interface {
	SavePriceList(
		ctx context.Context,
		req *commercev1.PriceListSaveRequest,
	) (*commercev1.PriceList, error)
	GetPriceList(ctx context.Context, id string) (*commercev1.PriceList, error)
	SearchPriceLists(
		ctx context.Context,
		req *commercev1.PriceListSearchRequest,
	) ([]*commercev1.PriceList, error)

	BatchSavePriceListEntries(
		ctx context.Context,
		req *commercev1.PriceListEntryBatchSaveRequest,
	) ([]*commercev1.PriceListEntry, error)

	SaveCustomerPriceListAssignment(
		ctx context.Context,
		req *commercev1.CustomerPriceListAssignmentSaveRequest,
	) (*commercev1.CustomerPriceListAssignment, error)
	SearchCustomerPriceListAssignments(
		ctx context.Context,
		req *commercev1.CustomerPriceListAssignmentSearchRequest,
	) ([]*commercev1.CustomerPriceListAssignment, error)

	SaveCustomerPriceOverride(
		ctx context.Context,
		req *commercev1.CustomerPriceOverrideSaveRequest,
	) (*commercev1.CustomerPriceOverride, error)
	SearchCustomerPriceOverrides(
		ctx context.Context,
		req *commercev1.CustomerPriceOverrideSearchRequest,
	) ([]*commercev1.CustomerPriceOverride, error)

	SaveDiscountRule(
		ctx context.Context,
		req *commercev1.DiscountRuleSaveRequest,
	) (*commercev1.DiscountRule, error)
	SearchDiscountRules(
		ctx context.Context,
		req *commercev1.DiscountRuleSearchRequest,
	) ([]*commercev1.DiscountRule, error)

	ResolvePrice(
		ctx context.Context,
		req *commercev1.ResolvePriceRequest,
	) (*commercev1.ResolvedPrice, error)

	// GetShopIDForVariant resolves the shop ID for a product variant by
	// following the variant -> product -> shop chain.
	GetShopIDForVariant(ctx context.Context, variantID string) (string, error)
}

// NewPricingBusiness creates a new PricingBusiness.
func NewPricingBusiness(
	_ context.Context,
	priceListRepo repository.PriceListRepository,
	priceListEntryRepo repository.PriceListEntryRepository,
	assignmentRepo repository.CustomerPriceListAssignmentRepository,
	overrideRepo repository.CustomerPriceOverrideRepository,
	discountRuleRepo repository.DiscountRuleRepository,
	variantRepo repository.ProductVariantRepository,
	productRepo repository.ProductRepository,
	shopRepo repository.ShopRepository,
) PricingBusiness {
	return &pricingBusiness{
		priceListRepo:      priceListRepo,
		priceListEntryRepo: priceListEntryRepo,
		assignmentRepo:     assignmentRepo,
		overrideRepo:       overrideRepo,
		discountRuleRepo:   discountRuleRepo,
		variantRepo:        variantRepo,
		productRepo:        productRepo,
		shopRepo:           shopRepo,
	}
}

type pricingBusiness struct {
	priceListRepo      repository.PriceListRepository
	priceListEntryRepo repository.PriceListEntryRepository
	assignmentRepo     repository.CustomerPriceListAssignmentRepository
	overrideRepo       repository.CustomerPriceOverrideRepository
	discountRuleRepo   repository.DiscountRuleRepository
	variantRepo        repository.ProductVariantRepository
	productRepo        repository.ProductRepository
	shopRepo           repository.ShopRepository
}

// subjectFromContext extracts the caller's subject ID from the JWT claims in ctx.
func subjectFromContext(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	subjectID, err := claims.GetSubject()
	if err != nil {
		return ""
	}
	return subjectID
}

// --- PriceList ---

func (pb *pricingBusiness) SavePriceList(
	ctx context.Context,
	req *commercev1.PriceListSaveRequest,
) (*commercev1.PriceList, error) {
	if req.GetId() != "" {
		return pb.updatePriceList(ctx, req)
	}
	return pb.createPriceList(ctx, req)
}

func (pb *pricingBusiness) createPriceList(
	ctx context.Context,
	req *commercev1.PriceListSaveRequest,
) (*commercev1.PriceList, error) {
	if req.GetShopId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("shop_id is required"))
	}
	if req.GetName() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("name is required"))
	}

	_, err := pb.shopRepo.GetByID(ctx, req.GetShopId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}

	pl := &models.PriceList{
		ShopID:   req.GetShopId(),
		Name:     req.GetName(),
		Currency: req.GetCurrency(),
		Priority: req.GetPriority(),
		Status:   int32(commercev1.PriceListStatus_PRICE_LIST_STATUS_ACTIVE),
	}
	if req.GetStatus() != commercev1.PriceListStatus_PRICE_LIST_STATUS_UNSPECIFIED {
		pl.Status = int32(req.GetStatus())
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		pl.ValidFrom = &t
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		pl.ValidUntil = &t
	}

	if createErr := pb.priceListRepo.Create(ctx, pl); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}
	return pl.ToAPI(), nil
}

func (pb *pricingBusiness) updatePriceList(
	ctx context.Context,
	req *commercev1.PriceListSaveRequest,
) (*commercev1.PriceList, error) {
	pl, err := pb.priceListRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns := make([]string, 0)
	if req.GetName() != "" {
		pl.Name = req.GetName()
		updateColumns = append(updateColumns, fieldName)
	}
	if req.GetCurrency() != "" {
		pl.Currency = req.GetCurrency()
		updateColumns = append(updateColumns, "currency")
	}
	if req.GetPriority() != 0 {
		pl.Priority = req.GetPriority()
		updateColumns = append(updateColumns, "priority")
	}
	if req.GetStatus() != commercev1.PriceListStatus_PRICE_LIST_STATUS_UNSPECIFIED {
		pl.Status = int32(req.GetStatus())
		updateColumns = append(updateColumns, fieldStatus)
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		pl.ValidFrom = &t
		updateColumns = append(updateColumns, "valid_from")
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		pl.ValidUntil = &t
		updateColumns = append(updateColumns, "valid_until")
	}

	if len(updateColumns) > 0 {
		_, updateErr := pb.priceListRepo.Update(ctx, pl, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}
	return pl.ToAPI(), nil
}

func (pb *pricingBusiness) GetPriceList(
	ctx context.Context,
	id string,
) (*commercev1.PriceList, error) {
	pl, err := pb.priceListRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return pl.ToAPI(), nil
}

func (pb *pricingBusiness) GetShopIDForVariant(
	ctx context.Context,
	variantID string,
) (string, error) {
	variant, err := pb.variantRepo.GetByID(ctx, variantID)
	if err != nil {
		return "", connect.NewError(connect.CodeNotFound, errors.New("product variant not found"))
	}

	product, err := pb.productRepo.GetByID(ctx, variant.ProductID)
	if err != nil {
		return "", connect.NewError(
			connect.CodeInternal,
			errors.New("could not resolve product for variant"),
		)
	}
	return product.ShopID, nil
}

func (pb *pricingBusiness) SearchPriceLists(
	ctx context.Context,
	req *commercev1.PriceListSearchRequest,
) ([]*commercev1.PriceList, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	items, err := pb.priceListRepo.ListByShopID(ctx, req.GetShopId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.PriceList, 0, len(items))
	for _, item := range items {
		result = append(result, item.ToAPI())
	}
	return result, nil
}

// --- PriceListEntry ---

func (pb *pricingBusiness) BatchSavePriceListEntries(
	ctx context.Context,
	req *commercev1.PriceListEntryBatchSaveRequest,
) ([]*commercev1.PriceListEntry, error) {
	if req.GetPriceListId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("price_list_id is required"),
		)
	}

	// Validate price list exists
	_, err := pb.priceListRepo.GetByID(ctx, req.GetPriceListId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("price list not found"))
	}

	// Collect unique variant IDs and delete existing entries for them
	variantSeen := make(map[string]bool)
	for _, entry := range req.GetEntries() {
		vid := entry.GetProductVariantId()
		if vid == "" {
			continue
		}
		if !variantSeen[vid] {
			variantSeen[vid] = true
			delErr := pb.priceListEntryRepo.DeleteByPriceListAndVariant(
				ctx, req.GetPriceListId(), vid,
			)
			if delErr != nil {
				return nil, data.ErrorConvertToAPI(delErr)
			}
		}
	}

	// Create new entries
	result := make([]*commercev1.PriceListEntry, 0, len(req.GetEntries()))
	for _, entry := range req.GetEntries() {
		currency, units, nanos := models.MoneyFromProto(entry.GetUnitPrice())
		e := &models.PriceListEntry{
			PriceListID:      req.GetPriceListId(),
			ProductVariantID: entry.GetProductVariantId(),
			CurrencyCode:     currency,
			PriceUnits:       units,
			PriceNanos:       nanos,
			MinQuantity:      entry.GetMinQuantity(),
			MaxQuantity:      entry.GetMaxQuantity(),
		}
		if createErr := pb.priceListEntryRepo.Create(ctx, e); createErr != nil {
			return nil, data.ErrorConvertToAPI(createErr)
		}
		result = append(result, e.ToAPI())
	}
	return result, nil
}

// --- CustomerPriceListAssignment ---

func (pb *pricingBusiness) SaveCustomerPriceListAssignment(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSaveRequest,
) (*commercev1.CustomerPriceListAssignment, error) {
	if req.GetId() != "" {
		return pb.updateAssignment(ctx, req)
	}
	return pb.createAssignment(ctx, req)
}

func (pb *pricingBusiness) createAssignment(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSaveRequest,
) (*commercev1.CustomerPriceListAssignment, error) {
	if req.GetCustomerId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("customer_id is required"),
		)
	}
	if req.GetPriceListId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("price_list_id is required"),
		)
	}

	// Validate price list exists
	_, err := pb.priceListRepo.GetByID(ctx, req.GetPriceListId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("price list not found"))
	}

	// Check for duplicate
	existing, existErr := pb.assignmentRepo.GetByCustomerAndPriceList(
		ctx,
		req.GetCustomerId(),
		req.GetPriceListId(),
	)
	if existErr == nil && existing != nil && existing.ID != "" {
		return nil, connect.NewError(
			connect.CodeAlreadyExists,
			errors.New("assignment already exists"),
		)
	}

	a := &models.CustomerPriceListAssignment{
		CustomerID:  req.GetCustomerId(),
		PriceListID: req.GetPriceListId(),
		AssignedBy:  subjectFromContext(ctx),
		Status: int32(
			commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE,
		),
	}
	if req.GetStatus() != commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED {
		a.Status = int32(req.GetStatus())
	}

	if createErr := pb.assignmentRepo.Create(ctx, a); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}
	return a.ToAPI(), nil
}

func (pb *pricingBusiness) updateAssignment(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSaveRequest,
) (*commercev1.CustomerPriceListAssignment, error) {
	a, err := pb.assignmentRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns := make([]string, 0)
	if req.GetStatus() != commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED {
		a.Status = int32(req.GetStatus())
		updateColumns = append(updateColumns, fieldStatus)
	}

	if len(updateColumns) > 0 {
		_, updateErr := pb.assignmentRepo.Update(ctx, a, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}
	return a.ToAPI(), nil
}

func (pb *pricingBusiness) SearchCustomerPriceListAssignments(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSearchRequest,
) ([]*commercev1.CustomerPriceListAssignment, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	items, err := pb.assignmentRepo.ListByCustomerID(ctx, req.GetCustomerId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.CustomerPriceListAssignment, 0, len(items))
	for _, item := range items {
		result = append(result, item.ToAPI())
	}
	return result, nil
}

// --- CustomerPriceOverride ---

func (pb *pricingBusiness) SaveCustomerPriceOverride(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSaveRequest,
) (*commercev1.CustomerPriceOverride, error) {
	if req.GetId() != "" {
		return pb.updateOverride(ctx, req)
	}
	return pb.createOverride(ctx, req)
}

func (pb *pricingBusiness) createOverride(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSaveRequest,
) (*commercev1.CustomerPriceOverride, error) {
	if req.GetCustomerId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("customer_id is required"),
		)
	}
	if req.GetProductVariantId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("product_variant_id is required"),
		)
	}

	currency, units, nanos := models.MoneyFromProto(req.GetUnitPrice())

	o := &models.CustomerPriceOverride{
		CustomerID:       req.GetCustomerId(),
		ProductVariantID: req.GetProductVariantId(),
		CurrencyCode:     currency,
		PriceUnits:       units,
		PriceNanos:       nanos,
		ApprovedBy:       subjectFromContext(ctx),
		Status: int32(
			commercev1.CustomerPriceOverrideStatus_CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE,
		),
	}
	if req.GetStatus() != commercev1.CustomerPriceOverrideStatus_CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED {
		o.Status = int32(req.GetStatus())
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		o.ValidFrom = &t
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		o.ValidUntil = &t
	}

	if createErr := pb.overrideRepo.Create(ctx, o); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}
	return o.ToAPI(), nil
}

func (pb *pricingBusiness) updateOverride(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSaveRequest,
) (*commercev1.CustomerPriceOverride, error) {
	o, err := pb.overrideRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns := make([]string, 0)
	if req.GetUnitPrice() != nil {
		currency, units, nanos := models.MoneyFromProto(req.GetUnitPrice())
		o.CurrencyCode = currency
		o.PriceUnits = units
		o.PriceNanos = nanos
		updateColumns = append(updateColumns, "currency_code", "price_units", "price_nanos")
	}
	if req.GetStatus() != commercev1.CustomerPriceOverrideStatus_CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED {
		o.Status = int32(req.GetStatus())
		updateColumns = append(updateColumns, fieldStatus)
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		o.ValidFrom = &t
		updateColumns = append(updateColumns, "valid_from")
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		o.ValidUntil = &t
		updateColumns = append(updateColumns, "valid_until")
	}
	// Always record the current caller as the approver on updates.
	if subject := subjectFromContext(ctx); subject != "" {
		o.ApprovedBy = subject
		updateColumns = append(updateColumns, "approved_by")
	}

	if len(updateColumns) > 0 {
		_, updateErr := pb.overrideRepo.Update(ctx, o, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}
	return o.ToAPI(), nil
}

func (pb *pricingBusiness) SearchCustomerPriceOverrides(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSearchRequest,
) ([]*commercev1.CustomerPriceOverride, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	items, err := pb.overrideRepo.ListByCustomerID(ctx, req.GetCustomerId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.CustomerPriceOverride, 0, len(items))
	for _, item := range items {
		result = append(result, item.ToAPI())
	}
	return result, nil
}

// --- DiscountRule ---

func (pb *pricingBusiness) SaveDiscountRule(
	ctx context.Context,
	req *commercev1.DiscountRuleSaveRequest,
) (*commercev1.DiscountRule, error) {
	if req.GetId() != "" {
		return pb.updateDiscountRule(ctx, req)
	}
	return pb.createDiscountRule(ctx, req)
}

func (pb *pricingBusiness) createDiscountRule(
	ctx context.Context,
	req *commercev1.DiscountRuleSaveRequest,
) (*commercev1.DiscountRule, error) {
	if req.GetShopId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("shop_id is required"))
	}
	if req.GetName() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("name is required"))
	}

	_, err := pb.shopRepo.GetByID(ctx, req.GetShopId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}

	conditions := data.JSONMap{}
	if req.GetConditions() != nil {
		conditions = conditions.FromProtoStruct(req.GetConditions())
	}

	dr := &models.DiscountRule{
		ShopID:             req.GetShopId(),
		Name:               req.GetName(),
		DiscountType:       int32(req.GetDiscountType()),
		Value:              req.GetValue(),
		AppliesTo:          int32(req.GetAppliesTo()),
		Conditions:         conditions,
		RequiresApproval:   req.GetRequiresApproval(),
		MaxDiscountPercent: req.GetMaxDiscountPercent(),
		Status:             int32(commercev1.DiscountRuleStatus_DISCOUNT_RULE_STATUS_ACTIVE),
	}
	if req.GetStatus() != commercev1.DiscountRuleStatus_DISCOUNT_RULE_STATUS_UNSPECIFIED {
		dr.Status = int32(req.GetStatus())
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		dr.ValidFrom = &t
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		dr.ValidUntil = &t
	}

	if createErr := pb.discountRuleRepo.Create(ctx, dr); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}
	return dr.ToAPI(), nil
}

func (pb *pricingBusiness) updateDiscountRule(
	ctx context.Context,
	req *commercev1.DiscountRuleSaveRequest,
) (*commercev1.DiscountRule, error) {
	dr, err := pb.discountRuleRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns := make([]string, 0)
	if req.GetName() != "" {
		dr.Name = req.GetName()
		updateColumns = append(updateColumns, fieldName)
	}
	if req.GetDiscountType() != commercev1.DiscountType_DISCOUNT_TYPE_UNSPECIFIED {
		dr.DiscountType = int32(req.GetDiscountType())
		updateColumns = append(updateColumns, "discount_type")
	}
	if req.GetValue() != 0 {
		dr.Value = req.GetValue()
		updateColumns = append(updateColumns, "value")
	}
	if req.GetAppliesTo() != commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_UNSPECIFIED {
		dr.AppliesTo = int32(req.GetAppliesTo())
		updateColumns = append(updateColumns, "applies_to")
	}
	if req.GetConditions() != nil {
		conditions := data.JSONMap{}
		dr.Conditions = conditions.FromProtoStruct(req.GetConditions())
		updateColumns = append(updateColumns, "conditions")
	}
	if req.GetStatus() != commercev1.DiscountRuleStatus_DISCOUNT_RULE_STATUS_UNSPECIFIED {
		dr.Status = int32(req.GetStatus())
		updateColumns = append(updateColumns, fieldStatus)
	}
	if req.GetValidFrom() != nil {
		t := req.GetValidFrom().AsTime()
		dr.ValidFrom = &t
		updateColumns = append(updateColumns, "valid_from")
	}
	if req.GetValidUntil() != nil {
		t := req.GetValidUntil().AsTime()
		dr.ValidUntil = &t
		updateColumns = append(updateColumns, "valid_until")
	}

	if len(updateColumns) > 0 {
		_, updateErr := pb.discountRuleRepo.Update(ctx, dr, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}
	return dr.ToAPI(), nil
}

func (pb *pricingBusiness) SearchDiscountRules(
	ctx context.Context,
	req *commercev1.DiscountRuleSearchRequest,
) ([]*commercev1.DiscountRule, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	items, err := pb.discountRuleRepo.ListByShopID(ctx, req.GetShopId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.DiscountRule, 0, len(items))
	for _, item := range items {
		result = append(result, item.ToAPI())
	}
	return result, nil
}

// --- ResolvePrice ---

func (pb *pricingBusiness) ResolvePrice(
	ctx context.Context,
	req *commercev1.ResolvePriceRequest,
) (*commercev1.ResolvedPrice, error) {
	if req.GetProductVariantId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("product_variant_id is required"),
		)
	}

	// Get the base variant for catalog price fallback
	variant, err := pb.variantRepo.GetByID(ctx, req.GetProductVariantId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("product variant not found"))
	}

	// Resolve the shop ID through the product
	product, productErr := pb.productRepo.GetByID(ctx, variant.ProductID)
	if productErr != nil {
		return nil, connect.NewError(
			connect.CodeInternal,
			errors.New("could not resolve product for variant"),
		)
	}
	shopID := product.ShopID

	resolved := &commercev1.ResolvedPrice{
		VariantId: req.GetProductVariantId(),
	}

	// Step 1: Check CustomerPriceOverride
	if req.GetCustomerId() != "" {
		override, overrideErr := pb.overrideRepo.GetByCustomerAndVariant(
			ctx,
			req.GetCustomerId(),
			req.GetProductVariantId(),
		)
		if overrideErr == nil && override != nil && override.ID != "" {
			resolved.UnitPrice = models.MoneyToProto(
				override.CurrencyCode,
				override.PriceUnits,
				override.PriceNanos,
			)
			resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_CUSTOMER_OVERRIDE
			resolved.OverrideId = override.ID
			return pb.applyDiscounts(ctx, resolved, shopID)
		}
	}

	// Step 2: Check PriceList assignments
	if req.GetCustomerId() != "" {
		priceListPrice := pb.resolveFromPriceLists(
			ctx,
			req.GetCustomerId(),
			req.GetProductVariantId(),
			req.GetQuantity(),
		)
		if priceListPrice != nil {
			resolved.UnitPrice = priceListPrice.unitPrice
			resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_PRICE_LIST
			resolved.PriceListId = priceListPrice.priceListID
			return pb.applyDiscounts(ctx, resolved, shopID)
		}
	}

	// Step 3: Fall back to catalog price
	resolved.UnitPrice = models.MoneyToProto(
		variant.CurrencyCode,
		variant.PriceUnits,
		variant.PriceNanos,
	)
	resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_CATALOG

	return pb.applyDiscounts(ctx, resolved, shopID)
}

type priceListMatch struct {
	unitPrice   *commonv1.Money
	priceListID string
	priority    int32
}

// Assignment lookup limit for price list resolution.
const maxAssignmentLookup = 100

// percentDivisor is used for percentage calculations to avoid magic numbers.
const percentDivisor = 100.0

func (pb *pricingBusiness) resolveFromPriceLists(
	ctx context.Context,
	customerID, variantID string,
	quantity int32,
) *priceListMatch {
	assignments, err := pb.assignmentRepo.ListByCustomerID(
		ctx, customerID, maxAssignmentLookup, 0,
	)
	if err != nil || len(assignments) == 0 {
		return nil
	}

	var matches []*priceListMatch
	for _, assignment := range assignments {
		m := pb.matchPriceListEntry(ctx, assignment, variantID, quantity)
		if m != nil {
			matches = append(matches, m)
		}
	}

	if len(matches) == 0 {
		return nil
	}

	sort.Slice(matches, func(i, j int) bool {
		return matches[i].priority > matches[j].priority
	})
	return matches[0]
}

func (pb *pricingBusiness) matchPriceListEntry(
	ctx context.Context,
	assignment *models.CustomerPriceListAssignment,
	variantID string,
	quantity int32,
) *priceListMatch {
	activeStatus := int32(
		commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE,
	)
	if assignment.Status != activeStatus {
		return nil
	}

	pl, plErr := pb.priceListRepo.GetByID(ctx, assignment.PriceListID)
	if plErr != nil {
		return nil
	}

	if !isPriceListActive(pl) {
		return nil
	}

	entries, entryErr := pb.priceListEntryRepo.GetByPriceListAndVariant(ctx, pl.ID, variantID)
	if entryErr != nil || len(entries) == 0 {
		return nil
	}

	for _, entry := range entries {
		if entry.MinQuantity > 0 && quantity < entry.MinQuantity {
			continue
		}
		if entry.MaxQuantity > 0 && quantity > entry.MaxQuantity {
			continue
		}
		return &priceListMatch{
			unitPrice: models.MoneyToProto(
				entry.CurrencyCode,
				entry.PriceUnits,
				entry.PriceNanos,
			),
			priceListID: pl.ID,
			priority:    pl.Priority,
		}
	}
	return nil
}

func isPriceListActive(pl *models.PriceList) bool {
	if pl.Status != int32(commercev1.PriceListStatus_PRICE_LIST_STATUS_ACTIVE) {
		return false
	}
	now := time.Now()
	if pl.ValidFrom != nil && now.Before(*pl.ValidFrom) {
		return false
	}
	if pl.ValidUntil != nil && now.After(*pl.ValidUntil) {
		return false
	}
	return true
}

func (pb *pricingBusiness) applyDiscounts(
	ctx context.Context,
	resolved *commercev1.ResolvedPrice,
	shopID string,
) (*commercev1.ResolvedPrice, error) {
	if resolved.GetUnitPrice() == nil {
		return resolved, nil
	}

	rules, err := pb.discountRuleRepo.ListActive(ctx, shopID)
	if err != nil {
		return resolved, nil //nolint:nilerr // no active rules is not an error
	}
	if len(rules) == 0 {
		return resolved, nil
	}

	var bestRule *models.DiscountRule
	var bestDiscountAmount int64

	for _, rule := range rules {
		if rule.AppliesTo != int32(commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM) &&
			rule.AppliesTo != int32(commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_ORDER) {
			continue
		}

		discountAmount := calculateDiscount(rule, resolved.GetUnitPrice())
		if discountAmount > bestDiscountAmount {
			bestDiscountAmount = discountAmount
			bestRule = rule
		}
	}

	if bestRule == nil || bestDiscountAmount <= 0 {
		return resolved, nil
	}

	preDiscount := resolved.GetUnitPrice()
	resolved.PreDiscountPrice = preDiscount

	unitNanos := preDiscount.GetUnits()*nanosFactor + int64(preDiscount.GetNanos())
	finalNanos := unitNanos - bestDiscountAmount
	if finalNanos < 0 {
		finalNanos = 0
	}

	resolved.UnitPrice = &commonv1.Money{
		CurrencyCode: preDiscount.GetCurrencyCode(),
		Units:        finalNanos / nanosFactor,
		Nanos:        int32(finalNanos % nanosFactor),
	}
	resolved.DiscountAmount = &commonv1.Money{
		CurrencyCode: preDiscount.GetCurrencyCode(),
		Units:        bestDiscountAmount / nanosFactor,
		Nanos:        int32(bestDiscountAmount % nanosFactor),
	}
	resolved.DiscountRuleId = bestRule.ID

	return resolved, nil
}

const nanosFactor = 1_000_000_000

func calculateDiscount(rule *models.DiscountRule, price *commonv1.Money) int64 {
	priceNanos := price.GetUnits()*nanosFactor + int64(price.GetNanos())
	if priceNanos <= 0 {
		return 0
	}

	var discountNanos int64

	switch commercev1.DiscountType(rule.DiscountType) {
	case commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE:
		discountNanos = int64(math.Round(
			float64(priceNanos) * rule.Value / percentDivisor,
		))
	case commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT:
		discountNanos = int64(rule.Value * float64(nanosFactor))
	case commercev1.DiscountType_DISCOUNT_TYPE_UNSPECIFIED:
		return 0
	default:
		return 0
	}

	if rule.MaxDiscountPercent > 0 {
		maxNanos := int64(math.Round(
			float64(priceNanos) * rule.MaxDiscountPercent / percentDivisor,
		))
		if discountNanos > maxNanos {
			discountNanos = maxNanos
		}
	}

	if discountNanos > priceNanos {
		discountNanos = priceNanos
	}

	return discountNanos
}
