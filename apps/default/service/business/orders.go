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

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
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
}

type OrderBusiness interface {
	CreateOrder(ctx context.Context, req *commercev1.CreateOrderRequest) (*commercev1.Order, error)
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
	policy        OrderPolicy
}

// CreateOrder is the back-office path: the shop records a sale it settles
// itself (cash, invoice), so the order starts confirmed.
func (ob *orderBusiness) CreateOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
) (*commercev1.Order, error) {
	return ob.createOrder(ctx, req, "", 0, false)
}

func (ob *orderBusiness) createOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
	convertCartID string,
	convertedCartStatus int32,
	awaitPayment bool,
) (*commercev1.Order, error) {
	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("order must have at least one line"))
	}

	requestHash := orderRequestHash(req)

	if existing, err := ob.replayedOrder(ctx, req.GetIdempotencyKey(), requestHash); err != nil {
		return nil, err
	} else if existing != nil {
		return existing, nil
	}

	shop, shopErr := ob.shopRepo.GetByID(ctx, req.GetShopId())
	if shopErr != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}
	if shop.Status != int32(commercev1.ShopStatus_SHOP_STATUS_ACTIVE) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("shop is not active"))
	}

	orderLines, subtotalCurrency, subtotalUnits, subtotalNanos, err := ob.buildOrderLines(
		ctx,
		req.GetShopId(),
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
	if awaitPayment {
		// Buyer orders hold stock only for the payment window; the
		// reconciler releases it afterwards.
		status = commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT
		due := time.Now().Add(ob.policy.PaymentWindow)
		paymentDue = &due
	}

	order := &models.Order{
		ShopID:           req.GetShopId(),
		IdempotencyKey:   idempotencyKey,
		RequestHash:      requestHash,
		Status:           int32(status),
		PaymentDueAt:     paymentDue,
		PaymentStatus:    int32(commercev1.PaymentStatus_PAYMENT_STATUS_PENDING),
		FulfilmentStatus: int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED),
		ProfileID:        req.GetProfileId(),
		ContactID:        req.GetContactId(),
		AddressID:        req.GetAddressId(),
		SubtotalCurrency: subtotalCurrency,
		SubtotalUnits:    subtotalUnits,
		SubtotalNanos:    subtotalNanos,
		TotalCurrency:    subtotalCurrency,
		TotalUnits:       subtotalUnits,
		TotalNanos:       subtotalNanos,
	}

	createErr := ob.orderRepo.CreateWithLinesAndStock(
		ctx, order, orderLines, convertCartID, convertedCartStatus,
	)
	if createErr != nil {
		return ob.mapCreateOrderError(ctx, req.GetIdempotencyKey(), createErr)
	}

	return ob.GetOrder(ctx, order.GetID())
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
			errors.New("idempotency key already used for a different order request"))
	}
	return existing.ToAPI(), nil
}

// mapCreateOrderError converts repository failures into API errors. A
// duplicate idempotency key means a concurrent retry committed first, so that
// order is returned instead of an error.
func (ob *orderBusiness) mapCreateOrderError(
	ctx context.Context,
	idempotencyKey string,
	createErr error,
) (*commercev1.Order, error) {
	if errors.Is(createErr, repository.ErrInsufficientStock) ||
		errors.Is(createErr, repository.ErrCartNotConvertible) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, createErr)
	}
	if idempotencyKey != "" && data.ErrorIsDuplicateKey(createErr) {
		if existing, getErr := ob.orderRepo.GetByIdempotencyKey(ctx, idempotencyKey); getErr == nil {
			return existing.ToAPI(), nil
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
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cart is not active"))
	}

	if len(cart.Lines) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("cart has no items"))
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

	return ob.createOrder(
		ctx,
		orderReq,
		cart.GetID(),
		int32(commercev1.CartStatus_CART_STATUS_CONVERTED),
		true,
	)
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
	orders, next, err := ob.orderRepo.ListByShopID(ctx, req.GetShopId(), page)
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
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("profile is required"))
	}
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	orders, next, err := ob.orderRepo.ListByProfileID(ctx, profileID, page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	// A shop filter narrows the buyer's history to that shop.
	if shopID := req.GetShopId(); shopID != "" {
		filtered := orders[:0]
		for _, o := range orders {
			if o.ShopID == shopID {
				filtered = append(filtered, o)
			}
		}
		orders = filtered
	}
	return toOrderPage(orders, next), nil
}

func toOrderPage(orders []*models.Order, next *repository.PageKey) *OrderPage {
	result := &OrderPage{Orders: make([]*commercev1.Order, 0, len(orders)), NextPage: nextCursor(next)}
	for _, o := range orders {
		result.Orders = append(result.Orders, o.ToAPI())
	}
	return result
}

const nanosPerUnit int64 = 1_000_000_000

func (ob *orderBusiness) buildOrderLines(
	ctx context.Context,
	shopID string,
	lines []*commercev1.CreateOrderLine,
) ([]*models.OrderLine, string, int64, int32, error) {
	var orderLines []*models.OrderLine
	var subtotalCurrency string
	var subtotalUnits int64
	var subtotalNanos int64

	for _, line := range lines {
		if line.GetQuantity() <= 0 {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("quantity must be positive for variant %s", line.GetVariantId()))
		}

		variant, err := ob.variantRepo.GetByID(ctx, line.GetVariantId())
		if err != nil {
			return nil, "", 0, 0, connect.NewError(connect.CodeNotFound,
				fmt.Errorf("variant %s not found", line.GetVariantId()))
		}
		if variant.Status != int32(commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_ACTIVE) {
			return nil, "", 0, 0, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("variant %s is not available for sale", line.GetVariantId()))
		}

		productShopID, productStatus, shopErr := ob.variantProduct(ctx, variant)
		if shopErr != nil {
			return nil, "", 0, 0, shopErr
		}
		if productShopID != shopID {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("variant %s does not belong to shop %s", line.GetVariantId(), shopID))
		}
		if productStatus != int32(commercev1.ProductStatus_PRODUCT_STATUS_ACTIVE) {
			return nil, "", 0, 0, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("product for variant %s is not available for sale", line.GetVariantId()))
		}

		if subtotalCurrency == "" {
			subtotalCurrency = variant.CurrencyCode
		} else if variant.CurrencyCode != subtotalCurrency {
			return nil, "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("variant %s is priced in %s but the order is in %s",
					line.GetVariantId(), variant.CurrencyCode, subtotalCurrency))
		}

		// Advisory stock check; CreateWithLinesAndStock re-checks under row update.
		if variant.StockQuantity < line.GetQuantity() {
			return nil, "", 0, 0, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("insufficient stock for variant %s: requested %d, available %d",
					line.GetVariantId(), line.GetQuantity(), variant.StockQuantity))
		}

		lineTotalNanos := int64(variant.PriceNanos) * line.GetQuantity()
		lineTotalUnits := variant.PriceUnits*line.GetQuantity() + lineTotalNanos/nanosPerUnit
		lineTotalNanos %= nanosPerUnit

		orderLines = append(orderLines, &models.OrderLine{
			ProductVariantID:   variant.GetID(),
			SKUSnapshot:        variant.SKU,
			NameSnapshot:       variant.Name,
			UnitPriceCurrency:  variant.CurrencyCode,
			UnitPriceUnits:     variant.PriceUnits,
			UnitPriceNanos:     variant.PriceNanos,
			Quantity:           line.GetQuantity(),
			TotalPriceCurrency: variant.CurrencyCode,
			TotalPriceUnits:    lineTotalUnits,
			TotalPriceNanos:    int32(lineTotalNanos),
		})

		subtotalUnits += lineTotalUnits
		subtotalNanos += lineTotalNanos
		subtotalUnits += subtotalNanos / nanosPerUnit
		subtotalNanos %= nanosPerUnit
	}

	return orderLines, subtotalCurrency, subtotalUnits, int32(subtotalNanos), nil
}

func (ob *orderBusiness) variantProduct(
	ctx context.Context,
	variant *models.ProductVariant,
) (string, int32, error) {
	if variant.Product != nil && variant.Product.ShopID != "" {
		return variant.Product.ShopID, variant.Product.Status, nil
	}

	product, err := ob.productRepo.GetByID(ctx, variant.ProductID)
	if err != nil {
		return "", 0, connect.NewError(connect.CodeNotFound,
			fmt.Errorf("product for variant %s not found", variant.GetID()))
	}
	return product.ShopID, product.Status, nil
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
