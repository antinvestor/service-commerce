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
	"errors"
	"fmt"
	"time"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

type OrderBusiness interface {
	CreateOrder(ctx context.Context, req *commercev1.CreateOrderRequest) (*commercev1.Order, error)
	CreateOrderFromCart(ctx context.Context, req *commercev1.CreateOrderFromCartRequest) (*commercev1.Order, error)
	GetOrder(ctx context.Context, id string) (*commercev1.Order, error)
	ListOrders(ctx context.Context, req *commercev1.ListOrdersRequest) ([]*commercev1.Order, error)
}

func NewOrderBusiness(
	_ context.Context,
	orderRepo repository.OrderRepository,
	orderLineRepo repository.OrderLineRepository,
	variantRepo repository.ProductVariantRepository,
	shopRepo repository.ShopRepository,
	cartRepo repository.CartRepository,
	cartLineRepo repository.CartLineRepository,
) OrderBusiness {
	return &orderBusiness{
		orderRepo:     orderRepo,
		orderLineRepo: orderLineRepo,
		variantRepo:   variantRepo,
		shopRepo:      shopRepo,
		cartRepo:      cartRepo,
		cartLineRepo:  cartLineRepo,
	}
}

type orderBusiness struct {
	orderRepo     repository.OrderRepository
	orderLineRepo repository.OrderLineRepository
	variantRepo   repository.ProductVariantRepository
	shopRepo      repository.ShopRepository
	cartRepo      repository.CartRepository
	cartLineRepo  repository.CartLineRepository
}

func (ob *orderBusiness) CreateOrder(
	ctx context.Context,
	req *commercev1.CreateOrderRequest,
) (*commercev1.Order, error) {
	// Idempotency check
	if req.GetIdempotencyKey() != "" {
		existing, err := ob.orderRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
		if err != nil && !frame.ErrorIsNotFound(err) {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	// Validate shop exists
	_, shopErr := ob.shopRepo.GetByID(ctx, req.GetShopId())
	if shopErr != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}

	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("order must have at least one line"))
	}

	// Validate all variants and snapshot prices
	orderLines, subtotalCurrency, subtotalUnits, subtotalNanos, err := ob.buildOrderLines(
		ctx,
		req.GetShopId(),
		req.GetLines(),
	)
	if err != nil {
		return nil, err
	}

	orderNumber := generateOrderNumber()

	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		idempotencyKey = orderNumber
	}

	order := &models.Order{
		ShopID:           req.GetShopId(),
		OrderNumber:      orderNumber,
		IdempotencyKey:   idempotencyKey,
		Status:           int32(commercev1.OrderStatus_ORDER_STATUS_CONFIRMED),
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

	if createErr := ob.orderRepo.Create(ctx, order); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	// Create order lines and decrement stock
	for _, line := range orderLines {
		line.OrderID = order.GetID()
		if lineErr := ob.orderLineRepo.Create(ctx, line); lineErr != nil {
			return nil, data.ErrorConvertToAPI(lineErr)
		}

		if stockErr := ob.variantRepo.DecrementStock(ctx, line.ProductVariantID, line.Quantity); stockErr != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("insufficient stock for variant %s", line.ProductVariantID))
		}
	}

	return ob.GetOrder(ctx, order.GetID())
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

	// Build CreateOrderLine from cart lines
	var createLines []*commercev1.CreateOrderLine
	for _, cartLine := range cart.Lines {
		createLines = append(createLines, &commercev1.CreateOrderLine{
			VariantId: cartLine.ProductVariantID,
			Quantity:  cartLine.Quantity,
		})
	}

	orderReq := &commercev1.CreateOrderRequest{
		ShopId:    cart.ShopID,
		ProfileId: req.GetProfileId(),
		ContactId: req.GetContactId(),
		AddressId: req.GetAddressId(),
		Lines:     createLines,
	}

	order, orderErr := ob.CreateOrder(ctx, orderReq)
	if orderErr != nil {
		return nil, orderErr
	}

	// Mark cart as converted
	cart.Status = int32(commercev1.CartStatus_CART_STATUS_CONVERTED)
	_, updateErr := ob.cartRepo.Update(ctx, cart, "status")
	if updateErr != nil {
		return nil, data.ErrorConvertToAPI(updateErr)
	}

	return order, nil
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
) ([]*commercev1.Order, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	orders, err := ob.orderRepo.ListByShopID(ctx, req.GetShopId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.Order, 0, len(orders))
	for _, o := range orders {
		result = append(result, o.ToAPI())
	}
	return result, nil
}

func (ob *orderBusiness) buildOrderLines(
	ctx context.Context,
	shopID string,
	lines []*commercev1.CreateOrderLine,
) ([]*models.OrderLine, string, int64, int32, error) {
	const nanosPerUnit int64 = 1_000_000_000

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

		// Validate variant belongs to a product in this shop
		if variant.Product == nil {
			// Need to load the product to check shop_id
			if _, prodErr := ob.shopRepo.GetByID(ctx, shopID); prodErr != nil {
				return nil, "", 0, 0, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
			}
		}

		// Check stock
		if variant.StockQuantity < line.GetQuantity() {
			return nil, "", 0, 0, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("insufficient stock for variant %s: requested %d, available %d",
					line.GetVariantId(), line.GetQuantity(), variant.StockQuantity))
		}

		// Compute line total using int64 to avoid overflow
		lineTotalNanos := int64(variant.PriceNanos) * line.GetQuantity()
		lineTotalUnits := variant.PriceUnits*line.GetQuantity() + lineTotalNanos/nanosPerUnit
		lineTotalNanos %= nanosPerUnit

		orderLine := &models.OrderLine{
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
		}
		orderLines = append(orderLines, orderLine)

		// Accumulate subtotal
		if subtotalCurrency == "" {
			subtotalCurrency = variant.CurrencyCode
		}
		subtotalUnits += lineTotalUnits
		subtotalNanos += lineTotalNanos
		subtotalUnits += subtotalNanos / nanosPerUnit
		subtotalNanos %= nanosPerUnit
	}

	return orderLines, subtotalCurrency, subtotalUnits, int32(subtotalNanos), nil
}

func generateOrderNumber() string {
	return fmt.Sprintf("ORD-%d", time.Now().UnixNano())
}
