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

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type supplierRepository struct {
	datastore.BaseRepository[*models.Supplier]
}

func NewSupplierRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) SupplierRepository {
	return &supplierRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Supplier](
			ctx, dbPool, workMan, func() *models.Supplier { return &models.Supplier{} },
		),
	}
}

func (r *supplierRepository) ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.Supplier, error) {
	var suppliers []*models.Supplier
	query := r.Pool().DB(ctx, true).
		Where("status = ?", status).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&suppliers).Error
	return suppliers, err
}

func (r *supplierRepository) ListByType(ctx context.Context, supplierType int32, limit, offset int) ([]*models.Supplier, error) {
	var suppliers []*models.Supplier
	query := r.Pool().DB(ctx, true).
		Where("supplier_type = ?", supplierType).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&suppliers).Error
	return suppliers, err
}

type supplierItemRepository struct {
	datastore.BaseRepository[*models.SupplierItem]
}

func NewSupplierItemRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) SupplierItemRepository {
	return &supplierItemRepository{
		BaseRepository: datastore.NewBaseRepository[*models.SupplierItem](
			ctx, dbPool, workMan, func() *models.SupplierItem { return &models.SupplierItem{} },
		),
	}
}

func (r *supplierItemRepository) ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.SupplierItem, error) {
	var items []*models.SupplierItem
	query := r.Pool().DB(ctx, true).
		Where("supplier_id = ?", supplierID).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&items).Error
	return items, err
}

func (r *supplierItemRepository) ListByInventoryItemID(ctx context.Context, inventoryItemID string) ([]*models.SupplierItem, error) {
	var items []*models.SupplierItem
	err := r.Pool().DB(ctx, true).
		Where("inventory_item_id = ?", inventoryItemID).
		Find(&items).Error
	return items, err
}

func (r *supplierItemRepository) GetBySupplierAndItem(ctx context.Context, supplierID, inventoryItemID string) (*models.SupplierItem, error) {
	item := &models.SupplierItem{}
	err := r.Pool().DB(ctx, true).
		First(item, "supplier_id = ? AND inventory_item_id = ?", supplierID, inventoryItemID).Error
	return item, err
}
