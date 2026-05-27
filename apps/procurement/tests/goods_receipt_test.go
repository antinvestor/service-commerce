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

package tests

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
)

type GoodsReceiptTestSuite struct {
	ProcurementBaseTestSuite
}

func TestGoodsReceiptSuite(t *testing.T) {
	suite.Run(t, new(GoodsReceiptTestSuite))
}

type allGRBiz struct {
	supplierBiz business.SupplierBusiness
	poBiz       business.PurchaseOrderBusiness
	grBiz       business.GoodsReceiptBusiness
}

func (gts *GoodsReceiptTestSuite) getBusiness(ctx context.Context, svc *frame.Service) allGRBiz {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	workMan := svc.WorkManager()

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)
	grRepo := repository.NewGoodsReceiptRepository(ctx, dbPool, workMan)
	grlRepo := repository.NewGoodsReceiptLineRepository(ctx, dbPool, workMan)

	return allGRBiz{
		supplierBiz: business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo),
		poBiz:       business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo),
		grBiz:       business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo),
	}
}

func (gts *GoodsReceiptTestSuite) createPOWithLines(
	ctx context.Context,
	biz allGRBiz,
	orderedQty float64,
) *procurementv1.PurchaseOrder {
	t := gts.T()

	supplier, err := biz.supplierBiz.SaveSupplier(ctx, &procurementv1.SaveSupplierRequest{
		Name:     "GR Test Supplier " + util.RandomAlphaNumericString(6),
		Currency: "USD",
	})
	require.NoError(t, err)

	item, err := biz.supplierBiz.SaveSupplierItem(ctx, &procurementv1.SaveSupplierItemRequest{
		SupplierId:      supplier.GetId(),
		InventoryItemId: "inv-" + util.RandomAlphaNumericString(6),
		SupplierSku:     "SKU-" + util.RandomAlphaNumericString(6),
		Price: &commonv1.Money{
			CurrencyCode: "USD",
			Units:        10,
		},
		Unit: "kg",
	})
	require.NoError(t, err)

	po, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.CreatePurchaseOrderRequest{
		PropertyId: "property-001",
		SupplierId: supplier.GetId(),
		Lines: []*procurementv1.CreatePurchaseOrderLine{
			{
				SupplierItemId:  item.GetId(),
				OrderedQuantity: orderedQty,
			},
		},
	})
	require.NoError(t, err)

	// Submit the PO so it can receive goods
	submitted, err := biz.poBiz.SubmitPurchaseOrder(ctx, &procurementv1.SubmitPurchaseOrderRequest{
		Id: po.GetId(),
	})
	require.NoError(t, err)

	return submitted
}

func (gts *GoodsReceiptTestSuite) TestCreateGoodsReceipt() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)

		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		po := gts.createPOWithLines(ctx, biz, 20)
		poLineID := po.GetLines()[0].GetId()

		gr, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.CreateGoodsReceiptRequest{
			PurchaseOrderId: po.GetId(),
			Notes:           "Partial delivery",
			Lines: []*procurementv1.CreateGoodsReceiptLine{
				{
					PurchaseOrderLineId: poLineID,
					ReceivedQuantity:    10,
					AcceptedQuantity:    10,
				},
			},
		})
		require.NoError(t, err)
		require.NotEmpty(t, gr.GetId())
		require.Len(t, gr.GetLines(), 1)
		require.Equal(t, float64(10), gr.GetLines()[0].GetReceivedQuantity())
		require.Equal(t, float64(10), gr.GetLines()[0].GetAcceptedQuantity())
		require.NotNil(t, gr.GetReceivedAt())

		// PO should be partially received
		updatedPO, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED, updatedPO.GetStatus())
	})
}

func (gts *GoodsReceiptTestSuite) TestFullReceive() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)

		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		po := gts.createPOWithLines(ctx, biz, 10)
		poLineID := po.GetLines()[0].GetId()

		// Receive all items
		_, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.CreateGoodsReceiptRequest{
			PurchaseOrderId: po.GetId(),
			Lines: []*procurementv1.CreateGoodsReceiptLine{
				{
					PurchaseOrderLineId: poLineID,
					ReceivedQuantity:    10,
					AcceptedQuantity:    10,
				},
			},
		})
		require.NoError(t, err)

		// PO should be fully received
		updatedPO, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED, updatedPO.GetStatus())

		// PO line should be received
		require.Equal(t, procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_RECEIVED, updatedPO.GetLines()[0].GetStatus())
	})
}

func (gts *GoodsReceiptTestSuite) TestOverReceiveBlocked() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)

		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		po := gts.createPOWithLines(ctx, biz, 10)
		poLineID := po.GetLines()[0].GetId()

		// Receive 7 items
		_, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.CreateGoodsReceiptRequest{
			PurchaseOrderId: po.GetId(),
			Lines: []*procurementv1.CreateGoodsReceiptLine{
				{
					PurchaseOrderLineId: poLineID,
					ReceivedQuantity:    7,
					AcceptedQuantity:    7,
				},
			},
		})
		require.NoError(t, err)

		// Try to receive 5 more (only 3 remaining) - should fail
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.CreateGoodsReceiptRequest{
			PurchaseOrderId: po.GetId(),
			Lines: []*procurementv1.CreateGoodsReceiptLine{
				{
					PurchaseOrderLineId: poLineID,
					ReceivedQuantity:    5,
				},
			},
		})
		require.Error(t, err)

		// Receive exactly remaining 3 - should succeed
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.CreateGoodsReceiptRequest{
			PurchaseOrderId: po.GetId(),
			Lines: []*procurementv1.CreateGoodsReceiptLine{
				{
					PurchaseOrderLineId: poLineID,
					ReceivedQuantity:    3,
					AcceptedQuantity:    3,
				},
			},
		})
		require.NoError(t, err)

		// PO should now be fully received
		updatedPO, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED, updatedPO.GetStatus())
	})
}
