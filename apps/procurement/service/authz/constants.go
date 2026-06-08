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

import "slices"

// Namespace constants aligned with the two-layer ReBAC model.
const (
	// NamespaceProcurement is the functional permissions namespace for procurement operations.
	NamespaceProcurement = "service_procurement"

	// NamespaceTenancyAccess is the cross-service data access namespace (Layer 1).
	NamespaceTenancyAccess = "tenancy_access"

	// NamespaceProfile is the platform-wide user identity namespace.
	NamespaceProfile = "profile_user"
)

// NamespaceProperty is the property-level namespace (resource-level ReBAC).
const NamespaceProperty = "procurement_property"

// Tenant-level permissions (checked in service_procurement namespace).
const (
	PermissionSuppliersManage     = "suppliers_manage"
	PermissionSuppliersView       = "suppliers_view"
	PermissionPurchaseOrderCreate = "purchase_order_create"
	PermissionPurchaseOrderView   = "purchase_order_view"
)

// Granted relation constants for direct permission grants.
const (
	GrantedSuppliersManage     = "granted_suppliers_manage"
	GrantedSuppliersView       = "granted_suppliers_view"
	GrantedPurchaseOrderCreate = "granted_purchase_order_create"
	GrantedPurchaseOrderView   = "granted_purchase_order_view"
)

// Property-level permissions (checked in procurement_property namespace).
const (
	PermissionPropertyView              = "property_view"
	PermissionPropertyUpdate            = "property_update"
	PermissionPurchaseOrderManage       = "purchase_order_manage"
	PermissionPurchaseOrderPropertyView = "purchase_order_property_view"
	PermissionGoodsReceiptManage        = "goods_receipt_manage"
	PermissionGoodsReceiptView          = "goods_receipt_view"
)

// Granted relation constants for property-level direct permission grants.
const (
	GrantedPropertyView              = "granted_property_view"
	GrantedPropertyUpdate            = "granted_property_update"
	GrantedPurchaseOrderManage       = "granted_purchase_order_manage"
	GrantedPurchaseOrderPropertyView = "granted_purchase_order_property_view"
	GrantedGoodsReceiptManage        = "granted_goods_receipt_manage"
	GrantedGoodsReceiptView          = "granted_goods_receipt_view"
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
func GrantedRelation(permission string) string {
	return "granted_" + permission
}

// RolePermissions documents the permission model defined in the OPL namespace config.
var RolePermissions = map[string][]string{ //nolint:gochecknoglobals // permission model registry
	RoleOwner: {
		PermissionSuppliersManage,
		PermissionSuppliersView,
		PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderView,
	},
	RoleAdmin: {
		PermissionSuppliersManage,
		PermissionSuppliersView,
		PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderView,
	},
	RoleMember: {
		PermissionSuppliersView,
		PermissionPurchaseOrderView,
	},
	RoleService: {
		PermissionSuppliersManage,
		PermissionSuppliersView,
		PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderView,
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
