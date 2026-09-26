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
	"slices"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
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
}

// ReconcileSummary reports one reconcile run.
type ReconcileSummary struct {
	Examined int32
	Paid     int32
	Expired  int32
	Failed   int32
}

// PaymentReturn is the outcome of a buyer returning from hosted checkout.
type PaymentReturn struct {
	Order *commercev1.Order
	// RedirectURL is the storefront page to forward the buyer to; empty when
	// commerce should render the status itself.
	RedirectURL string
}

type PaymentBusiness interface {
	// CheckoutOrder creates (or returns) the hosted checkout session for an
	// order awaiting payment.
	CheckoutOrder(ctx context.Context, req *commercev1.CheckoutOrderRequest) (*commercev1.Order, error)
	// ConfirmOrderPayment verifies the checkout sessions and marks the order
	// paid. Safe to call repeatedly.
	ConfirmOrderPayment(ctx context.Context, orderID string) (*commercev1.Order, error)
	// CancelOrder cancels an unfulfilled order and returns stock. Buyers may
	// only cancel unpaid orders; staff (staff=true) may cancel paid ones,
	// which records a refund for end-of-day posting.
	CancelOrder(ctx context.Context, orderID, reason string, staff bool) (*commercev1.Order, error)
	// ReconcilePayments settles orders whose sessions completed and expires
	// orders whose payment window lapsed.
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
	notifier notifications.Notifier,
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
	policy.ReturnBaseURL = strings.TrimRight(strings.TrimSpace(policy.ReturnBaseURL), "/")
	return &paymentBusiness{
		orderRepo: orderRepo,
		shopRepo:  shopRepo,
		gateway:   gateway,
		notifier:  notifier,
		policy:    policy,
	}
}

const (
	defaultPaymentWindow  = 45 * time.Minute
	defaultSettleGrace    = time.Hour
	defaultReconcileBatch = 200
	orderRefPrefix        = "order:"
	metadataShopID        = "shop_id"
	metadataOrderNumber   = "order_number"
	metadataSource        = "source"
	metadataReturnTo      = "return_to"
	sourceCommerce        = "service_commerce"
	cancelReasonExpired   = "payment window expired"

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
	notifier  notifications.Notifier
	policy    PaymentPolicy
}

// --- session scan ---

// sessionScan is what the checkout service knows about every session issued
// for an order.
type sessionScan struct {
	refs []string
	// sessions holds each session that could be read, by ref.
	sessions map[string]*checkoutv1.CheckoutSession
	// completed is the first session found paid.
	completed *checkoutv1.CheckoutSession
	// inFlight means a payment prompt went out on some session and the
	// provider has not reported a final outcome yet.
	inFlight bool
	// unreadable counts sessions that failed to load for a reason other than
	// not existing; their state is unknown.
	unreadable int
	lastErr    error
}

func (pb *paymentBusiness) scanSessions(ctx context.Context, order *models.Order) (*sessionScan, error) {
	refs, err := pb.orderRepo.ListPaymentSessionRefs(ctx, order.GetID())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	// Orders created before session history was kept only carry the latest.
	if order.PaymentSessionRef != "" && !slices.Contains(refs, order.PaymentSessionRef) {
		refs = append(refs, order.PaymentSessionRef)
	}

	scan := &sessionScan{refs: refs, sessions: make(map[string]*checkoutv1.CheckoutSession, len(refs))}
	for _, ref := range refs {
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
			if scan.completed == nil {
				scan.completed = session
			}
		case checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING,
			checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED:
			// Checkout still recovers an expired session whose prompt later
			// succeeds, so a prompt on either status may yet be paid.
			if session.GetPromptId() != "" {
				scan.inFlight = true
			}
		case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
			checkoutv1.SessionStatus_SESSION_STATUS_FAILED:
		}
	}
	return scan, nil
}

func isNotFound(err error) bool {
	return connect.CodeOf(err) == connect.CodeNotFound || frame.ErrorIsNotFound(err)
}

// --- CheckoutOrder ---

func (pb *paymentBusiness) CheckoutOrder(
	ctx context.Context,
	req *commercev1.CheckoutOrderRequest,
) (*commercev1.Order, error) {
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, errors.New("online payment is not configured"))
	}

	order, err := pb.orderRepo.GetWithLines(ctx, req.GetOrderId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	switch {
	case order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID):
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order is already paid"))
	case order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT):
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order is not awaiting payment"))
	}

	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return nil, err
	}

	// A buyer may have paid an earlier link; never issue a new session for
	// an order that is already paid at the checkout service.
	if scan.completed != nil {
		if err = pb.settle(ctx, order, scan.completed); err != nil {
			return nil, err
		}
		return pb.refresh(ctx, order.GetID())
	}

	if order.PaymentSessionRef != "" {
		// A live session is reused so a buyer who reloads, or whose attempt
		// failed and wants to retry, stays on the same payment page.
		if current, ok := scan.sessions[order.PaymentSessionRef]; ok && sessionReusable(current) {
			return order.ToAPI(), nil
		}
		// If the current session could not be read its state is unknown;
		// issuing another could let the buyer pay twice.
		if scan.unreadable > 0 {
			return nil, connect.NewError(connect.CodeUnavailable,
				fmt.Errorf("verify existing checkout session: %w", scan.lastErr))
		}
	}

	shop, err := pb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	session, err := pb.gateway.CreateSession(ctx, pb.buildSessionRequest(shop, order, req))
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("create checkout session: %w", err))
	}

	if err = pb.orderRepo.AttachPaymentSession(ctx, order.GetID(), session.GetRef(), session.GetPageUrl()); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	order.PaymentSessionRef = session.GetRef()
	order.CheckoutURL = session.GetPageUrl()

	// The buyer's confirmation carries the payment link, so it goes out once
	// the session exists rather than at order creation.
	pb.notifier.OrderPlaced(ctx, shop, order)

	return order.ToAPI(), nil
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

func (pb *paymentBusiness) buildSessionRequest(
	shop *models.Shop,
	order *models.Order,
	req *commercev1.CheckoutOrderRequest,
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

	return checkoutv1.CreateCheckoutSessionRequest_builder{
		Name: truncateRunes(fmt.Sprintf("%s order %s", shop.Name, order.OrderNumber), sessionNameMaxLen),
		Description: truncateRunes(
			fmt.Sprintf("%d item(s) from %s", len(order.Lines), shop.Name),
			sessionDescriptionMaxLen,
		),
		Amount:       models.MoneyToProto(order.TotalCurrency, order.TotalUnits, order.TotalNanos),
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
	if order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order is not awaiting payment"))
	}
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, errors.New("online payment is not configured"))
	}

	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return nil, err
	}
	if len(scan.refs) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order has no checkout session"))
	}
	if scan.completed != nil {
		if err = pb.settle(ctx, order, scan.completed); err != nil {
			return nil, err
		}
		return pb.refresh(ctx, order.GetID())
	}
	if len(scan.sessions) == 0 && scan.unreadable > 0 {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("verify checkout session: %w", scan.lastErr))
	}

	status := checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED
	if current, ok := scan.sessions[order.PaymentSessionRef]; ok {
		status = current.GetStatus()
	}
	return nil, connect.NewError(connect.CodeFailedPrecondition,
		fmt.Errorf("checkout session is %s, not completed", status))
}

// settle marks the order paid and notifies both sides, after checking the
// session charged exactly the order total. Only the first caller
// transitions; concurrent confirmations are no-ops.
func (pb *paymentBusiness) settle(ctx context.Context, order *models.Order, session *checkoutv1.CheckoutSession) error {
	if !amountMatches(order, session.GetAmount()) {
		util.Log(ctx).
			WithField("order_id", order.GetID()).
			WithField("session_ref", session.GetRef()).
			WithField("order_total", fmt.Sprintf("%s %d.%09d", order.TotalCurrency, order.TotalUnits, order.TotalNanos)).
			WithField("session_amount", fmt.Sprintf("%s %d.%09d", session.GetAmount().GetCurrencyCode(),
				session.GetAmount().GetUnits(), session.GetAmount().GetNanos())).
			Error("checkout session amount does not match the order total; not settling")
		return connect.NewError(connect.CodeFailedPrecondition,
			errors.New("the payment amount does not match the order total"))
	}

	paymentID := session.GetPaymentId()
	if paymentID == "" {
		paymentID = session.GetRef()
	}

	paidAt := time.Now()
	ok, err := pb.orderRepo.MarkPaid(ctx, order.GetID(), paymentID, paidAt)
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}
	if !ok {
		return nil
	}
	order.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID)
	order.Status = int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED)
	order.PaymentID = paymentID
	order.PaidAt = &paidAt

	if shop, shopErr := pb.shopRepo.GetByID(ctx, order.ShopID); shopErr == nil {
		pb.notifier.OrderPaid(ctx, shop, order)
	}
	return nil
}

// amountMatches compares the charged amount with the order total to the cent,
// which is the precision hosted checkout charges at.
func amountMatches(order *models.Order, charged *commonv1.Money) bool {
	if charged == nil || !strings.EqualFold(charged.GetCurrencyCode(), order.TotalCurrency) {
		return false
	}
	return models.MoneyCents(charged.GetUnits(), charged.GetNanos()) ==
		models.MoneyCents(order.TotalUnits, order.TotalNanos)
}

func (pb *paymentBusiness) refresh(ctx context.Context, orderID string) (*commercev1.Order, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return order.ToAPI(), nil
}

// --- HandlePaymentReturn ---

func (pb *paymentBusiness) HandlePaymentReturn(
	ctx context.Context,
	orderID, sessionRef string,
) (*PaymentReturn, error) {
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, errors.New("online payment is not configured"))
	}
	if orderID == "" || sessionRef == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("order and session are required"))
	}

	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	refs, err := pb.orderRepo.ListPaymentSessionRefs(ctx, order.GetID())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if sessionRef != order.PaymentSessionRef && !slices.Contains(refs, sessionRef) {
		// Indistinguishable from a missing order so refs cannot be probed.
		return nil, connect.NewError(connect.CodeNotFound, errors.New("order not found"))
	}

	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		scan, scanErr := pb.scanSessions(ctx, order)
		if scanErr != nil {
			return nil, scanErr
		}
		if scan.completed != nil {
			// A mismatch is logged inside settle and the order stays unpaid.
			_ = pb.settle(ctx, order, scan.completed)
		}
	}

	result := &PaymentReturn{}
	if session, getErr := pb.gateway.GetSession(ctx, sessionRef); getErr == nil {
		result.RedirectURL = session.GetMetadata()[metadataReturnTo]
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
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_FULFILLED) ||
		order.FulfilmentStatus >= int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("order has shipped and can no longer be cancelled"))
	}

	paid := order.PaymentStatus == int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID)
	if paid && !staff {
		return nil, connect.NewError(connect.CodePermissionDenied,
			errors.New("a paid order can only be cancelled by the shop"))
	}

	// A buyer cancelling an unpaid order they have in fact just paid would
	// otherwise lose both the goods and the money.
	if !paid {
		settled, settleErr := pb.settleIfPaid(ctx, order)
		if settleErr != nil {
			return nil, settleErr
		}
		if settled && !staff {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				errors.New("the order has been paid and can only be cancelled by the shop"))
		}
		paid = settled
	}

	reason = strings.TrimSpace(reason)
	if reason == "" {
		reason = "cancelled"
	}

	var paymentStatus int32
	if paid {
		// The refund itself runs on the payment rail; commerce records the
		// intent so end-of-day posting reverses the sale.
		paymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_REFUNDED)
	}

	allowed := []int32{
		int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT),
		int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED),
	}
	ok, err := pb.orderRepo.CancelAndRestock(ctx, order.GetID(), allowed, paymentStatus, reason, time.Now())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if !ok {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order changed; reload and retry"))
	}

	if shop, shopErr := pb.shopRepo.GetByID(ctx, order.ShopID); shopErr == nil {
		pb.notifier.OrderCancelled(ctx, shop, order, reason)
	}
	return pb.refresh(ctx, order.GetID())
}

// settleIfPaid settles an order awaiting payment whose checkout already
// completed, reporting whether it did.
func (pb *paymentBusiness) settleIfPaid(ctx context.Context, order *models.Order) (bool, error) {
	if pb.gateway == nil || order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		return false, nil
	}
	scan, err := pb.scanSessions(ctx, order)
	if err != nil {
		return false, err
	}
	if scan.completed == nil {
		return false, nil
	}
	if err = pb.settle(ctx, order, scan.completed); err != nil {
		return false, err
	}
	return true, nil
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
	orders, err := pb.orderRepo.ListPendingPayment(ctx, shopID, limit)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	summary := &ReconcileSummary{Examined: int32(len(orders))} //nolint:gosec // bounded by limit
	now := time.Now()
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
	return summary, nil
}

type reconcileOutcome int

const (
	reconciledUntouched reconcileOutcome = iota
	reconciledPaid
	reconciledExpired
	reconciledFailed
)

func (pb *paymentBusiness) reconcileOne(ctx context.Context, order *models.Order, now time.Time) reconcileOutcome {
	log := util.Log(ctx).WithField("order_id", order.GetID())

	inFlight := false
	if pb.gateway != nil {
		outcome, flight, decided := pb.reconcileSessions(ctx, order, now)
		if decided {
			return outcome
		}
		inFlight = flight
	}

	if !pb.expired(order, now) {
		return reconciledUntouched
	}
	// A prompt still outstanding at the provider gets a grace period before
	// the reservation is released.
	if inFlight && now.Before(pb.dueAt(order).Add(pb.policy.SettleGrace)) {
		return reconciledUntouched
	}
	ok, err := pb.orderRepo.CancelAndRestock(ctx, order.GetID(),
		[]int32{int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT)},
		int32(commercev1.PaymentStatus_PAYMENT_STATUS_EXPIRED),
		cancelReasonExpired, now)
	if err != nil {
		log.WithError(err).Warn("reconcile: could not expire order")
		return reconciledFailed
	}
	if !ok {
		return reconciledUntouched
	}
	if shop, shopErr := pb.shopRepo.GetByID(ctx, order.ShopID); shopErr == nil {
		pb.notifier.OrderPaymentExpired(ctx, shop, order)
	}
	return reconciledExpired
}

// reconcileSessions settles the order if any session completed. decided is
// true when that, or an unreadable session on an overdue order, settles the
// outcome; otherwise inFlight reports an outstanding prompt.
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
	if scan.completed != nil {
		if settleErr := pb.settle(ctx, order, scan.completed); settleErr != nil {
			log.WithError(settleErr).Warn("reconcile: could not settle paid order")
			return reconciledFailed, false, true
		}
		return reconciledPaid, false, true
	}
	// Never release stock for an order whose payment state is unknown.
	if scan.unreadable > 0 && pb.expired(order, now) {
		return reconciledFailed, false, true
	}
	return reconciledUntouched, scan.inFlight, false
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
		*connect.Request[checkoutv1.CreateCheckoutSessionRequest],
	) (*connect.Response[checkoutv1.CreateCheckoutSessionResponse], error)
	GetCheckoutSession(
		context.Context,
		*connect.Request[checkoutv1.GetCheckoutSessionRequest],
	) (*connect.Response[checkoutv1.GetCheckoutSessionResponse], error)
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
	resp, err := g.cli.CreateCheckoutSession(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg.GetData(), nil
}

func (g *connectCheckoutGateway) GetSession(ctx context.Context, ref string) (*checkoutv1.CheckoutSession, error) {
	resp, err := g.cli.GetCheckoutSession(ctx, connect.NewRequest(
		checkoutv1.GetCheckoutSessionRequest_builder{Ref: ref}.Build(),
	))
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return nil, fmt.Errorf("checkout session %s: %w", ref, err)
		}
		return nil, err
	}
	return resp.Msg.GetData(), nil
}
