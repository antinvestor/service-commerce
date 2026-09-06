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
	"errors"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/pkg/errorutil"
)

// CommerceServer implements the Connect handler. Authorization is layered:
// the interceptor chain has already verified partition access and the
// tenant-level functional permission for the RPC. Every handler here adds the
// resource-level check (which shop, which cart, which order) so a caller with
// a tenant-wide permission still only reaches records they are entitled to.
type CommerceServer struct {
	authz              authz.Middleware
	shopBusiness       business.ShopBusiness
	catalogBusiness    business.CatalogBusiness
	cartBusiness       business.CartBusiness
	orderBusiness      business.OrderBusiness
	fulfilmentBusiness business.FulfilmentBusiness
	pricingBusiness    business.PricingBusiness
	paymentBusiness    business.PaymentBusiness
	ledgerBusiness     business.LedgerBusiness

	commercev1connect.UnimplementedCommerceServiceHandler
}

// Dependencies are the peers and policies the server is built with.
type Dependencies struct {
	Checkout      business.CheckoutGateway
	Ledger        business.LedgerGateway
	Notifier      notifications.Notifier
	PaymentPolicy business.PaymentPolicy
	LedgerPolicy  business.LedgerPolicy
}

func NewCommerceServer(
	ctx context.Context,
	svc *frame.Service,
	authzMiddleware authz.Middleware,
	deps Dependencies,
) *CommerceServer {
	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	if deps.Notifier == nil {
		deps.Notifier = notifications.New(nil)
	}

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
	postingRepo := repository.NewLedgerPostingRepository(ctx, dbPool, workMan)

	return &CommerceServer{
		authz:           authzMiddleware,
		shopBusiness:    business.NewShopBusiness(ctx, shopRepo, authzMiddleware),
		catalogBusiness: business.NewCatalogBusiness(ctx, productRepo, variantRepo, shopRepo),
		cartBusiness:    business.NewCartBusiness(ctx, cartRepo, cartLineRepo, variantRepo),
		orderBusiness: business.NewOrderBusiness(
			ctx,
			orderRepo,
			orderLineRepo,
			variantRepo,
			productRepo,
			shopRepo,
			cartRepo,
			cartLineRepo,
			business.OrderPolicy{PaymentWindow: deps.PaymentPolicy.PaymentWindow},
		),
		fulfilmentBusiness: business.NewFulfilmentBusiness(
			ctx,
			fulfilmentRepo,
			fulfilmentLineRepo,
			orderRepo,
			orderLineRepo,
			shopRepo,
			deps.Notifier,
		),
		paymentBusiness: business.NewPaymentBusiness(
			ctx, orderRepo, shopRepo, deps.Checkout, deps.Notifier, deps.PaymentPolicy,
		),
		ledgerBusiness: business.NewLedgerBusiness(
			ctx, orderRepo, shopRepo, postingRepo, deps.Ledger, deps.Notifier, deps.LedgerPolicy,
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
	// Tenant-level shop_create is enforced by the FunctionAccessInterceptor.
	// The business layer grants ownership to the caller and rolls back the
	// shop if that grant fails.
	shop, err := cs.shopBusiness.CreateShop(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
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

func (cs *CommerceServer) ListShops(
	ctx context.Context,
	req *connect.Request[commercev1.ListShopsRequest],
) (*connect.Response[commercev1.ListShopsResponse], error) {
	// Tenant-level shops_list is enforced by the interceptor; shops are
	// partition-scoped so every member may see the partition's shops.
	page, err := cs.shopBusiness.ListShops(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListShopsResponse{Shops: page.Shops, NextPage: page.NextPage}), nil
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
	product, err := cs.catalogBusiness.GetProduct(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsView(ctx, product.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
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
	page, err := cs.catalogBusiness.ListProducts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListProductsResponse{
		Products: page.Products,
		NextPage: page.NextPage,
	}), nil
}

func (cs *CommerceServer) CreateProductVariant(
	ctx context.Context,
	req *connect.Request[commercev1.CreateProductVariantRequest],
) (*connect.Response[commercev1.CreateProductVariantResponse], error) {
	product, err := cs.catalogBusiness.GetProduct(ctx, req.Msg.GetProductId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsManage(ctx, product.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
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
	shopID, err := cs.catalogBusiness.GetShopIDForVariant(ctx, req.Msg.GetVariantId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsManage(ctx, shopID); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	variant, err := cs.catalogBusiness.UpdateProductVariant(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.UpdateProductVariantResponse{ProductVariant: variant},
	), nil
}

// ----------------------
// Cart
// ----------------------
//
// A cart belongs to the profile it was created for. The owner may always read
// and mutate it; anyone else needs orders_manage on the cart's shop.

func (cs *CommerceServer) CreateCart(
	ctx context.Context,
	req *connect.Request[commercev1.CreateCartRequest],
) (*connect.Response[commercev1.CreateCartResponse], error) {
	caller := callerSubject(ctx)
	switch {
	case req.Msg.GetProfileId() == "":
		if caller == "" {
			return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("cart needs an owner"))
		}
		req.Msg.SetProfileId(caller)
		if err := cs.authz.CanProductsView(ctx, req.Msg.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	case req.Msg.GetProfileId() == caller:
		if err := cs.authz.CanProductsView(ctx, req.Msg.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	default:
		// Creating a cart on behalf of someone else is a staff action.
		if err := cs.authz.CanOrdersManage(ctx, req.Msg.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
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
	cart, err := cs.authorizedCart(ctx, req.Msg.GetId(), false)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&commercev1.GetCartResponse{Cart: cart}), nil
}

func (cs *CommerceServer) AddCartLine(
	ctx context.Context,
	req *connect.Request[commercev1.AddCartLineRequest],
) (*connect.Response[commercev1.AddCartLineResponse], error) {
	if _, err := cs.authorizedCart(ctx, req.Msg.GetCartId(), true); err != nil {
		return nil, err
	}
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
	if _, err := cs.authorizedCart(ctx, req.Msg.GetCartId(), true); err != nil {
		return nil, err
	}
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
	if _, err := cs.authorizedCart(ctx, req.Msg.GetCartId(), true); err != nil {
		return nil, err
	}
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
	// Direct order creation is a staff action on the shop.
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
	order, err := cs.orderBusiness.GetOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if caller := callerSubject(ctx); caller == "" || order.GetProfileId() != caller {
		if authzErr := cs.authz.CanOrdersView(ctx, order.GetShopId()); authzErr != nil {
			return nil, authorizer.ToConnectError(authzErr)
		}
	}
	return connect.NewResponse(&commercev1.GetOrderResponse{Order: order}), nil
}

// ListOrders lists a shop's orders for staff. A caller without orders_view on
// the shop gets their own orders instead, so buyers can see their history.
func (cs *CommerceServer) ListOrders(
	ctx context.Context,
	req *connect.Request[commercev1.ListOrdersRequest],
) (*connect.Response[commercev1.ListOrdersResponse], error) {
	var page *business.OrderPage
	var err error

	if authzErr := cs.authz.CanOrdersView(ctx, req.Msg.GetShopId()); authzErr == nil {
		page, err = cs.orderBusiness.ListOrders(ctx, req.Msg)
	} else {
		caller := callerSubject(ctx)
		if caller == "" {
			return nil, authorizer.ToConnectError(authzErr)
		}
		page, err = cs.orderBusiness.ListOrdersForProfile(ctx, caller, req.Msg)
	}
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListOrdersResponse{
		Orders:   page.Orders,
		NextPage: page.NextPage,
	}), nil
}

// ----------------------
// Payment
// ----------------------

// CheckoutOrder may be called by the buyer who owns the order or by shop
// staff who manage orders.
func (cs *CommerceServer) CheckoutOrder(
	ctx context.Context,
	req *connect.Request[commercev1.CheckoutOrderRequest],
) (*connect.Response[commercev1.CheckoutOrderResponse], error) {
	if _, err := cs.authorizedOrder(ctx, req.Msg.GetOrderId(), cs.authz.CanOrdersManage); err != nil {
		return nil, err
	}
	order, err := cs.paymentBusiness.CheckoutOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CheckoutOrderResponse{
		Order:       order,
		CheckoutUrl: order.GetCheckoutUrl(),
		SessionRef:  order.GetPaymentSessionRef(),
	}), nil
}

func (cs *CommerceServer) ConfirmOrderPayment(
	ctx context.Context,
	req *connect.Request[commercev1.ConfirmOrderPaymentRequest],
) (*connect.Response[commercev1.ConfirmOrderPaymentResponse], error) {
	if _, err := cs.authorizedOrder(ctx, req.Msg.GetOrderId(), cs.authz.CanOrdersManage); err != nil {
		return nil, err
	}
	order, err := cs.paymentBusiness.ConfirmOrderPayment(ctx, req.Msg.GetOrderId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ConfirmOrderPaymentResponse{Order: order}), nil
}

func (cs *CommerceServer) CancelOrder(
	ctx context.Context,
	req *connect.Request[commercev1.CancelOrderRequest],
) (*connect.Response[commercev1.CancelOrderResponse], error) {
	existing, err := cs.authorizedOrder(ctx, req.Msg.GetOrderId(), cs.authz.CanOrdersManage)
	if err != nil {
		return nil, err
	}
	staff := cs.authz.CanOrdersManage(ctx, existing.GetShopId()) == nil
	order, err := cs.paymentBusiness.CancelOrder(ctx, req.Msg.GetOrderId(), req.Msg.GetReason(), staff)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CancelOrderResponse{Order: order}), nil
}

// ReconcilePayments is a scheduled, partition-wide operation. The tenant
// level ledger_post permission (owner, admin, service) gates it.
func (cs *CommerceServer) ReconcilePayments(
	ctx context.Context,
	req *connect.Request[commercev1.ReconcilePaymentsRequest],
) (*connect.Response[commercev1.ReconcilePaymentsResponse], error) {
	if shopID := req.Msg.GetShopId(); shopID != "" {
		if err := cs.authz.CanOrdersManage(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}
	summary, err := cs.paymentBusiness.ReconcilePayments(ctx, req.Msg.GetShopId(), int(req.Msg.GetLimit()))
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ReconcilePaymentsResponse{
		Examined: summary.Examined,
		Paid:     summary.Paid,
		Expired:  summary.Expired,
		Failed:   summary.Failed,
	}), nil
}

func (cs *CommerceServer) RunEndOfDayLedger(
	ctx context.Context,
	req *connect.Request[commercev1.RunEndOfDayLedgerRequest],
) (*connect.Response[commercev1.RunEndOfDayLedgerResponse], error) {
	if shopID := req.Msg.GetShopId(); shopID != "" {
		if err := cs.authz.CanOrdersManage(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}
	postings, err := cs.ledgerBusiness.RunEndOfDayLedger(ctx, req.Msg.GetShopId(), req.Msg.GetDate())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.RunEndOfDayLedgerResponse{Postings: postings}), nil
}

// ----------------------
// Fulfilment
// ----------------------

func (cs *CommerceServer) CreateFulfilment(
	ctx context.Context,
	req *connect.Request[commercev1.CreateFulfilmentRequest],
) (*connect.Response[commercev1.CreateFulfilmentResponse], error) {
	if err := cs.requireOrderPermission(ctx, req.Msg.GetOrderId(), cs.authz.CanFulfilmentManage); err != nil {
		return nil, err
	}
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
	existing, err := cs.fulfilmentBusiness.GetFulfilment(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if permErr := cs.requireOrderPermission(ctx, existing.GetOrderId(), cs.authz.CanFulfilmentManage); permErr != nil {
		return nil, permErr
	}
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
	fulfilment, err := cs.fulfilmentBusiness.GetFulfilment(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	order, err := cs.orderBusiness.GetOrder(ctx, fulfilment.GetOrderId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	// The buyer may track their own shipment; staff need orders_view.
	if caller := callerSubject(ctx); caller == "" || order.GetProfileId() != caller {
		if authzErr := cs.authz.CanOrdersView(ctx, order.GetShopId()); authzErr != nil {
			return nil, authorizer.ToConnectError(authzErr)
		}
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
	shopID := req.Msg.GetShopId()
	if req.Msg.GetId() != "" {
		// Updates are scoped by the stored shop, not whatever the client sent.
		existing, err := cs.pricingBusiness.GetPriceList(ctx, req.Msg.GetId())
		if err != nil {
			return nil, errorutil.CleanErr(err)
		}
		shopID = existing.GetShopId()
	}
	if err := cs.authz.CanPriceListManage(ctx, shopID); err != nil {
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
	page, err := cs.pricingBusiness.SearchPriceLists(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.PriceListSearchResponse{
		PriceLists: page.Items,
		NextPage:   page.NextPage,
	}), nil
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
	if req.Msg.GetPriceListId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("price_list_id is required"))
	}
	pl, plErr := cs.pricingBusiness.GetPriceList(ctx, req.Msg.GetPriceListId())
	if plErr != nil {
		return nil, errorutil.CleanErr(plErr)
	}
	if err := cs.authz.CanPriceListManage(ctx, pl.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
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
	page, err := cs.pricingBusiness.SearchCustomerPriceListAssignments(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceListAssignmentSearchResponse{
			Assignments: page.Items,
			NextPage:    page.NextPage,
		},
	), nil
}

func (cs *CommerceServer) CustomerPriceOverrideSave(
	ctx context.Context,
	req *connect.Request[commercev1.CustomerPriceOverrideSaveRequest],
) (*connect.Response[commercev1.CustomerPriceOverrideSaveResponse], error) {
	if req.Msg.GetProductVariantId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("product_variant_id is required"))
	}
	shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, req.Msg.GetProductVariantId())
	if shopErr != nil {
		return nil, errorutil.CleanErr(shopErr)
	}
	if err := cs.authz.CanCustomerPriceOverride(ctx, shopID); err != nil {
		return nil, authorizer.ToConnectError(err)
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
	page, err := cs.pricingBusiness.SearchCustomerPriceOverrides(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(
		&commercev1.CustomerPriceOverrideSearchResponse{
			Overrides: page.Items,
			NextPage:  page.NextPage,
		},
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
	page, err := cs.pricingBusiness.SearchDiscountRules(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.DiscountRuleSearchResponse{
		DiscountRules: page.Items,
		NextPage:      page.NextPage,
	}), nil
}

func (cs *CommerceServer) ResolvePrice(
	ctx context.Context,
	req *connect.Request[commercev1.ResolvePriceRequest],
) (*connect.Response[commercev1.ResolvePriceResponse], error) {
	// Non-privileged callers always resolve for their own identity; shop staff
	// with price_list_view may resolve for any customer.
	callerID := callerSubject(ctx)
	requestedCustomer := req.Msg.GetCustomerId()
	if requestedCustomer != "" && requestedCustomer != callerID {
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
		req.Msg.SetCustomerId(callerID)
	}

	resolved, err := cs.pricingBusiness.ResolvePrice(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ResolvePriceResponse{ResolvedPrice: resolved}), nil
}

// ----------------------
// Helpers
// ----------------------

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

// authorizedCart loads a cart and verifies the caller may access it: the owner
// always may; otherwise orders_manage (mutate) or orders_view (read) on the
// cart's shop is required.
func (cs *CommerceServer) authorizedCart(
	ctx context.Context,
	cartID string,
	mutate bool,
) (*commercev1.Cart, error) {
	cart, err := cs.cartBusiness.GetCart(ctx, cartID)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	caller := callerSubject(ctx)
	if caller != "" && cart.GetProfileId() == caller {
		return cart, nil
	}
	check := cs.authz.CanOrdersView
	if mutate {
		check = cs.authz.CanOrdersManage
	}
	if authzErr := check(ctx, cart.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	return cart, nil
}

// authorizedOrder loads an order and verifies the caller is its buyer or
// holds check on its shop.
func (cs *CommerceServer) authorizedOrder(
	ctx context.Context,
	orderID string,
	check func(context.Context, string) error,
) (*commercev1.Order, error) {
	order, err := cs.orderBusiness.GetOrder(ctx, orderID)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if caller := callerSubject(ctx); caller != "" && order.GetProfileId() == caller {
		return order, nil
	}
	if authzErr := check(ctx, order.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	return order, nil
}

// requireOrderPermission resolves the order's shop and applies check to it.
func (cs *CommerceServer) requireOrderPermission(
	ctx context.Context,
	orderID string,
	check func(context.Context, string) error,
) error {
	order, err := cs.orderBusiness.GetOrder(ctx, orderID)
	if err != nil {
		return errorutil.CleanErr(err)
	}
	if authzErr := check(ctx, order.GetShopId()); authzErr != nil {
		return authorizer.ToConnectError(authzErr)
	}
	return nil
}

func (cs *CommerceServer) checkAssignmentSearchAuthz(
	ctx context.Context,
	msg *commercev1.CustomerPriceListAssignmentSearchRequest,
) error {
	caller := callerSubject(ctx)
	if caller != "" && msg.GetCustomerId() == caller {
		return nil
	}
	if msg.GetPriceListId() == "" {
		return connect.NewError(connect.CodePermissionDenied,
			errors.New("price_list_id required for cross-customer search"))
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
	caller := callerSubject(ctx)
	if caller != "" && msg.GetCustomerId() == caller {
		return nil
	}
	if msg.GetProductVariantId() == "" {
		return connect.NewError(connect.CodePermissionDenied,
			errors.New("product_variant_id required for cross-customer search"))
	}
	shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, msg.GetProductVariantId())
	if shopErr != nil {
		return errorutil.CleanErr(shopErr)
	}
	return authorizer.ToConnectError(cs.authz.CanCustomerPriceOverride(ctx, shopID))
}
