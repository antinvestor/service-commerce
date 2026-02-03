package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)

	return dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.Shop{},
		&models.Product{}, &models.ProductVariant{},
		&models.Cart{}, &models.CartLine{},
		&models.Order{}, &models.OrderLine{},
		&models.Fulfilment{}, &models.FulfilmentLine{},
	)
}
