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

package handlers

import (
	"context"

	"buf.build/gen/go/antinvestor/commerce/connectrpc/go/v1/commercev1connect"
	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/pkg/errorutil"
)

type CommerceServer struct {
	authz              authz.Middleware
	shopBusiness       business.ShopBusiness
	catalogBusiness    business.CatalogBusiness
	cartBusiness       business.CartBusiness
	orderBusiness      business.OrderBusiness
	fulfilmentBusiness business.FulfilmentBusiness
	pricingBusiness    business.PricingBusiness

	commercev1connect.UnimplementedCommerceServiceHandler
}

func NewCommerceServer(
	ctx context.Context,
	svc *frame.Service,
	authzMiddleware authz.Middleware,
) *CommerceServer {
	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	shopRepo := repository.NewShopRepository(ctx, dbPool, workMan)
	productRepo := repository.NewProductRepository(ctx, dbPool, workMan)
	variantRepo := repository.NewProductVariantRepository(ctx, dbPool, workMan)
	cartRepo := repository.NewCartRepository(ctx, dbPool, workMan)
	cartLineRepo := repository.NewCartLineRepository(ctx, dbPool, workMan)
	orderRepo := repository.NewOrderRepository(ctx, dbPool, workMan)
	orderLineRepo := repository.NewOrderLineRepository(ctx, dbPool, workMan)
	fulfilmentRepo := repository.NewFulfilmentRepository(ctx, dbPool, workMan)
	fulfilmentLineRepo := repository.NewFulfilmentLineRepository(ctx, dbPool, workMan)
	priceListRepo := repository.NewPriceListRepository(ctx, dbPool, workMan)
	priceListEntryRepo := repository.NewPriceListEntryRepository(ctx, dbPool, workMan)
	assignmentRepo := repository.NewCustomerPriceListAssignmentRepository(ctx, dbPool, workMan)
	overrideRepo := repository.NewCustomerPriceOverrideRepository(ctx, dbPool, workMan)
	discountRuleRepo := repository.NewDiscountRuleRepository(ctx, dbPool, workMan)

	return &CommerceServer{
		authz:           authzMiddleware,
		shopBusiness:    business.NewShopBusiness(ctx, shopRepo),
		catalogBusiness: business.NewCatalogBusiness(ctx, productRepo, variantRepo, shopRepo),
		cartBusiness:    business.NewCartBusiness(ctx, cartRepo, cartLineRepo, variantRepo),
		orderBusiness: business.NewOrderBusiness(
			ctx,
			orderRepo,
			orderLineRepo,
			variantRepo,
			shopRepo,
			cartRepo,
			cartLineRepo,
		),
		fulfilmentBusiness: business.NewFulfilmentBusiness(
			ctx,
			fulfilmentRepo,
			fulfilmentLineRepo,
			orderRepo,
			orderLineRepo,
		),
		pricingBusiness: business.NewPricingBusiness(
			ctx,
			priceListRepo,
			priceListEntryRepo,
			assignmentRepo,
			overrideRepo,
			discountRuleRepo,
			variantRepo,
			productRepo,
			shopRepo,
		),
	}
}

// ----------------------
// Shop
// ----------------------

func (cs *CommerceServer) CreateShop(
	ctx context.Context,
	req *connect.Request[commercev1.CreateShopRequest],
) (*connect.Response[commercev1.CreateShopResponse], error) {
	// Tenant-level shop_create permission is enforced by the FunctionAccessInterceptor.
	shop, err := cs.shopBusiness.CreateShop(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}

	// Make the creator the owner of the newly created shop
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if profileID, subErr := claims.GetSubject(); subErr == nil && profileID != "" {
			_ = cs.authz.AddShopMember(ctx, shop.GetId(), profileID, authz.RoleOwner)
		}
	}

	return connect.NewResponse(&commercev1.CreateShopResponse{Shop: shop}), nil
}

func (cs *CommerceServer) GetShop(
	ctx context.Context,
	req *connect.Request[commercev1.GetShopRequest],
) (*connect.Response[commercev1.GetShopResponse], error) {
	if err := cs.authz.CanShopView(ctx, req.Msg.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	shop, err := cs.shopBusiness.GetShop(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.GetShopResponse{Shop: shop}), nil
}

func (cs *CommerceServer) UpdateShop(
	ctx context.Context,
	req *connect.Request[commercev1.UpdateShopRequest],
) (*connect.Response[commercev1.UpdateShopResponse], error) {
	if err := cs.authz.CanShopUpdate(ctx, req.Msg.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	shop, err := cs.shopBusiness.UpdateShop(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.UpdateShopResponse{Shop: shop}), nil
}

// ----------------------
// Catalog
// ----------------------

func (cs *CommerceServer) CreateProduct(
	ctx context.Context,
	req *connect.Request[commercev1.CreateProductRequest],
) (*connect.Response[commercev1.CreateProductResponse], error) {
	if err := cs.authz.CanProductsManage(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	product, err := cs.catalogBusiness.CreateProduct(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateProductResponse{Product: product}), nil
}

func (cs *CommerceServer) GetProduct(
	ctx context.Context,
	req *connect.Request[commercev1.GetProductRequest],
) (*connect.Response[commercev1.GetProductResponse], error) {
	// TODO: add shop-level CanProductsView check once product lookup provides shopID
	product, err := cs.catalogBusiness.GetProduct(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.GetProductResponse{Product: product}), nil
}

func (cs *CommerceServer) ListProducts(
	ctx context.Context,
	req *connect.Request[commercev1.ListProductsRequest],
) (*connect.Response[commercev1.ListProductsResponse], error) {
	if err := cs.authz.CanProductsView(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	products, err := cs.catalogBusiness.ListProducts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListProductsResponse{Products: products}), nil
}

// ListProductVariants handler will be wired here once the proto is updated with:
//
//	rpc ListProductVariants(ListProductVariantsRequest) returns (ListProductVariantsResponse)
//
// The business logic is already implemented in CatalogBusiness.ListProductVariants().

func (cs *CommerceServer) CreateProductVariant(
	ctx context.Context,
	req *connect.Request[commercev1.CreateProductVariantRequest],
) (*connect.Response[commercev1.CreateProductVariantResponse], error) {
	// TODO: add shop-level CanProductsManage check once product lookup provides shopID
	variant, err := cs.catalogBusiness.CreateProductVariant(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CreateProductVariantResponse{ProductVariant: variant},
	), nil
}

func (cs *CommerceServer) UpdateProductVariant(
	ctx context.Context,
	req *connect.Request[commercev1.UpdateProductVariantRequest],
) (*connect.Response[commercev1.UpdateProductVariantResponse], error) {
	// TODO: add shop-level CanProductsManage check once variant lookup provides shopID
	variant, err := cs.catalogBusiness.UpdateProductVariant(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.UpdateProductVariantResponse{ProductVariant: variant},
	), nil
}

// ----------------------
// Carts
// ----------------------

func (cs *CommerceServer) CreateCart(
	ctx context.Context,
	req *connect.Request[commercev1.CreateCartRequest],
) (*connect.Response[commercev1.CreateCartResponse], error) {
	// Carts are customer-facing; check that the caller can view products in the shop
	if err := cs.authz.CanProductsView(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	cart, err := cs.cartBusiness.CreateCart(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateCartResponse{Cart: cart}), nil
}

func (cs *CommerceServer) GetCart(
	ctx context.Context,
	req *connect.Request[commercev1.GetCartRequest],
) (*connect.Response[commercev1.GetCartResponse], error) {
	// TODO: add shop-level authz check once cart lookup provides shopID
	cart, err := cs.cartBusiness.GetCart(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.GetCartResponse{Cart: cart}), nil
}

func (cs *CommerceServer) AddCartLine(
	ctx context.Context,
	req *connect.Request[commercev1.AddCartLineRequest],
) (*connect.Response[commercev1.AddCartLineResponse], error) {
	// TODO: add shop-level authz check once cart lookup provides shopID
	cart, err := cs.cartBusiness.AddCartLine(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.AddCartLineResponse{Cart: cart}), nil
}

func (cs *CommerceServer) RemoveCartLine(
	ctx context.Context,
	req *connect.Request[commercev1.RemoveCartLineRequest],
) (*connect.Response[commercev1.RemoveCartLineResponse], error) {
	// TODO: add shop-level authz check once cart lookup provides shopID
	cart, err := cs.cartBusiness.RemoveCartLine(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.RemoveCartLineResponse{Cart: cart}), nil
}

// ----------------------
// Orders
// ----------------------

func (cs *CommerceServer) CreateOrderFromCart(
	ctx context.Context,
	req *connect.Request[commercev1.CreateOrderFromCartRequest],
) (*connect.Response[commercev1.CreateOrderFromCartResponse], error) {
	// TODO: add shop-level CanOrdersManage check once cart lookup provides shopID
	order, err := cs.orderBusiness.CreateOrderFromCart(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateOrderFromCartResponse{Order: order}), nil
}

func (cs *CommerceServer) CreateOrder(
	ctx context.Context,
	req *connect.Request[commercev1.CreateOrderRequest],
) (*connect.Response[commercev1.CreateOrderResponse], error) {
	if err := cs.authz.CanOrdersManage(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	order, err := cs.orderBusiness.CreateOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateOrderResponse{Order: order}), nil
}

func (cs *CommerceServer) GetOrder(
	ctx context.Context,
	req *connect.Request[commercev1.GetOrderRequest],
) (*connect.Response[commercev1.GetOrderResponse], error) {
	// TODO: add shop-level CanViewOrders check once order lookup provides shopID
	order, err := cs.orderBusiness.GetOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.GetOrderResponse{Order: order}), nil
}

func (cs *CommerceServer) ListOrders(
	ctx context.Context,
	req *connect.Request[commercev1.ListOrdersRequest],
) (*connect.Response[commercev1.ListOrdersResponse], error) {
	if err := cs.authz.CanOrdersView(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	orders, err := cs.orderBusiness.ListOrders(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListOrdersResponse{Orders: orders}), nil
}

// ----------------------
// Fulfilment
// ----------------------

func (cs *CommerceServer) CreateFulfilment(
	ctx context.Context,
	req *connect.Request[commercev1.CreateFulfilmentRequest],
) (*connect.Response[commercev1.CreateFulfilmentResponse], error) {
	// TODO: add shop-level CanManageFulfilment check once order lookup provides shopID
	fulfilment, err := cs.fulfilmentBusiness.CreateFulfilment(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateFulfilmentResponse{Fulfilment: fulfilment}), nil
}

func (cs *CommerceServer) UpdateFulfilment(
	ctx context.Context,
	req *connect.Request[commercev1.UpdateFulfilmentRequest],
) (*connect.Response[commercev1.UpdateFulfilmentResponse], error) {
	// TODO: add shop-level CanFulfilmentManage check once fulfilment lookup provides shopID
	fulfilment, err := cs.fulfilmentBusiness.UpdateFulfilment(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.UpdateFulfilmentResponse{Fulfilment: fulfilment}), nil
}

func (cs *CommerceServer) GetFulfilment(
	ctx context.Context,
	req *connect.Request[commercev1.GetFulfilmentRequest],
) (*connect.Response[commercev1.GetFulfilmentResponse], error) {
	// TODO: add shop-level CanOrdersView or CanFulfilmentManage check once fulfilment lookup provides shopID
	fulfilment, err := cs.fulfilmentBusiness.GetFulfilment(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.GetFulfilmentResponse{Fulfilment: fulfilment}), nil
}

// ----------------------
// Pricing
// ----------------------

func (cs *CommerceServer) PriceListSave(
	ctx context.Context,
	req *connect.Request[commercev1.PriceListSaveRequest],
) (*connect.Response[commercev1.PriceListSaveResponse], error) {
	if err := cs.authz.CanPriceListManage(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	pl, err := cs.pricingBusiness.SavePriceList(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.PriceListSaveResponse{PriceList: pl}), nil
}

func (cs *CommerceServer) PriceListGet(
	ctx context.Context,
	req *connect.Request[commercev1.PriceListGetRequest],
) (*connect.Response[commercev1.PriceListGetResponse], error) {
	pl, err := cs.pricingBusiness.GetPriceList(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}

	if authzErr := cs.authz.CanPriceListView(ctx, pl.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}

	return connect.NewResponse(&commercev1.PriceListGetResponse{PriceList: pl}), nil
}

func (cs *CommerceServer) PriceListSearch(
	ctx context.Context,
	req *connect.Request[commercev1.PriceListSearchRequest],
) (*connect.Response[commercev1.PriceListSearchResponse], error) {
	if err := cs.authz.CanPriceListView(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	priceLists, err := cs.pricingBusiness.SearchPriceLists(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.PriceListSearchResponse{PriceLists: priceLists}), nil
}

func (cs *CommerceServer) PriceListEntryBatchSave(
	ctx context.Context,
	req *connect.Request[commercev1.PriceListEntryBatchSaveRequest],
) (*connect.Response[commercev1.PriceListEntryBatchSaveResponse], error) {
	pl, plErr := cs.pricingBusiness.GetPriceList(ctx, req.Msg.GetPriceListId())
	if plErr != nil {
		return nil, errorutil.CleanErr(plErr)
	}

	if err := cs.authz.CanPriceListManage(ctx, pl.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	entries, err := cs.pricingBusiness.BatchSavePriceListEntries(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.PriceListEntryBatchSaveResponse{Entries: entries}), nil
}

func (cs *CommerceServer) CustomerPriceListAssignmentSave(
	ctx context.Context,
	req *connect.Request[commercev1.CustomerPriceListAssignmentSaveRequest],
) (*connect.Response[commercev1.CustomerPriceListAssignmentSaveResponse], error) {
	if req.Msg.GetPriceListId() != "" {
		pl, plErr := cs.pricingBusiness.GetPriceList(ctx, req.Msg.GetPriceListId())
		if plErr != nil {
			return nil, errorutil.CleanErr(plErr)
		}

		if err := cs.authz.CanPriceListManage(ctx, pl.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}

	assignment, err := cs.pricingBusiness.SaveCustomerPriceListAssignment(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceListAssignmentSaveResponse{Assignment: assignment},
	), nil
}

func (cs *CommerceServer) CustomerPriceListAssignmentSearch(
	ctx context.Context,
	req *connect.Request[commercev1.CustomerPriceListAssignmentSearchRequest],
) (*connect.Response[commercev1.CustomerPriceListAssignmentSearchResponse], error) {
	if authzErr := cs.checkAssignmentSearchAuthz(ctx, req.Msg); authzErr != nil {
		return nil, authzErr
	}

	assignments, err := cs.pricingBusiness.SearchCustomerPriceListAssignments(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceListAssignmentSearchResponse{Assignments: assignments},
	), nil
}

func (cs *CommerceServer) CustomerPriceOverrideSave(
	ctx context.Context,
	req *connect.Request[commercev1.CustomerPriceOverrideSaveRequest],
) (*connect.Response[commercev1.CustomerPriceOverrideSaveResponse], error) {
	if req.Msg.GetProductVariantId() != "" {
		shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, req.Msg.GetProductVariantId())
		if shopErr != nil {
			return nil, errorutil.CleanErr(shopErr)
		}

		if err := cs.authz.CanCustomerPriceOverride(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}

	override, err := cs.pricingBusiness.SaveCustomerPriceOverride(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceOverrideSaveResponse{Override: override},
	), nil
}

func (cs *CommerceServer) CustomerPriceOverrideSearch(
	ctx context.Context,
	req *connect.Request[commercev1.CustomerPriceOverrideSearchRequest],
) (*connect.Response[commercev1.CustomerPriceOverrideSearchResponse], error) {
	if authzErr := cs.checkOverrideSearchAuthz(ctx, req.Msg); authzErr != nil {
		return nil, authzErr
	}

	overrides, err := cs.pricingBusiness.SearchCustomerPriceOverrides(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceOverrideSearchResponse{Overrides: overrides},
	), nil
}

func (cs *CommerceServer) DiscountRuleSave(
	ctx context.Context,
	req *connect.Request[commercev1.DiscountRuleSaveRequest],
) (*connect.Response[commercev1.DiscountRuleSaveResponse], error) {
	if err := cs.authz.CanDiscountManage(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	rule, err := cs.pricingBusiness.SaveDiscountRule(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.DiscountRuleSaveResponse{DiscountRule: rule}), nil
}

func (cs *CommerceServer) DiscountRuleSearch(
	ctx context.Context,
	req *connect.Request[commercev1.DiscountRuleSearchRequest],
) (*connect.Response[commercev1.DiscountRuleSearchResponse], error) {
	if err := cs.authz.CanPriceListView(ctx, req.Msg.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	rules, err := cs.pricingBusiness.SearchDiscountRules(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.DiscountRuleSearchResponse{DiscountRules: rules}), nil
}

func (cs *CommerceServer) ResolvePrice(
	ctx context.Context,
	req *connect.Request[commercev1.ResolvePriceRequest],
) (*connect.Response[commercev1.ResolvePriceResponse], error) {
	// Determine the effective customer ID. Non-privileged callers always use
	// their own identity; privileged callers (shop staff with price_list_view)
	// may specify an arbitrary customer_id.
	callerID := ""
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if sub, subErr := claims.GetSubject(); subErr == nil {
			callerID = sub
		}
	}

	requestedCustomer := req.Msg.GetCustomerId()
	if requestedCustomer != "" && requestedCustomer != callerID {
		// Caller is trying to resolve prices for a different customer.
		// Require price_list_view on the variant's shop to allow this.
		shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(
			ctx, req.Msg.GetProductVariantId(),
		)
		if shopErr != nil {
			return nil, errorutil.CleanErr(shopErr)
		}

		if err := cs.authz.CanPriceListView(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	} else if requestedCustomer == "" && callerID != "" {
		// Default to the caller's own identity for customer-specific pricing.
		req.Msg.SetCustomerId(callerID)
	}

	resolved, err := cs.pricingBusiness.ResolvePrice(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ResolvePriceResponse{ResolvedPrice: resolved}), nil
}

func callerSubject(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	sub, err := claims.GetSubject()
	if err != nil {
		return ""
	}
	return sub
}

func (cs *CommerceServer) checkAssignmentSearchAuthz(
	ctx context.Context,
	msg *commercev1.CustomerPriceListAssignmentSearchRequest,
) error {
	if msg.GetCustomerId() == callerSubject(ctx) {
		return nil
	}
	if msg.GetPriceListId() == "" {
		return nil
	}
	pl, plErr := cs.pricingBusiness.GetPriceList(ctx, msg.GetPriceListId())
	if plErr != nil {
		return errorutil.CleanErr(plErr)
	}
	return authorizer.ToConnectError(cs.authz.CanPriceListView(ctx, pl.GetShopId()))
}

func (cs *CommerceServer) checkOverrideSearchAuthz(
	ctx context.Context,
	msg *commercev1.CustomerPriceOverrideSearchRequest,
) error {
	if msg.GetCustomerId() == callerSubject(ctx) {
		return nil
	}
	if msg.GetProductVariantId() == "" {
		return nil
	}
	shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, msg.GetProductVariantId())
	if shopErr != nil {
		return errorutil.CleanErr(shopErr)
	}
	return authorizer.ToConnectError(cs.authz.CanCustomerPriceOverride(ctx, shopID))
}
