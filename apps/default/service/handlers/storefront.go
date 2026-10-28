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

package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"html/template"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strconv"
	"strings"
	"time"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/cache"
	"github.com/pitabwire/frame/v3/ratelimiter"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
)

const (
	// storefrontFormLimit caps a checkout form body.
	storefrontFormLimit = 64 << 10
	// storefrontQuantityField prefixes each variant's quantity input.
	storefrontQuantityField = "qty."

	// A visitor may load this many pages a minute from one instance.
	// Pages only read, and cost a fixed few queries; the shared limits are
	// on checkout.
	storefrontPagesPerMinute = 120

	// checkoutSuffix follows a storefront's address to reach its checkout;
	// catalogueSuffix reaches the same catalogue as JSON, for embedding.
	checkoutSuffix  = "/checkout"
	catalogueSuffix = "/catalogue"

	// jsonError carries a catalogue failure.
	jsonError = "error"
)

// MountStorefront serves shops' public pages on mux: the catalogue at
// /shop/{slug} and guest checkout at /shop/{slug}/checkout.
func (cs *CommerceServer) MountStorefront(mux *http.ServeMux) {
	NewStorefrontHandler(cs.storefront).Mount(mux)
}

// StorefrontHandler renders storefront pages. Pages carry no credentials:
// the shop's own opt-in is what makes them public.
type StorefrontHandler struct {
	storefront business.StorefrontBusiness
	pages      *ratelimiter.WindowLimiter
}

// NewStorefrontHandler builds the storefront pages over storefront.
func NewStorefrontHandler(storefront business.StorefrontBusiness) *StorefrontHandler {
	// An in-memory cache always supports per-key expiry, so this cannot
	// fail.
	pages, _ := ratelimiter.NewWindowLimiter(cache.NewInMemoryCache(), &ratelimiter.WindowConfig{
		WindowDuration: time.Minute,
		MaxPerWindow:   storefrontPagesPerMinute,
		KeyPrefix:      "storefront-page",
	})
	return &StorefrontHandler{storefront: storefront, pages: pages}
}

// Mount registers the storefront routes on mux.
func (h *StorefrontHandler) Mount(mux *http.ServeMux) {
	mux.HandleFunc("GET "+business.StorefrontPath+"{slug}", h.page)
	mux.HandleFunc("POST "+business.StorefrontPath+"{slug}"+checkoutSuffix, h.checkout)
	mux.HandleFunc("GET "+business.StorefrontPath+"{slug}"+catalogueSuffix, h.catalogue)
}

// pageAllowed reports whether r's visitor may load another page now.
func (h *StorefrontHandler) pageAllowed(r *http.Request) bool {
	return h.pages.Allow(r.Context(), business.VisitorGroup(visitorAddress(r)))
}

func (h *StorefrontHandler) page(w http.ResponseWriter, r *http.Request) {
	if !h.pageAllowed(r) {
		renderReturnPage(w, http.StatusTooManyRequests, returnPage{Title: "Please wait",
			Message: "Too many pages have been loaded from your connection. Please wait a minute and try again."})
		return
	}
	view := storefrontView{Key: util.IDString()}
	switch r.URL.Query().Get("payment") {
	case returnStatePaid:
		view.Notice = "Payment received. Thank you, the shop has your order and will be in touch."
	case returnStatePartPaid:
		view.Notice = "Payment received. Thank you, the shop has your order and will be in touch about the balance."
	case returnStateUnpaid:
		view.Notice = "Your payment did not go through and nothing was charged. You can try again below."
	case returnStatePending:
		view.Notice = "We are still confirming your payment. You will hear from the shop once it is through."
	case returnStateCancelled:
		view.Notice = "That order was cancelled. You can place a new one below."
	}
	h.render(r.Context(), w, r.PathValue("slug"), http.StatusOK, view)
}

func (h *StorefrontHandler) checkout(w http.ResponseWriter, r *http.Request) {
	slug := r.PathValue("slug")
	r.Body = http.MaxBytesReader(w, r.Body, storefrontFormLimit)
	if err := r.ParseForm(); err != nil {
		h.render(r.Context(), w, slug, http.StatusBadRequest, storefrontView{
			Key: util.IDString(), Error: "We could not read that form. Please try again.",
		})
		return
	}

	order := business.StorefrontOrder{
		Name:       r.PostForm.Get("name"),
		Contact:    r.PostForm.Get("contact"),
		Deposit:    r.PostForm.Get("deposit"),
		Key:        r.PostForm.Get("key"),
		Quantities: map[string]int64{},
		Visitor:    visitorAddress(r),
	}
	for field, values := range r.PostForm {
		variantID, ok := strings.CutPrefix(field, storefrontQuantityField)
		if !ok || len(values) == 0 || strings.TrimSpace(values[0]) == "" {
			continue
		}
		quantity, err := strconv.ParseInt(strings.TrimSpace(values[0]), 10, 64)
		if err != nil {
			quantity = -1 // reported as an invalid quantity
		}
		order.Quantities[variantID] = quantity
	}
	// Echo what was typed if the page has to be shown again.
	view := storefrontView{
		Key: order.Key, Name: order.Name, Contact: order.Contact, Deposit: order.Deposit,
		Quantities: order.Quantities,
	}

	target, err := h.storefront.Checkout(r.Context(), slug, order)
	if err != nil {
		failure := storefrontFailure(r.Context(), slug, err)
		status := statusOf(failure.Code)
		if status == http.StatusNotFound {
			renderReturnPage(w, status, returnPage{Title: "Shop not found", Message: failure.Message})
			return
		}
		view.Error = failure.Message
		// Nothing was placed unless the failure says so: a fresh key lets
		// the corrected form through as a new order.
		if !failure.KeepKey {
			view.Key = util.IDString()
		}
		h.render(r.Context(), w, slug, status, view)
		return
	}
	// The target is the https checkout page the payment service issued for
	// this order, never anything from the request.
	w.Header().Set("Location", target)
	w.WriteHeader(http.StatusSeeOther)
}

// storefrontFailure is the shopper-facing form of a checkout error. Only a
// business.StorefrontError's message is ever shown; anything else is a
// failure on our side and gets fixed text.
func storefrontFailure(ctx context.Context, slug string, err error) *business.StorefrontError {
	var failure *business.StorefrontError
	if errors.As(err, &failure) {
		return failure
	}
	util.Log(ctx).WithError(err).WithField("slug", slug).Warn("storefront checkout failed")
	return &business.StorefrontError{
		Code:    connect.CodeUnavailable,
		Message: "We could not start your payment just now. Please try again.",
		KeepKey: true,
	}
}

func statusOf(code connect.Code) int {
	switch code { //nolint:exhaustive // every other code is a failure on our side
	case connect.CodeNotFound:
		return http.StatusNotFound
	case connect.CodeInvalidArgument, connect.CodeFailedPrecondition, connect.CodeAlreadyExists:
		return http.StatusUnprocessableEntity
	case connect.CodeResourceExhausted:
		return http.StatusTooManyRequests
	default:
		return http.StatusServiceUnavailable
	}
}

func (h *StorefrontHandler) render(
	ctx context.Context,
	w http.ResponseWriter,
	slug string,
	status int,
	view storefrontView,
) {
	front, err := h.storefront.Storefront(ctx, slug)
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			renderReturnPage(w, http.StatusNotFound, returnPage{Title: "Shop not found",
				Message: "This shop is not available."})
			return
		}
		util.Log(ctx).WithError(err).WithField("slug", slug).Warn("storefront page failed")
		renderReturnPage(w, http.StatusServiceUnavailable, returnPage{Title: "Shop unavailable",
			Message: "This shop could not be loaded just now. Please try again shortly."})
		return
	}
	view.fill(front)

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("Referrer-Policy", "no-referrer")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("X-Frame-Options", "DENY")
	w.Header().Set("Content-Security-Policy",
		"default-src 'none'; style-src 'unsafe-inline'; frame-ancestors 'none'; base-uri 'none'")
	w.WriteHeader(status)
	_ = storefrontTemplate.Execute(w, view)
}

// catalogue serves what the page shows as JSON, for a shop's own site to
// embed (web/ai-shop-module). It carries no credentials and needs none:
// buying goes through the same public checkout form as the page.
func (h *StorefrontHandler) catalogue(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("Content-Type", "application/json")
	if !h.pageAllowed(r) {
		writeJSON(
			w,
			http.StatusTooManyRequests,
			map[string]string{jsonError: "too many requests; try again in a minute"},
		)
		return
	}
	slug := r.PathValue("slug")
	front, err := h.storefront.Storefront(r.Context(), slug)
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			writeJSON(w, http.StatusNotFound, map[string]string{jsonError: "shop not found"})
			return
		}
		util.Log(r.Context()).WithError(err).WithField("slug", slug).Warn("storefront catalogue failed")
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{jsonError: "shop unavailable"})
		return
	}
	var view storefrontView
	view.fill(front)
	w.Header().Set("Cache-Control", "public, max-age=30")
	writeJSON(w, http.StatusOK, catalogueOf(front, view))
}

type catalogueJSON struct {
	Shop  catalogueShop   `json:"shop"`
	Items []catalogueItem `json:"items"`
}

type catalogueShop struct {
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
	Currency    string `json:"currency"`
	// CheckoutURL is where the order form is posted; relative to the
	// commerce address when the storefront's public address is not set.
	CheckoutURL       string `json:"checkout_url"`
	Instalments       bool   `json:"instalments"`
	MinDepositPercent int32  `json:"min_deposit_percent,omitempty"`
}

type catalogueItem struct {
	Name        string             `json:"name"`
	Description string             `json:"description,omitempty"`
	MediaIDs    []string           `json:"media_ids,omitempty"`
	Variants    []catalogueVariant `json:"variants"`
}

type catalogueVariant struct {
	// Field is the form field that carries this variant's quantity.
	Field    string `json:"field"`
	Name     string `json:"name"`
	Currency string `json:"currency"`
	Amount   string `json:"amount"`
	InStock  bool   `json:"in_stock"`
}

func catalogueOf(front *business.Storefront, view storefrontView) catalogueJSON {
	out := catalogueJSON{
		Shop: catalogueShop{
			Name: view.Shop, Description: view.Description, Currency: view.Currency,
			CheckoutURL: view.Action, Instalments: view.Instalments, MinDepositPercent: view.MinDeposit,
		},
		Items: make([]catalogueItem, 0, len(front.Items)),
	}
	for _, item := range front.Items {
		ci := catalogueItem{
			Name: item.Product.GetName(), Description: item.Product.GetDescription(),
			MediaIDs: item.Product.GetMediaIds(),
		}
		for _, variant := range item.Variants {
			v := variantView(variant, len(item.Variants), nil)
			price := variant.GetPrice()
			ci.Variants = append(ci.Variants, catalogueVariant{
				Field: v.Field, Name: v.Name, Currency: price.GetCurrencyCode(),
				Amount: formatCents(price.GetUnits(), price.GetNanos()), InStock: v.InStock,
			})
		}
		out.Items = append(out.Items, ci)
	}
	return out
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

type storefrontView struct {
	Shop        string
	Description string
	Action      string
	Items       []storefrontItemView
	// Instalments shows the pay-now field; MinDeposit is its floor in
	// percent of the order.
	Instalments bool
	MinDeposit  int32
	Currency    string

	Notice string
	Error  string

	Key        string
	Name       string
	Contact    string
	Deposit    string
	Quantities map[string]int64
}

type storefrontItemView struct {
	Name        string
	Description string
	Variants    []storefrontVariantView
}

type storefrontVariantView struct {
	Field    string
	Name     string
	Price    string
	InStock  bool
	Quantity int64
}

func (v *storefrontView) fill(front *business.Storefront) {
	shop := front.Shop
	v.Shop = shop.GetName()
	v.Description = shop.GetDescription()
	v.Currency = shop.GetCurrency()
	// The page's public address carries any gateway prefix the path here
	// lacks, so post back through it when it is known.
	v.Action = business.StorefrontPath + url.PathEscape(shop.GetSlug()) + checkoutSuffix
	if public := shop.GetStorefrontUrl(); public != "" {
		v.Action = public + checkoutSuffix
	}
	if policy := shop.GetPaymentPolicy(); policy.GetAllowInstalments() {
		v.Instalments = true
		v.MinDeposit = policy.GetMinDepositPercent()
	}
	for _, item := range front.Items {
		iv := storefrontItemView{Name: item.Product.GetName(), Description: item.Product.GetDescription()}
		for _, variant := range item.Variants {
			iv.Variants = append(iv.Variants, variantView(variant, len(item.Variants), v.Quantities))
		}
		v.Items = append(v.Items, iv)
	}
}

func variantView(variant *commercev1.ProductVariant, siblings int, typed map[string]int64) storefrontVariantView {
	name := variant.GetName()
	if siblings == 1 && name == "" {
		name = "Quantity"
	}
	price := variant.GetPrice()
	return storefrontVariantView{
		Field:    storefrontQuantityField + variant.GetId(),
		Name:     name,
		Price:    price.GetCurrencyCode() + " " + formatCents(price.GetUnits(), price.GetNanos()),
		InStock:  variant.GetStockQuantity() > 0,
		Quantity: max(typed[variant.GetId()], 0),
	}
}

// visitorAddress is the caller's IP as reported by infrastructure commerce
// trusts. Cloud Run's front end appends the address it saw to
// X-Forwarded-For, so the last entry cannot be forged by the caller. When
// that address is Cloudflare's, the request came through the API gateway,
// which appends the client it saw just before; anything earlier is the
// caller's to write and is ignored.
func visitorAddress(r *http.Request) string {
	var hops []string
	for _, value := range r.Header.Values("X-Forwarded-For") {
		for hop := range strings.SplitSeq(value, ",") {
			if hop = strings.TrimSpace(hop); hop != "" {
				hops = append(hops, hop)
			}
		}
	}
	if len(hops) == 0 {
		host, _, err := net.SplitHostPort(r.RemoteAddr)
		if err != nil {
			return r.RemoteAddr
		}
		return host
	}
	last := hops[len(hops)-1]
	if len(hops) > 1 && isCloudflare(last) {
		return hops[len(hops)-2]
	}
	return last
}

func isCloudflare(ip string) bool {
	addr, err := netip.ParseAddr(ip)
	if err != nil {
		return false
	}
	addr = addr.Unmap()
	for _, prefix := range cloudflareRanges {
		if prefix.Contains(addr) {
			return true
		}
	}
	return false
}

// cloudflareRanges are Cloudflare's published edge ranges
// (https://www.cloudflare.com/ips/).
//
//nolint:gochecknoglobals // parsed once, immutable afterwards
var cloudflareRanges = func() []netip.Prefix {
	ranges := []string{
		"173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22",
		"141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20",
		"197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13",
		"104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22",
		"2400:cb00::/32", "2606:4700::/32", "2803:f800::/32", "2405:b500::/32",
		"2405:8100::/32", "2a06:98c0::/29", "2c0f:f248::/32",
	}
	prefixes := make([]netip.Prefix, 0, len(ranges))
	for _, r := range ranges {
		prefixes = append(prefixes, netip.MustParsePrefix(r))
	}
	return prefixes
}()

//nolint:gochecknoglobals // parsed once, immutable afterwards
var storefrontTemplate = template.Must(template.New("storefront").Parse(`<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{.Shop}}</title>
<style>
:root{--bg:#f6f7f9;--card:#fff;--fg:#1b1f24;--muted:#5b6470;--line:#e3e6ea;--accent:#1f6feb;--bad:#b42318;--good:#067647}
@media (prefers-color-scheme:dark){:root{--bg:#111418;--card:#1b1f24;--fg:#e6e8eb;--muted:#9aa3ad;--line:#2c323a;--accent:#4c8dff;--bad:#f97066;--good:#47cd89}}
*{box-sizing:border-box}
body{margin:0;font-family:system-ui,-apple-system,sans-serif;background:var(--bg);color:var(--fg);line-height:1.5}
main{max-width:44rem;margin:0 auto;padding:2rem 1rem 4rem}
h1{font-size:1.75rem;margin:0 0 .25rem}
h2{font-size:1.1rem;margin:0 0 .25rem}
.lead{color:var(--muted);margin:0 0 1.5rem}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:1rem 1.25rem;margin:0 0 1rem}
.card p{margin:.25rem 0 .75rem;color:var(--muted)}
.row{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:.5rem 0;border-top:1px solid var(--line)}
.row:first-of-type{border-top:0}
.price{font-variant-numeric:tabular-nums;white-space:nowrap}
.out{color:var(--muted);font-size:.9rem}
label{display:block;font-weight:600;margin:.75rem 0 .25rem}
.hint{font-weight:400;color:var(--muted);font-size:.9rem}
input{font:inherit;color:inherit;background:var(--bg);border:1px solid var(--line);border-radius:8px;padding:.5rem .6rem;width:100%}
input[type=number]{width:5rem;text-align:right}
button{font:inherit;font-weight:600;color:#fff;background:var(--accent);border:0;border-radius:8px;padding:.75rem 1.25rem;margin-top:1.25rem;width:100%;cursor:pointer}
.notice,.error{border-radius:8px;padding:.75rem 1rem;margin:0 0 1rem}
.notice{background:color-mix(in srgb,var(--good) 12%,transparent);color:var(--good)}
.error{background:color-mix(in srgb,var(--bad) 12%,transparent);color:var(--bad)}
.empty{color:var(--muted)}
</style>
</head>
<body>
<main>
<h1>{{.Shop}}</h1>
{{if .Description}}<p class="lead">{{.Description}}</p>{{end}}
{{if .Notice}}<div class="notice" role="status">{{.Notice}}</div>{{end}}
{{if .Error}}<div class="error" role="alert">{{.Error}}</div>{{end}}
{{if .Items}}
<form method="post" action="{{.Action}}">
<input type="hidden" name="key" value="{{.Key}}">
{{range .Items}}
<section class="card">
<h2>{{.Name}}</h2>
{{if .Description}}<p>{{.Description}}</p>{{end}}
{{range .Variants}}
<div class="row">
<span>{{.Name}}</span>
<span class="price">{{.Price}}</span>
{{if .InStock}}<input type="number" name="{{.Field}}" min="0" max="99" value="{{if .Quantity}}{{.Quantity}}{{end}}" placeholder="0" aria-label="Quantity of {{.Name}}">{{else}}<span class="out">Out of stock</span>{{end}}
</div>
{{end}}
</section>
{{end}}
<section class="card">
<h2>Your details</h2>
<label for="name">Name</label>
<input id="name" name="name" autocomplete="name" required maxlength="100" value="{{.Name}}">
<label for="contact">Email or phone <span class="hint">for your receipt and order updates</span></label>
<input id="contact" name="contact" autocomplete="email" required maxlength="254" value="{{.Contact}}">
{{if .Instalments}}
<label for="deposit">Pay now ({{.Currency}}) <span class="hint">optional. Leave empty to pay in full{{if .MinDeposit}}; at least {{.MinDeposit}}% of the order{{end}}</span></label>
<input id="deposit" name="deposit" inputmode="decimal" value="{{.Deposit}}">
{{end}}
<button type="submit">Continue to payment</button>
</section>
</form>
{{else}}
<p class="empty">This shop has nothing for sale right now.</p>
{{end}}
</main>
</body>
</html>
`))
