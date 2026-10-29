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

package business_test

import (
	"context"
	"errors"
	"strings"
	"sync"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// storefrontWith is a storefront over biz with its own limits and guest
// order cap, as another instance of the service would be.
func (bts *BusinessTestSuite) storefrontWith(
	ctx context.Context,
	svc *frame.Service,
	biz allBiz,
	limits repository.LimitRepository,
	policy business.StorefrontPolicy,
	guestUnitsCap int64,
) business.StorefrontBusiness {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()
	shopRepo := repository.NewShopRepository(ctx, dbPool, workMan)
	cartRepo := repository.NewCartRepository(ctx, dbPool, workMan)
	orders := business.NewOrderBusiness(ctx,
		repository.NewOrderRepository(ctx, dbPool, workMan),
		repository.NewOrderLineRepository(ctx, dbPool, workMan),
		repository.NewProductVariantRepository(ctx, dbPool, workMan),
		repository.NewProductRepository(ctx, dbPool, workMan),
		shopRepo, cartRepo, repository.NewCartLineRepository(ctx, dbPool, workMan),
		biz.pricingBiz,
		business.OrderPolicy{PaymentWindow: 30 * time.Minute, GuestUnitsCap: guestUnitsCap},
	)
	return business.NewStorefrontBusiness(shopRepo, biz.catalogBiz, orders, biz.paymentBiz, &fakeBuyers{},
		limits, policy, "https://api.example/commerce/")
}

func limitRepo(ctx context.Context, svc *frame.Service) repository.LimitRepository {
	return repository.NewLimitRepository(svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName))
}

func guestOrder(variantID, contact, visitor string, quantity int64) business.StorefrontOrder {
	return business.StorefrontOrder{
		Name: "Guest", Contact: contact, Visitor: visitor, Key: util.IDString(),
		Quantities: map[string]int64{variantID: quantity},
	}
}

func shopperMessage(t *testing.T, err error) *business.StorefrontError {
	t.Helper()
	var failure *business.StorefrontError
	require.ErrorAs(t, err, &failure)
	return failure
}

// Checkouts are counted per visitor (an IPv6 /64), per typed contact and
// per shop, in the database every instance shares.
func (bts *BusinessTestSuite) TestStorefront_LimitsAreSharedPerVisitorContactAndShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		visitor := context.Background()

		policy := business.StorefrontPolicy{Window: time.Hour, PerVisitor: 2, PerContact: 2, PerShop: 8}
		one := bts.storefrontWith(ctx, svc, biz, limitRepo(ctx, svc), policy, 0)
		two := bts.storefrontWith(ctx, svc, biz, limitRepo(ctx, svc), policy, 0)
		checkout := func(front business.StorefrontBusiness, contact, address string) error {
			_, err := front.Checkout(visitor, shop.GetSlug(), guestOrder(variant.GetId(), contact, address, 1))
			return err
		}

		// One subscriber's /64, through two instances.
		require.NoError(t, checkout(one, "a@x.io", "2001:db8:7:1::10"))
		require.NoError(t, checkout(two, "b@x.io", "2001:db8:7:1::99"))
		err := checkout(one, "c@x.io", "2001:db8:7:1::abc")
		require.Equal(t, connect.CodeResourceExhausted, connect.CodeOf(err), "the /64's third checkout")
		require.False(t, shopperMessage(t, err).KeepKey)

		// One contact, however typed, from different addresses.
		require.NoError(t, checkout(two, "Same@X.io", "198.51.100.1"))
		require.NoError(t, checkout(one, "same@x.io ", "198.51.100.2"))
		err = checkout(two, "same@x.io", "198.51.100.3")
		require.Equal(t, connect.CodeResourceExhausted, connect.CodeOf(err), "the contact's third checkout")

		// The shop as a whole: six checkouts so far, refused ones included.
		require.NoError(t, checkout(one, "d@x.io", "198.51.100.4"))
		require.NoError(t, checkout(two, "e@x.io", "198.51.100.5"))
		err = checkout(one, "f@x.io", "198.51.100.6")
		require.Equal(t, connect.CodeResourceExhausted, connect.CodeOf(err), "the shop's ninth checkout")

		// Another shop is counted on its own.
		other := bts.publicShop(ctx, biz)
		_, otherVariant := bts.createTestProductWithVariant(ctx, biz, other.GetId())
		_, err = one.Checkout(visitor, other.GetSlug(), guestOrder(otherVariant.GetId(), "f@x.io", "198.51.100.5", 1))
		require.NoError(t, err)

		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		require.Len(t, orders.Orders, 6, "refused checkouts place nothing")
	})
}

type brokenLimits struct{}

func (brokenLimits) Hit(context.Context, []string, time.Time, time.Time) (map[string]int64, error) {
	return nil, errors.New("database unavailable")
}

// Without a working count no anonymous order is taken.
func (bts *BusinessTestSuite) TestStorefront_LimitFailsClosed() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		for name, limits := range map[string]repository.LimitRepository{"broken": brokenLimits{}, "missing": nil} {
			front := bts.storefrontWith(ctx, svc, biz, limits, business.StorefrontPolicy{}, 0)
			_, err := front.Checkout(context.Background(), shop.GetSlug(),
				guestOrder(variant.GetId(), "a@x.io", "198.51.100.1", 1))
			require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err), name)
		}
		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		require.Empty(t, orders.Orders)
	})
}

// A shop's unpaid guest orders hold no more than the cap.
func (bts *BusinessTestSuite) TestStorefront_GuestOrdersHoldAtMostTheCap() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		front := bts.storefrontWith(ctx, svc, biz, limitRepo(ctx, svc), business.StorefrontPolicy{}, 5)

		_, err := front.Checkout(context.Background(), shop.GetSlug(),
			guestOrder(variant.GetId(), "a@x.io", "198.51.100.1", 3))
		require.NoError(t, err)
		_, err = front.Checkout(context.Background(), shop.GetSlug(),
			guestOrder(variant.GetId(), "b@x.io", "198.51.100.2", 3))
		require.Equal(t, connect.CodeResourceExhausted, connect.CodeOf(err))
		require.Contains(t, shopperMessage(t, err).Message, "too many unpaid orders")

		got, err := biz.catalogBiz.ListProductVariants(ctx, variant.GetProductId())
		require.NoError(t, err)
		require.Equal(t, int64(97), got[0].GetStockQuantity(), "the refused order held nothing")
	})
}

// The deposit is checked before anything is held, and a form whose order
// was not placed comes back ready to send again.
func (bts *BusinessTestSuite) TestStorefront_DepositIsCheckedBeforeTheOrderIsPlaced() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		front := bts.storefront(ctx, svc, biz, &fakeBuyers{})
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())

		// 30% of 21.00 is 6.30.
		order := guestOrder(variant.GetId(), "a@x.io", "198.51.100.1", 2)
		order.Deposit = "5"
		_, err := front.Checkout(context.Background(), shop.GetSlug(), order)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		failure := shopperMessage(t, err)
		require.Equal(t, "The minimum deposit is 6.30 USD.", failure.Message)
		require.False(t, failure.KeepKey, "nothing was placed")

		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		require.Empty(t, orders.Orders, "no stock is held for a refused deposit")

		// Corrected, the same form goes through.
		order.Deposit = "6.30"
		_, err = front.Checkout(context.Background(), shop.GetSlug(), order)
		require.NoError(t, err)

		// Reusing that key for a different order is told plainly.
		order.Quantities = map[string]int64{variant.GetId(): 3}
		_, err = front.Checkout(context.Background(), shop.GetSlug(), order)
		require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(err))
		require.False(t, shopperMessage(t, err).KeepKey, "a fresh key lets the changed order through")
	})
}

// Anonymous callers learn nothing about stock levels or record ids.
func (bts *BusinessTestSuite) TestStorefront_ErrorsAreFixedText() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		front := bts.storefront(ctx, svc, biz, &fakeBuyers{})
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		other := bts.createTestShop(ctx, biz)
		_, foreign := bts.createTestProductWithVariant(ctx, biz, other.GetId())

		for name, order := range map[string]business.StorefrontOrder{
			"more than in stock": guestOrder(variant.GetId(), "a@x.io", "198.51.100.1", 99),
			"another shop's":     guestOrder(foreign.GetId(), "b@x.io", "198.51.100.2", 1),
			"no such item":       guestOrder("no-such-variant", "c@x.io", "198.51.100.3", 1),
		} {
			if name == "more than in stock" {
				_, err := biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
					VariantId: variant.GetId(), StockQuantity: 2,
					UpdateMask: fieldMask("stock_quantity"),
				})
				require.NoError(t, err)
			}
			_, err := front.Checkout(context.Background(), shop.GetSlug(), order)
			require.Error(t, err, name)
			message := shopperMessage(t, err).Message
			require.Equal(t, "Some of those items are no longer available in the quantities chosen. "+
				"Please check your order.", message, name)
		}
	})
}

// An order whose only fulfilment was cancelled has not shipped, and can be
// cancelled.
func (bts *BusinessTestSuite) TestCancelOrder_AfterItsFulfilmentWasCancelled() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines:  []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: 1}},
		})
		require.NoError(t, err)
		f, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines:   []*commercev1.FulfilmentLine{{OrderLineId: order.GetLines()[0].GetId(), Quantity: 1}},
		})
		require.NoError(t, err)
		_, err = biz.fulfilmentBiz.UpdateFulfilment(ctx, &commercev1.UpdateFulfilmentRequest{
			Id: f.GetId(), Status: commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED,
		})
		require.NoError(t, err)

		cancelled, err := biz.paymentBiz.CancelOrder(ctx, order.GetId(), "changed my mind", true)
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, cancelled.GetStatus())
	})
}

// A reused idempotency key returns the first order only for the same
// request, however the retries race.
func (bts *BusinessTestSuite) TestCreateOrder_RacingKeyReuseNeverReturnsAnotherOrder() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		const racers = 6
		key := "race-" + util.RandomAlphaNumericString(8)
		var wg sync.WaitGroup
		results := make([]*commercev1.Order, racers)
		errs := make([]error, racers)
		for i := range racers {
			wg.Add(1)
			go func() {
				defer wg.Done()
				results[i], errs[i] = biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
					ShopId: shop.GetId(), IdempotencyKey: key,
					Lines: []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: int64(i + 1)}},
				})
			}()
		}
		wg.Wait()

		created := 0
		for i := range racers {
			if errs[i] != nil {
				require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(errs[i]))
				continue
			}
			created++
			require.Equal(t, int64(i+1), results[i].GetLines()[0].GetQuantity(), "only its own order")
		}
		require.Equal(t, 1, created)
	})
}

// Overlapping quantity bands are refused, and the same list always wins a
// tie in priority.
func (bts *BusinessTestSuite) TestPriceListTiers_NoOverlapAndDeterministic() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		price := func(units int64) *commonv1.Money { return &commonv1.Money{CurrencyCode: "USD", Units: units} }

		list, err := biz.pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId: shop.GetId(), Name: "Trade", Priority: 10,
		})
		require.NoError(t, err)
		require.Equal(t, "USD", list.GetCurrency(), "a list prices in the shop's currency")

		for name, bands := range map[string][][2]int32{
			"overlapping":       {{1, 10}, {10, 20}},
			"open then another": {{5, 0}, {50, 0}},
			"floor inside":      {{0, 9}, {3, 0}},
		} {
			entries := make([]*commercev1.PriceListEntry, 0, len(bands))
			for _, b := range bands {
				entries = append(entries, &commercev1.PriceListEntry{
					ProductVariantId: variant.GetId(), UnitPrice: price(9), MinQuantity: b[0], MaxQuantity: b[1],
				})
			}
			_, err = biz.pricingBiz.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
				PriceListId: list.GetId(), Entries: entries,
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), name)
		}

		_, err = biz.pricingBiz.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
			PriceListId: list.GetId(),
			Entries: []*commercev1.PriceListEntry{
				{ProductVariantId: variant.GetId(), UnitPrice: price(9), MinQuantity: 1, MaxQuantity: 9},
				{ProductVariantId: variant.GetId(), UnitPrice: price(8), MinQuantity: 10},
			},
		})
		require.NoError(t, err)

		twin, err := biz.pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId: shop.GetId(), Name: "Trade too", Priority: 10,
		})
		require.NoError(t, err)
		_, err = biz.pricingBiz.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
			PriceListId: twin.GetId(),
			Entries:     []*commercev1.PriceListEntry{{ProductVariantId: variant.GetId(), UnitPrice: price(7)}},
		})
		require.NoError(t, err)

		customer := "customer-" + util.RandomAlphaNumericString(6)
		for _, id := range []string{list.GetId(), twin.GetId()} {
			assignment := &commercev1.CustomerPriceListAssignmentSaveRequest{CustomerId: customer, PriceListId: id}
			_, err = biz.pricingBiz.SaveCustomerPriceListAssignment(ctx, assignment)
			require.NoError(t, err)
		}
		first := min(list.GetId(), twin.GetId())
		for range 5 {
			resolved, resolveErr := biz.pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
				CustomerId: customer, ProductVariantId: variant.GetId(), Quantity: 12,
			})
			require.NoError(t, resolveErr)
			require.Equal(t, first, resolved.GetPriceListId(), "equal priority: the lower id, every time")
		}

		resolved, err := biz.pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
			CustomerId: customer, ProductVariantId: variant.GetId(), Quantity: 12,
		})
		require.NoError(t, err)
		if resolved.GetPriceListId() == list.GetId() {
			require.Equal(t, int64(8), resolved.GetUnitPrice().GetUnits(), "the 10+ band")
		}
	})
}

// A fixed discount is money in the shop's currency, taken off exactly.
func (bts *BusinessTestSuite) TestFixedDiscount_IsAnAmountInTheShopsCurrency() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		_, err := biz.pricingBiz.SaveDiscountRule(ctx, &commercev1.DiscountRuleSaveRequest{
			ShopId: shop.GetId(), Name: "Two fifty off", Value: 2.5,
			DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT,
			AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM,
		})
		require.NoError(t, err)

		resolved, err := biz.pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
			ProductVariantId: variant.GetId(), Quantity: 1,
		})
		require.NoError(t, err)
		require.Equal(t, "USD", resolved.GetUnitPrice().GetCurrencyCode())
		require.Equal(t, int64(8), resolved.GetUnitPrice().GetUnits(), "10.50 - 2.50")
		require.Equal(t, int32(0), resolved.GetUnitPrice().GetNanos())
		require.Equal(t, int64(2), resolved.GetDiscountAmount().GetUnits())
		require.Equal(t, int32(500_000_000), resolved.GetDiscountAmount().GetNanos())

		for name, req := range map[string]*commercev1.DiscountRuleSaveRequest{
			"negative amount": {Value: -1, DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT},
			"over 100%":       {Value: 150, DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE},
			"bad cap":         {Value: 5, DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE, MaxDiscountPercent: 101},
			"no type":         {Value: 5},
		} {
			req.ShopId, req.Name = shop.GetId(), name
			req.AppliesTo = commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM
			_, err = biz.pricingBiz.SaveDiscountRule(ctx, req)
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), name)
		}
	})
}

// Every price a caller sets is checked the same way.
func (bts *BusinessTestSuite) TestPrices_AreValidMoneyInTheShopsCurrency() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		product, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		bad := map[string]*commonv1.Money{
			"negative":       {CurrencyCode: "USD", Units: -1},
			"negative nanos": {CurrencyCode: "USD", Nanos: -5},
			"nanos overflow": {CurrencyCode: "USD", Units: 1, Nanos: 1_000_000_000},
			"other currency": {CurrencyCode: "KES", Units: 100},
			"not a currency": {CurrencyCode: "XYZ1", Units: 1},
			"no currency":    {Units: 1},
			"too large":      {CurrencyCode: "USD", Units: 1_000_000_000},
		}
		for name, money := range bad {
			_, err := biz.catalogBiz.CreateProductVariant(ctx, &commercev1.CreateProductVariantRequest{
				ProductId: product.GetId(), Sku: "SKU-" + util.RandomAlphaNumericString(8), Price: money,
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "variant: "+name)

			_, err = biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
				VariantId: variant.GetId(), Price: money, UpdateMask: fieldMask("price"),
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "variant update: "+name)

			_, err = biz.pricingBiz.SaveCustomerPriceOverride(ctx, &commercev1.CustomerPriceOverrideSaveRequest{
				CustomerId: "c-1", ProductVariantId: variant.GetId(), UnitPrice: money,
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "override: "+name)
		}

		list, err := biz.pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId: shop.GetId(), Name: "Trade",
		})
		require.NoError(t, err)
		_, err = biz.pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId: shop.GetId(), Name: "Shillings", Currency: "KES",
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "a list in another currency")
		_, err = biz.pricingBiz.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
			PriceListId: list.GetId(),
			Entries: []*commercev1.PriceListEntry{{
				ProductVariantId: variant.GetId(), UnitPrice: &commonv1.Money{CurrencyCode: "KES", Units: 1},
			}},
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "an entry in another currency")

		// A lower-case code is accepted and stored normalised.
		created, err := biz.catalogBiz.CreateProductVariant(ctx, &commercev1.CreateProductVariantRequest{
			ProductId: product.GetId(), Sku: "SKU-" + util.RandomAlphaNumericString(8),
			Price: &commonv1.Money{CurrencyCode: "usd", Units: 3, Nanos: 250_000_000},
		})
		require.NoError(t, err)
		require.Equal(t, "USD", created.GetPrice().GetCurrencyCode())
	})
}

// A buyer's history narrowed to one shop pages through that shop's orders.
func (bts *BusinessTestSuite) TestListOrdersForProfile_ShopFilterPagesFully() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		mine, other := bts.createTestShop(ctx, biz), bts.createTestShop(ctx, biz)
		_, mineVariant := bts.createTestProductWithVariant(ctx, biz, mine.GetId())
		_, otherVariant := bts.createTestProductWithVariant(ctx, biz, other.GetId())

		for range 2 {
			bts.buyerOrder(ctx, biz, mine.GetId(), mineVariant.GetId(), "buyer-p", 1)
			bts.buyerOrder(ctx, biz, other.GetId(), otherVariant.GetId(), "buyer-p", 1)
			bts.buyerOrder(ctx, biz, other.GetId(), otherVariant.GetId(), "buyer-p", 1)
		}
		page, err := biz.orderBiz.ListOrdersForProfile(ctx, "buyer-p", &commercev1.ListOrdersRequest{
			ShopId: mine.GetId(),
			Search: &commonv1.SearchRequest{Cursor: &commonv1.PageCursor{Limit: 2}},
		})
		require.NoError(t, err)
		require.Len(t, page.Orders, 2, "a full page of this shop's orders")
		for _, o := range page.Orders {
			require.Equal(t, mine.GetId(), o.GetShopId())
		}
	})
}

// Placing an order with many lines prices them all from one load.
func (bts *BusinessTestSuite) TestCreateOrder_ManyLinesPriceTogether() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		lines := make([]*commercev1.CreateOrderLine, 0, 20)
		for range 20 {
			_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
			lines = append(lines, &commercev1.CreateOrderLine{VariantId: variant.GetId(), Quantity: 1})
		}
		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{ShopId: shop.GetId(), Lines: lines})
		require.NoError(t, err)
		require.Len(t, order.GetLines(), 20)
		require.Equal(t, int64(210), order.GetTotal().GetUnits(), "20 x 10.50")
		require.True(t, strings.EqualFold("USD", order.GetTotal().GetCurrencyCode()))
	})
}

func fieldMask(paths ...string) *fieldmaskpb.FieldMask { return &fieldmaskpb.FieldMask{Paths: paths} }
