package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type orderRepository struct {
	datastore.BaseRepository[*models.Order]
}

func NewOrderRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrderRepository {
	return &orderRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Order](
			ctx, dbPool, workMan, func() *models.Order { return &models.Order{} },
		),
	}
}

func (r *orderRepository) GetWithLines(ctx context.Context, id string) (*models.Order, error) {
	order := &models.Order{}
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		First(order, "id = ?", id).Error
	return order, err
}

func (r *orderRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.Order, error) {
	order := &models.Order{}
	err := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		First(order, "idempotency_key = ?", key).Error
	return order, err
}

func (r *orderRepository) ListByShopID(ctx context.Context, shopID string, limit, offset int) ([]*models.Order, error) {
	var orders []*models.Order
	query := r.Pool().DB(ctx, true).
		Preload(clause.Associations).
		Where("shop_id = ?", shopID).
		Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&orders).Error
	return orders, err
}

type orderLineRepository struct {
	datastore.BaseRepository[*models.OrderLine]
}

func NewOrderLineRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrderLineRepository {
	return &orderLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.OrderLine](
			ctx, dbPool, workMan, func() *models.OrderLine { return &models.OrderLine{} },
		),
	}
}

func (r *orderLineRepository) GetByOrderID(ctx context.Context, orderID string) ([]*models.OrderLine, error) {
	var lines []*models.OrderLine
	err := r.Pool().DB(ctx, true).Where("order_id = ?", orderID).Find(&lines).Error
	return lines, err
}
