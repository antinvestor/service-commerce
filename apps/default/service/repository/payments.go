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

package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

const paymentStatusPartiallyPaid int32 = 6

// PaymentTransition decides what applying payment does to order. It is
// called inside the transaction with the order row locked and
// order.AmountPaidNanos already including the payment; it updates the
// order's state fields and returns the events to record.
type PaymentTransition func(order *models.Order, payment *models.OrderPayment) []*models.OrderEvent

// maxPaymentAttempts bounds how often ApplyPayment re-reads an order that
// another writer changed between its read and its write.
const maxPaymentAttempts = 5

// errOrderChanged aborts a payment transaction whose compare-and-set lost
// to a concurrent writer; the attempt is retried from a fresh read.
var errOrderChanged = errors.New("order changed concurrently")

// ApplyPayment uses optimistic concurrency rather than row locks, so it
// behaves the same on every database GORM supports: the order is read, the
// transition computed in memory, and the write succeeds only if the order's
// version is unchanged. The unique (order_id, reference) index makes a
// payment land at most once even when two callers race on the same one.
func (r *orderRepository) ApplyPayment(
	ctx context.Context,
	orderID string,
	payment *models.OrderPayment,
	transition PaymentTransition,
) (*models.Order, []*models.OrderEvent, bool, error) {
	for range maxPaymentAttempts {
		order, events, applied, err := r.applyPaymentOnce(ctx, orderID, *payment, transition)
		switch {
		case err == nil:
			return order, events, applied, nil
		case errors.Is(err, errOrderChanged), data.ErrorIsDuplicateKey(err):
			// Lost a race: re-read and decide again. A duplicate reference
			// is seen as already applied on the next read.
			continue
		default:
			return nil, nil, false, err
		}
	}
	return nil, nil, false, fmt.Errorf("apply payment to order %s: %w", orderID, errOrderChanged)
}

func (r *orderRepository) applyPaymentOnce(
	ctx context.Context,
	orderID string,
	payment models.OrderPayment,
	transition PaymentTransition,
) (*models.Order, []*models.OrderEvent, bool, error) {
	var (
		order   *models.Order
		events  []*models.OrderEvent
		applied bool
	)
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		order = &models.Order{}
		if err := tx.First(order, "id = ?", orderID).Error; err != nil {
			return fmt.Errorf("load order: %w", err)
		}

		var seen int64
		if err := tx.Model(&models.OrderPayment{}).
			Where("order_id = ? AND reference = ?", orderID, payment.Reference).
			Count(&seen).Error; err != nil {
			return fmt.Errorf("check payment reference: %w", err)
		}
		if seen > 0 {
			return nil
		}

		payment.OrderID = orderID
		payment.ShopID = order.ShopID
		// The payment belongs to the order's tenant, whoever applies it.
		payment.CopyPartitionInfo(&order.BaseModel)

		readVersion := order.Version
		cancelled := order.Status == orderStatusCancelled
		before := order.AmountPaidNanos
		order.AmountPaidNanos += payment.AmountNanos
		events = transition(order, &payment)
		order.Version = readVersion + 1

		// Whatever the order did not owe goes back to the buyer: all of it
		// on a cancelled order, else what went past the total.
		payment.ExcessNanos = excessOf(cancelled, before, order.AmountPaidNanos, order.TotalNanosValue())
		if err := tx.Create(&payment).Error; err != nil {
			return fmt.Errorf("record payment: %w", err)
		}
		if payment.ExcessNanos > 0 {
			refund := &models.OrderRefund{
				Reference:   models.RefundReferencePrefix + orderID + ":" + payment.Reference,
				Currency:    payment.Currency,
				AmountNanos: payment.ExcessNanos,
			}
			if err := createRefund(tx, order, refund); err != nil {
				return err
			}
		}

		result := tx.Model(&models.Order{}).
			Where("id = ? AND version = ?", orderID, readVersion).
			UpdateColumns(map[string]any{
				columnStatus:            order.Status,
				"payment_status":        order.PaymentStatus,
				columnPaymentID:         order.PaymentID,
				"paid_at":               order.PaidAt,
				"payment_due_at":        order.PaymentDueAt,
				"balance_due_at":        order.BalanceDueAt,
				"amount_paid_nanos":     order.AmountPaidNanos,
				columnNextReconcileAt:   nil,
				columnReconcileAttempts: 0,
				columnVersion:           order.Version,
				columnModifiedAt:        time.Now(),
			})
		if result.Error != nil {
			return fmt.Errorf("update order payment state: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return errOrderChanged
		}
		if err := createEvents(tx, events); err != nil {
			return err
		}
		applied = true
		return nil
	})
	if err != nil {
		return nil, nil, false, err
	}
	return order, events, applied, nil
}

// excessOf is the part of a payment that takes the amount paid past total,
// or the whole payment when the order is cancelled.
func excessOf(cancelled bool, before, after, total int64) int64 {
	if cancelled {
		return after - before
	}
	return max(after-total, 0) - max(before-total, 0)
}

func createEvents(tx *gorm.DB, events []*models.OrderEvent) error {
	if len(events) == 0 {
		return nil
	}
	if err := tx.Create(&events).Error; err != nil {
		return fmt.Errorf("record order events: %w", err)
	}
	return nil
}

func (r *orderRepository) ListPaymentSessions(
	ctx context.Context,
	orderID string,
) ([]*models.OrderPaymentSession, error) {
	var sessions []*models.OrderPaymentSession
	err := r.Pool().DB(ctx, false).
		Where("order_id = ?", orderID).
		Order("created_at ASC").
		Find(&sessions).Error
	if err != nil {
		return nil, fmt.Errorf("list payment sessions: %w", err)
	}
	return sessions, nil
}

// awaitingPaymentClause selects orders that may still receive money: unpaid
// orders inside or past their window, part-paid orders with a checkout
// session issued since sessionsSince that has not been applied, and orders
// cancelled since lateSince with such a session, whose buyer may still pay
// it (that money is then refunded). Orders under staff review, and orders
// whose next look is not yet due, are left out.
const awaitingPaymentClause = `payment_review = '' AND (next_reconcile_at IS NULL OR next_reconcile_at <= ?) AND (
	(status = ? AND payment_status = ?)
	OR ((payment_status = ? OR (status = ? AND cancelled_at >= ?)) AND EXISTS (
		SELECT 1 FROM order_payment_sessions s
		WHERE s.order_id = orders.id AND s.created_at >= ? AND s.deleted_at IS NULL
		AND NOT EXISTS (
			SELECT 1 FROM order_payments p
			WHERE p.order_id = s.order_id AND p.reference = s.session_ref AND p.deleted_at IS NULL))))`

func awaitingPaymentArgs(now, sessionsSince, lateSince time.Time) []any {
	return []any{
		now,
		orderStatusPendingPayment, paymentStatusPending,
		paymentStatusPartiallyPaid, orderStatusCancelled, lateSince,
		sessionsSince,
	}
}

func (r *orderRepository) ListAwaitingPayment(
	ctx context.Context,
	shopID string,
	window ReconcileWindow,
	limit int,
) ([]*models.Order, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where(awaitingPaymentClause, awaitingPaymentArgs(window.Now, window.SessionsSince, window.LateSince)...).
		// Least recently looked at first, so a backed-off order never holds
		// up one that has not been seen.
		Order("COALESCE(next_reconcile_at, created_at) ASC")
	if shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}
	if limit > 0 {
		query = query.Limit(limit)
	}
	if err := query.Find(&orders).Error; err != nil {
		return nil, fmt.Errorf("list orders awaiting payment: %w", err)
	}
	return orders, nil
}

// HasReconcileWork answers, in one round trip, whether a reconcile run has
// anything to do: an order that may receive money, a part-paid order past
// its deadline, a refund to send or confirm, or a webhook due.
func (r *orderRepository) HasReconcileWork(ctx context.Context, shopID string, window ReconcileWindow) (bool, error) {
	shopFilter, shopArgs := "", []any{}
	if shopID != "" {
		shopFilter, shopArgs = " AND shop_id = ?", []any{shopID}
	}
	args := append([]any{}, awaitingPaymentArgs(window.Now, window.SessionsSince, window.LateSince)...)
	args = append(args, shopArgs...)
	args = append(args, paymentStatusPartiallyPaid, orderStatusCancelled, window.Now)
	args = append(args, shopArgs...)
	args = append(args, models.RefundPending, models.RefundSent)
	args = append(args, shopArgs...)
	args = append(args, models.EventDeliveryPending, window.Now)
	args = append(args, shopArgs...)

	var found bool
	err := r.Pool().DB(ctx, true).Raw(
		`SELECT EXISTS (SELECT 1 FROM orders WHERE deleted_at IS NULL AND `+awaitingPaymentClause+shopFilter+`)
		OR EXISTS (SELECT 1 FROM orders WHERE deleted_at IS NULL AND payment_status = ? AND status <> ?
			AND balance_due_at < ? AND overdue_at IS NULL`+shopFilter+`)
		OR EXISTS (SELECT 1 FROM order_refunds WHERE deleted_at IS NULL AND status IN (?, ?)`+shopFilter+`)
		OR EXISTS (SELECT 1 FROM order_events WHERE deleted_at IS NULL AND delivery = ?
			AND (next_attempt_at IS NULL OR next_attempt_at <= ?)`+shopFilter+`)`,
		args...).Scan(&found).Error
	if err != nil {
		return false, fmt.Errorf("check for reconcile work: %w", err)
	}
	return found, nil
}

// DeferReconcile backs an order off until next and counts the look.
func (r *orderRepository) DeferReconcile(ctx context.Context, orderID string, next time.Time) error {
	return r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id = ?", orderID).
		UpdateColumns(map[string]any{
			columnNextReconcileAt:   next,
			columnReconcileAttempts: gorm.Expr("reconcile_attempts + 1"),
		}).Error
}

// FlagPaymentReview takes an order out of the reconcile sweep for staff to
// settle, recording why.
func (r *orderRepository) FlagPaymentReview(ctx context.Context, orderID, reason string) error {
	return r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id = ?", orderID).
		UpdateColumn("payment_review", reason).Error
}

func (r *orderRepository) ListOverdue(
	ctx context.Context,
	shopID string,
	now time.Time,
	limit int,
) ([]*models.Order, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Where("payment_status = ? AND status <> ? AND balance_due_at < ? AND overdue_at IS NULL",
			paymentStatusPartiallyPaid, orderStatusCancelled, now).
		Order("balance_due_at ASC")
	if shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}
	if limit > 0 {
		query = query.Limit(limit)
	}
	if err := query.Find(&orders).Error; err != nil {
		return nil, fmt.Errorf("list overdue orders: %w", err)
	}
	return orders, nil
}

func (r *orderRepository) MarkOverdue(
	ctx context.Context,
	orderID string,
	now time.Time,
	events []*models.OrderEvent,
) (bool, error) {
	marked := false
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		result := tx.Model(&models.Order{}).
			Where("id = ? AND overdue_at IS NULL", orderID).
			UpdateColumns(map[string]any{"overdue_at": now, columnVersion: bumpVersion()})
		if result.Error != nil {
			return fmt.Errorf("mark order overdue: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return nil
		}
		marked = true
		return createEvents(tx, events)
	})
	return marked, err
}
