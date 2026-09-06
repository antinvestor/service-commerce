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

// ErrPurchaseOrderStateChanged is returned when a compare-and-set status
// transition finds the purchase order no longer in the expected status.
var ErrPurchaseOrderStateChanged = errors.New("purchase order status changed concurrently")

type purchaseOrderRepository struct {
	datastore.BaseRepository[*models.PurchaseOrder]
}

func NewPurchaseOrderRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) PurchaseOrderRepository {
	return &purchaseOrderRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PurchaseOrder](
			ctx, dbPool, workMan, func() *models.PurchaseOrder { return &models.PurchaseOrder{} },
		),
	}
}

// CreateWithLines inserts the purchase order and its lines in one transaction.
func (r *purchaseOrderRepository) CreateWithLines(
	ctx context.Context,
	po *models.PurchaseOrder,
	lines []*models.PurchaseOrderLine,
) error {
	if po == nil {
		return errors.New("create purchase order: order is required")
	}
	if len(lines) == 0 {
		return errors.New("create purchase order: at least one line is required")
	}
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(po).Error; err != nil {
			return fmt.Errorf("create purchase order: %w", err)
		}
		for _, line := range lines {
			line.PurchaseOrderID = po.GetID()
			if err := tx.Create(line).Error; err != nil {
				return fmt.Errorf("create purchase order line: %w", err)
			}
		}
		return nil
	})
}

// Transition moves the purchase order from expectedStatus to newStatus and
// applies extra column updates atomically. When lineStatus is non-zero every
// non-cancelled line is moved to that status in the same transaction.
func (r *purchaseOrderRepository) Transition(
	ctx context.Context,
	poID string,
	expectedStatus, newStatus int32,
	columns map[string]any,
	lineStatus int32,
) error {
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		updates := map[string]any{"status": newStatus}
		for k, v := range columns {
			updates[k] = v
		}
		result := tx.Model(&models.PurchaseOrder{}).
			Where("id = ? AND status = ?", poID, expectedStatus).
			UpdateColumns(updates)
		if result.Error != nil {
			return fmt.Errorf("transition purchase order: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return ErrPurchaseOrderStateChanged
		}
		if lineStatus != 0 {
			if err := tx.Model(&models.PurchaseOrderLine{}).
				Where("purchase_order_id = ? AND status <> ?", poID, lineStatus).
				UpdateColumn("status", lineStatus).Error; err != nil {
				return fmt.Errorf("transition purchase order lines: %w", err)
			}
		}
		return nil
	})
}

func (r *purchaseOrderRepository) GetWithLines(ctx context.Context, id string) (*models.PurchaseOrder, error) {
	po := &models.PurchaseOrder{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(po, "id = ?", id).Error
	return po, err
}

func (r *purchaseOrderRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.PurchaseOrder, error) {
	po := &models.PurchaseOrder{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(po, "idempotency_key = ?", key).Error
	return po, err
}

func (r *purchaseOrderRepository) ListByPropertyID(
	ctx context.Context,
	propertyID string,
	limit, offset int,
) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
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
	err := query.Find(&orders).Error
	return orders, err
}

func (r *purchaseOrderRepository) ListBySupplierID(
	ctx context.Context,
	supplierID string,
	limit, offset int,
) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
	query := r.Pool().DB(ctx, true).
		Preload("Lines").
		Where("supplier_id = ?", supplierID).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&orders).Error
	return orders, err
}

func (r *purchaseOrderRepository) ListByStatus(
	ctx context.Context,
	status int32,
	limit, offset int,
) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
	query := r.Pool().DB(ctx, true).
		Preload("Lines").
		Where("status = ?", status).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&orders).Error
	return orders, err
}

type purchaseOrderLineRepository struct {
	datastore.BaseRepository[*models.PurchaseOrderLine]
}

func NewPurchaseOrderLineRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) PurchaseOrderLineRepository {
	return &purchaseOrderLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PurchaseOrderLine](
			ctx, dbPool, workMan, func() *models.PurchaseOrderLine { return &models.PurchaseOrderLine{} },
		),
	}
}

func (r *purchaseOrderLineRepository) ListByPurchaseOrderID(
	ctx context.Context,
	purchaseOrderID string,
) ([]*models.PurchaseOrderLine, error) {
	var lines []*models.PurchaseOrderLine
	err := r.Pool().DB(ctx, true).Where("purchase_order_id = ?", purchaseOrderID).Find(&lines).Error
	return lines, err
}
