package authz

import "slices"

// Namespace constants aligned with the two-layer ReBAC model.
const (
	// NamespaceCommerce is the functional permissions namespace for commerce operations.
	NamespaceCommerce = "service_commerce"

	// NamespaceTenancyAccess is the cross-service data access namespace (Layer 1).
	NamespaceTenancyAccess = "tenancy_access"

	// NamespaceProfile is the platform-wide user identity namespace.
	NamespaceProfile = "profile/user"
)

// Shop-level namespace (resource-level ReBAC, not affected by two-layer model).
const NamespaceShop = "commerce_shop"

// Tenant-level permissions (checked in service_commerce namespace).
const (
	PermissionCreateShop = "create_shop"
	PermissionViewShops  = "view_shops"
)

// Shop-level permissions (checked in commerce_shop namespace).
const (
	PermissionView             = "view"
	PermissionUpdate           = "update"
	PermissionManageProducts   = "manage_products"
	PermissionViewProducts     = "view_products"
	PermissionManageOrders     = "manage_orders"
	PermissionViewOrders       = "view_orders"
	PermissionManageFulfilment = "manage_fulfilment"
)

// Role constants.
const (
	RoleOwner    = "owner"
	RoleAdmin    = "admin"
	RoleOperator = "operator"
	RoleViewer   = "viewer"
	RoleMember   = "member"
	RoleService  = "service"
)

// RolePermissions maps each role to the permissions it grants in the service_commerce namespace.
// This materialises the permission model defined in the OPL namespace config,
// since the Keto v1alpha2 gRPC API does not evaluate OPL permits.
var RolePermissions = map[string][]string{ //nolint:gochecknoglobals // permission model registry
	RoleOwner: {
		PermissionCreateShop,
		PermissionViewShops,
	},
	RoleAdmin: {
		PermissionCreateShop,
		PermissionViewShops,
	},
	RoleMember: {
		PermissionViewShops,
	},
	RoleService: {
		PermissionCreateShop,
		PermissionViewShops,
	},
}

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
