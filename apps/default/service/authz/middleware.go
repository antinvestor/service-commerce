package authz

import (
	"context"
	"fmt"

	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	"github.com/pitabwire/util"
)

// middleware implements the Middleware interface.
// Tenant-level checks use FunctionChecker (service_commerce namespace).
// Shop-level checks use raw authorizer (commerce_shop namespace).
type middleware struct {
	checker *authorizer.FunctionChecker
	service security.Authorizer
}

// NewMiddleware creates a new Middleware with the given authorizer service.
// Data access (tenancy_access) is verified by the TenancyAccessInterceptor
// in the Connect middleware chain. This middleware only checks functional
// permissions in the service_commerce namespace and resource-level permissions
// in the commerce_shop namespace.
func NewMiddleware(service security.Authorizer) Middleware {
	return &middleware{
		checker: authorizer.NewFunctionChecker(service, NamespaceCommerce),
		service: service,
	}
}

// --- Tenant-level checks (via FunctionChecker) ---

// CanCreateShop checks if the caller can create a shop within their tenant.
func (m *middleware) CanCreateShop(ctx context.Context) error {
	return m.checker.Check(ctx, PermissionCreateShop)
}

// CanViewShops checks if the caller can list shops within their tenant.
func (m *middleware) CanViewShops(ctx context.Context) error {
	return m.checker.Check(ctx, PermissionViewShops)
}

// --- Shop-level checks (resource-level ReBAC) ---

// CanViewShop checks if the caller can view a specific shop.
func (m *middleware) CanViewShop(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionView)
}

// CanUpdateShop checks if the caller can update a specific shop.
func (m *middleware) CanUpdateShop(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionUpdate)
}

// CanManageProducts checks if the caller can manage products for a shop.
func (m *middleware) CanManageProducts(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionManageProducts)
}

// CanViewProducts checks if the caller can view products for a shop.
func (m *middleware) CanViewProducts(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionViewProducts)
}

// CanManageOrders checks if the caller can manage orders for a shop.
func (m *middleware) CanManageOrders(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionManageOrders)
}

// CanViewOrders checks if the caller can view orders for a shop.
func (m *middleware) CanViewOrders(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionViewOrders)
}

// CanManageFulfilment checks if the caller can manage fulfilment for a shop.
func (m *middleware) CanManageFulfilment(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionManageFulfilment)
}

// --- Tuple management ---

// AddShopMember adds a member to a shop with the specified role.
func (m *middleware) AddShopMember(ctx context.Context, shopID, profileID, role string) error {
	relation := RoleToRelation(role)
	util.Log(ctx).WithFields(map[string]any{
		"shop_id":    shopID,
		"profile_id": profileID,
		"role":       role,
		"relation":   relation,
	}).Debug("AddShopMember writing tuple")
	return m.service.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceShop, ID: shopID},
		Relation: relation,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	})
}

// RemoveShopMember removes all relations for a member from a shop.
func (m *middleware) RemoveShopMember(ctx context.Context, shopID, profileID string) error {
	util.Log(ctx).WithFields(map[string]any{
		"shop_id":    shopID,
		"profile_id": profileID,
	}).Debug("RemoveShopMember deleting tuples")
	tuples := make([]security.RelationTuple, len(ValidRoles()))
	for i, role := range ValidRoles() {
		tuples[i] = security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceShop, ID: shopID},
			Relation: role,
			Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
		}
	}
	return m.service.DeleteTuples(ctx, tuples)
}

// UpdateShopMemberRole updates a member's role in a shop.
func (m *middleware) UpdateShopMemberRole(ctx context.Context, shopID, profileID, oldRole, newRole string) error {
	util.Log(ctx).WithFields(map[string]any{
		"shop_id":    shopID,
		"profile_id": profileID,
		"old_role":   oldRole,
		"new_role":   newRole,
	}).Debug("UpdateShopMemberRole")
	// Remove old relation if specified
	if oldRole != "" {
		_ = m.service.DeleteTuple(ctx, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceShop, ID: shopID},
			Relation: RoleToRelation(oldRole),
			Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
		})
	}

	// Add new relation
	return m.service.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceShop, ID: shopID},
		Relation: RoleToRelation(newRole),
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	})
}

// --- Internal helpers ---

// checkShopPermission performs a shop-level permission check using claims from context.
func (m *middleware) checkShopPermission(ctx context.Context, shopID, permission string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return authorizer.ErrInvalidSubject
	}

	subjectID, err := claims.GetSubject()
	if err != nil || subjectID == "" {
		return authorizer.ErrInvalidSubject
	}

	util.Log(ctx).WithFields(map[string]any{
		"shop_id":    shopID,
		"profile_id": subjectID,
		"permission": permission,
	}).Debug("checkShopPermission")

	req := security.CheckRequest{
		Object:     security.ObjectRef{Namespace: NamespaceShop, ID: shopID},
		Permission: permission,
		Subject:    security.SubjectRef{Namespace: NamespaceProfile, ID: subjectID},
	}

	result, err := m.service.Check(ctx, req)
	if err != nil {
		return fmt.Errorf("authorization check failed: %w", err)
	}

	util.Log(ctx).WithFields(map[string]any{
		"shop_id":    shopID,
		"permission": permission,
		"allowed":    result.Allowed,
	}).Debug("checkShopPermission result")

	if !result.Allowed {
		return authorizer.NewPermissionDeniedError(req.Object, permission, req.Subject, result.Reason)
	}

	return nil
}
