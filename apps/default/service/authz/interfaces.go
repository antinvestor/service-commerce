package authz

import "context"

// Middleware defines permission checks for commerce operations.
type Middleware interface {
	// Tenant-level checks
	CanCreateShop(ctx context.Context) error
	CanViewShops(ctx context.Context) error

	// Shop-level checks (resource-level ReBAC)
	CanViewShop(ctx context.Context, shopID string) error
	CanUpdateShop(ctx context.Context, shopID string) error
	CanManageProducts(ctx context.Context, shopID string) error
	CanViewProducts(ctx context.Context, shopID string) error
	CanManageOrders(ctx context.Context, shopID string) error
	CanViewOrders(ctx context.Context, shopID string) error
	CanManageFulfilment(ctx context.Context, shopID string) error

	// Tuple management
	AddShopMember(ctx context.Context, shopID string, profileID string, role string) error
	RemoveShopMember(ctx context.Context, shopID string, profileID string) error
	UpdateShopMemberRole(ctx context.Context, shopID string, profileID string, oldRole string, newRole string) error
}
