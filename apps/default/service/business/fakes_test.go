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
	"fmt"
	"sync"

	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// The payment, ledger, and notification services are peers owned by other
// teams; tests substitute in-memory doubles that honour the same contracts.

// --- checkout ---

type fakeCheckout struct {
	mu       sync.Mutex
	sessions map[string]*checkoutv1.CheckoutSession
	created  int
	failNext error
}

func newFakeCheckout() *fakeCheckout {
	return &fakeCheckout{sessions: map[string]*checkoutv1.CheckoutSession{}}
}

func (f *fakeCheckout) CreateSession(
	_ context.Context,
	req *checkoutv1.CreateCheckoutSessionRequest,
) (*checkoutv1.CheckoutSession, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.failNext != nil {
		err := f.failNext
		f.failNext = nil
		return nil, err
	}
	ref := "cs_" + util.RandomAlphaNumericString(10)
	session := checkoutv1.CheckoutSession_builder{
		Ref:       ref,
		Name:      req.GetName(),
		Amount:    req.GetAmount(),
		OrderRef:  req.GetOrderRef(),
		Metadata:  req.GetMetadata(),
		ReturnUrl: req.GetReturnUrl(),
		Payer:     req.GetPayer(),
		Status:    checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
		PageUrl:   "https://pay.example/c/" + ref,
	}.Build()
	f.sessions[ref] = session
	f.created++
	return session, nil
}

func (f *fakeCheckout) GetSession(_ context.Context, ref string) (*checkoutv1.CheckoutSession, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	s, ok := f.sessions[ref]
	if !ok {
		return nil, fmt.Errorf("session %s not found", ref)
	}
	return s, nil
}

// complete marks a session paid the way the payment rail would.
func (f *fakeCheckout) complete(ref, paymentID string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[ref]; ok {
		s.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED)
		s.SetPaymentId(paymentID)
	}
}

func (f *fakeCheckout) expire(ref string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[ref]; ok {
		s.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED)
	}
}

func (f *fakeCheckout) createdSessions() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.created
}

// --- ledger ---

type fakeLedger struct {
	mu           sync.Mutex
	books        map[string]*business.ShopAccounts
	transactions []*ledgerv1.CreateTransactionRequest
	failNext     error
}

func newFakeLedger() *fakeLedger {
	return &fakeLedger{books: map[string]*business.ShopAccounts{}}
}

func (f *fakeLedger) EnsureShopBook(
	_ context.Context,
	shop *models.Shop,
	_ string,
) (*business.ShopAccounts, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if acc, ok := f.books[shop.GetID()]; ok {
		return acc, nil
	}
	acc := &business.ShopAccounts{
		BookID:              "book-" + shop.GetID(),
		ReceivableAccountID: "recv-" + shop.GetID(),
		SalesAccountID:      "sales-" + shop.GetID(),
	}
	f.books[shop.GetID()] = acc
	return acc, nil
}

func (f *fakeLedger) PostTransaction(_ context.Context, req *ledgerv1.CreateTransactionRequest) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.failNext != nil {
		err := f.failNext
		f.failNext = nil
		return "", err
	}
	for _, existing := range f.transactions {
		if existing.GetId() == req.GetId() {
			return "", errors.New("already exists")
		}
	}
	// Enforce the ledger's zero-sum rule so an unbalanced posting fails here
	// the way it would in production.
	var sum int64
	for _, e := range req.GetEntries() {
		v := e.GetAmount().GetUnits()*1_000_000_000 + int64(e.GetAmount().GetNanos())
		if e.GetCredit() {
			sum -= v
		} else {
			sum += v
		}
	}
	if sum != 0 {
		return "", errors.New("non zero sum transaction")
	}
	f.transactions = append(f.transactions, req)
	return req.GetId(), nil
}

func (f *fakeLedger) posted() []*ledgerv1.CreateTransactionRequest {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := make([]*ledgerv1.CreateTransactionRequest, len(f.transactions))
	copy(out, f.transactions)
	return out
}

// --- notifications ---

type recordingNotifier struct {
	mu     sync.Mutex
	events []string
}

func (r *recordingNotifier) record(kind string, order *models.Order) {
	r.mu.Lock()
	defer r.mu.Unlock()
	id := ""
	if order != nil {
		id = order.GetID()
	}
	r.events = append(r.events, kind+":"+id)
}

func (r *recordingNotifier) OrderPlaced(_ context.Context, _ *models.Shop, o *models.Order) {
	r.record("placed", o)
}

func (r *recordingNotifier) OrderPaid(_ context.Context, _ *models.Shop, o *models.Order) {
	r.record("paid", o)
}

func (r *recordingNotifier) OrderPaymentExpired(_ context.Context, _ *models.Shop, o *models.Order) {
	r.record("expired", o)
}

func (r *recordingNotifier) OrderCancelled(_ context.Context, _ *models.Shop, o *models.Order, _ string) {
	r.record("cancelled", o)
}

func (r *recordingNotifier) OrderShipped(_ context.Context, _ *models.Shop, o *models.Order, _ *models.Fulfilment) {
	r.record("shipped", o)
}

func (r *recordingNotifier) OrderDelivered(_ context.Context, _ *models.Shop, o *models.Order) {
	r.record("delivered", o)
}

func (r *recordingNotifier) LedgerDayPosted(_ context.Context, _ *models.Shop, _ *models.LedgerPosting) {
	r.record("ledger", nil)
}

func (r *recordingNotifier) count(kind string, orderID string) int {
	r.mu.Lock()
	defer r.mu.Unlock()
	n := 0
	for _, e := range r.events {
		if e == kind+":"+orderID {
			n++
		}
	}
	return n
}
