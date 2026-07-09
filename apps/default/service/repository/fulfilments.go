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

type fulfilmentRepository struct {
	datastore.BaseRepository[*models.Fulfilment]
}

func NewFulfilmentRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) FulfilmentRepository {
	return &fulfilmentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Fulfilment](
			ctx, dbPool, workMan, func() *models.Fulfilment { return &models.Fulfilment{} },
		),
	}
}

func (r *fulfilmentRepository) GetWithLines(ctx context.Context, id string) (*models.Fulfilment, error) {
	fulfilment := &models.Fulfilment{}
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		First(fulfilment, "id = ?", id).Error
	return fulfilment, err
}

func (r *fulfilmentRepository) ListByOrderID(ctx context.Context, orderID string) ([]*models.Fulfilment, error) {
	var fulfilments []*models.Fulfilment
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where("order_id = ?", orderID).Find(&fulfilments).Error
	return fulfilments, err
}

type fulfilmentLineRepository struct {
	datastore.BaseRepository[*models.FulfilmentLine]
}

func NewFulfilmentLineRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) FulfilmentLineRepository {
	return &fulfilmentLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.FulfilmentLine](
			ctx, dbPool, workMan, func() *models.FulfilmentLine { return &models.FulfilmentLine{} },
		),
	}
}

func (r *fulfilmentLineRepository) GetByFulfilmentID(
	ctx context.Context,
	fulfilmentID string,
) ([]*models.FulfilmentLine, error) {
	var lines []*models.FulfilmentLine
	err := r.Pool().DB(ctx, true).Where("fulfilment_id = ?", fulfilmentID).Find(&lines).Error
	return lines, err
}

func (r *fulfilmentLineRepository) GetFulfilledQuantityByOrderLineID(
	ctx context.Context,
	orderLineID string,
) (int64, error) {
	var total int64
	err := r.Pool().DB(ctx, true).
		Model(&models.FulfilmentLine{}).
		Where("order_line_id = ?", orderLineID).
		Select("COALESCE(SUM(quantity), 0)").
		Scan(&total).Error
	return total, err
}
