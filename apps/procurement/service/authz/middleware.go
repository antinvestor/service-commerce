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

	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	"github.com/pitabwire/util"
)

// Structured-log keys reused across authz middleware decisions below.
const (
	logKeyPropertyID = "property_id"
	logKeyProfileID  = "profile_id"
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

// --- Property-level checks (resource-level ReBAC) ---

func (m *middleware) CanPropertyView(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionPropertyView)
}

func (m *middleware) CanPropertyUpdate(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionPropertyUpdate)
}

func (m *middleware) CanPurchaseOrderManage(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionPurchaseOrderManage)
}

func (m *middleware) CanPurchaseOrderView(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionPurchaseOrderPropertyView)
}

func (m *middleware) CanGoodsReceiptManage(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionGoodsReceiptManage)
}

func (m *middleware) CanGoodsReceiptView(ctx context.Context, propertyID string) error {
	return m.checkPropertyPermission(ctx, propertyID, PermissionGoodsReceiptView)
}

// --- Tuple management ---

func (m *middleware) AddPropertyMember(ctx context.Context, propertyID, profileID, role string) error {
	relation := RoleToRelation(role)
	util.Log(ctx).WithFields(map[string]any{
		logKeyPropertyID: propertyID,
		logKeyProfileID:  profileID,
		"role":           role,
		"relation":       relation,
	}).Debug("AddPropertyMember writing tuple")
	return m.service.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceProperty, ID: propertyID},
		Relation: relation,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	})
}

func (m *middleware) RemovePropertyMember(ctx context.Context, propertyID, profileID string) error {
	util.Log(ctx).WithFields(map[string]any{
		logKeyPropertyID: propertyID,
		logKeyProfileID:  profileID,
	}).Debug("RemovePropertyMember deleting tuples")
	tuples := make([]security.RelationTuple, len(ValidRoles()))
	for i, role := range ValidRoles() {
		tuples[i] = security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceProperty, ID: propertyID},
			Relation: role,
			Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
		}
	}
	return m.service.DeleteTuples(ctx, tuples)
}

func (m *middleware) UpdatePropertyMemberRole(
	ctx context.Context,
	propertyID, profileID, oldRole, newRole string,
) error {
	util.Log(ctx).WithFields(map[string]any{
		logKeyPropertyID: propertyID,
		logKeyProfileID:  profileID,
		"old_role":       oldRole,
		"new_role":       newRole,
	}).Debug("UpdatePropertyMemberRole")
	// Remove old relation if specified
	if oldRole != "" {
		if err := m.service.DeleteTuple(ctx, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceProperty, ID: propertyID},
			Relation: RoleToRelation(oldRole),
			Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
		}); err != nil {
			return fmt.Errorf("remove old property role: %w", err)
		}
	}

	// Add new relation
	return m.service.WriteTuple(ctx, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceProperty, ID: propertyID},
		Relation: RoleToRelation(newRole),
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	})
}

// --- Internal helpers ---

func (m *middleware) checkPropertyPermission(ctx context.Context, propertyID, permission string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return authorizer.ErrInvalidSubject
	}

	subjectID, err := claims.GetSubject()
	if err != nil || subjectID == "" {
		return authorizer.ErrInvalidSubject
	}

	util.Log(ctx).WithFields(map[string]any{
		logKeyPropertyID: propertyID,
		logKeyProfileID:  subjectID,
		"permission":     permission,
	}).Debug("checkPropertyPermission")

	req := security.CheckRequest{
		Object:     security.ObjectRef{Namespace: NamespaceProperty, ID: propertyID},
		Permission: permission,
		Subject:    security.SubjectRef{Namespace: NamespaceProfile, ID: subjectID},
	}

	result, err := m.service.Check(ctx, req)
	if err != nil {
		return fmt.Errorf("authorization check failed: %w", err)
	}
	if !result.Allowed {
		result, err = m.checkPartitionPermission(ctx, claims, subjectID, permission)
		if err != nil {
			return err
		}
	}

	util.Log(ctx).WithFields(map[string]any{
		logKeyPropertyID: propertyID,
		"permission":     permission,
		"allowed":        result.Allowed,
	}).Debug("checkPropertyPermission result")

	if !result.Allowed {
		return authorizer.NewPermissionDeniedError(req.Object, permission, req.Subject, result.Reason)
	}

	return nil
}

// partitionPermissions maps each property permission to the partition-level
// permission that grants it on every property in the caller's partition.
var partitionPermissions = map[string]string{ //nolint:gochecknoglobals // permission model registry
	PermissionPropertyView:              PermissionPurchaseOrderView,
	PermissionPurchaseOrderPropertyView: PermissionPurchaseOrderView,
	PermissionPurchaseOrderManage:       PermissionPurchaseOrderCreate,
	PermissionPropertyUpdate:            PermissionPurchaseOrderCreate,
	PermissionGoodsReceiptView:          PermissionGoodsReceiptRead,
	PermissionGoodsReceiptManage:        PermissionGoodsReceiptCreate,
}

// checkPartitionPermission grants a property permission to a caller who holds
// the matching permission on their own partition, where the tenancy sync
// assigns staff roles. Properties are the console's sites (a branch,
// organisation or partition); row-level security keeps each partition's
// records to itself, so the partition grant never reaches another
// partition's data. Nothing is written: a check only reads.
func (m *middleware) checkPartitionPermission(
	ctx context.Context,
	claims *security.AuthenticationClaims,
	subjectID, permission string,
) (security.CheckResult, error) {
	tenantID, partitionID := claims.GetTenantID(), claims.GetPartitionID()
	partitionPermission, ok := partitionPermissions[permission]
	if tenantID == "" || partitionID == "" || !ok {
		return security.CheckResult{}, nil
	}
	result, err := m.service.Check(ctx, security.CheckRequest{
		Object:     security.ObjectRef{Namespace: NamespaceProcurement, ID: tenantID + "/" + partitionID},
		Permission: partitionPermission,
		Subject:    security.SubjectRef{Namespace: NamespaceProfile, ID: subjectID},
	})
	if err != nil {
		return security.CheckResult{}, fmt.Errorf("partition authorization check failed: %w", err)
	}
	return result, nil
}
