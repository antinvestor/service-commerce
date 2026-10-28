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

package business

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// OrderPage is one page of orders plus the cursor for the next page.
type OrderPage struct {
	Orders   []*commercev1.Order
	NextPage string
}

// OrderPolicy carries the deployment knobs order creation depends on.
type OrderPolicy struct {
	// PaymentWindow is how long stock stays reserved for a buyer order that
	// has not been paid.
	PaymentWindow time.Duration
	// GuestUnitsCap bounds the units a shop's unpaid guest orders may hold
	// at once; 0 means no bound.
	GuestUnitsCap int64
}

// PriceResolver quotes the unit prices a customer pays for a shop's
// variants, after customer overrides, price lists and discounts, loading
// what pricing depends on once for all of them. PricingBusiness satisfies
// it.
type PriceResolver interface {
	QuotePrices(
		ctx context.Context,
		shopID, customerID string,
		queries []PriceQuery,
	) ([]*commercev1.ResolvedPrice, error)
}

type OrderBusiness interface {
	CreateOrder(ctx context.Context, req *commercev1.CreateOrderRequest) (*commercev1.Order, error)
	// CreateGuestOrder places an order for a buyer who has not signed in.
	// It must be paid before it is confirmed (stock is held only for the
	// payment window) and is priced at list prices: the buyer's identity is
	// only what they typed, so customer-specific prices do not apply.
	// deposit, when set, is what the buyer will pay first; it is checked
	// against the order's policy before anything is reserved.
	CreateGuestOrder(
		ctx context.Context,
		req *commercev1.CreateOrderRequest,
		deposit *commonv1.Money,
	) (*commercev1.Order, error)
	// CreateOrderFromCart converts an active cart into an order. The order is
	// placed for the cart's profile; the request profile is used only when the
	// cart has none.
	CreateOrderFromCart(ctx context.Context, req *commercev1.CreateOrderFromCartRequest) (*commercev1.Order, error)
	GetOrder(ctx context.Context, id string) (*commercev1.Order, error)
	ListOrders(ctx context.Context, req *commercev1.ListOrdersRequest) (*OrderPage, error)
	// ListOrdersForProfile pages a buyer's own orders across shops.
	ListOrdersForProfile(ctx context.Context, profileID string, req *commercev1.ListOrdersRequest) (*OrderPage, error)
}

func NewOrderBusiness(
	_ context.Context,
	orderRepo repository.OrderRepository,
	orderLineRepo repository.OrderLineRepository,
	variantRepo repository.ProductVariantRepository,
	productRepo repository.ProductRepository,
	shopRepo repository.ShopRepository,
	cartRepo repository.CartRepository,
	cartLineRepo repository.CartLineRepository,
	prices PriceResolver,
	policy OrderPolicy,
) OrderBusiness {
	if policy.PaymentWindow <= 0 {
		policy.PaymentWindow = defaultPaymentWindow
	}
	return &orderBusiness{
		orderRepo:     orderRepo,
		orderLineRepo: orderLineRepo,
		variantRepo:   variantRepo,
		productRepo:   productRepo,
		shopRepo:      shopRepo,
		cartRepo:      cartRepo,
		cartLineRepo:  cartLineRepo,
		prices:        prices,
		policy:        policy,
	}
}

type orderBusiness struct {
	orderRepo     repository.OrderRepository
	orderLineRepo repository.OrderLineRepository
	variantRepo   repository.ProductVariantRepository
	productRepo   repository.ProductRepository
	shopRepo      repository.ShopRepository
	cartRepo      repository.CartRepository
	cartLineRepo  repository.CartLineRepository
	prices        PriceResolver
	policy        OrderPolicy
}

// CreateOrder is the back-office path: the shop records a sale it settles
// itself (cash, invoice), so the order starts confirmed.
func (ob *orderBusiness) CreateOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
) (*commercev1.Order, error) {
	return ob.createOrder(ctx, req, orderPlacement{})
}

func (ob *orderBusiness) CreateGuestOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
	deposit *commonv1.Money,
) (*commercev1.Order, error) {
	return ob.createOrder(ctx, req, orderPlacement{awaitPayment: true, listPrices: true, guest: true, deposit: deposit})
}

// orderPlacement is how an order comes about.
type orderPlacement struct {
	// cartID is the cart the order converts, which is then set to
	// cartStatus.
	cartID     string
	cartStatus int32
	// awaitPayment holds the order pending payment instead of confirming it.
	awaitPayment bool
	// listPrices ignores prices specific to the order's profile.
	listPrices bool
	// guest marks a storefront order from a buyer who did not sign in;
	// deposit is the first payment they asked to make.
	guest   bool
	deposit *commonv1.Money
}

func (ob *orderBusiness) createOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
	placement orderPlacement,
) (*commercev1.Order, error) {
	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "order must have at least one line")
	}

	requestHash := orderRequestHash(req)

	if existing, err := ob.replayedOrder(ctx, req.GetIdempotencyKey(), requestHash); err != nil {
		return nil, err
	} else if existing != nil {
		return existing, nil
	}

	shop, shopErr := ob.shopRepo.GetByID(ctx, req.GetShopId())
	if shopErr != nil {
		return nil, connect.NewError(connect.CodeNotFound, "shop not found")
	}
	if shop.Status != int32(commercev1.ShopStatus_SHOP_STATUS_ACTIVE) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "shop is not active")
	}

	pricingCustomer := req.GetProfileId()
	if placement.listPrices {
		pricingCustomer = ""
	}
	orderLines, linePolicies, subtotalCurrency, subtotalUnits, subtotalNanos, err := ob.buildOrderLines(
		ctx,
		req.GetShopId(),
		pricingCustomer,
		req.GetLines(),
	)
	if err != nil {
		return nil, err
	}

	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		idempotencyKey = util.IDString()
	}

	status := commercev1.OrderStatus_ORDER_STATUS_CONFIRMED
	var paymentDue *time.Time
	if placement.awaitPayment {
		// Buyer orders hold stock only for the payment window; the
		// reconciler releases it afterwards.
		status = commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT
		due := time.Now().Add(ob.policy.PaymentWindow)
		paymentDue = &due
	}

	order := &models.Order{
		ShopID:           req.GetShopId(),
		PaymentPolicy:    orderPolicy(shop, linePolicies),
		IdempotencyKey:   idempotencyKey,
		RequestHash:      requestHash,
		Status:           int32(status),
		PaymentDueAt:     paymentDue,
		PaymentStatus:    int32(commercev1.PaymentStatus_PAYMENT_STATUS_PENDING),
		FulfilmentStatus: int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED),
		ProfileID:        req.GetProfileId(),
		ContactID:        req.GetContactId(),
		AddressID:        req.GetAddressId(),
		Guest:            placement.guest,
		SubtotalCurrency: subtotalCurrency,
		SubtotalUnits:    subtotalUnits,
		SubtotalNanos:    subtotalNanos,
		TotalCurrency:    subtotalCurrency,
		TotalUnits:       subtotalUnits,
		TotalNanos:       subtotalNanos,
	}

	// A deposit the order's policy refuses is reported before any stock is
	// held, so the buyer can correct it and send the same order again.
	if placement.deposit != nil {
		if _, depositErr := requestedInstalment(order, placement.deposit); depositErr != nil {
			return nil, depositRefused(depositErr)
		}
	}

	opts := repository.CreateOrderOptions{
		ConvertCartID:       placement.cartID,
		ConvertedCartStatus: placement.cartStatus,
	}
	if placement.guest {
		opts.GuestUnitsCap = ob.policy.GuestUnitsCap
	}
	createErr := ob.orderRepo.CreateWithLinesAndStock(ctx, order, orderLines, opts)
	if createErr != nil {
		return ob.mapCreateOrderError(ctx, req.GetIdempotencyKey(), requestHash, createErr)
	}

	return ob.GetOrder(ctx, order.GetID())
}

// ErrDepositRefused marks an error about the amount a buyer asked to pay
// now; its message is about that amount alone and fit to show them.
var ErrDepositRefused = errors.New("deposit refused")

func depositRefused(err error) error {
	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		return connectErr.WithCause(ErrDepositRefused)
	}
	return err
}

// replayedOrder returns the previously created order for an idempotency key.
// A reused key with different content is a client bug and is refused rather
// than silently returning an unrelated order.
func (ob *orderBusiness) replayedOrder(
	ctx context.Context,
	idempotencyKey, requestHash string,
) (*commercev1.Order, error) {
	if idempotencyKey == "" {
		return nil, nil //nolint:nilnil // no key means nothing to replay
	}
	existing, err := ob.orderRepo.GetByIdempotencyKey(ctx, idempotencyKey)
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return nil, nil //nolint:nilnil // first use of this key
		}
		return nil, data.ErrorConvertToAPI(err)
	}
	if existing.RequestHash != "" && existing.RequestHash != requestHash {
		return nil, connect.NewError(connect.CodeAlreadyExists,
			"idempotency key already used for a different order request")
	}
	return existing.ToAPI(), nil
}

// mapCreateOrderError converts repository failures into API errors. A
// duplicate idempotency key means a concurrent retry committed first: that
// order is returned when it is the same request, and refused like any
// other reuse of the key when it is not.
func (ob *orderBusiness) mapCreateOrderError(
	ctx context.Context,
	idempotencyKey, requestHash string,
	createErr error,
) (*commercev1.Order, error) {
	if errors.Is(createErr, repository.ErrInsufficientStock) ||
		errors.Is(createErr, repository.ErrCartNotConvertible) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, createErr.Error()).WithCause(createErr)
	}
	if errors.Is(createErr, repository.ErrGuestHoldLimit) {
		return nil, connect.NewError(connect.CodeResourceExhausted,
			"the shop has too many unpaid orders just now").WithCause(createErr)
	}
	if idempotencyKey != "" && data.ErrorIsDuplicateKey(createErr) {
		existing, err := ob.replayedOrder(ctx, idempotencyKey, requestHash)
		if err != nil {
			return nil, err
		}
		if existing != nil {
			return existing, nil
		}
	}
	return nil, data.ErrorConvertToAPI(createErr)
}

func (ob *orderBusiness) CreateOrderFromCart(
	ctx context.Context,
	req *commercev1.CreateOrderFromCartRequest,
) (*commercev1.Order, error) {
	cart, err := ob.cartRepo.GetWithLines(ctx, req.GetCartId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if cart.Status != int32(commercev1.CartStatus_CART_STATUS_ACTIVE) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "cart is not active")
	}

	if len(cart.Lines) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "cart has no items")
	}

	createLines := make([]*commercev1.CreateOrderLine, 0, len(cart.Lines))
	for _, cartLine := range cart.Lines {
		createLines = append(createLines, &commercev1.CreateOrderLine{
			VariantId: cartLine.ProductVariantID,
			Quantity:  cartLine.Quantity,
		})
	}

	profileID := cart.ProfileID
	if profileID == "" {
		profileID = req.GetProfileId()
	}
	contactID := cart.ContactID
	if contactID == "" {
		contactID = req.GetContactId()
	}

	orderReq := &commercev1.CreateOrderRequest{
		ShopId:    cart.ShopID,
		ProfileId: profileID,
		ContactId: contactID,
		AddressId: req.GetAddressId(),
		Lines:     createLines,
		// One cart converts to at most one order.
		IdempotencyKey: "cart:" + cart.GetID(),
	}

	return ob.createOrder(ctx, orderReq, orderPlacement{
		cartID:       cart.GetID(),
		cartStatus:   int32(commercev1.CartStatus_CART_STATUS_CONVERTED),
		awaitPayment: true,
	})
}

func (ob *orderBusiness) GetOrder(ctx context.Context, id string) (*commercev1.Order, error) {
	order, err := ob.orderRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return order.ToAPI(), nil
}

func (ob *orderBusiness) ListOrders(
	ctx context.Context,
	req *commercev1.ListOrdersRequest,
) (*OrderPage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	orders, next, err := ob.orderRepo.ListByShopID(ctx, req.GetShopId(), orderStatusFilter(req), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return toOrderPage(orders, next), nil
}

func (ob *orderBusiness) ListOrdersForProfile(
	ctx context.Context,
	profileID string,
	req *commercev1.ListOrdersRequest,
) (*OrderPage, error) {
	if profileID == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "profile is required")
	}
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	// A shop filter narrows the buyer's history to that shop, in the query
	// so every page is full.
	orders, next, err := ob.orderRepo.ListByProfileID(ctx, profileID, req.GetShopId(), orderStatusFilter(req), page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return toOrderPage(orders, next), nil
}

// orderStatusFilter reads the request's order and payment status filters.
func orderStatusFilter(req *commercev1.ListOrdersRequest) repository.OrderStatusFilter {
	filter := repository.OrderStatusFilter{}
	for _, s := range req.GetStatuses() {
		filter.Statuses = append(filter.Statuses, int32(s))
	}
	for _, s := range req.GetPaymentStatuses() {
		filter.PaymentStatuses = append(filter.PaymentStatuses, int32(s))
	}
	return filter
}

func toOrderPage(orders []*models.Order, next *repository.PageKey) *OrderPage {
	result := &OrderPage{Orders: make([]*commercev1.Order, 0, len(orders)), NextPage: nextCursor(next)}
	for _, o := range orders {
		result.Orders = append(result.Orders, o.ToAPI())
	}
	return result
}

const nanosPerUnit int64 = 1_000_000_000

// buildOrderLines prices lines for customerID and checks each can be sold.
// Variants (with their products) and pricing inputs are loaded once for the
// whole order.
func (ob *orderBusiness) buildOrderLines(
	ctx context.Context,
	shopID, customerID string,
	lines []*commercev1.CreateOrderLine,
) ([]*models.OrderLine, []*models.PaymentPolicy, string, int64, int32, error) {
	fail := func(err error) ([]*models.OrderLine, []*models.PaymentPolicy, string, int64, int32, error) {
		return nil, nil, "", 0, 0, err
	}

	variants, err := ob.lineVariants(ctx, lines)
	if err != nil {
		return fail(err)
	}

	queries := make([]PriceQuery, 0, len(lines))
	for _, line := range lines {
		query, lineErr := sellable(line, variants[line.GetVariantId()], shopID)
		if lineErr != nil {
			return fail(lineErr)
		}
		queries = append(queries, query)
	}

	var quoted []*commercev1.ResolvedPrice
	if ob.prices != nil {
		if quoted, err = ob.prices.QuotePrices(ctx, shopID, customerID, queries); err != nil {
			return fail(err)
		}
	}

	orderLines := make([]*models.OrderLine, 0, len(lines))
	policies := make([]*models.PaymentPolicy, 0, len(lines))
	var subtotalCurrency string
	var subtotalUnits, subtotalNanos int64
	for i, q := range queries {
		currency, unitUnits, unitNanos := q.Variant.CurrencyCode, q.Variant.PriceUnits, q.Variant.PriceNanos
		if i < len(quoted) {
			if price := quoted[i].GetUnitPrice(); price != nil && price.GetCurrencyCode() != "" {
				currency, unitUnits, unitNanos = price.GetCurrencyCode(), price.GetUnits(), price.GetNanos()
			}
		}
		if currency == "" {
			return fail(connect.NewError(connect.CodeFailedPrecondition,
				fmt.Sprintf("variant %s has no price", q.Variant.GetID())))
		}
		// Payment is taken to the cent.
		unitUnits, unitNanos = models.RoundToCents(unitUnits, unitNanos)

		if subtotalCurrency == "" {
			subtotalCurrency = currency
		} else if currency != subtotalCurrency {
			return fail(connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("variant %s is priced in %s but the order is in %s",
					q.Variant.GetID(), currency, subtotalCurrency)))
		}

		lineTotalNanos := int64(unitNanos) * q.Quantity
		lineTotalUnits := unitUnits*q.Quantity + lineTotalNanos/nanosPerUnit
		lineTotalNanos %= nanosPerUnit

		policies = append(policies, q.Product.PaymentPolicy)
		orderLines = append(orderLines, &models.OrderLine{
			ProductVariantID:   q.Variant.GetID(),
			SKUSnapshot:        q.Variant.SKU,
			NameSnapshot:       q.Variant.Name,
			UnitPriceCurrency:  currency,
			UnitPriceUnits:     unitUnits,
			UnitPriceNanos:     unitNanos,
			Quantity:           q.Quantity,
			TotalPriceCurrency: currency,
			TotalPriceUnits:    lineTotalUnits,
			TotalPriceNanos:    int32(lineTotalNanos),
		})

		subtotalUnits += lineTotalUnits
		subtotalNanos += lineTotalNanos
		subtotalUnits += subtotalNanos / nanosPerUnit
		subtotalNanos %= nanosPerUnit
	}

	return orderLines, policies, subtotalCurrency, subtotalUnits, int32(subtotalNanos), nil
}

// lineVariants loads every variant the lines name, with its product, in one
// round trip.
func (ob *orderBusiness) lineVariants(
	ctx context.Context,
	lines []*commercev1.CreateOrderLine,
) (map[string]*models.ProductVariant, error) {
	ids := make([]string, 0, len(lines))
	for _, line := range lines {
		ids = append(ids, line.GetVariantId())
	}
	loaded, err := ob.variantRepo.ListByIDs(ctx, ids)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	variants := make(map[string]*models.ProductVariant, len(loaded))
	for _, v := range loaded {
		variants[v.GetID()] = v
	}
	return variants, nil
}

// sellable checks that line can be sold by shopID and returns what to
// price it by.
func sellable(line *commercev1.CreateOrderLine, variant *models.ProductVariant, shopID string) (PriceQuery, error) {
	id := line.GetVariantId()
	switch {
	case line.GetQuantity() <= 0:
		return PriceQuery{}, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("quantity must be positive for variant %s", id))
	case variant == nil:
		return PriceQuery{}, connect.NewError(connect.CodeNotFound, fmt.Sprintf("variant %s not found", id))
	case variant.Status != int32(commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_ACTIVE):
		return PriceQuery{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Sprintf("variant %s is not available for sale", id))
	case variant.Product == nil:
		return PriceQuery{}, connect.NewError(connect.CodeNotFound, fmt.Sprintf("product for variant %s not found", id))
	case variant.Product.ShopID != shopID:
		return PriceQuery{}, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("variant %s does not belong to shop %s", id, shopID))
	case variant.Product.Status != int32(commercev1.ProductStatus_PRODUCT_STATUS_ACTIVE):
		return PriceQuery{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Sprintf("product for variant %s is not available for sale", id))
	case variant.StockQuantity < line.GetQuantity():
		// Advisory; CreateWithLinesAndStock re-checks under row update.
		return PriceQuery{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Sprintf("insufficient stock for variant %s: requested %d, available %d",
				id, line.GetQuantity(), variant.StockQuantity))
	}
	return PriceQuery{Variant: variant, Product: variant.Product, Quantity: line.GetQuantity()}, nil
}

// orderPolicy is the payment policy fixed on a new order: each line's
// product override, else the shop's, merged into the strictest.
func orderPolicy(shop *models.Shop, productPolicies []*models.PaymentPolicy) *models.PaymentPolicy {
	lines := make([]*models.PaymentPolicy, len(productPolicies))
	for i, p := range productPolicies {
		lines[i] = p
		if p == nil {
			lines[i] = shop.PaymentPolicy
		}
	}
	return mergePolicies(lines)
}

// orderRequestHash fingerprints the parts of a create request that define the
// order, independent of line ordering.
func orderRequestHash(req *commercev1.CreateOrderRequest) string {
	parts := make([]string, 0, len(req.GetLines()))
	for _, l := range req.GetLines() {
		parts = append(parts, fmt.Sprintf("%s:%d", l.GetVariantId(), l.GetQuantity()))
	}
	sort.Strings(parts)
	payload := strings.Join([]string{
		req.GetShopId(), req.GetProfileId(), req.GetContactId(), req.GetAddressId(),
		strings.Join(parts, ","),
	}, "|")
	sum := sha256.Sum256([]byte(payload))
	return hex.EncodeToString(sum[:])
}
