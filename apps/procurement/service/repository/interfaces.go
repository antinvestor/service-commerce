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
	"time"

	"github.com/pitabwire/frame/v3/datastore"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

// SupplierFilter narrows a supplier search; zero fields do not filter.
type SupplierFilter struct {
	Status       int32
	SupplierType int32
}

type SupplierRepository interface {
	datastore.BaseRepository[*models.Supplier]
	ListPage(ctx context.Context, filter SupplierFilter, page Page) ([]*models.Supplier, *PageKey, error)
}

// SupplierItemFilter narrows a supplier item search; zero fields do not
// filter.
type SupplierItemFilter struct {
	SupplierID      string
	InventoryItemID string
}

type SupplierItemRepository interface {
	datastore.BaseRepository[*models.SupplierItem]
	ListPage(ctx context.Context, filter SupplierItemFilter, page Page) ([]*models.SupplierItem, *PageKey, error)
	// ListActiveForInventoryItems returns the active items of active
	// suppliers that supply any of inventoryItemIDs, each with its supplier,
	// in one query.
	ListActiveForInventoryItems(ctx context.Context, inventoryItemIDs []string) ([]*models.SupplierItem, error)
}

// PurchaseOrderFilter narrows a purchase order search; zero fields do not
// filter.
type PurchaseOrderFilter struct {
	PropertyID string
	SupplierID string
	Status     int32
}

type PurchaseOrderRepository interface {
	datastore.BaseRepository[*models.PurchaseOrder]
	// GetWithLines reads from the primary, so a read after a write sees it.
	GetWithLines(ctx context.Context, id string) (*models.PurchaseOrder, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.PurchaseOrder, error)
	ListPage(ctx context.Context, filter PurchaseOrderFilter, page Page) ([]*models.PurchaseOrder, *PageKey, error)
	// CreateWithLines inserts the order and its lines in one transaction.
	CreateWithLines(ctx context.Context, po *models.PurchaseOrder, lines []*models.PurchaseOrderLine) error
	// Transition is a compare-and-set status change with optional extra
	// columns and an optional line status applied in the same transaction.
	Transition(
		ctx context.Context,
		poID string,
		expectedStatus, newStatus int32,
		columns map[string]any,
		lineStatus int32,
	) error
	// CloseShort closes a partially received order: the order becomes
	// CLOSED and every line not fully received becomes CLOSED, so no receipt
	// is accepted any more. ErrPurchaseOrderStateChanged when the order is
	// not partially received.
	CloseShort(ctx context.Context, poID string) error
}

type PurchaseOrderLineRepository interface {
	datastore.BaseRepository[*models.PurchaseOrderLine]
	ListByPurchaseOrderID(ctx context.Context, purchaseOrderID string) ([]*models.PurchaseOrderLine, error)
}

// GoodsReceiptFilter narrows a goods receipt search; zero fields do not
// filter.
type GoodsReceiptFilter struct {
	PurchaseOrderID string
	PropertyID      string
	Status          int32
}

type GoodsReceiptRepository interface {
	datastore.BaseRepository[*models.GoodsReceipt]
	// GetWithLines reads from the primary, so a read after a write sees it.
	GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error)
	ListPage(ctx context.Context, filter GoodsReceiptFilter, page Page) ([]*models.GoodsReceipt, *PageKey, error)
	// CreateWithLines records the receipt, its lines (with their delivery
	// state), the purchase order line quantities and the order status
	// roll-up atomically, under the order's row lock. It returns
	// ErrNotReceivable when the order is not submitted, confirmed or
	// partially received, and ErrOverReceipt when a line would exceed its
	// ordered quantity.
	CreateWithLines(ctx context.Context, gr *models.GoodsReceipt, lines []*models.GoodsReceiptLine) error
}

type GoodsReceiptLineRepository interface {
	datastore.BaseRepository[*models.GoodsReceiptLine]
	ListByGoodsReceiptID(ctx context.Context, goodsReceiptID string) ([]*models.GoodsReceiptLine, error)
	// ListPendingDelivery returns up to limit lines whose stock is still to
	// be pushed, least-tried and oldest first.
	ListPendingDelivery(ctx context.Context, limit int) ([]*models.GoodsReceiptLine, error)
	// SettleDelivery moves a pending line to status (delivered or failed)
	// with note. It reports false when the line was no longer pending.
	SettleDelivery(ctx context.Context, lineID string, status int32, note string, at time.Time) (bool, error)
	// RecordDeliveryAttempt counts a failed attempt that may succeed later.
	RecordDeliveryAttempt(ctx context.Context, lineID, note string) error
	// GetInReceipt reads a line of a receipt from the primary.
	GetInReceipt(ctx context.Context, goodsReceiptID, lineID string) (*models.GoodsReceiptLine, error)
	// Resolve marks a line booked by hand (RESOLVED) with who, when and the
	// note, provided its delivery status is still one of from. It reports
	// false when the line had moved on.
	Resolve(ctx context.Context, lineID string, from []int32, by, note string, at time.Time) (bool, error)
	// Requeue puts a FAILED line back to PENDING with note. It reports false
	// when the line was no longer FAILED.
	Requeue(ctx context.Context, lineID, note string) (bool, error)
}
