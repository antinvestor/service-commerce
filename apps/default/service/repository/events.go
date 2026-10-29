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
	"fmt"
	"time"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type orderEventRepository struct {
	datastore.BaseRepository[*models.OrderEvent]
}

func NewOrderEventRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrderEventRepository {
	return &orderEventRepository{
		BaseRepository: datastore.NewBaseRepository[*models.OrderEvent](
			ctx, dbPool, workMan, func() *models.OrderEvent { return &models.OrderEvent{} },
		),
	}
}

// List pages events oldest first, so a consumer can follow the feed forward.
func (r *orderEventRepository) List(
	ctx context.Context,
	shopID, orderID string,
	page Page,
) ([]*models.OrderEvent, *PageKey, error) {
	var events []*models.OrderEvent
	query := r.Pool().DB(ctx, true).
		Order("created_at ASC, id ASC").
		Limit(page.NormalisedLimit() + 1)
	if shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}
	if orderID != "" {
		query = query.Where("order_id = ?", orderID)
	}
	if page.After != nil {
		query = query.Where("created_at > ? OR (created_at = ? AND id > ?)",
			page.After.CreatedAt, page.After.CreatedAt, page.After.ID)
	}
	if err := query.Find(&events).Error; err != nil {
		return nil, nil, fmt.Errorf("list order events: %w", err)
	}
	events, next := trimPage(events, page, func(e *models.OrderEvent) PageKey { return baseKey(e.BaseModel) })
	return events, next, nil
}

func (r *orderEventRepository) ListDue(ctx context.Context, now time.Time, limit int) ([]*models.OrderEvent, error) {
	var events []*models.OrderEvent
	err := r.Pool().DB(ctx, false).
		Where("delivery = ? AND (next_attempt_at IS NULL OR next_attempt_at <= ?)", models.EventDeliveryPending, now).
		Order("COALESCE(next_attempt_at, created_at) ASC").
		Limit(limit).
		Find(&events).Error
	if err != nil {
		return nil, fmt.Errorf("list due order events: %w", err)
	}
	return events, nil
}

// ClaimDelivery takes an event for one delivery attempt: it counts the
// attempt and holds the event until leaseUntil, so a concurrent run neither
// sends it too nor loses the count if this attempt dies. It reports false
// when the event is not due or another run holds it.
func (r *orderEventRepository) ClaimDelivery(
	ctx context.Context,
	eventID string,
	now, leaseUntil time.Time,
) (*models.OrderEvent, error) {
	result := r.Pool().DB(ctx, false).
		Model(&models.OrderEvent{}).
		Where("id = ? AND delivery = ? AND (next_attempt_at IS NULL OR next_attempt_at <= ?)",
			eventID, models.EventDeliveryPending, now).
		UpdateColumns(map[string]any{
			"next_attempt_at":   leaseUntil,
			"delivery_attempts": gorm.Expr("delivery_attempts + 1"),
		})
	if result.Error != nil {
		return nil, fmt.Errorf("claim order event delivery: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return nil, nil //nolint:nilnil // not claimed is a valid outcome
	}
	event := &models.OrderEvent{}
	if err := r.Pool().DB(ctx, false).First(event, "id = ?", eventID).Error; err != nil {
		return nil, fmt.Errorf("load claimed order event: %w", err)
	}
	return event, nil
}

// RecordDelivery saves the outcome of a claimed attempt; the attempt itself
// was counted by ClaimDelivery.
func (r *orderEventRepository) RecordDelivery(ctx context.Context, event *models.OrderEvent) error {
	return r.Pool().DB(ctx, false).
		Model(event).
		Select("delivery", "next_attempt_at", "delivered_at", "last_error").
		Updates(event).Error
}

// MarkNotRequired stops delivery of the pending events of a shop that has
// no webhook.
func (r *orderEventRepository) MarkNotRequired(ctx context.Context, ids []string) error {
	if len(ids) == 0 {
		return nil
	}
	return r.Pool().DB(ctx, false).
		Model(&models.OrderEvent{}).
		Where("id IN ? AND delivery = ?", ids, models.EventDeliveryPending).
		Update("delivery", models.EventDeliveryNotRequired).Error
}
