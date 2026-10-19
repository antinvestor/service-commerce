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
	"errors"
	"fmt"
	"math/bits"
	"slices"
	"time"

	"connectrpc.com/connect"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

const (
	fullPercent  int32 = 100
	nanosPerCent int64 = 10_000_000
	hoursPerDay        = 24
)

// validatePaymentPolicy rejects values the proto validation would, for
// callers that bypass the interceptor (tests, internal callers).
func validatePaymentPolicy(p *commercev1.PaymentPolicy) error {
	if p == nil {
		return nil
	}
	for name, v := range map[string]int32{
		"min_deposit_percent":    p.GetMinDepositPercent(),
		"min_instalment_percent": p.GetMinInstalmentPercent(),
		"fulfil_at_percent":      p.GetFulfilAtPercent(),
	} {
		if v < 0 || v > fullPercent {
			return connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("%s must be between 0 and 100", name))
		}
	}
	if p.GetBalanceDueDays() < 0 {
		return connect.NewError(connect.CodeInvalidArgument, errors.New("balance_due_days must not be negative"))
	}
	for _, t := range p.GetSignalThresholds() {
		if t <= 0 || t > fullPercent {
			return connect.NewError(connect.CodeInvalidArgument,
				errors.New("signal thresholds must be between 1 and 100"))
		}
	}
	return nil
}

// mergePolicies folds the policies of an order's lines into the strictest
// one. A nil entry is a line that must be paid in full. All nil yields nil.
func mergePolicies(policies []*models.PaymentPolicy) *models.PaymentPolicy {
	if !slices.ContainsFunc(policies, func(p *models.PaymentPolicy) bool { return p != nil }) {
		return nil
	}
	merged := &models.PaymentPolicy{AllowInstalments: true}
	fulfilAt := int32(0)
	for _, p := range policies {
		if p == nil {
			p = &models.PaymentPolicy{}
		}
		merged.AllowInstalments = merged.AllowInstalments && p.AllowInstalments
		merged.MinDepositPercent = max(merged.MinDepositPercent, p.MinDepositPercent)
		merged.MinInstalmentPercent = max(merged.MinInstalmentPercent, p.MinInstalmentPercent)
		if p.BalanceDueDays > 0 && (merged.BalanceDueDays == 0 || p.BalanceDueDays < merged.BalanceDueDays) {
			merged.BalanceDueDays = p.BalanceDueDays
		}
		fulfilAt = max(fulfilAt, fulfilMark(p))
		merged.SignalThresholds = append(merged.SignalThresholds, p.SignalThresholds...)
		merged.CancelWhenOverdue = merged.CancelWhenOverdue || p.CancelWhenOverdue
	}
	if fulfilAt < fullPercent {
		merged.FulfilAtPercent = fulfilAt
	}
	slices.Sort(merged.SignalThresholds)
	merged.SignalThresholds = slices.Compact(merged.SignalThresholds)
	return merged
}

// fulfilMark is the paid share needed before fulfilment; 0 means all.
func fulfilMark(p *models.PaymentPolicy) int32 {
	if p == nil || p.FulfilAtPercent <= 0 {
		return fullPercent
	}
	return p.FulfilAtPercent
}

// percentOfCeilCents is pct percent of total nanos, rounded up to the cent.
func percentOfCeilCents(total int64, pct int32) int64 {
	if total <= 0 || pct <= 0 {
		return 0
	}
	hi, lo := bits.Mul64(uint64(total), uint64(pct))
	denominator := uint64(fullPercent) * uint64(nanosPerCent)
	quo, rem := bits.Div64(hi, lo, denominator)
	if rem > 0 {
		quo++
	}
	return int64(quo) * nanosPerCent //nolint:gosec // bounded by total
}

// instalmentRange is the smallest and largest amount the next instalment on
// order may be. Without instalments both are the balance.
func instalmentRange(order *models.Order) (int64, int64) {
	balance := order.BalanceNanos()
	policy := order.PaymentPolicy
	if policy == nil || !policy.AllowInstalments {
		return balance, balance
	}
	pct := policy.MinInstalmentPercent
	if order.AmountPaidNanos == 0 {
		pct = policy.MinDepositPercent
	}
	minimum := max(percentOfCeilCents(order.TotalNanosValue(), pct), nanosPerCent)
	return min(minimum, balance), balance
}

// newOrderEvent snapshots order into an event of type t.
func newOrderEvent(
	shop *models.Shop,
	order *models.Order,
	t commercev1.OrderEventType,
	paymentNanos int64,
) *models.OrderEvent {
	delivery := models.EventDeliveryNotRequired
	if shop != nil && shop.WebhookURL != "" {
		delivery = models.EventDeliveryPending
	}
	return &models.OrderEvent{
		ShopID:          order.ShopID,
		OrderID:         order.GetID(),
		OrderNumber:     order.OrderNumber,
		Type:            int32(t),
		PaidPercent:     order.PaidPercent(),
		Currency:        order.TotalCurrency,
		AmountPaidNanos: order.AmountPaidNanos,
		BalanceNanos:    order.BalanceNanos(),
		PaymentNanos:    paymentNanos,
		Delivery:        delivery,
	}
}

// paymentTransition moves an order forward after an instalment and lists
// the signals it raises. It runs inside ApplyPayment with the order locked
// and AmountPaidNanos already including the payment.
func paymentTransition(shop *models.Shop, now time.Time) repository.PaymentTransition {
	return func(order *models.Order, payment *models.OrderPayment) []*models.OrderEvent {
		events := []*models.OrderEvent{
			newOrderEvent(
				shop,
				order,
				commercev1.OrderEventType_ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
				payment.AmountNanos,
			),
		}
		// Money that arrives on a cancelled order is owed back to the buyer.
		if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
			return append(events,
				newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_OVERPAID, payment.AmountNanos))
		}

		if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
			order.Status = int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED)
		}
		order.PaymentDueAt = nil
		if order.PaymentID == "" {
			order.PaymentID = paymentReference(payment)
		}

		before := order.AmountPaidNanos - payment.AmountNanos
		events = append(events, depositEvents(shop, order, before, now)...)
		events = append(events, thresholdEvents(shop, order, before)...)
		return append(events, settlementEvents(shop, order, before, now)...)
	}
}

// depositEvents starts the balance clock on the first of several
// instalments.
func depositEvents(shop *models.Shop, order *models.Order, before int64, now time.Time) []*models.OrderEvent {
	if before != 0 || order.AmountPaidNanos >= order.TotalNanosValue() {
		return nil
	}
	if days := policyBalanceDays(order.PaymentPolicy); days > 0 && order.BalanceDueAt == nil {
		due := now.Add(time.Duration(days) * hoursPerDay * time.Hour)
		order.BalanceDueAt = &due
	}
	return []*models.OrderEvent{newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_DEPOSIT_PAID, 0)}
}

// thresholdEvents signals every policy mark the payment crossed, and the
// fulfilment mark when it is reached before full payment.
func thresholdEvents(shop *models.Shop, order *models.Order, before int64) []*models.OrderEvent {
	total, after := order.TotalNanosValue(), order.AmountPaidNanos
	beforePct, afterPct := models.PercentOf(before, total), models.PercentOf(after, total)
	crossed := func(mark int32) bool { return beforePct < mark && mark <= afterPct }

	var events []*models.OrderEvent
	if order.PaymentPolicy != nil {
		for _, t := range order.PaymentPolicy.SignalThresholds {
			if crossed(t) {
				event := newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED, 0)
				event.ThresholdPercent = t
				events = append(events, event)
			}
		}
	}
	if mark := fulfilMark(order.PaymentPolicy); mark < fullPercent && after < total && crossed(mark) {
		events = append(events,
			newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_FULFILMENT_RELEASED, 0))
	}
	return events
}

// settlementEvents sets the payment status and signals full payment and
// any excess.
func settlementEvents(shop *models.Shop, order *models.Order, before int64, now time.Time) []*models.OrderEvent {
	total, after := order.TotalNanosValue(), order.AmountPaidNanos
	if after < total {
		order.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_PARTIALLY_PAID)
		return nil
	}
	order.PaymentStatus = int32(commercev1.PaymentStatus_PAYMENT_STATUS_PAID)
	if order.PaidAt == nil {
		paidAt := now
		order.PaidAt = &paidAt
	}
	var events []*models.OrderEvent
	if before < total {
		events = append(events, newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_FULLY_PAID, 0))
	}
	if after > total {
		events = append(events,
			newOrderEvent(shop, order, commercev1.OrderEventType_ORDER_EVENT_TYPE_OVERPAID, after-total))
	}
	return events
}

func policyBalanceDays(p *models.PaymentPolicy) int32 {
	if p == nil || !p.AllowInstalments {
		return 0
	}
	return p.BalanceDueDays
}

func paymentReference(p *models.OrderPayment) string {
	if p.PaymentID != "" {
		return p.PaymentID
	}
	return p.Reference
}
