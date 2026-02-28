package authz

import "slices"

// Namespace constants aligned with the two-layer ReBAC model.
const (
	// NamespaceCommerce is the functional permissions namespace for commerce operations.
	NamespaceCommerce = "service_commerce"

	// NamespaceTenancyAccess is the cross-service data access namespace (Layer 1).
	NamespaceTenancyAccess = "tenancy_access"

	// NamespaceProfile is the platform-wide user identity namespace.
	NamespaceProfile = "profile_user"
)

// Shop-level namespace (resource-level ReBAC, not affected by two-layer model).
const NamespaceShop = "commerce_shop"

// Tenant-level permissions (checked in service_commerce namespace).
const (
	PermissionShopCreate = "shop_create"
	PermissionShopsView  = "shops_view"
)

// Granted relation constants for direct permission grants.
// These use the "granted_" prefix so that Keto does not skip permit evaluation
// when a relation shares the same name as a permit function.
const (
	GrantedShopCreate = "granted_shop_create"
	GrantedShopsView  = "granted_shops_view"
)

// Shop-level permissions (checked in commerce_shop namespace).
const (
	PermissionShopView          = "shop_view"
	PermissionShopUpdate        = "shop_update"
	PermissionProductsManage    = "products_manage"
	PermissionProductsView      = "products_view"
	PermissionOrdersManage      = "orders_manage"
	PermissionOrdersView        = "orders_view"
	PermissionFulfilmentManage  = "fulfilment_manage"
)

// Granted relation constants for shop-level direct permission grants.
const (
	GrantedShopView         = "granted_shop_view"
	GrantedShopUpdate       = "granted_shop_update"
	GrantedProductsManage   = "granted_products_manage"
	GrantedProductsView     = "granted_products_view"
	GrantedOrdersManage     = "granted_orders_manage"
	GrantedOrdersView       = "granted_orders_view"
	GrantedFulfilmentManage = "granted_fulfilment_manage"
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

// GrantedRelation returns the granted_ prefixed relation name for a permission.
// This is used when writing direct permission grant tuples to avoid name conflicts
// with OPL permit functions in Keto.
func GrantedRelation(permission string) string {
	return "granted_" + permission
}

// RolePermissions documents the permission model defined in the OPL namespace config.
// Keto's Check API evaluates OPL permits, so only role tuples need to be written;
// permission resolution happens automatically through the OPL model.
var RolePermissions = map[string][]string{ //nolint:gochecknoglobals // permission model registry
	RoleOwner: {
		PermissionShopCreate,
		PermissionShopsView,
	},
	RoleAdmin: {
		PermissionShopCreate,
		PermissionShopsView,
	},
	RoleMember: {
		PermissionShopsView,
	},
	RoleService: {
		PermissionShopCreate,
		PermissionShopsView,
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
