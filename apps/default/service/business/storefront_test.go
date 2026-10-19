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
	"context"
	"strings"
	"sync"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// fakeBuyers hands out one profile per contact, as the profile service does.
type fakeBuyers struct {
	mu       sync.Mutex
	profiles map[string]string
	// tenants records the tenancy each lookup carried to the profile
	// service.
	tenants []string
}

func (f *fakeBuyers) Resolve(ctx context.Context, _, contact string) (*business.Buyer, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.profiles == nil {
		f.profiles = map[string]string{}
	}
	if info := util.GetTenancy(ctx); info != nil {
		f.tenants = append(f.tenants, info.GetTenantID())
	}
	id, ok := f.profiles[contact]
	if !ok {
		id = "buyer-" + strings.ToLower(util.RandomAlphaNumericString(8))
		f.profiles[contact] = id
	}
	return &business.Buyer{ProfileID: id, ContactID: "contact-" + id}, nil
}

func (bts *BusinessTestSuite) storefront(
	ctx context.Context,
	svc *frame.Service,
	biz allBiz,
	buyers business.BuyerDirectory,
) business.StorefrontBusiness {
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	shopRepo := repository.NewShopRepository(ctx, dbPool, svc.WorkManager())
	return business.NewStorefrontBusiness(
		shopRepo, biz.catalogBiz, biz.orderBiz, biz.paymentBiz, buyers, "https://api.example/commerce/",
	)
}

func (bts *BusinessTestSuite) publicShop(ctx context.Context, biz allBiz) *commercev1.Shop {
	t := bts.T()
	shop, err := biz.shopBiz.CreateShop(ctx, &commercev1.CreateShopRequest{
		Name:             "Corner Shop",
		Slug:             "corner-" + strings.ToLower(util.RandomAlphaNumericString(6)),
		Currency:         "USD",
		PublicStorefront: true,
	})
	require.NoError(t, err)
	return shop
}

func (bts *BusinessTestSuite) TestStorefront_GuestBuysFromAPublicShop() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		buyers := &fakeBuyers{}
		front := bts.storefront(ctx, svc, biz, buyers)

		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		require.Equal(t, "https://api.example/commerce/shop/"+shop.GetSlug(), func() string {
			got, err := biz.shopBiz.GetShop(ctx, shop.GetId())
			require.NoError(t, err)
			return got.GetStorefrontUrl()
		}())

		// The visitor carries no identity at all.
		visitor := context.Background()

		page, err := front.Storefront(visitor, shop.GetSlug())
		require.NoError(t, err)
		require.Equal(t, "Corner Shop", page.Shop.GetName())
		require.Len(t, page.Items, 1)
		require.Equal(t, variant.GetId(), page.Items[0].Variants[0].GetId())

		order := business.StorefrontOrder{
			Name: " Jane Buyer ", Contact: "Jane@Example.com", Key: util.IDString(),
			Quantities: map[string]int64{variant.GetId(): 2},
		}
		target, err := front.Checkout(visitor, shop.GetSlug(), order)
		require.NoError(t, err)
		require.True(t, strings.HasPrefix(target, "https://pay.example/c/"), target)
		require.Equal(t, []string{shopTenant(ctx)}, buyers.tenants,
			"the profile lookup runs in the shop's tenancy")

		// Submitting the same form again starts no second order or session.
		again, err := front.Checkout(visitor, shop.GetSlug(), order)
		require.NoError(t, err)
		require.Equal(t, target, again)
		require.Equal(t, 1, biz.checkout.createdSessions())

		// The shop's staff see the order, placed for the buyer and awaiting
		// payment, with the storefront as the place to come back to.
		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		require.Len(t, orders.Orders, 1)
		placed := orders.Orders[0]
		require.Equal(t, buyers.profiles["jane@example.com"], placed.GetProfileId())
		require.Equal(t, commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT, placed.GetStatus())
		require.Equal(t, int64(21), placed.GetTotal().GetUnits())
		session := biz.checkout.session(placed.GetPaymentSessionRef())
		require.Equal(t, "https://api.example/commerce/shop/"+shop.GetSlug(), session.GetReturnUrl())
	})
}

// shopTenant is the tenant the test service's claims create shops in.
func shopTenant(ctx context.Context) string {
	return security.ClaimsFromContext(ctx).GetTenantID()
}

func (bts *BusinessTestSuite) TestStorefront_HidesShopsThatHaveNotOptedIn() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		front := bts.storefront(ctx, svc, biz, &fakeBuyers{})

		private := bts.createTestShop(ctx, biz)
		_, err := front.Storefront(ctx, private.GetSlug())
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		public := bts.publicShop(ctx, biz)
		_, err = biz.shopBiz.UpdateShop(ctx, &commercev1.UpdateShopRequest{
			Id:         public.GetId(),
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"public_storefront"}},
		})
		require.NoError(t, err)
		_, err = front.Storefront(ctx, public.GetSlug())
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err), "turned off again")

		_, err = front.Storefront(ctx, "no-such-shop")
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}

func (bts *BusinessTestSuite) TestStorefront_RejectsBadForms() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		shop := bts.publicShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		good := func() business.StorefrontOrder {
			return business.StorefrontOrder{
				Name: "Sam", Contact: "+254 700-000 001", Key: util.IDString(),
				Quantities: map[string]int64{variant.GetId(): 1},
			}
		}

		_, err := bts.storefront(ctx, svc, biz, nil).Checkout(ctx, shop.GetSlug(), good())
		require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err), "no profile service, no checkout")

		front := bts.storefront(ctx, svc, biz, &fakeBuyers{})
		for name, mutate := range map[string]func(*business.StorefrontOrder){
			"no name":        func(o *business.StorefrontOrder) { o.Name = " " },
			"bad contact":    func(o *business.StorefrontOrder) { o.Contact = "call me" },
			"no key":         func(o *business.StorefrontOrder) { o.Key = "" },
			"nothing chosen": func(o *business.StorefrontOrder) { o.Quantities = map[string]int64{variant.GetId(): 0} },
			"too many":       func(o *business.StorefrontOrder) { o.Quantities = map[string]int64{variant.GetId(): 100} },
			"bad variant":    func(o *business.StorefrontOrder) { o.Quantities = map[string]int64{"<x>": 1} },
			"bad deposit":    func(o *business.StorefrontOrder) { o.Deposit = "ten" },
			"zero deposit":   func(o *business.StorefrontOrder) { o.Deposit = "0.00" },
		} {
			order := good()
			mutate(&order)
			_, err = front.Checkout(ctx, shop.GetSlug(), order)
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), name)
		}

		// A deposit is refused when the shop does not take instalments.
		order := good()
		order.Deposit = "5"
		_, err = front.Checkout(ctx, shop.GetSlug(), order)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// With instalments, a deposit that meets the policy is charged.
		bts.setShopPolicy(ctx, biz, shop.GetId(), instalmentPolicy())
		order = good()
		order.Quantities = map[string]int64{variant.GetId(): 2}
		order.Deposit = "7.50"
		_, err = front.Checkout(ctx, shop.GetSlug(), order)
		require.NoError(t, err)
		orders, err := biz.orderBiz.ListOrders(ctx, &commercev1.ListOrdersRequest{ShopId: shop.GetId()})
		require.NoError(t, err)
		var charged int64
		var cents int32
		for _, o := range orders.Orders {
			if ref := o.GetPaymentSessionRef(); ref != "" {
				amount := biz.checkout.session(ref).GetAmount()
				charged, cents = amount.GetUnits(), amount.GetNanos()
			}
		}
		require.Equal(t, int64(7), charged)
		require.Equal(t, int32(500_000_000), cents)
	})
}
