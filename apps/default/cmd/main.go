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
	"net/http"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/notification"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-commerce/apps/default/config"
	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/service/business"
	"github.com/antinvestor/service-commerce/apps/default/service/handlers"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/apps/default/service/workflows"
	commercepb "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"
	"github.com/antinvestor/service-commerce/pkg/clients"
	"github.com/antinvestor/service-commerce/pkg/dbmigrate"
	"github.com/antinvestor/service-commerce/pkg/dbrole"
	"github.com/antinvestor/service-commerce/pkg/messages"
	workflowdefs "github.com/antinvestor/service-commerce/workflows"
)

func main() {
	ctx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.CommerceConfig](ctx)
	if err != nil {
		util.Log(ctx).WithError(err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_commerce"
	}

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

	// Setup Job: migrate, publish the permission manifest, register
	// notification templates, and register scheduled workflows. Then exit.
	commerceSD := commercepb.File_v1_commerce_proto.Services().ByName("CommerceService")
	if frame.ShouldRunSetup(&cfg) {
		notification.RegisterTemplateSync(svc, &cfg, clients.NotificationTarget(&cfg), messages.Registry())

		// Only the trustage client is needed here; the runtime peers are
		// built after the setup early return.
		trustage, trustageErr := clients.NewWorkflowClient(ctx, &cfg)
		if trustageErr != nil {
			log.WithError(trustageErr).Fatal("could not build the trustage client for setup")
		}
		workflows.RegisterSync(svc, trustage, workflowdefs.Definitions(), workflows.Env{
			CommerceURI: cfg.CommerceServiceURI,
		})

		svc.Init(ctx, frame.WithPermissionRegistration(commerceSD))
		if setupErr := svc.RunSetupForProcess(ctx, &cfg); setupErr != nil {
			util.Log(ctx).WithError(setupErr).Fatal("setup plan failed")
		}
		log.Info("setup plan complete — exiting")
		return
	}

	// Runtime: HTTP only, no permission registration.
	if cfgErr := cfg.Validate(); cfgErr != nil {
		log.WithError(cfgErr).Fatal("configuration is not deployment-safe")
	}
	dbrole.MustVerify(ctx, svc.DatastoreManager())
	// A query that names no tenant is refused from here on; only the
	// scheduled sweeps, the storefront slug lookup and the payment return
	// page read across tenants, explicitly.
	if tenancyErr := dbrole.FailClosed(svc); tenancyErr != nil {
		log.WithError(tenancyErr).Fatal("could not enforce tenant isolation")
	}

	platform, err := clients.New(ctx, &cfg)
	if err != nil {
		log.WithError(err).Fatal("could not build peer clients")
	}

	connectHandler := setupConnectServer(ctx, svc, &cfg, platform)
	svc.Init(ctx, frame.WithHTTPHandler(connectHandler))

	if runErr := svc.Run(ctx, ""); runErr != nil {
		log.WithError(runErr).Fatal("could not run Server")
	}
}

// setupConnectServer wires the interceptor chain and the Connect handler.
func setupConnectServer(
	ctx context.Context,
	svc *frame.Service,
	cfg *aconfig.CommerceConfig,
	platform *clients.Platform,
) http.Handler {
	securityMan := svc.SecurityManager()
	auth := securityMan.GetAuthorizer(ctx)

	// Layer 1: caller may access the partition.
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	// Layer 2: per-RPC functional permission from the proto annotations.
	sd := commercepb.File_v1_commerce_proto.Services().ByName("CommerceService")
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

	// Layer 3: per-shop and per-record checks inside the handlers.
	authzMiddleware := authz.NewMiddleware(auth)

	var checkout business.CheckoutGateway
	if platform.Checkout != nil {
		checkout = business.NewConnectCheckoutGateway(platform.Checkout)
	}
	var ledger business.LedgerGateway
	if platform.Ledger != nil {
		ledger = business.NewConnectLedgerGateway(platform.Ledger)
	}

	// Typed nils must not reach the directory as non-nil interfaces.
	var (
		settingsCli business.SettingsClient
		devicesCli  business.DeviceClient
		profilesCli business.ProfileClient
	)
	if platform.Settings != nil {
		settingsCli = platform.Settings
	}
	if platform.Devices != nil {
		devicesCli = platform.Devices
	}
	if platform.Profiles != nil {
		profilesCli = platform.Profiles
	}

	secrets, err := business.NewSecretBox(cfg.WebhookSecretKey)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("invalid WEBHOOK_SECRET_KEY")
	}
	if !business.Sealing(secrets) {
		util.Log(ctx).Warn("WEBHOOK_SECRET_KEY not set; shop webhook secrets are stored unencrypted (local runs only)")
	}

	implementation := handlers.NewCommerceServer(ctx, svc, authzMiddleware, handlers.Dependencies{
		Checkout:   checkout,
		Ledger:     ledger,
		Currencies: business.NewConnectCurrencyDirectory(settingsCli, devicesCli, profilesCli),
		Webhooks:   business.NewHTTPWebhookSender(ctx),
		Secrets:    secrets,
		Notifier:   notifications.New(platform.Notification),
		PaymentPolicy: business.PaymentPolicy{
			DefaultReturnURL:   cfg.CheckoutReturnURL,
			ReturnBaseURL:      cfg.ReturnBaseURL(),
			PaymentWindow:      cfg.OrderPaymentWindow,
			SettleGrace:        cfg.PaymentSettleGrace,
			ReconcileBatchSize: cfg.PaymentReconcileBatchSize,
		},
		LedgerPolicy: business.LedgerPolicy{
			BookType: cfg.LedgerBookType,
			Timezone: cfg.LedgerTimezone,
		},
		Buyers:            business.NewProfileBuyerDirectory(profilesCli),
		StorefrontBaseURL: cfg.StorefrontURL(),
	})

	server := connect.NewServer(defaultInterceptorList...)
	commercev1connect.RegisterCommerceServiceHandler(server, implementation)

	mux := http.NewServeMux()
	mux.Handle(business.PaymentReturnPath, implementation.PaymentReturnHandler())
	implementation.MountStorefront(mux)
	connecthttp.Mount(mux, server)

	return mux
}
