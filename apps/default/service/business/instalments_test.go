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
	"encoding/base64"
	"strings"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
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

func usd(units int64, nanos int32) *commonv1.Money {
	return &commonv1.Money{CurrencyCode: "USD", Units: units, Nanos: nanos}
}

// setShopPolicy gives the shop a payment policy and a webhook.
func (bts *BusinessTestSuite) setShopPolicy(
	ctx context.Context,
	biz allBiz,
	shopID string,
	policy *commercev1.PaymentPolicy,
) {
	_, err := biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
		Id:            shopID,
		UpdateMask:    &fieldmaskpb.FieldMask{Paths: []string{"payment_policy", "webhook_url", "webhook_secret"}},
		PaymentPolicy: policy,
		WebhookUrl:    "https://hooks.example/commerce",
		WebhookSecret: "s3cret",
	})
	bts.Require().NoError(err)
}

func (bts *BusinessTestSuite) eventTypes(ctx context.Context, biz allBiz, orderID string) []commercev1.OrderEventType {
	page, err := biz.eventBiz.List(ctx, "", orderID, repository.Page{})
	bts.Require().NoError(err)
	types := make([]commercev1.OrderEventType, 0, len(page.Events))
	for _, e := range page.Events {
		types = append(types, e.GetType())
	}
	return types
}

// backdateBalanceDue moves an order's balance deadline into the past.
func (bts *BusinessTestSuite) backdateBalanceDue(ctx context.Context, svc *frame.Service, orderID string) {
	t := bts.T()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	repo := repository.NewOrderRepository(ctx, dbPool, svc.WorkManager())
	order, err := repo.GetByID(ctx, orderID)
	require.NoError(t, err)
	due := time.Now().Add(-time.Hour)
	order.BalanceDueAt = &due
	_, err = repo.Update(ctx, order, "balance_due_at")
	require.NoError(t, err)
}

func instalmentPolicy() *commercev1.PaymentPolicy {
	return &commercev1.PaymentPolicy{
		AllowInstalments:     true,
		MinDepositPercent:    30,
		MinInstalmentPercent: 20,
		BalanceDueDays:       7,
		FulfilAtPercent:      50,
		SignalThresholds:     []int32{75, 25, 50},
	}
}

func (bts *BusinessTestSuite) TestInstalments_DepositThresholdsAndFullPayment() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// 2 x 10.50 = 21.00; deposit >= 6.30, later instalments >= 4.20.
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i1", 2)
		require.True(t, order.GetPaymentPolicy().GetAllowInstalments())
		require.Equal(t, []int32{25, 50, 75}, order.GetPaymentPolicy().GetSignalThresholds())
		require.Equal(t, int64(21), order.GetBalance().GetUnits())

		_, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(5, 0),
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "below the deposit")

		deposit, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(7, 0),
		})
		require.NoError(t, err)
		require.Equal(t, int64(7), deposit.Amount.GetUnits())
		biz.checkout.complete(deposit.Order.GetPaymentSessionRef(), "pay-dep")

		partial, err := biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PARTIALLY_PAID, partial.GetPaymentStatus())
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CONFIRMED, partial.GetStatus())
		require.Equal(t, int64(7), partial.GetAmountPaid().GetUnits())
		require.Equal(t, int64(14), partial.GetBalance().GetUnits())
		require.Nil(t, partial.GetPaymentDueAt(), "stock is now held until the balance deadline")
		require.WithinDuration(t, time.Now().Add(7*24*time.Hour), partial.GetBalanceDueAt().AsTime(), time.Minute)
		require.Len(t, partial.GetPayments(), 1)
		require.Equal(t, []commercev1.OrderEventType{
			commercev1.OrderEventType_ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_DEPOSIT_PAID,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
		}, bts.eventTypes(ctx, biz, order.GetId()))
		require.Equal(t, 1, biz.notifier.count("instalment", order.GetId()))
		require.Equal(t, 1, biz.notifier.count("threshold", order.GetId()))

		// Webhooks went out signed, one per event.
		require.Equal(t, []string{
			"ORDER_EVENT_TYPE_PAYMENT_RECEIVED", "ORDER_EVENT_TYPE_DEPOSIT_PAID", "ORDER_EVENT_TYPE_THRESHOLD_CROSSED",
		}, biz.webhooks.events())
		first := biz.webhooks.delivered[0]
		require.Equal(t, "https://hooks.example/commerce", first.URL)
		require.Equal(t, "s3cret", first.Secret)
		require.NotZero(t, first.Timestamp)
		require.NotEqual(t, business.SignWebhook("s3cret", first.Timestamp, first.Body),
			business.SignWebhook("s3cret", first.Timestamp+1, first.Body), "the timestamp is signed")

		// 33% paid is below the 50% the policy needs before fulfilment.
		lines := []*commercev1.FulfilmentLine{{OrderLineId: order.GetLines()[0].GetId(), Quantity: 1}}
		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(), Lines: lines,
		})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// A buyer cannot cancel once money has been paid.
		_, err = biz.paymentBiz.CancelOrder(ctx, order.GetId(), "", false)
		require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

		// Cash at the counter takes it to 53%: threshold 50 and fulfilment.
		recorded, err := biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: order.GetId(), Amount: usd(4, 200_000_000), Reference: "till-1", RecordedBy: "staff-1",
		})
		require.NoError(t, err)
		require.Equal(t, int64(11), recorded.GetAmountPaid().GetUnits())
		again, err := biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: order.GetId(), Amount: usd(4, 200_000_000), Reference: "till-1",
		})
		require.NoError(t, err)
		require.Len(t, again.GetPayments(), 2, "a repeated reference is applied once")

		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(), Lines: lines,
		})
		require.NoError(t, err)

		// The balance is paid online and picked up by the reconciler.
		rest, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.Equal(t, int64(9), rest.Amount.GetUnits())
		require.Equal(t, int32(800_000_000), rest.Amount.GetNanos())
		biz.checkout.complete(rest.Order.GetPaymentSessionRef(), "pay-rest")

		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Paid)

		paid, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, paid.GetPaymentStatus())
		require.Equal(t, int64(0), paid.GetBalance().GetUnits())
		require.NotNil(t, paid.GetPaidAt())
		require.Len(t, paid.GetPayments(), 3)
		require.Equal(t, []commercev1.OrderEventType{
			commercev1.OrderEventType_ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_DEPOSIT_PAID,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_FULFILMENT_RELEASED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
			commercev1.OrderEventType_ORDER_EVENT_TYPE_FULLY_PAID,
		}, bts.eventTypes(ctx, biz, order.GetId()))
		require.Equal(t, 1, biz.notifier.count("paid", order.GetId()))

		// End of day books every instalment as received.
		postings, err := bts.ledgerAt(ctx, svc, biz, 24*time.Hour).
			RunEndOfDayLedger(ctx, shop.GetId(), time.Now().UTC().Format("2006-01-02"))
		require.NoError(t, err)
		require.Len(t, postings, 1)
		require.Equal(t, int64(21), postings[0].GetSales().GetUnits())
		require.Equal(t, int32(0), postings[0].GetSales().GetNanos())
		require.Equal(t, int32(1), postings[0].GetOrders())
	})
}

func (bts *BusinessTestSuite) TestInstalments_RefusedWithoutPolicy() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i2", 2)

		_, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(10, 0),
		})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		full, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId: order.GetId(), Amount: usd(21, 0),
		})
		require.NoError(t, err, "the whole balance is always accepted")
		require.Equal(t, int64(21), full.Amount.GetUnits())
	})
}

func (bts *BusinessTestSuite) TestInstalments_ProductOverrideIsMergedStrictest() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		product, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		_, err := biz.catalogBiz.UpdateProduct(ctx, &commercev1.UpdateProductRequest{
			Id:         product.GetId(),
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"payment_policy"}},
			PaymentPolicy: &commercev1.PaymentPolicy{
				AllowInstalments: true, MinDepositPercent: 60, BalanceDueDays: 3, SignalThresholds: []int32{90},
			},
		})
		require.NoError(t, err)

		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i3", 1)
		policy := order.GetPaymentPolicy()
		require.Equal(t, int32(60), policy.GetMinDepositPercent())
		require.Equal(t, int32(3), policy.GetBalanceDueDays())
		require.Equal(t, []int32{90}, policy.GetSignalThresholds(), "the product's policy replaces the shop's")

		// Removing the override brings the shop's policy back for new orders.
		_, err = biz.catalogBiz.UpdateProduct(ctx, &commercev1.UpdateProductRequest{
			Id:         product.GetId(),
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"payment_policy"}},
		})
		require.NoError(t, err)
		next := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i3", 1)
		require.Equal(t, int32(30), next.GetPaymentPolicy().GetMinDepositPercent())
		require.Equal(t, int32(60), policy.GetMinDepositPercent(), "placed orders keep their policy")
	})
}

func (bts *BusinessTestSuite) TestInstalments_OverdueFlagsOnceOrCancels() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		// Flag only.
		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i4", 2)
		_, err := biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: order.GetId(), Amount: usd(7, 0), Reference: "dep-1",
		})
		require.NoError(t, err)
		bts.backdateBalanceDue(ctx, svc, order.GetId())

		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Overdue)
		require.Equal(t, 1, biz.notifier.count("overdue", order.GetId()))
		flagged, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CONFIRMED, flagged.GetStatus())
		require.Contains(t, bts.eventTypes(ctx, biz, order.GetId()),
			commercev1.OrderEventType_ORDER_EVENT_TYPE_BALANCE_OVERDUE)

		again, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(0), again.Overdue, "the overdue signal is raised once")

		// Cancel when overdue: stock comes back and what was paid is refunded.
		strict := bts.createTestShop(ctx, biz)
		policy := instalmentPolicy()
		policy.CancelWhenOverdue = true
		bts.setShopPolicy(ctx, biz, strict.GetId(), policy)
		_, strictVariant := bts.createTestProductWithVariant(ctx, biz, strict.GetId())
		doomed := bts.buyerOrder(ctx, biz, strict.GetId(), strictVariant.GetId(), "buyer-i5", 2)
		_, err = biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: doomed.GetId(), Amount: usd(7, 0), Reference: "dep-2",
		})
		require.NoError(t, err)
		require.Equal(t, int64(98), bts.stockOf(ctx, biz, strictVariant))
		bts.backdateBalanceDue(ctx, svc, doomed.GetId())

		summary, err = biz.paymentBiz.ReconcilePayments(ctx, strict.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Overdue)
		cancelled, err := biz.orderBiz.GetOrder(ctx, doomed.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CANCELLED, cancelled.GetStatus())
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING, cancelled.GetPaymentStatus())
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, strictVariant))
		require.Equal(t, 1, biz.notifier.count("cancelled", doomed.GetId()))
		require.Equal(t, int64(7_000_000_000), biz.refunds.refunded(models.RefundReferencePrefix+doomed.GetId()),
			"only what was paid is refunded")

		biz.refunds.confirmAll()
		_, err = biz.paymentBiz.ReconcilePayments(ctx, strict.GetId(), 0)
		require.NoError(t, err)
		postings, err := bts.ledgerAt(ctx, svc, biz, 24*time.Hour).
			RunEndOfDayLedger(ctx, strict.GetId(), time.Now().UTC().Format("2006-01-02"))
		require.NoError(t, err)
		require.Equal(t, int64(7), postings[0].GetSales().GetUnits())
		require.Equal(t, int64(7), postings[0].GetRefunds().GetUnits(), "only what was paid is reversed")
		require.True(t, postings[0].GetSkipped(), "a sale refunded the same day nets to nothing")
	})
}

func (bts *BusinessTestSuite) TestInstalments_WebhookRetriesUntilDelivered() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i6", 2)

		biz.webhooks.setFailing(true)
		_, err := biz.paymentBiz.RecordOrderPayment(ctx, business.RecordedPayment{
			OrderID: order.GetId(), Amount: usd(7, 0), Reference: "dep-3",
		})
		require.NoError(t, err, "a failing webhook never fails the payment")

		page, err := biz.eventBiz.List(ctx, shop.GetId(), "", repository.Page{})
		require.NoError(t, err)
		require.NotEmpty(t, page.Events)
		for _, e := range page.Events {
			require.Equal(t, commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_PENDING, e.GetDelivery())
		}

		// Not due yet: nothing is retried.
		require.Equal(t, 0, biz.eventBiz.DeliverDue(ctx, time.Now()))

		biz.webhooks.setFailing(false)
		delivered := biz.eventBiz.DeliverDue(ctx, time.Now().Add(2*time.Minute))
		require.Equal(t, len(page.Events), delivered)

		page, err = biz.eventBiz.List(ctx, shop.GetId(), "", repository.Page{})
		require.NoError(t, err)
		for _, e := range page.Events {
			require.Equal(t, commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_DELIVERED, e.GetDelivery())
		}
	})
}

func (bts *BusinessTestSuite) TestWebhookSecret_SealedAtRestAndUsedToSign() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		shopRepo := repository.NewShopRepository(ctx, dbPool, svc.WorkManager())

		box, err := business.NewSecretBox(base64.StdEncoding.EncodeToString([]byte(strings.Repeat("k", 32))))
		require.NoError(t, err)
		shops := business.NewShopBusiness(ctx, shopRepo, nil, nil, box, "")
		shop, err := shops.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "Sealed " + util.RandomAlphaNumericString(6), Currency: "USD",
			WebhookUrl: "https://hooks.example/c", WebhookSecret: "s3cret",
		})
		require.NoError(t, err)
		require.True(t, shop.GetWebhookSecretSet())

		stored, err := shopRepo.GetByID(ctx, shop.GetId())
		require.NoError(t, err)
		require.NotContains(t, stored.WebhookSecret, "s3cret", "never stored in the clear")

		webhooks := &fakeWebhooks{}
		events := business.NewEventBusiness(
			repository.NewOrderEventRepository(ctx, dbPool, svc.WorkManager()), shopRepo,
			notifications.New(nil), webhooks, box, nil)
		event := &models.OrderEvent{ShopID: shop.GetId(), OrderID: "o1", Type: 1, Delivery: models.EventDeliveryPending}
		require.NoError(t, repository.NewOrderEventRepository(ctx, dbPool, svc.WorkManager()).Create(ctx, event))
		require.Equal(t, 1, events.DeliverDue(ctx, time.Now()))
		require.Equal(t, "s3cret", webhooks.delivered[0].Secret)
	})
}
