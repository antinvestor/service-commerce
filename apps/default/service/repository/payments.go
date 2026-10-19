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

	"github.com/pitabwire/frame/v2/data"
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
		if err := tx.Create(&payment).Error; err != nil {
			return fmt.Errorf("record payment: %w", err)
		}

		readVersion := order.Version
		order.AmountPaidNanos += payment.AmountNanos
		events = transition(order, &payment)
		order.Version = readVersion + 1

		result := tx.Model(&models.Order{}).
			Where("id = ? AND version = ?", orderID, readVersion).
			UpdateColumns(map[string]any{
				columnStatus:        order.Status,
				"payment_status":    order.PaymentStatus,
				"payment_id":        order.PaymentID,
				"paid_at":           order.PaidAt,
				"payment_due_at":    order.PaymentDueAt,
				"balance_due_at":    order.BalanceDueAt,
				"amount_paid_nanos": order.AmountPaidNanos,
				columnVersion:       order.Version,
				columnModifiedAt:    time.Now(),
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
	err := r.Pool().DB(ctx, true).
		Where("order_id = ?", orderID).
		Order("created_at ASC").
		Find(&sessions).Error
	if err != nil {
		return nil, fmt.Errorf("list payment sessions: %w", err)
	}
	return sessions, nil
}

func (r *orderRepository) ListAwaitingPayment(
	ctx context.Context,
	shopID string,
	sessionsSince time.Time,
	limit int,
) ([]*models.Order, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where(`((status = ? AND payment_status = ?) OR (payment_status = ? AND EXISTS (
			SELECT 1 FROM order_payment_sessions s
			WHERE s.order_id = orders.id AND s.created_at >= ? AND s.deleted_at IS NULL
			AND NOT EXISTS (
				SELECT 1 FROM order_payments p
				WHERE p.order_id = s.order_id AND p.reference = s.session_ref AND p.deleted_at IS NULL))))`,
			orderStatusPendingPayment, paymentStatusPending, paymentStatusPartiallyPaid, sessionsSince).
		Order("created_at ASC")
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

func (r *orderRepository) ListPaymentsBetween(
	ctx context.Context,
	shopID string,
	from, to time.Time,
) ([]*models.OrderPayment, error) {
	var payments []*models.OrderPayment
	err := r.Pool().DB(ctx, true).
		Where("shop_id = ? AND paid_at >= ? AND paid_at < ? AND ledger_transaction_id = ''", shopID, from, to).
		Order("paid_at ASC").
		Find(&payments).Error
	if err != nil {
		return nil, fmt.Errorf("list payments: %w", err)
	}
	return payments, nil
}

func (r *orderRepository) SetPaymentLedgerTransaction(
	ctx context.Context,
	paymentIDs []string,
	transactionID string,
) error {
	if len(paymentIDs) == 0 {
		return nil
	}
	return r.Pool().DB(ctx, false).
		Model(&models.OrderPayment{}).
		Where("id IN ?", paymentIDs).
		UpdateColumn("ledger_transaction_id", transactionID).Error
}
