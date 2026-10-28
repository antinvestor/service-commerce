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
	"io"
	"slices"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// RefundOutcome is where the payment service says a refund stands.
type RefundOutcome int

const (
	// RefundOutcomePending means the payment service has the refund and has
	// not finished it.
	RefundOutcomePending RefundOutcome = iota
	// RefundOutcomeSucceeded means the money reached the buyer.
	RefundOutcomeSucceeded
	// RefundOutcomeFailed means the payment service gave up on it.
	RefundOutcomeFailed
)

// RefundState is a refund as the payment service holds it.
type RefundState struct {
	PaymentID string
	Outcome   RefundOutcome
}

// ErrRefundLookupInconclusive is returned when a search by reference could
// neither find a refund nor rule it out; the caller waits and asks again.
var ErrRefundLookupInconclusive = errors.New("refund lookup inconclusive")

// RefundGateway pays refunds out through the platform payment service. The
// payee is the order's buyer (profile, and the order's contact when it has
// one); the payment service picks the route.
type RefundGateway interface {
	// Send hands the refund to the payment service.
	Send(ctx context.Context, refund *models.OrderRefund) (*RefundState, error)
	// Status asks how a sent refund stands.
	Status(ctx context.Context, refund *models.OrderRefund) (*RefundState, error)
	// FindByReference finds the payment the service holds for the refund's
	// reference; nil when it holds none, ErrRefundLookupInconclusive when
	// it cannot tell.
	FindByReference(ctx context.Context, refund *models.OrderRefund) (*RefundState, error)
}

// refundClaimGrace is how long an attempt that claimed a refund but never
// recorded the payment service's answer is given before the service is asked
// whether it holds the refund. The payment service saves a payout through
// its queue, so an immediate search can miss one that did land.
const refundClaimGrace = 10 * time.Minute

// refundBatchSize caps the refunds looked at in one reconcile run.
const refundBatchSize = 100

// refundSummary counts what one pass over refunds did.
type refundSummary struct {
	sent      int32
	confirmed int32
}

// processRefunds sends pending refunds and asks after sent ones.
func (pb *paymentBusiness) processRefunds(ctx context.Context, shopID string, now time.Time) refundSummary {
	var summary refundSummary
	refunds, err := pb.orderRepo.ListOpenRefunds(ctx, shopID, refundBatchSize)
	if err != nil {
		util.Log(ctx).WithError(err).Warn("reconcile: could not list open refunds")
		return summary
	}
	if len(refunds) > 0 && pb.refunds == nil {
		util.Log(ctx).WithField("open_refunds", len(refunds)).
			Error("refunds are owed but the payment service is not configured; set PAYMENT_SERVICE_URI")
		return summary
	}
	for _, refund := range refunds {
		if ctx.Err() != nil {
			break
		}
		sent, confirmed := pb.processRefund(ctx, refund, now)
		if sent {
			summary.sent++
		}
		if confirmed {
			summary.confirmed++
		}
	}
	return summary
}

// sendOrderRefunds sends an order's pending refunds now rather than at the
// next reconcile run. Best effort: whatever is left is picked up then.
func (pb *paymentBusiness) sendOrderRefunds(ctx context.Context, orderID string) {
	if pb.refunds == nil {
		return
	}
	refunds, err := pb.orderRepo.ListRefunds(ctx, orderID)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("order_id", orderID).Warn("could not list the order's refunds")
		return
	}
	now := time.Now()
	for _, refund := range refunds {
		if refund.Status == models.RefundPending && refund.SentAt == nil {
			pb.processRefund(ctx, refund, now)
		}
	}
}

// processRefund moves one refund on and reports whether it was handed to
// the payment service and whether it was confirmed.
func (pb *paymentBusiness) processRefund(
	ctx context.Context,
	refund *models.OrderRefund,
	now time.Time,
) (bool, bool) {
	log := util.Log(ctx).WithField("refund_id", refund.GetID()).WithField("order_id", refund.OrderID)
	switch {
	case refund.Status == models.RefundSent && refund.PaymentID != "":
		state, err := pb.refunds.Status(ctx, refund)
		if err != nil {
			log.WithError(err).Warn("could not ask the payment service about a refund")
			pb.touchRefund(ctx, refund, err)
			return false, false
		}
		return false, pb.settleRefund(ctx, refund, state, now)

	case refund.SentAt == nil:
		claimed, err := pb.orderRepo.ClaimRefund(ctx, refund.GetID(), now)
		if err != nil || !claimed {
			if err != nil {
				log.WithError(err).Warn("could not claim a refund")
			}
			return false, false
		}
		return pb.sendRefund(ctx, refund, now)

	case now.Sub(*refund.SentAt) < refundClaimGrace:
		// An attempt is under way, or only just died; leave it be.
		return false, false

	default:
		// An earlier attempt claimed the refund but never recorded the
		// payment service's answer. Only the payment service can say
		// whether that attempt landed; a blind resend could pay twice.
		state, err := pb.refunds.FindByReference(ctx, refund)
		if err != nil {
			log.WithError(err).Warn("could not confirm an earlier refund attempt")
			pb.touchRefund(ctx, refund, err)
			return false, false
		}
		if state != nil {
			if recErr := pb.orderRepo.RecordRefundSent(ctx, refund.GetID(), state.PaymentID); recErr != nil {
				log.WithError(recErr).Warn("could not record a refund's payment")
			}
			return false, pb.settleRefund(ctx, refund, state, now)
		}
		retaken, err := pb.orderRepo.RetakeRefund(ctx, refund.GetID(), *refund.SentAt, now)
		if err != nil || !retaken {
			return false, false
		}
		log.Warn("earlier refund attempt never reached the payment service; sending it now")
		return pb.sendRefund(ctx, refund, now)
	}
}

// sendRefund hands a claimed refund to the payment service.
func (pb *paymentBusiness) sendRefund(ctx context.Context, refund *models.OrderRefund, now time.Time) (bool, bool) {
	log := util.Log(ctx).WithField("refund_id", refund.GetID()).WithField("order_id", refund.OrderID)
	state, err := pb.refunds.Send(ctx, refund)
	if err != nil {
		// The claim stays: the payment service may have taken the refund
		// before the error. A later run asks it by reference.
		log.WithError(err).Warn("refund send failed; it is confirmed by reference later")
		pb.touchRefund(ctx, refund, err)
		return false, false
	}
	if state.PaymentID != "" {
		if recErr := pb.orderRepo.RecordRefundSent(ctx, refund.GetID(), state.PaymentID); recErr != nil {
			log.WithError(recErr).Warn("could not record a refund's payment")
		}
	}
	return true, pb.settleRefund(ctx, refund, state, now)
}

// settleRefund records what the payment service says and reports whether
// the refund was newly confirmed.
func (pb *paymentBusiness) settleRefund(
	ctx context.Context,
	refund *models.OrderRefund,
	state *RefundState,
	now time.Time,
) bool {
	log := util.Log(ctx).WithField("refund_id", refund.GetID()).WithField("order_id", refund.OrderID)
	switch state.Outcome {
	case RefundOutcomeFailed:
		log.WithField("payment_id", state.PaymentID).
			Error("the payment service failed a refund; staff must pay the buyer back")
		if err := pb.orderRepo.FailRefund(ctx, refund.GetID(), state.PaymentID,
			"the payment service failed the refund"); err != nil {
			log.WithError(err).Warn("could not record a failed refund")
		}
		return false
	case RefundOutcomeSucceeded:
		return pb.confirmRefund(ctx, refund, now)
	case RefundOutcomePending:
		pb.touchRefund(ctx, refund, nil)
		return false
	default:
		return false
	}
}

func (pb *paymentBusiness) confirmRefund(ctx context.Context, refund *models.OrderRefund, now time.Time) bool {
	log := util.Log(ctx).WithField("refund_id", refund.GetID()).WithField("order_id", refund.OrderID)
	shop, err := pb.shopRepo.GetByID(ctx, refund.ShopID)
	if err != nil {
		log.WithError(err).Warn("could not load the shop of a confirmed refund")
		return false
	}
	order, events, err := pb.orderRepo.ConfirmRefund(ctx, refund.GetID(), now,
		func(order *models.Order, r *models.OrderRefund) []*models.OrderEvent {
			return []*models.OrderEvent{
				newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_REFUNDED, r.AmountNanos),
			}
		})
	if err != nil {
		log.WithError(err).Warn("could not record a confirmed refund")
		return false
	}
	if order == nil {
		return false
	}
	if pb.events != nil {
		pb.events.Publish(ctx, shop, order, nil, events)
	}
	return true
}

func (pb *paymentBusiness) touchRefund(ctx context.Context, refund *models.OrderRefund, cause error) {
	reason := ""
	if cause != nil {
		reason = cause.Error()
	}
	if err := pb.orderRepo.TouchRefund(ctx, refund.GetID(), reason); err != nil {
		util.Log(ctx).WithError(err).WithField("refund_id", refund.GetID()).Warn("could not record a refund check")
	}
}

// RefundResolution is how staff settle a refund the payment service failed.
type RefundResolution struct {
	OrderID    string
	RefundID   string
	Resolution commercev1.OrderRefundResolution
	Note       string
	// ResolvedBy is the staff member settling it.
	ResolvedBy string
}

func (pb *paymentBusiness) ResolveOrderRefund(
	ctx context.Context,
	resolution RefundResolution,
) (*commercev1.Order, error) {
	refunds, err := pb.orderRepo.ListRefunds(ctx, resolution.OrderID)
	if err != nil {
		return nil, err
	}
	idx := slices.IndexFunc(refunds, func(r *models.OrderRefund) bool { return r.GetID() == resolution.RefundID })
	if idx < 0 {
		return nil, connect.NewError(connect.CodeNotFound, "the order has no such refund")
	}
	refund := refunds[idx]
	if refund.Status != models.RefundFailed {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"only a refund the payment service failed can be resolved")
	}
	note := strings.TrimSpace(resolution.Note)

	switch resolution.Resolution {
	case commercev1.OrderRefundResolution_ORDER_REFUND_RESOLUTION_RETRY:
		if pb.refunds == nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				"refunds are not configured; pay the buyer back and record it")
		}
		requeued, reqErr := pb.orderRepo.RequeueRefund(ctx, refund.GetID(), note)
		if reqErr != nil {
			return nil, reqErr
		}
		if !requeued {
			return nil, connect.NewError(connect.CodeFailedPrecondition, "the refund changed; reload the order")
		}
		pb.sendOrderRefunds(ctx, resolution.OrderID)

	case commercev1.OrderRefundResolution_ORDER_REFUND_RESOLUTION_PAID_BACK:
		shop, shopErr := pb.shopRepo.GetByID(ctx, refund.ShopID)
		if shopErr != nil {
			return nil, data.ErrorConvertToAPI(shopErr)
		}
		order, events, confirmErr := pb.orderRepo.RecordRefundPaidBack(ctx, refund.GetID(),
			resolution.ResolvedBy, note, time.Now(),
			func(order *models.Order, r *models.OrderRefund) []*models.OrderEvent {
				return []*models.OrderEvent{
					newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_REFUNDED, r.AmountNanos),
				}
			})
		if confirmErr != nil {
			return nil, confirmErr
		}
		if order == nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, "the refund changed; reload the order")
		}
		if pb.events != nil {
			pb.events.Publish(ctx, shop, order, nil, events)
		}

	case commercev1.OrderRefundResolution_ORDER_REFUND_RESOLUTION_UNSPECIFIED:
		return nil, connect.NewError(connect.CodeInvalidArgument, "resolution is RETRY or PAID_BACK")
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, "resolution is RETRY or PAID_BACK")
	}
	return pb.refresh(ctx, resolution.OrderID)
}

// --- Connect-backed refund gateway ---

type connectRefundGateway struct {
	cli paymentv1connect.PaymentServiceClient
}

// NewConnectRefundGateway wraps a payment client; nil in, nil out.
func NewConnectRefundGateway(cli paymentv1connect.PaymentServiceClient) RefundGateway {
	if cli == nil {
		return nil
	}
	return &connectRefundGateway{cli: cli}
}

// refundSearchLimit caps the payments a reference search reads.
const refundSearchLimit = 100

// paymentEntityType names a payment to the payment service's Status.
const paymentEntityType = "payment"

// inTenancy makes the payment service see the refund's tenant and partition,
// which decide how the payout is routed, whoever is calling.
func inTenancy(ctx context.Context, refund *models.OrderRefund) context.Context {
	return util.SetTenancy(ctx, &security.AuthenticationClaims{
		TenantID:    refund.TenantID,
		PartitionID: refund.PartitionID,
		AccessID:    refund.AccessID,
	})
}

func (g *connectRefundGateway) Send(ctx context.Context, refund *models.OrderRefund) (*RefundState, error) {
	resp, err := g.cli.Send(inTenancy(ctx, refund), paymentv1.SendRequest_builder{
		Data: paymentv1.Payment_builder{
			ReferenceId: refund.PaymentReference(),
			Recipient: commonv1.ContactLink_builder{
				ProfileId: refund.ProfileID,
				ContactId: refund.ContactID,
			}.Build(),
			Amount:   models.MoneyFromNanos(refund.Currency, refund.AmountNanos),
			Outbound: true,
		}.Build(),
	}.Build())
	if err != nil {
		return nil, err
	}
	return &RefundState{PaymentID: resp.GetData().GetId(), Outcome: outcomeOf(resp.GetData().GetStatus())}, nil
}

func (g *connectRefundGateway) Status(ctx context.Context, refund *models.OrderRefund) (*RefundState, error) {
	extras, _ := structpb.NewStruct(map[string]any{"entity_type": paymentEntityType})
	resp, err := g.cli.Status(inTenancy(ctx, refund), commonv1.StatusRequest_builder{
		Id:     refund.PaymentID,
		Extras: extras,
	}.Build())
	if err != nil {
		return nil, err
	}
	return &RefundState{PaymentID: refund.PaymentID, Outcome: outcomeOf(resp.GetStatus())}, nil
}

func (g *connectRefundGateway) FindByReference(
	ctx context.Context,
	refund *models.OrderRefund,
) (*RefundState, error) {
	stream, err := g.cli.Search(inTenancy(ctx, refund), commonv1.SearchRequest_builder{
		Query:      refund.PaymentReference(),
		Properties: []string{"reference_id"},
		Cursor:     commonv1.PageCursor_builder{Limit: refundSearchLimit}.Build(),
	}.Build())
	if err != nil {
		return nil, err
	}
	defer func() { _ = stream.Close() }()
	seen := 0
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				break
			}
			return nil, recvErr
		}
		for _, p := range msg.GetData() {
			seen++
			if p.GetReferenceId() == refund.PaymentReference() && p.GetOutbound() && refundMatches(p, refund) {
				return &RefundState{PaymentID: p.GetId(), Outcome: outcomeOf(p.GetStatus())}, nil
			}
		}
	}
	if seen > 0 {
		// The search also matches text, so other payments may have crowded
		// ours out: only an empty answer rules the refund out.
		return nil, ErrRefundLookupInconclusive
	}
	return nil, nil //nolint:nilnil // holding no payment is an answer
}

func refundMatches(p *paymentv1.Payment, refund *models.OrderRefund) bool {
	amount := p.GetAmount()
	return amount != nil && strings.EqualFold(amount.GetCurrencyCode(), refund.Currency) &&
		models.MoneyNanos(amount.GetUnits(), amount.GetNanos()) == refund.AmountNanos
}

func outcomeOf(status commonv1.STATUS) RefundOutcome {
	switch status { //nolint:exhaustive // every other status is still in progress
	case commonv1.STATUS_SUCCESSFUL:
		return RefundOutcomeSucceeded
	case commonv1.STATUS_FAILED:
		return RefundOutcomeFailed
	default:
		return RefundOutcomePending
	}
}
