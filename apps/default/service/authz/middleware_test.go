package authz_test

import (
	"context"
	"fmt"
	"net/url"
	"testing"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/tests/testketo"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	"github.com/stretchr/testify/suite"
)

const (
	testTenantID    = "tenant1"
	testPartitionID = "partition1"
)

var testTenancyPath = fmt.Sprintf("%s/%s", testTenantID, testPartitionID)

// ---------------------------------------------------------------------------
// Test suite with real Keto
// ---------------------------------------------------------------------------

type MiddlewareTestSuite struct {
	frametests.FrameBaseTestSuite
	ketoReadURI  string
	ketoWriteURI string
}

func initMiddlewareResources(_ context.Context) []definition.TestResource {
	pg := testpostgres.NewWithOpts("authz_middleware_test",
		definition.WithUserName("ant"),
		definition.WithCredential("s3cr3t"),
		definition.WithEnableLogging(false),
		definition.WithUseHostMode(false),
	)
	keto := testketo.NewWithOpts(
		definition.WithDependancies(pg),
		definition.WithEnableLogging(false),
	)
	return []definition.TestResource{pg, keto}
}

func (s *MiddlewareTestSuite) SetupSuite() {
	s.InitResourceFunc = initMiddlewareResources
	s.FrameBaseTestSuite.SetupSuite()

	ctx := s.T().Context()
	var ketoDep definition.DependancyConn
	for _, res := range s.Resources() {
		if res.Name() == testketo.ImageName {
			ketoDep = res
			break
		}
	}
	s.Require().NotNil(ketoDep, "keto dependency should be available")

	writeURL, err := url.Parse(string(ketoDep.GetDS(ctx)))
	s.Require().NoError(err)
	s.ketoWriteURI = writeURL.Host

	readPort, err := ketoDep.PortMapping(ctx, "4466/tcp")
	s.Require().NoError(err)
	s.ketoReadURI = fmt.Sprintf("%s:%s", writeURL.Hostname(), readPort)
}

func (s *MiddlewareTestSuite) newAuthorizer() security.Authorizer {
	cfg := &config.ConfigurationDefault{
		AuthorizationServiceReadURI:  s.ketoReadURI,
		AuthorizationServiceWriteURI: s.ketoWriteURI,
	}
	return authorizer.NewKetoAdapter(cfg, nil)
}

func (s *MiddlewareTestSuite) ctxWithClaims(subjectID string) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    testTenantID,
		PartitionID: testPartitionID,
	}
	claims.Subject = subjectID
	return claims.ClaimsToContext(context.Background())
}

func (s *MiddlewareTestSuite) ctxWithSystemInternalClaims(subjectID string) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    testTenantID,
		PartitionID: testPartitionID,
		Roles:       []string{"system_internal"},
	}
	claims.Subject = subjectID
	return claims.ClaimsToContext(context.Background())
}

// seedRole writes functional permission tuples in service_commerce namespace.
func (s *MiddlewareTestSuite) seedRole(auth security.Authorizer, tenancyPath, profileID, role string) {
	permissions := authz.RolePermissions[role]
	tuples := make([]security.RelationTuple, 0, 1+len(permissions))

	tuples = append(tuples, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: authz.NamespaceCommerce, ID: tenancyPath},
		Relation: role,
		Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: profileID},
	})

	for _, perm := range permissions {
		tuples = append(tuples, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: authz.NamespaceCommerce, ID: tenancyPath},
			Relation: perm,
			Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: profileID},
		})
	}

	err := auth.WriteTuples(s.T().Context(), tuples)
	s.Require().NoError(err)
}

func TestMiddlewareSuite(t *testing.T) {
	suite.Run(t, new(MiddlewareTestSuite))
}

// ---------------------------------------------------------------------------
// FunctionChecker (middleware) tests — only checks service_commerce permissions
// ---------------------------------------------------------------------------

func (s *MiddlewareTestSuite) TestOwnerHasAllPermissions() {
	auth := s.newAuthorizer()
	s.seedRole(auth, testTenancyPath, "user1", authz.RoleOwner)

	mw := authz.NewMiddleware(auth)
	ctx := s.ctxWithClaims("user1")

	s.NoError(mw.CanCreateShop(ctx))
	s.NoError(mw.CanViewShops(ctx))
}

func (s *MiddlewareTestSuite) TestAdminPermissions() {
	auth := s.newAuthorizer()
	s.seedRole(auth, testTenancyPath, "user2", authz.RoleAdmin)

	mw := authz.NewMiddleware(auth)
	ctx := s.ctxWithClaims("user2")

	s.NoError(mw.CanCreateShop(ctx))
	s.NoError(mw.CanViewShops(ctx))
}

func (s *MiddlewareTestSuite) TestMemberPermissions() {
	auth := s.newAuthorizer()
	s.seedRole(auth, testTenancyPath, "user3", authz.RoleMember)

	mw := authz.NewMiddleware(auth)
	ctx := s.ctxWithClaims("user3")

	// Member can view shops
	s.NoError(mw.CanViewShops(ctx))

	// Member cannot create shops
	s.Error(mw.CanCreateShop(ctx))
}

func (s *MiddlewareTestSuite) TestNoClaims() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	err := mw.CanViewShops(context.Background())
	s.ErrorIs(err, authorizer.ErrInvalidSubject)
}

func (s *MiddlewareTestSuite) TestNoTenant() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	claims := &security.AuthenticationClaims{}
	claims.Subject = "user1"
	ctx := claims.ClaimsToContext(context.Background())
	err := mw.CanViewShops(ctx)
	s.ErrorIs(err, authorizer.ErrInvalidObject)
}

// ---------------------------------------------------------------------------
// TenancyAccessChecker tests — data access layer
// ---------------------------------------------------------------------------

func (s *MiddlewareTestSuite) TestAccessChecker_MemberAllowed() {
	auth := s.newAuthorizer()
	checker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	// Seed member tuple in tenancy_access
	err := auth.WriteTuple(s.T().Context(), authz.BuildAccessTuple(testTenancyPath, "member-user"))
	s.Require().NoError(err)

	ctx := s.ctxWithClaims("member-user")
	s.NoError(checker.CheckAccess(ctx))
}

func (s *MiddlewareTestSuite) TestAccessChecker_ServiceBotAllowed() {
	auth := s.newAuthorizer()
	checker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	// Seed service tuple in tenancy_access
	err := auth.WriteTuple(s.T().Context(), authz.BuildServiceAccessTuple(testTenancyPath, "bot-user"))
	s.Require().NoError(err)

	ctx := s.ctxWithSystemInternalClaims("bot-user")
	s.NoError(checker.CheckAccess(ctx))
}

func (s *MiddlewareTestSuite) TestAccessChecker_NoTupleDenied() {
	auth := s.newAuthorizer()
	checker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	ctx := s.ctxWithClaims("unknown-user")
	s.Error(checker.CheckAccess(ctx))
}

// ---------------------------------------------------------------------------
// Service bot via subject sets — full two-layer check
// ---------------------------------------------------------------------------

func (s *MiddlewareTestSuite) seedServiceBridgeTuples(auth security.Authorizer, tenancyPath string) {
	tuples := authz.BuildServiceInheritanceTuples(tenancyPath)
	err := auth.WriteTuples(s.T().Context(), tuples)
	s.Require().NoError(err)
}

func (s *MiddlewareTestSuite) TestServiceBotViaSubjectSets() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)
	accessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	// Step 1: Write bridge tuples (normally done at partition sync).
	s.seedServiceBridgeTuples(auth, testTenancyPath)

	// Step 2: Grant the bot service access in tenancy_access.
	err := auth.WriteTuple(s.T().Context(), authz.BuildServiceAccessTuple(testTenancyPath, "service-bot"))
	s.Require().NoError(err)

	botCtx := s.ctxWithSystemInternalClaims("service-bot")

	// Layer 1: Access check passes
	s.NoError(accessChecker.CheckAccess(botCtx))

	// Layer 2: Functional permissions resolved through subject sets
	s.NoError(mw.CanCreateShop(botCtx))
	s.NoError(mw.CanViewShops(botCtx))
}

func (s *MiddlewareTestSuite) TestDirectPermissionGrant() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	// User has a direct permission grant for create_shop only
	err := auth.WriteTuple(s.T().Context(), security.RelationTuple{
		Object:   security.ObjectRef{Namespace: authz.NamespaceCommerce, ID: testTenancyPath},
		Relation: authz.PermissionCreateShop,
		Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: "user4"},
	})
	s.Require().NoError(err)

	ctx := s.ctxWithClaims("user4")

	// Direct grant works
	s.NoError(mw.CanCreateShop(ctx))

	// view_shops inherits from create_shop in OPL, but since we materialise permissions,
	// the user only has create_shop. view_shops requires its own tuple.
	s.Error(mw.CanViewShops(ctx))
}

// ---------------------------------------------------------------------------
// Shop-level ReBAC tests
// ---------------------------------------------------------------------------

// seedShopPermissions writes direct permission tuples for shop-level checks.
// The Keto v1alpha2 gRPC Check API checks direct relation tuples, not OPL permits,
// so we materialise the permission tuples explicitly.
func (s *MiddlewareTestSuite) seedShopPermissions(auth security.Authorizer, shopID, profileID string, permissions []string) {
	tuples := make([]security.RelationTuple, len(permissions))
	for i, perm := range permissions {
		tuples[i] = security.RelationTuple{
			Object:   security.ObjectRef{Namespace: authz.NamespaceShop, ID: shopID},
			Relation: perm,
			Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: profileID},
		}
	}
	err := auth.WriteTuples(s.T().Context(), tuples)
	s.Require().NoError(err)
}

func (s *MiddlewareTestSuite) TestShopOwnerHasAllPermissions() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	shopID := "shop-1"
	ownerPermissions := []string{
		authz.PermissionView, authz.PermissionUpdate,
		authz.PermissionManageProducts, authz.PermissionViewProducts,
		authz.PermissionManageOrders, authz.PermissionViewOrders,
		authz.PermissionManageFulfilment,
	}
	s.seedShopPermissions(auth, shopID, "shop-owner", ownerPermissions)

	ctx := s.ctxWithClaims("shop-owner")

	s.NoError(mw.CanViewShop(ctx, shopID))
	s.NoError(mw.CanUpdateShop(ctx, shopID))
	s.NoError(mw.CanManageProducts(ctx, shopID))
	s.NoError(mw.CanViewProducts(ctx, shopID))
	s.NoError(mw.CanManageOrders(ctx, shopID))
	s.NoError(mw.CanViewOrders(ctx, shopID))
	s.NoError(mw.CanManageFulfilment(ctx, shopID))
}

func (s *MiddlewareTestSuite) TestShopViewerPermissions() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	shopID := "shop-2"
	viewerPermissions := []string{
		authz.PermissionView, authz.PermissionViewProducts, authz.PermissionViewOrders,
	}
	s.seedShopPermissions(auth, shopID, "shop-viewer", viewerPermissions)

	ctx := s.ctxWithClaims("shop-viewer")

	// Viewer can view
	s.NoError(mw.CanViewShop(ctx, shopID))
	s.NoError(mw.CanViewProducts(ctx, shopID))
	s.NoError(mw.CanViewOrders(ctx, shopID))

	// Viewer cannot manage
	s.Error(mw.CanUpdateShop(ctx, shopID))
	s.Error(mw.CanManageProducts(ctx, shopID))
	s.Error(mw.CanManageOrders(ctx, shopID))
	s.Error(mw.CanManageFulfilment(ctx, shopID))
}
