package business_test

import (
	"context"
	"testing"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	money "google.golang.org/genproto/googleapis/type/money"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/apps/default/tests"
)

type BusinessTestSuite struct {
	tests.CommerceBaseTestSuite
}

func TestBusinessSuite(t *testing.T) {
	suite.Run(t, new(BusinessTestSuite))
}

type allBiz struct {
	shopBiz       business.ShopBusiness
	catalogBiz    business.CatalogBusiness
	cartBiz       business.CartBusiness
	orderBiz      business.OrderBusiness
	fulfilmentBiz business.FulfilmentBusiness
}

func (bts *BusinessTestSuite) getBusiness(ctx context.Context, svc *frame.Service) allBiz {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()

	shopRepo := repository.NewShopRepository(ctx, dbPool, workMan)
	productRepo := repository.NewProductRepository(ctx, dbPool, workMan)
	variantRepo := repository.NewProductVariantRepository(ctx, dbPool, workMan)
	cartRepo := repository.NewCartRepository(ctx, dbPool, workMan)
	cartLineRepo := repository.NewCartLineRepository(ctx, dbPool, workMan)
	orderRepo := repository.NewOrderRepository(ctx, dbPool, workMan)
	orderLineRepo := repository.NewOrderLineRepository(ctx, dbPool, workMan)
	fulfilmentRepo := repository.NewFulfilmentRepository(ctx, dbPool, workMan)
	fulfilmentLineRepo := repository.NewFulfilmentLineRepository(ctx, dbPool, workMan)

	return allBiz{
		shopBiz:       business.NewShopBusiness(ctx, shopRepo),
		catalogBiz:    business.NewCatalogBusiness(ctx, productRepo, variantRepo, shopRepo),
		cartBiz:       business.NewCartBusiness(ctx, cartRepo, cartLineRepo, variantRepo),
		orderBiz:      business.NewOrderBusiness(ctx, orderRepo, orderLineRepo, variantRepo, shopRepo, cartRepo, cartLineRepo),
		fulfilmentBiz: business.NewFulfilmentBusiness(ctx, fulfilmentRepo, fulfilmentLineRepo, orderRepo, orderLineRepo),
	}
}

func (bts *BusinessTestSuite) createTestShop(ctx context.Context, biz allBiz) *commercev1.Shop {
	t := bts.T()
	shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
		Name: "Test Shop " + util.RandomAlphaNumericString(6),
		Slug: "test-shop-" + util.RandomAlphaNumericString(6),
	})
	require.NoError(t, err)
	return shop
}

func (bts *BusinessTestSuite) createTestProductWithVariant(ctx context.Context, biz allBiz, shopID string) (*commercev1.Product, *commercev1.ProductVariant) {
	t := bts.T()

	product, err := biz.catalogBiz.CreateProduct(ctx, &commercev1.CreateProductRequest{
		ShopId: shopID,
		Name:   "Test Product " + util.RandomAlphaNumericString(6),
	})
	require.NoError(t, err)

	variant, err := biz.catalogBiz.CreateProductVariant(ctx, &commercev1.CreateProductVariantRequest{
		ProductId: product.GetId(),
		Sku:       "SKU-" + util.RandomAlphaNumericString(8),
		Name:      "Test Variant",
		Price: &money.Money{
			CurrencyCode: "USD",
			Units:        10,
			Nanos:        500000000, // $10.50
		},
		StockQuantity: 100,
	})
	require.NoError(t, err)

	return product, variant
}

// --- Shop Business Tests ---

func (bts *BusinessTestSuite) TestCreateShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name:        "Coffee Corner",
			Slug:        "coffee-corner-" + util.RandomAlphaNumericString(6),
			Description: "A nice coffee shop",
		})
		require.NoError(t, err)
		require.NotEmpty(t, shop.GetId())
		require.Equal(t, "Coffee Corner", shop.GetName())
		require.Equal(t, commercev1.ShopStatus_SHOP_STATUS_ACTIVE, shop.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestCreateShop_EmptyName() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		_, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "",
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestCreateShop_DuplicateSlug() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		slug := "unique-slug-" + util.RandomAlphaNumericString(8)

		_, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "Shop 1",
			Slug: slug,
		})
		require.NoError(t, err)

		_, err = biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "Shop 2",
			Slug: slug,
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestGetShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		retrieved, err := biz.shopBiz.GetShop(ctx, shop.GetId())
		require.NoError(t, err)
		require.Equal(t, shop.GetId(), retrieved.GetId())
	})
}

func (bts *BusinessTestSuite) TestUpdateShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		updated, err := biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id:          shop.GetId(),
			Description: "Updated description",
		})
		require.NoError(t, err)
		require.Equal(t, "Updated description", updated.GetDescription())
	})
}

// --- Catalog Business Tests ---

func (bts *BusinessTestSuite) TestCreateProduct() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		product, err := biz.catalogBiz.CreateProduct(ctx, &commercev1.CreateProductRequest{
			ShopId:      shop.GetId(),
			Name:        "Laptop",
			Description: "A powerful laptop",
		})
		require.NoError(t, err)
		require.NotEmpty(t, product.GetId())
		require.Equal(t, "Laptop", product.GetName())
	})
}

func (bts *BusinessTestSuite) TestCreateProduct_InvalidShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		_, err := biz.catalogBiz.CreateProduct(ctx, &commercev1.CreateProductRequest{
			ShopId: "nonexistent-shop",
			Name:   "Widget",
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestListProducts() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		for range 3 {
			_, err := biz.catalogBiz.CreateProduct(ctx, &commercev1.CreateProductRequest{
				ShopId: shop.GetId(),
				Name:   "Product " + util.RandomAlphaNumericString(6),
			})
			require.NoError(t, err)
		}

		products, err := biz.catalogBiz.ListProducts(ctx, &commercev1.ListProductsRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)
		require.Len(t, products, 3)
	})
}

func (bts *BusinessTestSuite) TestCreateProductVariant() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		require.NotEmpty(t, variant.GetId())
		require.Equal(t, "Test Variant", variant.GetName())
		require.Equal(t, int64(10), variant.GetPrice().GetUnits())
		require.Equal(t, int32(500000000), variant.GetPrice().GetNanos())
		require.Equal(t, int64(100), variant.GetStockQuantity())
	})
}

func (bts *BusinessTestSuite) TestUpdateProductVariant() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		updated, err := biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
			VariantId: variant.GetId(),
			Name:      "Updated Variant",
			Price: &money.Money{
				CurrencyCode: "EUR",
				Units:        20,
			},
		})
		require.NoError(t, err)
		require.Equal(t, "Updated Variant", updated.GetName())
		require.Equal(t, "EUR", updated.GetPrice().GetCurrencyCode())
		require.Equal(t, int64(20), updated.GetPrice().GetUnits())
	})
}

// --- Cart Business Tests ---

func (bts *BusinessTestSuite) TestCreateCart() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId:    shop.GetId(),
			ProfileId: "profile-123",
		})
		require.NoError(t, err)
		require.NotEmpty(t, cart.GetId())
		require.Equal(t, commercev1.CartStatus_CART_STATUS_ACTIVE, cart.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestAddCartLine() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)

		updatedCart, err := biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId:           cart.GetId(),
			ProductVariantId: variant.GetId(),
			Quantity:         2,
		})
		require.NoError(t, err)
		require.Len(t, updatedCart.GetLines(), 1)
		require.Equal(t, int64(2), updatedCart.GetLines()[0].GetQuantity())
	})
}

func (bts *BusinessTestSuite) TestAddCartLine_MergesSameVariant() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)

		_, err = biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId:           cart.GetId(),
			ProductVariantId: variant.GetId(),
			Quantity:         2,
		})
		require.NoError(t, err)

		updatedCart, err := biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId:           cart.GetId(),
			ProductVariantId: variant.GetId(),
			Quantity:         3,
		})
		require.NoError(t, err)
		require.Len(t, updatedCart.GetLines(), 1)
		require.Equal(t, int64(5), updatedCart.GetLines()[0].GetQuantity())
	})
}

func (bts *BusinessTestSuite) TestRemoveCartLine() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)

		cartWithLine, err := biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId:           cart.GetId(),
			ProductVariantId: variant.GetId(),
			Quantity:         2,
		})
		require.NoError(t, err)
		require.Len(t, cartWithLine.GetLines(), 1)

		lineID := cartWithLine.GetLines()[0].GetId()
		updatedCart, err := biz.cartBiz.RemoveCartLine(ctx, &commercev1.RemoveCartLineRequest{
			CartId:     cart.GetId(),
			CartLineId: lineID,
		})
		require.NoError(t, err)
		require.Empty(t, updatedCart.GetLines())
	})
}

// --- Order Business Tests ---

func (bts *BusinessTestSuite) TestCreateOrder() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId:    shop.GetId(),
			ProfileId: "profile-123",
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  2,
				},
			},
		})
		require.NoError(t, err)
		require.NotEmpty(t, order.GetId())
		require.NotEmpty(t, order.GetOrderNumber())
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CONFIRMED, order.GetStatus())
		require.Len(t, order.GetLines(), 1)
		require.Equal(t, int64(2), order.GetLines()[0].GetQuantity())
		// Price should be 2 * $10.50 = $21.00
		require.Equal(t, int64(21), order.GetTotal().GetUnits())
		require.Equal(t, int32(0), order.GetTotal().GetNanos())
	})
}

func (bts *BusinessTestSuite) TestCreateOrder_Idempotency() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		idemKey := "order-idem-" + util.RandomAlphaNumericString(10)
		req := &commercev1.CreateOrderRequest{
			ShopId:         shop.GetId(),
			ProfileId:      "profile-123",
			IdempotencyKey: idemKey,
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  1,
				},
			},
		}

		order1, err := biz.orderBiz.CreateOrder(ctx, req)
		require.NoError(t, err)

		order2, err := biz.orderBiz.CreateOrder(ctx, req)
		require.NoError(t, err)
		require.Equal(t, order1.GetId(), order2.GetId())
	})
}

func (bts *BusinessTestSuite) TestCreateOrder_InsufficientStock() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		_, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  999, // Stock is 100
				},
			},
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestCreateOrder_EmptyLines() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)

		_, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines:  nil,
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestCreateOrderFromCart() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)

		_, err = biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId:           cart.GetId(),
			ProductVariantId: variant.GetId(),
			Quantity:         3,
		})
		require.NoError(t, err)

		order, err := biz.orderBiz.CreateOrderFromCart(ctx, &commercev1.CreateOrderFromCartRequest{
			CartId:    cart.GetId(),
			ProfileId: "profile-123",
		})
		require.NoError(t, err)
		require.NotEmpty(t, order.GetId())
		require.Len(t, order.GetLines(), 1)
		require.Equal(t, int64(3), order.GetLines()[0].GetQuantity())

		// Cart should be converted
		updatedCart, err := biz.cartBiz.GetCart(ctx, cart.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.CartStatus_CART_STATUS_CONVERTED, updatedCart.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestListOrders() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		for range 2 {
			_, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
				ShopId: shop.GetId(),
				Lines: []*commercev1.CreateOrderLine{
					{
						VariantId: variant.GetId(),
						Quantity:  1,
					},
				},
			})
			require.NoError(t, err)
		}

		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{
			ShopId: shop.GetId(),
		})
		require.NoError(t, err)
		require.Len(t, orders, 2)
	})
}

// --- Fulfilment Business Tests ---

func (bts *BusinessTestSuite) TestCreateFulfilment() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  5,
				},
			},
		})
		require.NoError(t, err)

		orderLineID := order.GetLines()[0].GetId()

		fulfilment, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines: []*commercev1.FulfilmentLine{
				{
					OrderLineId: orderLineID,
					Quantity:    3,
				},
			},
		})
		require.NoError(t, err)
		require.NotEmpty(t, fulfilment.GetId())
		require.Len(t, fulfilment.GetLines(), 1)
		require.Equal(t, int64(3), fulfilment.GetLines()[0].GetQuantity())
	})
}

func (bts *BusinessTestSuite) TestCreateFulfilment_FullyFulfilled() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  5,
				},
			},
		})
		require.NoError(t, err)

		orderLineID := order.GetLines()[0].GetId()

		// Fulfil all 5 items
		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines: []*commercev1.FulfilmentLine{
				{
					OrderLineId: orderLineID,
					Quantity:    5,
				},
			},
		})
		require.NoError(t, err)

		// Check order status is fully fulfilled
		updatedOrder, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_FULFILLED, updatedOrder.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestCreateFulfilment_ExceedsQuantity() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  5,
				},
			},
		})
		require.NoError(t, err)

		orderLineID := order.GetLines()[0].GetId()

		// Try to fulfil more than ordered
		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines: []*commercev1.FulfilmentLine{
				{
					OrderLineId: orderLineID,
					Quantity:    10,
				},
			},
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestUpdateFulfilment() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{
					VariantId: variant.GetId(),
					Quantity:  5,
				},
			},
		})
		require.NoError(t, err)

		orderLineID := order.GetLines()[0].GetId()

		fulfilment, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines: []*commercev1.FulfilmentLine{
				{
					OrderLineId: orderLineID,
					Quantity:    5,
				},
			},
		})
		require.NoError(t, err)

		updated, err := biz.fulfilmentBiz.UpdateFulfilment(ctx, &commercev1.UpdateFulfilmentRequest{
			Id:             fulfilment.GetId(),
			Status:         commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED,
			Carrier:        "FedEx",
			TrackingNumber: "TRACK-12345",
		})
		require.NoError(t, err)
		require.Equal(t, commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED, updated.GetStatus())
		require.Equal(t, "FedEx", updated.GetCarrier())
		require.Equal(t, "TRACK-12345", updated.GetTrackingNumber())
	})
}
