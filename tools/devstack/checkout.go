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

package main

import (
	"context"
	"fmt"
	"html/template"
	"net/http"
	"net/url"
	"sync"
	"time"

	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/checkout/v1/checkoutv1connect"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/proto"
)

// payPath is where the simulated hosted payment page is served.
const payPath = "/pay/"

const (
	sessionLifetime = time.Hour
	maxPayFormSize  = 1 << 10
)

// checkoutService stands in for service-payment's hosted checkout. Sessions
// live in memory; the payment page lets whoever opens it pay or cancel.
type checkoutService struct {
	checkoutv1connect.UnimplementedCheckoutServiceHandler

	baseURL string

	mu       sync.Mutex
	sessions map[string]*checkoutv1.CheckoutSession
}

func newCheckoutService(baseURL string) *checkoutService {
	return &checkoutService{baseURL: baseURL, sessions: map[string]*checkoutv1.CheckoutSession{}}
}

func (s *checkoutService) CreateCheckoutSession(
	_ context.Context,
	req *checkoutv1.CreateCheckoutSessionRequest,
) (*checkoutv1.CreateCheckoutSessionResponse, error) {
	if req.GetAmount().GetCurrencyCode() == "" || req.GetReturnUrl() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "amount and return_url are required")
	}
	ref := "cs_" + util.IDString()
	session := checkoutv1.CheckoutSession_builder{
		Ref:          ref,
		Name:         req.GetName(),
		Description:  req.GetDescription(),
		Amount:       req.GetAmount(),
		AmountOption: req.GetAmountOption(),
		OrderRef:     req.GetOrderRef(),
		Metadata:     req.GetMetadata(),
		ReturnUrl:    req.GetReturnUrl(),
		Payer:        req.GetPayer(),
		Status:       checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
		PageUrl:      s.baseURL + payPath + ref,
		ExpiresAt:    time.Now().Add(sessionLifetime).UTC().Format(time.RFC3339),
	}.Build()

	s.mu.Lock()
	s.sessions[ref] = session
	s.mu.Unlock()
	return checkoutv1.CreateCheckoutSessionResponse_builder{Data: clone(session)}.Build(), nil
}

func (s *checkoutService) GetCheckoutSession(
	_ context.Context,
	req *checkoutv1.GetCheckoutSessionRequest,
) (*checkoutv1.GetCheckoutSessionResponse, error) {
	session := s.session(req.GetRef())
	if session == nil {
		return nil, connect.NewError(connect.CodeNotFound, "checkout session not found")
	}
	return checkoutv1.GetCheckoutSessionResponse_builder{Data: session}.Build(), nil
}

// session returns a copy of the session with ref, or nil.
func (s *checkoutService) session(ref string) *checkoutv1.CheckoutSession {
	s.mu.Lock()
	defer s.mu.Unlock()
	if session, ok := s.sessions[ref]; ok {
		return clone(session)
	}
	return nil
}

// settle moves a pending session to its final status. It reports false when
// the session is unknown or already settled.
func (s *checkoutService) settle(ref string, paid bool) (*checkoutv1.CheckoutSession, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	session, ok := s.sessions[ref]
	if !ok || session.GetStatus() != checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED {
		return nil, false
	}
	if paid {
		session.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED)
		session.SetPaymentId("pay_" + util.IDString())
	} else {
		session.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_FAILED)
	}
	return clone(session), true
}

func clone(session *checkoutv1.CheckoutSession) *checkoutv1.CheckoutSession {
	c, _ := proto.Clone(session).(*checkoutv1.CheckoutSession)
	return c
}

//nolint:gochecknoglobals // parsed once, immutable afterwards
var payPage = template.Must(template.New("pay").Parse(`<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Simulated payment</title>
<style>
body{font-family:system-ui,sans-serif;max-width:28rem;margin:3rem auto;padding:0 1rem;color:#1f2937}
.banner{background:#fef3c7;border:1px solid #f59e0b;padding:.5rem .75rem;border-radius:6px;font-size:.875rem}
.amount{font-size:2rem;font-weight:700;margin:1rem 0}
button{font-size:1rem;padding:.6rem 1.2rem;border-radius:6px;border:0;cursor:pointer;margin-right:.5rem}
.pay{background:#059669;color:#fff}.cancel{background:#e5e7eb}
</style></head><body>
<p class="banner">Local development: no money moves.</p>
{{if .Session}}
<h1>{{.Session.GetName}}</h1>
<p>{{.Session.GetDescription}}</p>
<p class="amount">{{.Amount}}</p>
{{if .Open}}
<form method="post">
<button class="pay" name="action" value="pay">Pay</button>
<button class="cancel" name="action" value="cancel">Cancel</button>
</form>
{{else}}<p>This payment is {{.Status}}.</p>{{end}}
{{else}}<h1>Payment not found</h1>{{end}}
</body></html>`))

type payView struct {
	Session *checkoutv1.CheckoutSession
	Amount  string
	Open    bool
	Status  string
}

// payHandler serves the simulated hosted payment page. Paying or cancelling
// sends the browser back to the session's return URL with the session ref, as
// hosted checkout does.
func (s *checkoutService) payHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ref := r.PathValue("ref")
		switch r.Method {
		case http.MethodGet:
			session := s.session(ref)
			view := payView{Session: session}
			status := http.StatusNotFound
			if session != nil {
				status = http.StatusOK
				amount := session.GetAmount()
				view.Amount = fmt.Sprintf("%s %d.%02d", amount.GetCurrencyCode(),
					amount.GetUnits(), amount.GetNanos()/10_000_000) //nolint:mnd // nanos to cents
				view.Open = session.GetStatus() == checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED
				view.Status = session.GetStatus().String()
			}
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			w.WriteHeader(status)
			_ = payPage.Execute(w, view)
		case http.MethodPost:
			r.Body = http.MaxBytesReader(w, r.Body, maxPayFormSize)
			session, ok := s.settle(ref, r.FormValue("action") == "pay")
			if !ok {
				http.Error(w, "this payment is no longer open", http.StatusConflict)
				return
			}
			target, err := url.Parse(session.GetReturnUrl())
			if err != nil {
				http.Error(w, "the return address is not valid", http.StatusBadGateway)
				return
			}
			query := target.Query()
			query.Set("session", session.GetRef())
			target.RawQuery = query.Encode()
			w.Header().Set("Location", target.String())
			w.WriteHeader(http.StatusSeeOther)
		default:
			w.Header().Set("Allow", "GET, POST")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}
