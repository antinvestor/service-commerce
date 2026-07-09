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

import "github.com/pitabwire/frame/v2/security"

// BuildAccessTuple creates a member relation tuple in the tenancy_access namespace,
// recording that a profile has access to a tenant/partition combination.
func BuildAccessTuple(tenancyPath, profileID string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceTenancyAccess, ID: tenancyPath},
		Relation: RoleMember,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	}
}

// BuildServiceAccessTuple creates a service relation tuple in tenancy_access,
// marking a profile as a service account for the given tenancy path.
func BuildServiceAccessTuple(tenancyPath, profileID string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceTenancyAccess, ID: tenancyPath},
		Relation: RoleService,
		Subject:  security.SubjectRef{Namespace: NamespaceProfile, ID: profileID},
	}
}

// BuildServiceInheritanceTuples creates the subject set chain that gives service
// accounts automatic access to functional roles via Keto composition.
//
// It writes a single cross-namespace bridge:
//
//	service_commerce:path#service <- tenancy_access:path#service
//
// Permission resolution from service role to individual permissions is handled
// by Keto's OPL permits evaluation, so no permission bridge tuples are needed.
func BuildServiceInheritanceTuples(tenancyPath string) []security.RelationTuple {
	return []security.RelationTuple{
		{
			Object:   security.ObjectRef{Namespace: NamespaceCommerce, ID: tenancyPath},
			Relation: RoleService,
			Subject:  security.SubjectRef{Namespace: NamespaceTenancyAccess, ID: tenancyPath, Relation: RoleService},
		},
	}
}
