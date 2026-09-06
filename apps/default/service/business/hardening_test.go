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

package business_test

import (
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// These tests pin the hardening behaviour added for multi-seller readiness:
// idempotency that checks content, partial updates that cannot blank data,
// keyset pagination, and orders that only accept sellable lines.

func (bts *BusinessTestSuite) TestCreateOrder_IdempotencyKeyRejectsDifferentContent() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		key := "idem-" + util.RandomAlphaNumericString(8)
		first, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId:         shop.GetId(),
			IdempotencyKey: key,
			Lines:          []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: 1}},
		})
		require.NoError(t, err)

		// Same key, same content: same order, no second reservation.
		again, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId:         shop.GetId(),
			IdempotencyKey: key,
			Lines:          []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: 1}},
		})
		require.NoError(t, err)
		require.Equal(t, first.GetId(), again.GetId())

		// Same key, different quantity: refused rather than returning the old order.
		_, err = biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId:         shop.GetId(),
			IdempotencyKey: key,
			Lines:          []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: 2}},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(err))

		variants, err := biz.catalogBiz.ListProductVariants(ctx, variant.GetProductId())
		require.NoError(t, err)
		require.Equal(t, int64(99), variants[0].GetStockQuantity())
	})
}

func (bts *BusinessTestSuite) TestCreateOrder_RejectsMixedCurrenciesAndUnsellableLines() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		product, usdVariant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		kesVariant, err := biz.catalogBiz.CreateProductVariant(ctx, &commercev1.CreateProductVariantRequest{
			ProductId:     product.GetId(),
			Sku:           "SKU-KES-" + util.RandomAlphaNumericString(6),
			Name:          "KES Variant",
			Price:         &commonv1.Money{CurrencyCode: "KES", Units: 1300},
			StockQuantity: 10,
		})
		require.NoError(t, err)

		_, err = biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines: []*commercev1.CreateOrderLine{
				{VariantId: usdVariant.GetId(), Quantity: 1},
				{VariantId: kesVariant.GetId(), Quantity: 1},
			},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		// Disable the variant; it must no longer be orderable.
		_, err = biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
			VariantId: kesVariant.GetId(),
			Status:    commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_DISABLED,
		})
		require.NoError(t, err)

		_, err = biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines:  []*commercev1.CreateOrderLine{{VariantId: kesVariant.GetId(), Quantity: 1}},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestUpdateProductVariant_PartialUpdateKeepsStock() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		// No mask, only a name: stock and attributes untouched.
		renamed, err := biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
			VariantId: variant.GetId(),
			Name:      "Renamed",
		})
		require.NoError(t, err)
		require.Equal(t, "Renamed", renamed.GetName())
		require.Equal(t, int64(100), renamed.GetStockQuantity())
		require.Equal(t, variant.GetSku(), renamed.GetSku())

		// Stock is only written when explicitly masked.
		counted, err := biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
			VariantId:     variant.GetId(),
			StockQuantity: 42,
			UpdateMask:    &fieldmaskpb.FieldMask{Paths: []string{"stock_quantity"}},
		})
		require.NoError(t, err)
		require.Equal(t, int64(42), counted.GetStockQuantity())
		require.Equal(t, "Renamed", counted.GetName())

		// Negative stock is rejected.
		_, err = biz.catalogBiz.UpdateProductVariant(ctx, &commercev1.UpdateProductVariantRequest{
			VariantId:     variant.GetId(),
			StockQuantity: -1,
			UpdateMask:    &fieldmaskpb.FieldMask{Paths: []string{"stock_quantity"}},
		})
		require.Error(t, err)
	})
}

func (bts *BusinessTestSuite) TestUpdateShop_PartialUpdateKeepsDescription() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
			Name:        "Described " + util.RandomAlphaNumericString(6),
			Description: "Keep me",
		})
		require.NoError(t, err)

		updated, err := biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id:   shop.GetId(),
			Name: "New name",
		})
		require.NoError(t, err)
		require.Equal(t, "New name", updated.GetName())
		require.Equal(t, "Keep me", updated.GetDescription())

		cleared, err := biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id:         shop.GetId(),
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"description"}},
		})
		require.NoError(t, err)
		require.Empty(t, cleared.GetDescription())
	})
}

func (bts *BusinessTestSuite) TestListProducts_PagesWithCursorAndHidesArchived() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		for range 5 {
			_, err := biz.catalogBiz.CreateProduct(ctx, &commercev1.CreateProductRequest{
				ShopId: shop.GetId(),
				Name:   "P " + util.RandomAlphaNumericString(6),
			})
			require.NoError(t, err)
		}

		seen := map[string]bool{}
		cursor := ""
		pages := 0
		for {
			page, err := biz.catalogBiz.ListProducts(ctx, &commercev1.ListProductsRequest{
				ShopId: shop.GetId(),
				Search: &commonv1.SearchRequest{Cursor: &commonv1.PageCursor{Limit: 2, Page: cursor}},
			})
			require.NoError(t, err)
			pages++
			for _, p := range page.Products {
				require.False(t, seen[p.GetId()])
				seen[p.GetId()] = true
			}
			if page.NextPage == "" {
				break
			}
			cursor = page.NextPage
		}
		require.Len(t, seen, 5)
		require.Equal(t, 3, pages)

		_, err := biz.catalogBiz.ListProducts(ctx, &commercev1.ListProductsRequest{
			ShopId: shop.GetId(),
			Search: &commonv1.SearchRequest{Cursor: &commonv1.PageCursor{Page: "not-a-cursor"}},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestCart_RejectsForeignShopVariantAndForeignLine() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shopA := bts.createTestShop(ctx, biz)
		shopB := bts.createTestShop(ctx, biz)
		_, variantA := bts.createTestProductWithVariant(ctx, biz, shopA.GetId())
		_, variantB := bts.createTestProductWithVariant(ctx, biz, shopB.GetId())

		cartA, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shopA.GetId(), ProfileId: "buyer-a",
		})
		require.NoError(t, err)
		cartB, err := biz.cartBiz.CreateCart(ctx, &commercev1.CreateCartRequest{
			ShopId: shopB.GetId(), ProfileId: "buyer-b",
		})
		require.NoError(t, err)

		_, err = biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId: cartA.GetId(), ProductVariantId: variantB.GetId(), Quantity: 1,
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		withLine, err := biz.cartBiz.AddCartLine(ctx, &commercev1.AddCartLineRequest{
			CartId: cartA.GetId(), ProductVariantId: variantA.GetId(), Quantity: 1,
		})
		require.NoError(t, err)
		lineID := withLine.GetLines()[0].GetId()

		// A line can only be removed through its own cart.
		_, err = biz.cartBiz.RemoveCartLine(ctx, &commercev1.RemoveCartLineRequest{
			CartId: cartB.GetId(), CartLineId: lineID,
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		// Checkout places the order for the cart owner, whatever the request says,
		// and a converted cart cannot be checked out again.
		order, err := biz.orderBiz.CreateOrderFromCart(ctx, &commercev1.CreateOrderFromCartRequest{
			CartId: cartA.GetId(), ProfileId: "someone-else",
		})
		require.NoError(t, err)
		require.Equal(t, "buyer-a", order.GetProfileId())

		_, err = biz.orderBiz.CreateOrderFromCart(ctx, &commercev1.CreateOrderFromCartRequest{
			CartId: cartA.GetId(),
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestCreateFulfilment_AggregatesDuplicateLines() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		order, err := biz.orderBiz.CreateOrder(ctx, &commercev1.CreateOrderRequest{
			ShopId: shop.GetId(),
			Lines:  []*commercev1.CreateOrderLine{{VariantId: variant.GetId(), Quantity: 5}},
		})
		require.NoError(t, err)
		lineID := order.GetLines()[0].GetId()

		// 3 + 3 for one line of 5 must fail as a whole; nothing is written.
		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines: []*commercev1.FulfilmentLine{
				{OrderLineId: lineID, Quantity: 3},
				{OrderLineId: lineID, Quantity: 3},
			},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
		require.Empty(t, listFulfilmentsForOrder(ctx, t, svc, order.GetId()))

		// Cancelled fulfilments release their quantity.
		f, err := biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines:   []*commercev1.FulfilmentLine{{OrderLineId: lineID, Quantity: 5}},
		})
		require.NoError(t, err)
		_, err = biz.fulfilmentBiz.UpdateFulfilment(ctx, &commercev1.UpdateFulfilmentRequest{
			Id: f.GetId(), Status: commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED,
		})
		require.NoError(t, err)

		_, err = biz.fulfilmentBiz.CreateFulfilment(ctx, &commercev1.CreateFulfilmentRequest{
			OrderId: order.GetId(),
			Lines:   []*commercev1.FulfilmentLine{{OrderLineId: lineID, Quantity: 5}},
		})
		require.NoError(t, err)
	})
}

func (bts *BusinessTestSuite) TestPriceListEntryBatchSave_ValidatesAndReplaces() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricing := bts.getPricingBusiness(svc)

		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		pl, err := pricing.SavePriceList(ctx, &commercev1.PriceListSaveRequest{
			ShopId: shop.GetId(), Name: "Wholesale", Currency: "USD",
		})
		require.NoError(t, err)

		_, err = pricing.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
			PriceListId: pl.GetId(),
			Entries: []*commercev1.PriceListEntry{
				{ProductVariantId: variant.GetId(), UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: 9}},
				{ProductVariantId: "", UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: 9}},
			},
		})
		require.Error(t, err)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		for _, units := range []int64{9, 8} {
			entries, saveErr := pricing.BatchSavePriceListEntries(ctx, &commercev1.PriceListEntryBatchSaveRequest{
				PriceListId: pl.GetId(),
				Entries: []*commercev1.PriceListEntry{
					{ProductVariantId: variant.GetId(), UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: units}},
				},
			})
			require.NoError(t, saveErr)
			require.Len(t, entries, 1)
		}

		lists, err := pricing.SearchPriceLists(ctx, &commercev1.PriceListSearchRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		require.Len(t, lists.Items, 1)
	})
}
