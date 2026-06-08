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

type PurchaseOrderTestSuite struct {
	tests.ProcurementBaseTestSuite
}

func TestPurchaseOrderSuite(t *testing.T) {
	suite.Run(t, new(PurchaseOrderTestSuite))
}

type allPOBiz struct {
	supplierBiz business.SupplierBusiness
	poBiz       business.PurchaseOrderBusiness
}

func (pts *PurchaseOrderTestSuite) getBusiness(ctx context.Context, svc *frame.Service) allPOBiz {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)

	return allPOBiz{
		supplierBiz: business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo),
		poBiz:       business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo),
	}
}

func (pts *PurchaseOrderTestSuite) createSupplierWithItem(
	ctx context.Context,
	biz allPOBiz,
) (*procurementv1.Supplier, *procurementv1.SupplierItem) {
	t := pts.T()

	supplier, err := biz.supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name:     "PO Test Supplier " + util.RandomAlphaNumericString(6),
		Currency: "USD",
	})
	require.NoError(t, err)

	item, err := biz.supplierBiz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId:      supplier.GetId(),
		InventoryItemId: "inv-" + util.RandomAlphaNumericString(6),
		SupplierSku:     "SKU-" + util.RandomAlphaNumericString(6),
		UnitPrice: &commonv1.Money{
			CurrencyCode: "USD",
			Units:        25,
			Nanos:        0,
		},
		Unit: "kg",
	})
	require.NoError(t, err)

	return supplier, item
}

func (pts *PurchaseOrderTestSuite) TestCreatePurchaseOrder() {
	t := pts.T()

	pts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := pts.CreateService(t, dep)
		biz := pts.getBusiness(ctx, svc)

		supplier, supplierItem := pts.createSupplierWithItem(ctx, biz)

		po, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001",
			SupplierId: supplier.GetId(),
			Notes:      "Test purchase order",
			Lines: []*procurementv1.PurchaseOrderLineInput{
				{
					SupplierItemId:  supplierItem.GetId(),
					OrderedQuantity: 10,
				},
			},
		})
		require.NoError(t, err)
		require.NotEmpty(t, po.GetId())
		require.NotEmpty(t, po.GetOrderNumber())
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT, po.GetStatus())
		require.Len(t, po.GetLines(), 1)
		require.InDelta(t, 10, po.GetLines()[0].GetOrderedQuantity(), 0.001)
		// Total should be 10 * $25 = $250
		require.Equal(t, int64(250), po.GetTotalAmount().GetUnits())
		require.Equal(t, int32(0), po.GetTotalAmount().GetNanos())
	})
}

func (pts *PurchaseOrderTestSuite) TestIdempotentCreate() {
	t := pts.T()

	pts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := pts.CreateService(t, dep)
		biz := pts.getBusiness(ctx, svc)

		supplier, supplierItem := pts.createSupplierWithItem(ctx, biz)

		idemKey := "po-idem-" + util.RandomAlphaNumericString(10)
		req := &procurementv1.PurchaseOrderCreateRequest{
			PropertyId:     "property-001",
			SupplierId:     supplier.GetId(),
			IdempotencyKey: idemKey,
			Lines: []*procurementv1.PurchaseOrderLineInput{
				{
					SupplierItemId:  supplierItem.GetId(),
					OrderedQuantity: 5,
				},
			},
		}

		po1, err := biz.poBiz.CreatePurchaseOrder(ctx, req)
		require.NoError(t, err)

		po2, err := biz.poBiz.CreatePurchaseOrder(ctx, req)
		require.NoError(t, err)
		require.Equal(t, po1.GetId(), po2.GetId())
	})
}

func (pts *PurchaseOrderTestSuite) TestSubmitAndCancel() {
	t := pts.T()

	pts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := pts.CreateService(t, dep)
		biz := pts.getBusiness(ctx, svc)

		supplier, supplierItem := pts.createSupplierWithItem(ctx, biz)

		// Add auth claims for submit
		ctx = pts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-submitter")

		po, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001",
			SupplierId: supplier.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{
				{
					SupplierItemId:  supplierItem.GetId(),
					OrderedQuantity: 10,
				},
			},
		})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT, po.GetStatus())

		// Submit the PO
		submitted, err := biz.poBiz.SubmitPurchaseOrder(ctx, &procurementv1.PurchaseOrderSubmitRequest{
			Id: po.GetId(),
		})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED, submitted.GetStatus())
		require.NotNil(t, submitted.GetSubmittedAt())
		require.Equal(t, "profile-submitter", submitted.GetSubmittedBy())

		// Cannot submit again
		_, err = biz.poBiz.SubmitPurchaseOrder(ctx, &procurementv1.PurchaseOrderSubmitRequest{
			Id: po.GetId(),
		})
		require.Error(t, err)

		// Cancel the PO
		cancelled, err := biz.poBiz.CancelPurchaseOrder(ctx, &procurementv1.PurchaseOrderCancelRequest{
			Id: po.GetId(),
		})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED, cancelled.GetStatus())

		// Verify lines are cancelled
		for _, line := range cancelled.GetLines() {
			require.Equal(
				t,
				procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED,
				line.GetStatus(),
			)
		}
	})
}
