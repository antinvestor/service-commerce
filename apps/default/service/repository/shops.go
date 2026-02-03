package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

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
