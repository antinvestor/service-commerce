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

package business

import (
	"context"
	"errors"
	"fmt"
	"net/url"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// CheckoutGateway is the slice of the hosted checkout service commerce
// depends on. Production wraps the Connect client; tests substitute a fake.
type CheckoutGateway interface {
	CreateSession(
		ctx context.Context,
		req *checkoutv1.CreateCheckoutSessionRequest,
	) (*checkoutv1.CheckoutSession, error)
	GetSession(ctx context.Context, ref string) (*checkoutv1.CheckoutSession, error)
}

// PaymentPolicy carries the deployment knobs payment flow depends on.
type PaymentPolicy struct {
	// DefaultReturnURL is used when a shop has none; {order_id} is substituted.
	DefaultReturnURL string
	// ReturnBaseURL is commerce's own public address. When set, hosted
	// checkout sends buyers to {ReturnBaseURL}/payments/return so the payment
	// is verified the moment they come back; they are then forwarded to the
	// storefront URL, or shown a status page when there is none.
	ReturnBaseURL string
	// PaymentWindow bounds how long stock stays reserved for an unpaid order.
	PaymentWindow time.Duration
	// SettleGrace keeps an overdue order open while a payment attempt is
	// still in flight at the provider, so a slow confirmation is not lost.
	SettleGrace time.Duration
	// ReconcileBatchSize caps orders examined per reconcile run.
	ReconcileBatchSize int
	// LatePaymentWindow is how long after an order is cancelled its unpaid
	// checkout sessions are still checked: a buyer who pays one late is
	// refunded automatically.
	LatePaymentWindow time.Duration
	// ReturnHosts are the hosts, besides the shop's own return URL host, a
	// buyer may be sent back to after paying: the storefront and the
	// deployment's default return page.
	ReturnHosts []string
}

// ReconcileSummary reports one reconcile run.
type ReconcileSummary struct {
	Examined int32
	// Paid counts orders that received money in this run, in full or in part.
	Paid    int32
	Expired int32
	Failed  int32
	// Overdue counts part-paid orders flagged past their balance deadline.
	Overdue int32
	// EventsDelivered counts webhook deliveries that succeeded on retry.
	EventsDelivered int32
	// RefundsSent counts refunds handed to the payment service.
	RefundsSent int32
	// RefundsConfirmed counts refunds the payment service confirmed.
	RefundsConfirmed int32
}

// PaymentReturn is the outcome of a buyer returning from hosted checkout.
type PaymentReturn struct {
	Order *commercev1.Order
	// RedirectURL is the storefront page to forward the buyer to; empty when
	// commerce should render the status itself.
	RedirectURL string
	// Unpaid means the session the buyer came back from ended without taking
	// payment: they cancelled, it failed, or it expired with nothing pending.
	Unpaid bool
}

// CheckoutResult is the order and the amount its checkout session charges.
type CheckoutResult struct {
	Order  *commercev1.Order
	Amount *commonv1.Money
}

// RecordedPayment is an instalment the shop took itself.
type RecordedPayment struct {
	OrderID    string
	Amount     *commonv1.Money
	Reference  string
	Note       string
	RecordedBy string
}

type PaymentBusiness interface {
	// CheckoutOrder creates (or returns) the hosted checkout session for the
	// next instalment of an order: req.amount, or the whole balance.
	CheckoutOrder(ctx context.Context, req *commercev1.CheckoutOrderRequest) (*CheckoutResult, error)
	// ConfirmOrderPayment verifies the checkout sessions and applies every
	// completed one. Safe to call repeatedly.
	ConfirmOrderPayment(ctx context.Context, orderID string) (*commercev1.Order, error)
	// RecordOrderPayment applies an offline instalment. A reference already
	// recorded on the order is a no-op.
	RecordOrderPayment(ctx context.Context, payment RecordedPayment) (*commercev1.Order, error)
	// ResolveOrderRefund settles a refund the payment service failed: sends
	// it again as a new payment, or records that the shop paid the buyer
	// back itself.
	ResolveOrderRefund(ctx context.Context, resolution RefundResolution) (*commercev1.Order, error)
	// CancelOrder cancels an unfulfilled order and returns stock. Buyers may
	// only cancel orders with nothing paid; staff (staff=true) may cancel
	// paid and part-paid ones, which pays what was paid back to the buyer
	// through the payment service (REFUND_PENDING until it confirms, then
	// REFUNDED).
	CancelOrder(ctx context.Context, orderID, reason string, staff bool) (*commercev1.Order, error)
	// ReconcilePayments applies completed sessions (refunding any that land
	// on a cancelled order), expires orders whose payment window lapsed,
	// flags part-paid orders past their balance deadline, sends and confirms
	// refunds, and retries webhook deliveries.
	ReconcilePayments(ctx context.Context, shopID string, limit int) (*ReconcileSummary, error)
	// HandlePaymentReturn settles the order a buyer is returning from hosted
	// checkout with. sessionRef must be one of the order's sessions; it is
	// the capability that lets an unauthenticated browser redirect through.
	HandlePaymentReturn(ctx context.Context, orderID, sessionRef string) (*PaymentReturn, error)
}

func NewPaymentBusiness(
	_ context.Context,
	orderRepo repository.OrderRepository,
	shopRepo repository.ShopRepository,
	gateway CheckoutGateway,
	refunds RefundGateway,
	notifier notifications.Notifier,
	events EventBusiness,
	policy PaymentPolicy,
) PaymentBusiness {
	if policy.PaymentWindow <= 0 {
		policy.PaymentWindow = defaultPaymentWindow
	}
	if policy.SettleGrace <= 0 {
		policy.SettleGrace = defaultSettleGrace
	}
	if policy.ReconcileBatchSize <= 0 {
		policy.ReconcileBatchSize = defaultReconcileBatch
	}
	if policy.LatePaymentWindow <= 0 {
		policy.LatePaymentWindow = defaultLatePaymentWindow
	}
	policy.ReturnBaseURL = strings.TrimRight(strings.TrimSpace(policy.ReturnBaseURL), "/")
	return &paymentBusiness{
		orderRepo: orderRepo,
		shopRepo:  shopRepo,
		gateway:   gateway,
		refunds:   refunds,
		notifier:  notifier,
		events:    events,
		policy:    policy,
	}
}

const (
	defaultPaymentWindow  = 45 * time.Minute
	defaultSettleGrace    = time.Hour
	defaultReconcileBatch = 200
	// defaultLatePaymentWindow is how long after cancellation an order's
	// sessions are still checked for a late payment.
	defaultLatePaymentWindow = 24 * time.Hour
	// sessionTTL is how long a checkout session can be paid when the
	// checkout service does not say; the payment window is extended to
	// cover it whenever a session is issued.
	sessionTTL = 30 * time.Minute
	// Reconcile backoff for an order looked at without being settled.
	reconcileBackoffBase = 20 * time.Minute
	reconcileBackoffMax  = 6 * time.Hour
	// sessionLookback bounds how long an unpaid instalment session on a
	// part-paid order keeps being checked by the reconciler.
	sessionLookback = 7 * 24 * time.Hour

	orderRefPrefix      = "order:"
	metadataShopID      = "shop_id"
	metadataOrderNumber = "order_number"
	metadataSource      = "source"
	metadataReturnTo    = "return_to"
	sourceCommerce      = "service_commerce"
	cancelReasonExpired = "payment window expired"
	cancelReasonOverdue = "balance not paid by the deadline"
	// PaymentReturnPath is where hosted checkout sends buyers back to.
	PaymentReturnPath = "/payments/return"
	// Checkout session field limits (checkout.v1 validation).
	sessionNameMaxLen        = 100
	sessionDescriptionMaxLen = 500
)

type paymentBusiness struct {
	orderRepo repository.OrderRepository
	shopRepo  repository.ShopRepository
	gateway   CheckoutGateway
	refunds   RefundGateway
	notifier  notifications.Notifier
	events    EventBusiness
	policy    PaymentPolicy
}

// --- session scan ---

// completedSession is a paid checkout session and what it was issued to
// charge.
type completedSession struct {
	session       *checkoutv1.CheckoutSession
	expectedNanos int64
}

// sessionScan is what the checkout service knows about every session issued
// for an order.
type sessionScan struct {
	refs []string
	// expected is what each session was issued to charge, by ref.
	expected map[string]int64
	// sessions holds each session that could be read, by ref.
	sessions map[string]*checkoutv1.CheckoutSession
	// completed lists every paid session, oldest first.
	completed []completedSession
	// inFlight means a payment prompt went out on some session and the
	// provider has not reported a final outcome yet.
	inFlight bool
	// unreadable counts sessions that failed to load for a reason other than
	// not existing; their state is unknown.
	unreadable int
	lastErr    error
	// mismatched counts completed sessions that charged something other
	// than what they were issued for; only staff can settle those.
	mismatched int
}

// errSessionAmountMismatch marks a completed session whose charge differs
// from what it was issued for.
var errSessionAmountMismatch = errors.New("the payment amount does not match the amount requested")

// scanSessions asks the checkout service about every session issued for the
// order.
func (pb *paymentBusiness) scanSessions(ctx context.Context, order *models.Order) (*sessionScan, error) {
	scan, err := pb.issuedSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	pb.fetchSessions(ctx, order, scan)
	return scan, nil
}

// issuedSessions lists, from commerce's own records, every session issued
// for the order and what each was issued to charge.
func (pb *paymentBusiness) issuedSessions(ctx context.Context, order *models.Order) (*sessionScan, error) {
	issued, err := pb.orderRepo.ListPaymentSessions(ctx, order.GetID())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	scan := &sessionScan{
		expected: make(map[string]int64, len(issued)+1),
		sessions: make(map[string]*checkoutv1.CheckoutSession, len(issued)+1),
	}
	for _, s := range issued {
		scan.refs = append(scan.refs, s.SessionRef)
		// Sessions issued before instalments existed charged the total.
		scan.expected[s.SessionRef] = s.AmountNanos
		if s.AmountNanos == 0 {
			scan.expected[s.SessionRef] = order.TotalNanosValue()
		}
	}
	// Orders created before session history was kept only carry the latest.
	if ref := order.PaymentSessionRef; ref != "" {
		if _, known := scan.expected[ref]; !known {
			scan.refs = append(scan.refs, ref)
			scan.expected[ref] = order.TotalNanosValue()
		}
	}
	return scan, nil
}

func (pb *paymentBusiness) fetchSessions(ctx context.Context, order *models.Order, scan *sessionScan) {
	for _, ref := range scan.refs {
		session, getErr := pb.gateway.GetSession(ctx, ref)
		if getErr != nil {
			if !isNotFound(getErr) {
				scan.unreadable++
				scan.lastErr = getErr
				util.Log(ctx).WithError(getErr).
					WithField("order_id", order.GetID()).
					WithField("session_ref", ref).
					Warn("could not load checkout session")
			}
			continue
		}
		scan.sessions[ref] = session
		switch session.GetStatus() {
		case checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED:
			scan.completed = append(
				scan.completed,
				completedSession{session: session, expectedNanos: scan.expected[ref]},
			)
		case checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING,
			checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED,
			checkoutv1.SessionStatus_SESSION_STATUS_FAILED:
			// Checkout still recovers a session whose prompt later succeeds,
			// whatever it last reported, so any prompt may yet be paid.
			if session.GetPromptId() != "" {
				scan.inFlight = true
			}
		case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED:
		}
	}
}

func isNotFound(err error) bool {
	return connect.CodeOf(err) == connect.CodeNotFound || frame.ErrorIsNotFound(err)
}

// applyCompleted applies every completed session not yet recorded on the
// order and publishes the resulting signals. It reports how many were newly
// applied; a session whose charge does not match what it was issued for is
// logged and skipped.
func (pb *paymentBusiness) applyCompleted(ctx context.Context, order *models.Order, scan *sessionScan) (int, error) {
	if len(scan.completed) == 0 {
		return 0, nil
	}
	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return 0, data.ErrorConvertToAPI(err)
	}
	applied := 0
	var firstErr error
	for _, done := range scan.completed {
		session := done.session
		charged := session.GetAmount()
		if !strings.EqualFold(charged.GetCurrencyCode(), order.TotalCurrency) ||
			models.MoneyCents(charged.GetUnits(), charged.GetNanos()) != done.expectedNanos/nanosPerCent {
			util.Log(ctx).
				WithField("order_id", order.GetID()).
				WithField("session_ref", session.GetRef()).
				WithField("expected_nanos", done.expectedNanos).
				WithField("session_amount", fmt.Sprintf("%s %d.%09d", charged.GetCurrencyCode(),
					charged.GetUnits(), charged.GetNanos())).
				Error("checkout session amount does not match what it was issued for; not applying")
			scan.mismatched++
			if firstErr == nil {
				firstErr = connect.NewError(connect.CodeFailedPrecondition, errSessionAmountMismatch.Error())
			}
			continue
		}
		payment := &models.OrderPayment{
			Source:      int32(commercev1.OrderPaymentSource_ORDER_PAYMENT_SOURCE_CHECKOUT),
			Currency:    order.TotalCurrency,
			AmountNanos: done.expectedNanos,
			Reference:   session.GetRef(),
			PaymentID:   session.GetPaymentId(),
			PaidAt:      time.Now(),
		}
		ok, applyErr := pb.apply(ctx, shop, order.GetID(), payment)
		if applyErr != nil {
			return applied, applyErr
		}
		if ok {
			applied++
		}
	}
	if applied == 0 && firstErr != nil {
		return 0, firstErr
	}
	return applied, nil
}

// apply records one instalment and publishes its signals.
func (pb *paymentBusiness) apply(
	ctx context.Context,
	shop *models.Shop,
	orderID string,
	payment *models.OrderPayment,
) (bool, error) {
	order, events, applied, err := pb.orderRepo.ApplyPayment(ctx, orderID, payment,
		paymentTransition(shop, payment.PaidAt))
	if err != nil {
		return false, data.ErrorConvertToAPI(err)
	}
	if applied && pb.events != nil {
		pb.events.Publish(ctx, shop, order, payment, events)
	}
	return applied, nil
}

// --- CheckoutOrder ---

func (pb *paymentBusiness) CheckoutOrder(
	ctx context.Context,
	req *commercev1.CheckoutOrderRequest,
) (*CheckoutResult, error) {
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, "online payment is not configured")
	}
	order, err := pb.orderRepo.GetWithLines(ctx, req.GetOrderId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if err = checkoutable(order); err != nil {
		return nil, err
	}
	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if err = pb.checkReturnURL(shop, req.GetReturnUrl()); err != nil {
		return nil, err
	}

	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	// A buyer may have paid an earlier link; apply it before deciding what
	// is still owed, so they are never asked to pay twice.
	if order, err = pb.applyAndReload(ctx, order, scan); err != nil {
		return nil, err
	}
	if order.BalanceNanos() == 0 {
		return &CheckoutResult{Order: order.ToAPI()}, nil
	}

	amount, err := requestedInstalment(order, req.GetAmount())
	if err != nil {
		return nil, depositRefused(err)
	}

	reuse, err := currentSessionReusable(ctx, order, scan, amount, time.Now())
	if err != nil {
		return nil, err
	}
	if reuse {
		return &CheckoutResult{Order: order.ToAPI(), Amount: models.MoneyFromNanos(order.TotalCurrency, amount)}, nil
	}

	session, err := pb.gateway.CreateSession(ctx, pb.buildSessionRequest(shop, order, req, amount))
	if err != nil {
		util.Log(ctx).WithError(err).WithField("order_id", order.GetID()).Warn("could not create checkout session")
		return nil, connect.NewError(connect.CodeUnavailable, "payment could not be started just now; please try again")
	}
	attached, err := pb.orderRepo.AttachPaymentSession(ctx, order.GetID(), order.PaymentSessionRef,
		session.GetRef(), session.GetPageUrl(), amount, pb.extendedDueAt(order, session, time.Now()))
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if !attached {
		// Another checkout of this order won the race; offer its session
		// rather than open a second one the buyer could also pay.
		return pb.concurrentSession(ctx, order.GetID(), amount)
	}
	firstSession := order.PaymentSessionRef == ""
	order.PaymentSessionRef = session.GetRef()
	order.CheckoutURL = session.GetPageUrl()

	// The buyer's confirmation carries the payment link, so it goes out once
	// the first session exists rather than at order creation.
	if firstSession {
		pb.notifier.OrderPlaced(ctx, shop, order)
	}
	return &CheckoutResult{Order: order.ToAPI(), Amount: models.MoneyFromNanos(order.TotalCurrency, amount)}, nil
}

// extendedDueAt is the payment window an unpaid order needs once session is
// issued: long enough for the buyer to pay the session, so stock is never
// released under a payment page that still takes money. Nil leaves the
// window as it is.
func (pb *paymentBusiness) extendedDueAt(
	order *models.Order,
	session *checkoutv1.CheckoutSession,
	now time.Time,
) *time.Time {
	if order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		return nil
	}
	sessionEnds := now.Add(sessionTTL)
	if expires, err := time.Parse(time.RFC3339, session.GetExpiresAt()); err == nil && expires.After(now) {
		sessionEnds = expires
	}
	if !sessionEnds.After(pb.dueAt(order)) {
		return nil
	}
	return &sessionEnds
}

// concurrentSession answers a checkout that lost the race to attach its
// session with the session that won, when it charges the same amount.
func (pb *paymentBusiness) concurrentSession(
	ctx context.Context,
	orderID string,
	amount int64,
) (*CheckoutResult, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	issued, err := pb.issuedSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	if order.PaymentSessionRef != "" && issued.expected[order.PaymentSessionRef] == amount {
		return &CheckoutResult{Order: order.ToAPI(), Amount: models.MoneyFromNanos(order.TotalCurrency, amount)}, nil
	}
	return nil, connect.NewError(connect.CodeAborted, "the order changed; reload it and try again")
}

// applyAndReload applies completed sessions and returns the order as it now
// stands.
func (pb *paymentBusiness) applyAndReload(
	ctx context.Context,
	order *models.Order,
	scan *sessionScan,
) (*models.Order, error) {
	applied, err := pb.applyCompleted(ctx, order, scan)
	if err != nil || applied == 0 {
		return order, err
	}
	reloaded, err := pb.orderRepo.GetWithLines(ctx, order.GetID())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return reloaded, nil
}

// currentSessionReusable reports whether the order's live session charges
// amount and can still be paid, so a buyer who reloads, or whose attempt
// failed, stays on the same page. A session whose state is unknown blocks a
// new one, and so does an open session for a different amount: issuing
// another could let the buyer pay both.
func currentSessionReusable(
	ctx context.Context,
	order *models.Order,
	scan *sessionScan,
	amount int64,
	now time.Time,
) (bool, error) {
	ref := order.PaymentSessionRef
	if ref == "" {
		return false, nil
	}
	current, ok := scan.sessions[ref]
	if ok && !sessionApplied(order, ref) && sessionReusable(current) {
		if scan.expected[ref] == amount {
			return true, nil
		}
		if sessionOpen(current, now) {
			return false, connect.NewError(connect.CodeFailedPrecondition, fmt.Sprintf(
				"a payment of %s %s is already open for this order; complete it or wait for it to expire",
				order.TotalCurrency, formatMoneyNanos(scan.expected[ref])))
		}
	}
	if scan.unreadable > 0 {
		util.Log(ctx).WithError(scan.lastErr).WithField("order_id", order.GetID()).
			Warn("could not verify existing checkout session")
		return false, connect.NewError(
			connect.CodeUnavailable,
			"could not verify the existing payment just now; please try again",
		)
	}
	return false, nil
}

// sessionOpen reports whether a buyer could still be paying s: it is
// waiting for them or has a payment under way, and has not expired.
func sessionOpen(s *checkoutv1.CheckoutSession, now time.Time) bool {
	switch s.GetStatus() { //nolint:exhaustive // only these can still take money now
	case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
		checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING:
	default:
		return false
	}
	expires, err := time.Parse(time.RFC3339, s.GetExpiresAt())
	return err != nil || expires.After(now)
}

// awaitingPayment reports whether the order can still take a payment.
func awaitingPayment(order *models.Order) bool {
	return checkoutable(order) == nil
}

// checkoutable rejects orders that cannot take another online payment.
func checkoutable(order *models.Order) error {
	switch {
	case order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID):
		return connect.NewError(connect.CodeFailedPrecondition, "order is already paid")
	case order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT):
		return nil
	case order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED) &&
		order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PARTIALLY_PAID):
		return nil
	default:
		return connect.NewError(connect.CodeFailedPrecondition, "order is not awaiting payment")
	}
}

// requestedInstalment validates the amount a buyer asked to pay now against
// the order's policy. Empty means the whole balance.
func requestedInstalment(order *models.Order, requested *commonv1.Money) (int64, error) {
	balance := order.BalanceNanos()
	if requested == nil || (requested.GetUnits() == 0 && requested.GetNanos() == 0) {
		return balance, nil
	}
	if !strings.EqualFold(requested.GetCurrencyCode(), order.TotalCurrency) {
		return 0, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("amount must be in %s", order.TotalCurrency))
	}
	units, nanos := models.RoundToCents(requested.GetUnits(), requested.GetNanos())
	amount := models.MoneyNanos(units, nanos)
	if amount == balance {
		return balance, nil
	}
	if order.PaymentPolicy == nil || !order.PaymentPolicy.AllowInstalments {
		return 0, connect.NewError(connect.CodeFailedPrecondition,
			"this order must be paid in full")
	}
	minimum, maximum := instalmentRange(order)
	if amount <= 0 || amount > maximum {
		return 0, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("amount must be between %s and %s %s",
				formatMoneyNanos(minimum), formatMoneyNanos(maximum), order.TotalCurrency))
	}
	if amount < minimum {
		what := "instalment"
		if order.AmountPaidNanos == 0 {
			what = "deposit"
		}
		return 0, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("the minimum %s is %s %s", what, formatMoneyNanos(minimum), order.TotalCurrency))
	}
	return amount, nil
}

// formatMoneyNanos renders nanos with two decimals.
func formatMoneyNanos(nanos int64) string {
	cents := nanos / nanosPerCent
	return fmt.Sprintf("%d.%02d", cents/100, cents%100) //nolint:mnd // cents
}

// recordedBefore reports whether the shop recorded reference before
// recorded references were prefixed.
func recordedBefore(order *models.Order, reference string) bool {
	for _, p := range order.Payments {
		if p.Reference == reference &&
			p.Source == int32(commercev1.OrderPaymentSource_ORDER_PAYMENT_SOURCE_RECORDED) {
			return true
		}
	}
	return false
}

// sessionApplied reports whether the session's payment is already recorded.
func sessionApplied(order *models.Order, ref string) bool {
	for _, p := range order.Payments {
		if p.Reference == ref {
			return true
		}
	}
	return false
}

// sessionReusable reports whether the buyer can still pay on s. A failed
// attempt is retryable on the same page; only completed and expired sessions
// are finished.
func sessionReusable(s *checkoutv1.CheckoutSession) bool {
	if s == nil || s.GetPageUrl() == "" {
		return false
	}
	switch s.GetStatus() {
	case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
		checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING,
		checkoutv1.SessionStatus_SESSION_STATUS_FAILED:
		return true
	case checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED,
		checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED:
		return false
	default:
		return false
	}
}

// storefrontReturnURL is where the buyer finally lands: the request's URL,
// else the shop's, else the deployment default, with {order_id} filled in.
// The request's URL was checked by checkReturnURL.
func (pb *paymentBusiness) storefrontReturnURL(
	shop *models.Shop,
	order *models.Order,
	req *commercev1.CheckoutOrderRequest,
) string {
	returnURL := strings.TrimSpace(req.GetReturnUrl())
	if returnURL == "" {
		returnURL = shop.CheckoutReturnURL
	}
	if returnURL == "" {
		returnURL = pb.policy.DefaultReturnURL
	}
	return strings.ReplaceAll(returnURL, "{order_id}", order.GetID())
}

// checkReturnURL refuses a caller-supplied return URL that is not https on
// a host commerce trusts, so checkout cannot be used to bounce buyers to
// another site.
func (pb *paymentBusiness) checkReturnURL(shop *models.Shop, raw string) error {
	raw = strings.TrimSpace(raw)
	if raw == "" || pb.returnAllowed(shop, raw) {
		return nil
	}
	return connect.NewError(
		connect.CodeInvalidArgument,
		"return_url must be an https address on the shop's or the storefront's host",
	)
}

// returnAllowed reports whether raw is an https URL on the host of the
// shop's return URL, the storefront, or the deployment's return page.
func (pb *paymentBusiness) returnAllowed(shop *models.Shop, raw string) bool {
	u, err := url.Parse(raw)
	if err != nil || u.Scheme != schemeHTTPS || u.Host == "" || u.User != nil {
		return false
	}
	host := strings.ToLower(u.Hostname())
	allowed := append([]string{}, pb.policy.ReturnHosts...)
	if shop != nil {
		allowed = append(allowed, hostOf(shop.CheckoutReturnURL))
	}
	allowed = append(allowed, hostOf(pb.policy.DefaultReturnURL))
	for _, h := range allowed {
		if h != "" && strings.EqualFold(h, host) {
			return true
		}
	}
	return false
}

// hostOf is the host of an absolute URL, or "".
func hostOf(raw string) string {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil {
		return ""
	}
	return strings.ToLower(u.Hostname())
}

// ReturnHost is the host buyers may be returned to on base, for
// PaymentPolicy.ReturnHosts.
func ReturnHost(base string) string { return hostOf(base) }

func (pb *paymentBusiness) buildSessionRequest(
	shop *models.Shop,
	order *models.Order,
	req *commercev1.CheckoutOrderRequest,
	amountNanos int64,
) *checkoutv1.CreateCheckoutSessionRequest {
	metadata := map[string]string{
		metadataShopID:      shop.GetID(),
		metadataOrderNumber: order.OrderNumber,
		metadataSource:      sourceCommerce,
	}
	returnURL := pb.storefrontReturnURL(shop, order, req)
	if pb.policy.ReturnBaseURL != "" {
		// Route the buyer through commerce so the payment is confirmed on
		// arrival; the storefront URL rides along in the session metadata.
		if returnURL != "" {
			metadata[metadataReturnTo] = returnURL
		}
		returnURL = pb.policy.ReturnBaseURL + PaymentReturnPath + "?order=" + url.QueryEscape(order.GetID())
	}

	payer := checkoutv1.PayerPrefill_builder{ProfileId: order.ProfileID}
	if order.ContactID != "" {
		payer.Contacts = []*checkoutv1.PayerContact{
			checkoutv1.PayerContact_builder{ContactId: order.ContactID}.Build(),
		}
	}

	description := fmt.Sprintf("%d item(s) from %s", len(order.Lines), shop.Name)
	if amountNanos < order.TotalNanosValue() {
		description = fmt.Sprintf("Instalment of %s %s towards %s %s for %d item(s) from %s",
			order.TotalCurrency, formatMoneyNanos(amountNanos),
			order.TotalCurrency, formatMoneyNanos(order.TotalNanosValue()), len(order.Lines), shop.Name)
	}

	return checkoutv1.CreateCheckoutSessionRequest_builder{
		Name:         truncateRunes(fmt.Sprintf("%s order %s", shop.Name, order.OrderNumber), sessionNameMaxLen),
		Description:  truncateRunes(description, sessionDescriptionMaxLen),
		Amount:       models.MoneyFromNanos(order.TotalCurrency, amountNanos),
		AmountOption: checkoutv1.AmountOption_AMOUNT_OPTION_FIXED_UNSPECIFIED,
		OrderRef:     orderRefPrefix + order.GetID(),
		Metadata:     metadata,
		ReturnUrl:    returnURL,
		Payer:        payer.Build(),
		Methods:      req.GetMethods(),
	}.Build()
}

func truncateRunes(s string, limit int) string {
	r := []rune(s)
	if len(r) <= limit {
		return s
	}
	return string(r[:limit])
}

// --- ConfirmOrderPayment ---

func (pb *paymentBusiness) ConfirmOrderPayment(ctx context.Context, orderID string) (*commercev1.Order, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID) {
		return order.ToAPI(), nil
	}
	if checkoutable(order) != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "order is not awaiting payment")
	}
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, "online payment is not configured")
	}

	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	if len(scan.refs) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "order has no checkout session")
	}
	applied, err := pb.applyCompleted(ctx, order, scan)
	if err != nil {
		return nil, err
	}
	// A part-paid order with nothing new is simply reported as it stands.
	if applied > 0 || order.AmountPaidNanos > 0 {
		return pb.refresh(ctx, order.GetID())
	}
	if len(scan.sessions) == 0 && scan.unreadable > 0 {
		util.Log(ctx).WithError(scan.lastErr).WithField("order_id", order.GetID()).
			Warn("could not verify checkout session")
		return nil, connect.NewError(connect.CodeUnavailable,
			"could not verify the payment just now; please try again")
	}

	status := checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED
	if current, ok := scan.sessions[order.PaymentSessionRef]; ok {
		status = current.GetStatus()
	}
	return nil, connect.NewError(connect.CodeFailedPrecondition,
		fmt.Sprintf("checkout session is %s, not completed", status))
}

func (pb *paymentBusiness) refresh(ctx context.Context, orderID string) (*commercev1.Order, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return order.ToAPI(), nil
}

// --- RecordOrderPayment ---

func (pb *paymentBusiness) RecordOrderPayment(
	ctx context.Context,
	recorded RecordedPayment,
) (*commercev1.Order, error) {
	given := strings.TrimSpace(recorded.Reference)
	if given == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "reference is required")
	}
	// The shop's references live apart from checkout session refs, so a
	// receipt number can never pass for (and block) an online payment.
	reference := models.RecordedReferencePrefix + given
	order, err := pb.orderRepo.GetWithLines(ctx, recorded.OrderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if sessionApplied(order, reference) || recordedBefore(order, given) {
		return order.ToAPI(), nil
	}
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "order is cancelled")
	}
	if order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "order is already paid")
	}
	amount := recorded.Amount
	if !strings.EqualFold(amount.GetCurrencyCode(), order.TotalCurrency) {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			fmt.Sprintf("amount must be in %s", order.TotalCurrency))
	}
	units, nanos := models.RoundToCents(amount.GetUnits(), amount.GetNanos())
	amountNanos := models.MoneyNanos(units, nanos)
	if amountNanos <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "amount must be positive")
	}
	if amountNanos > order.BalanceNanos() {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			fmt.Sprintf(
				"amount exceeds the balance of %s %s",
				formatMoneyNanos(order.BalanceNanos()),
				order.TotalCurrency,
			))
	}

	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	payment := &models.OrderPayment{
		Source:      int32(commercev1.OrderPaymentSource_ORDER_PAYMENT_SOURCE_RECORDED),
		Currency:    order.TotalCurrency,
		AmountNanos: amountNanos,
		Reference:   reference,
		PaidAt:      time.Now(),
		RecordedBy:  recorded.RecordedBy,
		Note:        strings.TrimSpace(recorded.Note),
	}
	if _, err = pb.apply(ctx, shop, order.GetID(), payment); err != nil {
		return nil, err
	}
	return pb.refresh(ctx, order.GetID())
}

// --- HandlePaymentReturn ---

func (pb *paymentBusiness) HandlePaymentReturn(
	ctx context.Context,
	orderID, sessionRef string,
) (*PaymentReturn, error) {
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, "online payment is not configured")
	}
	if orderID == "" || sessionRef == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "order and session are required")
	}

	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	// The ref is the capability: check it against commerce's own records
	// before anything is asked of the checkout service.
	scan, err := pb.issuedSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	if _, known := scan.expected[sessionRef]; !known {
		// Indistinguishable from a missing order so refs cannot be probed.
		return nil, connect.NewError(connect.CodeNotFound, "order not found")
	}
	pb.fetchSessions(ctx, order, scan)
	// A mismatch is logged inside applyCompleted and the order stays as is;
	// a payment on a cancelled order is applied and refunded.
	if checkoutable(order) == nil || order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		_, _ = pb.applyCompleted(ctx, order, scan)
	}

	result := &PaymentReturn{}
	if session, ok := scan.sessions[sessionRef]; ok {
		// Only a destination commerce trusts; anything else gets the status
		// page.
		if target := session.GetMetadata()[metadataReturnTo]; pb.returnAllowed(order.Shop, target) {
			result.RedirectURL = target
		}
		switch session.GetStatus() {
		case checkoutv1.SessionStatus_SESSION_STATUS_FAILED:
			result.Unpaid = true
		case checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED:
			result.Unpaid = session.GetPromptId() == ""
		case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
			checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING,
			checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED:
		}
	}
	result.Order, err = pb.refresh(ctx, order.GetID())
	if err != nil {
		return nil, err
	}
	return result, nil
}

// --- CancelOrder ---

func (pb *paymentBusiness) CancelOrder(
	ctx context.Context,
	orderID, reason string,
	staff bool,
) (*commercev1.Order, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		return order.ToAPI(), nil
	}
	if err = cancellable(order); err != nil {
		return nil, err
	}
	if order.AmountPaidNanos > 0 && !staff {
		return nil, connect.NewError(connect.CodePermissionDenied,
			"a paid order can only be cancelled by the shop")
	}

	// A buyer cancelling an order they have in fact just paid would
	// otherwise lose both the goods and the money.
	before := order.AmountPaidNanos
	if order, err = pb.settleBeforeCancel(ctx, order); err != nil {
		return nil, err
	}
	if order.AmountPaidNanos > before && !staff {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"the order has been paid and can only be cancelled by the shop")
	}

	reason = strings.TrimSpace(reason)
	if reason == "" {
		reason = "cancelled"
	}
	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	// Decided again against the order as it stands when it is written, so
	// a payment landing meanwhile is refunded rather than lost.
	cancelled, plan, err := pb.orderRepo.Cancel(ctx, order.GetID(), time.Now(), cancelDecision(shop, reason, staff))
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if plan == nil {
		return pb.refresh(ctx, order.GetID())
	}

	pb.notifier.OrderCancelled(ctx, shop, cancelled, reason)
	if pb.events != nil {
		pb.events.Publish(ctx, shop, cancelled, nil, plan.Events)
	}
	if plan.Refund != nil {
		pb.sendOrderRefunds(ctx, order.GetID())
	}
	return pb.refresh(ctx, order.GetID())
}

// cancelDecision cancels an order still open for it, refunding what was
// paid towards it; only staff may cancel one with money on it.
func cancelDecision(shop *models.Shop, reason string, staff bool) repository.CancelDecision {
	return func(current *models.Order, salePaid int64) (*repository.CancelPlan, error) {
		if current.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
			return nil, nil
		}
		if err := cancellable(current); err != nil {
			return nil, err
		}
		if salePaid > 0 && !staff {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				"the order has been paid and can only be cancelled by the shop")
		}
		plan := &repository.CancelPlan{
			Reason: reason,
			Events: []*models.OrderEvent{
				newOrderEvent(shop, current, commercev1.OrderEventType_ORDER_EVENT_TYPE_CANCELLED, 0),
			},
		}
		withRefund(plan, current, salePaid)
		return plan, nil
	}
}

// cancellable rejects orders that can no longer be cancelled.
func cancellable(order *models.Order) error {
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_FULFILLED) || shipped(order) {
		return connect.NewError(connect.CodeFailedPrecondition, "order has shipped and can no longer be cancelled")
	}
	if order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) &&
		order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED) {
		return connect.NewError(connect.CodeFailedPrecondition, "order can no longer be cancelled")
	}
	return nil
}

// shipped reports whether goods have left the shop.
func shipped(order *models.Order) bool {
	return order.FulfilmentStatus == int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED) ||
		order.FulfilmentStatus == int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED)
}

// withRefund adds to plan the refund of what the buyer paid towards order.
func withRefund(plan *repository.CancelPlan, order *models.Order, salePaid int64) {
	if salePaid <= 0 {
		return
	}
	plan.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_REFUND_PENDING)
	plan.Refund = &models.OrderRefund{
		Reference:    models.RefundReferencePrefix + order.GetID() + ":cancel",
		Currency:     order.TotalCurrency,
		AmountNanos:  salePaid,
		ReversesSale: true,
	}
}

// settleBeforeCancel applies any payment that completed since the order was
// read, returning the order as it now stands.
func (pb *paymentBusiness) settleBeforeCancel(ctx context.Context, order *models.Order) (*models.Order, error) {
	// Only an order still taking payments can have one in flight.
	if pb.gateway == nil || !awaitingPayment(order) {
		return order, nil
	}
	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	return pb.applyAndReload(ctx, order, scan)
}

// --- ReconcilePayments ---

func (pb *paymentBusiness) ReconcilePayments(
	ctx context.Context,
	shopID string,
	limit int,
) (*ReconcileSummary, error) {
	if limit <= 0 || limit > pb.policy.ReconcileBatchSize {
		limit = pb.policy.ReconcileBatchSize
	}
	now := time.Now()
	window := repository.ReconcileWindow{
		Now:           now,
		SessionsSince: now.Add(-sessionLookback),
		LateSince:     now.Add(-pb.policy.LatePaymentWindow),
	}
	summary := &ReconcileSummary{}

	// Most runs find nothing to do; they cost one query.
	work, err := pb.orderRepo.HasReconcileWork(ctx, shopID, window)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if !work {
		return summary, nil
	}

	orders, err := pb.orderRepo.ListAwaitingPayment(ctx, shopID, window, limit)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	summary.Examined = int32(len(orders)) //nolint:gosec // bounded by limit
	for _, order := range orders {
		if ctx.Err() != nil {
			return summary, ctx.Err()
		}
		switch pb.reconcileOne(ctx, order, now) {
		case reconciledPaid:
			summary.Paid++
		case reconciledExpired:
			summary.Expired++
		case reconciledFailed:
			summary.Failed++
		case reconciledUntouched:
		}
	}

	overdue, err := pb.orderRepo.ListOverdue(ctx, shopID, now, limit)
	if err != nil {
		return summary, data.ErrorConvertToAPI(err)
	}
	for _, order := range overdue {
		if ctx.Err() != nil {
			return summary, ctx.Err()
		}
		if pb.flagOverdue(ctx, order, now) {
			summary.Overdue++
		} else {
			summary.Failed++
		}
	}

	refunds := pb.processRefunds(ctx, shopID, now)
	summary.RefundsSent, summary.RefundsConfirmed = refunds.sent, refunds.confirmed

	if pb.events != nil {
		summary.EventsDelivered = int32(pb.events.DeliverDue(ctx, now)) //nolint:gosec // bounded batch
	}
	return summary, nil
}

type reconcileOutcome int

const (
	reconciledUntouched reconcileOutcome = iota
	reconciledPaid
	reconciledExpired
	reconciledFailed
)

// reconcileOne settles what it can of one order. An order it leaves as it
// was is backed off, so the next run starts with orders not yet looked at.
func (pb *paymentBusiness) reconcileOne(ctx context.Context, order *models.Order, now time.Time) reconcileOutcome {
	outcome, inFlight := pb.reconcileOrder(ctx, order, now)
	if outcome == reconciledUntouched || outcome == reconciledFailed {
		pb.deferReconcile(ctx, order, now, inFlight)
	}
	return outcome
}

func (pb *paymentBusiness) reconcileOrder(
	ctx context.Context,
	order *models.Order,
	now time.Time,
) (reconcileOutcome, bool) {
	inFlight := false
	if pb.gateway != nil {
		outcome, flight, decided := pb.reconcileSessions(ctx, order, now)
		if decided {
			return outcome, flight
		}
		inFlight = flight
	}

	// Only an order with nothing paid is held by the payment window; a
	// part-paid one is governed by its balance deadline, and a cancelled
	// one is only watched for late payments.
	if order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) || !pb.expired(order, now) {
		return reconciledUntouched, inFlight
	}
	// A prompt still outstanding at the provider gets a grace period before
	// the reservation is released.
	if inFlight && now.Before(pb.dueAt(order).Add(pb.policy.SettleGrace)) {
		return reconciledUntouched, inFlight
	}
	return pb.expire(ctx, order, now), inFlight
}

// expire cancels an unpaid order whose payment window lapsed.
func (pb *paymentBusiness) expire(ctx context.Context, order *models.Order, now time.Time) reconcileOutcome {
	log := util.Log(ctx).WithField("order_id", order.GetID())
	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		log.WithError(err).Warn("reconcile: could not load shop")
		return reconciledFailed
	}
	cancelled, plan, err := pb.orderRepo.Cancel(ctx, order.GetID(), now,
		func(current *models.Order, salePaid int64) (*repository.CancelPlan, error) {
			// Anything paid meanwhile keeps the order.
			if current.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) ||
				current.AmountPaidNanos > 0 || salePaid > 0 {
				return nil, nil //nolint:nilnil // nothing to expire
			}
			return &repository.CancelPlan{
				Reason:        cancelReasonExpired,
				PaymentStatus: int32(commercev1.PaymentStatus_PAYMENT_STATUS_EXPIRED),
				Events: []*models.OrderEvent{
					newOrderEvent(shop, current, commercev1.OrderEventType_ORDER_EVENT_TYPE_EXPIRED, 0),
				},
			}, nil
		})
	if err != nil {
		log.WithError(err).Warn("reconcile: could not expire order")
		return reconciledFailed
	}
	if plan == nil {
		return reconciledUntouched
	}
	pb.notifier.OrderPaymentExpired(ctx, shop, cancelled)
	if pb.events != nil {
		pb.events.Publish(ctx, shop, cancelled, nil, plan.Events)
	}
	return reconciledExpired
}

// deferReconcile backs off an order the run could not settle: doubling from
// reconcileBackoffBase per look, but never past the moment its payment
// window (plus grace, for a payment in flight) lapses, so expiry is on time.
func (pb *paymentBusiness) deferReconcile(ctx context.Context, order *models.Order, now time.Time, inFlight bool) {
	delay := reconcileBackoffBase
	for i := int32(0); i < order.ReconcileAttempts && delay < reconcileBackoffMax; i++ {
		delay *= 2
	}
	next := now.Add(min(delay, reconcileBackoffMax))
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		due := pb.dueAt(order)
		if inFlight {
			due = due.Add(pb.policy.SettleGrace)
		}
		if due.After(now) && due.Before(next) {
			next = due
		}
	}
	if err := pb.orderRepo.DeferReconcile(ctx, order.GetID(), next); err != nil {
		util.Log(ctx).WithError(err).WithField("order_id", order.GetID()).Warn("reconcile: could not back off order")
	}
}

// reconcileSessions applies any completed session. decided is true when
// that, or an unreadable session on an overdue unpaid order, settles the
// outcome; otherwise inFlight reports an outstanding prompt. A session that
// charged the wrong amount puts the order under staff review.
func (pb *paymentBusiness) reconcileSessions(
	ctx context.Context,
	order *models.Order,
	now time.Time,
) (reconcileOutcome, bool, bool) {
	log := util.Log(ctx).WithField("order_id", order.GetID())
	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		log.WithError(err).Warn("reconcile: could not list checkout sessions")
		return reconciledFailed, false, true
	}
	applied, applyErr := pb.applyCompleted(ctx, order, scan)
	if scan.mismatched > 0 {
		reason := "a checkout session charged a different amount from the one it was issued for"
		if flagErr := pb.orderRepo.FlagPaymentReview(ctx, order.GetID(), reason); flagErr != nil {
			log.WithError(flagErr).Warn("reconcile: could not flag order for review")
		}
	}
	if applyErr != nil {
		log.WithError(applyErr).Warn("reconcile: could not apply paid session")
		return reconciledFailed, scan.inFlight, true
	}
	if applied > 0 {
		return reconciledPaid, false, true
	}
	// Never release stock for an order whose payment state is unknown.
	if scan.unreadable > 0 && pb.expired(order, now) {
		return reconciledFailed, scan.inFlight, true
	}
	return reconciledUntouched, scan.inFlight, false
}

// flagOverdue raises the overdue signal once. When the order's policy says
// so and nothing has shipped, it also cancels the order, releases its stock
// and refunds what was paid; goods already out are never restocked.
func (pb *paymentBusiness) flagOverdue(ctx context.Context, order *models.Order, now time.Time) bool {
	log := util.Log(ctx).WithField("order_id", order.GetID())
	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		log.WithError(err).Warn("reconcile: could not load shop")
		return false
	}

	if order.PaymentPolicy != nil && order.PaymentPolicy.CancelWhenOverdue {
		cancelled, cancelErr := pb.cancelOverdue(ctx, shop, order, now)
		if cancelErr != nil {
			log.WithError(cancelErr).Warn("reconcile: could not cancel overdue order")
			return false
		}
		if cancelled {
			return true
		}
	}

	events := []*models.OrderEvent{
		newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_BALANCE_OVERDUE, 0),
	}
	ok, err := pb.orderRepo.MarkOverdue(ctx, order.GetID(), now, events)
	if err != nil {
		log.WithError(err).Warn("reconcile: could not flag overdue order")
		return false
	}
	if ok && pb.events != nil {
		pb.events.Publish(ctx, shop, order, nil, events)
	}
	return ok
}

// cancelOverdue cancels an overdue order whose goods are all still in the
// shop, restocks it and refunds what was paid. It reports false when the
// order is only to be flagged.
func (pb *paymentBusiness) cancelOverdue(
	ctx context.Context,
	shop *models.Shop,
	order *models.Order,
	now time.Time,
) (bool, error) {
	cancelled, plan, err := pb.orderRepo.Cancel(ctx, order.GetID(), now,
		func(current *models.Order, salePaid int64) (*repository.CancelPlan, error) {
			if current.OverdueAt != nil || shipped(current) ||
				current.Status != int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED) {
				return nil, nil //nolint:nilnil // only flagged
			}
			plan := &repository.CancelPlan{
				Reason:      cancelReasonOverdue,
				MarkOverdue: true,
				Events: []*models.OrderEvent{
					newOrderEvent(shop, current, commercev1.OrderEventType_ORDER_EVENT_TYPE_BALANCE_OVERDUE, 0),
					newOrderEvent(shop, current, commercev1.OrderEventType_ORDER_EVENT_TYPE_CANCELLED, 0),
				},
			}
			withRefund(plan, current, salePaid)
			return plan, nil
		})
	if err != nil || plan == nil {
		return false, err
	}
	pb.notifier.OrderCancelled(ctx, shop, cancelled, cancelReasonOverdue)
	if pb.events != nil {
		pb.events.Publish(ctx, shop, cancelled, nil, plan.Events)
	}
	pb.sendOrderRefunds(ctx, order.GetID())
	return true, nil
}

func (pb *paymentBusiness) dueAt(order *models.Order) time.Time {
	if order.PaymentDueAt != nil {
		return *order.PaymentDueAt
	}
	return order.CreatedAt.Add(pb.policy.PaymentWindow)
}

func (pb *paymentBusiness) expired(order *models.Order, now time.Time) bool {
	return now.After(pb.dueAt(order))
}

// connectCheckoutGateway adapts the generated Connect client.
type connectCheckoutGateway struct {
	cli checkoutClient
}

// checkoutClient is the subset of the generated client used here.
type checkoutClient interface {
	CreateCheckoutSession(
		context.Context,
		*checkoutv1.CreateCheckoutSessionRequest,
	) (*checkoutv1.CreateCheckoutSessionResponse, error)
	GetCheckoutSession(
		context.Context,
		*checkoutv1.GetCheckoutSessionRequest,
	) (*checkoutv1.GetCheckoutSessionResponse, error)
}

// NewConnectCheckoutGateway wraps a generated checkout client. A nil client
// yields a nil gateway so callers can treat "not configured" uniformly.
func NewConnectCheckoutGateway(cli checkoutClient) CheckoutGateway {
	if cli == nil {
		return nil
	}
	return &connectCheckoutGateway{cli: cli}
}

func (g *connectCheckoutGateway) CreateSession(
	ctx context.Context,
	req *checkoutv1.CreateCheckoutSessionRequest,
) (*checkoutv1.CheckoutSession, error) {
	resp, err := g.cli.CreateCheckoutSession(ctx, req)
	if err != nil {
		return nil, err
	}
	return resp.GetData(), nil
}

func (g *connectCheckoutGateway) GetSession(ctx context.Context, ref string) (*checkoutv1.CheckoutSession, error) {
	resp, err := g.cli.GetCheckoutSession(ctx,
		checkoutv1.GetCheckoutSessionRequest_builder{Ref: ref}.Build(),
	)
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return nil, fmt.Errorf("checkout session %s: %w", ref, err)
		}
		return nil, err
	}
	return resp.GetData(), nil
}
