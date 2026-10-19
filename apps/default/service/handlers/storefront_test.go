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
	"strings"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/handlers"
)

type stubStorefront struct {
	front     *business.Storefront
	err       error
	target    string
	checkErr  error
	gotSlug   string
	gotOrders []business.StorefrontOrder
}

func (s *stubStorefront) Storefront(_ context.Context, slug string) (*business.Storefront, error) {
	s.gotSlug = slug
	return s.front, s.err
}

func (s *stubStorefront) Checkout(_ context.Context, slug string, order business.StorefrontOrder) (string, error) {
	s.gotSlug = slug
	s.gotOrders = append(s.gotOrders, order)
	return s.target, s.checkErr
}

func cornerShop() *business.Storefront {
	return &business.Storefront{
		Shop: &commercev1.Shop{
			Name: "Corner <Shop>", Slug: "corner", Currency: "KES",
			PaymentPolicy: &commercev1.PaymentPolicy{AllowInstalments: true, MinDepositPercent: 30},
		},
		Items: []business.StorefrontItem{{
			Product: &commercev1.Product{Name: "Tea"},
			Variants: []*commercev1.ProductVariant{
				{Id: "v-small", Name: "Small", StockQuantity: 5,
					Price: &commonv1.Money{CurrencyCode: "KES", Units: 150}},
				{Id: "v-large", Name: "Large", Price: &commonv1.Money{CurrencyCode: "KES", Units: 250}},
			},
		}},
	}
}

func serveStorefront(t *testing.T, h *handlers.StorefrontHandler, req *http.Request) *httptest.ResponseRecorder {
	t.Helper()
	mux := http.NewServeMux()
	h.Mount(mux)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	return rec
}

func checkoutForm(values url.Values) *http.Request {
	req := httptest.NewRequest(http.MethodPost, "/shop/corner/checkout", strings.NewReader(values.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	return req
}

func TestStorefrontPage_ListsWhatIsForSale(t *testing.T) {
	stub := &stubStorefront{front: cornerShop()}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub),
		httptest.NewRequest(http.MethodGet, "/shop/corner?payment=paid", nil))

	require.Equal(t, http.StatusOK, rec.Code)
	require.Equal(t, "corner", stub.gotSlug)
	body := rec.Body.String()
	require.Contains(t, body, "Corner &lt;Shop&gt;", "shop text is escaped")
	require.Contains(t, body, `name="qty.v-small"`)
	require.Contains(t, body, "KES 150.00")
	require.Contains(t, body, "Out of stock", "the large size has none left")
	require.NotContains(t, body, `name="qty.v-large"`)
	require.Contains(t, body, `name="deposit"`, "the shop takes instalments")
	require.Contains(t, body, "at least 30%")
	require.Contains(t, body, "Payment received")
	require.Contains(t, body, `action="/shop/corner/checkout"`)
	require.Equal(t, "no-store", rec.Header().Get("Cache-Control"))
	require.Contains(t, rec.Header().Get("Content-Security-Policy"), "frame-ancestors 'none'")
}

func TestStorefrontPage_UnknownShop(t *testing.T) {
	stub := &stubStorefront{err: connect.NewError(connect.CodeNotFound, "shop not found")}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub),
		httptest.NewRequest(http.MethodGet, "/shop/nope", nil))
	require.Equal(t, http.StatusNotFound, rec.Code)
	require.Contains(t, rec.Body.String(), "Shop not found")
}

func TestStorefrontCheckout_RedirectsToPayment(t *testing.T) {
	stub := &stubStorefront{front: cornerShop(), target: "https://pay.example/c/cs_1"}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"jane@example.com"}, "deposit": {"100"},
		"qty.v-small": {"2"}, "qty.v-large": {""}, "other": {"ignored"},
	}))

	require.Equal(t, http.StatusSeeOther, rec.Code)
	require.Equal(t, "https://pay.example/c/cs_1", rec.Header().Get("Location"))
	require.Len(t, stub.gotOrders, 1)
	got := stub.gotOrders[0]
	require.Equal(t, map[string]int64{"v-small": 2}, got.Quantities)
	require.Equal(t, "Jane", got.Name)
	require.Equal(t, "100", got.Deposit)
	require.Equal(t, "k-12345678", got.Key)
}

func TestStorefrontCheckout_ShowsProblemsAndKeepsTheForm(t *testing.T) {
	stub := &stubStorefront{
		front:    cornerShop(),
		checkErr: connect.NewError(connect.CodeInvalidArgument, "enter a valid email address or phone number"),
	}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"nope"}, "qty.v-small": {"3"},
	}))

	require.Equal(t, http.StatusUnprocessableEntity, rec.Code)
	body := rec.Body.String()
	require.Contains(t, body, "Enter a valid email address or phone number.")
	require.Contains(t, body, `value="Jane"`)
	require.Contains(t, body, `value="k-12345678"`, "the same key, so a fixed resubmit places one order")
	require.Contains(t, body, `value="3"`)
}

func TestStorefrontCheckout_HidesInternalFailures(t *testing.T) {
	stub := &stubStorefront{front: cornerShop(), checkErr: connect.NewError(connect.CodeInternal, "db exploded")}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"jane@example.com"}, "qty.v-small": {"1"},
	}))
	require.Equal(t, http.StatusServiceUnavailable, rec.Code)
	require.NotContains(t, rec.Body.String(), "exploded")
}

func TestStorefrontCheckout_LimitsOneVisitor(t *testing.T) {
	stub := &stubStorefront{front: cornerShop(), target: "https://pay.example/c/cs_1"}
	h := handlers.NewStorefrontHandler(stub)
	form := url.Values{"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"j@x.io"}, "qty.v-small": {"1"}}

	codes := map[int]int{}
	for range 12 {
		req := checkoutForm(form)
		req.Header.Set("Cf-Connecting-Ip", "203.0.113.9")
		codes[serveStorefront(t, h, req).Code]++
	}
	require.Equal(t, 10, codes[http.StatusSeeOther])
	require.Equal(t, 2, codes[http.StatusTooManyRequests])

	other := checkoutForm(form)
	other.Header.Set("Cf-Connecting-Ip", "203.0.113.10")
	require.Equal(t, http.StatusSeeOther, serveStorefront(t, h, other).Code, "other visitors are unaffected")
}
