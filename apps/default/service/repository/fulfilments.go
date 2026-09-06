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

// CreateWithLines inserts the fulfilment and all of its lines in one
// transaction so a crash cannot leave a header without lines.
func (r *fulfilmentRepository) CreateWithLines(
	ctx context.Context,
	fulfilment *models.Fulfilment,
	lines []*models.FulfilmentLine,
) error {
	if fulfilment == nil {
		return errors.New("create fulfilment: fulfilment is required")
	}
	if len(lines) == 0 {
		return errors.New("create fulfilment: at least one line is required")
	}
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(fulfilment).Error; err != nil {
			return fmt.Errorf("create fulfilment: %w", err)
		}
		for _, line := range lines {
			line.FulfilmentID = fulfilment.GetID()
			if err := tx.Create(line).Error; err != nil {
				return fmt.Errorf("create fulfilment line: %w", err)
			}
		}
		return nil
	})
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

// GetFulfilledQuantityByOrderLineID sums quantities on non-cancelled
// fulfilments for one order line.
func (r *fulfilmentLineRepository) GetFulfilledQuantityByOrderLineID(
	ctx context.Context,
	orderLineID string,
) (int64, error) {
	var total int64
	err := r.Pool().DB(ctx, true).
		Table("fulfilment_lines AS fl").
		Joins("JOIN fulfilments f ON f.id = fl.fulfilment_id AND f.deleted_at IS NULL").
		Where("fl.order_line_id = ? AND fl.deleted_at IS NULL AND f.status <> ?",
			orderLineID, cancelledFulfilmentStatus).
		Select("COALESCE(SUM(fl.quantity), 0)").
		Scan(&total).Error
	return total, err
}

// SumFulfilledByOrderID returns fulfilled quantity per order line for a whole
// order in a single query, ignoring cancelled fulfilments.
func (r *fulfilmentLineRepository) SumFulfilledByOrderID(
	ctx context.Context,
	orderID string,
) (map[string]int64, error) {
	type row struct {
		OrderLineID string
		Total       int64
	}
	var rows []row
	err := r.Pool().DB(ctx, true).
		Table("fulfilment_lines AS fl").
		Joins("JOIN fulfilments f ON f.id = fl.fulfilment_id AND f.deleted_at IS NULL").
		Where("f.order_id = ? AND fl.deleted_at IS NULL AND f.status <> ?", orderID, cancelledFulfilmentStatus).
		Select("fl.order_line_id AS order_line_id, COALESCE(SUM(fl.quantity), 0) AS total").
		Group("fl.order_line_id").
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}
	out := make(map[string]int64, len(rows))
	for _, rw := range rows {
		out[rw.OrderLineID] = rw.Total
	}
	return out, nil
}

// cancelledFulfilmentStatus mirrors commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED.
const cancelledFulfilmentStatus = 6
