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
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

func (bts *BusinessTestSuite) orderRepo(ctx context.Context, svc *frame.Service) repository.OrderRepository {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	return repository.NewOrderRepository(ctx, dbPool, svc.WorkManager())
}

func (bts *BusinessTestSuite) TestLatePayment_OnExpiredOrderIsAppliedAndRefunded() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-late", 2)

		checked, err := checkoutOrder(ctx, biz.paymentBiz, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		ref := checked.GetPaymentSessionRef()

		// The window lapses with nothing paid: the order expires.
		bts.backdatePaymentDue(ctx, svc, order.GetId(), -2*time.Hour)
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Expired)
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, variant))

		// The buyer pays the old link afterwards. The money is found, kept
		// off the expired order's stock, and paid straight back.
		biz.checkout.complete(ref, "pay-late")
		summary, err = biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Paid)
		require.Equal(t, int32(1), summary.RefundsSent)

		late, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, late.GetStatus())
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING, late.GetPaymentStatus())
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, variant), "a late payment reserves nothing")
		require.Equal(t, int64(21_000_000_000), biz.refunds.refunded(models.RefundReferencePrefix+order.GetId()))
		require.Equal(t, "buyer-late/", biz.refunds.payee(models.RefundReferencePrefix+order.GetId()+":"+ref),
			"the buyer is paid back; payment picks the route")

		biz.refunds.confirmAll()
		summary, err = biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.RefundsConfirmed)
		refunded, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUNDED, refunded.GetPaymentStatus())
		require.Contains(
			t,
			bts.eventTypes(ctx, biz, order.GetId()),
			commercev1.OrderEventType_ORDER_EVENT_TYPE_REFUNDED,
		)

		// Money that was never a sale is neither booked nor reversed.
		postings, err := bts.ledgerAt(ctx, svc, biz, 24*time.Hour).
			RunEndOfDayLedger(ctx, shop.GetId(), time.Now().UTC().Format("2006-01-02"))
		require.NoError(t, err)
		require.True(t, postings[0].GetSkipped())
		require.Zero(t, postings[0].GetSales().GetUnits())
		require.Zero(t, postings[0].GetRefunds().GetUnits())
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_ExtendsWindowToCoverTheSession() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-w", 1)

		// One minute of the window left when the buyer starts paying.
		bts.backdatePaymentDue(ctx, svc, order.GetId(), time.Minute)
		_, err := checkoutOrder(ctx, biz.paymentBiz, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)

		extended, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.WithinDuration(t, time.Now().Add(30*time.Minute), extended.GetPaymentDueAt().AsTime(), time.Minute,
			"stock stays held for as long as the session can be paid")
	})
}

func (bts *BusinessTestSuite) TestReconcile_FailedSessionWithPromptIsInFlight() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-f", 1)

		checked, err := checkoutOrder(ctx, biz.paymentBiz, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		biz.checkout.attempt(checked.GetPaymentSessionRef(), "prompt-1")
		biz.checkout.fail(checked.GetPaymentSessionRef())

		bts.backdatePaymentDue(ctx, svc, order.GetId(), -10*time.Minute)
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Zero(t, summary.Expired, "a failed session's prompt may still be paid")
	})
}

func (bts *BusinessTestSuite) TestOverdue_ShippedOrderIsOnlyFlagged() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		policy := instalmentPolicy()
		policy.CancelWhenOverdue = true
		bts.setShopPolicy(ctx, biz, shop.GetId(), policy)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-s", 2) // 21.00

		// 11.00 paid passes the 50% fulfilment mark; the goods ship.
		_, err := biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: order.GetId(), Amount: usd(11, 0), Reference: "dep-s",
		})
		require.NoError(t, err)
		f, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines:   []*commercev1.FulfilmentLine{{OrderLineId: order.GetLines()[0].GetId(), Quantity: 2}},
		})
		require.NoError(t, err)
		_, err = biz.fulfilmentBiz.UpdateFulfilment(ctx, &commercev1.UpdateFulfilmentRequest{
			Id: f.GetId(), Status: commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED, Carrier: "G4S",
		})
		require.NoError(t, err)

		bts.backdateBalanceDue(ctx, svc, order.GetId())
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Overdue)

		flagged, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.NotEqual(
			t,
			commercev1.OrderStatus_ORDER_STATUS_CANCELLED,
			flagged.GetStatus(),
			"shipped goods stay sold",
		)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PARTIALLY_PAID, flagged.GetPaymentStatus())
		require.Equal(t, int64(98), bts.stockOf(ctx, biz, variant), "nothing that left is restocked")
		require.Zero(t, biz.refunds.sendCount())

		again, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Zero(t, again.Overdue, "flagged once, never looped")
	})
}

func (bts *BusinessTestSuite) TestReconcile_StuckOrdersDoNotBlockOthers() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// Two older orders that cannot be settled yet: a prompt is out on
		// each and they are inside the settle grace.
		var stuck []*commercev1.Order
		for i := range 2 {
			o := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-stuck", int64(i+1))
			checked, err := checkoutOrder(ctx, biz.paymentBiz, &commercev1.CheckoutOrderRequest{OrderId: o.GetId()})
			require.NoError(t, err)
			biz.checkout.attempt(checked.GetPaymentSessionRef(), "prompt-stuck")
			bts.backdatePaymentDue(ctx, svc, o.GetId(), -10*time.Minute)
			stuck = append(stuck, o)
		}
		// A newer one that is simply abandoned.
		abandoned := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-gone", 1)
		bts.backdatePaymentDue(ctx, svc, abandoned.GetId(), -time.Hour)

		first, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 2)
		require.NoError(t, err)
		require.Equal(t, int32(2), first.Examined)
		require.Zero(t, first.Expired, "the oldest two are still in flight")

		second, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 2)
		require.NoError(t, err)
		require.Equal(t, int32(1), second.Examined, "the backed-off orders wait their turn")
		require.Equal(t, int32(1), second.Expired)
		released, err := biz.orderBiz.GetOrder(ctx, abandoned.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, released.GetStatus())

		// A session that charged the wrong amount goes to staff review and
		// leaves the sweep.
		odd := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-odd", 1)
		checked, err := checkoutOrder(ctx, biz.paymentBiz, &commercev1.CheckoutOrderRequest{OrderId: odd.GetId()})
		require.NoError(t, err)
		biz.checkout.complete(checked.GetPaymentSessionRef(), "pay-odd")
		biz.checkout.setAmount(checked.GetPaymentSessionRef(), usd(1, 0))
		_, err = biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 10)
		require.NoError(t, err)
		reviewed, err := biz.orderBiz.GetOrder(ctx, odd.GetId())
		require.NoError(t, err)
		require.NotEmpty(t, reviewed.GetPaymentReview())
		bts.backdatePaymentDue(ctx, svc, odd.GetId(), -time.Hour)
		after, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 10)
		require.NoError(t, err)
		require.Zero(t, after.Examined+after.Expired, "an order under review is left to staff")
		require.Len(t, stuck, 2)
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_OneOpenSessionPerOrder() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// Concurrent checkouts of one order all land on one session.
		racing := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-race", 1)
		var (
			wg   sync.WaitGroup
			mu   sync.Mutex
			refs = map[string]int{}
		)
		for range 5 {
			wg.Add(1)
			go func() {
				defer wg.Done()
				result, err := biz.paymentBiz.CheckoutOrder(
					ctx,
					&commercev1.CheckoutOrderRequest{OrderId: racing.GetId()},
				)
				if err != nil {
					return
				}
				mu.Lock()
				refs[result.Order.GetPaymentSessionRef()]++
				mu.Unlock()
			}()
		}
		wg.Wait()
		require.Len(t, refs, 1, "every buyer tab is offered the same session")

		// While a deposit link is open, a different amount is refused
		// rather than a second payable link issued.
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-one", 2) // 21.00
		deposit, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(7, 0),
		})
		require.NoError(t, err)
		created := biz.checkout.createdSessions()
		_, err = biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(10, 0),
		})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
		require.Equal(t, created, biz.checkout.createdSessions())

		// Once that link can no longer be paid, the buyer may pick another
		// amount.
		biz.checkout.expire(deposit.Order.GetPaymentSessionRef())
		_, err = biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(10, 0),
		})
		require.NoError(t, err)
		require.Equal(t, created+1, biz.checkout.createdSessions())
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_ReturnURLMustBeTrusted() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-u", 1)

		for _, bad := range []string{
			"https://evil.example/phish",
			"http://store.example/thanks",
			"https://user@store.example/thanks",
			"javascript:alert(1)",
		} {
			_, err := biz.returnPaymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
				OrderId: order.GetId(), ReturnUrl: bad,
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), bad)
		}
		require.Zero(t, biz.checkout.createdSessions())

		// The shop's own return host is trusted too.
		_, err := biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id:                shop.GetId(),
			UpdateMask:        &fieldmaskpb.FieldMask{Paths: []string{"checkout_return_url"}},
			CheckoutReturnUrl: "https://myshop.example/done",
		})
		require.NoError(t, err)
		_, err = biz.returnPaymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), ReturnUrl: "https://myshop.example/orders/{order_id}",
		})
		require.NoError(t, err)
	})
}

func (bts *BusinessTestSuite) TestPaymentReturn_ChecksRefBeforeAskingCheckout() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-p", 1)
		_, err := checkoutOrder(ctx, biz.returnPaymentBiz, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)

		before := biz.checkout.getCount()
		_, err = biz.returnPaymentBiz.HandlePaymentReturn(ctx, order.GetId(), "cs_guessed")
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
		require.Equal(t, before, biz.checkout.getCount(), "a guessed ref never reaches the checkout service")
	})
}

func (bts *BusinessTestSuite) TestRefund_LostSendResponseIsConfirmedNotResent() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-l", 1)
		bts.payOrder(ctx, biz, order.GetId())

		biz.refunds.loseResponse = true
		cancelled, err := biz.paymentBiz.CancelOrder(ctx, order.GetId(), "out of stock", true)
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING, cancelled.GetPaymentStatus())

		// Inside the claim grace nothing is resent.
		_, err = biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, 1, biz.refunds.sendCount())

		// After it, the payment service is asked by reference, finds the
		// refund, and it is confirmed without a second payout.
		repo := bts.orderRepo(ctx, svc)
		refunds, err := repo.ListRefunds(ctx, order.GetId())
		require.NoError(t, err)
		require.Len(t, refunds, 1)
		stale := time.Now().Add(-time.Hour)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		require.NoError(t, dbPool.DB(ctx, false).Model(&models.OrderRefund{}).
			Where("id = ?", refunds[0].GetID()).UpdateColumn("sent_at", stale).Error)

		biz.refunds.confirmAll()
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, "", 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.RefundsConfirmed)
		require.Equal(t, 1, biz.refunds.sendCount(), "never paid out twice")
		refunded, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUNDED, refunded.GetPaymentStatus())
	})
}

func (bts *BusinessTestSuite) TestRunEndOfDayLedger_PagesEveryShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		restore := business.SetShopsPerPage(1)
		defer restore()

		shops := map[string]bool{}
		for range 3 {
			shop := bts.createTestShop(ctx, biz)
			_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
			o := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-page", 1)
			bts.payOrder(ctx, biz, o.GetId())
			shops[shop.GetId()] = true
		}

		postings, err := bts.ledgerAt(ctx, svc, biz, 24*time.Hour).
			RunEndOfDayLedger(ctx, "", time.Now().UTC().Format("2006-01-02"))
		require.NoError(t, err)
		posted := 0
		for _, p := range postings {
			if shops[p.GetShopId()] {
				require.False(t, p.GetSkipped(), p.GetError())
				posted++
			}
		}
		require.Equal(t, 3, posted, "a shop past the first page is posted too")
	})
}

func (bts *BusinessTestSuite) TestWebhooks_ClaimedOnceAndRefusedWithoutSecret() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		eventRepo := repository.NewOrderEventRepository(ctx, dbPool, svc.WorkManager())
		shopRepo := repository.NewShopRepository(ctx, dbPool, svc.WorkManager())

		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		event := &models.OrderEvent{
			ShopID:   shop.GetId(),
			OrderID:  "o-claim",
			Type:     1,
			Delivery: models.EventDeliveryPending,
		}
		require.NoError(t, eventRepo.Create(ctx, event))

		// Two runs racing for one event: one claims it, and the attempt is
		// counted on the row before anything is sent.
		now := time.Now()
		claimed, err := eventRepo.ClaimDelivery(ctx, event.GetID(), now, now.Add(time.Minute))
		require.NoError(t, err)
		require.NotNil(t, claimed)
		require.Equal(t, int32(1), claimed.DeliveryAttempts)
		again, err := eventRepo.ClaimDelivery(ctx, event.GetID(), now, now.Add(time.Minute))
		require.NoError(t, err)
		require.Nil(t, again, "held by the first claim")

		// An attempt that dies without recording is retried once the lease
		// lapses; the delivery is then recorded.
		webhooks := &fakeWebhooks{}
		events := business.NewEventBusiness(eventRepo, shopRepo, notifications.New(nil), webhooks, nil, nil)
		require.Zero(t, events.DeliverDue(ctx, now))
		require.Equal(t, 1, events.DeliverDue(ctx, now.Add(2*time.Minute)))
		delivered, err := eventRepo.GetByID(ctx, event.GetID())
		require.NoError(t, err)
		require.Equal(t, models.EventDeliveryDelivered, delivered.Delivery)
		require.Equal(t, int32(2), delivered.DeliveryAttempts)

		// A shop with a webhook but no secret gets nothing unsigned.
		bare, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "Bare " + util.RandomAlphaNumericString(6), Slug: "bare-" + util.RandomAlphaNumericString(6),
			WebhookUrl: "https://hooks.example/bare",
		})
		require.NoError(t, err)
		unsigned := &models.OrderEvent{
			ShopID:   bare.GetId(),
			OrderID:  "o-bare",
			Type:     1,
			Delivery: models.EventDeliveryPending,
		}
		require.NoError(t, eventRepo.Create(ctx, unsigned))
		sent := len(webhooks.events())
		require.Zero(t, events.DeliverDue(ctx, time.Now()))
		require.Len(t, webhooks.events(), sent)
		refused, err := eventRepo.GetByID(ctx, unsigned.GetID())
		require.NoError(t, err)
		require.Contains(t, refused.LastError, "secret")
	})
}

func (bts *BusinessTestSuite) TestCancel_PaymentLandingMidCancelIsRefunded() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-mid", 1)
		repo := bts.orderRepo(ctx, svc)

		// The payment lands between the cancel's read and its write; the
		// cancel must decide again and refund it rather than drop it.
		decisions := 0
		_, plan, err := repo.Cancel(ctx, order.GetId(), time.Now(),
			func(current *models.Order, salePaid int64) (*repository.CancelPlan, error) {
				decisions++
				if decisions == 1 {
					_, _, applied, applyErr := repo.ApplyPayment(ctx, current.GetID(), &models.OrderPayment{
						Currency: "USD", AmountNanos: 10_500_000_000, Reference: "cs_mid", PaidAt: time.Now(),
					}, func(o *models.Order, _ *models.OrderPayment) []*models.OrderEvent {
						o.Status = int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED)
						o.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID)
						return nil
					})
					require.NoError(t, applyErr)
					require.True(t, applied)
				}
				plan := &repository.CancelPlan{Reason: "staff"}
				if salePaid > 0 {
					plan.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING)
					plan.Refund = &models.OrderRefund{
						Reference: models.RefundReferencePrefix + current.GetID() + ":cancel", AmountNanos: salePaid,
						ReversesSale: true,
					}
				}
				return plan, nil
			})
		require.NoError(t, err)
		require.NotNil(t, plan)
		require.Equal(t, 2, decisions, "the stale decision was thrown away")

		refunds, err := repo.ListRefunds(ctx, order.GetId())
		require.NoError(t, err)
		require.Len(t, refunds, 1)
		require.Equal(t, int64(10_500_000_000), refunds[0].AmountNanos)
		require.True(t, refunds[0].ReversesSale)
		cancelled, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, cancelled.GetStatus())
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING, cancelled.GetPaymentStatus())

		// And the other way round: a payment applied after the cancel is
		// all excess, refunded, and never a sale.
		_, _, applied, err := repo.ApplyPayment(ctx, order.GetId(), &models.OrderPayment{
			Currency: "USD", AmountNanos: 2_000_000_000, Reference: "cs_after", PaidAt: time.Now(),
		}, func(*models.Order, *models.OrderPayment) []*models.OrderEvent { return nil })
		require.NoError(t, err)
		require.True(t, applied)
		refunds, err = repo.ListRefunds(ctx, order.GetId())
		require.NoError(t, err)
		require.Len(t, refunds, 2)
		require.Equal(t, int64(2_000_000_000), refunds[1].AmountNanos)
		require.False(t, refunds[1].ReversesSale)
	})
}
