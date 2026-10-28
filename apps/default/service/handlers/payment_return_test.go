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

package handlers_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/handlers"
)

type stubPayments struct {
	business.PaymentBusiness
	result           *business.PaymentReturn
	err              error
	gotOrder, gotRef string
}

func (s *stubPayments) HandlePaymentReturn(_ context.Context, orderID, ref string) (*business.PaymentReturn, error) {
	s.gotOrder, s.gotRef = orderID, ref
	return s.result, s.err
}

func paidOrder() *commercev1.Order {
	return &commercev1.Order{
		Id:            "order-1",
		OrderNumber:   "0000042",
		Status:        commercev1.OrderStatus_ORDER_STATUS_CONFIRMED,
		PaymentStatus: commercev1.PaymentStatus_PAYMENT_STATUS_PAID,
		Total:         &commonv1.Money{CurrencyCode: "KES", Units: 1250, Nanos: 500_000_000},
	}
}

func serveReturn(t *testing.T, payments business.PaymentBusiness, method, target string) *httptest.ResponseRecorder {
	t.Helper()
	rec := httptest.NewRecorder()
	handlers.NewPaymentReturnHandler(payments).ServeHTTP(rec, httptest.NewRequest(method, target, nil))
	return rec
}

func TestPaymentReturn_RedirectsToStorefrontWithOutcome(t *testing.T) {
	stub := &stubPayments{result: &business.PaymentReturn{
		Order:       paidOrder(),
		RedirectURL: "https://store.example/thanks/order-1?ref=abc",
	}}
	rec := serveReturn(t, stub, http.MethodGet,
		"/payments/return?order=order-1&session=Ab12Cd34Ef56&status=completed")

	require.Equal(t, http.StatusSeeOther, rec.Code)
	require.Equal(t, "order-1", stub.gotOrder)
	require.Equal(t, "Ab12Cd34Ef56", stub.gotRef)
	location, err := url.Parse(rec.Header().Get("Location"))
	require.NoError(t, err)
	require.Equal(t, "store.example", location.Host)
	require.Equal(t, "paid", location.Query().Get("payment"))
	require.Equal(t, "order-1", location.Query().Get("order_id"))
	require.Equal(t, "abc", location.Query().Get("ref"))
	require.Equal(t, "no-referrer", rec.Header().Get("Referrer-Policy"))
	require.Equal(t, "no-store", rec.Header().Get("Cache-Control"))
}

func TestPaymentReturn_OnlyRedirectsOverHTTPS(t *testing.T) {
	for _, target := range []string{"http://store.example/thanks", "javascript:alert(1)", "https://u@store.example/"} {
		stub := &stubPayments{result: &business.PaymentReturn{Order: paidOrder(), RedirectURL: target}}
		rec := serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
		require.Equal(t, http.StatusOK, rec.Code, target)
		require.Empty(t, rec.Header().Get("Location"), target)
		require.Contains(t, rec.Body.String(), "Payment received", target)
	}
}

func TestPaymentReturn_RendersStatusWithoutStorefront(t *testing.T) {
	stub := &stubPayments{result: &business.PaymentReturn{Order: paidOrder()}}
	rec := serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")

	require.Equal(t, http.StatusOK, rec.Code)
	body := rec.Body.String()
	require.Contains(t, body, "Payment received")
	require.Contains(t, body, "KES 1250.50")
	require.NotContains(t, body, `http-equiv="refresh"`)

	pending := paidOrder()
	pending.PaymentStatus = commercev1.PaymentStatus_PAYMENT_STATUS_PENDING
	pending.Status = commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT
	stub.result = &business.PaymentReturn{Order: pending}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Contains(t, rec.Body.String(), "Confirming your payment")
	require.Contains(t, rec.Body.String(), `http-equiv="refresh"`)

	// A deposit is received in full even though the order is not paid off;
	// an earlier instalment does not vouch for this one.
	deposit := paidOrder()
	deposit.PaymentStatus = commercev1.PaymentStatus_PAYMENT_STATUS_PARTIALLY_PAID
	deposit.Balance = &commonv1.Money{CurrencyCode: "KES", Units: 850}
	deposit.Payments = []*commercev1.OrderPayment{{Reference: "Earlier00001"}}
	stub.result = &business.PaymentReturn{Order: deposit}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Contains(t, rec.Body.String(), "Confirming your payment")

	// A shop's recorded receipt that happens to read like the ref does not
	// count either: only the session's own checkout payment does.
	deposit.Payments = append(deposit.Payments, &commercev1.OrderPayment{
		Reference: "Ab12Cd34Ef56", Source: commercev1.OrderPaymentSource_ORDER_PAYMENT_SOURCE_RECORDED,
	})
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Contains(t, rec.Body.String(), "Confirming your payment")

	deposit.Payments = append(deposit.Payments, &commercev1.OrderPayment{
		Reference: "Ab12Cd34Ef56", Source: commercev1.OrderPaymentSource_ORDER_PAYMENT_SOURCE_CHECKOUT,
	})
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	body = rec.Body.String()
	require.Contains(t, body, "Payment received")
	require.Contains(t, body, "KES 850.00 remains to be paid")
	require.NotContains(t, body, `http-equiv="refresh"`)

	// The buyer cancelled on the payment page: say so instead of waiting.
	pending.PaymentStatus = commercev1.PaymentStatus_PAYMENT_STATUS_PENDING
	stub.result = &business.PaymentReturn{Order: pending, Unpaid: true}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	body = rec.Body.String()
	require.Contains(t, body, "Payment not completed")
	require.NotContains(t, body, `http-equiv="refresh"`)

	stub.result = &business.PaymentReturn{Order: pending, Unpaid: true, RedirectURL: "https://store.example/shop/x"}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	location, err := url.Parse(rec.Header().Get("Location"))
	require.NoError(t, err)
	require.Equal(t, "unpaid", location.Query().Get("payment"))
}

func TestPaymentReturn_RejectsBadInput(t *testing.T) {
	stub := &stubPayments{err: connect.NewError(connect.CodeNotFound, "order not found")}

	rec := serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=wrong-ref-123")
	require.Equal(t, http.StatusNotFound, rec.Code)

	rec = serveReturn(t, &stubPayments{}, http.MethodGet, "/payments/return?order=<script>&session=x")
	require.Equal(t, http.StatusNotFound, rec.Code)
	require.NotContains(t, rec.Body.String(), "<script>")

	rec = serveReturn(t, &stubPayments{}, http.MethodPost, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Equal(t, http.StatusMethodNotAllowed, rec.Code)

	// A storefront URL that is not absolute http(s) is never followed.
	stub = &stubPayments{result: &business.PaymentReturn{Order: paidOrder(), RedirectURL: "javascript:alert(1)"}}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Equal(t, http.StatusOK, rec.Code)

	stub = &stubPayments{err: connect.NewError(connect.CodeUnavailable, "checkout down")}
	rec = serveReturn(t, stub, http.MethodGet, "/payments/return?order=order-1&session=Ab12Cd34Ef56")
	require.Equal(t, http.StatusServiceUnavailable, rec.Code)
	require.Contains(t, rec.Body.String(), `http-equiv="refresh"`)
}
