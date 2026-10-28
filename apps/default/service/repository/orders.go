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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// ErrCartNotConvertible is returned when the cart to convert is missing or no
// longer active at commit time.
var ErrCartNotConvertible = errors.New("cart is not active")

type orderRepository struct {
	datastore.BaseRepository[*models.Order]
}

func NewOrderRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrderRepository {
	return &orderRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Order](
			ctx, dbPool, workMan, func() *models.Order { return &models.Order{} },
		),
	}
}

func (r *orderRepository) GetWithLines(ctx context.Context, id string) (*models.Order, error) {
	order := &models.Order{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		Preload("Shop").
		Preload("Payments", func(db *gorm.DB) *gorm.DB { return db.Order("paid_at ASC") }).
		First(order, "id = ?", id).Error
	return order, err
}

func (r *orderRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.Order, error) {
	order := &models.Order{}
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		First(order, "idempotency_key = ?", key).Error
	return order, err
}

func (r *orderRepository) ListByShopID(
	ctx context.Context,
	shopID string,
	page Page,
) ([]*models.Order, *PageKey, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where("shop_id = ?", shopID)
	if err := applyKeyset(query, page).Find(&orders).Error; err != nil {
		return nil, nil, err
	}
	orders, next := trimPage(orders, page, func(o *models.Order) PageKey { return baseKey(o.BaseModel) })
	return orders, next, nil
}

func (r *orderRepository) ListByProfileID(
	ctx context.Context,
	profileID string,
	page Page,
) ([]*models.Order, *PageKey, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where("profile_id = ?", profileID)
	if err := applyKeyset(query, page).Find(&orders).Error; err != nil {
		return nil, nil, err
	}
	orders, next := trimPage(orders, page, func(o *models.Order) PageKey { return baseKey(o.BaseModel) })
	return orders, next, nil
}

// CreateWithLinesAndStock atomically allocates the shop order number, creates
// the order and its lines, reserves stock, and optionally converts the source
// cart. Any failure rolls the whole thing back.
func (r *orderRepository) CreateWithLinesAndStock(
	ctx context.Context,
	order *models.Order,
	lines []*models.OrderLine,
	convertCartID string,
	convertedCartStatus int32,
) error {
	if err := validateOrderInput(order, lines); err != nil {
		return err
	}

	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if err := assignOrderNumber(tx, order); err != nil {
			return err
		}
		if err := tx.Create(order).Error; err != nil {
			return fmt.Errorf("create order: %w", err)
		}
		if err := createLinesAndReserve(tx, order.GetID(), lines); err != nil {
			return err
		}
		if convertCartID != "" {
			return convertCart(tx, convertCartID, convertedCartStatus)
		}
		return nil
	})
}

func validateOrderInput(order *models.Order, lines []*models.OrderLine) error {
	if order == nil {
		return errors.New("create order with stock: order is required")
	}
	if len(lines) == 0 {
		return errors.New("create order with stock: at least one line is required")
	}
	for _, line := range lines {
		if line.Quantity <= 0 {
			return fmt.Errorf("%w: quantity must be positive for variant %s",
				ErrInsufficientStock, line.ProductVariantID)
		}
	}
	return nil
}

func assignOrderNumber(tx *gorm.DB, order *models.Order) error {
	if order.OrderNumber != "" {
		return nil
	}
	seq, err := nextOrderSequence(tx, order.ShopID)
	if err != nil {
		return err
	}
	order.OrderNumber = formatOrderNumber(seq)
	return nil
}

func createLinesAndReserve(tx *gorm.DB, orderID string, lines []*models.OrderLine) error {
	for _, line := range lines {
		line.OrderID = orderID
		if err := tx.Create(line).Error; err != nil {
			return fmt.Errorf("create order line: %w", err)
		}
		if err := reserveStock(tx, line.ProductVariantID, line.Quantity); err != nil {
			return err
		}
	}
	return nil
}

// reserveStock decrements on-hand stock only when enough remains; zero rows
// affected means the variant is missing or oversold by a concurrent order.
func reserveStock(tx *gorm.DB, variantID string, quantity int64) error {
	result := tx.Model(&models.ProductVariant{}).
		Where("id = ? AND stock_quantity >= ?", variantID, quantity).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity - ?", quantity))
	if result.Error != nil {
		return fmt.Errorf("decrement stock for variant %s: %w", variantID, result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("%w for variant %s", ErrInsufficientStock, variantID)
	}
	return nil
}

// convertCart marks the cart converted. Only a cart not already in the target
// status qualifies, so a concurrent checkout of the same cart loses here
// instead of producing two orders.
func convertCart(tx *gorm.DB, cartID string, convertedStatus int32) error {
	result := tx.Model(&models.Cart{}).
		Where("id = ? AND status <> ?", cartID, convertedStatus).
		UpdateColumn("status", convertedStatus)
	if result.Error != nil {
		return fmt.Errorf("convert cart %s: %w", cartID, result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("%w: cart %s", ErrCartNotConvertible, cartID)
	}
	return nil
}

// UpdateStatus applies a status transition only when the current status
// matches expectedStatus, so concurrent transitions cannot both succeed.
func (r *orderRepository) UpdateStatus(
	ctx context.Context,
	orderID string,
	expectedStatus, newStatus int32,
	fulfilmentStatus int32,
) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id = ? AND status = ?", orderID, expectedStatus).
		UpdateColumns(map[string]any{
			columnStatus:        newStatus,
			"fulfilment_status": fulfilmentStatus,
			columnVersion:       bumpVersion(),
		})
	if result.Error != nil {
		return false, fmt.Errorf("update order status: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

// Order and payment statuses mirrored from commercev1 so the repository can
// express transitions without importing the API package.
const (
	orderStatusCancelled       int32 = 2
	orderStatusPendingPayment  int32 = 4
	paymentStatusPending       int32 = 1
	paymentStatusPaid          int32 = 2
	paymentStatusRefunded      int32 = 4
	paymentStatusRefundPending int32 = 7

	columnStatus            = "status"
	columnVersion           = "version"
	columnModifiedAt        = "modified_at"
	columnNextReconcileAt   = "next_reconcile_at"
	columnReconcileAttempts = "reconcile_attempts"
	columnPaymentID         = "payment_id"
	columnLastError         = "last_error"
)

// bumpVersion advances an order's version in the same statement that
// changes its state, so a concurrent optimistic writer (ApplyPayment) sees
// the change and retries instead of overwriting it.
func bumpVersion() clause.Expr {
	return gorm.Expr("version + 1")
}

// CancelPlan is what cancelling an order does, decided against the order as
// it stands inside the cancelling transaction.
type CancelPlan struct {
	Reason string
	// PaymentStatus replaces the order's payment status; 0 keeps it.
	PaymentStatus int32
	// MarkOverdue records that the balance deadline passed.
	MarkOverdue bool
	// Refund, when set, is raised in the same transaction: money the buyer
	// paid towards the order, owed back now that it is cancelled.
	Refund *models.OrderRefund
	Events []*models.OrderEvent
}

// CancelDecision decides whether and how order is cancelled. salePaidNanos
// is what the buyer paid towards the order itself (excess payments are
// refunded on their own). A nil plan leaves the order alone; an error is
// returned to the caller as is.
type CancelDecision func(order *models.Order, salePaidNanos int64) (*CancelPlan, error)

// Cancel cancels an order, returns its stock and raises any refund in one
// transaction. The decision is taken against the order read inside the
// transaction and the write only lands if the order's version is unchanged,
// so a payment applied concurrently is either seen by the decision (and
// refunded) or lands after the cancellation (and is refunded as excess);
// it is never lost between the two.
func (r *orderRepository) Cancel(
	ctx context.Context,
	orderID string,
	cancelledAt time.Time,
	decide CancelDecision,
) (*models.Order, *CancelPlan, error) {
	for range maxPaymentAttempts {
		order, plan, err := r.cancelOnce(ctx, orderID, cancelledAt, decide)
		if errors.Is(err, errOrderChanged) {
			continue
		}
		return order, plan, err
	}
	return nil, nil, fmt.Errorf("cancel order %s: %w", orderID, errOrderChanged)
}

func (r *orderRepository) cancelOnce(
	ctx context.Context,
	orderID string,
	cancelledAt time.Time,
	decide CancelDecision,
) (*models.Order, *CancelPlan, error) {
	var (
		order *models.Order
		out   *CancelPlan
	)
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		order = &models.Order{}
		if err := tx.First(order, "id = ?", orderID).Error; err != nil {
			return fmt.Errorf("load order: %w", err)
		}
		salePaid, err := salePaidNanos(tx, order)
		if err != nil {
			return err
		}
		decided, err := decide(order, salePaid)
		if err != nil || decided == nil {
			return err
		}

		if err = writeCancel(tx, order, decided, cancelledAt); err != nil {
			return err
		}
		out = decided
		return nil
	})
	if err != nil {
		return nil, nil, err
	}
	return order, out, nil
}

// writeCancel applies a decided cancellation to order inside tx: the
// version-checked state change, the restock, any refund and the events.
func writeCancel(tx *gorm.DB, order *models.Order, decided *CancelPlan, cancelledAt time.Time) error {
	updates := map[string]any{
		columnStatus:          orderStatusCancelled,
		"cancel_reason":       decided.Reason,
		"cancelled_at":        cancelledAt,
		columnVersion:         order.Version + 1,
		columnModifiedAt:      time.Now(),
		columnNextReconcileAt: nil,
	}
	if decided.PaymentStatus != 0 {
		updates["payment_status"] = decided.PaymentStatus
	}
	if decided.MarkOverdue && order.OverdueAt == nil {
		updates["overdue_at"] = cancelledAt
	}
	result := tx.Model(&models.Order{}).
		Where("id = ? AND version = ?", order.GetID(), order.Version).
		UpdateColumns(updates)
	if result.Error != nil {
		return fmt.Errorf("cancel order: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errOrderChanged
	}
	if err := restock(tx, order.GetID()); err != nil {
		return err
	}
	if decided.Refund != nil && decided.Refund.AmountNanos > 0 {
		if err := createRefund(tx, order, decided.Refund); err != nil {
			return err
		}
	}
	if err := createEvents(tx, decided.Events); err != nil {
		return err
	}
	order.Status = orderStatusCancelled
	order.CancelReason = decided.Reason
	order.CancelledAt = &cancelledAt
	if decided.PaymentStatus != 0 {
		order.PaymentStatus = decided.PaymentStatus
	}
	return nil
}

// salePaidNanos is what the buyer paid towards the order itself: every
// payment less its excess, or, for an order paid in full before payments
// were recorded one by one, the total.
func salePaidNanos(tx *gorm.DB, order *models.Order) (int64, error) {
	var sum struct{ Total int64 }
	if err := tx.Model(&models.OrderPayment{}).
		Select("COALESCE(SUM(amount_nanos - excess_nanos), 0) AS total").
		Where("order_id = ?", order.GetID()).
		Scan(&sum).Error; err != nil {
		return 0, fmt.Errorf("sum order payments: %w", err)
	}
	if sum.Total == 0 && order.AmountPaidNanos == 0 && order.PaymentStatus == paymentStatusPaid {
		return order.TotalNanosValue(), nil
	}
	return sum.Total, nil
}

func restock(tx *gorm.DB, orderID string) error {
	var lines []*models.OrderLine
	if err := tx.Where("order_id = ?", orderID).Find(&lines).Error; err != nil {
		return fmt.Errorf("load order lines: %w", err)
	}
	for _, line := range lines {
		if err := tx.Model(&models.ProductVariant{}).
			Where("id = ?", line.ProductVariantID).
			UpdateColumn("stock_quantity", gorm.Expr("stock_quantity + ?", line.Quantity)).Error; err != nil {
			return fmt.Errorf("restock variant %s: %w", line.ProductVariantID, err)
		}
	}
	return nil
}

// AttachPaymentSession records the session in the order's history and makes
// it the order's current one, but only while the current one is still
// expectedRef: of two concurrent checkouts, one wins and the other reports
// false and should offer the winner's session. paymentDueAt, when set,
// extends the order's payment window (never shortens it) so the stock stays
// held for as long as the new session can be paid.
func (r *orderRepository) AttachPaymentSession(
	ctx context.Context,
	orderID, expectedRef, ref, checkoutURL string,
	amountNanos int64,
	paymentDueAt *time.Time,
) (bool, error) {
	attached := false
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		order := &models.Order{}
		if err := tx.First(order, "id = ?", orderID).Error; err != nil {
			return fmt.Errorf("attach payment session: %w", err)
		}
		// Every issued session is recorded, the losing one of a race too, so
		// a payment on it is still found and applied (or refunded).
		session := &models.OrderPaymentSession{OrderID: orderID, SessionRef: ref, AmountNanos: amountNanos}
		session.CopyPartitionInfo(&order.BaseModel)
		if err := tx.Create(session).Error; err != nil {
			return fmt.Errorf("record payment session: %w", err)
		}

		updates := map[string]any{
			"payment_session_ref":   ref,
			"checkout_url":          checkoutURL,
			columnNextReconcileAt:   nil,
			columnReconcileAttempts: 0,
			columnVersion:           bumpVersion(),
		}
		if paymentDueAt != nil && (order.PaymentDueAt == nil || order.PaymentDueAt.Before(*paymentDueAt)) {
			updates["payment_due_at"] = *paymentDueAt
		}
		result := tx.Model(&models.Order{}).
			Where("id = ? AND payment_session_ref = ?", orderID, expectedRef).
			UpdateColumns(updates)
		if result.Error != nil {
			return fmt.Errorf("attach payment session: %w", result.Error)
		}
		attached = result.RowsAffected > 0
		return nil
	})
	return attached, err
}

func (r *orderRepository) SetLedgerTransaction(ctx context.Context, orderIDs []string, transactionID string) error {
	if len(orderIDs) == 0 {
		return nil
	}
	return r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id IN ?", orderIDs).
		UpdateColumn("ledger_transaction_id", transactionID).Error
}

// orderNumberWidth pads sequence numbers so they sort as strings.
const orderNumberWidth = 6

func formatOrderNumber(seq int64) string {
	return fmt.Sprintf("ORD-%0*d", orderNumberWidth, seq)
}

// nextOrderSequence advances the per-shop counter with a single atomic
// increment, which every database serialises on the row it writes; no
// explicit lock is taken. A shop's first order creates the row inside a
// savepoint, so losing that race to a concurrent first order leaves the
// transaction usable and simply increments the winner's row.
func nextOrderSequence(tx *gorm.DB, shopID string) (int64, error) {
	advanced, err := advanceOrderSequence(tx, shopID)
	if err != nil || advanced > 0 {
		return advanced, err
	}

	createErr := tx.Transaction(func(sp *gorm.DB) error {
		return sp.Create(&models.OrderSequence{ShopID: shopID, LastNumber: 1}).Error
	})
	if createErr == nil {
		return 1, nil
	}
	advanced, err = advanceOrderSequence(tx, shopID)
	if err != nil {
		return 0, err
	}
	if advanced == 0 {
		return 0, fmt.Errorf("create order sequence: %w", createErr)
	}
	return advanced, nil
}

// advanceOrderSequence increments the shop's counter and returns the new
// value, or 0 when the shop has no counter yet.
func advanceOrderSequence(tx *gorm.DB, shopID string) (int64, error) {
	result := tx.Model(&models.OrderSequence{}).
		Where("shop_id = ?", shopID).
		UpdateColumn("last_number", gorm.Expr("last_number + 1"))
	if result.Error != nil {
		return 0, fmt.Errorf("advance order sequence: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return 0, nil
	}
	seq := &models.OrderSequence{}
	if err := tx.Where("shop_id = ?", shopID).First(seq).Error; err != nil {
		return 0, fmt.Errorf("read order sequence: %w", err)
	}
	return seq.LastNumber, nil
}

type orderLineRepository struct {
	datastore.BaseRepository[*models.OrderLine]
}

func NewOrderLineRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrderLineRepository {
	return &orderLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.OrderLine](
			ctx, dbPool, workMan, func() *models.OrderLine { return &models.OrderLine{} },
		),
	}
}

func (r *orderLineRepository) GetByOrderID(ctx context.Context, orderID string) ([]*models.OrderLine, error) {
	var lines []*models.OrderLine
	err := r.Pool().DB(ctx, true).Where("order_id = ?", orderID).Find(&lines).Error
	return lines, err
}
