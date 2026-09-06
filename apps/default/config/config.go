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

package config

import (
	"time"

	"github.com/pitabwire/frame/v2/config"
)

// CommerceConfig extends the Frame defaults with the peer services commerce
// talks to and the commercial policy knobs a deployment tunes.
type CommerceConfig struct {
	config.ConfigurationDefault

	// Peer services. An empty URI disables that integration: checkout falls
	// back to marking orders pending, notifications are skipped, ledger
	// posting reports skipped, and workflow sync is a no-op.
	CheckoutServiceURI                       string `env:"CHECKOUT_SERVICE_URI"                          envDefault:""`
	CheckoutServiceWorkloadAPITargetPath     string `env:"CHECKOUT_SERVICE_WORKLOAD_API_TARGET_PATH"     envDefault:"/ns/payment/sa/service-checkout"`
	LedgerServiceURI                         string `env:"LEDGER_SERVICE_URI"                            envDefault:""`
	LedgerServiceWorkloadAPITargetPath       string `env:"LEDGER_SERVICE_WORKLOAD_API_TARGET_PATH"       envDefault:"/ns/ledger/sa/service-ledger"`
	NotificationServiceURI                   string `env:"NOTIFICATION_SERVICE_URI"                      envDefault:""`
	NotificationServiceWorkloadAPITargetPath string `env:"NOTIFICATION_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/notification/sa/service-notification"`
	TrustageServiceURI                       string `env:"TRUSTAGE_SERVICE_URI"                          envDefault:""`
	TrustageServiceWorkloadAPITargetPath     string `env:"TRUSTAGE_SERVICE_WORKLOAD_API_TARGET_PATH"     envDefault:"/ns/trustage/sa/service-trustage"`

	// Checkout policy.
	// CheckoutReturnURL is where the hosted payment page sends buyers when a
	// shop has not configured its own. {order_id} is substituted.
	CheckoutReturnURL string `env:"CHECKOUT_RETURN_URL" envDefault:""`
	// OrderPaymentWindow is how long a reservation is held for an unpaid
	// order before ReconcilePayments releases the stock.
	OrderPaymentWindow time.Duration `env:"ORDER_PAYMENT_WINDOW" envDefault:"45m"`
	// PaymentReconcileBatchSize caps the orders examined per reconcile run.
	PaymentReconcileBatchSize int `env:"PAYMENT_RECONCILE_BATCH_SIZE" envDefault:"200"`

	// Ledger policy.
	// LedgerBookType is the book type each shop's book is created under.
	LedgerBookType string `env:"LEDGER_BOOK_TYPE" envDefault:"merchant"`
	// LedgerTimezone is the trading-day boundary used by end-of-day posting
	// when a shop has no timezone of its own.
	LedgerTimezone string `env:"LEDGER_TIMEZONE" envDefault:"Africa/Nairobi"`

	// WorkflowsPath holds the trustage workflow DSL files synced by the
	// setup job.
	WorkflowsPath string `env:"WORKFLOWS_PATH" envDefault:"./workflows"`
	// CommerceServiceURI is the address trustage calls back into for
	// scheduled runs; substituted into the workflow DSL as env.commerce_uri.
	CommerceServiceURI string `env:"COMMERCE_SERVICE_URI" envDefault:""`
}

// CheckoutEnabled reports whether hosted checkout is wired.
func (c *CommerceConfig) CheckoutEnabled() bool { return c.CheckoutServiceURI != "" }

// LedgerEnabled reports whether end-of-day posting is wired.
func (c *CommerceConfig) LedgerEnabled() bool { return c.LedgerServiceURI != "" }

// NotificationsEnabled reports whether buyer and seller messages are wired.
func (c *CommerceConfig) NotificationsEnabled() bool { return c.NotificationServiceURI != "" }

// TrustageEnabled reports whether scheduled workflows are wired.
func (c *CommerceConfig) TrustageEnabled() bool { return c.TrustageServiceURI != "" }
