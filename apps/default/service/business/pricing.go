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
	"encoding/json"
	"math"
	"slices"
	"sort"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// PriceListPage is one page of price lists plus the next cursor.
type PriceListPage struct {
	Items    []*commercev1.PriceList
	NextPage string
}

// AssignmentPage is one page of customer price list assignments.
type AssignmentPage struct {
	Items    []*commercev1.CustomerPriceListAssignment
	NextPage string
}

// OverridePage is one page of customer price overrides.
type OverridePage struct {
	Items    []*commercev1.CustomerPriceOverride
	NextPage string
}

// DiscountRulePage is one page of discount rules.
type DiscountRulePage struct {
	Items    []*commercev1.DiscountRule
	NextPage string
}

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
	) (*PriceListPage, error)

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
	) (*AssignmentPage, error)

	SaveCustomerPriceOverride(
		ctx context.Context,
		req *commercev1.CustomerPriceOverrideSaveRequest,
	) (*commercev1.CustomerPriceOverride, error)
	SearchCustomerPriceOverrides(
		ctx context.Context,
		req *commercev1.CustomerPriceOverrideSearchRequest,
	) (*OverridePage, error)

	SaveDiscountRule(
		ctx context.Context,
		req *commercev1.DiscountRuleSaveRequest,
	) (*commercev1.DiscountRule, error)
	// ApproveDiscountRule records the caller's approval so pricing may
	// apply a rule that requires one.
	ApproveDiscountRule(ctx context.Context, id string) (*commercev1.DiscountRule, error)
	// GetDiscountRuleShopID resolves the shop that owns a discount rule.
	GetDiscountRuleShopID(ctx context.Context, id string) (string, error)
	SearchDiscountRules(
		ctx context.Context,
		req *commercev1.DiscountRuleSearchRequest,
	) (*DiscountRulePage, error)

	ResolvePrice(
		ctx context.Context,
		req *commercev1.ResolvePriceRequest,
	) (*commercev1.ResolvedPrice, error)
	// QuotePrices prices several variants of one shop for a customer at
	// once; see PriceResolver.
	QuotePrices(
		ctx context.Context,
		shopID, customerID string,
		queries []PriceQuery,
	) ([]*commercev1.ResolvedPrice, error)

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
		return nil, connect.NewError(connect.CodeInvalidArgument, "shop_id is required")
	}
	if req.GetName() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "name is required")
	}

	currency, err := shopCurrency(ctx, pb.shopRepo, req.GetShopId())
	if err != nil {
		return nil, err
	}
	if req.GetCurrency() != "" {
		if currency, err = listCurrency(req.GetCurrency(), currency); err != nil {
			return nil, err
		}
	}

	pl := &models.PriceList{
		ShopID:   req.GetShopId(),
		Name:     req.GetName(),
		Currency: currency,
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
		shopCode, currencyErr := shopCurrency(ctx, pb.shopRepo, pl.ShopID)
		if currencyErr != nil {
			return nil, currencyErr
		}
		if pl.Currency, currencyErr = listCurrency(req.GetCurrency(), shopCode); currencyErr != nil {
			return nil, currencyErr
		}
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

// listCurrency is the currency a price list is set to: a valid code, the
// shop's own when it has one.
func listCurrency(requested, shopCode string) (string, error) {
	code := normalizeCurrency(requested)
	switch {
	case code == "":
		return "", connect.NewError(connect.CodeInvalidArgument, "currency must be an ISO 4217 code")
	case shopCode != "" && code != shopCode:
		return "", connect.NewError(connect.CodeInvalidArgument,
			"a price list must be in the shop's currency, "+shopCode)
	}
	return code, nil
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
		return "", connect.NewError(connect.CodeNotFound, "product variant not found")
	}

	product, err := pb.productRepo.GetByID(ctx, variant.ProductID)
	if err != nil {
		return "", connect.NewError(
			connect.CodeInternal,
			"could not resolve product for variant")
	}
	return product.ShopID, nil
}

func (pb *pricingBusiness) SearchPriceLists(
	ctx context.Context,
	req *commercev1.PriceListSearchRequest,
) (*PriceListPage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	items, next, err := pb.priceListRepo.ListByShopID(ctx, req.GetShopId(), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &PriceListPage{Items: make([]*commercev1.PriceList, 0, len(items)), NextPage: nextCursor(next)}
	for _, item := range items {
		result.Items = append(result.Items, item.ToAPI())
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
			"price_list_id is required")
	}

	pl, err := pb.priceListRepo.GetByID(ctx, req.GetPriceListId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "price list not found")
	}

	currency, err := shopCurrency(ctx, pb.shopRepo, pl.ShopID)
	if err != nil {
		return nil, err
	}

	entries := make([]*models.PriceListEntry, 0, len(req.GetEntries()))
	variantShops := map[string]string{}
	for _, entry := range req.GetEntries() {
		e, entryErr := pb.listEntry(ctx, pl, currency, entry, variantShops)
		if entryErr != nil {
			return nil, entryErr
		}
		entries = append(entries, e)
	}

	if err = checkBands(entries); err != nil {
		return nil, err
	}

	// Replace existing entries for the touched variants and insert the new
	// ones atomically.
	if replaceErr := pb.priceListEntryRepo.ReplaceEntries(ctx, req.GetPriceListId(), entries); replaceErr != nil {
		return nil, data.ErrorConvertToAPI(replaceErr)
	}

	result := make([]*commercev1.PriceListEntry, 0, len(entries))
	for _, e := range entries {
		result = append(result, e.ToAPI())
	}
	return result, nil
}

// listEntry checks one entry of a batch save for pl, whose shop prices in
// currency. variantShops remembers each variant's shop across the batch.
func (pb *pricingBusiness) listEntry(
	ctx context.Context,
	pl *models.PriceList,
	currency string,
	entry *commercev1.PriceListEntry,
	variantShops map[string]string,
) (*models.PriceListEntry, error) {
	if entry.GetProductVariantId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "every entry needs a product_variant_id")
	}
	// A price list prices only its own shop's variants; the caller was
	// authorised on that shop alone.
	shopID, seen := variantShops[entry.GetProductVariantId()]
	if !seen {
		var err error
		if shopID, err = pb.GetShopIDForVariant(ctx, entry.GetProductVariantId()); err != nil {
			return nil, err
		}
		variantShops[entry.GetProductVariantId()] = shopID
	}
	if shopID != pl.ShopID {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"every entry's variant must belong to the price list's shop")
	}
	price, err := validateMoney(entry.GetUnitPrice(), currency, "every entry's unit_price")
	if err != nil {
		return nil, err
	}
	if entry.GetMinQuantity() < 0 || entry.GetMaxQuantity() < 0 ||
		(entry.GetMaxQuantity() > 0 && entry.GetMaxQuantity() < entry.GetMinQuantity()) {
		return nil, connect.NewError(connect.CodeInvalidArgument, "entry quantity band is invalid")
	}
	priceCurrency, units, nanos := models.MoneyFromProto(price)
	return &models.PriceListEntry{
		PriceListID:      pl.GetID(),
		ProductVariantID: entry.GetProductVariantId(),
		CurrencyCode:     priceCurrency,
		PriceUnits:       units,
		PriceNanos:       nanos,
		MinQuantity:      entry.GetMinQuantity(),
		MaxQuantity:      entry.GetMaxQuantity(),
	}, nil
}

// checkBands refuses quantity bands that overlap for one variant: a
// quantity must have one price on a list. The save replaces each touched
// variant's entries, so only the request's own entries can overlap.
func checkBands(entries []*models.PriceListEntry) error {
	byVariant := map[string][]*models.PriceListEntry{}
	for _, e := range entries {
		byVariant[e.ProductVariantID] = append(byVariant[e.ProductVariantID], e)
	}
	for _, bands := range byVariant {
		sort.Slice(bands, func(i, j int) bool { return bandFloor(bands[i]) < bandFloor(bands[j]) })
		for i := 1; i < len(bands); i++ {
			previous := bands[i-1]
			if previous.MaxQuantity <= 0 || bandFloor(bands[i]) <= previous.MaxQuantity {
				return connect.NewError(connect.CodeInvalidArgument,
					"a variant's quantity bands on one price list must not overlap")
			}
		}
	}
	return nil
}

// bandFloor is the smallest quantity a band prices.
func bandFloor(e *models.PriceListEntry) int32 {
	return max(e.MinQuantity, 1)
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
			"customer_id is required")
	}
	if req.GetPriceListId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			"price_list_id is required")
	}

	// Validate price list exists
	_, err := pb.priceListRepo.GetByID(ctx, req.GetPriceListId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "price list not found")
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
			"assignment already exists")
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
	// The caller was authorised against the request's price list; an
	// assignment on another list is not theirs to change.
	if a.PriceListID != req.GetPriceListId() {
		return nil, connect.NewError(connect.CodeNotFound, "assignment not found")
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
) (*AssignmentPage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	items, next, err := pb.assignmentRepo.ListByCustomerID(ctx, req.GetCustomerId(), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &AssignmentPage{
		Items:    make([]*commercev1.CustomerPriceListAssignment, 0, len(items)),
		NextPage: nextCursor(next),
	}
	for _, item := range items {
		if req.GetPriceListId() != "" && item.PriceListID != req.GetPriceListId() {
			continue
		}
		result.Items = append(result.Items, item.ToAPI())
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
			"customer_id is required")
	}
	if req.GetProductVariantId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			"product_variant_id is required")
	}

	price, err := pb.validateVariantPrice(ctx, req.GetProductVariantId(), req.GetUnitPrice())
	if err != nil {
		return nil, err
	}
	currency, units, nanos := models.MoneyFromProto(price)

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
	// The caller was authorised against the request's variant (and so its
	// shop); an override on another variant is not theirs to change.
	if o.ProductVariantID != req.GetProductVariantId() {
		return nil, connect.NewError(connect.CodeNotFound, "override not found")
	}

	updateColumns := make([]string, 0)
	if req.GetUnitPrice() != nil {
		price, priceErr := pb.validateVariantPrice(ctx, o.ProductVariantID, req.GetUnitPrice())
		if priceErr != nil {
			return nil, priceErr
		}
		currency, units, nanos := models.MoneyFromProto(price)
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

// validateVariantPrice checks a price set for variantID against its shop's
// currency.
func (pb *pricingBusiness) validateVariantPrice(
	ctx context.Context,
	variantID string,
	price *commonv1.Money,
) (*commonv1.Money, error) {
	shopID, err := pb.GetShopIDForVariant(ctx, variantID)
	if err != nil {
		return nil, err
	}
	currency, err := shopCurrency(ctx, pb.shopRepo, shopID)
	if err != nil {
		return nil, err
	}
	return validateMoney(price, currency, "unit_price")
}

func (pb *pricingBusiness) SearchCustomerPriceOverrides(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSearchRequest,
) (*OverridePage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	items, next, err := pb.overrideRepo.ListByCustomerID(ctx, req.GetCustomerId(), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &OverridePage{
		Items:    make([]*commercev1.CustomerPriceOverride, 0, len(items)),
		NextPage: nextCursor(next),
	}
	for _, item := range items {
		if req.GetProductVariantId() != "" && item.ProductVariantID != req.GetProductVariantId() {
			continue
		}
		result.Items = append(result.Items, item.ToAPI())
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
		return nil, connect.NewError(connect.CodeInvalidArgument, "shop_id is required")
	}
	if req.GetName() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "name is required")
	}

	currency, err := shopCurrency(ctx, pb.shopRepo, req.GetShopId())
	if err != nil {
		return nil, err
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
	if err = setDiscountTerms(dr, currency); err != nil {
		return nil, err
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
	// Approval can be demanded by any update. Waiving it needs the field in
	// the update mask (the handler then requires discount_approve), so a
	// partial update can never make a guarded rule apply unchecked.
	if req.GetRequiresApproval() != dr.RequiresApproval &&
		(req.GetRequiresApproval() || slices.Contains(req.GetUpdateMask().GetPaths(), "requires_approval")) {
		dr.RequiresApproval = req.GetRequiresApproval()
		updateColumns = append(updateColumns, "requires_approval")
	}
	// An approval covers the terms that were approved; changing what the
	// rule gives away needs a fresh one.
	if updateColumns, err = pb.refreshDiscountTerms(ctx, dr, updateColumns); err != nil {
		return nil, err
	}
	if dr.ApprovedAt != nil && slices.ContainsFunc(updateColumns, func(c string) bool {
		return c == "discount_type" || c == "value" || c == "applies_to" || c == "conditions"
	}) {
		dr.ApprovedAt = nil
		dr.ApprovedBy = ""
		updateColumns = append(updateColumns, "approved_at", "approved_by")
	}

	if len(updateColumns) > 0 {
		_, updateErr := pb.discountRuleRepo.Update(ctx, dr, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}
	return dr.ToAPI(), nil
}

// refreshDiscountTerms re-checks what dr gives away when an update changed
// its type or value, adding the columns that changes.
func (pb *pricingBusiness) refreshDiscountTerms(
	ctx context.Context,
	dr *models.DiscountRule,
	columns []string,
) ([]string, error) {
	if !slices.ContainsFunc(columns, func(c string) bool { return c == "discount_type" || c == "value" }) {
		return columns, nil
	}
	currency, err := shopCurrency(ctx, pb.shopRepo, dr.ShopID)
	if err != nil {
		return nil, err
	}
	if err = setDiscountTerms(dr, currency); err != nil {
		return nil, err
	}
	return append(columns, "amount_currency", "amount_units", "amount_nanos"), nil
}

// setDiscountTerms checks what dr gives away and, for a fixed amount, fixes
// it as money in the shop's currency.
func setDiscountTerms(dr *models.DiscountRule, currency string) error {
	invalid := func(msg string) error { return connect.NewError(connect.CodeInvalidArgument, msg) }
	if math.IsNaN(dr.MaxDiscountPercent) || dr.MaxDiscountPercent < 0 || dr.MaxDiscountPercent > percentDivisor {
		return invalid("max_discount_percent must be between 0 and 100")
	}
	dr.AmountCurrency, dr.AmountUnits, dr.AmountNanos = "", 0, 0
	switch commercev1.DiscountType(dr.DiscountType) {
	case commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE:
		if math.IsNaN(dr.Value) || dr.Value < 0 || dr.Value > percentDivisor {
			return invalid("a percentage discount must be between 0 and 100")
		}
	case commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT:
		if currency == "" {
			return invalid("the shop needs a currency before it can give a fixed discount")
		}
		amount, err := moneyFromDecimal(dr.Value, currency, "a fixed discount")
		if err != nil {
			return err
		}
		dr.AmountCurrency, dr.AmountUnits, dr.AmountNanos = models.MoneyFromProto(amount)
	case commercev1.DiscountType_DISCOUNT_TYPE_UNSPECIFIED:
		return invalid("discount_type is required")
	default:
		return invalid("discount_type is not supported")
	}
	return nil
}

func (pb *pricingBusiness) SearchDiscountRules(
	ctx context.Context,
	req *commercev1.DiscountRuleSearchRequest,
) (*DiscountRulePage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	items, next, err := pb.discountRuleRepo.ListByShopID(ctx, req.GetShopId(), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &DiscountRulePage{Items: make([]*commercev1.DiscountRule, 0, len(items)), NextPage: nextCursor(next)}
	for _, item := range items {
		result.Items = append(result.Items, item.ToAPI())
	}
	return result, nil
}

// --- ResolvePrice ---

// PriceQuery is one line to price: a variant, the product it belongs to and
// the quantity bought.
type PriceQuery struct {
	Variant  *models.ProductVariant
	Product  *models.Product
	Quantity int64
}

func (pb *pricingBusiness) ResolvePrice(
	ctx context.Context,
	req *commercev1.ResolvePriceRequest,
) (*commercev1.ResolvedPrice, error) {
	if req.GetProductVariantId() == "" {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			"product_variant_id is required")
	}

	variant, err := pb.variantRepo.GetByID(ctx, req.GetProductVariantId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "product variant not found")
	}
	product := variant.Product
	if product == nil || product.ShopID == "" {
		if product, err = pb.productRepo.GetByID(ctx, variant.ProductID); err != nil {
			return nil, connect.NewError(connect.CodeInternal, "could not resolve product for variant")
		}
	}
	quoted, err := pb.QuotePrices(ctx, product.ShopID, req.GetCustomerId(), []PriceQuery{{
		Variant: variant, Product: product, Quantity: int64(req.GetQuantity()),
	}})
	if err != nil {
		return nil, err
	}
	return quoted[0], nil
}

// QuotePrices prices every query for customerID (none for list prices) in
// shopID. What pricing depends on (overrides, price lists and their
// entries, discount rules) is loaded once for all of them, so an order
// costs the same few queries however many lines it has. For each line the
// customer's own override wins, then the highest-priority active price
// list with an entry whose quantity band holds the quantity, then the
// catalogue price; the best applicable discount comes off that.
func (pb *pricingBusiness) QuotePrices(
	ctx context.Context,
	shopID, customerID string,
	queries []PriceQuery,
) ([]*commercev1.ResolvedPrice, error) {
	variantIDs := make([]string, 0, len(queries))
	for _, q := range queries {
		variantIDs = append(variantIDs, q.Variant.GetID())
	}
	inputs, err := pb.loadPricingInputs(ctx, shopID, customerID, variantIDs)
	if err != nil {
		return nil, err
	}

	quoted := make([]*commercev1.ResolvedPrice, 0, len(queries))
	for _, q := range queries {
		resolved := inputs.basePrice(q)
		applyDiscounts(resolved, inputs.rules, discountTarget{
			variantID: q.Variant.GetID(),
			productID: q.Product.GetID(),
			quantity:  q.Quantity,
		})
		quoted = append(quoted, resolved)
	}
	return quoted, nil
}

// pricingInputs is everything pricing a shop's variants for one customer
// depends on.
type pricingInputs struct {
	// overrides holds the customer's override for each variant.
	overrides map[string]*models.CustomerPriceOverride
	// lists are the customer's active lists in the shop, highest priority
	// first and by id among equals, so the same list always wins.
	lists []*models.PriceList
	// entries holds each list's entries per variant, narrowest band first.
	entries map[string][]*models.PriceListEntry
	// rules are the shop's active discount rules by id.
	rules []*models.DiscountRule
}

// Assignment lookup limit for price list resolution.
const maxAssignmentLookup = 100

func (pb *pricingBusiness) loadPricingInputs(
	ctx context.Context,
	shopID, customerID string,
	variantIDs []string,
) (*pricingInputs, error) {
	inputs := &pricingInputs{
		overrides: map[string]*models.CustomerPriceOverride{},
		entries:   map[string][]*models.PriceListEntry{},
	}

	if customerID != "" {
		if err := pb.loadCustomerPrices(ctx, inputs, shopID, customerID, variantIDs); err != nil {
			return nil, err
		}
	}

	rules, err := pb.discountRuleRepo.ListActive(ctx, shopID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	sort.Slice(rules, func(i, j int) bool { return rules[i].GetID() < rules[j].GetID() })
	inputs.rules = rules
	return inputs, nil
}

// loadCustomerPrices adds customerID's overrides and price lists for
// variantIDs to inputs.
func (pb *pricingBusiness) loadCustomerPrices(
	ctx context.Context,
	inputs *pricingInputs,
	shopID, customerID string,
	variantIDs []string,
) error {
	overrides, err := pb.overrideRepo.ListActiveForVariants(ctx, customerID, variantIDs)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	for _, o := range overrides {
		if _, seen := inputs.overrides[o.ProductVariantID]; !seen {
			inputs.overrides[o.ProductVariantID] = o
		}
	}

	assignments, _, err := pb.assignmentRepo.ListByCustomerID(
		ctx, customerID, repository.Page{Limit: maxAssignmentLookup},
	)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	active := int32(commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE)
	listIDs := make([]string, 0, len(assignments))
	for _, a := range assignments {
		if a.Status == active {
			listIDs = append(listIDs, a.PriceListID)
		}
	}
	// Another shop's list never prices this shop's variants.
	if inputs.lists, err = pb.priceListRepo.ListActiveByIDs(ctx, shopID, listIDs); err != nil {
		return data.ErrorConvertToAPI(err)
	}
	activeIDs := make([]string, 0, len(inputs.lists))
	for _, pl := range inputs.lists {
		activeIDs = append(activeIDs, pl.GetID())
	}
	entries, err := pb.priceListEntryRepo.ListForVariants(ctx, activeIDs, variantIDs)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	for _, e := range entries {
		key := e.PriceListID + "/" + e.ProductVariantID
		inputs.entries[key] = append(inputs.entries[key], e)
	}
	return nil
}

// basePrice is q's price before discounts.
func (in *pricingInputs) basePrice(q PriceQuery) *commercev1.ResolvedPrice {
	variantID := q.Variant.GetID()
	resolved := &commercev1.ResolvedPrice{VariantId: variantID}

	if o, ok := in.overrides[variantID]; ok {
		resolved.UnitPrice = models.MoneyToProto(o.CurrencyCode, o.PriceUnits, o.PriceNanos)
		resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_CUSTOMER_OVERRIDE
		resolved.OverrideId = o.GetID()
		return resolved
	}

	for _, pl := range in.lists {
		for _, entry := range in.entries[pl.GetID()+"/"+variantID] {
			if !inBand(entry, q.Quantity) {
				continue
			}
			resolved.UnitPrice = models.MoneyToProto(entry.CurrencyCode, entry.PriceUnits, entry.PriceNanos)
			resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_PRICE_LIST
			resolved.PriceListId = pl.GetID()
			return resolved
		}
	}

	resolved.UnitPrice = models.MoneyToProto(q.Variant.CurrencyCode, q.Variant.PriceUnits, q.Variant.PriceNanos)
	resolved.PriceSource = commercev1.PriceSource_PRICE_SOURCE_CATALOG
	return resolved
}

// inBand reports whether quantity falls in entry's band; a zero bound is
// open.
func inBand(entry *models.PriceListEntry, quantity int64) bool {
	if entry.MinQuantity > 0 && quantity < int64(entry.MinQuantity) {
		return false
	}
	return entry.MaxQuantity <= 0 || quantity <= int64(entry.MaxQuantity)
}

// percentDivisor is used for percentage calculations to avoid magic numbers.
const percentDivisor = 100.0

// discountTarget is what a discount rule's conditions are evaluated against.
type discountTarget struct {
	variantID string
	productID string
	quantity  int64
}

// Discount rule condition keys understood at pricing time. A rule carrying
// any other key is never applied automatically: guessing at a condition
// would give away money the merchant did not intend to.
const (
	conditionVariantIDs  = "variant_ids"
	conditionProductIDs  = "product_ids"
	conditionMinQuantity = "min_quantity"
)

// discountApplies reports whether rule may be applied to one unit of target
// without a person approving it.
func discountApplies(rule *models.DiscountRule, target discountTarget) bool {
	if rule.RequiresApproval && rule.ApprovedAt == nil {
		return false
	}
	switch commercev1.DiscountAppliesTo(rule.AppliesTo) {
	case commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM:
	case commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_ORDER:
		// A fixed amount off the order cannot be spread per unit; a
		// percentage off the order is the same percentage off every unit.
		if commercev1.DiscountType(rule.DiscountType) != commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE {
			return false
		}
	case commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_UNSPECIFIED:
		return false
	default:
		return false
	}
	for key, value := range rule.Conditions {
		switch key {
		case conditionVariantIDs:
			if !conditionListContains(value, target.variantID) {
				return false
			}
		case conditionProductIDs:
			if !conditionListContains(value, target.productID) {
				return false
			}
		case conditionMinQuantity:
			minQty, ok := conditionNumber(value)
			if !ok || float64(target.quantity) < minQty {
				return false
			}
		default:
			return false
		}
	}
	return true
}

// conditionNumber reads a numeric condition whether it came straight from a
// protobuf Struct (float64) or back out of the JSONB column (json.Number).
func conditionNumber(value any) (float64, bool) {
	switch v := value.(type) {
	case float64:
		return v, true
	case json.Number:
		f, err := v.Float64()
		return f, err == nil
	default:
		return 0, false
	}
}

func conditionListContains(value any, want string) bool {
	items, ok := value.([]any)
	if !ok {
		return false
	}
	for _, item := range items {
		if s, isString := item.(string); isString && s == want {
			return true
		}
	}
	return false
}

// applyDiscounts takes the largest applicable discount in rules off
// resolved's unit price; among equal discounts the first rule wins.
func applyDiscounts(resolved *commercev1.ResolvedPrice, rules []*models.DiscountRule, target discountTarget) {
	if resolved.GetUnitPrice() == nil {
		return
	}

	var bestRule *models.DiscountRule
	var bestDiscountAmount int64
	for _, rule := range rules {
		if !discountApplies(rule, target) {
			continue
		}
		discountAmount := calculateDiscount(rule, resolved.GetUnitPrice())
		if discountAmount > bestDiscountAmount {
			bestDiscountAmount = discountAmount
			bestRule = rule
		}
	}
	if bestRule == nil || bestDiscountAmount <= 0 {
		return
	}

	preDiscount := resolved.GetUnitPrice()
	resolved.PreDiscountPrice = preDiscount

	unitNanos := preDiscount.GetUnits()*nanosFactor + int64(preDiscount.GetNanos())
	finalNanos := max(unitNanos-bestDiscountAmount, 0)

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
}

const nanosFactor = 1_000_000_000

// calculateDiscount is what rule takes off one unit at price, in nanos. A
// fixed amount applies only to a price in the amount's own currency.
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
		if rule.AmountCurrency == "" || !strings.EqualFold(rule.AmountCurrency, price.GetCurrencyCode()) {
			return 0
		}
		discountNanos = models.MoneyNanos(rule.AmountUnits, rule.AmountNanos)
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

	return max(discountNanos, 0)
}

func (pb *pricingBusiness) GetDiscountRuleShopID(ctx context.Context, id string) (string, error) {
	dr, err := pb.discountRuleRepo.GetByID(ctx, id)
	if err != nil {
		return "", data.ErrorConvertToAPI(err)
	}
	return dr.ShopID, nil
}

func (pb *pricingBusiness) ApproveDiscountRule(ctx context.Context, id string) (*commercev1.DiscountRule, error) {
	dr, err := pb.discountRuleRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if !dr.RequiresApproval {
		return nil, connect.NewError(
			connect.CodeFailedPrecondition,
			"discount rule does not require approval")
	}
	if dr.ApprovedAt != nil {
		return dr.ToAPI(), nil
	}
	approver := subjectFromContext(ctx)
	if approver == "" {
		return nil, connect.NewError(connect.CodeUnauthenticated, "an approver is required")
	}
	now := time.Now()
	dr.ApprovedAt = &now
	dr.ApprovedBy = approver
	if _, updateErr := pb.discountRuleRepo.Update(ctx, dr, "approved_at", "approved_by"); updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}
	return dr.ToAPI(), nil
}
