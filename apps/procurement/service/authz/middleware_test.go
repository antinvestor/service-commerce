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

	"github.com/antinvestor/service-commerce/apps/procurement/service/authz"
	"github.com/antinvestor/service-commerce/apps/procurement/tests/testketo"
)

const (
	testTenantID    = "tenant1"
	testPartitionID = "partition1"
)

type MiddlewareTestSuite struct {
	frametests.FrameBaseTestSuite
	ketoReadURI  string
	ketoWriteURI string
}

func initMiddlewareResources(_ context.Context) []definition.TestResource {
	pg := testpostgres.NewWithOpts("authz_procurement_test",
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

func TestMiddlewareSuite(t *testing.T) {
	suite.Run(t, new(MiddlewareTestSuite))
}

func (s *MiddlewareTestSuite) TestNoSubjectDenied() {
	mw := authz.NewMiddleware(s.newAuthorizer())

	// No claims at all.
	err := mw.CanPurchaseOrderManage(context.Background(), "property-x")
	s.Require().ErrorIs(err, authorizer.ErrInvalidSubject)

	// Claims present but empty subject.
	emptyClaims := &security.AuthenticationClaims{}
	err = mw.CanPurchaseOrderManage(emptyClaims.ClaimsToContext(context.Background()), "property-x")
	s.Require().ErrorIs(err, authorizer.ErrInvalidSubject)
}

// TestOwnerGrantedPropertyPermissions verifies the owner relation resolves all
// property-level permits via the OPL.
func (s *MiddlewareTestSuite) TestOwnerGrantedPropertyPermissions() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	propertyID := "property-owned"
	s.Require().NoError(mw.AddPropertyMember(s.T().Context(), propertyID, "owner-user", authz.RoleOwner))

	ctx := s.ctxWithClaims("owner-user")
	s.Require().NoError(mw.CanPurchaseOrderManage(ctx, propertyID))
	s.Require().NoError(mw.CanPurchaseOrderView(ctx, propertyID))
	s.Require().NoError(mw.CanGoodsReceiptManage(ctx, propertyID))
	s.Require().NoError(mw.CanGoodsReceiptView(ctx, propertyID))
	s.Require().NoError(mw.CanPropertyView(ctx, propertyID))
}

// TestCrossPropertyDenied verifies a user who owns one property is denied on a
// different property.
func (s *MiddlewareTestSuite) TestCrossPropertyDenied() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	owned := "property-A"
	other := "property-B"
	s.Require().NoError(mw.AddPropertyMember(s.T().Context(), owned, "user-A", authz.RoleOwner))

	ctx := s.ctxWithClaims("user-A")

	// Allowed on the owned property.
	s.Require().NoError(mw.CanPurchaseOrderManage(ctx, owned))

	// Denied on a different property the user has no relation to.
	s.Require().Error(mw.CanPurchaseOrderManage(ctx, other))
	s.Require().Error(mw.CanGoodsReceiptManage(ctx, other))
	s.Require().Error(mw.CanPurchaseOrderView(ctx, other))
}

// TestViewerCannotManage verifies the viewer role can view but not manage.
func (s *MiddlewareTestSuite) TestViewerCannotManage() {
	auth := s.newAuthorizer()
	mw := authz.NewMiddleware(auth)

	propertyID := "property-viewer"
	s.Require().NoError(mw.AddPropertyMember(s.T().Context(), propertyID, "viewer-user", authz.RoleViewer))

	ctx := s.ctxWithClaims("viewer-user")
	s.Require().NoError(mw.CanPurchaseOrderView(ctx, propertyID))
	s.Require().NoError(mw.CanGoodsReceiptView(ctx, propertyID))
	s.Require().Error(mw.CanPurchaseOrderManage(ctx, propertyID))
	s.Require().Error(mw.CanGoodsReceiptManage(ctx, propertyID))
}
