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
	"strings"
	"time"

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
	// PaymentWindow bounds how long stock stays reserved for an unpaid order.
	PaymentWindow time.Duration
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

type PaymentBusiness interface {
	// CheckoutOrder creates (or returns) the hosted checkout session for an
	// order awaiting payment.
	CheckoutOrder(ctx context.Context, req *commercev1.CheckoutOrderRequest) (*commercev1.Order, error)
	// ConfirmOrderPayment verifies the checkout session and marks the order
	// paid. Safe to call repeatedly.
	ConfirmOrderPayment(ctx context.Context, orderID string) (*commercev1.Order, error)
	// CancelOrder cancels an unfulfilled order and returns stock. Buyers may
	// only cancel unpaid orders; staff (staff=true) may cancel paid ones,
	// which records a refund for end-of-day posting.
	CancelOrder(ctx context.Context, orderID, reason string, staff bool) (*commercev1.Order, error)
	// ReconcilePayments settles orders whose sessions completed and expires
	// orders whose payment window lapsed.
	ReconcilePayments(ctx context.Context, shopID string, limit int) (*ReconcileSummary, error)
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
	if policy.ReconcileBatchSize <= 0 {
		policy.ReconcileBatchSize = defaultReconcileBatch
	}
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
	defaultReconcileBatch = 200
	orderRefPrefix        = "order:"
	metadataShopID        = "shop_id"
	metadataOrderNumber   = "order_number"
	metadataSource        = "source"
	sourceCommerce        = "service_commerce"
	cancelReasonExpired   = "payment window expired"
)

type paymentBusiness struct {
	orderRepo repository.OrderRepository
	shopRepo  repository.ShopRepository
	gateway   CheckoutGateway
	notifier  notifications.Notifier
	policy    PaymentPolicy
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

	// An existing live session is reused so a buyer who reloads does not get
	// a second reservation at the payment service.
	if order.PaymentSessionRef != "" {
		session, getErr := pb.gateway.GetSession(ctx, order.PaymentSessionRef)
		if getErr == nil && sessionReusable(session) {
			return order.ToAPI(), nil
		}
		if getErr != nil {
			util.Log(ctx).WithError(getErr).WithField("order_id", order.GetID()).
				Warn("could not load existing checkout session; creating a new one")
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

	order.PaymentSessionRef = session.GetRef()
	order.CheckoutURL = session.GetPageUrl()
	if _, updErr := pb.orderRepo.Update(ctx, order, "payment_session_ref", "checkout_url"); updErr != nil {
		return nil, data.ErrorConvertToAPI(updErr)
	}

	// The buyer's confirmation carries the payment link, so it goes out once
	// the session exists rather than at order creation.
	pb.notifier.OrderPlaced(ctx, shop, order)

	return order.ToAPI(), nil
}

func sessionReusable(s *checkoutv1.CheckoutSession) bool {
	if s == nil || s.GetPageUrl() == "" {
		return false
	}
	switch s.GetStatus() {
	case checkoutv1.SessionStatus_SESSION_STATUS_PENDING_UNSPECIFIED,
		checkoutv1.SessionStatus_SESSION_STATUS_PROCESSING:
		return true
	case checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED,
		checkoutv1.SessionStatus_SESSION_STATUS_FAILED,
		checkoutv1.SessionStatus_SESSION_STATUS_EXPIRED:
		return false
	default:
		return false
	}
}

func (pb *paymentBusiness) buildSessionRequest(
	shop *models.Shop,
	order *models.Order,
	req *commercev1.CheckoutOrderRequest,
) *checkoutv1.CreateCheckoutSessionRequest {
	returnURL := strings.TrimSpace(req.GetReturnUrl())
	if returnURL == "" {
		returnURL = shop.CheckoutReturnURL
	}
	if returnURL == "" {
		returnURL = pb.policy.DefaultReturnURL
	}
	returnURL = strings.ReplaceAll(returnURL, "{order_id}", order.GetID())

	payer := checkoutv1.PayerPrefill_builder{ProfileId: order.ProfileID}
	if order.ContactID != "" {
		payer.Contacts = []*checkoutv1.PayerContact{
			checkoutv1.PayerContact_builder{ContactId: order.ContactID}.Build(),
		}
	}

	return checkoutv1.CreateCheckoutSessionRequest_builder{
		Name:         fmt.Sprintf("%s order %s", shop.Name, order.OrderNumber),
		Description:  fmt.Sprintf("%d item(s) from %s", len(order.Lines), shop.Name),
		Amount:       models.MoneyToProto(order.TotalCurrency, order.TotalUnits, order.TotalNanos),
		AmountOption: checkoutv1.AmountOption_AMOUNT_OPTION_FIXED_UNSPECIFIED,
		OrderRef:     orderRefPrefix + order.GetID(),
		Metadata: map[string]string{
			metadataShopID:      shop.GetID(),
			metadataOrderNumber: order.OrderNumber,
			metadataSource:      sourceCommerce,
		},
		ReturnUrl: returnURL,
		Payer:     payer.Build(),
		Methods:   req.GetMethods(),
	}.Build()
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
	if order.PaymentSessionRef == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order has no checkout session"))
	}
	if pb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, errors.New("online payment is not configured"))
	}

	session, err := pb.gateway.GetSession(ctx, order.PaymentSessionRef)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("verify checkout session: %w", err))
	}
	if session.GetStatus() != checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("checkout session is %s, not completed", session.GetStatus()))
	}
	if err = pb.settle(ctx, order, session.GetPaymentId()); err != nil {
		return nil, err
	}
	return pb.refresh(ctx, order.GetID())
}

// settle marks the order paid and notifies both sides. Only the first caller
// transitions; concurrent confirmations are no-ops.
func (pb *paymentBusiness) settle(ctx context.Context, order *models.Order, paymentID string) error {
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

func (pb *paymentBusiness) refresh(ctx context.Context, orderID string) (*commercev1.Order, error) {
	order, err := pb.orderRepo.GetWithLines(ctx, orderID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return order.ToAPI(), nil
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

	if order.PaymentSessionRef != "" && pb.gateway != nil {
		session, err := pb.gateway.GetSession(ctx, order.PaymentSessionRef)
		switch {
		case err != nil:
			log.WithError(err).Warn("reconcile: could not load checkout session")
			return reconciledFailed
		case session.GetStatus() == checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED:
			if settleErr := pb.settle(ctx, order, session.GetPaymentId()); settleErr != nil {
				log.WithError(settleErr).Warn("reconcile: could not settle paid order")
				return reconciledFailed
			}
			return reconciledPaid
		}
	}

	if !pb.expired(order, now) {
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

func (pb *paymentBusiness) expired(order *models.Order, now time.Time) bool {
	if order.PaymentDueAt != nil {
		return now.After(*order.PaymentDueAt)
	}
	return now.Sub(order.CreatedAt) > pb.policy.PaymentWindow
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
