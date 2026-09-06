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

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type shopRepository struct {
	datastore.BaseRepository[*models.Shop]
}

func NewShopRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ShopRepository {
	return &shopRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Shop](
			ctx, dbPool, workMan, func() *models.Shop { return &models.Shop{} },
		),
	}
}

func (r *shopRepository) GetBySlug(ctx context.Context, slug string) (*models.Shop, error) {
	shop := &models.Shop{}
	err := r.Pool().DB(ctx, true).First(shop, "slug = ?", slug).Error
	return shop, err
}

func (r *shopRepository) List(ctx context.Context, page Page) ([]*models.Shop, *PageKey, error) {
	var shops []*models.Shop
	if err := applyKeyset(r.Pool().DB(ctx, true), page).Find(&shops).Error; err != nil {
		return nil, nil, err
	}
	shops, next := trimPage(shops, page, func(s *models.Shop) PageKey { return baseKey(s.BaseModel) })
	return shops, next, nil
}
