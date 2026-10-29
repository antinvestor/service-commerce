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
	"errors"
	"time"

	"github.com/pitabwire/frame/v3/config"
)

// CommerceConfig extends the Frame defaults with the peer services commerce
// talks to and the commercial policy knobs a deployment tunes.
type CommerceConfig struct {
	config.ConfigurationDefault

	// Peer services. An empty URI disables that integration: checkout falls
	// back to marking orders pending, notifications are skipped, ledger
	// posting reports skipped, and workflow sync is a no-op.
	CheckoutServiceURI                   string `env:"CHECKOUT_SERVICE_URI"                      envDefault:""`
	CheckoutServiceWorkloadAPITargetPath string `env:"CHECKOUT_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/payment/sa/service-checkout"`
	// PaymentServiceURI is the platform payment service refunds are paid out
	// through. Without it refunds are recorded but stay pending.
	PaymentServiceURI                        string `env:"PAYMENT_SERVICE_URI"                           envDefault:""`
	PaymentServiceWorkloadAPITargetPath      string `env:"PAYMENT_SERVICE_WORKLOAD_API_TARGET_PATH"      envDefault:"/ns/payment/sa/service-payment"`
	LedgerServiceURI                         string `env:"LEDGER_SERVICE_URI"                            envDefault:""`
	LedgerServiceWorkloadAPITargetPath       string `env:"LEDGER_SERVICE_WORKLOAD_API_TARGET_PATH"       envDefault:"/ns/ledger/sa/service-ledger"`
	NotificationServiceURI                   string `env:"NOTIFICATION_SERVICE_URI"                      envDefault:""`
	NotificationServiceWorkloadAPITargetPath string `env:"NOTIFICATION_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/notification/sa/service-notification"`
	TrustageServiceURI                       string `env:"TRUSTAGE_SERVICE_URI"                          envDefault:""`
	TrustageServiceWorkloadAPITargetPath     string `env:"TRUSTAGE_SERVICE_WORKLOAD_API_TARGET_PATH"     envDefault:"/ns/trustage/sa/service-trustage"`

	// Where a caller's default currency comes from: their "currency" setting,
	// their device locale, then their profile address. Each is optional.
	SettingsServiceURI                   string `env:"SETTINGS_SERVICE_URI"                      envDefault:""`
	SettingsServiceWorkloadAPITargetPath string `env:"SETTINGS_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/profile/sa/service-settings"`
	DeviceServiceURI                     string `env:"DEVICE_SERVICE_URI"                        envDefault:""`
	DeviceServiceWorkloadAPITargetPath   string `env:"DEVICE_SERVICE_WORKLOAD_API_TARGET_PATH"   envDefault:"/ns/profile/sa/service-devices"`
	ProfileServiceURI                    string `env:"PROFILE_SERVICE_URI"                       envDefault:""`
	ProfileServiceWorkloadAPITargetPath  string `env:"PROFILE_SERVICE_WORKLOAD_API_TARGET_PATH"  envDefault:"/ns/profile/sa/service-profile"`

	// WebhookSecretKey seals shop webhook secrets at rest: base64 of 32
	// random bytes (AES-256-GCM). Keep it in the secret store; rotating it
	// requires shops to set their webhook secrets again.
	WebhookSecretKey string `env:"WEBHOOK_SECRET_KEY" envDefault:""`

	// Checkout policy.
	// CheckoutReturnURL is where the hosted payment page sends buyers when a
	// shop has not configured its own. {order_id} is substituted.
	CheckoutReturnURL string `env:"CHECKOUT_RETURN_URL" envDefault:""`
	// PaymentReturnBaseURL is commerce's public address that hosted checkout
	// returns buyers to (/payments/return), where the payment is verified on
	// arrival. Defaults to CommerceServiceURI.
	PaymentReturnBaseURL string `env:"PAYMENT_RETURN_BASE_URL" envDefault:""`
	// StorefrontBaseURL is where shops' public pages are served. Empty uses
	// the payment return address, which is commerce itself.
	StorefrontBaseURL string `env:"STOREFRONT_BASE_URL" envDefault:""`
	// Anonymous storefront checkouts are counted in the database, so every
	// instance enforces the same limits: per visitor address (IPv6 by /64),
	// per typed contact and per shop, in fixed windows. A shop's unpaid
	// guest orders may hold at most StorefrontUnpaidUnitsPerShop units.
	StorefrontLimitWindow         time.Duration `env:"STOREFRONT_LIMIT_WINDOW"          envDefault:"10m"`
	StorefrontCheckoutsPerVisitor int64         `env:"STOREFRONT_CHECKOUTS_PER_VISITOR" envDefault:"10"`
	StorefrontCheckoutsPerContact int64         `env:"STOREFRONT_CHECKOUTS_PER_CONTACT" envDefault:"5"`
	StorefrontCheckoutsPerShop    int64         `env:"STOREFRONT_CHECKOUTS_PER_SHOP"    envDefault:"120"`
	StorefrontUnpaidUnitsPerShop  int64         `env:"STOREFRONT_UNPAID_UNITS_PER_SHOP" envDefault:"500"`
	// PaymentSettleGrace keeps an overdue order reserved while a payment
	// prompt is still outstanding at the provider.
	PaymentSettleGrace time.Duration `env:"PAYMENT_SETTLE_GRACE" envDefault:"1h"`
	// OrderPaymentWindow is how long a reservation is held for an unpaid
	// order before ReconcilePayments releases the stock.
	OrderPaymentWindow time.Duration `env:"ORDER_PAYMENT_WINDOW" envDefault:"45m"`
	// LatePaymentWindow is how long after an order is cancelled its checkout
	// sessions are still checked, so a late payment is found and refunded.
	LatePaymentWindow time.Duration `env:"LATE_PAYMENT_WINDOW" envDefault:"24h"`
	// PaymentReconcileBatchSize caps the orders examined per reconcile run.
	PaymentReconcileBatchSize int `env:"PAYMENT_RECONCILE_BATCH_SIZE" envDefault:"200"`

	// Ledger policy.
	// LedgerBookType is the book type each shop's book is created under.
	LedgerBookType string `env:"LEDGER_BOOK_TYPE" envDefault:"merchant"`
	// LedgerTimezone is the trading-day boundary used by end-of-day posting
	// when a shop has no timezone of its own.
	LedgerTimezone string `env:"LEDGER_TIMEZONE" envDefault:"Africa/Nairobi"`

	// CommerceServiceURI is the address trustage calls back into for
	// scheduled runs; substituted into the workflow DSL as env.commerce_uri.
	CommerceServiceURI string `env:"COMMERCE_SERVICE_URI" envDefault:""`
}

// CheckoutEnabled reports whether hosted checkout is wired.
func (c *CommerceConfig) CheckoutEnabled() bool { return c.CheckoutServiceURI != "" }

// ReturnBaseURL is where hosted checkout sends buyers back to commerce.
func (c *CommerceConfig) ReturnBaseURL() string {
	if c.PaymentReturnBaseURL != "" {
		return c.PaymentReturnBaseURL
	}
	return c.CommerceServiceURI
}

// StorefrontURL is the base of shops' public pages.
func (c *CommerceConfig) StorefrontURL() string {
	if c.StorefrontBaseURL != "" {
		return c.StorefrontBaseURL
	}
	return c.ReturnBaseURL()
}

// PaymentEnabled reports whether refunds can be paid out.
func (c *CommerceConfig) PaymentEnabled() bool { return c.PaymentServiceURI != "" }

// LedgerEnabled reports whether end-of-day posting is wired.
func (c *CommerceConfig) LedgerEnabled() bool { return c.LedgerServiceURI != "" }

// NotificationsEnabled reports whether buyer and seller messages are wired.
func (c *CommerceConfig) NotificationsEnabled() bool { return c.NotificationServiceURI != "" }

// TrustageEnabled reports whether scheduled workflows are wired.
func (c *CommerceConfig) TrustageEnabled() bool { return c.TrustageServiceURI != "" }

// Validate refuses settings a secure deployment cannot run with: shop webhook
// secrets would be stored unencrypted without WEBHOOK_SECRET_KEY, the public
// storefront cannot find or create its buyers without the profile service,
// and money taken online cannot be refunded without the payment service. Local runs (RUN_SERVICE_SECURELY=false) may leave them unset.
func (c *CommerceConfig) Validate() error {
	if !c.IsRunSecurely() {
		return nil
	}
	var errs []error
	if c.WebhookSecretKey == "" {
		errs = append(errs, errors.New("WEBHOOK_SECRET_KEY is required"))
	}
	if c.StorefrontURL() != "" && c.ProfileServiceURI == "" {
		errs = append(errs, errors.New("PROFILE_SERVICE_URI is required while the storefront is served"))
	}
	if c.CheckoutEnabled() && !c.PaymentEnabled() {
		errs = append(
			errs,
			errors.New("PAYMENT_SERVICE_URI is required while checkout is on: refunds are paid through it"),
		)
	}
	return errors.Join(errs...)
}
