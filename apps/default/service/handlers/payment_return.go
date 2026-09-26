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
	"fmt"
	"html/template"
	"net/http"
	"net/url"
	"regexp"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/tenancy"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// Payment states reported to the storefront in the redirect.
const (
	returnStatePaid      = "paid"
	returnStatePending   = "pending"
	returnStateCancelled = "cancelled"

	// pendingRefreshSeconds is how often the status page re-checks an
	// unconfirmed payment.
	pendingRefreshSeconds = 5
)

var returnParamPattern = regexp.MustCompile(`^[0-9A-Za-z_-]{3,64}$`)

// PaymentReturnHandler serves the page hosted checkout sends buyers back to.
// The browser arrives without credentials, so the checkout session ref in the
// query is the capability: it is random, and must belong to the order. The
// payment is verified with the checkout service on arrival, then the buyer is
// forwarded to the storefront or shown the order's payment state.
func (cs *CommerceServer) PaymentReturnHandler() http.Handler {
	return NewPaymentReturnHandler(cs.paymentBusiness)
}

// NewPaymentReturnHandler builds the payment return page over payments.
func NewPaymentReturnHandler(payments business.PaymentBusiness) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.Header().Set("Allow", "GET, HEAD")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// The URL carries the session ref; keep it out of caches and out of
		// the Referer sent to wherever the buyer goes next.
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Referrer-Policy", "no-referrer")
		w.Header().Set("X-Content-Type-Options", "nosniff")

		query := r.URL.Query()
		orderID, sessionRef := query.Get("order"), query.Get("session")
		if !returnParamPattern.MatchString(orderID) || !returnParamPattern.MatchString(sessionRef) {
			renderReturnPage(w, http.StatusNotFound, returnPage{Title: "Payment not found",
				Message: "This payment link is not valid."})
			return
		}

		// No caller identity: the lookup is keyed by the unguessable ref.
		ctx := tenancy.WithSkipEnforcement(r.Context())
		result, err := payments.HandlePaymentReturn(ctx, orderID, sessionRef)
		if err != nil {
			renderReturnError(ctx, w, orderID, err)
			return
		}

		state := returnState(result.Order)
		if target := storefrontRedirect(result.RedirectURL, result.Order.GetId(), state); target != "" {
			// The target is the storefront URL commerce itself stored on the
			// session when the order was checked out, restricted to http(s).
			w.Header().Set("Location", target)
			w.WriteHeader(http.StatusSeeOther)
			return
		}
		renderReturnPage(w, http.StatusOK, statusPage(result.Order, state))
	})
}

func renderReturnError(ctx context.Context, w http.ResponseWriter, orderID string, err error) {
	code := connect.CodeOf(err)
	if code == connect.CodeNotFound || code == connect.CodeInvalidArgument || code == connect.CodeUnimplemented {
		renderReturnPage(w, http.StatusNotFound, returnPage{Title: "Payment not found",
			Message: "We could not find this payment."})
		return
	}
	util.Log(ctx).WithError(err).WithField("order_id", orderID).Warn("payment return failed")
	renderReturnPage(w, http.StatusServiceUnavailable, returnPage{
		Title:   "Confirming your payment",
		Message: "We could not confirm your payment just now. This page will try again.",
		Refresh: pendingRefreshSeconds,
	})
}

func returnState(order *commercev1.Order) string {
	switch {
	case order.GetPaymentStatus() == commercev1.PaymentStatus_PAYMENT_STATUS_PAID:
		return returnStatePaid
	case order.GetStatus() == commercev1.OrderStatus_ORDER_STATUS_CANCELLED:
		return returnStateCancelled
	default:
		return returnStatePending
	}
}

// storefrontRedirect appends the outcome to the storefront URL. Only absolute
// http(s) targets are followed.
func storefrontRedirect(raw, orderID, state string) string {
	if raw == "" {
		return ""
	}
	u, err := url.Parse(raw)
	if err != nil || (u.Scheme != "https" && u.Scheme != "http") || u.Host == "" {
		return ""
	}
	q := u.Query()
	q.Set("order_id", orderID)
	q.Set("payment", state)
	u.RawQuery = q.Encode()
	return u.String()
}

func statusPage(order *commercev1.Order, state string) returnPage {
	page := returnPage{OrderNumber: order.GetOrderNumber()}
	if total := order.GetTotal(); total != nil {
		page.Amount = total.GetCurrencyCode() + " " + formatCents(total.GetUnits(), total.GetNanos())
	}
	switch state {
	case returnStatePaid:
		page.Title = "Payment received"
		page.Message = "Thank you. Your payment has been received and the shop has been notified."
	case returnStateCancelled:
		page.Title = "Order cancelled"
		page.Message = "This order was cancelled before payment was confirmed. " +
			"If you were charged, contact the shop for a refund."
	default:
		page.Title = "Confirming your payment"
		page.Message = "We are waiting for your payment to be confirmed. This page updates automatically."
		page.Refresh = pendingRefreshSeconds
	}
	return page
}

func formatCents(units int64, nanos int32) string {
	const centsPerUnit = 100
	cents := models.MoneyCents(units, nanos)
	sign := ""
	if cents < 0 {
		sign, cents = "-", -cents
	}
	return fmt.Sprintf("%s%d.%02d", sign, cents/centsPerUnit, cents%centsPerUnit)
}

type returnPage struct {
	Title       string
	Message     string
	OrderNumber string
	Amount      string
	Refresh     int
}

func renderReturnPage(w http.ResponseWriter, status int, page returnPage) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'")
	w.WriteHeader(status)
	_ = returnPageTemplate.Execute(w, page)
}

//nolint:gochecknoglobals // parsed once, immutable afterwards
var returnPageTemplate = template.Must(template.New("return").Parse(`<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
{{if .Refresh}}<meta http-equiv="refresh" content="{{.Refresh}}">{{end}}
<title>{{.Title}}</title>
<style>
body{margin:0;font-family:system-ui,-apple-system,sans-serif;background:#f6f7f9;color:#1b1f24}
main{max-width:28rem;margin:12vh auto;padding:2rem 1.5rem;background:#fff;border-radius:12px;
box-shadow:0 1px 3px rgba(0,0,0,.08)}
h1{font-size:1.4rem;margin:0 0 .75rem}
p{line-height:1.5;margin:.5rem 0}
.meta{color:#5b6470;font-size:.95rem}
@media (prefers-color-scheme:dark){body{background:#111418;color:#e6e8eb}main{background:#1b1f24}.meta{color:#9aa3ad}}
</style>
</head>
<body>
<main>
<h1>{{.Title}}</h1>
<p>{{.Message}}</p>
{{if .OrderNumber}}<p class="meta">Order {{.OrderNumber}}{{if .Amount}} &middot; {{.Amount}}{{end}}</p>{{end}}
</main>
</body>
</html>
`))
