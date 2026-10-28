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

package handlers_test

import (
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-commerce/apps/default/service/handlers"
	"github.com/antinvestor/service-commerce/apps/default/tests"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

type BuyerAccessSuite struct {
	tests.CommerceBaseTestSuite
}

func TestBuyerAccessSuite(t *testing.T) {
	suite.Run(t, new(BuyerAccessSuite))
}

// A partition's buyer, checked against the shipped OPL in a real Keto, reads
// their own orders and no one else's: another buyer's order looks missing,
// listing a shop's orders falls back to their own, and the shop's negotiated
// prices stay closed.
func (s *BuyerAccessSuite) TestBuyerSeesOnlyOwnOrders() {
	t := s.T()

	s.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)
		server := handlers.NewCommerceServer(ctx, svc, s.AuthzMiddleware, handlers.Dependencies{})

		tenantID, partitionID := "tenant-"+util.RandomAlphaNumericString(6), "partition-1"
		owner := s.WithAuthClaims(ctx, tenantID, partitionID, "owner-"+util.RandomAlphaNumericString(6))
		buyerID := "buyer-" + util.RandomAlphaNumericString(6)
		buyer := s.WithAuthClaims(ctx, tenantID, partitionID, buyerID)
		s.SeedTenantRole(ctx, svc, tenantID, partitionID, buyerID, "member")

		shop, err := server.CreateShop(owner, &commercev1.CreateShopRequest{
			Name: "Duka", Slug: "duka-" + util.RandomAlphaNumericString(6), Currency: "KES",
		})
		require.NoError(t, err)
		shopID := shop.GetShop().GetId()
		product, err := server.CreateProduct(owner, &commercev1.CreateProductRequest{ShopId: shopID, Name: "Tea"})
		require.NoError(t, err)
		variant, err := server.CreateProductVariant(owner, &commercev1.CreateProductVariantRequest{
			ProductId: product.GetProduct().GetId(), Sku: "TEA-" + util.RandomAlphaNumericString(6), Name: "1kg",
			Price: &commonv1.Money{CurrencyCode: "KES", Units: 500}, StockQuantity: 10,
		})
		require.NoError(t, err)
		orderFor := func(profileID string) *commercev1.Order {
			created, createErr := server.CreateOrder(owner, &commercev1.CreateOrderRequest{
				ShopId: shopID, ProfileId: profileID,
				Lines: []*commercev1.CreateOrderLine{{VariantId: variant.GetProductVariant().GetId(), Quantity: 1}},
			})
			require.NoError(t, createErr)
			return created.GetOrder()
		}
		mine, theirs := orderFor(buyerID), orderFor("someone-else")

		_, err = server.GetShop(buyer, &commercev1.GetShopRequest{Id: shopID})
		require.NoError(t, err, "buyers see the shop")

		_, err = server.GetOrder(buyer, &commercev1.GetOrderRequest{Id: mine.GetId()})
		require.NoError(t, err)
		_, err = server.GetOrder(buyer, &commercev1.GetOrderRequest{Id: theirs.GetId()})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		listed, err := server.ListOrders(buyer, &commercev1.ListOrdersRequest{ShopId: shopID})
		require.NoError(t, err)
		require.Len(t, listed.GetOrders(), 1)
		require.Equal(t, mine.GetId(), listed.GetOrders()[0].GetId())

		_, err = server.PriceListSearch(buyer, &commercev1.PriceListSearchRequest{ShopId: shopID})
		require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

		staff, err := server.ListOrders(owner, &commercev1.ListOrdersRequest{ShopId: shopID})
		require.NoError(t, err)
		require.Len(t, staff.GetOrders(), 2)

		// Staff narrow the shop's orders to one customer, in the query.
		history, err := server.ListOrders(
			owner,
			&commercev1.ListOrdersRequest{ShopId: shopID, ProfileId: "someone-else"},
		)
		require.NoError(t, err)
		require.Len(t, history.GetOrders(), 1)
		require.Equal(t, theirs.GetId(), history.GetOrders()[0].GetId())

		// A buyer may filter by themselves, never by someone else.
		own, err := server.ListOrders(buyer, &commercev1.ListOrdersRequest{ShopId: shopID, ProfileId: buyerID})
		require.NoError(t, err)
		require.Len(t, own.GetOrders(), 1)
		_, err = server.ListOrders(buyer, &commercev1.ListOrdersRequest{ShopId: shopID, ProfileId: "someone-else"})
		require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
	})
}

// A buyer's own cart and order reach them through their profile's default
// contact: a contact id they send is not checked against their profile, so
// it is not kept. Staff placing a cart for a customer may still name one.
func (s *BuyerAccessSuite) TestBuyerCannotPointNotificationsAtAnotherContact() {
	t := s.T()

	s.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := s.CreateService(t, dep)
		server := handlers.NewCommerceServer(ctx, svc, s.AuthzMiddleware, handlers.Dependencies{})

		tenantID, partitionID := "tenant-"+util.RandomAlphaNumericString(6), "partition-1"
		owner := s.WithAuthClaims(ctx, tenantID, partitionID, "owner-"+util.RandomAlphaNumericString(6))
		buyerID := "buyer-" + util.RandomAlphaNumericString(6)
		buyer := s.WithAuthClaims(ctx, tenantID, partitionID, buyerID)
		s.SeedTenantRole(ctx, svc, tenantID, partitionID, buyerID, "member")

		shop, err := server.CreateShop(owner, &commercev1.CreateShopRequest{
			Name: "Duka", Slug: "duka-" + util.RandomAlphaNumericString(6), Currency: "KES",
		})
		require.NoError(t, err)
		shopID := shop.GetShop().GetId()
		product, err := server.CreateProduct(owner, &commercev1.CreateProductRequest{ShopId: shopID, Name: "Tea"})
		require.NoError(t, err)
		variant, err := server.CreateProductVariant(owner, &commercev1.CreateProductVariantRequest{
			ProductId: product.GetProduct().GetId(), Sku: "TEA-" + util.RandomAlphaNumericString(6), Name: "1kg",
			Price: &commonv1.Money{CurrencyCode: "KES", Units: 500}, StockQuantity: 10,
		})
		require.NoError(t, err)

		cart, err := server.CreateCart(buyer, &commercev1.CreateCartRequest{
			ShopId: shopID, ContactId: "someone-elses-contact",
		})
		require.NoError(t, err)
		require.Empty(t, cart.GetCart().GetContactId())
		_, err = server.AddCartLine(buyer, &commercev1.AddCartLineRequest{
			CartId: cart.GetCart().GetId(), ProductVariantId: variant.GetProductVariant().GetId(), Quantity: 1,
		})
		require.NoError(t, err)
		order, err := server.CreateOrderFromCart(buyer, &commercev1.CreateOrderFromCartRequest{
			CartId: cart.GetCart().GetId(), ContactId: "someone-elses-contact",
		})
		require.NoError(t, err)
		require.Equal(t, buyerID, order.GetOrder().GetProfileId())
		require.Empty(t, order.GetOrder().GetContactId(), "notification picks the profile's own contact")

		staffCart, err := server.CreateCart(owner, &commercev1.CreateCartRequest{
			ShopId: shopID, ProfileId: buyerID, ContactId: "customers-contact",
		})
		require.NoError(t, err)
		require.Equal(t, "customers-contact", staffCart.GetCart().GetContactId())
	})
}
