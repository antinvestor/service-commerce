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

package main

import (
	"context"
	"fmt"
	"net/http"

	"buf.build/gen/go/antinvestor/manufacturing/connectrpc/go/v2/v1/manufacturingv1connect"
	"buf.build/gen/go/antinvestor/workflow/connectrpc/go/v2/v1/workflowv1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"
	procurementpb "github.com/antinvestor/service-commerce/gen/go/procurement/v1"
	"github.com/antinvestor/service-commerce/gen/go/procurement/v1/procurementv1connect"

	aconfig "github.com/antinvestor/service-commerce/apps/procurement/config"
	"github.com/antinvestor/service-commerce/apps/procurement/service/authz"
	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/handlers"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/antinvestor/service-commerce/pkg/dbmigrate"
	"github.com/antinvestor/service-commerce/pkg/dbrole"
	"github.com/antinvestor/service-commerce/pkg/workflows"
	procurementworkflows "github.com/antinvestor/service-commerce/workflows/procurement"
)

func main() {
	ctx := context.Background()

	// Initialize configuration
	cfg, err := config.LoadWithOIDC[aconfig.ProcurementConfig](ctx)
	if err != nil {
		util.Log(ctx).WithError(err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_procurement"
	}

	// Create service
	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)

	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
		return repository.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
	})
	svc.Setup().RegisterFunc(dbrole.StepName, dbrole.Step(svc.DatastoreManager()))
	defer svc.Stop(ctx)
	log := svc.Log(ctx)

	// Frame keeps an empty pool when the database cannot be reached; stop
	// here rather than build repositories or migrate on it.
	if dbErr := dbmigrate.Ready(ctx, svc); dbErr != nil {
		log.WithError(dbErr).Fatal("database is unavailable; check DATABASE_URL and the database provider's status")
	}

	// Setup Job: migrate, publish the permission manifest and register the
	// scheduled workflows (no HTTP/runtime wiring).
	procurementSD := procurementpb.File_v1_procurement_proto.Services().ByName("ProcurementService")
	if frame.ShouldRunSetup(&cfg) {
		trustage, trustageErr := newWorkflowClient(ctx, &cfg)
		if trustageErr != nil {
			log.WithError(trustageErr).Fatal("could not build the trustage client for setup")
		}
		workflows.RegisterSync(svc, trustage, procurementworkflows.Definitions(), workflows.Env{
			Owner: &workflows.Owner{
				Prefix:      "procurement.",
				Placeholder: "${PROCUREMENT_URI}",
				URI:         cfg.ProcurementServiceURI,
				URIVariable: "PROCUREMENT_SERVICE_URI",
			},
		})
		svc.Init(ctx, frame.WithPermissionRegistration(procurementSD))
		if setupErr := svc.RunSetupForProcess(ctx, &cfg); setupErr != nil {
			util.Log(ctx).WithError(setupErr).Fatal("setup plan failed")
		}
		log.Info("setup plan complete — exiting")
		return
	}

	// Runtime: HTTP only — no WithPermissionRegistration.
	dbrole.MustVerify(ctx, svc.DatastoreManager())
	// Every procurement call carries its caller's tenant; a query that names
	// none is refused.
	if tenancyErr := dbrole.FailClosed(svc); tenancyErr != nil {
		log.WithError(tenancyErr).Fatal("could not enforce tenant isolation")
	}
	manufacturing, err := newManufacturingClient(ctx, &cfg)
	if err != nil {
		log.WithError(err).Fatal("could not build the manufacturing client")
	}
	commerce, err := newCommerceClient(ctx, &cfg)
	if err != nil {
		log.WithError(err).Fatal("could not build the commerce client")
	}
	connectHandler := setupConnectServer(ctx, svc,
		business.NewManufacturingMaterialSource(manufacturing),
		business.NewCommerceStockDestination(commerce))
	svc.Init(ctx, frame.WithHTTPHandler(connectHandler))

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

// setupConnectServer initializes and configures the gRPC server.
func setupConnectServer(
	ctx context.Context,
	svc *frame.Service,
	materials business.MaterialSource,
	stock business.StockDestination,
) http.Handler {
	securityMan := svc.SecurityManager()

	auth := securityMan.GetAuthorizer(ctx)

	// Layer 1: TenancyAccessChecker verifies caller can access the partition.
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	// Layer 2: FunctionAccessInterceptor enforces per-RPC permissions from proto annotations.
	sd := procurementpb.File_v1_procurement_proto.Services().ByName("ProcurementService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, securityMan.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	// Property-level permissions middleware.
	authzMiddleware := authz.NewMiddleware(securityMan.GetAuthorizer(ctx))
	implementation := handlers.NewProcurementServer(ctx, svc, authzMiddleware, materials, stock)

	server := connect.NewServer(defaultInterceptorList...)
	procurementv1connect.RegisterProcurementServiceHandler(server, implementation)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	return mux
}

// newManufacturingClient builds the client purchase order suggestions read
// plan shortages through. It returns nil when manufacturing is not
// configured, which leaves suggestions unavailable.
func newManufacturingClient(
	ctx context.Context,
	cfg *aconfig.ProcurementConfig,
) (business.ManufacturingClient, error) {
	if cfg.ManufacturingServiceURI == "" {
		util.Log(ctx).Warn("manufacturing service not configured; purchase order suggestions are unavailable")
		return nil, nil //nolint:nilnil // not configured is a valid state
	}
	cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		ServiceID:             servicecatalog.ServiceManufacturing,
		Endpoint:              cfg.ManufacturingServiceURI,
		WorkloadAPITargetPath: cfg.ManufacturingServiceWorkloadAPITargetPath,
	}, manufacturingv1connect.NewManufacturingServiceClient)
	if err != nil {
		return nil, fmt.Errorf("manufacturing client: %w", err)
	}
	return cli, nil
}

// newCommerceClient builds the client received resale stock is pushed
// through, authenticated as the procurement service itself. It returns nil
// when commerce is not configured, which leaves those lines pending.
func newCommerceClient(
	ctx context.Context,
	cfg *aconfig.ProcurementConfig,
) (business.CommerceStockClient, error) {
	if cfg.CommerceServiceURI == "" {
		util.Log(ctx).Warn("commerce service not configured; received resale stock stays pending")
		return nil, nil //nolint:nilnil // not configured is a valid state
	}
	cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		ServiceID:             servicecatalog.ServiceCommerce,
		Endpoint:              cfg.CommerceServiceURI,
		WorkloadAPITargetPath: cfg.CommerceServiceWorkloadAPITargetPath,
	}, commercev1connect.NewCommerceServiceClient)
	if err != nil {
		return nil, fmt.Errorf("commerce client: %w", err)
	}
	return cli, nil
}

// newWorkflowClient builds the trustage client the setup job registers
// workflows with; nil when trustage is not configured.
func newWorkflowClient(
	ctx context.Context,
	cfg *aconfig.ProcurementConfig,
) (workflows.Client, error) {
	if cfg.TrustageServiceURI == "" {
		return nil, nil //nolint:nilnil // not configured is a valid state
	}
	cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		ServiceID:             servicecatalog.ServiceTrustage,
		Endpoint:              cfg.TrustageServiceURI,
		WorkloadAPITargetPath: cfg.TrustageServiceWorkloadAPITargetPath,
	}, workflowv1connect.NewWorkflowServiceClient)
	if err != nil {
		return nil, fmt.Errorf("workflow client: %w", err)
	}
	return cli, nil
}
