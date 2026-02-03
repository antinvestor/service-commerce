package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
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

func (r *cartLineRepository) GetByCartAndVariant(ctx context.Context, cartID, variantID string) (*models.CartLine, error) {
	line := &models.CartLine{}
	err := r.Pool().DB(ctx, true).
		Where("cart_id = ? AND product_variant_id = ?", cartID, variantID).
		First(line).Error
	return line, err
}
