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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/antinvestor/service-commerce/apps/procurement/tests"
)

type SupplierTestSuite struct {
	tests.ProcurementBaseTestSuite
}

func TestSupplierSuite(t *testing.T) {
	suite.Run(t, new(SupplierTestSuite))
}

func (sts *SupplierTestSuite) getBusiness(ctx context.Context, svc *frame.Service) business.SupplierBusiness {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)

	return business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
}

func (sts *SupplierTestSuite) createTestSupplier(
	ctx context.Context,
	biz business.SupplierBusiness,
) *procurementv1.Supplier {
	t := sts.T()
	supplier, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name:      "Test Supplier " + util.RandomAlphaNumericString(6),
		ProfileId: "profile-" + util.RandomAlphaNumericString(6),
		Currency:  "USD",
	})
	require.NoError(t, err)
	return supplier
}

func (sts *SupplierTestSuite) TestCreateSupplier() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		biz := sts.getBusiness(ctx, svc)

		supplier, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
			Name:             "Acme Supplies",
			ProfileId:        "profile-123",
			SupplierType:     procurementv1.SupplierType_SUPPLIER_TYPE_RAW_MATERIAL,
			Currency:         "USD",
			PaymentTermsDays: 30,
			LeadTimeDays:     7,
			Notes:            "Primary supplier",
		})
		require.NoError(t, err)
		require.NotEmpty(t, supplier.GetId())
		require.Equal(t, "Acme Supplies", supplier.GetName())
		require.Equal(t, procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE, supplier.GetStatus())
		require.Equal(t, procurementv1.SupplierRating_SUPPLIER_RATING_UNRATED, supplier.GetRating())
		require.Equal(t, int32(30), supplier.GetPaymentTermsDays())
	})
}

func (sts *SupplierTestSuite) TestUpdateSupplier() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		biz := sts.getBusiness(ctx, svc)

		supplier := sts.createTestSupplier(ctx, biz)

		updated, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
			Id:               supplier.GetId(),
			Name:             "Updated Supplier Name",
			ProfileId:        supplier.GetProfileId(),
			Currency:         "EUR",
			PaymentTermsDays: 45,
			Rating:           procurementv1.SupplierRating_SUPPLIER_RATING_PREFERRED,
		})
		require.NoError(t, err)
		require.Equal(t, supplier.GetId(), updated.GetId())
		require.Equal(t, "Updated Supplier Name", updated.GetName())
		require.Equal(t, "EUR", updated.GetCurrency())
		require.Equal(t, int32(45), updated.GetPaymentTermsDays())
		require.Equal(t, procurementv1.SupplierRating_SUPPLIER_RATING_PREFERRED, updated.GetRating())
	})
}

func (sts *SupplierTestSuite) TestCreateSupplierItem() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		biz := sts.getBusiness(ctx, svc)

		supplier := sts.createTestSupplier(ctx, biz)

		item, err := biz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
			SupplierId:      supplier.GetId(),
			InventoryItemId: "inv-item-001",
			SupplierSku:     "SUP-SKU-001",
			UnitPrice: &commonv1.Money{
				CurrencyCode: "USD",
				Units:        15,
				Nanos:        500000000, // $15.50
			},
			MinOrderQuantity: 10,
			Unit:             "kg",
			LeadTimeDays:     5,
		})
		require.NoError(t, err)
		require.NotEmpty(t, item.GetId())
		require.Equal(t, supplier.GetId(), item.GetSupplierId())
		require.Equal(t, "inv-item-001", item.GetInventoryItemId())
		require.Equal(t, "SUP-SKU-001", item.GetSupplierSku())
		require.Equal(t, int64(15), item.GetUnitPrice().GetUnits())
		require.Equal(t, int32(500000000), item.GetUnitPrice().GetNanos())
		require.InDelta(t, 10, item.GetMinOrderQuantity(), 0.001)
		require.Equal(t, procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE, item.GetStatus())
	})
}

func (sts *SupplierTestSuite) TestSearchSupplierItems() {
	t := sts.T()

	sts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := sts.CreateService(t, dep)
		biz := sts.getBusiness(ctx, svc)

		supplier := sts.createTestSupplier(ctx, biz)

		for i := range 3 {
			_, err := biz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
				SupplierId:      supplier.GetId(),
				InventoryItemId: "inv-item-" + util.RandomAlphaNumericString(6),
				SupplierSku:     "SKU-" + util.RandomAlphaNumericString(6),
				UnitPrice: &commonv1.Money{
					CurrencyCode: "USD",
					Units:        int64(10 + i),
				},
				Unit: "kg",
			})
			require.NoError(t, err)
		}

		items, err := biz.SearchSupplierItems(ctx, &procurementv1.SupplierItemSearchRequest{
			SupplierId: supplier.GetId(),
		})
		require.NoError(t, err)
		require.Len(t, items, 3)
	})
}
