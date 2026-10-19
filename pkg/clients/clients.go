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

// Package clients builds the typed Connect clients commerce uses to reach its
// peers. Every client is constructed once at startup with its auth and
// timeout settings resolved from configuration; call sites pass the request
// context and let the client enforce deadlines.
package clients

import (
	"context"
	"fmt"

	"buf.build/gen/go/antinvestor/device/connectrpc/go/device/v1/devicev1connect"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v1/ledgerv1connect"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/checkout/v1/checkoutv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	"buf.build/gen/go/antinvestor/settingz/connectrpc/go/settings/v1/settingsv1connect"
	"buf.build/gen/go/antinvestor/workflow/connectrpc/go/v1/workflowv1connect"
	"github.com/antinvestor/common/notification"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-commerce/apps/default/config"
)

// Outbound deadlines are owned by the shared connection layer, which builds
// each client with the platform's default HTTP timeouts and retry policy.
// Nothing here adds per-call budgets.

// Platform holds every peer client. A nil client means that peer is not
// configured and the feature degrades gracefully.
type Platform struct {
	Checkout     checkoutv1connect.CheckoutServiceClient
	Ledger       ledgerv1connect.LedgerServiceClient
	Notification notification.Sender
	Settings     settingsv1connect.SettingsServiceClient
	Devices      devicev1connect.DeviceServiceClient
	Profiles     profilev1connect.ProfileServiceClient
}

// New builds the platform clients that have an endpoint configured.
func New(ctx context.Context, cfg *aconfig.CommerceConfig) (*Platform, error) {
	p := &Platform{}
	log := util.Log(ctx)

	if cfg.CheckoutEnabled() {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceCheckout,
			Endpoint:              cfg.CheckoutServiceURI,
			WorkloadAPITargetPath: cfg.CheckoutServiceWorkloadAPITargetPath,
		}, checkoutv1connect.NewCheckoutServiceClient)
		if err != nil {
			return nil, fmt.Errorf("checkout client: %w", err)
		}
		p.Checkout = cli
	} else {
		log.Warn("checkout service not configured; orders cannot be paid online")
	}

	if cfg.LedgerEnabled() {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceLedger,
			Endpoint:              cfg.LedgerServiceURI,
			WorkloadAPITargetPath: cfg.LedgerServiceWorkloadAPITargetPath,
		}, ledgerv1connect.NewLedgerServiceClient)
		if err != nil {
			return nil, fmt.Errorf("ledger client: %w", err)
		}
		p.Ledger = cli
	} else {
		log.Warn("ledger service not configured; end-of-day posting is disabled")
	}

	if cfg.NotificationsEnabled() {
		cli, err := notification.NewClient(ctx, cfg, NotificationTarget(cfg))
		if err != nil {
			return nil, fmt.Errorf("notification client: %w", err)
		}
		p.Notification = notification.NewSender(cli)
	} else {
		log.Warn("notification service not configured; buyer and seller messages are disabled")
	}

	if err := addCurrencySources(ctx, cfg, p); err != nil {
		return nil, err
	}

	return p, nil
}

// addCurrencySources builds the profile-side clients a caller's default
// currency is read from. Any of them may be absent.
func addCurrencySources(ctx context.Context, cfg *aconfig.CommerceConfig, p *Platform) error {
	if cfg.SettingsServiceURI != "" {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceSettings,
			Endpoint:              cfg.SettingsServiceURI,
			WorkloadAPITargetPath: cfg.SettingsServiceWorkloadAPITargetPath,
		}, settingsv1connect.NewSettingsServiceClient)
		if err != nil {
			return fmt.Errorf("settings client: %w", err)
		}
		p.Settings = cli
	}

	if cfg.DeviceServiceURI != "" {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceDevices,
			Endpoint:              cfg.DeviceServiceURI,
			WorkloadAPITargetPath: cfg.DeviceServiceWorkloadAPITargetPath,
		}, devicev1connect.NewDeviceServiceClient)
		if err != nil {
			return fmt.Errorf("device client: %w", err)
		}
		p.Devices = cli
	}

	if cfg.ProfileServiceURI != "" {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceProfile,
			Endpoint:              cfg.ProfileServiceURI,
			WorkloadAPITargetPath: cfg.ProfileServiceWorkloadAPITargetPath,
		}, profilev1connect.NewProfileServiceClient)
		if err != nil {
			return fmt.Errorf("profile client: %w", err)
		}
		p.Profiles = cli
	}

	if p.Settings == nil && p.Devices == nil && p.Profiles == nil {
		util.Log(ctx).Warn("no profile services configured; new shops default to the platform currency")
	}
	return nil
}

// NotificationTarget describes the notification service for the shared
// template sync and client helpers.
func NotificationTarget(cfg *aconfig.CommerceConfig) notification.Target {
	return notification.Target{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
	}
}

// NewWorkflowClient builds the trustage client the setup job registers
// scheduled workflows with. It returns nil when trustage is not configured;
// the sync then logs and skips. The runtime never talks to trustage.
func NewWorkflowClient(
	ctx context.Context,
	cfg *aconfig.CommerceConfig,
) (workflowv1connect.WorkflowServiceClient, error) {
	if !cfg.TrustageEnabled() {
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
