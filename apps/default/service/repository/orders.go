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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
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
		Preload(clause.Associations).
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
		})
	if result.Error != nil {
		return false, fmt.Errorf("update order status: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

// Order and payment statuses mirrored from commercev1 so the repository can
// express transitions without importing the API package.
const (
	orderStatusCancelled      int32 = 2
	orderStatusPendingPayment int32 = 4
	paymentStatusPending      int32 = 1
	paymentStatusPaid         int32 = 2
	paymentStatusRefunded     int32 = 4

	columnStatus = "status"
)

func (r *orderRepository) ListPendingPayment(
	ctx context.Context,
	shopID string,
	limit int,
) ([]*models.Order, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where("status = ? AND payment_status = ?", orderStatusPendingPayment, paymentStatusPending).
		Order("created_at ASC")
	if shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}
	if limit > 0 {
		query = query.Limit(limit)
	}
	err := query.Find(&orders).Error
	return orders, err
}

func (r *orderRepository) ListPaidBetween(
	ctx context.Context,
	shopID string,
	from, to time.Time,
) ([]*models.Order, error) {
	var orders []*models.Order
	err := r.Pool().DB(ctx, true).
		Where("shop_id = ? AND payment_status IN ? AND paid_at >= ? AND paid_at < ? AND ledger_transaction_id = ''",
			shopID, []int32{paymentStatusPaid, paymentStatusRefunded}, from, to).
		Order("paid_at ASC").
		Find(&orders).Error
	return orders, err
}

func (r *orderRepository) ListRefundedBetween(
	ctx context.Context,
	shopID string,
	from, to time.Time,
) ([]*models.Order, error) {
	var orders []*models.Order
	err := r.Pool().DB(ctx, true).
		Where("shop_id = ? AND payment_status = ? AND cancelled_at >= ? AND cancelled_at < ? AND refund_ledger_transaction_id = ''",
			shopID, paymentStatusRefunded, from, to).
		Order("cancelled_at ASC").
		Find(&orders).Error
	return orders, err
}

func (r *orderRepository) MarkPaid(
	ctx context.Context,
	orderID, paymentID string,
	paidAt time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id = ? AND status = ? AND payment_status = ?",
			orderID, orderStatusPendingPayment, paymentStatusPending).
		UpdateColumns(map[string]any{
			columnStatus:     1, // confirmed
			"payment_status": paymentStatusPaid,
			"payment_id":     paymentID,
			"paid_at":        paidAt,
		})
	if result.Error != nil {
		return false, fmt.Errorf("mark order paid: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

func (r *orderRepository) CancelAndRestock(
	ctx context.Context,
	orderID string,
	allowedStatuses []int32,
	paymentStatus int32,
	reason string,
	cancelledAt time.Time,
) (bool, error) {
	transitioned := false
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		updates := map[string]any{
			columnStatus:    orderStatusCancelled,
			"cancel_reason": reason,
			"cancelled_at":  cancelledAt,
		}
		if paymentStatus != 0 {
			updates["payment_status"] = paymentStatus
		}
		result := tx.Model(&models.Order{}).
			Where("id = ? AND status IN ?", orderID, allowedStatuses).
			UpdateColumns(updates)
		if result.Error != nil {
			return fmt.Errorf("cancel order: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return nil
		}
		transitioned = true

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
	})
	return transitioned, err
}

func (r *orderRepository) SetLedgerTransaction(ctx context.Context, orderIDs []string, transactionID string) error {
	return r.stampColumn(ctx, orderIDs, "ledger_transaction_id", transactionID)
}

func (r *orderRepository) SetRefundLedgerTransaction(
	ctx context.Context,
	orderIDs []string,
	transactionID string,
) error {
	return r.stampColumn(ctx, orderIDs, "refund_ledger_transaction_id", transactionID)
}

func (r *orderRepository) stampColumn(ctx context.Context, orderIDs []string, column, value string) error {
	if len(orderIDs) == 0 {
		return nil
	}
	return r.Pool().DB(ctx, false).
		Model(&models.Order{}).
		Where("id IN ?", orderIDs).
		UpdateColumn(column, value).Error
}

// orderNumberWidth pads sequence numbers so they sort as strings.
const orderNumberWidth = 6

func formatOrderNumber(seq int64) string {
	return fmt.Sprintf("ORD-%0*d", orderNumberWidth, seq)
}

// nextOrderSequence advances the per-shop counter under a row lock. The first
// order for a shop inserts the row; a concurrent first insert is resolved by
// the unique index and retried once as a locked read.
func nextOrderSequence(tx *gorm.DB, shopID string) (int64, error) {
	seq := &models.OrderSequence{}
	err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("shop_id = ?", shopID).
		First(seq).Error
	switch {
	case err == nil:
		seq.LastNumber++
		if updErr := tx.Model(seq).UpdateColumn("last_number", seq.LastNumber).Error; updErr != nil {
			return 0, fmt.Errorf("advance order sequence: %w", updErr)
		}
		return seq.LastNumber, nil
	case errors.Is(err, gorm.ErrRecordNotFound):
		seq = &models.OrderSequence{ShopID: shopID, LastNumber: 1}
		if createErr := tx.Create(seq).Error; createErr != nil {
			// Lost the race on first insert; take the row lock and advance.
			return retryOrderSequence(tx, shopID, createErr)
		}
		return 1, nil
	default:
		return 0, fmt.Errorf("read order sequence: %w", err)
	}
}

func retryOrderSequence(tx *gorm.DB, shopID string, cause error) (int64, error) {
	seq := &models.OrderSequence{}
	err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("shop_id = ?", shopID).
		First(seq).Error
	if err != nil {
		return 0, fmt.Errorf("create order sequence: %w (retry: %w)", cause, err)
	}
	seq.LastNumber++
	if updErr := tx.Model(seq).UpdateColumn("last_number", seq.LastNumber).Error; updErr != nil {
		return 0, fmt.Errorf("advance order sequence: %w", updErr)
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
