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
	"time"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// --- PriceList ---

type priceListRepository struct {
	datastore.BaseRepository[*models.PriceList]
}

func NewPriceListRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) PriceListRepository {
	return &priceListRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PriceList](
			ctx, dbPool, workMan, func() *models.PriceList { return &models.PriceList{} },
		),
	}
}

func (r *priceListRepository) ListByShopID(
	ctx context.Context, shopID string, limit, offset int,
) ([]*models.PriceList, error) {
	var items []*models.PriceList
	query := r.Pool().DB(ctx, true).
		Where("shop_id = ?", shopID).
		Order("priority DESC, created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&items).Error
	return items, err
}

func (r *priceListRepository) ListActive(
	ctx context.Context,
	shopID string,
) ([]*models.PriceList, error) {
	var items []*models.PriceList
	now := time.Now()
	err := r.Pool().DB(ctx, true).
		Where("shop_id = ? AND status = ? AND (valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)",
			shopID, 1, now, now).
		Order("priority DESC").
		Find(&items).Error
	return items, err
}

// --- PriceListEntry ---

type priceListEntryRepository struct {
	datastore.BaseRepository[*models.PriceListEntry]
}

func NewPriceListEntryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) PriceListEntryRepository {
	return &priceListEntryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PriceListEntry](
			ctx, dbPool, workMan, func() *models.PriceListEntry { return &models.PriceListEntry{} },
		),
	}
}

func (r *priceListEntryRepository) ListByPriceListID(
	ctx context.Context,
	priceListID string,
) ([]*models.PriceListEntry, error) {
	var items []*models.PriceListEntry
	err := r.Pool().DB(ctx, true).Where("price_list_id = ?", priceListID).Find(&items).Error
	return items, err
}

func (r *priceListEntryRepository) DeleteByPriceListAndVariant(
	ctx context.Context,
	priceListID, variantID string,
) error {
	return r.Pool().DB(ctx, false).
		Where("price_list_id = ? AND product_variant_id = ?", priceListID, variantID).
		Delete(&models.PriceListEntry{}).Error
}

func (r *priceListEntryRepository) GetByPriceListAndVariant(
	ctx context.Context,
	priceListID, variantID string,
) ([]*models.PriceListEntry, error) {
	var items []*models.PriceListEntry
	err := r.Pool().DB(ctx, true).
		Where("price_list_id = ? AND product_variant_id = ?", priceListID, variantID).
		Find(&items).Error
	return items, err
}

// --- CustomerPriceListAssignment ---

type customerPriceListAssignmentRepository struct {
	datastore.BaseRepository[*models.CustomerPriceListAssignment]
}

func NewCustomerPriceListAssignmentRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) CustomerPriceListAssignmentRepository {
	return &customerPriceListAssignmentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.CustomerPriceListAssignment](
			ctx,
			dbPool,
			workMan,
			func() *models.CustomerPriceListAssignment { return &models.CustomerPriceListAssignment{} },
		),
	}
}

func (r *customerPriceListAssignmentRepository) ListByCustomerID(
	ctx context.Context,
	customerID string,
	limit, offset int,
) ([]*models.CustomerPriceListAssignment, error) {
	var items []*models.CustomerPriceListAssignment
	query := r.Pool().DB(ctx, true).Where("customer_id = ?", customerID).Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&items).Error
	return items, err
}

func (r *customerPriceListAssignmentRepository) GetByCustomerAndPriceList(
	ctx context.Context,
	customerID, priceListID string,
) (*models.CustomerPriceListAssignment, error) {
	item := &models.CustomerPriceListAssignment{}
	err := r.Pool().DB(ctx, true).
		First(item, "customer_id = ? AND price_list_id = ?", customerID, priceListID).Error
	return item, err
}

// --- CustomerPriceOverride ---

type customerPriceOverrideRepository struct {
	datastore.BaseRepository[*models.CustomerPriceOverride]
}

func NewCustomerPriceOverrideRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) CustomerPriceOverrideRepository {
	return &customerPriceOverrideRepository{
		BaseRepository: datastore.NewBaseRepository[*models.CustomerPriceOverride](
			ctx,
			dbPool,
			workMan,
			func() *models.CustomerPriceOverride { return &models.CustomerPriceOverride{} },
		),
	}
}

func (r *customerPriceOverrideRepository) ListByCustomerID(
	ctx context.Context,
	customerID string,
	limit, offset int,
) ([]*models.CustomerPriceOverride, error) {
	var items []*models.CustomerPriceOverride
	query := r.Pool().DB(ctx, true).Where("customer_id = ?", customerID).Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&items).Error
	return items, err
}

func (r *customerPriceOverrideRepository) GetByCustomerAndVariant(
	ctx context.Context,
	customerID, variantID string,
) (*models.CustomerPriceOverride, error) {
	item := &models.CustomerPriceOverride{}
	now := time.Now()
	err := r.Pool().DB(ctx, true).
		First(item, "customer_id = ? AND product_variant_id = ? AND status = ? AND (valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)",
			customerID, variantID, 1, now, now).
		Error
	return item, err
}

// --- DiscountRule ---

type discountRuleRepository struct {
	datastore.BaseRepository[*models.DiscountRule]
}

func NewDiscountRuleRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) DiscountRuleRepository {
	return &discountRuleRepository{
		BaseRepository: datastore.NewBaseRepository[*models.DiscountRule](
			ctx, dbPool, workMan, func() *models.DiscountRule { return &models.DiscountRule{} },
		),
	}
}

func (r *discountRuleRepository) ListByShopID(
	ctx context.Context,
	shopID string,
	limit, offset int,
) ([]*models.DiscountRule, error) {
	var items []*models.DiscountRule
	query := r.Pool().DB(ctx, true).Where("shop_id = ?", shopID).Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&items).Error
	return items, err
}

func (r *discountRuleRepository) ListActive(
	ctx context.Context,
	shopID string,
) ([]*models.DiscountRule, error) {
	var items []*models.DiscountRule
	now := time.Now()
	err := r.Pool().DB(ctx, true).
		Where("shop_id = ? AND status = ? AND (valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)",
			shopID, 1, now, now).
		Find(&items).Error
	return items, err
}
