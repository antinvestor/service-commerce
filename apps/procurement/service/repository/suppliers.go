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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

const (
	supplierStatusActive     = 1
	supplierItemStatusActive = 1
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

func (r *supplierRepository) ListPage(
	ctx context.Context,
	filter SupplierFilter,
	page Page,
) ([]*models.Supplier, *PageKey, error) {
	query := r.Pool().DB(ctx, true).Model(&models.Supplier{})
	if filter.Status != 0 {
		query = query.Where("status = ?", filter.Status)
	}
	if filter.SupplierType != 0 {
		query = query.Where("supplier_type = ?", filter.SupplierType)
	}
	var suppliers []*models.Supplier
	if err := applyKeyset(query, page).Find(&suppliers).Error; err != nil {
		return nil, nil, err
	}
	items, next := trimPage(suppliers, page, func(s *models.Supplier) *data.BaseModel { return &s.BaseModel })
	return items, next, nil
}

type supplierItemRepository struct {
	datastore.BaseRepository[*models.SupplierItem]
}

func NewSupplierItemRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) SupplierItemRepository {
	return &supplierItemRepository{
		BaseRepository: datastore.NewBaseRepository[*models.SupplierItem](
			ctx, dbPool, workMan, func() *models.SupplierItem { return &models.SupplierItem{} },
		),
	}
}

func (r *supplierItemRepository) ListPage(
	ctx context.Context,
	filter SupplierItemFilter,
	page Page,
) ([]*models.SupplierItem, *PageKey, error) {
	query := r.Pool().DB(ctx, true).Model(&models.SupplierItem{})
	if filter.SupplierID != "" {
		query = query.Where("supplier_id = ?", filter.SupplierID)
	}
	if filter.InventoryItemID != "" {
		query = query.Where("inventory_item_id = ?", filter.InventoryItemID)
	}
	var items []*models.SupplierItem
	if err := applyKeyset(query, page).Find(&items).Error; err != nil {
		return nil, nil, err
	}
	out, next := trimPage(items, page, func(i *models.SupplierItem) *data.BaseModel { return &i.BaseModel })
	return out, next, nil
}

func (r *supplierItemRepository) ListActiveForInventoryItems(
	ctx context.Context,
	inventoryItemIDs []string,
) ([]*models.SupplierItem, error) {
	var items []*models.SupplierItem
	if len(inventoryItemIDs) == 0 {
		return items, nil
	}
	err := r.Pool().DB(ctx, true).
		Joins("Supplier").
		Where("supplier_items.inventory_item_id IN ?", inventoryItemIDs).
		Where("supplier_items.status = ? AND \"Supplier\".status = ?", supplierItemStatusActive, supplierStatusActive).
		Order("supplier_items.id").
		Find(&items).Error
	return items, err
}
