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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type cartRepository struct {
	datastore.BaseRepository[*models.Cart]
}

func NewCartRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) CartRepository {
	return &cartRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Cart](
			ctx, dbPool, workMan, func() *models.Cart { return &models.Cart{} },
		),
	}
}

func (r *cartRepository) GetWithLines(ctx context.Context, id string) (*models.Cart, error) {
	cart := &models.Cart{}
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		First(cart, "id = ?", id).Error
	return cart, err
}

type cartLineRepository struct {
	datastore.BaseRepository[*models.CartLine]
}

func NewCartLineRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) CartLineRepository {
	return &cartLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.CartLine](
			ctx, dbPool, workMan, func() *models.CartLine { return &models.CartLine{} },
		),
	}
}

func (r *cartLineRepository) GetByCartID(ctx context.Context, cartID string) ([]*models.CartLine, error) {
	var lines []*models.CartLine
	err := r.Pool().DB(ctx, true).Where("cart_id = ?", cartID).Find(&lines).Error
	return lines, err
}

func (r *cartLineRepository) GetByCartAndVariant(
	ctx context.Context,
	cartID, variantID string,
) (*models.CartLine, error) {
	line := &models.CartLine{}
	err := r.Pool().DB(ctx, true).
		Where("cart_id = ? AND product_variant_id = ?", cartID, variantID).
		First(line).Error
	return line, err
}
