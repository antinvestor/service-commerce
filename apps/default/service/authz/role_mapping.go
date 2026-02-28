package authz

import "github.com/pitabwire/frame/security"

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
// For service_commerce it writes:
//  1. Cross-namespace bridge: service_commerce:path#service <- tenancy_access:path#service
//  2. Permission bridges: service_commerce:path#perm <- service_commerce:path#service
func BuildServiceInheritanceTuples(tenancyPath string) []security.RelationTuple {
	servicePermissions := RolePermissions[RoleService]
	tuples := make([]security.RelationTuple, 0, 1+len(servicePermissions))

	// Cross-namespace bridge: service_commerce#service <- tenancy_access#service
	tuples = append(tuples, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: NamespaceCommerce, ID: tenancyPath},
		Relation: RoleService,
		Subject:  security.SubjectRef{Namespace: NamespaceTenancyAccess, ID: tenancyPath, Relation: RoleService},
	})

	// Permission bridges: service_commerce#perm <- service_commerce#service
	for _, perm := range servicePermissions {
		tuples = append(tuples, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: NamespaceCommerce, ID: tenancyPath},
			Relation: perm,
			Subject:  security.SubjectRef{Namespace: NamespaceCommerce, ID: tenancyPath, Relation: RoleService},
		})
	}

	return tuples
}
