package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

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

func (r *productRepository) ListByShopID(ctx context.Context, shopID string, limit, offset int) ([]*models.Product, error) {
	var products []*models.Product
	query := r.Pool().DB(ctx, true).Where("shop_id = ?", shopID).Order("created_at DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}
	err := query.Find(&products).Error
	return products, err
}

type productVariantRepository struct {
	datastore.BaseRepository[*models.ProductVariant]
}

func NewProductVariantRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ProductVariantRepository {
	return &productVariantRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ProductVariant](
			ctx, dbPool, workMan, func() *models.ProductVariant { return &models.ProductVariant{} },
		),
	}
}

func (r *productVariantRepository) ListByProductID(ctx context.Context, productID string) ([]*models.ProductVariant, error) {
	var variants []*models.ProductVariant
	err := r.Pool().DB(ctx, true).Where("product_id = ?", productID).Find(&variants).Error
	return variants, err
}

func (r *productVariantRepository) DecrementStock(ctx context.Context, variantID string, quantity int64) error {
	return r.Pool().DB(ctx, false).
		Model(&models.ProductVariant{}).
		Where("id = ? AND stock_quantity >= ?", variantID, quantity).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity - ?", quantity)).Error
}

func (r *productVariantRepository) IncrementStock(ctx context.Context, variantID string, quantity int64) error {
	return r.Pool().DB(ctx, false).
		Model(&models.ProductVariant{}).
		Where("id = ?", variantID).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity + ?", quantity)).Error
}
