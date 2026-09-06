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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
)

// Receiving is atomic and cannot overshoot the order, even when the same
// line is listed twice in one receipt or received across two receipts.
func (gts *GoodsReceiptTestSuite) TestReceipt_DuplicateLinesAndPartialCancelGuard() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		po := gts.createPOWithLines(ctx, biz, 10)
		lineID := po.GetLines()[0].GetId()

		// 6 + 6 on a line of 10 fails as a whole and writes nothing.
		_, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			Lines: []*procurementv1.GoodsReceiptLineInput{
				{PurchaseOrderLineId: lineID, ReceivedQuantity: 6},
				{PurchaseOrderLineId: lineID, ReceivedQuantity: 6},
			},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		receipts, err := biz.grBiz.SearchGoodsReceipts(ctx, &procurementv1.GoodsReceiptSearchRequest{
			PurchaseOrderId: po.GetId(),
		})
		require.NoError(t, err)
		require.Empty(t, receipts)

		untouched, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.InDelta(t, 0, untouched.GetLines()[0].GetReceivedQuantity(), 0.001)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED, untouched.GetStatus())

		// Partial receipt, then cancellation is refused.
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			Lines:           []*procurementv1.GoodsReceiptLineInput{{PurchaseOrderLineId: lineID, ReceivedQuantity: 4}},
		})
		require.NoError(t, err)

		_, err = biz.poBiz.CancelPurchaseOrder(ctx, &procurementv1.PurchaseOrderCancelRequest{Id: po.GetId()})
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// Idempotent receipt replay returns the original receipt without re-receiving.
		key := "gr-" + util.RandomAlphaNumericString(6)
		first, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			IdempotencyKey:  key,
			Lines:           []*procurementv1.GoodsReceiptLineInput{{PurchaseOrderLineId: lineID, ReceivedQuantity: 6}},
		})
		require.NoError(t, err)
		again, err := biz.grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			IdempotencyKey:  key,
			Lines:           []*procurementv1.GoodsReceiptLineInput{{PurchaseOrderLineId: lineID, ReceivedQuantity: 6}},
		})
		require.NoError(t, err)
		require.Equal(t, first.GetId(), again.GetId())

		done, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED, done.GetStatus())
		require.InDelta(t, 10, done.GetLines()[0].GetReceivedQuantity(), 0.001)
	})
}

// A purchase order only accepts active items from its own supplier, priced
// in one currency, and honours fractional quantities.
func (pts *PurchaseOrderTestSuite) TestCreatePurchaseOrder_LineValidation() {
	t := pts.T()

	pts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := pts.CreateService(t, dep)
		biz := pts.getBusiness(ctx, svc)

		supplierA, itemA := pts.createSupplierWithItem(ctx, biz)
		_, itemB := pts.createSupplierWithItem(ctx, biz)

		_, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001",
			SupplierId: supplierA.GetId(),
			Lines:      []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: itemB.GetId(), OrderedQuantity: 1}},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		kesItem, err := biz.supplierBiz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
			SupplierId:      supplierA.GetId(),
			InventoryItemId: "inv-" + util.RandomAlphaNumericString(6),
			SupplierSku:     "SKU-" + util.RandomAlphaNumericString(6),
			UnitPrice:       &commonv1.Money{CurrencyCode: "KES", Units: 500},
			Unit:            "kg",
		})
		require.NoError(t, err)

		_, err = biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001",
			SupplierId: supplierA.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{
				{SupplierItemId: itemA.GetId(), OrderedQuantity: 1},
				{SupplierItemId: kesItem.GetId(), OrderedQuantity: 1},
			},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		// 2.5 units at the item price is not truncated to 2.
		po, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001",
			SupplierId: supplierA.GetId(),
			Lines:      []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: itemA.GetId(), OrderedQuantity: 2.5}},
		})
		require.NoError(t, err)
		unit := itemA.GetUnitPrice()
		unitNanos := unit.GetUnits()*1_000_000_000 + int64(unit.GetNanos())
		wantNanos := int64(float64(unitNanos) * 2.5)
		gotNanos := po.GetTotalAmount().GetUnits()*1_000_000_000 + int64(po.GetTotalAmount().GetNanos())
		require.Equal(t, wantNanos, gotNanos)
		require.NotEmpty(t, po.GetOrderNumber())
	})
}
