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
	"strings"
	"sync"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/models"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// The payment, ledger, and notification services are peers owned by other
// teams; tests substitute in-memory doubles that honour the same contracts.

// --- checkout ---

type fakeCheckout struct {
	mu       sync.Mutex
	sessions map[string]*checkoutv1.CheckoutSession
	created  int
	failNext error
	// getErr, when set, fails every GetSession the way an unreachable
	// checkout service would.
	getErr error
	// gets counts GetSession calls.
	gets int
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
	f.gets++
	if f.getErr != nil {
		return nil, f.getErr
	}
	s, ok := f.sessions[ref]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Sprintf("session %s not found", ref))
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

// attempt records a payment prompt going out on a session.
func (f *fakeCheckout) attempt(ref, promptID string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[ref]; ok {
		s.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING)
		s.SetPromptId(promptID)
	}
}

// fail marks the latest attempt on a session as declined.
func (f *fakeCheckout) fail(ref string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[ref]; ok {
		s.SetStatus(checkoutv1.SessionStatus_SESSION_STATUS_FAILED)
	}
}

// setAmount rewrites what the session charged.
func (f *fakeCheckout) setAmount(ref string, amount *commonv1.Money) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[ref]; ok {
		s.SetAmount(amount)
	}
}

func (f *fakeCheckout) session(ref string) *checkoutv1.CheckoutSession {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.sessions[ref]
}

func (f *fakeCheckout) setGetErr(err error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.getErr = err
}

func (f *fakeCheckout) getCount() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.gets
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

func (r *recordingNotifier) InstalmentReceived(
	_ context.Context, _ *models.Shop, o *models.Order, _ *models.OrderPayment,
) {
	r.record("instalment", o)
}

func (r *recordingNotifier) PaymentThresholdReached(_ context.Context, _ *models.Shop, o *models.Order, _ int32) {
	r.record("threshold", o)
}

func (r *recordingNotifier) BalanceOverdue(_ context.Context, _ *models.Shop, o *models.Order) {
	r.record("overdue", o)
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

// fakeWebhooks records webhook deliveries and fails while failing is set.
type fakeWebhooks struct {
	mu        sync.Mutex
	failing   bool
	delivered []business.WebhookDelivery
}

func (f *fakeWebhooks) Send(_ context.Context, delivery business.WebhookDelivery) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.failing {
		return errors.New("receiver unavailable")
	}
	f.delivered = append(f.delivered, delivery)
	return nil
}

func (f *fakeWebhooks) setFailing(failing bool) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.failing = failing
}

func (f *fakeWebhooks) events() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	types := make([]string, 0, len(f.delivered))
	for _, d := range f.delivered {
		types = append(types, d.EventType)
	}
	return types
}

// checkoutOrder is CheckoutOrder for tests that only need the order.
func checkoutOrder(
	ctx context.Context,
	payments business.PaymentBusiness,
	req *commercev1.CheckoutOrderRequest,
) (*commercev1.Order, error) {
	result, err := payments.CheckoutOrder(ctx, req)
	if err != nil {
		return nil, err
	}
	return result.Order, nil
}

// syncWebhookQueue delivers queued webhooks at once, as the Frame events
// queue would shortly after.
type syncWebhookQueue struct {
	events business.EventBusiness
}

func (q *syncWebhookQueue) Enqueue(ctx context.Context, eventIDs []string) error {
	q.events.Deliver(ctx, eventIDs)
	return nil
}

// --- payment service (refunds) ---

// fakeRefunds stands in for the payment service's Send and Status. A sent
// refund stays pending until settle decides it.
type fakeRefunds struct {
	mu       sync.Mutex
	sent     map[string]*business.RefundState // by reference
	amounts  map[string]int64
	payees   map[string]string
	sends    int
	failSend error
	// loseResponse makes Send take the refund and then fail, the way a
	// response lost on the network would.
	loseResponse bool
}

func newFakeRefunds() *fakeRefunds {
	return &fakeRefunds{
		sent: map[string]*business.RefundState{}, amounts: map[string]int64{}, payees: map[string]string{},
	}
}

func (f *fakeRefunds) Send(_ context.Context, refund *models.OrderRefund) (*business.RefundState, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.failSend != nil {
		return nil, f.failSend
	}
	f.sends++
	state := &business.RefundState{PaymentID: "pay-" + util.RandomAlphaNumericString(8)}
	f.sent[refund.Reference] = state
	f.amounts[refund.Reference] = refund.AmountNanos
	f.payees[refund.Reference] = refund.ProfileID + "/" + refund.ContactID
	if f.loseResponse {
		f.loseResponse = false
		return nil, connect.NewError(connect.CodeUnavailable, "connection reset")
	}
	return &business.RefundState{PaymentID: state.PaymentID, Outcome: state.Outcome}, nil
}

func (f *fakeRefunds) Status(_ context.Context, refund *models.OrderRefund) (*business.RefundState, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, state := range f.sent {
		if state.PaymentID == refund.PaymentID {
			return &business.RefundState{PaymentID: state.PaymentID, Outcome: state.Outcome}, nil
		}
	}
	return nil, connect.NewError(connect.CodeNotFound, "payment not found")
}

func (f *fakeRefunds) FindByReference(_ context.Context, refund *models.OrderRefund) (*business.RefundState, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	state, ok := f.sent[refund.Reference]
	if !ok {
		return nil, nil //nolint:nilnil // holds none
	}
	return &business.RefundState{PaymentID: state.PaymentID, Outcome: state.Outcome}, nil
}

// confirmAll completes every sent refund the way the payment rail would.
func (f *fakeRefunds) confirmAll() {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, state := range f.sent {
		state.Outcome = business.RefundOutcomeSucceeded
	}
}

func (f *fakeRefunds) sendCount() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.sends
}

// refunded returns the amount sent under references starting with prefix.
func (f *fakeRefunds) refunded(prefix string) int64 {
	f.mu.Lock()
	defer f.mu.Unlock()
	var total int64
	for ref, amount := range f.amounts {
		if strings.HasPrefix(ref, prefix) {
			total += amount
		}
	}
	return total
}

func (f *fakeRefunds) payee(reference string) string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.payees[reference]
}
