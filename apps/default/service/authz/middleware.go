package authz

import (
	"context"
	"fmt"

	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	"github.com/pitabwire/util"
)

// middleware implements the Middleware interface.
type middleware struct {
	service security.Authorizer
}

// NewMiddleware creates a new Middleware with the given authorizer service.
func NewMiddleware(service security.Authorizer) Middleware {
	return &middleware{
		service: service,
	}
}

// --- Tenant-level checks ---

// CanCreateShop checks if the caller can create a shop within their tenant.
func (m *middleware) CanCreateShop(ctx context.Context) error {
	return m.check(ctx, PermissionCreateShop)
}

// CanViewShops checks if the caller can list shops within their tenant.
func (m *middleware) CanViewShops(ctx context.Context) error {
	return m.check(ctx, PermissionViewShops)
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

// check performs a tenant-level permission check using claims from context.
func (m *middleware) check(ctx context.Context, permission string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return authorizer.ErrInvalidSubject
	}

	subjectID, err := claims.GetSubject()
	if err != nil || subjectID == "" {
		return authorizer.ErrInvalidSubject
	}

	tenantID := claims.GetTenantID()
	if tenantID == "" {
		return authorizer.ErrInvalidObject
	}

	req := security.CheckRequest{
		Object:     security.ObjectRef{Namespace: NamespaceTenant, ID: tenantID},
		Permission: permission,
		Subject:    security.SubjectRef{Namespace: NamespaceProfile, ID: subjectID},
	}

	result, err := m.service.Check(ctx, req)
	if err != nil {
		return fmt.Errorf("authorization check failed: %w", err)
	}
	if !result.Allowed {
		return authorizer.NewPermissionDeniedError(req.Object, permission, req.Subject, result.Reason)
	}

	return nil
}

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
