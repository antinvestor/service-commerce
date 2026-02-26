package authz

import "slices"

// Tenant-level namespace
const (
	NamespaceTenant  = "commerce_tenant"
	NamespaceProfile = "profile"
)

// Shop-level namespace
const NamespaceShop = "commerce_shop"

// Tenant-level permissions
const (
	PermissionCreateShop = "create_shop"
	PermissionViewShops  = "view_shops"
)

// Shop-level permissions
const (
	PermissionView            = "view"
	PermissionUpdate          = "update"
	PermissionManageProducts  = "manage_products"
	PermissionViewProducts    = "view_products"
	PermissionManageOrders    = "manage_orders"
	PermissionViewOrders      = "view_orders"
	PermissionManageFulfilment = "manage_fulfilment"
)

// Role constants
const (
	RoleOwner    = "owner"
	RoleAdmin    = "admin"
	RoleOperator = "operator"
	RoleViewer   = "viewer"
	RoleMember   = "member"
)

func RoleToRelation(role string) string {
	switch role {
	case RoleOwner:
		return RoleOwner
	case RoleAdmin:
		return RoleAdmin
	case RoleOperator:
		return RoleOperator
	case RoleViewer:
		return RoleViewer
	default:
		return RoleViewer
	}
}

func ValidRoles() []string {
	return []string{RoleOwner, RoleAdmin, RoleOperator, RoleViewer}
}

func IsValidRole(role string) bool {
	return slices.Contains(ValidRoles(), role)
}
