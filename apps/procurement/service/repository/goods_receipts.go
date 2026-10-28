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
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

// ErrOverReceipt is returned when a receipt line would push a purchase order
// line past its ordered quantity, including under concurrent receipts.
var ErrOverReceipt = errors.New("received quantity exceeds remaining ordered quantity")

// ErrNotReceivable is returned when goods are received against an order that
// is not submitted, confirmed or partially received.
var ErrNotReceivable = errors.New("purchase order is not open for receipts")

// Purchase order, line and delivery statuses mirrored from procurementv1 so
// the repository needs no API package.
const (
	poStatusSubmitted         = 2
	poStatusConfirmed         = 3
	poStatusPartiallyReceived = 4
	poStatusReceived          = 5
	poStatusClosed            = 7
	poLineStatusPending       = 1
	poLineStatusPartial       = 2
	poLineStatusReceived      = 3
	poLineStatusClosed        = 5
	deliveryStatusPending     = 1
	deliveryStatusFailed      = 4
	deliveryStatusResolved    = 5
)

type goodsReceiptRepository struct {
	datastore.BaseRepository[*models.GoodsReceipt]
}

func NewGoodsReceiptRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) GoodsReceiptRepository {
	return &goodsReceiptRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceipt](
			ctx, dbPool, workMan, func() *models.GoodsReceipt { return &models.GoodsReceipt{} },
		),
	}
}

// CreateWithLines records the receipt, its lines, the purchase order line
// received quantities, and the purchase order status roll-up in one
// transaction. Each line increment is guarded so two concurrent receipts
// cannot together exceed the ordered quantity.
func (r *goodsReceiptRepository) CreateWithLines(
	ctx context.Context,
	gr *models.GoodsReceipt,
	lines []*models.GoodsReceiptLine,
) error {
	if gr == nil {
		return errors.New("create goods receipt: receipt is required")
	}
	if len(lines) == 0 {
		return errors.New("create goods receipt: at least one line is required")
	}
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if err := lockReceivable(tx, gr.PurchaseOrderID); err != nil {
			return err
		}
		if err := tx.Create(gr).Error; err != nil {
			return fmt.Errorf("create goods receipt: %w", err)
		}
		for _, line := range lines {
			line.GoodsReceiptID = gr.GetID()
			if err := tx.Create(line).Error; err != nil {
				return fmt.Errorf("create goods receipt line: %w", err)
			}
			if err := receiveOrderLine(tx, gr.PurchaseOrderID, line); err != nil {
				return err
			}
		}
		return rollUpPurchaseOrderStatus(tx, gr.PurchaseOrderID)
	})
}

// lockReceivable takes the order's row lock, which orders a receipt against
// a concurrent cancel or close (whichever commits first decides), and checks
// the order still takes receipts.
func lockReceivable(tx *gorm.DB, poID string) error {
	var status int32
	if err := tx.Model(&models.PurchaseOrder{}).Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("id = ?", poID).Select("status").Scan(&status).Error; err != nil {
		return fmt.Errorf("lock purchase order: %w", err)
	}
	if status != poStatusSubmitted && status != poStatusConfirmed && status != poStatusPartiallyReceived {
		return ErrNotReceivable
	}
	return nil
}

// receiveOrderLine adds a receipt line to its open order line, never past
// the ordered quantity, and updates the line's status.
func receiveOrderLine(tx *gorm.DB, poID string, line *models.GoodsReceiptLine) error {
	result := tx.Model(&models.PurchaseOrderLine{}).
		Where("purchase_order_id = ? AND id = ? AND status IN ? AND received_quantity + ? <= ordered_quantity",
			poID, line.PurchaseOrderLineID,
			[]int32{poLineStatusPending, poLineStatusPartial}, line.ReceivedQuantity).
		UpdateColumn("received_quantity", gorm.Expr("received_quantity + ?", line.ReceivedQuantity))
	if result.Error != nil {
		return fmt.Errorf("receive purchase order line %s: %w", line.PurchaseOrderLineID, result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("%w: purchase order line %s", ErrOverReceipt, line.PurchaseOrderLineID)
	}
	return markLineReceiptStatus(tx, line.PurchaseOrderLineID)
}

// markLineReceiptStatus sets a line received or partially received from its
// quantities. Two conditional updates keep it plain, portable SQL.
func markLineReceiptStatus(tx *gorm.DB, lineID string) error {
	if err := tx.Model(&models.PurchaseOrderLine{}).
		Where("id = ? AND received_quantity >= ordered_quantity", lineID).
		UpdateColumn("status", poLineStatusReceived).Error; err != nil {
		return fmt.Errorf("mark purchase order line %s received: %w", lineID, err)
	}
	if err := tx.Model(&models.PurchaseOrderLine{}).
		Where("id = ? AND received_quantity < ordered_quantity", lineID).
		UpdateColumn("status", poLineStatusPartial).Error; err != nil {
		return fmt.Errorf("mark purchase order line %s partially received: %w", lineID, err)
	}
	return nil
}

// rollUpPurchaseOrderStatus derives the PO status from its live lines.
func rollUpPurchaseOrderStatus(tx *gorm.DB, poID string) error {
	var lines []*models.PurchaseOrderLine
	if err := tx.Where("purchase_order_id = ? AND status IN ?", poID,
		[]int32{poLineStatusPending, poLineStatusPartial, poLineStatusReceived}).
		Find(&lines).Error; err != nil {
		return fmt.Errorf("load purchase order lines: %w", err)
	}
	if len(lines) == 0 {
		return nil
	}
	allReceived := true
	anyReceived := false
	for _, l := range lines {
		if l.ReceivedQuantity >= l.OrderedQuantity {
			anyReceived = true
			continue
		}
		allReceived = false
		if l.ReceivedQuantity > 0 {
			anyReceived = true
		}
	}
	var status int32
	switch {
	case allReceived:
		status = poStatusReceived
	case anyReceived:
		status = poStatusPartiallyReceived
	default:
		return nil
	}
	if err := tx.Model(&models.PurchaseOrder{}).
		Where("id = ?", poID).
		UpdateColumn("status", status).Error; err != nil {
		return fmt.Errorf("roll up purchase order status: %w", err)
	}
	return nil
}

func (r *goodsReceiptRepository) GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, false).
		Preload("Lines", receiptLines).
		First(gr, "id = ?", id).Error
	return gr, err
}

func (r *goodsReceiptRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, false).
		Preload("Lines", receiptLines).
		First(gr, "idempotency_key = ?", key).Error
	return gr, err
}

func (r *goodsReceiptRepository) ListPage(
	ctx context.Context,
	filter GoodsReceiptFilter,
	page Page,
) ([]*models.GoodsReceipt, *PageKey, error) {
	query := r.Pool().DB(ctx, true).Model(&models.GoodsReceipt{}).Preload("Lines", receiptLines)
	if filter.PurchaseOrderID != "" {
		query = query.Where("purchase_order_id = ?", filter.PurchaseOrderID)
	}
	if filter.PropertyID != "" {
		query = query.Where("property_id = ?", filter.PropertyID)
	}
	if filter.Status != 0 {
		query = query.Where("status = ?", filter.Status)
	}
	return findPage(query, page, func(g *models.GoodsReceipt) *data.BaseModel { return &g.BaseModel })
}

func receiptLines(db *gorm.DB) *gorm.DB { return db.Order("created_at ASC, id ASC") }

type goodsReceiptLineRepository struct {
	datastore.BaseRepository[*models.GoodsReceiptLine]
}

func NewGoodsReceiptLineRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) GoodsReceiptLineRepository {
	return &goodsReceiptLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceiptLine](
			ctx, dbPool, workMan, func() *models.GoodsReceiptLine { return &models.GoodsReceiptLine{} },
		),
	}
}

func (r *goodsReceiptLineRepository) ListByGoodsReceiptID(
	ctx context.Context,
	goodsReceiptID string,
) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, false).Where("goods_receipt_id = ?", goodsReceiptID).
		Order("created_at ASC, id ASC").Find(&lines).Error
	return lines, err
}

func (r *goodsReceiptLineRepository) ListPendingDelivery(
	ctx context.Context,
	limit int,
) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, false).
		Preload("GoodsReceipt").
		Where("delivery_status = ?", deliveryStatusPending).
		Order("delivery_attempts ASC, created_at ASC, id ASC").
		Limit(limit).
		Find(&lines).Error
	return lines, err
}

func (r *goodsReceiptLineRepository) SettleDelivery(
	ctx context.Context,
	lineID string,
	status int32,
	note string,
	at time.Time,
) (bool, error) {
	updates := map[string]any{"delivery_status": status, "delivery_note": note}
	if status != deliveryStatusPending {
		updates["delivered_at"] = at
	}
	result := r.Pool().DB(ctx, false).Model(&models.GoodsReceiptLine{}).
		Where("id = ? AND delivery_status = ?", lineID, deliveryStatusPending).
		UpdateColumns(updates)
	if result.Error != nil {
		return false, fmt.Errorf("settle delivery of receipt line %s: %w", lineID, result.Error)
	}
	return result.RowsAffected == 1, nil
}

func (r *goodsReceiptLineRepository) RecordDeliveryAttempt(ctx context.Context, lineID, note string) error {
	err := r.Pool().DB(ctx, false).Model(&models.GoodsReceiptLine{}).
		Where("id = ? AND delivery_status = ?", lineID, deliveryStatusPending).
		UpdateColumns(map[string]any{
			"delivery_attempts": gorm.Expr("delivery_attempts + 1"),
			"delivery_note":     note,
		}).Error
	if err != nil {
		return fmt.Errorf("record delivery attempt for receipt line %s: %w", lineID, err)
	}
	return nil
}

func (r *goodsReceiptLineRepository) GetInReceipt(
	ctx context.Context,
	goodsReceiptID, lineID string,
) (*models.GoodsReceiptLine, error) {
	line := &models.GoodsReceiptLine{}
	err := r.Pool().DB(ctx, false).
		Preload("GoodsReceipt").
		First(line, "id = ? AND goods_receipt_id = ?", lineID, goodsReceiptID).Error
	return line, err
}

func (r *goodsReceiptLineRepository) Resolve(
	ctx context.Context,
	lineID string,
	from []int32,
	by, note string,
	at time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).Model(&models.GoodsReceiptLine{}).
		Where("id = ? AND delivery_status IN ?", lineID, from).
		UpdateColumns(map[string]any{
			"delivery_status": deliveryStatusResolved,
			"resolved_by":     by,
			"resolved_at":     at,
			"resolution_note": note,
		})
	if result.Error != nil {
		return false, fmt.Errorf("resolve receipt line %s: %w", lineID, result.Error)
	}
	return result.RowsAffected == 1, nil
}

func (r *goodsReceiptLineRepository) Requeue(
	ctx context.Context,
	lineID string,
	from []int32,
	locationID, note string,
) (bool, error) {
	updates := map[string]any{
		"delivery_status": deliveryStatusPending,
		"delivery_note":   note,
		"delivered_at":    nil,
	}
	if locationID != "" {
		updates["location_id"] = locationID
	}
	result := r.Pool().DB(ctx, false).Model(&models.GoodsReceiptLine{}).
		Where("id = ? AND delivery_status IN ?", lineID, from).
		UpdateColumns(updates)
	if result.Error != nil {
		return false, fmt.Errorf("requeue receipt line %s: %w", lineID, result.Error)
	}
	return result.RowsAffected == 1, nil
}
