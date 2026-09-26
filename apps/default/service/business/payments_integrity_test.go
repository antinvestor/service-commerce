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
	"errors"
	"net/url"
	"strings"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

func (bts *BusinessTestSuite) TestCheckoutOrder_FailedAttemptKeepsSession() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-f", 1)

		first, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		biz.checkout.attempt(first.GetPaymentSessionRef(), "prompt-1")
		biz.checkout.fail(first.GetPaymentSessionRef())

		// The hosted page lets the buyer retry a declined attempt, so the
		// same session is handed back rather than a second one.
		again, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.Equal(t, first.GetPaymentSessionRef(), again.GetPaymentSessionRef())
		require.Equal(t, 1, biz.checkout.createdSessions())
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_UnreadableSessionIsNotReplaced() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-u", 1)

		first, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)

		biz.checkout.setGetErr(connect.NewError(connect.CodeUnavailable, errors.New("checkout down")))
		_, err = biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
		require.Equal(t, 1, biz.checkout.createdSessions())

		biz.checkout.setGetErr(nil)
		again, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.Equal(t, first.GetPaymentSessionRef(), again.GetPaymentSessionRef())
	})
}

func (bts *BusinessTestSuite) TestPayment_SupersededSessionStillSettles() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-s", 1)

		first, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		biz.checkout.expire(first.GetPaymentSessionRef())

		second, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		require.NotEqual(t, first.GetPaymentSessionRef(), second.GetPaymentSessionRef())

		// The buyer pays the first link (checkout recovers an expired session
		// whose prompt later succeeds). Commerce must still see it.
		biz.checkout.complete(first.GetPaymentSessionRef(), "pay-old-link")

		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Paid)

		paid, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, paid.GetPaymentStatus())
		require.Equal(t, "pay-old-link", paid.GetPaymentId())
	})
}

func (bts *BusinessTestSuite) TestPayment_AmountMismatchIsNotSettled() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-m", 2)

		checked, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		ref := checked.GetPaymentSessionRef()

		cases := []*commonv1.Money{
			{CurrencyCode: "USD", Units: 20, Nanos: 990_000_000},
			{CurrencyCode: "KES", Units: 21},
			nil,
		}
		for _, charged := range cases {
			biz.checkout.setAmount(ref, charged)
			biz.checkout.complete(ref, "pay-wrong")
			_, err = biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
			require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err), "charged %v", charged)

			summary, recErr := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
			require.NoError(t, recErr)
			require.Zero(t, summary.Paid)
		}

		// The exact total, to the cent, settles.
		biz.checkout.setAmount(ref, &commonv1.Money{CurrencyCode: "usd", Units: 21})
		paid, err := biz.paymentBiz.ConfirmOrderPayment(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, paid.GetPaymentStatus())
	})
}

func (bts *BusinessTestSuite) TestReconcile_InFlightPromptDelaysExpiry() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-i", 5)

		checked, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		biz.checkout.attempt(checked.GetPaymentSessionRef(), "prompt-slow")

		// Past the window but inside the grace period: the reservation holds.
		bts.backdatePaymentDue(ctx, svc, order.GetId(), -10*time.Minute)
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Zero(t, summary.Expired)
		require.Equal(t, int64(95), bts.stockOf(ctx, biz, variant))

		// Past the grace period: released.
		bts.backdatePaymentDue(ctx, svc, order.GetId(), -2*time.Hour)
		summary, err = biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Expired)
		require.Equal(t, int64(100), bts.stockOf(ctx, biz, variant))
	})
}

func (bts *BusinessTestSuite) TestReconcile_UnreadableSessionNeverExpires() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-x", 1)

		_, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		bts.backdatePaymentDue(ctx, svc, order.GetId(), -3*time.Hour)

		biz.checkout.setGetErr(connect.NewError(connect.CodeUnavailable, errors.New("checkout down")))
		summary, err := biz.paymentBiz.ReconcilePayments(ctx, shop.GetId(), 0)
		require.NoError(t, err)
		require.Equal(t, int32(1), summary.Failed)
		require.Zero(t, summary.Expired)

		reloaded, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT, reloaded.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestCancelOrder_PaidAtCheckoutIsNotLost() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-c", 1)

		checked, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		biz.checkout.complete(checked.GetPaymentSessionRef(), "pay-race")

		_, err = biz.paymentBiz.CancelOrder(ctx, order.GetId(), "too slow", false)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		reloaded, err := biz.orderBiz.GetOrder(ctx, order.GetId())
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, reloaded.GetPaymentStatus())
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_CONFIRMED, reloaded.GetStatus())
	})
}

func (bts *BusinessTestSuite) TestPaymentReturn_VerifiesAndForwards() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-r", 1)

		checked, err := biz.returnPaymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
			OrderId:   order.GetId(),
			ReturnUrl: "https://store.example/thanks/{order_id}",
		})
		require.NoError(t, err)
		ref := checked.GetPaymentSessionRef()

		session := biz.checkout.session(ref)
		returnURL, err := url.Parse(session.GetReturnUrl())
		require.NoError(t, err)
		require.Equal(t, "https://api.example/commerce/payments/return", strings.Split(returnURL.String(), "?")[0])
		require.Equal(t, order.GetId(), returnURL.Query().Get("order"))
		require.Equal(t, "https://store.example/thanks/"+order.GetId(), session.GetMetadata()["return_to"])

		// A ref that is not one of the order's sessions reveals nothing.
		_, err = biz.returnPaymentBiz.HandlePaymentReturn(ctx, order.GetId(), "not-the-session-ref")
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		// Returning before paying leaves the order pending.
		pending, err := biz.returnPaymentBiz.HandlePaymentReturn(ctx, order.GetId(), ref)
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PENDING, pending.Order.GetPaymentStatus())

		biz.checkout.complete(ref, "pay-return")
		result, err := biz.returnPaymentBiz.HandlePaymentReturn(ctx, order.GetId(), ref)
		require.NoError(t, err)
		require.Equal(t, commercev1.PaymentStatus_PAYMENT_STATUS_PAID, result.Order.GetPaymentStatus())
		require.Equal(t, "https://store.example/thanks/"+order.GetId(), result.RedirectURL)
		require.Equal(t, 1, biz.notifier.count("paid", order.GetId()))
	})
}

func (bts *BusinessTestSuite) TestCheckoutOrder_LongShopNameFitsSessionLimits() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: strings.Repeat("Duka ", 50),
			Slug: "long-name-shop",
		})
		require.NoError(t, err)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		order := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-l", 1)

		checked, err := biz.paymentBiz.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{OrderId: order.GetId()})
		require.NoError(t, err)
		session := biz.checkout.session(checked.GetPaymentSessionRef())
		require.LessOrEqual(t, len([]rune(session.GetName())), 100)
	})
}

// --- order pricing ---

func (bts *BusinessTestSuite) TestOrderPricing_UsesResolvedPrice() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		product, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId()) // catalog 10.50 USD

		// A negotiated price for one customer.
		_, err := biz.pricingBiz.SaveCustomerPriceOverride(ctx, &commercev1.CustomerPriceOverrideSaveRequest{
			CustomerId:       "vip-buyer",
			ProductVariantId: variant.GetId(),
			UnitPrice:        &commonv1.Money{CurrencyCode: "USD", Units: 8},
		})
		require.NoError(t, err)

		vip := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "vip-buyer", 2)
		require.Equal(t, int64(8), vip.GetLines()[0].GetUnitPrice().GetUnits())
		require.Equal(t, int64(16), vip.GetTotal().GetUnits())
		require.Zero(t, vip.GetTotal().GetNanos())

		// Everyone else pays catalog.
		regular := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "walk-in", 2)
		require.Equal(t, int64(21), regular.GetTotal().GetUnits())

		// 15% off this product: 10.50 * 0.85 = 8.925, charged as 8.93.
		conditions, err := structpb.NewStruct(map[string]any{"product_ids": []any{product.GetId()}})
		require.NoError(t, err)
		_, err = biz.pricingBiz.SaveDiscountRule(ctx, &commercev1.DiscountRuleSaveRequest{
			ShopId:       shop.GetId(),
			Name:         "Product promo",
			DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
			Value:        15,
			AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM,
			Conditions:   conditions,
		})
		require.NoError(t, err)

		promo := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "walk-in-2", 2)
		require.Equal(t, int64(8), promo.GetLines()[0].GetUnitPrice().GetUnits())
		require.Equal(t, int32(930_000_000), promo.GetLines()[0].GetUnitPrice().GetNanos())
		require.Equal(t, int64(17), promo.GetTotal().GetUnits())
		require.Equal(t, int32(860_000_000), promo.GetTotal().GetNanos())
	})
}

func (bts *BusinessTestSuite) TestOrderPricing_SkipsRulesItCannotHonour() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		unknownCondition, err := structpb.NewStruct(map[string]any{"customer_segment": "gold"})
		require.NoError(t, err)
		otherVariant, err := structpb.NewStruct(map[string]any{"variant_ids": []any{"some-other-variant"}})
		require.NoError(t, err)
		bulkOnly, err := structpb.NewStruct(map[string]any{"min_quantity": 10})
		require.NoError(t, err)

		rules := []*commercev1.DiscountRuleSaveRequest{
			{Name: "Needs approval", RequiresApproval: true, Value: 50,
				DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
				AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM},
			{Name: "Unknown condition", Conditions: unknownCondition, Value: 50,
				DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
				AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM},
			{Name: "Other variant", Conditions: otherVariant, Value: 50,
				DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
				AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM},
			{Name: "Fixed off the order", Value: 5,
				DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT,
				AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_ORDER},
			{Name: "Bulk only", Conditions: bulkOnly, Value: 10,
				DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
				AppliesTo:    commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM},
		}
		for _, rule := range rules {
			rule.ShopId = shop.GetId()
			_, err = biz.pricingBiz.SaveDiscountRule(ctx, rule)
			require.NoError(t, err, rule.GetName())
		}

		small := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-small", 2)
		require.Equal(t, int64(21), small.GetTotal().GetUnits())
		require.Zero(t, small.GetTotal().GetNanos())

		// Only the bulk rule applies at 10 units: 10.50 * 0.9 = 9.45.
		bulk := bts.buyerOrder(ctx, biz, shop.GetId(), variant.GetId(), "buyer-bulk", 10)
		require.Equal(t, int64(94), bulk.GetTotal().GetUnits())
		require.Equal(t, int32(500_000_000), bulk.GetTotal().GetNanos())
	})
}

func (bts *BusinessTestSuite) TestShop_RejectsValuesCheckoutWouldRefuse() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		for _, bad := range []string{"ftp://store.example/{order_id}", "/orders/{order_id}", "not a url"} {
			_, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
				Name: "Return URL shop", Slug: "return-url-shop", CheckoutReturnUrl: bad,
			})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), bad)
		}

		_, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: strings.Repeat("x", 256), Slug: "too-long-name",
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name: "Return URL shop", Slug: "return-url-shop",
			CheckoutReturnUrl: "https://store.example/orders/{order_id}",
		})
		require.NoError(t, err)

		_, err = biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id: shop.GetId(), CheckoutReturnUrl: "javascript:alert(1)",
		})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}
