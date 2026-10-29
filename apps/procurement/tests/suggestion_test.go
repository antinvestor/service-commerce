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

package tests_test

import (
	"context"
	"fmt"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/antinvestor/service-commerce/apps/procurement/tests"
)

type SuggestionTestSuite struct {
	tests.ProcurementBaseTestSuite
}

func TestSuggestionSuite(t *testing.T) {
	suite.Run(t, new(SuggestionTestSuite))
}

// fakeMaterials returns fixed shortages for one plan in one property.
type fakeMaterials struct {
	property  string
	shortages []business.Shortage
}

func (f *fakeMaterials) PlanShortages(_ context.Context, propertyID, _ string) ([]business.Shortage, error) {
	if propertyID != f.property {
		return nil, business.ErrPlanNotInProperty
	}
	return f.shortages, nil
}

func usd(units int64, nanos int32) *commonv1.Money {
	return &commonv1.Money{CurrencyCode: "USD", Units: units, Nanos: nanos}
}

func (sts *SuggestionTestSuite) TestSuggestPurchaseOrders_PicksCheapestAndGroupsBySupplier() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		supplierRepo := repository.NewSupplierRepository(ctx, dbPool, svc.WorkManager())
		itemRepo := repository.NewSupplierItemRepository(ctx, dbPool, svc.WorkManager())
		suppliers := business.NewSupplierBusiness(ctx, supplierRepo, itemRepo)

		newSupplier := func(name string) *procurementv1.Supplier {
			s, err := suppliers.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
				Name: name, ProfileId: "p-" + util.RandomAlphaNumericString(6), Currency: "USD",
			})
			require.NoError(t, err)
			return s
		}
		addItem := func(supplierID, inventoryID string, price *commonv1.Money, moq float64, lead int32) string {
			item, err := suppliers.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
				SupplierId: supplierID, InventoryItemId: inventoryID, SupplierSku: util.RandomAlphaNumericString(6),
				UnitPrice: price, MinOrderQuantity: moq, Unit: "kg", LeadTimeDays: lead,
			})
			require.NoError(t, err)
			return item.GetId()
		}

		dairy := newSupplier("Dairy Co")
		packs := newSupplier("Pack Co")
		milkDairy := addItem(dairy.GetId(), "milk", usd(1, 200_000_000), 50, 2)
		addItem(packs.GetId(), "milk", usd(1, 500_000_000), 0, 1) // dearer
		cupsPack := addItem(packs.GetId(), "cups", usd(0, 100_000_000), 0, 3)
		// A tie on price goes to the shorter lead time.
		addItem(dairy.GetId(), "lids", usd(0, 50_000_000), 0, 9)
		lidsPack := addItem(packs.GetId(), "lids", usd(0, 50_000_000), 0, 1)

		source := &fakeMaterials{property: "prop-1", shortages: []business.Shortage{
			{InventoryItemID: "milk", ItemName: "Milk", Quantity: 20, Unit: "l"},
			{InventoryItemID: "cups", ItemName: "Cups", Quantity: 1000, Unit: "pcs"},
			{InventoryItemID: "lids", ItemName: "Lids", Quantity: 1000, Unit: "pcs"},
			{InventoryItemID: "cultures", ItemName: "Cultures", Quantity: 2, Unit: "kg"},
		}}
		biz := business.NewSuggestionBusiness(source, itemRepo)

		got, err := biz.SuggestPurchaseOrders(ctx, &procurementv1.SuggestPurchaseOrdersRequest{
			PropertyId: "prop-1", PlanId: "plan-1",
		})
		require.NoError(t, err)
		require.Len(t, got, 3, "dairy, packaging, and the unsourced remainder")

		bySupplier := map[string]*procurementv1.PurchaseOrderSuggestion{}
		for _, s := range got {
			bySupplier[s.GetSupplierId()] = s
		}

		milk := bySupplier[dairy.GetId()]
		require.Equal(t, "Dairy Co", milk.GetSupplierName())
		require.Len(t, milk.GetLines(), 1)
		require.Equal(t, milkDairy, milk.GetLines()[0].GetSupplierItemId())
		require.InDelta(t, 50, milk.GetLines()[0].GetShortageQuantity(), 0.0001, "raised to the minimum order")
		require.Equal(t, int64(60), milk.GetEstimatedTotal().GetUnits()) // 50 x 1.20

		pack := bySupplier[packs.GetId()]
		require.Len(t, pack.GetLines(), 2)
		ids := []string{pack.GetLines()[0].GetSupplierItemId(), pack.GetLines()[1].GetSupplierItemId()}
		require.ElementsMatch(t, []string{cupsPack, lidsPack}, ids)
		require.Equal(t, int64(150), pack.GetEstimatedTotal().GetUnits()) // 1000 x 0.10 + 1000 x 0.05

		unsourced := bySupplier[""]
		require.Len(t, unsourced.GetLines(), 1)
		require.Equal(t, "cultures", unsourced.GetLines()[0].GetInventoryItemId())
		require.Empty(t, unsourced.GetLines()[0].GetSupplierItemId())
	})
}

func (sts *SuggestionTestSuite) TestSuggestPurchaseOrders_Errors() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		itemRepo := repository.NewSupplierItemRepository(ctx, dbPool, svc.WorkManager())

		_, err := business.NewSuggestionBusiness(nil, itemRepo).SuggestPurchaseOrders(ctx,
			&procurementv1.SuggestPurchaseOrdersRequest{PropertyId: "prop-1", PlanId: "plan-1"})
		require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))

		biz := business.NewSuggestionBusiness(&fakeMaterials{property: "prop-1"}, itemRepo)
		_, err = biz.SuggestPurchaseOrders(ctx, &procurementv1.SuggestPurchaseOrdersRequest{PropertyId: "prop-1"})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		_, err = biz.SuggestPurchaseOrders(ctx,
			&procurementv1.SuggestPurchaseOrdersRequest{PropertyId: "prop-2", PlanId: "plan-1"})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err), "another property's plan is invisible")

		empty, err := biz.SuggestPurchaseOrders(ctx,
			&procurementv1.SuggestPurchaseOrdersRequest{PropertyId: "prop-1", PlanId: "plan-1"})
		require.NoError(t, err)
		require.Empty(t, empty, "no shortages, nothing to buy")
	})
}

// Prices are never compared across currencies: a material offered in two is
// left for the buyer unless the request names one, and a plan short of more
// materials than one run handles is refused.
func (sts *SuggestionTestSuite) TestSuggestPurchaseOrders_CurrencyAware() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		itemRepo := repository.NewSupplierItemRepository(ctx, dbPool, svc.WorkManager())
		suppliers := business.NewSupplierBusiness(ctx,
			repository.NewSupplierRepository(ctx, dbPool, svc.WorkManager()), itemRepo)

		offer := func(name string, price *commonv1.Money) string {
			s, err := suppliers.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{Name: name})
			require.NoError(t, err)
			item, err := suppliers.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
				SupplierId: s.GetId(), InventoryItemId: "milk", UnitPrice: price, Unit: "l",
			})
			require.NoError(t, err)
			return item.GetId()
		}
		usdItem := offer("Dollar Dairy", usd(5, 0))
		kesItem := offer("Shilling Dairy", &commonv1.Money{CurrencyCode: "KES", Units: 3})

		source := &fakeMaterials{property: "prop-1", shortages: []business.Shortage{
			{InventoryItemID: "milk", ItemName: "Milk", Quantity: 2, Unit: "l"},
		}}
		biz := business.NewSuggestionBusiness(source, itemRepo)
		suggest := func(currency string) []*procurementv1.PurchaseOrderSuggestion {
			got, err := biz.SuggestPurchaseOrders(ctx, &procurementv1.SuggestPurchaseOrdersRequest{
				PropertyId: "prop-1", PlanId: "plan-1", CurrencyCode: currency,
			})
			require.NoError(t, err)
			require.Len(t, got, 1)
			return got
		}

		mixed := suggest("")
		require.Empty(t, mixed[0].GetSupplierId(), "3 KES is not cheaper than 5 USD; the buyer chooses")
		require.Equal(t, usdItem, suggest("USD")[0].GetLines()[0].GetSupplierItemId())
		kes := suggest("kes")[0]
		require.Equal(t, kesItem, kes.GetLines()[0].GetSupplierItemId())
		require.Equal(t, "KES", kes.GetEstimatedTotal().GetCurrencyCode())
		require.Equal(t, int64(6), kes.GetEstimatedTotal().GetUnits())

		many := make([]business.Shortage, 501)
		for i := range many {
			many[i] = business.Shortage{InventoryItemID: fmt.Sprintf("m-%d", i), Quantity: 1}
		}
		_, err := business.NewSuggestionBusiness(&fakeMaterials{property: "prop-1", shortages: many}, itemRepo).
			SuggestPurchaseOrders(ctx, &procurementv1.SuggestPurchaseOrdersRequest{PropertyId: "prop-1", PlanId: "p"})
		require.Equal(t, connect.CodeResourceExhausted, connect.CodeOf(err))
	})
}
