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
	// ListByProductIDs returns the variants of every product in productIDs.
	ListByProductIDs(ctx context.Context, productIDs []string) ([]*models.ProductVariant, error)
	// ListByIDs returns the variants with ids, each with its Product loaded.
	ListByIDs(ctx context.Context, ids []string) ([]*models.ProductVariant, error)
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

// CreateOrderOptions are what order creation does besides the order itself.
type CreateOrderOptions struct {
	// ConvertCartID is the cart the order converts, set to
	// ConvertedCartStatus in the same transaction.
	ConvertCartID       string
	ConvertedCartStatus int32
	// GuestUnitsCap bounds the units a shop's unpaid guest orders may hold
	// at once, this one included; 0 means no bound.
	GuestUnitsCap int64
}

type OrderRepository interface {
	datastore.BaseRepository[*models.Order]
	GetWithLines(ctx context.Context, id string) (*models.Order, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Order, error)
	ListByShopID(ctx context.Context, shopID string, page Page) ([]*models.Order, *PageKey, error)
	// ListByProfileID pages a buyer's orders, narrowed to one shop when
	// shopID is set.
	ListByProfileID(ctx context.Context, profileID, shopID string, page Page) ([]*models.Order, *PageKey, error)
	// CreateWithLinesAndStock allocates the order number, inserts the order and
	// lines, and decrements stock for each line inside a single transaction.
	// If opts.ConvertCartID is non-empty, marks that cart as converted in the
	// same transaction. Returns ErrInsufficientStock when any stock decrement
	// updates zero rows, ErrCartNotConvertible when the cart is not active and
	// ErrGuestHoldLimit when a guest order would pass opts.GuestUnitsCap.
	CreateWithLinesAndStock(
		ctx context.Context,
		order *models.Order,
		lines []*models.OrderLine,
		opts CreateOrderOptions,
	) error
	// UpdateStatus performs a compare-and-set status transition. Returns false
	// when the order was not in expectedStatus.
	UpdateStatus(ctx context.Context, orderID string, expectedStatus, newStatus, fulfilmentStatus int32) (bool, error)
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
	// ListAwaitingPayment returns orders that may still receive money:
	// unpaid orders, part-paid orders with an unapplied session issued since
	// window.SessionsSince, and orders cancelled since window.LateSince with
	// one, skipping orders under review or backed off past window.Now.
	ListAwaitingPayment(ctx context.Context, shopID string, window ReconcileWindow, limit int) ([]*models.Order, error)
	// HasReconcileWork reports, in one query, whether a reconcile run has
	// anything to do.
	HasReconcileWork(ctx context.Context, shopID string, window ReconcileWindow) (bool, error)
	// DeferReconcile backs an order off until next.
	DeferReconcile(ctx context.Context, orderID string, next time.Time) error
	// FlagPaymentReview takes an order out of the sweep for staff to settle.
	FlagPaymentReview(ctx context.Context, orderID, reason string) error
	// ListOverdue returns part-paid orders past their balance deadline that
	// have not been flagged overdue.
	ListOverdue(ctx context.Context, shopID string, now time.Time, limit int) ([]*models.Order, error)
	// MarkOverdue flags the order overdue once, recording events with it.
	MarkOverdue(ctx context.Context, orderID string, now time.Time, events []*models.OrderEvent) (bool, error)
	// Cancel cancels an order as decide plans it, returning stock and raising
	// any refund in one transaction; see CancelDecision. A nil plan means the
	// order was left as it was.
	Cancel(
		ctx context.Context,
		orderID string,
		cancelledAt time.Time,
		decide CancelDecision,
	) (*models.Order, *CancelPlan, error)
	// AttachPaymentSession records the session and makes it current while
	// the current one is still expectedRef, extending the payment window to
	// paymentDueAt when that is later. It reports false when another session
	// became current first.
	AttachPaymentSession(
		ctx context.Context,
		orderID, expectedRef, ref, checkoutURL string,
		amountNanos int64,
		paymentDueAt *time.Time,
	) (bool, error)
	// ListPaymentSessions returns every checkout session ever issued for the
	// order, oldest first.
	ListPaymentSessions(ctx context.Context, orderID string) ([]*models.OrderPaymentSession, error)
	// SetLedgerTransaction stamps the sale-side ledger transaction on orders.
	SetLedgerTransaction(ctx context.Context, orderIDs []string, transactionID string) error
	// ListOpenRefunds returns refunds not yet confirmed or failed.
	ListOpenRefunds(ctx context.Context, shopID string, limit int) ([]*models.OrderRefund, error)
	// ListRefunds returns an order's refunds.
	ListRefunds(ctx context.Context, orderID string) ([]*models.OrderRefund, error)
	// ClaimRefund claims a pending refund for sending; one caller wins.
	ClaimRefund(ctx context.Context, refundID string, at time.Time) (bool, error)
	// RetakeRefund takes over a stale claim the caller observed.
	RetakeRefund(ctx context.Context, refundID string, observed, at time.Time) (bool, error)
	// RecordRefundSent notes the payment holding a refund.
	RecordRefundSent(ctx context.Context, refundID, paymentID string) error
	// TouchRefund records a look that settled nothing.
	TouchRefund(ctx context.Context, refundID, lastError string) error
	// FailRefund records a refund the payment service gave up on.
	FailRefund(ctx context.Context, refundID, paymentID, reason string) error
	// ConfirmRefund records a confirmed refund on it and its order.
	ConfirmRefund(
		ctx context.Context,
		refundID string,
		confirmedAt time.Time,
		events func(order *models.Order, refund *models.OrderRefund) []*models.OrderEvent,
	) (*models.Order, []*models.OrderEvent, error)
	// ClaimLedgerItems fixes, and returns, what one end-of-day transaction
	// merges.
	ClaimLedgerItems(ctx context.Context, shopID string, to time.Time, transactionID string) (*LedgerItems, error)
}

type OrderEventRepository interface {
	datastore.BaseRepository[*models.OrderEvent]
	// List pages a shop's or an order's events oldest first.
	List(ctx context.Context, shopID, orderID string, page Page) ([]*models.OrderEvent, *PageKey, error)
	// ListDue returns events awaiting webhook delivery whose retry time has
	// come.
	ListDue(ctx context.Context, now time.Time, limit int) ([]*models.OrderEvent, error)
	// ClaimDelivery takes a due event for one attempt, counting it and
	// holding the event until leaseUntil; nil when not claimed.
	ClaimDelivery(ctx context.Context, eventID string, now, leaseUntil time.Time) (*models.OrderEvent, error)
	// RecordDelivery saves the outcome of a claimed attempt.
	RecordDelivery(ctx context.Context, event *models.OrderEvent) error
	// MarkNotRequired stops delivery for events whose shop has no webhook.
	MarkNotRequired(ctx context.Context, ids []string) error
}

type LedgerPostingRepository interface {
	datastore.BaseRepository[*models.LedgerPosting]
	GetByShopAndDay(ctx context.Context, shopID, tradingDay string) (*models.LedgerPosting, error)
	// ListFailedSince returns failed postings for trading days from
	// sinceDay on, optionally for one shop.
	ListFailedSince(ctx context.Context, shopID, sinceDay string, limit int) ([]*models.LedgerPosting, error)
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
	// ListActiveByIDs returns those of ids that are active lists of shopID.
	ListActiveByIDs(ctx context.Context, shopID string, ids []string) ([]*models.PriceList, error)
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
	// ListForVariants returns the entries of the given lists for the given
	// variants, narrowest band first (min_quantity descending, then id).
	ListForVariants(ctx context.Context, priceListIDs, variantIDs []string) ([]*models.PriceListEntry, error)
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
	// ListActiveForVariants returns customerID's active overrides on any of
	// variantIDs, oldest first.
	ListActiveForVariants(
		ctx context.Context, customerID string, variantIDs []string,
	) ([]*models.CustomerPriceOverride, error)
}

type DiscountRuleRepository interface {
	datastore.BaseRepository[*models.DiscountRule]
	ListByShopID(
		ctx context.Context, shopID string, page Page,
	) ([]*models.DiscountRule, *PageKey, error)
	ListActive(ctx context.Context, shopID string) ([]*models.DiscountRule, error)
}

// StockReceiptRepository adds received goods to variant stock once per
// reference.
type StockReceiptRepository interface {
	// Receive inserts receipt and raises its variant's stock by its quantity
	// in one transaction, the variant's tenancy copied onto the receipt. When
	// the reference was already received it changes nothing and returns that
	// earlier receipt with replayed true. It returns the stock after the
	// receipt either way.
	Receive(ctx context.Context, variant *models.ProductVariant, receipt *models.StockReceipt) (
		stock int64, existing *models.StockReceipt, replayed bool, err error)
}
