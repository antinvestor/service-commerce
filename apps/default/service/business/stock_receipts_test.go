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

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/pkg/dbrole"
)

// A procurement receipt line raises a variant's stock once, however often it
// is delivered, and only within the tenancy it was recorded in.
func (bts *BusinessTestSuite) TestReceiveStock_OncePerReferenceWithinTenant() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		seller := bts.WithAuthClaims(ctx, "tenant-a", "partition-a", "seller-1")
		shop := bts.createTestShop(seller, biz)
		_, variant := bts.createTestProductWithVariant(seller, biz, shop.GetId())
		require.Equal(t, int64(100), bts.stockOf(seller, biz, variant))

		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		receipts := business.NewStockReceiptBusiness(
			repository.NewProductVariantRepository(ctx, dbPool, svc.WorkManager()),
			repository.NewStockReceiptRepository(dbPool),
		)
		procurement := (&security.AuthenticationClaims{
			TenantID: "platform", PartitionID: "platform",
			Roles: []string{security.ConstantSystemInternalRole},
		}).ClaimsToContext(ctx)
		procurement = dbrole.AcrossTenants(procurement, "test")

		receiveIn := func(variantID, tenantID, partitionID, reference string, quantity int64) (*commercev1.ReceiveStockResponse, error) {
			return receipts.ReceiveStock(procurement, &commercev1.ReceiveStockRequest{
				VariantId: variantID, TenantId: tenantID, PartitionId: partitionID,
				Reference: reference, Quantity: quantity,
			})
		}
		receive := func(variantID, tenantID, reference string, quantity int64) (*commercev1.ReceiveStockResponse, error) {
			return receiveIn(variantID, tenantID, "partition-a", reference, quantity)
		}

		first, err := receive(variant.GetId(), "tenant-a", "procurement:grl:line-1", 12)
		require.NoError(t, err)
		require.Equal(t, int64(112), first.GetStockQuantity())
		require.False(t, first.GetReplayed())

		// The retry after a lost answer adds nothing.
		again, err := receive(variant.GetId(), "tenant-a", "procurement:grl:line-1", 12)
		require.NoError(t, err)
		require.True(t, again.GetReplayed())
		require.Equal(t, int64(112), again.GetStockQuantity())
		require.Equal(t, int64(112), bts.stockOf(seller, biz, variant))

		// The same reference for another quantity is refused, not added.
		_, err = receive(variant.GetId(), "tenant-a", "procurement:grl:line-1", 5)
		require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(err))

		// Another tenant's receipt cannot reach this variant.
		_, err = receive(variant.GetId(), "tenant-b", "procurement:grl:line-2", 3)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		// Nor can a receipt from another partition of the same tenant.
		_, err = receiveIn(variant.GetId(), "tenant-a", "partition-b", "procurement:grl:line-5", 3)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		_, err = receive(variant.GetId(), "tenant-a", "procurement:grl:line-3", 0)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		next, err := receive(variant.GetId(), "tenant-a", "procurement:grl:line-4", 3)
		require.NoError(t, err)
		require.Equal(t, int64(115), next.GetStockQuantity())
		require.Equal(t, int64(115), bts.stockOf(seller, biz, variant))
	})
}
