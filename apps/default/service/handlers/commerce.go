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
	"slices"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/pkg/dbrole"
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
	currencies         business.CurrencyResolver
	catalogBusiness    business.CatalogBusiness
	cartBusiness       business.CartBusiness
	orderBusiness      business.OrderBusiness
	fulfilmentBusiness business.FulfilmentBusiness
	pricingBusiness    business.PricingBusiness
	paymentBusiness    business.PaymentBusiness
	ledgerBusiness     business.LedgerBusiness
	eventBusiness      business.EventBusiness
	storefront         business.StorefrontBusiness
}

// CommerceServer answers every RPC itself; a new one in the proto fails the
// build here rather than reaching callers as unimplemented.
var _ commercev1connect.CommerceServiceHandler = (*CommerceServer)(nil)

// Dependencies are the peers and policies the server is built with.
type Dependencies struct {
	Checkout business.CheckoutGateway
	// Refunds pays refunds out through the payment service; nil leaves them
	// pending.
	Refunds    business.RefundGateway
	Ledger     business.LedgerGateway
	Currencies business.CurrencyDirectory
	Webhooks   business.WebhookSender
	// WebhookQueue delivers webhooks off the request path; nil leaves them
	// to the reconcile run.
	WebhookQueue  business.WebhookQueue
	Secrets       business.SecretBox
	Notifier      notifications.Notifier
	PaymentPolicy business.PaymentPolicy
	LedgerPolicy  business.LedgerPolicy
	// Buyers resolves storefront guests to profiles; nil disables guest
	// checkout.
	Buyers business.BuyerDirectory
	// StorefrontBaseURL is where shops' public pages are served.
	StorefrontBaseURL string
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
	eventRepo := repository.NewOrderEventRepository(ctx, dbPool, workMan)
	events := business.NewEventBusiness(
		eventRepo, shopRepo, deps.Notifier, deps.Webhooks, deps.Secrets, deps.WebhookQueue,
	)

	pricingBusiness := business.NewPricingBusiness(
		ctx,
		priceListRepo,
		priceListEntryRepo,
		assignmentRepo,
		overrideRepo,
		discountRuleRepo,
		variantRepo,
		productRepo,
		shopRepo,
	)

	currencies := business.NewCurrencyResolver(deps.Currencies)

	catalogBusiness := business.NewCatalogBusiness(ctx, productRepo, variantRepo, shopRepo)
	orderBusiness := business.NewOrderBusiness(
		ctx,
		orderRepo,
		orderLineRepo,
		variantRepo,
		productRepo,
		shopRepo,
		cartRepo,
		cartLineRepo,
		pricingBusiness,
		business.OrderPolicy{PaymentWindow: deps.PaymentPolicy.PaymentWindow},
	)
	paymentBusiness := business.NewPaymentBusiness(
		ctx, orderRepo, shopRepo, deps.Checkout, deps.Refunds, deps.Notifier, events, deps.PaymentPolicy,
	)

	return &CommerceServer{
		authz:      authzMiddleware,
		currencies: currencies,
		shopBusiness: business.NewShopBusiness(
			ctx, shopRepo, authzMiddleware, currencies, deps.Secrets, deps.StorefrontBaseURL,
		),
		catalogBusiness: catalogBusiness,
		cartBusiness:    business.NewCartBusiness(ctx, cartRepo, cartLineRepo, variantRepo),
		orderBusiness:   orderBusiness,
		fulfilmentBusiness: business.NewFulfilmentBusiness(
			ctx,
			fulfilmentRepo,
			fulfilmentLineRepo,
			orderRepo,
			orderLineRepo,
			shopRepo,
			deps.Notifier,
		),
		paymentBusiness: paymentBusiness,
		ledgerBusiness: business.NewLedgerBusiness(
			ctx, orderRepo, shopRepo, postingRepo, deps.Ledger, deps.Notifier, deps.LedgerPolicy,
		),
		pricingBusiness: pricingBusiness,
		eventBusiness:   events,
		storefront: business.NewStorefrontBusiness(
			shopRepo, catalogBusiness, orderBusiness, paymentBusiness, deps.Buyers, deps.StorefrontBaseURL,
		),
	}
}

// ----------------------
// Shop
// ----------------------

func (cs *CommerceServer) CreateShop(
	ctx context.Context,
	req *commercev1.CreateShopRequest,
) (*commercev1.CreateShopResponse, error) {
	// Tenant-level shop_create is enforced by the FunctionAccessInterceptor.
	// The business layer grants ownership to the caller and rolls back the
	// shop if that grant fails.
	shop, err := cs.shopBusiness.CreateShop(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateShopResponse{Shop: shop}, nil
}

func (cs *CommerceServer) GetShop(
	ctx context.Context,
	req *commercev1.GetShopRequest,
) (*commercev1.GetShopResponse, error) {
	if err := cs.authz.CanShopView(ctx, req.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	shop, err := cs.shopBusiness.GetShop(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.GetShopResponse{Shop: shop}, nil
}

func (cs *CommerceServer) UpdateShop(
	ctx context.Context,
	req *commercev1.UpdateShopRequest,
) (*commercev1.UpdateShopResponse, error) {
	if err := cs.authz.CanShopUpdate(ctx, req.GetId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	shop, err := cs.shopBusiness.UpdateShop(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.UpdateShopResponse{Shop: shop}, nil
}

func (cs *CommerceServer) ListShops(
	ctx context.Context,
	req *commercev1.ListShopsRequest,
) (*commercev1.ListShopsResponse, error) {
	// Tenant-level shops_list is enforced by the interceptor; shops are
	// partition-scoped so every member may see the partition's shops.
	page, err := cs.shopBusiness.ListShops(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListShopsResponse{Shops: page.Shops, NextPage: page.NextPage}, nil
}

// ResolveDefaultCurrency tells the console which currency to offer when the
// caller sets up a shop. shops_list is enforced by the interceptor.
func (cs *CommerceServer) ResolveDefaultCurrency(
	ctx context.Context,
	_ *commercev1.ResolveDefaultCurrencyRequest,
) (*commercev1.ResolveDefaultCurrencyResponse, error) {
	code, source := cs.currencies.DefaultCurrency(ctx)
	return &commercev1.ResolveDefaultCurrencyResponse{Currency: code, Source: source}, nil
}

// ----------------------
// Catalog
// ----------------------

func (cs *CommerceServer) CreateProduct(
	ctx context.Context,
	req *commercev1.CreateProductRequest,
) (*commercev1.CreateProductResponse, error) {
	if err := cs.authz.CanProductsManage(ctx, req.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	product, err := cs.catalogBusiness.CreateProduct(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateProductResponse{Product: product}, nil
}

func (cs *CommerceServer) GetProduct(
	ctx context.Context,
	req *commercev1.GetProductRequest,
) (*commercev1.GetProductResponse, error) {
	product, err := cs.catalogBusiness.GetProduct(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsView(ctx, product.GetShopId()); authzErr != nil {
		return nil, notVisible(authorizer.ToConnectError(authzErr))
	}
	return &commercev1.GetProductResponse{Product: product}, nil
}

func (cs *CommerceServer) ListProducts(
	ctx context.Context,
	req *commercev1.ListProductsRequest,
) (*commercev1.ListProductsResponse, error) {
	if err := cs.authz.CanProductsView(ctx, req.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	page, err := cs.catalogBusiness.ListProducts(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListProductsResponse{
		Products: page.Products,
		NextPage: page.NextPage,
	}, nil
}

func (cs *CommerceServer) CreateProductVariant(
	ctx context.Context,
	req *commercev1.CreateProductVariantRequest,
) (*commercev1.CreateProductVariantResponse, error) {
	product, err := cs.catalogBusiness.GetProduct(ctx, req.GetProductId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsManage(ctx, product.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	variant, err := cs.catalogBusiness.CreateProductVariant(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateProductVariantResponse{ProductVariant: variant}, nil
}

func (cs *CommerceServer) ListProductVariants(
	ctx context.Context,
	req *commercev1.ListProductVariantsRequest,
) (*commercev1.ListProductVariantsResponse, error) {
	product, err := cs.catalogBusiness.GetProduct(ctx, req.GetProductId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsView(ctx, product.GetShopId()); authzErr != nil {
		return nil, notVisible(authorizer.ToConnectError(authzErr))
	}
	variants, err := cs.catalogBusiness.ListProductVariants(ctx, product.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListProductVariantsResponse{ProductVariants: variants}, nil
}

func (cs *CommerceServer) UpdateProductVariant(
	ctx context.Context,
	req *commercev1.UpdateProductVariantRequest,
) (*commercev1.UpdateProductVariantResponse, error) {
	shopID, err := cs.catalogBusiness.GetShopIDForVariant(ctx, req.GetVariantId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsManage(ctx, shopID); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	variant, err := cs.catalogBusiness.UpdateProductVariant(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.UpdateProductVariantResponse{ProductVariant: variant}, nil
}

// ----------------------
// Cart
// ----------------------
//
// A cart belongs to the profile it was created for. The owner may always read
// and mutate it; anyone else needs orders_manage on the cart's shop.

func (cs *CommerceServer) CreateCart(
	ctx context.Context,
	req *commercev1.CreateCartRequest,
) (*commercev1.CreateCartResponse, error) {
	caller := callerSubject(ctx)
	switch {
	case req.GetProfileId() == "":
		if caller == "" {
			return nil, connect.NewError(connect.CodeUnauthenticated, "cart needs an owner")
		}
		req.SetProfileId(caller)
		if err := cs.authz.CanProductsView(ctx, req.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	case req.GetProfileId() == caller:
		if err := cs.authz.CanProductsView(ctx, req.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	default:
		// Creating a cart on behalf of someone else is a staff action.
		if err := cs.authz.CanOrdersManage(ctx, req.GetShopId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}

	cart, err := cs.cartBusiness.CreateCart(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateCartResponse{Cart: cart}, nil
}

func (cs *CommerceServer) GetCart(
	ctx context.Context,
	req *commercev1.GetCartRequest,
) (*commercev1.GetCartResponse, error) {
	cart, err := cs.authorizedCart(ctx, req.GetId(), false)
	if err != nil {
		return nil, notVisible(err)
	}
	return &commercev1.GetCartResponse{Cart: cart}, nil
}

func (cs *CommerceServer) AddCartLine(
	ctx context.Context,
	req *commercev1.AddCartLineRequest,
) (*commercev1.AddCartLineResponse, error) {
	if _, err := cs.authorizedCart(ctx, req.GetCartId(), true); err != nil {
		return nil, err
	}
	cart, err := cs.cartBusiness.AddCartLine(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.AddCartLineResponse{Cart: cart}, nil
}

func (cs *CommerceServer) RemoveCartLine(
	ctx context.Context,
	req *commercev1.RemoveCartLineRequest,
) (*commercev1.RemoveCartLineResponse, error) {
	if _, err := cs.authorizedCart(ctx, req.GetCartId(), true); err != nil {
		return nil, err
	}
	cart, err := cs.cartBusiness.RemoveCartLine(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.RemoveCartLineResponse{Cart: cart}, nil
}

// ----------------------
// Orders
// ----------------------

func (cs *CommerceServer) CreateOrderFromCart(
	ctx context.Context,
	req *commercev1.CreateOrderFromCartRequest,
) (*commercev1.CreateOrderFromCartResponse, error) {
	if _, err := cs.authorizedCart(ctx, req.GetCartId(), true); err != nil {
		return nil, err
	}
	order, err := cs.orderBusiness.CreateOrderFromCart(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateOrderFromCartResponse{Order: order}, nil
}

func (cs *CommerceServer) CreateOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
) (*commercev1.CreateOrderResponse, error) {
	// Direct order creation is a staff action on the shop.
	if err := cs.authz.CanOrdersManage(ctx, req.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	order, err := cs.orderBusiness.CreateOrder(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateOrderResponse{Order: order}, nil
}

func (cs *CommerceServer) GetOrder(
	ctx context.Context,
	req *commercev1.GetOrderRequest,
) (*commercev1.GetOrderResponse, error) {
	order, err := cs.orderBusiness.GetOrder(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if caller := callerSubject(ctx); caller == "" || order.GetProfileId() != caller {
		if authzErr := cs.authz.CanOrdersView(ctx, order.GetShopId()); authzErr != nil {
			return nil, notVisible(authorizer.ToConnectError(authzErr))
		}
	}
	return &commercev1.GetOrderResponse{Order: order}, nil
}

// ListOrders lists a shop's orders for staff. A caller without orders_view on
// the shop gets their own orders instead, so buyers can see their history.
func (cs *CommerceServer) ListOrders(
	ctx context.Context,
	req *commercev1.ListOrdersRequest,
) (*commercev1.ListOrdersResponse, error) {
	var page *business.OrderPage
	var err error

	if authzErr := cs.authz.CanOrdersView(ctx, req.GetShopId()); authzErr == nil {
		page, err = cs.orderBusiness.ListOrders(ctx, req)
	} else {
		caller := callerSubject(ctx)
		if caller == "" {
			return nil, authorizer.ToConnectError(authzErr)
		}
		page, err = cs.orderBusiness.ListOrdersForProfile(ctx, caller, req)
	}
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListOrdersResponse{
		Orders:   page.Orders,
		NextPage: page.NextPage,
	}, nil
}

// ----------------------
// Payment
// ----------------------

// CheckoutOrder may be called by the buyer who owns the order or by shop
// staff who manage orders.
func (cs *CommerceServer) CheckoutOrder(
	ctx context.Context,
	req *commercev1.CheckoutOrderRequest,
) (*commercev1.CheckoutOrderResponse, error) {
	if _, err := cs.authorizedOrder(ctx, req.GetOrderId(), cs.authz.CanOrdersManage); err != nil {
		return nil, err
	}
	result, err := cs.paymentBusiness.CheckoutOrder(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CheckoutOrderResponse{
		Order:       result.Order,
		CheckoutUrl: result.Order.GetCheckoutUrl(),
		SessionRef:  result.Order.GetPaymentSessionRef(),
		Amount:      result.Amount,
	}, nil
}

func (cs *CommerceServer) ConfirmOrderPayment(
	ctx context.Context,
	req *commercev1.ConfirmOrderPaymentRequest,
) (*commercev1.ConfirmOrderPaymentResponse, error) {
	if _, err := cs.authorizedOrder(ctx, req.GetOrderId(), cs.authz.CanOrdersManage); err != nil {
		return nil, err
	}
	order, err := cs.paymentBusiness.ConfirmOrderPayment(ctx, req.GetOrderId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ConfirmOrderPaymentResponse{Order: order}, nil
}

func (cs *CommerceServer) CancelOrder(
	ctx context.Context,
	req *commercev1.CancelOrderRequest,
) (*commercev1.CancelOrderResponse, error) {
	existing, err := cs.authorizedOrder(ctx, req.GetOrderId(), cs.authz.CanOrdersManage)
	if err != nil {
		return nil, err
	}
	staff := cs.authz.CanOrdersManage(ctx, existing.GetShopId()) == nil
	order, err := cs.paymentBusiness.CancelOrder(ctx, req.GetOrderId(), req.GetReason(), staff)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CancelOrderResponse{Order: order}, nil
}

// ReconcilePayments is a scheduled, partition-wide operation. The tenant
// level ledger_post permission (owner, admin, service) gates it.
func (cs *CommerceServer) ReconcilePayments(
	ctx context.Context,
	req *commercev1.ReconcilePaymentsRequest,
) (*commercev1.ReconcilePaymentsResponse, error) {
	if shopID := req.GetShopId(); shopID != "" {
		if err := cs.authz.CanOrdersManage(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	} else {
		ctx = sweepContext(ctx, "reconcile payments")
	}
	summary, err := cs.paymentBusiness.ReconcilePayments(ctx, req.GetShopId(), int(req.GetLimit()))
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ReconcilePaymentsResponse{
		Examined:         summary.Examined,
		Paid:             summary.Paid,
		Expired:          summary.Expired,
		Failed:           summary.Failed,
		Overdue:          summary.Overdue,
		EventsDelivered:  summary.EventsDelivered,
		RefundsSent:      summary.RefundsSent,
		RefundsConfirmed: summary.RefundsConfirmed,
	}, nil
}

func (cs *CommerceServer) RunEndOfDayLedger(
	ctx context.Context,
	req *commercev1.RunEndOfDayLedgerRequest,
) (*commercev1.RunEndOfDayLedgerResponse, error) {
	if shopID := req.GetShopId(); shopID != "" {
		if err := cs.authz.CanOrdersManage(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	} else {
		ctx = sweepContext(ctx, "end-of-day ledger")
	}
	postings, err := cs.ledgerBusiness.RunEndOfDayLedger(ctx, req.GetShopId(), req.GetDate())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.RunEndOfDayLedgerResponse{Postings: postings}, nil
}

// ----------------------
// Fulfilment
// ----------------------

func (cs *CommerceServer) CreateFulfilment(
	ctx context.Context,
	req *commercev1.CreateFulfilmentRequest,
) (*commercev1.CreateFulfilmentResponse, error) {
	if err := cs.requireOrderPermission(ctx, req.GetOrderId(), cs.authz.CanFulfilmentManage); err != nil {
		return nil, err
	}
	fulfilment, err := cs.fulfilmentBusiness.CreateFulfilment(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CreateFulfilmentResponse{Fulfilment: fulfilment}, nil
}

func (cs *CommerceServer) UpdateFulfilment(
	ctx context.Context,
	req *commercev1.UpdateFulfilmentRequest,
) (*commercev1.UpdateFulfilmentResponse, error) {
	existing, err := cs.fulfilmentBusiness.GetFulfilment(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if permErr := cs.requireOrderPermission(ctx, existing.GetOrderId(), cs.authz.CanFulfilmentManage); permErr != nil {
		return nil, permErr
	}
	fulfilment, err := cs.fulfilmentBusiness.UpdateFulfilment(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.UpdateFulfilmentResponse{Fulfilment: fulfilment}, nil
}

func (cs *CommerceServer) GetFulfilment(
	ctx context.Context,
	req *commercev1.GetFulfilmentRequest,
) (*commercev1.GetFulfilmentResponse, error) {
	fulfilment, err := cs.fulfilmentBusiness.GetFulfilment(ctx, req.GetId())
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
			return nil, notVisible(authorizer.ToConnectError(authzErr))
		}
	}
	return &commercev1.GetFulfilmentResponse{Fulfilment: fulfilment}, nil
}

// ----------------------
// Pricing
// ----------------------

func (cs *CommerceServer) PriceListSave(
	ctx context.Context,
	req *commercev1.PriceListSaveRequest,
) (*commercev1.PriceListSaveResponse, error) {
	shopID := req.GetShopId()
	if req.GetId() != "" {
		// Updates are scoped by the stored shop, not whatever the client sent.
		existing, err := cs.pricingBusiness.GetPriceList(ctx, req.GetId())
		if err != nil {
			return nil, errorutil.CleanErr(err)
		}
		shopID = existing.GetShopId()
	}
	if err := cs.authz.CanPriceListManage(ctx, shopID); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	pl, err := cs.pricingBusiness.SavePriceList(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.PriceListSaveResponse{PriceList: pl}, nil
}

func (cs *CommerceServer) PriceListGet(
	ctx context.Context,
	req *commercev1.PriceListGetRequest,
) (*commercev1.PriceListGetResponse, error) {
	pl, err := cs.pricingBusiness.GetPriceList(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanPriceListView(ctx, pl.GetShopId()); authzErr != nil {
		return nil, notVisible(authorizer.ToConnectError(authzErr))
	}
	return &commercev1.PriceListGetResponse{PriceList: pl}, nil
}

func (cs *CommerceServer) PriceListSearch(
	ctx context.Context,
	req *commercev1.PriceListSearchRequest,
) (*commercev1.PriceListSearchResponse, error) {
	if err := cs.authz.CanPriceListView(ctx, req.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	page, err := cs.pricingBusiness.SearchPriceLists(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.PriceListSearchResponse{
		PriceLists: page.Items,
		NextPage:   page.NextPage,
	}, nil
}

func (cs *CommerceServer) PriceListEntryBatchSave(
	ctx context.Context,
	req *commercev1.PriceListEntryBatchSaveRequest,
) (*commercev1.PriceListEntryBatchSaveResponse, error) {
	pl, plErr := cs.pricingBusiness.GetPriceList(ctx, req.GetPriceListId())
	if plErr != nil {
		return nil, errorutil.CleanErr(plErr)
	}
	if err := cs.authz.CanPriceListManage(ctx, pl.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	entries, err := cs.pricingBusiness.BatchSavePriceListEntries(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.PriceListEntryBatchSaveResponse{Entries: entries}, nil
}

func (cs *CommerceServer) CustomerPriceListAssignmentSave(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSaveRequest,
) (*commercev1.CustomerPriceListAssignmentSaveResponse, error) {
	if req.GetPriceListId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"price_list_id is required")
	}
	pl, plErr := cs.pricingBusiness.GetPriceList(ctx, req.GetPriceListId())
	if plErr != nil {
		return nil, errorutil.CleanErr(plErr)
	}
	if err := cs.authz.CanPriceListManage(ctx, pl.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	assignment, err := cs.pricingBusiness.SaveCustomerPriceListAssignment(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CustomerPriceListAssignmentSaveResponse{Assignment: assignment}, nil
}

func (cs *CommerceServer) CustomerPriceListAssignmentSearch(
	ctx context.Context,
	req *commercev1.CustomerPriceListAssignmentSearchRequest,
) (*commercev1.CustomerPriceListAssignmentSearchResponse, error) {
	if authzErr := cs.checkAssignmentSearchAuthz(ctx, req); authzErr != nil {
		return nil, authzErr
	}
	page, err := cs.pricingBusiness.SearchCustomerPriceListAssignments(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CustomerPriceListAssignmentSearchResponse{
		Assignments: page.Items,
		NextPage:    page.NextPage,
	}, nil
}

func (cs *CommerceServer) CustomerPriceOverrideSave(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSaveRequest,
) (*commercev1.CustomerPriceOverrideSaveResponse, error) {
	if req.GetProductVariantId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"product_variant_id is required")
	}
	shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, req.GetProductVariantId())
	if shopErr != nil {
		return nil, errorutil.CleanErr(shopErr)
	}
	if err := cs.authz.CanCustomerPriceOverride(ctx, shopID); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	override, err := cs.pricingBusiness.SaveCustomerPriceOverride(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CustomerPriceOverrideSaveResponse{Override: override}, nil
}

func (cs *CommerceServer) CustomerPriceOverrideSearch(
	ctx context.Context,
	req *commercev1.CustomerPriceOverrideSearchRequest,
) (*commercev1.CustomerPriceOverrideSearchResponse, error) {
	if authzErr := cs.checkOverrideSearchAuthz(ctx, req); authzErr != nil {
		return nil, authzErr
	}
	page, err := cs.pricingBusiness.SearchCustomerPriceOverrides(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.CustomerPriceOverrideSearchResponse{
		Overrides: page.Items,
		NextPage:  page.NextPage,
	}, nil
}

func (cs *CommerceServer) DiscountRuleSave(
	ctx context.Context,
	req *commercev1.DiscountRuleSaveRequest,
) (*commercev1.DiscountRuleSaveResponse, error) {
	shopID := req.GetShopId()
	if req.GetId() != "" {
		// Updates are scoped by the stored shop, not whatever the client sent.
		stored, err := cs.pricingBusiness.GetDiscountRuleShopID(ctx, req.GetId())
		if err != nil {
			return nil, errorutil.CleanErr(err)
		}
		shopID = stored
	}
	if err := cs.authz.CanDiscountManage(ctx, shopID); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	// Waiving a rule's approval requirement is an approver's decision.
	if req.GetId() != "" && !req.GetRequiresApproval() &&
		slices.Contains(req.GetUpdateMask().GetPaths(), "requires_approval") {
		if err := cs.authz.CanDiscountApprove(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	}
	rule, err := cs.pricingBusiness.SaveDiscountRule(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.DiscountRuleSaveResponse{DiscountRule: rule}, nil
}

func (cs *CommerceServer) DiscountRuleSearch(
	ctx context.Context,
	req *commercev1.DiscountRuleSearchRequest,
) (*commercev1.DiscountRuleSearchResponse, error) {
	if err := cs.authz.CanPriceListView(ctx, req.GetShopId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	page, err := cs.pricingBusiness.SearchDiscountRules(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.DiscountRuleSearchResponse{
		DiscountRules: page.Items,
		NextPage:      page.NextPage,
	}, nil
}

func (cs *CommerceServer) ResolvePrice(
	ctx context.Context,
	req *commercev1.ResolvePriceRequest,
) (*commercev1.ResolvePriceResponse, error) {
	// Non-privileged callers always resolve for their own identity; shop staff
	// with price_list_view may resolve for any customer.
	callerID := callerSubject(ctx)
	requestedCustomer := req.GetCustomerId()
	if requestedCustomer != "" && requestedCustomer != callerID {
		shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(
			ctx, req.GetProductVariantId(),
		)
		if shopErr != nil {
			return nil, errorutil.CleanErr(shopErr)
		}
		if err := cs.authz.CanPriceListView(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	} else if requestedCustomer == "" && callerID != "" {
		req.SetCustomerId(callerID)
	}

	resolved, err := cs.pricingBusiness.ResolvePrice(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ResolvePriceResponse{ResolvedPrice: resolved}, nil
}

// ----------------------
// Helpers
// ----------------------

// notVisible answers a read of a record the caller may not see exactly as a
// read of one that does not exist, so ids cannot be probed for existence.
func notVisible(err error) error {
	if connect.CodeOf(err) == connect.CodePermissionDenied {
		return connect.NewError(connect.CodeNotFound, "record not found")
	}
	return err
}

// sweepContext lets a partition-wide scheduled run reach every tenant when
// the scheduler (an internal service account) calls; staff stay within their
// own tenant, as row-level security binds their claims.
func sweepContext(ctx context.Context, reason string) context.Context {
	claims := security.ClaimsFromContext(ctx)
	if claims != nil && (claims.IsInternalSystem() || claims.GetTenantID() == "") {
		return dbrole.AcrossTenants(ctx, reason)
	}
	return ctx
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
			"price_list_id required for cross-customer search")
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
			"product_variant_id required for cross-customer search")
	}
	shopID, shopErr := cs.pricingBusiness.GetShopIDForVariant(ctx, msg.GetProductVariantId())
	if shopErr != nil {
		return errorutil.CleanErr(shopErr)
	}
	return authorizer.ToConnectError(cs.authz.CanCustomerPriceOverride(ctx, shopID))
}

// RecordOrderPayment applies an instalment the shop took itself. Staff only:
// unlike checkout, a buyer cannot vouch for their own payment.
func (cs *CommerceServer) RecordOrderPayment(
	ctx context.Context,
	req *commercev1.RecordOrderPaymentRequest,
) (*commercev1.RecordOrderPaymentResponse, error) {
	if err := cs.requireOrderPermission(ctx, req.GetOrderId(), cs.authz.CanOrdersManage); err != nil {
		return nil, err
	}
	order, err := cs.paymentBusiness.RecordOrderPayment(ctx, business.RecordedPayment{
		OrderID:    req.GetOrderId(),
		Amount:     req.GetAmount(),
		Reference:  req.GetReference(),
		Note:       req.GetNote(),
		RecordedBy: callerSubject(ctx),
	})
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.RecordOrderPaymentResponse{Order: order}, nil
}

// ListOrderEvents serves an order's signals to its buyer or to staff, and a
// shop's to staff.
func (cs *CommerceServer) ListOrderEvents(
	ctx context.Context,
	req *commercev1.ListOrderEventsRequest,
) (*commercev1.ListOrderEventsResponse, error) {
	shopID, orderID := req.GetShopId(), req.GetOrderId()
	switch {
	case orderID != "":
		order, err := cs.authorizedOrder(ctx, orderID, cs.authz.CanOrdersView)
		if err != nil {
			return nil, notVisible(err)
		}
		if shopID != "" && shopID != order.GetShopId() {
			return nil, connect.NewError(connect.CodeInvalidArgument, "order is not in that shop")
		}
		shopID = ""
	case shopID != "":
		if err := cs.authz.CanOrdersView(ctx, shopID); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, "shop_id or order_id is required")
	}
	page, err := business.PageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	events, err := cs.eventBusiness.List(ctx, shopID, orderID, page)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListOrderEventsResponse{
		Events: events.Events, NextPage: events.NextPage,
	}, nil
}

func (cs *CommerceServer) UpdateProduct(
	ctx context.Context,
	req *commercev1.UpdateProductRequest,
) (*commercev1.UpdateProductResponse, error) {
	existing, err := cs.catalogBusiness.GetProduct(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanProductsManage(ctx, existing.GetShopId()); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	product, err := cs.catalogBusiness.UpdateProduct(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.UpdateProductResponse{Product: product}, nil
}

// ListFulfilments lets a buyer track their own order and staff see any.
func (cs *CommerceServer) ListFulfilments(
	ctx context.Context,
	req *commercev1.ListFulfilmentsRequest,
) (*commercev1.ListFulfilmentsResponse, error) {
	if _, err := cs.authorizedOrder(ctx, req.GetOrderId(), cs.authz.CanOrdersView); err != nil {
		return nil, notVisible(err)
	}
	fulfilments, err := cs.fulfilmentBusiness.ListFulfilments(ctx, req.GetOrderId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.ListFulfilmentsResponse{Fulfilments: fulfilments}, nil
}

func (cs *CommerceServer) DiscountRuleApprove(
	ctx context.Context,
	req *commercev1.DiscountRuleApproveRequest,
) (*commercev1.DiscountRuleApproveResponse, error) {
	shopID, err := cs.pricingBusiness.GetDiscountRuleShopID(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if authzErr := cs.authz.CanDiscountApprove(ctx, shopID); authzErr != nil {
		return nil, authorizer.ToConnectError(authzErr)
	}
	rule, err := cs.pricingBusiness.ApproveDiscountRule(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &commercev1.DiscountRuleApproveResponse{DiscountRule: rule}, nil
}

// WebhookDeliveryEvent is the Frame event that delivers queued webhooks.
func (cs *CommerceServer) WebhookDeliveryEvent() events.EventI {
	return business.NewWebhookDeliveryEvent(cs.eventBusiness)
}
