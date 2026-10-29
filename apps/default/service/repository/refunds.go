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
	"fmt"
	"time"

	"gorm.io/gorm"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// ReconcileWindow bounds what a reconcile run looks at.
type ReconcileWindow struct {
	Now time.Time
	// SessionsSince bounds how far back an unpaid instalment session on a
	// part-paid order is still checked.
	SessionsSince time.Time
	// LateSince bounds how long after cancellation an order's unpaid
	// sessions are still checked for a late payment.
	LateSince time.Time
}

// createRefund raises refund for order inside tx, owed to the order's buyer.
// A refund whose reference is already raised is left as it is.
func createRefund(tx *gorm.DB, order *models.Order, refund *models.OrderRefund) error {
	refund.OrderID = order.GetID()
	refund.ShopID = order.ShopID
	refund.ProfileID = order.ProfileID
	refund.ContactID = order.ContactID
	if refund.Currency == "" {
		refund.Currency = order.TotalCurrency
	}
	refund.Status = models.RefundPending
	// The refund belongs to the order's tenant, whoever raises it.
	refund.CopyPartitionInfo(&order.BaseModel)

	var existing int64
	if err := tx.Model(&models.OrderRefund{}).Where("reference = ?", refund.Reference).
		Count(&existing).Error; err != nil {
		return fmt.Errorf("check refund reference: %w", err)
	}
	if existing > 0 {
		return nil
	}
	if err := tx.Create(refund).Error; err != nil {
		return fmt.Errorf("raise refund: %w", err)
	}
	return nil
}

// ListOpenRefunds returns refunds not yet confirmed or failed, least
// recently looked at first.
func (r *orderRepository) ListOpenRefunds(
	ctx context.Context,
	shopID string,
	limit int,
) ([]*models.OrderRefund, error) {
	var refunds []*models.OrderRefund
	query := r.Pool().DB(ctx, false).
		Where("status IN ?", []int32{models.RefundPending, models.RefundSent}).
		Order("modified_at ASC")
	if shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}
	if limit > 0 {
		query = query.Limit(limit)
	}
	if err := query.Find(&refunds).Error; err != nil {
		return nil, fmt.Errorf("list open refunds: %w", err)
	}
	return refunds, nil
}

// ListRefunds returns an order's refunds, oldest first.
func (r *orderRepository) ListRefunds(ctx context.Context, orderID string) ([]*models.OrderRefund, error) {
	var refunds []*models.OrderRefund
	if err := r.Pool().DB(ctx, false).
		Where("order_id = ?", orderID).
		Order("created_at ASC").
		Find(&refunds).Error; err != nil {
		return nil, fmt.Errorf("list refunds: %w", err)
	}
	return refunds, nil
}

// ClaimRefund marks a pending refund as being sent. Only one caller wins; a
// refund already claimed is never sent again without RetakeRefund.
func (r *orderRepository) ClaimRefund(ctx context.Context, refundID string, at time.Time) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ? AND status = ? AND sent_at IS NULL", refundID, models.RefundPending).
		UpdateColumns(map[string]any{columnSentAt: at, columnModifiedAt: at})
	if result.Error != nil {
		return false, fmt.Errorf("claim refund: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

// RetakeRefund takes over a claim that never reached the payment service:
// it compares the claim time the caller saw, so of several callers that saw
// the same stale claim exactly one may send.
func (r *orderRepository) RetakeRefund(ctx context.Context, refundID string, observed, at time.Time) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ? AND status = ? AND payment_id = '' AND sent_at = ?", refundID, models.RefundPending, observed).
		UpdateColumns(map[string]any{columnSentAt: at, columnModifiedAt: at})
	if result.Error != nil {
		return false, fmt.Errorf("retake refund: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

// RecordRefundSent notes the payment the payment service holds for a refund.
func (r *orderRepository) RecordRefundSent(ctx context.Context, refundID, paymentID string) error {
	return r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ? AND status IN ?", refundID, []int32{models.RefundPending, models.RefundSent}).
		UpdateColumns(map[string]any{
			columnStatus:     models.RefundSent,
			columnPaymentID:  paymentID,
			columnLastError:  "",
			columnModifiedAt: time.Now(),
		}).Error
}

// TouchRefund records a look at a refund that settled nothing, so the next
// run starts with the others.
func (r *orderRepository) TouchRefund(ctx context.Context, refundID, lastError string) error {
	if len(lastError) > maxRefundError {
		lastError = lastError[:maxRefundError]
	}
	return r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ?", refundID).
		UpdateColumns(map[string]any{columnLastError: lastError, columnModifiedAt: time.Now()}).Error
}

const maxRefundError = 500

// FailRefund records that the payment service gave up on a refund; staff
// must settle it.
func (r *orderRepository) FailRefund(ctx context.Context, refundID, paymentID, reason string) error {
	return r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ? AND status IN ?", refundID, []int32{models.RefundPending, models.RefundSent}).
		UpdateColumns(map[string]any{
			columnStatus:     models.RefundFailed,
			columnPaymentID:  paymentID,
			columnLastError:  reason,
			columnModifiedAt: time.Now(),
		}).Error
}

// ConfirmRefund records a refund the payment service confirmed, adds it to
// what the order has refunded and, when it was the last open refund of a
// cancelled order, marks the order REFUNDED, with events, in one
// transaction. It returns the order when the refund was newly confirmed.
func (r *orderRepository) ConfirmRefund(
	ctx context.Context,
	refundID string,
	confirmedAt time.Time,
	events func(order *models.Order, refund *models.OrderRefund) []*models.OrderEvent,
) (*models.Order, []*models.OrderEvent, error) {
	return r.confirmRefund(ctx, refundID, []int32{models.RefundPending, models.RefundSent},
		map[string]any{}, confirmedAt, events)
}

// RecordRefundPaidBack confirms a failed refund the shop paid back itself,
// noting who did and how, as ConfirmRefund confirms one the payment service
// paid. It returns a nil order when the refund was not failed.
func (r *orderRepository) RecordRefundPaidBack(
	ctx context.Context,
	refundID, by, note string,
	at time.Time,
	events func(order *models.Order, refund *models.OrderRefund) []*models.OrderEvent,
) (*models.Order, []*models.OrderEvent, error) {
	return r.confirmRefund(ctx, refundID, []int32{models.RefundFailed},
		map[string]any{"resolved_by": by, "note": note}, at, events)
}

// RequeueRefund puts a failed refund back to be sent as a new payment, under
// its next reference. It reports false when the refund was not failed.
func (r *orderRepository) RequeueRefund(ctx context.Context, refundID, note string) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.OrderRefund{}).
		Where("id = ? AND status = ?", refundID, models.RefundFailed).
		UpdateColumns(map[string]any{
			columnStatus:     models.RefundPending,
			"attempt":        gorm.Expr("attempt + 1"),
			columnSentAt:     nil,
			columnPaymentID:  "",
			columnLastError:  "",
			"note":           note,
			columnModifiedAt: time.Now(),
		})
	if result.Error != nil {
		return false, fmt.Errorf("requeue refund: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

func (r *orderRepository) confirmRefund(
	ctx context.Context,
	refundID string,
	from []int32,
	extra map[string]any,
	confirmedAt time.Time,
	events func(order *models.Order, refund *models.OrderRefund) []*models.OrderEvent,
) (*models.Order, []*models.OrderEvent, error) {
	var (
		order    *models.Order
		recorded []*models.OrderEvent
	)
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		refund := &models.OrderRefund{}
		if err := tx.First(refund, "id = ?", refundID).Error; err != nil {
			return fmt.Errorf("load refund: %w", err)
		}
		updates := map[string]any{
			columnStatus: models.RefundConfirmed, "confirmed_at": confirmedAt, columnLastError: "",
			columnModifiedAt: confirmedAt,
		}
		for column, value := range extra {
			updates[column] = value
		}
		result := tx.Model(&models.OrderRefund{}).
			Where("id = ? AND status IN ?", refundID, from).
			UpdateColumns(updates)
		if result.Error != nil {
			return fmt.Errorf("confirm refund: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return nil
		}

		var open int64
		if err := tx.Model(&models.OrderRefund{}).
			Where("order_id = ? AND status <> ?", refund.OrderID, models.RefundConfirmed).
			Count(&open).Error; err != nil {
			return fmt.Errorf("count open refunds: %w", err)
		}
		orderUpdates := map[string]any{
			"amount_refunded_nanos": gorm.Expr("amount_refunded_nanos + ?", refund.AmountNanos),
			columnVersion:           bumpVersion(),
			columnModifiedAt:        confirmedAt,
		}
		if open == 0 {
			orderUpdates["payment_status"] = gorm.Expr(
				"CASE WHEN status = ? AND payment_status = ? THEN ? ELSE payment_status END",
				orderStatusCancelled,
				paymentStatusRefundPending,
				paymentStatusRefunded,
			)
		}
		if err := tx.Model(&models.Order{}).Where("id = ?", refund.OrderID).
			UpdateColumns(orderUpdates).Error; err != nil {
			return fmt.Errorf("record refund on order: %w", err)
		}
		order = &models.Order{}
		if err := tx.First(order, "id = ?", refund.OrderID).Error; err != nil {
			return fmt.Errorf("reload order: %w", err)
		}
		if events != nil {
			recorded = events(order, refund)
		}
		return createEvents(tx, recorded)
	})
	if err != nil {
		return nil, nil, err
	}
	return order, recorded, nil
}

// LedgerItems is what one end-of-day transaction merges.
type LedgerItems struct {
	// Payments are instalments; their sale part is booked.
	Payments []*models.OrderPayment
	// Orders are orders paid in full before payments were recorded one by
	// one; their total is booked.
	Orders []*models.Order
	// Refunds are confirmed refunds of money booked as a sale; they are
	// reversed.
	Refunds []*models.OrderRefund
}

// ClaimLedgerItems stamps transactionID on every payment, legacy paid order
// and confirmed sale refund of the shop before to that no transaction has
// merged yet, unless items already carry it, and returns the items that
// carry it. A retried posting thus always sends exactly what the first
// attempt sent, so the ledger's answer to a repeated transaction id can be
// trusted. Items noticed late (dated before an earlier, already posted day)
// are picked up by the next day's posting rather than lost.
func (r *orderRepository) ClaimLedgerItems(
	ctx context.Context,
	shopID string,
	to time.Time,
	transactionID string,
) (*LedgerItems, error) {
	items := &LedgerItems{}
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, err := countLedgerItems(tx, shopID, transactionID)
		if err != nil {
			return err
		}
		if claimed == 0 {
			if err = stampLedgerItems(tx, shopID, to, transactionID); err != nil {
				return err
			}
		}
		if err = tx.Where("shop_id = ? AND ledger_transaction_id = ?", shopID, transactionID).
			Order("paid_at ASC").Find(&items.Payments).Error; err != nil {
			return fmt.Errorf("load claimed payments: %w", err)
		}
		if err = tx.Where("shop_id = ? AND ledger_transaction_id = ? AND amount_paid_nanos = 0", shopID, transactionID).
			Order("paid_at ASC").Find(&items.Orders).Error; err != nil {
			return fmt.Errorf("load claimed orders: %w", err)
		}
		if err = tx.Where("shop_id = ? AND ledger_transaction_id = ?", shopID, transactionID).
			Order("confirmed_at ASC").Find(&items.Refunds).Error; err != nil {
			return fmt.Errorf("load claimed refunds: %w", err)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return items, nil
}

func countLedgerItems(tx *gorm.DB, shopID, transactionID string) (int64, error) {
	var total int64
	for _, model := range []any{&models.OrderPayment{}, &models.OrderRefund{}} {
		var n int64
		if err := tx.Model(model).Where("shop_id = ? AND ledger_transaction_id = ?", shopID, transactionID).
			Count(&n).Error; err != nil {
			return 0, fmt.Errorf("count claimed ledger items: %w", err)
		}
		total += n
	}
	var n int64
	if err := tx.Model(&models.Order{}).
		Where("shop_id = ? AND ledger_transaction_id = ? AND amount_paid_nanos = 0", shopID, transactionID).
		Count(&n).Error; err != nil {
		return 0, fmt.Errorf("count claimed ledger orders: %w", err)
	}
	return total + n, nil
}

func stampLedgerItems(tx *gorm.DB, shopID string, to time.Time, transactionID string) error {
	if err := tx.Model(&models.OrderPayment{}).
		Where("shop_id = ? AND ledger_transaction_id = '' AND paid_at < ?", shopID, to).
		UpdateColumn("ledger_transaction_id", transactionID).Error; err != nil {
		return fmt.Errorf("claim payments: %w", err)
	}
	// Orders paid in full before payments were recorded one by one.
	if err := tx.Model(&models.Order{}).
		Where("shop_id = ? AND ledger_transaction_id = '' AND amount_paid_nanos = 0 AND payment_status IN ? AND paid_at < ?",
			shopID, []int32{paymentStatusPaid, paymentStatusRefundPending, paymentStatusRefunded}, to).
		UpdateColumn("ledger_transaction_id", transactionID).Error; err != nil {
		return fmt.Errorf("claim paid orders: %w", err)
	}
	if err := tx.Model(&models.OrderRefund{}).
		Where("shop_id = ? AND ledger_transaction_id = '' AND reverses_sale AND status = ? AND confirmed_at < ?",
			shopID, models.RefundConfirmed, to).
		UpdateColumn("ledger_transaction_id", transactionID).Error; err != nil {
		return fmt.Errorf("claim refunds: %w", err)
	}
	return nil
}
