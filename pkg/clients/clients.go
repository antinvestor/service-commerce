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

	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v1/ledgerv1connect"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/checkout/v1/checkoutv1connect"
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
	Workflow     workflowv1connect.WorkflowServiceClient
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

	if cfg.TrustageEnabled() {
		cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
			ServiceID:             servicecatalog.ServiceTrustage,
			Endpoint:              cfg.TrustageServiceURI,
			WorkloadAPITargetPath: cfg.TrustageServiceWorkloadAPITargetPath,
		}, workflowv1connect.NewWorkflowServiceClient)
		if err != nil {
			return nil, fmt.Errorf("workflow client: %w", err)
		}
		p.Workflow = cli
	}

	return p, nil
}

// NotificationTarget describes the notification service for the shared
// template sync and client helpers.
func NotificationTarget(cfg *aconfig.CommerceConfig) notification.Target {
	return notification.Target{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
	}
}
