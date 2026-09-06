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
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// buyerOrder places a cart order for a buyer and returns it awaiting payment.
func (bts *BusinessTestSuite) buyerOrder(
	ctx context.Context,
	biz allBiz,
	shopID, variantID, buyer string,
	qty int64,
) *commercev1.Order {
	t := bts.T()
	cart, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{ShopId: shopID, ProfileId: buyer})
	require.NoError(t, err)
	_, err = biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
		CartId: cart.GetId(), ProductVariantId: variantID, Quantity: qty,
	})
	require.NoError(t, err)
	order, err := biz.orderBiz.CreateOrderFromCart(ctx, &commercev1.CreateOrderFromCartRequest{CartId: cart.GetId()})
	require.NoError(t, err)
	require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT, order.GetStatus())
	return order
}

func (bts *BusinessTestSuite) TestCheckoutOrder_CreatesSessionOnceAndNotifies() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-1", 2)

		first, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.NotEmpty(t, first.GetPaymentSessionRef())
		require.Contains(t, first.GetCheckoutUrl(), first.GetPaymentSessionRef())

		session, err := biz.checkout.GetSession(ctx, first.GetPaymentSessionRef())
		require.NoError(t, err)
		require.Equal(t, "order:"+order.GetId(), session.GetOrderRef())
		require.Equal(t, int64(21), session.GetAmount().GetUnits())
		require.Equal(t, "USD", session.GetAmount().GetCurrencyCode())
		require.Equal(t, "buyer-1", session.GetPayer().GetProfileId())
		require.Equal(t, "https://shop.example/orders/"+order.GetId(), session.GetReturnUrl())
		require.Equal(t, 1, biz.notifier.count("placed", order.GetId()))

		// A reload reuses the live session instead of creating another.
		again, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.Equal(t, first.GetPaymentSessionRef(), again.GetPaymentSessionRef())
		require.Equal(t, 1, biz.checkout.createdSessions())

		// An expired session is replaced.
		biz.checkout.expire(first.GetPaymentSessionRef())
		replaced, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.NotEqual(t, first.GetPaymentSessionRef(), replaced.GetPaymentSessionRef())
		require.Equal(t, 2, biz.checkout.createdSessions())

		// Confirming before the rail completes is refused; after, it settles
		// once and further confirmations are no-ops.
		_, err = biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		biz.checkout.complete(replaced.GetPaymentSessionRef(), "pay-1")
		paid, err := biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CONFIRMED, paid.GetStatus())
		require.Equal(t, "pay-1", paid.GetPaymentId())
		paidAgain, err := biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, paid.GetPaymentId(), paidAgain.GetPaymentId())
		require.Equal(t, 1, biz.notifier.count("paid", order.GetId()))

		// A paid order cannot be checked out again.
		_, err = biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_GatewayFailureLeavesOrderUntouched() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-2", 1)

		biz.checkout.failNext = errors.New("rail down")
		_, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))

		reloaded, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Empty(t, reloaded.GetPaymentSessionRef())
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT, reloaded.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestCancelOrder_RestocksAndRespectsRoles() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// Buyer cancels their own unpaid order: stock returns.
		unpaid := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-3", 4)
		cancelled, err := biz.paymentBiz.CancelOrder(ctx, unpaid.GetId(), "changed my mind", false)
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, cancelled.GetStatus())
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PENDING, cancelled.GetPaymentStatus())
		require.Equal(t, "changed my mind", cancelled.GetCancelReason())
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, variant))
		require.Equal(t, 1, biz.notifier.count("cancelled", unpaid.GetId()))

		// Paid order: buyer is refused, staff cancel records a refund.
		paidOrder := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-3", 3)
		bts.payOrder(ctx, biz, paidOrder.GetId())
		require.Equal(t, int64(97), bts.stockOf(ctx, biz, variant))

		_, err = biz.paymentBiz.CancelOrder(ctx, paidOrder.GetId(), "", false)
		require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

		refunded, err := biz.paymentBiz.CancelOrder(ctx, paidOrder.GetId(), "out of stock", true)
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUNDED, refunded.GetPaymentStatus())
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, variant))

		// Shipped orders cannot be cancelled.
		shipped := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-3", 1)
		bts.payOrder(ctx, biz, shipped.GetId())
		f, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: shipped.GetId(),
			Lines:   []*commercev1.FulfilmentLine{{OrderLineId: shipped.GetLines()[0].GetId(), Quantity: 1}},
		})
		require.NoError(t, err)
		_, err = biz.fulfilmentBiz.UpdateFulfilment(ctx, &commercev1.UpdateFulfilmentRequest{
			Id: f.GetId(), Status: commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED, Carrier: "G4S",
		})
		require.NoError(t, err)
		require.Equal(t, 1, biz.notifier.count("shipped", shipped.GetId()))
		_, err = biz.paymentBiz.CancelOrder(ctx, shipped.GetId(), "", true)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestReconcilePayments_SettlesAndExpires() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// Paid at the rail but never confirmed by the buyer's browser.
		silentlyPaid := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-4", 2)
		checked, err := biz.paymentBiz.CheckoutOrder(
			ctx,
			&commercev1.CheckoutOrderRequest{OrderId: silentlyPaid.GetId()},
		)
		require.NoError(t, err)
		biz.checkout.complete(checked.GetPaymentSessionRef(), "pay-silent")

		// Abandoned past its payment window.
		abandoned := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-5", 5)
		bts.backdatePaymentDue(ctx, svc, abandoned.GetId(), -time.Hour)

		// Still inside its window.
		fresh := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-6", 1)

		summary, err := biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, int32(3), summary.Examined)
		require.Equal(t, int32(1), summary.Paid)
		require.Equal(t, int32(1), summary.Expired)
		require.Equal(t, int32(0), summary.Failed)

		settled, err := biz.orderBiz.GetOrder(ctx, silentlyPaid.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, settled.GetPaymentStatus())
		require.Equal(t, "pay-silent", settled.GetPaymentId())

		released, err := biz.orderBiz.GetOrder(ctx, abandoned.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, released.GetStatus())
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_EXPIRED, released.GetPaymentStatus())
		require.Equal(t, 1, biz.notifier.count("expired", abandoned.GetId()))

		untouched, err := biz.orderBiz.GetOrder(ctx, fresh.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT, untouched.GetStatus())

		// 100 - 2 (paid) - 1 (fresh) = 97; the abandoned 5 came back.
		require.Equal(t, int64(97), bts.stockOf(ctx, biz, variant))

		// A second run finds only the fresh order and changes nothing.
		again, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 10)
		require.NoError(t, err)
		require.Equal(t, int32(1), again.Examined)
		require.Equal(t, int32(0), again.Paid+again.Expired+again.Failed)
	})
}

func (bts *BusinessTestSuite) TestRunEndOfDayLedger_PostsOnceAndBalances() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// Two paid orders and one refund on the same day.
		a := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-7", 2) // 21.00
		bts.payOrder(ctx, biz, a.GetId())
		b := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-8", 1) // 10.50
		bts.payOrder(ctx, biz, b.GetId())
		c := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-9", 1) // 10.50 refunded
		bts.payOrder(ctx, biz, c.GetId())
		_, err := biz.paymentBiz.CancelOrder(ctx, c.GetId(), "damaged", true)
		require.NoError(t, err)

		today := time.Now().UTC().Format("2006-01-02")
		postings, err := biz.ledgerBiz.RunEndOfDayLedger(ctx, "", today)
		require.NoError(t, err)
		require.Len(t, postings, 1)
		p := postings[0]
		require.False(t, p.GetSkipped(), p.GetError())
		require.Equal(t, shop.GetId(), p.GetShopId())
		require.Equal(t, int32(3), p.GetOrders())
		require.Equal(t, int64(42), p.GetSales().GetUnits())   // 21 + 10.5 + 10.5
		require.Equal(t, int64(10), p.GetRefunds().GetUnits()) // the refunded order
		require.Equal(t, int32(500_000_000), p.GetRefunds().GetNanos())
		require.NotEmpty(t, p.GetTransactionId())

		posted := biz.ledger.posted()
		require.Len(t, posted, 1)
		require.Equal(t, "USD", posted[0].GetCurrency())
		require.Len(t, posted[0].GetEntries(), 2)
		// Net 31.50 debits receivable and credits sales.
		require.Equal(t, int64(31), posted[0].GetEntries()[0].GetAmount().GetUnits())
		require.False(t, posted[0].GetEntries()[0].GetCredit())
		require.True(t, posted[0].GetEntries()[1].GetCredit())
		require.Equal(t, 1, biz.notifier.count("ledger", ""))

		// Orders now carry the transaction, and a re-run posts nothing new.
		stamped, err := biz.orderBiz.GetOrder(ctx, a.GetId())
		require.NoError(t, err)
		require.Equal(t, p.GetTransactionId(), stamped.GetLedgerTransactionId())

		rerun, err := biz.ledgerBiz.RunEndOfDayLedger(ctx, shop.GetId(), today)
		require.NoError(t, err)
		require.Len(t, rerun, 1)
		require.Equal(t, p.GetTransactionId(), rerun[0].GetTransactionId())
		require.Len(t, biz.ledger.posted(), 1)

		// A day with no activity is recorded as skipped.
		quiet, err := biz.ledgerBiz.RunEndOfDayLedger(ctx, shop.GetId(), "2000-01-01")
		require.NoError(t, err)
		require.True(t, quiet[0].GetSkipped())

		_, err = biz.ledgerBiz.RunEndOfDayLedger(ctx, shop.GetId(), "not-a-date")
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestRunEndOfDayLedger_FailureIsRetried() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		o := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-10", 1)
		bts.payOrder(ctx, biz, o.GetId())
		today := time.Now().UTC().Format("2006-01-02")

		biz.ledger.failNext = errors.New("ledger unavailable")
		failed, err := biz.ledgerBiz.RunEndOfDayLedger(ctx, shop.GetId(), today)
		require.NoError(t, err)
		require.NotEmpty(t, failed[0].GetError())
		require.Empty(t, failed[0].GetTransactionId())

		recovered, err := biz.ledgerBiz.RunEndOfDayLedger(ctx, shop.GetId(), today)
		require.NoError(t, err)
		require.Empty(t, recovered[0].GetError())
		require.NotEmpty(t, recovered[0].GetTransactionId())
	})
}

func (bts *BusinessTestSuite) TestListShops_Pages() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		for range 3 {
			bts.createTestShop(ctx, biz)
		}
		page, err := biz.shopBiz.ListShops(ctx, &commercev1.ListShopsRequest{})
		require.NoError(t, err)
		require.Len(t, page.Shops, 3)
		require.Equal(t, "KES", page.Shops[0].GetCurrency())
	})
}

// --- helpers ---

func (bts *BusinessTestSuite) stockOf(ctx context.Context, biz allBiz, variant *commercev1.ProductVariant) int64 {
	t := bts.T()
	variants, err := biz.catalogBiz.ListProductVariants(ctx, variant.GetProductId())
	require.NoError(t, err)
	for _, v := range variants {
		if v.GetId() == variant.GetId() {
			return v.GetStockQuantity()
		}
	}
	t.Fatalf("variant %s not found", variant.GetId())
	return 0
}

// backdatePaymentDue shifts an order's payment deadline, standing in for the
// passage of time.
func (bts *BusinessTestSuite) backdatePaymentDue(
	ctx context.Context,
	svc *frame.Service,
	orderID string,
	by time.Duration,
) {
	t := bts.T()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	repo := repository.NewOrderRepository(ctx, dbPool, svc.WorkManager())
	order, err := repo.GetByID(ctx, orderID)
	require.NoError(t, err)
	due := time.Now().Add(by)
	order.PaymentDueAt = &due
	_, err = repo.Update(ctx, order, "payment_due_at")
	require.NoError(t, err)
}
