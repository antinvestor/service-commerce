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

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type SupplierRepository interface {
	datastore.BaseRepository[*models.Supplier]
	ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.Supplier, error)
	ListByType(ctx context.Context, supplierType int32, limit, offset int) ([]*models.Supplier, error)
}

type SupplierItemRepository interface {
	datastore.BaseRepository[*models.SupplierItem]
	ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.SupplierItem, error)
	ListByInventoryItemID(ctx context.Context, inventoryItemID string) ([]*models.SupplierItem, error)
	GetBySupplierAndItem(ctx context.Context, supplierID, inventoryItemID string) (*models.SupplierItem, error)
}

type PurchaseOrderRepository interface {
	datastore.BaseRepository[*models.PurchaseOrder]
	GetWithLines(ctx context.Context, id string) (*models.PurchaseOrder, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.PurchaseOrder, error)
	ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.PurchaseOrder, error)
	ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.PurchaseOrder, error)
	ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.PurchaseOrder, error)
}

type PurchaseOrderLineRepository interface {
	datastore.BaseRepository[*models.PurchaseOrderLine]
	ListByPurchaseOrderID(ctx context.Context, purchaseOrderID string) ([]*models.PurchaseOrderLine, error)
}

type GoodsReceiptRepository interface {
	datastore.BaseRepository[*models.GoodsReceipt]
	GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error)
	ListByPurchaseOrderID(ctx context.Context, purchaseOrderID string) ([]*models.GoodsReceipt, error)
	ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.GoodsReceipt, error)
}

type GoodsReceiptLineRepository interface {
	datastore.BaseRepository[*models.GoodsReceiptLine]
	ListByGoodsReceiptID(ctx context.Context, goodsReceiptID string) ([]*models.GoodsReceiptLine, error)
	ListByPurchaseOrderLineID(ctx context.Context, purchaseOrderLineID string) ([]*models.GoodsReceiptLine, error)
}
