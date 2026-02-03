package business

import (
	"context"
	"errors"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

type CartBusiness interface {
	CreateCart(ctx context.Context, req *commercev1.CreateCartRequest) (*commercev1.Cart, error)
	GetCart(ctx context.Context, id string) (*commercev1.Cart, error)
	AddCartLine(ctx context.Context, req *commercev1.AddCartLineRequest) (*commercev1.Cart, error)
	RemoveCartLine(ctx context.Context, req *commercev1.RemoveCartLineRequest) (*commercev1.Cart, error)
}

func NewCartBusiness(
	_ context.Context,
	cartRepo repository.CartRepository,
	cartLineRepo repository.CartLineRepository,
	variantRepo repository.ProductVariantRepository,
) CartBusiness {
	return &cartBusiness{
		cartRepo:     cartRepo,
		cartLineRepo: cartLineRepo,
		variantRepo:  variantRepo,
	}
}

type cartBusiness struct {
	cartRepo     repository.CartRepository
	cartLineRepo repository.CartLineRepository
	variantRepo  repository.ProductVariantRepository
}

func (cb *cartBusiness) CreateCart(ctx context.Context, req *commercev1.CreateCartRequest) (*commercev1.Cart, error) {
	cart := &models.Cart{
		ShopID:    req.GetShopId(),
		Status:    int32(commercev1.CartStatus_CART_STATUS_ACTIVE),
		ProfileID: req.GetProfileId(),
		ContactID: req.GetContactId(),
	}

	if createErr := cb.cartRepo.Create(ctx, cart); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return cart.ToAPI(), nil
}

func (cb *cartBusiness) GetCart(ctx context.Context, id string) (*commercev1.Cart, error) {
	cart, err := cb.cartRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return cart.ToAPI(), nil
}

func (cb *cartBusiness) AddCartLine(ctx context.Context, req *commercev1.AddCartLineRequest) (*commercev1.Cart, error) {
	cart, err := cb.cartRepo.GetWithLines(ctx, req.GetCartId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if cart.Status != int32(commercev1.CartStatus_CART_STATUS_ACTIVE) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cart is not active"))
	}

	// Validate variant exists
	_, variantErr := cb.variantRepo.GetByID(ctx, req.GetProductVariantId())
	if variantErr != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("product variant not found"))
	}

	if req.GetQuantity() <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("quantity must be positive"))
	}

	// Check if line already exists for this variant
	existing, findErr := cb.cartLineRepo.GetByCartAndVariant(ctx, req.GetCartId(), req.GetProductVariantId())
	if findErr == nil && existing != nil {
		// Update existing line quantity
		existing.Quantity += req.GetQuantity()
		_, updateErr := cb.cartLineRepo.Update(ctx, existing, "quantity")
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	} else if findErr != nil && !frame.ErrorIsNotFound(findErr) {
		return nil, data.ErrorConvertToAPI(findErr)
	} else {
		// Create new line
		line := &models.CartLine{
			CartID:           req.GetCartId(),
			ProductVariantID: req.GetProductVariantId(),
			Quantity:         req.GetQuantity(),
		}
		if createErr := cb.cartLineRepo.Create(ctx, line); createErr != nil {
			return nil, data.ErrorConvertToAPI(createErr)
		}
	}

	return cb.GetCart(ctx, req.GetCartId())
}

func (cb *cartBusiness) RemoveCartLine(ctx context.Context, req *commercev1.RemoveCartLineRequest) (*commercev1.Cart, error) {
	cart, err := cb.cartRepo.GetWithLines(ctx, req.GetCartId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if cart.Status != int32(commercev1.CartStatus_CART_STATUS_ACTIVE) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cart is not active"))
	}

	if deleteErr := cb.cartLineRepo.Delete(ctx, req.GetCartLineId()); deleteErr != nil {
		return nil, data.ErrorConvertToAPI(deleteErr)
	}

	return cb.GetCart(ctx, req.GetCartId())
}
