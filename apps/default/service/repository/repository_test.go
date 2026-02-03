package repository_test

import (
	"context"
	"testing"

	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/apps/default/tests"
)

type RepositoryTestSuite struct {
	tests.CommerceBaseTestSuite
}

func TestRepositorySuite(t *testing.T) {
	suite.Run(t, new(RepositoryTestSuite))
}

func (rts *RepositoryTestSuite) getRepos(ctx context.Context, svc *frame.Service) (
	repository.ShopRepository,
	repository.ProductRepository,
	repository.ProductVariantRepository,
	repository.CartRepository,
	repository.CartLineRepository,
	repository.OrderRepository,
	repository.OrderLineRepository,
	repository.FulfilmentRepository,
	repository.FulfilmentLineRepository,
) {
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

	return shopRepo, productRepo, variantRepo, cartRepo, cartLineRepo, orderRepo, orderLineRepo, fulfilmentRepo, fulfilmentLineRepo
}

func (rts *RepositoryTestSuite) createTestShop(ctx context.Context, shopRepo repository.ShopRepository) *models.Shop {
	shop := &models.Shop{
		Name:   "Test Shop " + util.RandomAlphaNumericString(6),
		Slug:   "test-shop-" + util.RandomAlphaNumericString(6),
		Status: 1,
	}
	shop.GenID(ctx)
	err := shopRepo.Create(ctx, shop)
	require.NoError(rts.T(), err)
	return shop
}

func (rts *RepositoryTestSuite) createTestProduct(ctx context.Context, productRepo repository.ProductRepository, shopID string) *models.Product {
	product := &models.Product{
		ShopID: shopID,
		Name:   "Test Product " + util.RandomAlphaNumericString(6),
		Status: 1,
	}
	product.GenID(ctx)
	err := productRepo.Create(ctx, product)
	require.NoError(rts.T(), err)
	return product
}

func (rts *RepositoryTestSuite) createTestVariant(ctx context.Context, variantRepo repository.ProductVariantRepository, productID string) *models.ProductVariant {
	variant := &models.ProductVariant{
		ProductID:     productID,
		SKU:           "SKU-" + util.RandomAlphaNumericString(8),
		Name:          "Test Variant " + util.RandomAlphaNumericString(6),
		CurrencyCode:  "USD",
		PriceUnits:    10,
		PriceNanos:    0,
		StockQuantity: 100,
		Status:        1,
	}
	variant.GenID(ctx)
	err := variantRepo.Create(ctx, variant)
	require.NoError(rts.T(), err)
	return variant
}

// --- Shop Repository Tests ---

func (rts *RepositoryTestSuite) TestShopRepository_Create() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := &models.Shop{
			Name:        "My Shop",
			Slug:        "my-shop-" + util.RandomAlphaNumericString(6),
			Description: "A test shop",
			Status:      1,
		}
		shop.GenID(ctx)

		err := shopRepo.Create(ctx, shop)
		require.NoError(t, err)
		require.NotEmpty(t, shop.GetID())

		retrieved, err := shopRepo.GetByID(ctx, shop.GetID())
		require.NoError(t, err)
		require.Equal(t, shop.GetID(), retrieved.GetID())
		require.Equal(t, "My Shop", retrieved.Name)
	})
}

func (rts *RepositoryTestSuite) TestShopRepository_GetBySlug() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		slug := "unique-slug-" + util.RandomAlphaNumericString(8)
		shop := &models.Shop{
			Name:   "Slug Shop",
			Slug:   slug,
			Status: 1,
		}
		shop.GenID(ctx)
		err := shopRepo.Create(ctx, shop)
		require.NoError(t, err)

		retrieved, err := shopRepo.GetBySlug(ctx, slug)
		require.NoError(t, err)
		require.Equal(t, shop.GetID(), retrieved.GetID())
	})
}

func (rts *RepositoryTestSuite) TestShopRepository_Update() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		shop.Description = "Updated description"
		_, err := shopRepo.Update(ctx, shop, "description")
		require.NoError(t, err)

		retrieved, err := shopRepo.GetByID(ctx, shop.GetID())
		require.NoError(t, err)
		require.Equal(t, "Updated description", retrieved.Description)
	})
}

// --- Product Repository Tests ---

func (rts *RepositoryTestSuite) TestProductRepository_Create() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, _, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := &models.Product{
			ShopID:      shop.GetID(),
			Name:        "Widget",
			Description: "A fine widget",
			Status:      1,
		}
		product.GenID(ctx)

		err := productRepo.Create(ctx, product)
		require.NoError(t, err)
		require.NotEmpty(t, product.GetID())

		retrieved, err := productRepo.GetByID(ctx, product.GetID())
		require.NoError(t, err)
		require.Equal(t, "Widget", retrieved.Name)
	})
}

func (rts *RepositoryTestSuite) TestProductRepository_ListByShopID() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, _, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		for range 3 {
			rts.createTestProduct(ctx, productRepo, shop.GetID())
		}

		products, err := productRepo.ListByShopID(ctx, shop.GetID(), 50, 0)
		require.NoError(t, err)
		require.Len(t, products, 3)
	})
}

// --- Product Variant Repository Tests ---

func (rts *RepositoryTestSuite) TestProductVariantRepository_Create() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())

		variant := &models.ProductVariant{
			ProductID:     product.GetID(),
			SKU:           "SKU-" + util.RandomAlphaNumericString(8),
			Name:          "Blue Widget",
			CurrencyCode:  "USD",
			PriceUnits:    25,
			PriceNanos:    500000000, // 25.50
			StockQuantity: 50,
			Status:        1,
		}
		variant.GenID(ctx)

		err := variantRepo.Create(ctx, variant)
		require.NoError(t, err)

		retrieved, err := variantRepo.GetByID(ctx, variant.GetID())
		require.NoError(t, err)
		require.Equal(t, "Blue Widget", retrieved.Name)
		require.Equal(t, int64(25), retrieved.PriceUnits)
		require.Equal(t, int32(500000000), retrieved.PriceNanos)
	})
}

func (rts *RepositoryTestSuite) TestProductVariantRepository_ListByProductID() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())

		for range 3 {
			rts.createTestVariant(ctx, variantRepo, product.GetID())
		}

		variants, err := variantRepo.ListByProductID(ctx, product.GetID())
		require.NoError(t, err)
		require.Len(t, variants, 3)
	})
}

func (rts *RepositoryTestSuite) TestProductVariantRepository_DecrementStock() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())
		variant := rts.createTestVariant(ctx, variantRepo, product.GetID())

		err := variantRepo.DecrementStock(ctx, variant.GetID(), 10)
		require.NoError(t, err)

		updated, err := variantRepo.GetByID(ctx, variant.GetID())
		require.NoError(t, err)
		require.Equal(t, int64(90), updated.StockQuantity)
	})
}

func (rts *RepositoryTestSuite) TestProductVariantRepository_IncrementStock() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())
		variant := rts.createTestVariant(ctx, variantRepo, product.GetID())

		err := variantRepo.IncrementStock(ctx, variant.GetID(), 50)
		require.NoError(t, err)

		updated, err := variantRepo.GetByID(ctx, variant.GetID())
		require.NoError(t, err)
		require.Equal(t, int64(150), updated.StockQuantity)
	})
}

// --- Cart Repository Tests ---

func (rts *RepositoryTestSuite) TestCartRepository_CreateAndGetWithLines() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, cartRepo, cartLineRepo, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())
		variant := rts.createTestVariant(ctx, variantRepo, product.GetID())

		cart := &models.Cart{
			ShopID:    shop.GetID(),
			Status:    1,
			ProfileID: "profile-123",
		}
		cart.GenID(ctx)
		err := cartRepo.Create(ctx, cart)
		require.NoError(t, err)

		line := &models.CartLine{
			CartID:           cart.GetID(),
			ProductVariantID: variant.GetID(),
			Quantity:         3,
		}
		line.GenID(ctx)
		err = cartLineRepo.Create(ctx, line)
		require.NoError(t, err)

		cartWithLines, err := cartRepo.GetWithLines(ctx, cart.GetID())
		require.NoError(t, err)
		require.Len(t, cartWithLines.Lines, 1)
		require.Equal(t, int64(3), cartWithLines.Lines[0].Quantity)
	})
}

func (rts *RepositoryTestSuite) TestCartLineRepository_GetByCartAndVariant() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, cartRepo, cartLineRepo, _, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())
		variant := rts.createTestVariant(ctx, variantRepo, product.GetID())

		cart := &models.Cart{
			ShopID: shop.GetID(),
			Status: 1,
		}
		cart.GenID(ctx)
		err := cartRepo.Create(ctx, cart)
		require.NoError(t, err)

		line := &models.CartLine{
			CartID:           cart.GetID(),
			ProductVariantID: variant.GetID(),
			Quantity:         2,
		}
		line.GenID(ctx)
		err = cartLineRepo.Create(ctx, line)
		require.NoError(t, err)

		found, err := cartLineRepo.GetByCartAndVariant(ctx, cart.GetID(), variant.GetID())
		require.NoError(t, err)
		require.Equal(t, int64(2), found.Quantity)
	})
}

// --- Order Repository Tests ---

func (rts *RepositoryTestSuite) TestOrderRepository_CreateAndGetWithLines() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, orderRepo, orderLineRepo, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		order := &models.Order{
			ShopID:           shop.GetID(),
			OrderNumber:      "ORD-" + util.RandomAlphaNumericString(10),
			IdempotencyKey:   "idem-" + util.RandomAlphaNumericString(10),
			Status:           1,
			PaymentStatus:    1,
			ProfileID:        "profile-123",
			SubtotalCurrency: "USD",
			SubtotalUnits:    50,
			TotalCurrency:    "USD",
			TotalUnits:       50,
		}
		order.GenID(ctx)
		err := orderRepo.Create(ctx, order)
		require.NoError(t, err)

		orderLine := &models.OrderLine{
			OrderID:            order.GetID(),
			ProductVariantID:   "variant-1",
			SKUSnapshot:        "SKU-001",
			NameSnapshot:       "Widget",
			UnitPriceCurrency:  "USD",
			UnitPriceUnits:     25,
			Quantity:           2,
			TotalPriceCurrency: "USD",
			TotalPriceUnits:    50,
		}
		orderLine.GenID(ctx)
		err = orderLineRepo.Create(ctx, orderLine)
		require.NoError(t, err)

		orderWithLines, err := orderRepo.GetWithLines(ctx, order.GetID())
		require.NoError(t, err)
		require.Len(t, orderWithLines.Lines, 1)
		require.Equal(t, "Widget", orderWithLines.Lines[0].NameSnapshot)
	})
}

func (rts *RepositoryTestSuite) TestOrderRepository_GetByIdempotencyKey() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, orderRepo, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		idemKey := "idem-" + util.RandomAlphaNumericString(10)

		order := &models.Order{
			ShopID:           shop.GetID(),
			OrderNumber:      "ORD-" + util.RandomAlphaNumericString(10),
			IdempotencyKey:   idemKey,
			Status:           1,
			SubtotalCurrency: "USD",
			TotalCurrency:    "USD",
		}
		order.GenID(ctx)
		err := orderRepo.Create(ctx, order)
		require.NoError(t, err)

		found, err := orderRepo.GetByIdempotencyKey(ctx, idemKey)
		require.NoError(t, err)
		require.Equal(t, order.GetID(), found.GetID())
	})
}

func (rts *RepositoryTestSuite) TestOrderRepository_ListByShopID() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, orderRepo, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		for range 3 {
			order := &models.Order{
				ShopID:           shop.GetID(),
				OrderNumber:      "ORD-" + util.RandomAlphaNumericString(10),
				IdempotencyKey:   "idem-" + util.RandomAlphaNumericString(10),
				Status:           1,
				SubtotalCurrency: "USD",
				TotalCurrency:    "USD",
			}
			order.GenID(ctx)
			err := orderRepo.Create(ctx, order)
			require.NoError(t, err)
		}

		orders, err := orderRepo.ListByShopID(ctx, shop.GetID(), 50, 0)
		require.NoError(t, err)
		require.Len(t, orders, 3)
	})
}

// --- Fulfilment Repository Tests ---

func (rts *RepositoryTestSuite) TestFulfilmentRepository_CreateAndGetWithLines() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, orderRepo, orderLineRepo, fulfilmentRepo, fulfilmentLineRepo := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		order := &models.Order{
			ShopID:           shop.GetID(),
			OrderNumber:      "ORD-" + util.RandomAlphaNumericString(10),
			IdempotencyKey:   "idem-" + util.RandomAlphaNumericString(10),
			Status:           1,
			SubtotalCurrency: "USD",
			TotalCurrency:    "USD",
		}
		order.GenID(ctx)
		err := orderRepo.Create(ctx, order)
		require.NoError(t, err)

		orderLine := &models.OrderLine{
			OrderID:          order.GetID(),
			ProductVariantID: "variant-1",
			Quantity:         5,
		}
		orderLine.GenID(ctx)
		err = orderLineRepo.Create(ctx, orderLine)
		require.NoError(t, err)

		fulfilment := &models.Fulfilment{
			OrderID: order.GetID(),
			Status:  1,
		}
		fulfilment.GenID(ctx)
		err = fulfilmentRepo.Create(ctx, fulfilment)
		require.NoError(t, err)

		fulfilmentLine := &models.FulfilmentLine{
			FulfilmentID: fulfilment.GetID(),
			OrderLineID:  orderLine.GetID(),
			Quantity:     3,
		}
		fulfilmentLine.GenID(ctx)
		err = fulfilmentLineRepo.Create(ctx, fulfilmentLine)
		require.NoError(t, err)

		fWithLines, err := fulfilmentRepo.GetWithLines(ctx, fulfilment.GetID())
		require.NoError(t, err)
		require.Len(t, fWithLines.Lines, 1)
		require.Equal(t, int64(3), fWithLines.Lines[0].Quantity)
	})
}

func (rts *RepositoryTestSuite) TestFulfilmentLineRepository_GetFulfilledQuantity() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, _, _, _, _, orderRepo, orderLineRepo, fulfilmentRepo, fulfilmentLineRepo := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)

		order := &models.Order{
			ShopID:           shop.GetID(),
			OrderNumber:      "ORD-" + util.RandomAlphaNumericString(10),
			IdempotencyKey:   "idem-" + util.RandomAlphaNumericString(10),
			Status:           1,
			SubtotalCurrency: "USD",
			TotalCurrency:    "USD",
		}
		order.GenID(ctx)
		err := orderRepo.Create(ctx, order)
		require.NoError(t, err)

		orderLine := &models.OrderLine{
			OrderID:          order.GetID(),
			ProductVariantID: "variant-1",
			Quantity:         10,
		}
		orderLine.GenID(ctx)
		err = orderLineRepo.Create(ctx, orderLine)
		require.NoError(t, err)

		// Create two fulfilments with partial quantities
		for _, qty := range []int64{3, 4} {
			f := &models.Fulfilment{
				OrderID: order.GetID(),
				Status:  1,
			}
			f.GenID(ctx)
			err = fulfilmentRepo.Create(ctx, f)
			require.NoError(t, err)

			fl := &models.FulfilmentLine{
				FulfilmentID: f.GetID(),
				OrderLineID:  orderLine.GetID(),
				Quantity:     qty,
			}
			fl.GenID(ctx)
			err = fulfilmentLineRepo.Create(ctx, fl)
			require.NoError(t, err)
		}

		total, err := fulfilmentLineRepo.GetFulfilledQuantityByOrderLineID(ctx, orderLine.GetID())
		require.NoError(t, err)
		require.Equal(t, int64(7), total)
	})
}

func (rts *RepositoryTestSuite) TestMigrate() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)

		err := repository.Migrate(ctx, svc.DatastoreManager(), "../../migrations")
		require.NoError(t, err)
	})
}
