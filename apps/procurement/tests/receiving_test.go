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
	"errors"
	"fmt"
	"strings"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
)

// fakeStock stands in for commerce: it adds a reference's quantity once.
// failNext errors are returned before anything is applied; loseNext calls
// apply and then fail, as when commerce's answer is lost.
type fakeStock struct {
	stock    map[string]int64
	received map[string]int64
	tenants  []string
	calls    int
	failNext []error
	loseNext int
}

func newFakeStock() *fakeStock {
	return &fakeStock{stock: map[string]int64{}, received: map[string]int64{}}
}

func (f *fakeStock) ReceiveVariantStock(_ context.Context, tenantID, variantID string, qty int64, ref string) error {
	f.calls++
	if len(f.failNext) > 0 {
		err := f.failNext[0]
		f.failNext = f.failNext[1:]
		return err
	}
	f.tenants = append(f.tenants, tenantID)
	if _, ok := f.received[ref]; !ok {
		f.received[ref] = qty
		f.stock[variantID] += qty
	}
	if f.loseNext > 0 {
		f.loseNext--
		return errors.New("connection reset by peer")
	}
	return nil
}

// fakeInventory stands in for manufacturing inventory: it books a
// reference once. failNext errors are returned before anything is booked;
// loseNext calls book and then fail, as when manufacturing's answer is lost.
type fakeInventory struct {
	booked   map[string]business.MaterialReceipt
	onHand   map[string]float64
	calls    int
	failNext []error
	loseNext int
}

func newFakeInventory() *fakeInventory {
	return &fakeInventory{booked: map[string]business.MaterialReceipt{}, onHand: map[string]float64{}}
}

func (f *fakeInventory) ReceiveMaterial(_ context.Context, receipt business.MaterialReceipt) error {
	f.calls++
	if len(f.failNext) > 0 {
		err := f.failNext[0]
		f.failNext = f.failNext[1:]
		return err
	}
	if _, ok := f.booked[receipt.Reference]; !ok {
		f.booked[receipt.Reference] = receipt
		f.onHand[receipt.ItemID+"@"+receipt.LocationID] += receipt.Quantity
	}
	if f.loseNext > 0 {
		f.loseNext--
		return errors.New("connection reset by peer")
	}
	return nil
}

func usdPrice(units int64) *commonv1.Money { return &commonv1.Money{CurrencyCode: "USD", Units: units} }

// supplierWith creates an active supplier and one item for it.
func (gts *GoodsReceiptTestSuite) supplierWith(
	ctx context.Context,
	biz allGRBiz,
	item *procurementv1.SupplierItemSaveRequest,
) (*procurementv1.Supplier, *procurementv1.SupplierItem) {
	t := gts.T()
	supplier, err := biz.supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Supplier " + util.RandomAlphaNumericString(6), Currency: "USD",
	})
	require.NoError(t, err)
	item.SupplierId = supplier.GetId()
	if item.GetUnitPrice() == nil {
		item.UnitPrice = usdPrice(10)
	}
	saved, err := biz.supplierBiz.SaveSupplierItem(ctx, item)
	require.NoError(t, err)
	return supplier, saved
}

// submittedPO orders quantity of item and submits the order.
func (gts *GoodsReceiptTestSuite) submittedPO(
	ctx context.Context,
	biz allGRBiz,
	supplierID, itemID string,
	quantity float64,
) *procurementv1.PurchaseOrder {
	t := gts.T()
	po, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		PropertyId: "property-001",
		SupplierId: supplierID,
		Lines:      []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: itemID, OrderedQuantity: quantity}},
	})
	require.NoError(t, err)
	submitted, err := biz.poBiz.SubmitPurchaseOrder(ctx, &procurementv1.PurchaseOrderSubmitRequest{Id: po.GetId()})
	require.NoError(t, err)
	return submitted
}

func receive(lineID string, quantity float64) *procurementv1.GoodsReceiptCreateRequest {
	return &procurementv1.GoodsReceiptCreateRequest{
		Lines: []*procurementv1.GoodsReceiptLineInput{{PurchaseOrderLineId: lineID, ReceivedQuantity: quantity}},
	}
}

func receiveOn(po *procurementv1.PurchaseOrder, quantity float64) *procurementv1.GoodsReceiptCreateRequest {
	req := receive(po.GetLines()[0].GetId(), quantity)
	req.PurchaseOrderId = po.GetId()
	return req
}

// Resale goods raise the commerce variant's stock exactly once: a failed
// push stays pending and is retried by the sweep, and a push whose answer is
// lost is resent with the same reference, which commerce counts once.
func (gts *GoodsReceiptTestSuite) TestReceipt_ResaleStockReachesCommerceOnce() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		supplier, item := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			SupplyKind: procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, ProductVariantId: "variant-1",
		})
		require.Equal(t, procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, item.GetSupplyKind())
		po := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 10)
		require.Equal(t, "variant-1", po.GetLines()[0].GetProductVariantId())

		// Commerce is down when the receipt is recorded: the receipt stands.
		biz.stock.failNext = []error{connect.NewError(connect.CodeUnavailable, "down")}
		gr, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 4))
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING,
			gr.GetLines()[0].GetDeliveryStatus())
		require.Zero(t, biz.stock.stock["variant-1"])

		// The sweep delivers it; its answer is lost, so it stays pending.
		biz.stock.loseNext = 1
		summary, err := biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{Pending: 1}, summary)
		require.Equal(t, int64(4), biz.stock.stock["variant-1"])

		// The next sweep resends the same reference: counted once.
		summary, err = biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{Delivered: 1}, summary)
		require.Equal(t, int64(4), biz.stock.stock["variant-1"])
		require.Equal(t, []string{"tenant-1", "tenant-1"}, biz.stock.tenants)

		got, err := biz.grBiz.GetGoodsReceipt(ctx, gr.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			got.GetLines()[0].GetDeliveryStatus())

		// Nothing is left to deliver; a sweep is a no-op.
		calls := biz.stock.calls
		summary, err = biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{}, summary)
		require.Equal(t, calls, biz.stock.calls)

		// A receipt pushed straight away is delivered in the same call.
		next, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 6))
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			next.GetLines()[0].GetDeliveryStatus())
		require.Equal(t, int64(10), biz.stock.stock["variant-1"])

		// Variants are bought and received in whole units.
		_, err = biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001", SupplierId: supplier.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: item.GetId(), OrderedQuantity: 1.5}},
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		half := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 2)
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(half, 0.5))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		// A refusal (say the variant is gone) is final and left for staff.
		biz.stock.failNext = []error{fmt.Errorf("%w: variant not found", business.ErrDeliveryRefused)}
		refused, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(half, 1))
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED,
			refused.GetLines()[0].GetDeliveryStatus())
		require.Contains(t, refused.GetLines()[0].GetDeliveryNote(), "variant not found")
		summary, err = biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{}, summary)
	})
}

// Raw materials received into a stock location are booked into
// manufacturing inventory once, in the receipt's tenancy and property, and
// never sent to commerce. Received without a location, they wait until staff
// choose one.
func (gts *GoodsReceiptTestSuite) TestReceipt_RawMaterialReachesManufacturingOnce() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		supplier, item := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			InventoryItemId: "flour", Unit: "kg",
		})
		require.Equal(t, procurementv1.SupplyKind_SUPPLY_KIND_MATERIAL, item.GetSupplyKind())
		po := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 20)

		// Manufacturing's answer is lost: the line stays pending, and the
		// sweep's resend under the same reference is booked once.
		biz.materials.loseNext = 1
		req := receiveOn(po, 12.5)
		req.StockLocationId = "store-1"
		req.Lines[0].LotNumber = "LOT-7"
		gr, err := biz.grBiz.CreateGoodsReceipt(ctx, req)
		require.NoError(t, err)
		require.Equal(t, "store-1", gr.GetStockLocationId())
		line := gr.GetLines()[0]
		require.Equal(t, "store-1", line.GetLocationId())
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING, line.GetDeliveryStatus())

		summary, err := biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{Delivered: 1}, summary)
		require.InDelta(t, 12.5, biz.materials.onHand["flour@store-1"], 0.000001)
		require.Equal(t, 2, biz.materials.calls)
		require.Len(t, biz.materials.booked, 1)
		for _, booked := range biz.materials.booked {
			require.Equal(t, "tenant-1", booked.TenantID)
			require.Equal(t, "partition-1", booked.PartitionID)
			require.Equal(t, "property-001", booked.PropertyID)
			require.Equal(t, "LOT-7", booked.LotNumber)
			require.Equal(t, gr.GetId(), booked.ReceiptID)
		}
		require.Zero(t, biz.stock.calls, "raw materials never go to commerce")

		// Received without a location, the line waits for staff.
		waiting, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 2.5))
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING_TRANSFER,
			waiting.GetLines()[0].GetDeliveryStatus())
		summary, err = biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{}, summary)

		// Staff choose a location; it is booked straight away.
		retry := func(location string) (*procurementv1.GoodsReceipt, error) {
			return biz.grBiz.ResolveLine(ctx, &procurementv1.GoodsReceiptLineResolveRequest{
				GoodsReceiptId: waiting.GetId(), LineId: waiting.GetLines()[0].GetId(),
				Resolution: procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
				LocationId: location,
			})
		}
		_, err = retry("")
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		sent, err := retry("store-2")
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			sent.GetLines()[0].GetDeliveryStatus())
		require.Equal(t, "store-2", sent.GetLines()[0].GetLocationId())
		require.InDelta(t, 2.5, biz.materials.onHand["flour@store-2"], 0.000001)

		// A location manufacturing refuses is left for staff, who may send
		// it elsewhere.
		biz.materials.failNext = []error{fmt.Errorf("%w: location not found", business.ErrDeliveryRefused)}
		bad := receiveOn(po, 5)
		bad.StockLocationId = "gone"
		refused, err := biz.grBiz.CreateGoodsReceipt(ctx, bad)
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED,
			refused.GetLines()[0].GetDeliveryStatus())
		moved, err := biz.grBiz.ResolveLine(ctx, &procurementv1.GoodsReceiptLineResolveRequest{
			GoodsReceiptId: refused.GetId(), LineId: refused.GetLines()[0].GetId(),
			Resolution: procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
			LocationId: "store-1",
		})
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			moved.GetLines()[0].GetDeliveryStatus())
		require.InDelta(t, 17.5, biz.materials.onHand["flour@store-1"], 0.000001)
	})
}

// Staff settle lines that need a person: a raw material booked by hand is
// marked resolved with who, when and why; a refused variant line is retried
// once straight away and, if it fails again, booked by hand. Lines that do
// not need a person cannot be resolved.
func (gts *GoodsReceiptTestSuite) TestReceipt_StaffResolveLines() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-storekeeper")

		resolve := func(gr *procurementv1.GoodsReceipt, resolution procurementv1.GoodsReceiptLineResolution,
			note string) (*procurementv1.GoodsReceipt, error) {
			return biz.grBiz.ResolveLine(ctx, &procurementv1.GoodsReceiptLineResolveRequest{
				GoodsReceiptId: gr.GetId(), LineId: gr.GetLines()[0].GetId(), Resolution: resolution, Note: note,
			})
		}
		booked := procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY
		retry := procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_RETRY

		// A raw material awaiting transfer is booked by hand.
		matSupplier, material := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			InventoryItemId: "flour", Unit: "kg",
		})
		matPO := gts.submittedPO(ctx, biz, matSupplier.GetId(), material.GetId(), 5)
		matGR, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(matPO, 5))
		require.NoError(t, err)

		_, err = resolve(matGR, retry, "")
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "a raw material needs a location")
		_, err = resolve(matGR, procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_UNSPECIFIED, "")
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		_, err = resolve(matGR, booked, strings.Repeat("x", 1001))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		_, err = biz.grBiz.ResolveLine(ctx, &procurementv1.GoodsReceiptLineResolveRequest{
			GoodsReceiptId: matGR.GetId(), LineId: "missing-line", Resolution: booked,
		})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		resolved, err := resolve(matGR, booked, "booked into store 1, GRN 42")
		require.NoError(t, err)
		line := resolved.GetLines()[0]
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_RESOLVED, line.GetDeliveryStatus())
		require.Equal(t, "profile-storekeeper", line.GetResolvedBy())
		require.Equal(t, "booked into store 1, GRN 42", line.GetResolutionNote())
		require.NotNil(t, line.GetResolvedAt())

		// Once resolved it needs nothing more.
		_, err = resolve(matGR, booked, "again")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// A variant line refused by commerce is retried once now.
		varSupplier, variant := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			SupplyKind: procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, ProductVariantId: "variant-9",
		})
		varPO := gts.submittedPO(ctx, biz, varSupplier.GetId(), variant.GetId(), 3)
		biz.stock.failNext = []error{fmt.Errorf("%w: variant not found", business.ErrDeliveryRefused)}
		varGR, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(varPO, 3))
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_FAILED,
			varGR.GetLines()[0].GetDeliveryStatus())

		retried, err := resolve(varGR, retry, "variant restored")
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_DELIVERED,
			retried.GetLines()[0].GetDeliveryStatus())
		require.Equal(t, int64(3), biz.stock.stock["variant-9"])

		// A delivered line needs nothing: neither retried nor booked.
		_, err = resolve(varGR, retry, "")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
		_, err = resolve(varGR, booked, "")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// A retry that fails for now stays pending for the sweep; refused
		// again, staff book it by hand.
		biz.stock.failNext = []error{fmt.Errorf("%w: variant not found", business.ErrDeliveryRefused)}
		againGR, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(gts.submittedPO(ctx, biz,
			varSupplier.GetId(), variant.GetId(), 2), 2))
		require.NoError(t, err)
		biz.stock.failNext = []error{connect.NewError(connect.CodeUnavailable, "down")}
		pending, err := resolve(againGR, retry, "")
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_PENDING,
			pending.GetLines()[0].GetDeliveryStatus())
		biz.stock.failNext = []error{fmt.Errorf("%w: variant not found", business.ErrDeliveryRefused)}
		summary, err := biz.grBiz.DeliverPending(ctx, 10)
		require.NoError(t, err)
		require.Equal(t, business.DeliverySummary{Failed: 1}, summary)
		bookedLine, err := resolve(againGR, booked, "counted into the shop by hand")
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_RESOLVED,
			bookedLine.GetLines()[0].GetDeliveryStatus())
	})
}

// Goods are received only against submitted, confirmed or partially
// received orders; a partially received order can be closed short, after
// which nothing more is received and it cannot be cancelled.
func (gts *GoodsReceiptTestSuite) TestReceipt_OrderStateAndCloseShort() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		supplier, item := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{InventoryItemId: "sugar"})

		draft, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001", SupplierId: supplier.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: item.GetId(), OrderedQuantity: 5}},
		})
		require.NoError(t, err)
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(draft, 1))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "draft")

		cancelled := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 5)
		_, err = biz.poBiz.CancelPurchaseOrder(ctx, &procurementv1.PurchaseOrderCancelRequest{Id: cancelled.GetId()})
		require.NoError(t, err)
		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(cancelled, 1))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "cancelled")

		po := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 10)
		_, err = biz.poBiz.ClosePurchaseOrder(ctx, &procurementv1.PurchaseOrderCloseRequest{Id: po.GetId()})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "nothing received: cancel instead")

		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 4))
		require.NoError(t, err)
		closed, err := biz.poBiz.ClosePurchaseOrder(ctx, &procurementv1.PurchaseOrderCloseRequest{
			Id: po.GetId(), Reason: "supplier out of stock",
		})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CLOSED, closed.GetStatus())
		require.Equal(t, procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CLOSED,
			closed.GetLines()[0].GetStatus())
		require.InDelta(t, 4, closed.GetLines()[0].GetReceivedQuantity(), 0)

		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 1))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "closed")
		_, err = biz.poBiz.CancelPurchaseOrder(ctx, &procurementv1.PurchaseOrderCancelRequest{Id: po.GetId()})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		again, err := biz.poBiz.ClosePurchaseOrder(ctx, &procurementv1.PurchaseOrderCloseRequest{Id: po.GetId()})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CLOSED, again.GetStatus())
	})
}

// Quantities are exact decimals: ten receipts of 0.1 fill an order of 1.
func (gts *GoodsReceiptTestSuite) TestReceipt_QuantitiesAreExact() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-receiver")

		supplier, item := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			InventoryItemId: "saffron", UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: 0, Nanos: 300_000_000},
		})
		po := gts.submittedPO(ctx, biz, supplier.GetId(), item.GetId(), 1)
		// 1 × 0.30 = 0.30 exactly.
		require.Equal(t, int64(0), po.GetTotalAmount().GetUnits())
		require.Equal(t, int32(300_000_000), po.GetTotalAmount().GetNanos())

		_, err := biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 0.0000001))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "more than six places")

		for range 10 {
			_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 0.1))
			require.NoError(t, err)
		}
		got, err := biz.poBiz.GetPurchaseOrder(ctx, po.GetId())
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED, got.GetStatus())
		require.Equal(t, 1.0, got.GetLines()[0].GetReceivedQuantity()) //nolint:testifylint // exact on purpose

		_, err = biz.grBiz.CreateGoodsReceipt(ctx, receiveOn(po, 0.000001))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "nothing remains")
	})
}

// Supplier prices are checked, an order's total cannot overflow, inactive
// suppliers take no orders, and an idempotency key replays only the same
// request.
func (gts *GoodsReceiptTestSuite) TestPurchaseOrder_Validation() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-buyer")

		supplier, item := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{InventoryItemId: "oil"})

		for name, tc := range map[string]*procurementv1.SupplierItemSaveRequest{
			"no price":       {InventoryItemId: "x"},
			"not a currency": {InventoryItemId: "x", UnitPrice: &commonv1.Money{CurrencyCode: "ZZQ", Units: 1}},
			"negative":       {InventoryItemId: "x", UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: -1}},
			"nanos overflow": {InventoryItemId: "x", UnitPrice: &commonv1.Money{CurrencyCode: "USD", Nanos: 1_000_000_000}},
			"negative moq":   {InventoryItemId: "x", UnitPrice: usdPrice(1), MinOrderQuantity: -1},
			"no target":      {UnitPrice: usdPrice(1)},
			"variant with inventory id": {
				SupplyKind: procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, ProductVariantId: "v",
				InventoryItemId: "x", UnitPrice: usdPrice(1),
			},
			"fractional variant moq": {
				SupplyKind: procurementv1.SupplyKind_SUPPLY_KIND_PRODUCT_VARIANT, ProductVariantId: "v",
				UnitPrice: usdPrice(1), MinOrderQuantity: 0.5,
			},
		} {
			tc.SupplierId = supplier.GetId()
			_, err := biz.supplierBiz.SaveSupplierItem(ctx, tc)
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), name)
		}

		// What an item supplies is fixed once created.
		_, err := biz.supplierBiz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
			Id: item.GetId(), SupplierId: supplier.GetId(), InventoryItemId: "other", UnitPrice: usdPrice(2),
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		// The line total is computed exactly and refused when it overflows.
		_, huge := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{
			InventoryItemId: "gold", UnitPrice: usdPrice(9_000_000_000),
		})
		_, err = biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001", SupplierId: huge.GetSupplierId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: huge.GetId(), OrderedQuantity: 1e11}},
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		// An idempotency key replays only the request it was used for.
		key := "po-" + util.RandomAlphaNumericString(6)
		create := func(quantity float64) (*procurementv1.PurchaseOrder, error) {
			return biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
				IdempotencyKey: key, PropertyId: "property-001", SupplierId: supplier.GetId(),
				Lines: []*procurementv1.PurchaseOrderLineInput{
					{SupplierItemId: item.GetId(), OrderedQuantity: quantity},
				},
			})
		}
		first, err := create(3)
		require.NoError(t, err)
		again, err := create(3)
		require.NoError(t, err)
		require.Equal(t, first.GetId(), again.GetId())
		_, err = create(4)
		require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(err))

		// A suspended supplier takes no new orders.
		_, err = biz.supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
			Id: supplier.GetId(), Name: supplier.GetName(), Currency: "USD",
			Status: procurementv1.SupplierStatus_SUPPLIER_STATUS_SUSPENDED,
		})
		require.NoError(t, err)
		_, err = biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001", SupplierId: supplier.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: item.GetId(), OrderedQuantity: 1}},
		})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

// Searches combine their filters, clamp the page size and page by cursor.
func (gts *GoodsReceiptTestSuite) TestPurchaseOrderSearch_FiltersAndPages() {
	t := gts.T()

	gts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := gts.CreateService(t, dep)
		biz := gts.getBusiness(ctx, svc)
		ctx = gts.WithAuthClaims(ctx, "tenant-1", "partition-1", "profile-buyer")

		supplierA, itemA := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{InventoryItemId: "a"})
		supplierB, itemB := gts.supplierWith(ctx, biz, &procurementv1.SupplierItemSaveRequest{InventoryItemId: "b"})
		for range 3 {
			gts.submittedPO(ctx, biz, supplierA.GetId(), itemA.GetId(), 1)
		}
		gts.submittedPO(ctx, biz, supplierB.GetId(), itemB.GetId(), 1)
		_, err := biz.poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
			PropertyId: "property-001", SupplierId: supplierA.GetId(),
			Lines: []*procurementv1.PurchaseOrderLineInput{{SupplierItemId: itemA.GetId(), OrderedQuantity: 1}},
		})
		require.NoError(t, err) // a draft

		search := func(status procurementv1.PurchaseOrderStatus, limit int32, page string) (
			[]*procurementv1.PurchaseOrder, string, error,
		) {
			return biz.poBiz.SearchPurchaseOrders(ctx, &procurementv1.PurchaseOrderSearchRequest{
				PropertyId: "property-001", SupplierId: supplierA.GetId(), Status: status,
				Search: &commonv1.SearchRequest{Cursor: &commonv1.PageCursor{Limit: limit, Page: page}},
			})
		}

		submitted := procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED
		first, next, err := search(submitted, 2, "")
		require.NoError(t, err)
		require.Len(t, first, 2)
		require.NotEmpty(t, next)
		rest, last, err := search(submitted, 2, next)
		require.NoError(t, err)
		require.Len(t, rest, 1)
		require.Empty(t, last)
		seen := map[string]bool{}
		for _, po := range append(first, rest...) {
			require.Equal(t, supplierA.GetId(), po.GetSupplierId())
			require.Equal(t, submitted, po.GetStatus())
			seen[po.GetId()] = true
		}
		require.Len(t, seen, 3)

		all, _, err := search(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_UNSPECIFIED, 1_000_000, "")
		require.NoError(t, err)
		require.Len(t, all, 4, "a huge limit is clamped, not refused")

		_, _, err = search(submitted, 2, "not-a-cursor")
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

// The commerce destination tells refusals (final) from failures (retried).
func TestCommerceStockDestination_ClassifiesErrors(t *testing.T) {
	t.Parallel()
	for _, tc := range []struct {
		code    connect.Code
		refused bool
	}{
		{connect.CodeNotFound, true},
		{connect.CodeAlreadyExists, true},
		{connect.CodeInvalidArgument, true},
		{connect.CodeFailedPrecondition, true},
		{connect.CodeUnavailable, false},
		{connect.CodeDeadlineExceeded, false},
		{connect.CodePermissionDenied, false},
		{connect.CodeUnauthenticated, false},
		{connect.CodeInternal, false},
	} {
		code, refused := tc.code, tc.refused
		dest := business.NewCommerceStockDestination(&commerceAnswering{err: connect.NewError(code, "x")})
		err := dest.ReceiveVariantStock(t.Context(), "t", "v", 1, "r")
		require.Error(t, err)
		require.Equal(t, refused, errors.Is(err, business.ErrDeliveryRefused), code.String())
	}
	ok := commerceAnswering{}
	require.NoError(t, business.NewCommerceStockDestination(&ok).ReceiveVariantStock(t.Context(), "t", "v", 2, "r"))
	require.Nil(t, business.NewCommerceStockDestination(nil))
}

type commerceAnswering struct {
	err error
	got *commercev1.ReceiveStockRequest
}

func (c *commerceAnswering) ReceiveStock(
	_ context.Context,
	req *commercev1.ReceiveStockRequest,
) (*commercev1.ReceiveStockResponse, error) {
	c.got = req
	return &commercev1.ReceiveStockResponse{}, c.err
}
