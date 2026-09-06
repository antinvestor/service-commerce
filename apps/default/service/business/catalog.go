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
	"strings"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// ProductPage is one page of products plus the cursor for the next page.
type ProductPage struct {
	Products []*commercev1.Product
	NextPage string
}

type CatalogBusiness interface {
	CreateProduct(ctx context.Context, req *commercev1.CreateProductRequest) (*commercev1.Product, error)
	GetProduct(ctx context.Context, id string) (*commercev1.Product, error)
	// ListProducts pages products for a shop. Archived products are excluded
	// unless the search query is "status:archived"; "status:active" limits to
	// active products only.
	ListProducts(ctx context.Context, req *commercev1.ListProductsRequest) (*ProductPage, error)
	CreateProductVariant(
		ctx context.Context,
		req *commercev1.CreateProductVariantRequest,
	) (*commercev1.ProductVariant, error)
	UpdateProductVariant(
		ctx context.Context,
		req *commercev1.UpdateProductVariantRequest,
	) (*commercev1.ProductVariant, error)
	ListProductVariants(ctx context.Context, productID string) ([]*commercev1.ProductVariant, error)
	// GetShopIDForVariant resolves the owning shop of a variant.
	GetShopIDForVariant(ctx context.Context, variantID string) (string, error)
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

func (cb *catalogBusiness) CreateProduct(
	ctx context.Context,
	req *commercev1.CreateProductRequest,
) (*commercev1.Product, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("product name is required"))
	}

	if _, err := cb.shopRepo.GetByID(ctx, req.GetShopId()); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("shop not found"))
	}

	product := &models.Product{
		ShopID:         req.GetShopId(),
		Name:           name,
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

// Status filter keywords accepted in ListProductsRequest.search.query.
const (
	queryStatusActive   = "status:active"
	queryStatusArchived = "status:archived"
	queryStatusAll      = "status:all"
)

func (cb *catalogBusiness) ListProducts(
	ctx context.Context,
	req *commercev1.ListProductsRequest,
) (*ProductPage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}

	var statuses []int32
	switch strings.ToLower(strings.TrimSpace(req.GetSearch().GetQuery())) {
	case queryStatusActive:
		statuses = []int32{int32(commercev1.ProductStatus_PRODUCT_STATUS_ACTIVE)}
	case queryStatusArchived:
		statuses = []int32{int32(commercev1.ProductStatus_PRODUCT_STATUS_ARCHIVED)}
	case queryStatusAll:
		statuses = nil
	default:
		statuses = []int32{
			int32(commercev1.ProductStatus_PRODUCT_STATUS_ACTIVE),
			int32(commercev1.ProductStatus_PRODUCT_STATUS_INACTIVE),
		}
	}

	products, next, err := cb.productRepo.ListByShopID(ctx, req.GetShopId(), statuses, page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := &ProductPage{Products: make([]*commercev1.Product, 0, len(products)), NextPage: nextCursor(next)}
	for _, p := range products {
		result.Products = append(result.Products, p.ToAPI())
	}
	return result, nil
}

func (cb *catalogBusiness) CreateProductVariant(
	ctx context.Context,
	req *commercev1.CreateProductVariantRequest,
) (*commercev1.ProductVariant, error) {
	if _, err := cb.productRepo.GetByID(ctx, req.GetProductId()); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("product not found"))
	}
	if strings.TrimSpace(req.GetSku()) == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("sku is required"))
	}
	if req.GetStockQuantity() < 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("stock quantity must not be negative"))
	}

	currency, units, nanos := models.MoneyFromProto(req.GetPrice())
	if currency == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("price with currency is required"))
	}

	variant := &models.ProductVariant{
		ProductID:     req.GetProductId(),
		SKU:           strings.TrimSpace(req.GetSku()),
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

func (cb *catalogBusiness) ListProductVariants(
	ctx context.Context,
	productID string,
) ([]*commercev1.ProductVariant, error) {
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

func (cb *catalogBusiness) GetShopIDForVariant(ctx context.Context, variantID string) (string, error) {
	variant, err := cb.variantRepo.GetByID(ctx, variantID)
	if err != nil {
		return "", connect.NewError(connect.CodeNotFound, errors.New("product variant not found"))
	}
	if variant.Product != nil && variant.Product.ShopID != "" {
		return variant.Product.ShopID, nil
	}
	product, err := cb.productRepo.GetByID(ctx, variant.ProductID)
	if err != nil {
		return "", connect.NewError(connect.CodeNotFound, errors.New("product for variant not found"))
	}
	return product.ShopID, nil
}

// UpdateProductVariant applies only the fields the caller asked for. Without an
// update mask, a field is applied only when the request carries a non-zero
// value, so a partial request can never blank a field. Stock is the exception:
// it is only ever written when "stock_quantity" is explicitly masked, because
// an absolute stock write races with order reservations.
func (cb *catalogBusiness) UpdateProductVariant(
	ctx context.Context,
	req *commercev1.UpdateProductVariantRequest,
) (*commercev1.ProductVariant, error) {
	variant, err := cb.variantRepo.GetByID(ctx, req.GetVariantId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns, setStock, applyErr := applyVariantFields(variant, req)
	if applyErr != nil {
		return nil, applyErr
	}

	if len(updateColumns) > 0 {
		if _, updateErr := cb.variantRepo.Update(ctx, variant, updateColumns...); updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	if setStock {
		if stockErr := cb.variantRepo.SetStock(ctx, variant.GetID(), req.GetStockQuantity()); stockErr != nil {
			return nil, data.ErrorConvertToAPI(stockErr)
		}
		variant.StockQuantity = req.GetStockQuantity()
	}

	return variant.ToAPI(), nil
}

// applyVariantFields copies requested fields onto the variant. It returns the
// columns to persist and whether an explicit stock write was requested.
func applyVariantFields(
	variant *models.ProductVariant,
	req *commercev1.UpdateProductVariantRequest,
) ([]string, bool, error) {
	fields := req.GetUpdateMask().GetPaths()
	explicitMask := len(fields) > 0
	if !explicitMask {
		fields = []string{fieldSKU, fieldName, "price", fieldStatus, fieldAttributes, fieldMediaIDs}
	}

	setStock := false
	updateColumns := make([]string, 0, len(fields)+2) //nolint:mnd // price expands to three columns
	for _, field := range fields {
		if field == "stock_quantity" {
			if !explicitMask {
				continue
			}
			if req.GetStockQuantity() < 0 {
				return nil, false, connect.NewError(connect.CodeInvalidArgument,
					errors.New("stock quantity must not be negative"))
			}
			setStock = true
			continue
		}
		columns, err := applyVariantField(variant, req, field, explicitMask)
		if err != nil {
			return nil, false, err
		}
		updateColumns = append(updateColumns, columns...)
	}
	return updateColumns, setStock, nil
}

func applyVariantField(
	variant *models.ProductVariant,
	req *commercev1.UpdateProductVariantRequest,
	field string,
	explicitMask bool,
) ([]string, error) {
	switch field {
	case fieldSKU:
		if sku := strings.TrimSpace(req.GetSku()); sku != "" {
			variant.SKU = sku
			return []string{fieldSKU}, nil
		}
	case fieldName:
		if req.GetName() != "" {
			variant.Name = req.GetName()
			return []string{fieldName}, nil
		}
	case "price":
		if req.GetPrice() == nil {
			return nil, nil
		}
		currency, units, nanos := models.MoneyFromProto(req.GetPrice())
		if currency == "" {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("price currency is required"))
		}
		variant.CurrencyCode = currency
		variant.PriceUnits = units
		variant.PriceNanos = nanos
		return []string{"currency_code", "price_units", "price_nanos"}, nil
	case fieldStatus:
		if req.GetStatus() != commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_UNSPECIFIED {
			variant.Status = int32(req.GetStatus())
			return []string{fieldStatus}, nil
		}
	case fieldAttributes:
		if explicitMask || len(req.GetAttributes()) > 0 {
			variant.Attributes = models.MapToJSONMap(req.GetAttributes())
			return []string{fieldAttributes}, nil
		}
	case fieldMediaIDs:
		if explicitMask || len(req.GetMediaIds()) > 0 {
			variant.MediaIDs = models.StringArray(req.GetMediaIds())
			return []string{fieldMediaIDs}, nil
		}
	}
	return nil, nil
}
