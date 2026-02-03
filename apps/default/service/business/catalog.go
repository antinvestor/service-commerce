package business

import (
	"context"
	"errors"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

type CatalogBusiness interface {
	CreateProduct(ctx context.Context, req *commercev1.CreateProductRequest) (*commercev1.Product, error)
	GetProduct(ctx context.Context, id string) (*commercev1.Product, error)
	ListProducts(ctx context.Context, req *commercev1.ListProductsRequest) ([]*commercev1.Product, error)
	CreateProductVariant(ctx context.Context, req *commercev1.CreateProductVariantRequest) (*commercev1.ProductVariant, error)
	UpdateProductVariant(ctx context.Context, req *commercev1.UpdateProductVariantRequest) (*commercev1.ProductVariant, error)
	ListProductVariants(ctx context.Context, productID string) ([]*commercev1.ProductVariant, error)
}

func NewCatalogBusiness(
	_ context.Context,
	productRepo repository.ProductRepository,
	variantRepo repository.ProductVariantRepository,
	shopRepo repository.ShopRepository,
) CatalogBusiness {
	return &catalogBusiness{
		productRepo: productRepo,
		variantRepo: variantRepo,
		shopRepo:    shopRepo,
	}
}

type catalogBusiness struct {
	productRepo repository.ProductRepository
	variantRepo repository.ProductVariantRepository
	shopRepo    repository.ShopRepository
}

func (cb *catalogBusiness) CreateProduct(ctx context.Context, req *commercev1.CreateProductRequest) (*commercev1.Product, error) {
	// Validate shop exists
	_, err := cb.shopRepo.GetByID(ctx, req.GetShopId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}

	product := &models.Product{
		ShopID:         req.GetShopId(),
		Name:           req.GetName(),
		Description:    req.GetDescription(),
		Attributes:     models.MapToJSONMap(req.GetAttributes()),
		FulfilmentType: 0,
		Status:         int32(commercev1.ProductStatus_PRODUCT_STATUS_ACTIVE),
		MediaIDs:       models.StringArray(req.GetMediaIds()),
	}

	if createErr := cb.productRepo.Create(ctx, product); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return product.ToAPI(), nil
}

func (cb *catalogBusiness) GetProduct(ctx context.Context, id string) (*commercev1.Product, error) {
	product, err := cb.productRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return product.ToAPI(), nil
}

func (cb *catalogBusiness) ListProducts(ctx context.Context, req *commercev1.ListProductsRequest) ([]*commercev1.Product, error) {
	limit := 50
	offset := 0
	if req.GetSearch() != nil && req.GetSearch().GetCursor() != nil {
		if req.GetSearch().GetCursor().GetLimit() > 0 {
			limit = int(req.GetSearch().GetCursor().GetLimit())
		}
	}

	products, err := cb.productRepo.ListByShopID(ctx, req.GetShopId(), limit, offset)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.Product, 0, len(products))
	for _, p := range products {
		result = append(result, p.ToAPI())
	}
	return result, nil
}

func (cb *catalogBusiness) CreateProductVariant(ctx context.Context, req *commercev1.CreateProductVariantRequest) (*commercev1.ProductVariant, error) {
	// Validate product exists
	_, err := cb.productRepo.GetByID(ctx, req.GetProductId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("product not found"))
	}

	currency, units, nanos := models.MoneyFromProto(req.GetPrice())

	variant := &models.ProductVariant{
		ProductID:     req.GetProductId(),
		SKU:           req.GetSku(),
		Name:          req.GetName(),
		CurrencyCode:  currency,
		PriceUnits:    units,
		PriceNanos:    nanos,
		StockQuantity: req.GetStockQuantity(),
		Attributes:    models.MapToJSONMap(req.GetAttributes()),
		MediaIDs:      models.StringArray(req.GetMediaIds()),
		Status:        int32(commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_ACTIVE),
	}

	if createErr := cb.variantRepo.Create(ctx, variant); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return variant.ToAPI(), nil
}

func (cb *catalogBusiness) ListProductVariants(ctx context.Context, productID string) ([]*commercev1.ProductVariant, error) {
	variants, err := cb.variantRepo.ListByProductID(ctx, productID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*commercev1.ProductVariant, 0, len(variants))
	for _, v := range variants {
		result = append(result, v.ToAPI())
	}
	return result, nil
}

func (cb *catalogBusiness) UpdateProductVariant(ctx context.Context, req *commercev1.UpdateProductVariantRequest) (*commercev1.ProductVariant, error) {
	variant, err := cb.variantRepo.GetByID(ctx, req.GetVariantId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	fields := req.GetUpdateMask().GetPaths()
	if len(fields) == 0 {
		fields = []string{"sku", "name", "price", "stock_quantity", "status", "attributes", "media_ids"}
	}

	updateColumns := make([]string, 0, len(fields))
	for _, field := range fields {
		switch field {
		case "sku":
			if req.GetSku() != "" {
				variant.SKU = req.GetSku()
				updateColumns = append(updateColumns, "sku")
			}
		case "name":
			if req.GetName() != "" {
				variant.Name = req.GetName()
				updateColumns = append(updateColumns, "name")
			}
		case "price":
			if req.GetPrice() != nil {
				currency, units, nanos := models.MoneyFromProto(req.GetPrice())
				variant.CurrencyCode = currency
				variant.PriceUnits = units
				variant.PriceNanos = nanos
				updateColumns = append(updateColumns, "currency_code", "price_units", "price_nanos")
			}
		case "stock_quantity":
			variant.StockQuantity = req.GetStockQuantity()
			updateColumns = append(updateColumns, "stock_quantity")
		case "status":
			if req.GetStatus() != commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_UNSPECIFIED {
				variant.Status = int32(req.GetStatus())
				updateColumns = append(updateColumns, "status")
			}
		case "attributes":
			variant.Attributes = models.MapToJSONMap(req.GetAttributes())
			updateColumns = append(updateColumns, "attributes")
		case "media_ids":
			variant.MediaIDs = models.StringArray(req.GetMediaIds())
			updateColumns = append(updateColumns, "media_ids")
		}
	}

	if len(updateColumns) > 0 {
		_, updateErr := cb.variantRepo.Update(ctx, variant, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	return variant.ToAPI(), nil
}
