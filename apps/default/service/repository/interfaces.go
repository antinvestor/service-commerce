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

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type ShopRepository interface {
	datastore.BaseRepository[*models.Shop]
	GetBySlug(ctx context.Context, slug string) (*models.Shop, error)
	// List pages every shop visible in the caller's partition.
	List(ctx context.Context, page Page) ([]*models.Shop, *PageKey, error)
}

type ProductRepository interface {
	datastore.BaseRepository[*models.Product]
	// ListByShopID pages a shop's products newest-first, optionally filtered
	// to the given statuses.
	ListByShopID(ctx context.Context, shopID string, statuses []int32, page Page) ([]*models.Product, *PageKey, error)
}

type ProductVariantRepository interface {
	datastore.BaseRepository[*models.ProductVariant]
	ListByProductID(ctx context.Context, productID string) ([]*models.ProductVariant, error)
	// SetStock is an explicit absolute stock take; never used by order flow.
	SetStock(ctx context.Context, variantID string, quantity int64) error
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
	ListByShopID(ctx context.Context, shopID string, page Page) ([]*models.Order, *PageKey, error)
	ListByProfileID(ctx context.Context, profileID string, page Page) ([]*models.Order, *PageKey, error)
	// CreateWithLinesAndStock allocates the order number, inserts the order and
	// lines, and decrements stock for each line inside a single transaction.
	// If convertCartID is non-empty, marks that cart as converted in the same
	// transaction. Returns ErrInsufficientStock when any stock decrement
	// updates zero rows and ErrCartNotConvertible when the cart is not active.
	CreateWithLinesAndStock(
		ctx context.Context,
		order *models.Order,
		lines []*models.OrderLine,
		convertCartID string,
		convertedCartStatus int32,
	) error
	// UpdateStatus performs a compare-and-set status transition. Returns false
	// when the order was not in expectedStatus.
	UpdateStatus(ctx context.Context, orderID string, expectedStatus, newStatus, fulfilmentStatus int32) (bool, error)
	// ListPaidBetween returns orders whose paid_at falls in [from, to) whose
	// sale has not yet been merged into a ledger transaction. Refunded
	// orders are included: their sale still happened on the day they paid.
	ListPaidBetween(ctx context.Context, shopID string, from, to time.Time) ([]*models.Order, error)
	// ListRefundedBetween returns orders refunded in [from, to) whose refund
	// has not yet been merged into a ledger transaction.
	ListRefundedBetween(ctx context.Context, shopID string, from, to time.Time) ([]*models.Order, error)
	// ApplyPayment records payment against the order and applies transition
	// under a row lock, with the events it returns, in one transaction. A
	// payment whose reference is already recorded on the order is ignored
	// (applied=false).
	ApplyPayment(
		ctx context.Context,
		orderID string,
		payment *models.OrderPayment,
		transition PaymentTransition,
	) (order *models.Order, events []*models.OrderEvent, applied bool, err error)
	// ListAwaitingPayment returns orders that may still receive money: unpaid
	// orders inside or past their window, and part-paid orders with a
	// checkout session issued since sessionsSince that has not been applied.
	ListAwaitingPayment(ctx context.Context, shopID string, sessionsSince time.Time, limit int) ([]*models.Order, error)
	// ListOverdue returns part-paid orders past their balance deadline that
	// have not been flagged overdue.
	ListOverdue(ctx context.Context, shopID string, now time.Time, limit int) ([]*models.Order, error)
	// MarkOverdue flags the order overdue once, recording events with it.
	MarkOverdue(ctx context.Context, orderID string, now time.Time, events []*models.OrderEvent) (bool, error)
	// ListPaymentsBetween returns instalments paid in [from, to) not yet
	// merged into a ledger transaction.
	ListPaymentsBetween(ctx context.Context, shopID string, from, to time.Time) ([]*models.OrderPayment, error)
	// SetPaymentLedgerTransaction stamps instalments with their ledger
	// transaction.
	SetPaymentLedgerTransaction(ctx context.Context, paymentIDs []string, transactionID string) error
	// CancelAndRestock cancels an order and returns every line's quantity to
	// stock in one transaction. Only orders in one of allowedStatuses
	// transition; returns false otherwise.
	CancelAndRestock(
		ctx context.Context,
		orderID string,
		allowedStatuses []int32,
		paymentStatus int32,
		reason string,
		cancelledAt time.Time,
		events []*models.OrderEvent,
	) (bool, error)
	// AttachPaymentSession makes ref the order's current checkout session and
	// records it, with the amount it charges, in the order's session
	// history, atomically.
	AttachPaymentSession(ctx context.Context, orderID, ref, checkoutURL string, amountNanos int64) error
	// ListPaymentSessions returns every checkout session ever issued for the
	// order, oldest first.
	ListPaymentSessions(ctx context.Context, orderID string) ([]*models.OrderPaymentSession, error)
	// SetLedgerTransaction stamps the sale-side ledger transaction on orders.
	SetLedgerTransaction(ctx context.Context, orderIDs []string, transactionID string) error
	// SetRefundLedgerTransaction stamps the refund-side ledger transaction.
	SetRefundLedgerTransaction(ctx context.Context, orderIDs []string, transactionID string) error
}

type OrderEventRepository interface {
	datastore.BaseRepository[*models.OrderEvent]
	// List pages a shop's or an order's events oldest first.
	List(ctx context.Context, shopID, orderID string, page Page) ([]*models.OrderEvent, *PageKey, error)
	// ListDue returns events awaiting webhook delivery whose retry time has
	// come.
	ListDue(ctx context.Context, now time.Time, limit int) ([]*models.OrderEvent, error)
	// RecordDelivery saves the outcome of a delivery attempt.
	RecordDelivery(ctx context.Context, event *models.OrderEvent) error
	// MarkNotRequired stops delivery for events whose shop has no webhook.
	MarkNotRequired(ctx context.Context, ids []string) error
}

type LedgerPostingRepository interface {
	datastore.BaseRepository[*models.LedgerPosting]
	GetByShopAndDay(ctx context.Context, shopID, tradingDay string) (*models.LedgerPosting, error)
}

type OrderLineRepository interface {
	datastore.BaseRepository[*models.OrderLine]
	GetByOrderID(ctx context.Context, orderID string) ([]*models.OrderLine, error)
}

type FulfilmentRepository interface {
	datastore.BaseRepository[*models.Fulfilment]
	GetWithLines(ctx context.Context, id string) (*models.Fulfilment, error)
	ListByOrderID(ctx context.Context, orderID string) ([]*models.Fulfilment, error)
	// CreateWithLines inserts the fulfilment and its lines in one transaction.
	CreateWithLines(ctx context.Context, fulfilment *models.Fulfilment, lines []*models.FulfilmentLine) error
}

type FulfilmentLineRepository interface {
	datastore.BaseRepository[*models.FulfilmentLine]
	GetByFulfilmentID(ctx context.Context, fulfilmentID string) ([]*models.FulfilmentLine, error)
	GetFulfilledQuantityByOrderLineID(ctx context.Context, orderLineID string) (int64, error)
	// SumFulfilledByOrderID returns fulfilled quantity keyed by order line id,
	// ignoring cancelled fulfilments.
	SumFulfilledByOrderID(ctx context.Context, orderID string) (map[string]int64, error)
}

type PriceListRepository interface {
	datastore.BaseRepository[*models.PriceList]
	ListByShopID(
		ctx context.Context, shopID string, page Page,
	) ([]*models.PriceList, *PageKey, error)
	ListActive(ctx context.Context, shopID string) ([]*models.PriceList, error)
}

type PriceListEntryRepository interface {
	datastore.BaseRepository[*models.PriceListEntry]
	ListByPriceListID(
		ctx context.Context, priceListID string,
	) ([]*models.PriceListEntry, error)
	DeleteByPriceListAndVariant(
		ctx context.Context, priceListID, variantID string,
	) error
	// ReplaceEntries atomically replaces entries for the variants present in
	// entries.
	ReplaceEntries(ctx context.Context, priceListID string, entries []*models.PriceListEntry) error
	GetByPriceListAndVariant(
		ctx context.Context, priceListID, variantID string,
	) ([]*models.PriceListEntry, error)
}

type CustomerPriceListAssignmentRepository interface {
	datastore.BaseRepository[*models.CustomerPriceListAssignment]
	ListByCustomerID(
		ctx context.Context, customerID string, page Page,
	) ([]*models.CustomerPriceListAssignment, *PageKey, error)
	GetByCustomerAndPriceList(
		ctx context.Context, customerID, priceListID string,
	) (*models.CustomerPriceListAssignment, error)
}

type CustomerPriceOverrideRepository interface {
	datastore.BaseRepository[*models.CustomerPriceOverride]
	ListByCustomerID(
		ctx context.Context, customerID string, page Page,
	) ([]*models.CustomerPriceOverride, *PageKey, error)
	GetByCustomerAndVariant(
		ctx context.Context, customerID, variantID string,
	) (*models.CustomerPriceOverride, error)
}

type DiscountRuleRepository interface {
	datastore.BaseRepository[*models.DiscountRule]
	ListByShopID(
		ctx context.Context, shopID string, page Page,
	) ([]*models.DiscountRule, *PageKey, error)
	ListActive(ctx context.Context, shopID string) ([]*models.DiscountRule, error)
}
