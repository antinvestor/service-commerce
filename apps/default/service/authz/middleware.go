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

import (
	"context"
	"fmt"

	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	"github.com/pitabwire/util"
)

// middleware implements the Middleware interface.
// Tenant-level checks are handled by the FunctionAccessInterceptor.
// Shop-level checks use the raw authorizer (commerce_shop namespace).
type middleware struct {
	service security.Authorizer
}

// NewMiddleware creates a new Middleware with the given authorizer service.
// Data access (tenancy_access) is verified by the TenancyAccessInterceptor
// in the Connect middleware chain. Tenant-level functional permissions are
// enforced by the FunctionAccessInterceptor. This middleware only checks
// resource-level permissions in the commerce_shop namespace.
func NewMiddleware(service security.Authorizer) Middleware {
	return &middleware{
		service: service,
	}
}

// --- Shop-level checks (resource-level ReBAC) ---

// CanShopView checks if the caller can view a specific shop.
func (m *middleware) CanShopView(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionShopView)
}

// CanShopUpdate checks if the caller can update a specific shop.
func (m *middleware) CanShopUpdate(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionShopUpdate)
}

// CanProductsManage checks if the caller can manage products for a shop.
func (m *middleware) CanProductsManage(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionProductsManage)
}

// CanProductsView checks if the caller can view products for a shop.
func (m *middleware) CanProductsView(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionProductsView)
}

// CanOrdersManage checks if the caller can manage orders for a shop.
func (m *middleware) CanOrdersManage(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionOrdersManage)
}

// CanOrdersView checks if the caller can view orders for a shop.
func (m *middleware) CanOrdersView(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionOrdersView)
}

// CanFulfilmentManage checks if the caller can manage fulfilment for a shop.
func (m *middleware) CanFulfilmentManage(ctx context.Context, shopID string) error {
	return m.checkShopPermission(ctx, shopID, PermissionFulfilmentManage)
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
