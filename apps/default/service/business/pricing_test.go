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
	"testing"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

func (bts *BusinessTestSuite) getPricingBusiness(svc *frame.Service) business.PricingBusiness {
	ctx := bts.T().Context()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()

	shopRepo := repository.NewShopRepository(ctx, dbPool, workMan)
	productRepo := repository.NewProductRepository(ctx, dbPool, workMan)
	variantRepo := repository.NewProductVariantRepository(ctx, dbPool, workMan)
	priceListRepo := repository.NewPriceListRepository(ctx, dbPool, workMan)
	priceListEntryRepo := repository.NewPriceListEntryRepository(ctx, dbPool, workMan)
	assignmentRepo := repository.NewCustomerPriceListAssignmentRepository(ctx, dbPool, workMan)
	overrideRepo := repository.NewCustomerPriceOverrideRepository(ctx, dbPool, workMan)
	discountRuleRepo := repository.NewDiscountRuleRepository(ctx, dbPool, workMan)

	return business.NewPricingBusiness(
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
}

// --- PriceList Tests ---

func (bts *BusinessTestSuite) TestCreatePriceList() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricingBiz := bts.getPricingBusiness(svc)

		shop := bts.createTestShop(ctx, biz)

		pl, err := pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId:   shop.GetId(),
			Name:     "Wholesale Prices",
			Currency: "USD",
			Priority: 10,
		})
		require.NoError(t, err)
		require.NotEmpty(t, pl.GetId())
		require.Equal(t, "Wholesale Prices", pl.GetName())
		require.Equal(t, "USD", pl.GetCurrency())
		require.Equal(t, int32(10), pl.GetPriority())
		require.Equal(t, commercev1.PriceListStatus_PRICE_LIST_STATUS_ACTIVE, pl.GetStatus())

		// Verify get
		retrieved, err := pricingBiz.GetPriceList(ctx, pl.GetId())
		require.NoError(t, err)
		require.Equal(t, pl.GetId(), retrieved.GetId())
		require.Equal(t, "Wholesale Prices", retrieved.GetName())
	})
}

// --- PriceListEntry Tests ---

func (bts *BusinessTestSuite) TestPriceListEntryBatchSave() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricingBiz := bts.getPricingBusiness(svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		pl, err := pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId:   shop.GetId(),
			Name:     "Test Price List",
			Currency: "USD",
			Priority: 5,
		})
		require.NoError(t, err)

		// Batch save entries
		entries, err := pricingBiz.BatchSavePriceListEntries(
			ctx,
			&commercev1.PriceListEntryBatchSaveRequest{
				PriceListId: pl.GetId(),
				Entries: []*commercev1.PriceListEntry{
					{
						ProductVariantId: variant.GetId(),
						UnitPrice: &commonv1.Money{
							CurrencyCode: "USD",
							Units:        20,
							Nanos:        0,
						},
						MinQuantity: 1,
						MaxQuantity: 99,
					},
					{
						ProductVariantId: variant.GetId(),
						UnitPrice: &commonv1.Money{
							CurrencyCode: "USD",
							Units:        15,
							Nanos:        0,
						},
						MinQuantity: 100,
						MaxQuantity: 0,
					},
				},
			},
		)
		require.NoError(t, err)
		require.Len(t, entries, 2)
		require.Equal(t, int64(20), entries[0].GetUnitPrice().GetUnits())
		require.Equal(t, int64(15), entries[1].GetUnitPrice().GetUnits())
	})
}

// --- ResolvePrice Tests ---

func (bts *BusinessTestSuite) TestResolvePrice() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricingBiz := bts.getPricingBusiness(svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		customerID := "customer-" + util.RandomAlphaNumericString(8)

		// Step 1: Resolve without any pricing -- should return catalog price
		resolved, err := pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
			CustomerId:       customerID,
			ProductVariantId: variant.GetId(),
			Quantity:         1,
		})
		require.NoError(t, err)
		require.Equal(t, commercev1.PriceSource_PRICE_SOURCE_CATALOG, resolved.GetPriceSource())
		require.Equal(t, int64(10), resolved.GetUnitPrice().GetUnits())

		// Step 2: Create a price list, entry, and assignment -- resolve should use price list
		pl, err := pricingBiz.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId:   shop.GetId(),
			Name:     "VIP Price List",
			Currency: "USD",
			Priority: 10,
		})
		require.NoError(t, err)

		_, err = pricingBiz.BatchSavePriceListEntries(
			ctx,
			&commercev1.PriceListEntryBatchSaveRequest{
				PriceListId: pl.GetId(),
				Entries: []*commercev1.PriceListEntry{
					{
						ProductVariantId: variant.GetId(),
						UnitPrice: &commonv1.Money{
							CurrencyCode: "USD",
							Units:        8,
							Nanos:        0,
						},
						MinQuantity: 0,
						MaxQuantity: 0,
					},
				},
			},
		)
		require.NoError(t, err)

		_, err = pricingBiz.SaveCustomerPriceListAssignment(
			ctx,
			&commercev1.CustomerPriceListAssignmentSaveRequest{
				CustomerId:  customerID,
				PriceListId: pl.GetId(),
				AssignedBy:  "admin-user",
			},
		)
		require.NoError(t, err)

		resolved, err = pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
			CustomerId:       customerID,
			ProductVariantId: variant.GetId(),
			Quantity:         1,
		})
		require.NoError(t, err)
		require.Equal(t, commercev1.PriceSource_PRICE_SOURCE_PRICE_LIST, resolved.GetPriceSource())
		require.Equal(t, int64(8), resolved.GetUnitPrice().GetUnits())
		require.Equal(t, pl.GetId(), resolved.GetPriceListId())

		// Step 3: Create a customer override -- should take precedence
		_, err = pricingBiz.SaveCustomerPriceOverride(
			ctx,
			&commercev1.CustomerPriceOverrideSaveRequest{
				CustomerId:       customerID,
				ProductVariantId: variant.GetId(),
				UnitPrice: &commonv1.Money{
					CurrencyCode: "USD",
					Units:        5,
					Nanos:        0,
				},
				ApprovedBy: "manager-user",
			},
		)
		require.NoError(t, err)

		resolved, err = pricingBiz.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
			CustomerId:       customerID,
			ProductVariantId: variant.GetId(),
			Quantity:         1,
		})
		require.NoError(t, err)
		require.Equal(t, commercev1.PriceSource_PRICE_SOURCE_CUSTOMER_OVERRIDE, resolved.GetPriceSource())
		require.Equal(t, int64(5), resolved.GetUnitPrice().GetUnits())
	})
}
