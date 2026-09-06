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

package authz

import "context"

// Middleware defines permission checks for commerce operations.
// Tenant-level checks (e.g. shop_create, shops_view) are handled by
// the FunctionAccessInterceptor. This interface only exposes
// shop-level (resource-level ReBAC) checks and tuple management.
type Middleware interface {
	// Shop-level checks (resource-level ReBAC)
	CanShopView(ctx context.Context, shopID string) error
	CanShopUpdate(ctx context.Context, shopID string) error
	CanProductsManage(ctx context.Context, shopID string) error
	CanProductsView(ctx context.Context, shopID string) error
	CanOrdersManage(ctx context.Context, shopID string) error
	CanOrdersView(ctx context.Context, shopID string) error
	CanFulfilmentManage(ctx context.Context, shopID string) error
	CanPriceListView(ctx context.Context, shopID string) error
	CanPriceListManage(ctx context.Context, shopID string) error
	CanCustomerPriceOverride(ctx context.Context, shopID string) error
	CanDiscountManage(ctx context.Context, shopID string) error

	// Tuple management
	AddShopMember(ctx context.Context, shopID string, profileID string, role string) error
	// BridgeShopRoles makes every partition-level commerce role (owner, admin,
	// operator, viewer, member) hold the same role on the shop, so staff
	// provisioned through the identity service reach the shop without any
	// per-shop grant. tenancyPath is "<tenant>/<partition>".
	BridgeShopRoles(ctx context.Context, shopID string, tenancyPath string) error
	RemoveShopMember(ctx context.Context, shopID string, profileID string) error
	UpdateShopMemberRole(
		ctx context.Context,
		shopID string,
		profileID string,
		oldRole string,
		newRole string,
	) error
}
