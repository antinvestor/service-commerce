package handlers

import (
	"context"

	"buf.build/gen/go/antinvestor/commerce/connectrpc/go/commerce/v1/commercev1connect"
	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/internal/errorutil"
)

type CommerceServer struct {
	shopBusiness      business.ShopBusiness
	catalogBusiness   business.CatalogBusiness
	cartBusiness      business.CartBusiness
	orderBusiness     business.OrderBusiness
	fulfilmentBusiness business.FulfilmentBusiness

	commercev1connect.UnimplementedCommerceServiceHandler
}

func NewCommerceServer(ctx context.Context, svc *frame.Service) *CommerceServer {
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

	return &CommerceServer{
		shopBusiness:    business.NewShopBusiness(ctx, shopRepo),
		catalogBusiness: business.NewCatalogBusiness(ctx, productRepo, variantRepo, shopRepo),
		cartBusiness:    business.NewCartBusiness(ctx, cartRepo, cartLineRepo, variantRepo),
		orderBusiness:   business.NewOrderBusiness(ctx, orderRepo, orderLineRepo, variantRepo, shopRepo, cartRepo, cartLineRepo),
		fulfilmentBusiness: business.NewFulfilmentBusiness(ctx, fulfilmentRepo, fulfilmentLineRepo, orderRepo, orderLineRepo),
	}
}

// ----------------------
// Shop
// ----------------------

func (cs *CommerceServer) CreateShop(
	ctx context.Context,
	req *connect.Request[commercev1.CreateShopRequest],
) (*connect.Response[commercev1.CreateShopResponse], error) {
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
	return connect.NewResponse(&commercev1.GetProductResponse{Product: product}), nil
}

func (cs *CommerceServer) ListProducts(
	ctx context.Context,
	req *connect.Request[commercev1.ListProductsRequest],
) (*connect.Response[commercev1.ListProductsResponse], error) {
	products, err := cs.catalogBusiness.ListProducts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.ListProductsResponse{Products: products}), nil
}

// ListProductVariants handler will be wired here once the proto is updated with:
//   rpc ListProductVariants(ListProductVariantsRequest) returns (ListProductVariantsResponse)
// The business logic is already implemented in CatalogBusiness.ListProductVariants().

func (cs *CommerceServer) CreateProductVariant(
	ctx context.Context,
	req *connect.Request[commercev1.CreateProductVariantRequest],
) (*connect.Response[commercev1.CreateProductVariantResponse], error) {
	variant, err := cs.catalogBusiness.CreateProductVariant(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.CreateProductVariantResponse{ProductVariant: variant}), nil
}

func (cs *CommerceServer) UpdateProductVariant(
	ctx context.Context,
	req *connect.Request[commercev1.UpdateProductVariantRequest],
) (*connect.Response[commercev1.UpdateProductVariantResponse], error) {
	variant, err := cs.catalogBusiness.UpdateProductVariant(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&commercev1.UpdateProductVariantResponse{ProductVariant: variant}), nil
}

// ----------------------
// Carts
// ----------------------

func (cs *CommerceServer) CreateCart(
	ctx context.Context,
	req *connect.Request[commercev1.CreateCartRequest],
) (*connect.Response[commercev1.CreateCartResponse], error) {
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
	return connect.NewResponse(&commercev1.GetOrderResponse{Order: order}), nil
}

func (cs *CommerceServer) ListOrders(
	ctx context.Context,
	req *connect.Request[commercev1.ListOrdersRequest],
) (*connect.Response[commercev1.ListOrdersResponse], error) {
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
	return connect.NewResponse(&commercev1.GetFulfilmentResponse{Fulfilment: fulfilment}), nil
}
