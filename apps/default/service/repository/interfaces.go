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

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type ShopRepository interface {
	datastore.BaseRepository[*models.Shop]
	GetBySlug(ctx context.Context, slug string) (*models.Shop, error)
}

type ProductRepository interface {
	datastore.BaseRepository[*models.Product]
	ListByShopID(ctx context.Context, shopID string, limit, offset int) ([]*models.Product, error)
}

type ProductVariantRepository interface {
	datastore.BaseRepository[*models.ProductVariant]
	ListByProductID(ctx context.Context, productID string) ([]*models.ProductVariant, error)
	DecrementStock(ctx context.Context, variantID string, quantity int64) error
	IncrementStock(ctx context.Context, variantID string, quantity int64) error
}

type CartRepository interface {
	datastore.BaseRepository[*models.Cart]
	GetWithLines(ctx context.Context, id string) (*models.Cart, error)
}

type CartLineRepository interface {
	datastore.BaseRepository[*models.CartLine]
	GetByCartID(ctx context.Context, cartID string) ([]*models.CartLine, error)
	GetByCartAndVariant(ctx context.Context, cartID, variantID string) (*models.CartLine, error)
}

type OrderRepository interface {
	datastore.BaseRepository[*models.Order]
	GetWithLines(ctx context.Context, id string) (*models.Order, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Order, error)
	ListByShopID(ctx context.Context, shopID string, limit, offset int) ([]*models.Order, error)
}

type OrderLineRepository interface {
	datastore.BaseRepository[*models.OrderLine]
	GetByOrderID(ctx context.Context, orderID string) ([]*models.OrderLine, error)
}

type FulfilmentRepository interface {
	datastore.BaseRepository[*models.Fulfilment]
	GetWithLines(ctx context.Context, id string) (*models.Fulfilment, error)
	ListByOrderID(ctx context.Context, orderID string) ([]*models.Fulfilment, error)
}

type FulfilmentLineRepository interface {
	datastore.BaseRepository[*models.FulfilmentLine]
	GetByFulfilmentID(ctx context.Context, fulfilmentID string) ([]*models.FulfilmentLine, error)
	GetFulfilledQuantityByOrderLineID(ctx context.Context, orderLineID string) (int64, error)
}
