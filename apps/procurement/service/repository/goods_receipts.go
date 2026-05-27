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

type goodsReceiptRepository struct {
	datastore.BaseRepository[*models.GoodsReceipt]
}

func NewGoodsReceiptRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) GoodsReceiptRepository {
	return &goodsReceiptRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceipt](
			ctx, dbPool, workMan, func() *models.GoodsReceipt { return &models.GoodsReceipt{} },
		),
	}
}

func (r *goodsReceiptRepository) GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(gr, "id = ?", id).Error
	return gr, err
}

func (r *goodsReceiptRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		First(gr, "idempotency_key = ?", key).Error
	return gr, err
}

func (r *goodsReceiptRepository) ListByPurchaseOrderID(
	ctx context.Context,
	purchaseOrderID string,
) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
	err := r.Pool().DB(ctx, true).
		Preload("Lines").
		Where("purchase_order_id = ?", purchaseOrderID).
		Order("created_at DESC").
		Find(&receipts).Error
	return receipts, err
}

func (r *goodsReceiptRepository) ListByPropertyID(
	ctx context.Context,
	propertyID string,
	limit, offset int,
) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
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
	err := query.Find(&receipts).Error
	return receipts, err
}

type goodsReceiptLineRepository struct {
	datastore.BaseRepository[*models.GoodsReceiptLine]
}

func NewGoodsReceiptLineRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) GoodsReceiptLineRepository {
	return &goodsReceiptLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceiptLine](
			ctx, dbPool, workMan, func() *models.GoodsReceiptLine { return &models.GoodsReceiptLine{} },
		),
	}
}

func (r *goodsReceiptLineRepository) ListByGoodsReceiptID(
	ctx context.Context,
	goodsReceiptID string,
) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, true).Where("goods_receipt_id = ?", goodsReceiptID).Find(&lines).Error
	return lines, err
}

func (r *goodsReceiptLineRepository) ListByPurchaseOrderLineID(
	ctx context.Context,
	purchaseOrderLineID string,
) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, true).Where("purchase_order_line_id = ?", purchaseOrderLineID).Find(&lines).Error
	return lines, err
}
