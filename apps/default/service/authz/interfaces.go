package authz

import "context"

// Middleware defines permission checks for commerce operations.
type Middleware interface {
	// Tenant-level checks
	CanShopCreate(ctx context.Context) error
	CanShopsView(ctx context.Context) error

	// Shop-level checks (resource-level ReBAC)
	CanShopView(ctx context.Context, shopID string) error
	CanShopUpdate(ctx context.Context, shopID string) error
	CanProductsManage(ctx context.Context, shopID string) error
	CanProductsView(ctx context.Context, shopID string) error
	CanOrdersManage(ctx context.Context, shopID string) error
	CanOrdersView(ctx context.Context, shopID string) error
	CanFulfilmentManage(ctx context.Context, shopID string) error

	// Tuple management
	AddShopMember(ctx context.Context, shopID string, profileID string, role string) error
	RemoveShopMember(ctx context.Context, shopID string, profileID string) error
	UpdateShopMemberRole(ctx context.Context, shopID string, profileID string, oldRole string, newRole string) error
}
