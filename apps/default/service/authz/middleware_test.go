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

package authz_test

import (
	"context"
	"fmt"
	"net/url"
	"testing"

	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/tests/testketo"
)

const (
	testTenantID    = "tenant1"
	testPartitionID = "partition1"
	testTenancyPath = testTenantID + "/" + testPartitionID
)

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
		Roles:       []string{"internal"},
	}
	claims.Subject = subjectID
	return claims.ClaimsToContext(context.Background())
}

func TestMiddlewareSuite(t *testing.T) {
	suite.Run(t, new(MiddlewareTestSuite))
}

// ---------------------------------------------------------------------------
// Shop-level middleware tests — tenant-level checks are now handled by
// the FunctionAccessInterceptor, so we only test shop-level ReBAC here.
// ---------------------------------------------------------------------------

func (s *MiddlewareTestSuite) TestNoClaims() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	err := mw.CanShopView(context.Background(), "shop-1")
	s.ErrorIs(err, authorizer.ErrInvalidSubject)
}

func (s *MiddlewareTestSuite) TestNoSubject() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	claims := &security.AuthenticationClaims{}
	ctx := claims.ClaimsToContext(context.Background())
	err := mw.CanShopView(ctx, "shop-1")
	s.ErrorIs(err, authorizer.ErrInvalidSubject)
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
	s.Require().NoError(checker.CheckAccess(ctx))
}

func (s *MiddlewareTestSuite) TestAccessChecker_ServiceBotAllowed() {
	auth := s.newAuthorizer()
	checker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	// Seed service tuple in tenancy_access
	err := auth.WriteTuple(s.T().Context(), authz.BuildServiceAccessTuple(testTenancyPath, "bot-user"))
	s.Require().NoError(err)

	ctx := s.ctxWithSystemInternalClaims("bot-user")
	s.Require().NoError(checker.CheckAccess(ctx))
}

func (s *MiddlewareTestSuite) TestAccessChecker_NoTupleDenied() {
	auth := s.newAuthorizer()
	checker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	ctx := s.ctxWithClaims("unknown-user")
	s.Require().Error(checker.CheckAccess(ctx))
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
	accessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)

	// Step 1: Write bridge tuples (normally done at partition sync).
	s.seedServiceBridgeTuples(auth, testTenancyPath)

	// Step 2: Grant the bot service access in tenancy_access.
	err := auth.WriteTuple(s.T().Context(), authz.BuildServiceAccessTuple(testTenancyPath, "service-bot"))
	s.Require().NoError(err)

	botCtx := s.ctxWithSystemInternalClaims("service-bot")

	// Layer 1: Access check passes
	s.Require().NoError(accessChecker.CheckAccess(botCtx))

	// Note: Tenant-level functional permissions (shop_create, shops_view)
	// are now checked by the FunctionAccessInterceptor, not the middleware.
}

func (s *MiddlewareTestSuite) TestDirectPermissionGrant() {
	auth := s.newAuthorizer()

	// Direct permission grants for tenant-level permissions (shop_create, shops_view)
	// are now verified by the FunctionAccessInterceptor, not the middleware.
	// Here we verify a direct shop-level grant works through the middleware.
	shopID := "shop-direct-grant"
	err := auth.WriteTuple(s.T().Context(), security.RelationTuple{
		Object:   security.ObjectRef{Namespace: authz.NamespaceShop, ID: shopID},
		Relation: authz.GrantedRelation(authz.PermissionShopView),
		Subject:  security.SubjectRef{Namespace: authz.NamespaceProfile, ID: "user4"},
	})
	s.Require().NoError(err)

	mw := authz.NewMiddleware(auth)
	ctx := s.ctxWithClaims("user4")

	s.Require().NoError(mw.CanShopView(ctx, shopID))
}

// ---------------------------------------------------------------------------
// Shop-level ReBAC tests
// ---------------------------------------------------------------------------

// seedShopPermissions writes direct permission tuples for shop-level checks.
// This tests direct permission grants at the resource level using granted_ prefix.
func (s *MiddlewareTestSuite) seedShopPermissions(
	auth security.Authorizer,
	shopID, profileID string,
	permissions []string,
) {
	tuples := make([]security.RelationTuple, len(permissions))
	for i, perm := range permissions {
		tuples[i] = security.RelationTuple{
			Object:   security.ObjectRef{Namespace: authz.NamespaceShop, ID: shopID},
			Relation: authz.GrantedRelation(perm),
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
		authz.PermissionShopView, authz.PermissionShopUpdate,
		authz.PermissionProductsManage, authz.PermissionProductsView,
		authz.PermissionOrdersManage, authz.PermissionOrdersView,
		authz.PermissionFulfilmentManage,
	}
	s.seedShopPermissions(auth, shopID, "shop-owner", ownerPermissions)

	ctx := s.ctxWithClaims("shop-owner")

	s.Require().NoError(mw.CanShopView(ctx, shopID))
	s.Require().NoError(mw.CanShopUpdate(ctx, shopID))
	s.Require().NoError(mw.CanProductsManage(ctx, shopID))
	s.Require().NoError(mw.CanProductsView(ctx, shopID))
	s.Require().NoError(mw.CanOrdersManage(ctx, shopID))
	s.Require().NoError(mw.CanOrdersView(ctx, shopID))
	s.Require().NoError(mw.CanFulfilmentManage(ctx, shopID))
}

func (s *MiddlewareTestSuite) TestShopViewerPermissions() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	shopID := "shop-2"
	viewerPermissions := []string{
		authz.PermissionShopView, authz.PermissionProductsView, authz.PermissionOrdersView,
	}
	s.seedShopPermissions(auth, shopID, "shop-viewer", viewerPermissions)

	ctx := s.ctxWithClaims("shop-viewer")

	// Viewer can view
	s.Require().NoError(mw.CanShopView(ctx, shopID))
	s.Require().NoError(mw.CanProductsView(ctx, shopID))
	s.Require().NoError(mw.CanOrdersView(ctx, shopID))

	// Viewer cannot manage
	s.Require().Error(mw.CanShopUpdate(ctx, shopID))
	s.Require().Error(mw.CanProductsManage(ctx, shopID))
	s.Require().Error(mw.CanOrdersManage(ctx, shopID))
	s.Require().Error(mw.CanFulfilmentManage(ctx, shopID))
}
