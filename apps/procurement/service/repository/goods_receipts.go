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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

// ErrOverReceipt is returned when a receipt line would push a purchase order
// line past its ordered quantity, including under concurrent receipts.
var ErrOverReceipt = errors.New("received quantity exceeds remaining ordered quantity")

// Purchase order and line statuses mirrored from procurementv1 so the
// repository can roll status up without importing the API package.
const (
	poStatusPartiallyReceived = 4
	poStatusReceived          = 5
	poLineStatusPending       = 1
	poLineStatusPartial       = 2
	poLineStatusReceived      = 3
	poLineStatusCancelled     = 4
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
		if err := tx.Create(gr).Error; err != nil {
			return fmt.Errorf("create goods receipt: %w", err)
		}
		for _, line := range lines {
			line.GoodsReceiptID = gr.GetID()
			if err := tx.Create(line).Error; err != nil {
				return fmt.Errorf("create goods receipt line: %w", err)
			}

			result := tx.Model(&models.PurchaseOrderLine{}).
				Where("id = ? AND status <> ? AND received_quantity + ? <= ordered_quantity",
					line.PurchaseOrderLineID, poLineStatusCancelled, line.ReceivedQuantity).
				UpdateColumns(map[string]any{
					"received_quantity": gorm.Expr("received_quantity + ?", line.ReceivedQuantity),
					"status": gorm.Expr(
						"CASE WHEN received_quantity + ? >= ordered_quantity THEN ?::integer ELSE ?::integer END",
						line.ReceivedQuantity, poLineStatusReceived, poLineStatusPartial,
					),
				})
			if result.Error != nil {
				return fmt.Errorf("receive purchase order line %s: %w", line.PurchaseOrderLineID, result.Error)
			}
			if result.RowsAffected == 0 {
				return fmt.Errorf("%w: purchase order line %s", ErrOverReceipt, line.PurchaseOrderLineID)
			}
		}

		return rollUpPurchaseOrderStatus(tx, gr.PurchaseOrderID)
	})
}

// rollUpPurchaseOrderStatus derives the PO status from its live lines.
func rollUpPurchaseOrderStatus(tx *gorm.DB, poID string) error {
	var lines []*models.PurchaseOrderLine
	if err := tx.Where("purchase_order_id = ? AND status <> ?", poID, poLineStatusCancelled).
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
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(gr, "id = ?", id).Error
	return gr, err
}

func (r *goodsReceiptRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(gr, "idempotency_key = ?", key).Error
	return gr, err
}

func (r *goodsReceiptRepository) ListByPurchaseOrderID(
	ctx context.Context,
	purchaseOrderID string,
) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		Where("purchase_order_id = ?", purchaseOrderID).
		Order("created_at DESC").
		Find(&receipts).Error
	return receipts, err
}

func (r *goodsReceiptRepository) ListByPropertyID(
	ctx context.Context,
	propertyID string,
	limit, offset int,
) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
	query := r.Pool().DB(ctx, true).
		Preload("Lines").
		Where("property_id = ?", propertyID).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&receipts).Error
	return receipts, err
}

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
	err := r.Pool().DB(ctx, true).Where("goods_receipt_id = ?", goodsReceiptID).Find(&lines).Error
	return lines, err
}

func (r *goodsReceiptLineRepository) ListByPurchaseOrderLineID(
	ctx context.Context,
	purchaseOrderLineID string,
) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, true).Where("purchase_order_line_id = ?", purchaseOrderLineID).Find(&lines).Error
	return lines, err
}
