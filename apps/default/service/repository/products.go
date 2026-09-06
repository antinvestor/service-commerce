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

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

// ErrInsufficientStock is returned when a stock mutation affects zero rows
// (missing variant, concurrent oversell, or quantity larger than available stock).
var ErrInsufficientStock = errors.New("insufficient stock")

type productRepository struct {
	datastore.BaseRepository[*models.Product]
}

func NewProductRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ProductRepository {
	return &productRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Product](
			ctx, dbPool, workMan, func() *models.Product { return &models.Product{} },
		),
	}
}

// ListByShopID pages products for a shop newest-first. When statuses is
// non-empty only products in those statuses are returned.
func (r *productRepository) ListByShopID(
	ctx context.Context,
	shopID string,
	statuses []int32,
	page Page,
) ([]*models.Product, *PageKey, error) {
	var products []*models.Product
	query := r.Pool().DB(ctx, true).Where("shop_id = ?", shopID)
	if len(statuses) > 0 {
		query = query.Where("status IN ?", statuses)
	}
	if err := applyKeyset(query, page).Find(&products).Error; err != nil {
		return nil, nil, err
	}
	products, next := trimPage(products, page, func(p *models.Product) PageKey { return baseKey(p.BaseModel) })
	return products, next, nil
}

type productVariantRepository struct {
	datastore.BaseRepository[*models.ProductVariant]
}

func NewProductVariantRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ProductVariantRepository {
	return &productVariantRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ProductVariant](
			ctx, dbPool, workMan, func() *models.ProductVariant { return &models.ProductVariant{} },
		),
	}
}

func (r *productVariantRepository) ListByProductID(
	ctx context.Context,
	productID string,
) ([]*models.ProductVariant, error) {
	var variants []*models.ProductVariant
	err := r.Pool().DB(ctx, true).Where("product_id = ?", productID).Find(&variants).Error
	return variants, err
}

// SetStock overwrites a variant's on-hand quantity. This is an explicit
// operator action (stock take); order flow only ever adjusts relatively.
func (r *productVariantRepository) SetStock(ctx context.Context, variantID string, quantity int64) error {
	if quantity < 0 {
		return errors.New("set stock: quantity must not be negative")
	}
	result := r.Pool().DB(ctx, false).
		Model(&models.ProductVariant{}).
		Where("id = ?", variantID).
		UpdateColumn("stock_quantity", quantity)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("variant %s not found for stock set", variantID)
	}
	return nil
}

func (r *productVariantRepository) DecrementStock(ctx context.Context, variantID string, quantity int64) error {
	if quantity <= 0 {
		return fmt.Errorf("%w: quantity must be positive", ErrInsufficientStock)
	}
	result := r.Pool().DB(ctx, false).
		Model(&models.ProductVariant{}).
		Where("id = ? AND stock_quantity >= ?", variantID, quantity).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity - ?", quantity))
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("%w for variant %s", ErrInsufficientStock, variantID)
	}
	return nil
}

func (r *productVariantRepository) IncrementStock(ctx context.Context, variantID string, quantity int64) error {
	if quantity <= 0 {
		return errors.New("increment stock: quantity must be positive")
	}
	result := r.Pool().DB(ctx, false).
		Model(&models.ProductVariant{}).
		Where("id = ?", variantID).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity + ?", quantity))
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("variant %s not found for stock increment", variantID)
	}
	return nil
}
