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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

func asSubject(ctx context.Context, subject string) context.Context {
	claims := &security.AuthenticationClaims{}
	claims.Subject = subject
	return claims.ClaimsToContext(ctx)
}

func (bts *BusinessTestSuite) TestDiscountApproval_GatesAutomaticDiscounts() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricing := bts.getPricingBusiness(svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())

		price := func() int32 {
			resolved, err := pricing.ResolvePrice(ctx, &commercev1.ResolvePriceRequest{
				ProductVariantId: variant.GetId(), Quantity: 1,
			})
			require.NoError(t, err)
			return int32(resolved.GetUnitPrice().GetUnits())*100 + resolved.GetUnitPrice().GetNanos()/10_000_000
		}
		require.Equal(t, int32(1050), price(), "catalog 10.50")

		rule, err := pricing.SaveDiscountRule(ctx, &commercev1.DiscountRuleSaveRequest{
			ShopId: shop.GetId(), Name: "Staff 10%", DiscountType: commercev1.DiscountType_DISCOUNT_TYPE_PERCENTAGE,
			Value: 10, AppliesTo: commercev1.DiscountAppliesTo_DISCOUNT_APPLIES_TO_LINE_ITEM,
			RequiresApproval: true, Status: commercev1.DiscountRuleStatus_DISCOUNT_RULE_STATUS_ACTIVE,
		})
		require.NoError(t, err)
		require.Equal(t, int32(1050), price(), "unapproved rules are never applied")

		_, err = pricing.ApproveDiscountRule(ctx, rule.GetId())
		require.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err), "an approver must be known")

		approved, err := pricing.ApproveDiscountRule(asSubject(ctx, "approver-1"), rule.GetId())
		require.NoError(t, err)
		require.Equal(t, "approver-1", approved.GetApprovedBy())
		require.Equal(t, int32(945), price(), "approved: 10% off")

		// Changing what the rule gives away needs a fresh approval.
		changed, err := pricing.SaveDiscountRule(ctx, &commercev1.DiscountRuleSaveRequest{
			Id: rule.GetId(), ShopId: shop.GetId(), Value: 20,
		})
		require.NoError(t, err)
		require.Empty(t, changed.GetApprovedBy())
		require.True(t, changed.GetRequiresApproval(), "a plain update cannot drop the requirement")
		require.Equal(t, int32(1050), price())

		// Waiving it explicitly (the handler requires discount_approve).
		waived, err := pricing.SaveDiscountRule(ctx, &commercev1.DiscountRuleSaveRequest{
			Id: rule.GetId(), ShopId: shop.GetId(),
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"requires_approval"}},
		})
		require.NoError(t, err)
		require.False(t, waived.GetRequiresApproval())
		require.Equal(t, int32(840), price(), "20% off, no approval needed")
	})
}

func (bts *BusinessTestSuite) TestPricingUpdates_StayOnTheirParent() {
	t := bts.T()

	bts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := bts.CreateService(t, dep)
		biz := bts.getBusiness(ctx, svc)
		pricing := bts.getPricingBusiness(svc)
		shop := bts.createTestShop(ctx, biz)
		_, variant := bts.createTestProductWithVariant(ctx, biz, shop.GetId())
		_, other := bts.createTestProductWithVariant(ctx, biz, bts.createTestShop(ctx, biz).GetId())

		override, err := pricing.SaveCustomerPriceOverride(ctx, &commercev1.CustomerPriceOverrideSaveRequest{
			CustomerId: "cust-1", ProductVariantId: variant.GetId(),
			UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: 5},
		})
		require.NoError(t, err)
		// Authorised for `other`'s shop, trying to edit an override in this one.
		_, err = pricing.SaveCustomerPriceOverride(ctx, &commercev1.CustomerPriceOverrideSaveRequest{
			Id: override.GetId(), CustomerId: "cust-1", ProductVariantId: other.GetId(),
			UnitPrice: &commonv1.Money{CurrencyCode: "USD", Units: 1},
		})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		listA, err := pricing.SavePriceList(ctx, &commercev1.PriceListSaveRequest{ShopId: shop.GetId(), Name: "A"})
		require.NoError(t, err)
		listB, err := pricing.SavePriceList(ctx, &commercev1.PriceListSaveRequest{ShopId: shop.GetId(), Name: "B"})
		require.NoError(t, err)
		assignment, err := pricing.SaveCustomerPriceListAssignment(ctx,
			&commercev1.CustomerPriceListAssignmentSaveRequest{CustomerId: "cust-1", PriceListId: listA.GetId()})
		require.NoError(t, err)
		_, err = pricing.SaveCustomerPriceListAssignment(ctx, &commercev1.CustomerPriceListAssignmentSaveRequest{
			Id: assignment.GetId(), CustomerId: "cust-1", PriceListId: listB.GetId(),
			Status: commercev1.CustomerPriceListAssignmentStatus_CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE,
		})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}
