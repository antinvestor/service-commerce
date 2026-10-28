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
	"encoding/json"
	"fmt"
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

func TestStorefrontPage_PostsThroughItsPublicAddress(t *testing.T) {
	front := cornerShop()
	front.Shop.StorefrontUrl = "https://api.example/commerce/shop/corner"
	rec := serveStorefront(t, handlers.NewStorefrontHandler(&stubStorefront{front: front}),
		httptest.NewRequest(http.MethodGet, "/shop/corner", nil))

	require.Equal(t, http.StatusOK, rec.Code)
	require.Contains(t, rec.Body.String(), `action="https://api.example/commerce/shop/corner/checkout"`,
		"the gateway prefix the request path lost is kept")
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

func TestStorefrontCheckout_ShowsProblemsWithAFreshKey(t *testing.T) {
	stub := &stubStorefront{
		front: cornerShop(),
		checkErr: &business.StorefrontError{
			Code: connect.CodeInvalidArgument, Message: "Enter a valid email address or phone number.",
		},
	}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"nope"}, "qty.v-small": {"3"},
	}))

	require.Equal(t, http.StatusUnprocessableEntity, rec.Code)
	body := rec.Body.String()
	require.Contains(t, body, "Enter a valid email address or phone number.")
	require.Contains(t, body, `value="Jane"`)
	require.Contains(t, body, `value="3"`)
	require.NotContains(t, body, `value="k-12345678"`,
		"nothing was placed, so the corrected form goes through as a new order")
}

func TestStorefrontCheckout_KeepsTheKeyOnceAnOrderExists(t *testing.T) {
	stub := &stubStorefront{
		front: cornerShop(),
		checkErr: &business.StorefrontError{
			Code: connect.CodeUnavailable, Message: "We could not start your payment just now.", KeepKey: true,
		},
	}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"jane@example.com"}, "qty.v-small": {"1"},
	}))
	require.Equal(t, http.StatusServiceUnavailable, rec.Code)
	require.Contains(t, rec.Body.String(), `value="k-12345678"`, "a retry carries on with the same order")
}

func TestStorefrontCheckout_HidesInternalFailures(t *testing.T) {
	for _, err := range []error{
		connect.NewError(connect.CodeInternal, "db exploded"),
		// Only a StorefrontError's message reaches a shopper, whatever the
		// code says.
		connect.NewError(connect.CodeFailedPrecondition, "insufficient stock for variant v-small: available 3"),
	} {
		stub := &stubStorefront{front: cornerShop(), checkErr: err}
		rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
			"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"jane@example.com"}, "qty.v-small": {"1"},
		}))
		require.Equal(t, http.StatusServiceUnavailable, rec.Code)
		require.NotContains(t, rec.Body.String(), "exploded")
		require.NotContains(t, rec.Body.String(), "available 3")
	}
}

func TestStorefrontCheckout_TooManyIsTooManyRequests(t *testing.T) {
	stub := &stubStorefront{front: cornerShop(), checkErr: &business.StorefrontError{
		Code: connect.CodeResourceExhausted, Message: "Too many orders have been started just now.",
	}}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(stub), checkoutForm(url.Values{
		"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"jane@example.com"}, "qty.v-small": {"1"},
	}))
	require.Equal(t, http.StatusTooManyRequests, rec.Code)
	require.Contains(t, rec.Body.String(), "Too many orders have been started just now.")
}

func TestStorefrontCheckout_PassesTheTrustedVisitorAddress(t *testing.T) {
	stub := &stubStorefront{front: cornerShop(), target: "https://pay.example/c/cs_1"}
	h := handlers.NewStorefrontHandler(stub)
	form := url.Values{"key": {"k-12345678"}, "name": {"Jane"}, "contact": {"j@x.io"}, "qty.v-small": {"1"}}

	// Through the gateway: the client, then the Cloudflare hop Cloud Run
	// saw. Whatever the caller wrote before them is ignored.
	req := checkoutForm(form)
	req.Header.Set("X-Forwarded-For", "10.0.0.1, 203.0.113.9, 172.70.1.1")
	require.Equal(t, http.StatusSeeOther, serveStorefront(t, h, req).Code)

	// Straight to Cloud Run, the caller cannot pose as someone else.
	req = checkoutForm(form)
	req.Header.Set("X-Forwarded-For", "203.0.113.100, 198.51.100.7")
	req.Header.Set("Cf-Connecting-Ip", "203.0.113.100")
	require.Equal(t, http.StatusSeeOther, serveStorefront(t, h, req).Code)

	require.Len(t, stub.gotOrders, 2)
	require.Equal(t, "203.0.113.9", stub.gotOrders[0].Visitor)
	require.Equal(t, "198.51.100.7", stub.gotOrders[1].Visitor)
}

func TestStorefrontPage_LimitsOneVisitorsPageLoads(t *testing.T) {
	h := handlers.NewStorefrontHandler(&stubStorefront{front: cornerShop()})
	load := func(addr string) int {
		req := httptest.NewRequest(http.MethodGet, "/shop/corner", nil)
		req.Header.Set("X-Forwarded-For", addr)
		return serveStorefront(t, h, req).Code
	}
	codes := map[int]int{}
	for i := range 125 {
		// One subscriber's IPv6 /64 is one visitor.
		codes[load(fmt.Sprintf("2001:db8:1:2::%x", i+1))]++
	}
	require.Equal(t, 120, codes[http.StatusOK])
	require.Equal(t, 5, codes[http.StatusTooManyRequests])
	require.Equal(t, http.StatusOK, load("2001:db8:1:3::1"), "the next /64 is someone else")
}

func TestStorefrontCatalogue_ServesTheFormAsJSON(t *testing.T) {
	front := cornerShop()
	front.Shop.StorefrontUrl = "https://api.example/commerce/shop/corner"
	front.Items[0].Product.MediaIds = []string{"m-1"}
	rec := serveStorefront(t, handlers.NewStorefrontHandler(&stubStorefront{front: front}),
		httptest.NewRequest(http.MethodGet, "/shop/corner/catalogue", nil))

	require.Equal(t, http.StatusOK, rec.Code)
	require.Equal(t, "*", rec.Header().Get("Access-Control-Allow-Origin"), "any site may embed the shop")
	require.Equal(t, "application/json", rec.Header().Get("Content-Type"))
	var got struct {
		Shop struct {
			Name              string `json:"name"`
			Currency          string `json:"currency"`
			CheckoutURL       string `json:"checkout_url"`
			Instalments       bool   `json:"instalments"`
			MinDepositPercent int32  `json:"min_deposit_percent"`
		} `json:"shop"`
		Items []struct {
			Name     string   `json:"name"`
			MediaIDs []string `json:"media_ids"`
			Variants []struct {
				Field   string `json:"field"`
				Name    string `json:"name"`
				Amount  string `json:"amount"`
				InStock bool   `json:"in_stock"`
			} `json:"variants"`
		} `json:"items"`
	}
	require.NoError(t, json.Unmarshal(rec.Body.Bytes(), &got))
	require.Equal(t, "Corner <Shop>", got.Shop.Name, "JSON carries text as is; the widget escapes it")
	require.Equal(t, "https://api.example/commerce/shop/corner/checkout", got.Shop.CheckoutURL)
	require.True(t, got.Shop.Instalments)
	require.Equal(t, int32(30), got.Shop.MinDepositPercent)
	require.Len(t, got.Items, 1)
	require.Equal(t, []string{"m-1"}, got.Items[0].MediaIDs)
	require.Len(t, got.Items[0].Variants, 2)
	require.Equal(t, "qty.v-small", got.Items[0].Variants[0].Field)
	require.Equal(t, "150.00", got.Items[0].Variants[0].Amount)
	require.True(t, got.Items[0].Variants[0].InStock)
	require.False(t, got.Items[0].Variants[1].InStock)

	missing := serveStorefront(t, handlers.NewStorefrontHandler(&stubStorefront{
		err: connect.NewError(connect.CodeNotFound, "shop not found"),
	}), httptest.NewRequest(http.MethodGet, "/shop/nope/catalogue", nil))
	require.Equal(t, http.StatusNotFound, missing.Code)
}
