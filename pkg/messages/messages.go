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

// Package messages declares every notification commerce sends, once, in code.
// The setup job registers them with the notification service through
// notification.RegisterTemplateSync, and the runtime sends by template name
// with a payload. Bodies are Go text/template; the short form is the SMS body
// and the long form the email body.
package messages

import "github.com/antinvestor/common/notification"

// Owner is the template namespace segment for this service.
const Owner = "commerce"

// Template names. Follow template.<service>.<entity>.<event>; init checks
// each against the notification module's naming rule.
const (
	OrderPlacedBuyer     = "template.commerce.order.placed_buyer"
	OrderPlacedSeller    = "template.commerce.order.placed_seller"
	OrderPaidBuyer       = "template.commerce.order.paid_buyer"
	OrderPaidSeller      = "template.commerce.order.paid_seller"
	OrderPaymentExpired  = "template.commerce.order.payment_expired"
	OrderCancelledBuyer  = "template.commerce.order.cancelled_buyer"
	OrderCancelledSeller = "template.commerce.order.cancelled_seller"
	OrderShipped         = "template.commerce.fulfilment.shipped"
	OrderDelivered       = "template.commerce.fulfilment.delivered"
	LedgerDayPosted      = "template.commerce.ledger.day_posted"
)

// Payload keys shared by the templates.
const (
	VarShopName     = "shop_name"
	VarOrderNumber  = "order_number"
	VarAmount       = "amount"
	VarCurrency     = "currency"
	VarCheckoutURL  = "checkout_url"
	VarReason       = "reason"
	VarCarrier      = "carrier"
	VarTracking     = "tracking_number"
	VarTradingDay   = "trading_day"
	VarOrderCount   = "order_count"
	VarSalesAmount  = "sales_amount"
	VarRefundAmount = "refund_amount"
)

//nolint:gochecknoglobals // template registry is declared once at package init
var registry = notification.NewRegistry(Owner)

//nolint:gochecknoinits // registers the immutable template catalogue
func init() {
	for _, name := range []string{
		OrderPlacedBuyer, OrderPlacedSeller, OrderPaidBuyer, OrderPaidSeller, OrderPaymentExpired,
		OrderCancelledBuyer, OrderCancelledSeller, OrderShipped, OrderDelivered, LedgerDayPosted,
	} {
		if err := notification.ValidateName(name); err != nil {
			panic(err)
		}
	}
	registry.MustAdd(
		notification.New(OrderPlacedBuyer,
			"Order {{.order_number}} at {{.shop_name}}",
			"{{.shop_name}}: order {{.order_number}} received, {{.currency}} {{.amount}}. Pay here: {{.checkout_url}}",
			"Thank you for your order {{.order_number}} at {{.shop_name}}.\n\n"+
				"Total: {{.currency}} {{.amount}}\n\n"+
				"Complete payment to reserve your items: {{.checkout_url}}\n",
			VarShopName, VarOrderNumber, VarAmount, VarCurrency, VarCheckoutURL),
		notification.New(OrderPlacedSeller,
			"New order {{.order_number}}",
			"{{.shop_name}}: new order {{.order_number}} for {{.currency}} {{.amount}} awaiting payment.",
			"A new order {{.order_number}} for {{.currency}} {{.amount}} was placed at {{.shop_name}} "+
				"and is awaiting payment.\n",
			VarShopName, VarOrderNumber, VarAmount, VarCurrency),
		notification.New(
			OrderPaidBuyer,
			"Payment received for {{.order_number}}",
			"{{.shop_name}}: payment of {{.currency}} {{.amount}} for order {{.order_number}} received. We are preparing it.",
			"We received your payment of {{.currency}} {{.amount}} for order {{.order_number}} "+
				"at {{.shop_name}}. Your order is now being prepared.\n",
			VarShopName,
			VarOrderNumber,
			VarAmount,
			VarCurrency,
		),
		notification.New(OrderPaidSeller,
			"Order {{.order_number}} paid",
			"{{.shop_name}}: order {{.order_number}} paid, {{.currency}} {{.amount}}. Ready to fulfil.",
			"Order {{.order_number}} at {{.shop_name}} has been paid ({{.currency}} {{.amount}}) "+
				"and is ready to fulfil.\n",
			VarShopName, VarOrderNumber, VarAmount, VarCurrency),
		notification.New(OrderPaymentExpired,
			"Order {{.order_number}} expired",
			"{{.shop_name}}: order {{.order_number}} was not paid in time and has been released.",
			"Order {{.order_number}} at {{.shop_name}} was not paid within the payment window, "+
				"so the items have been released back to stock. You can place a new order any time.\n",
			VarShopName, VarOrderNumber),
		notification.New(OrderCancelledBuyer,
			"Order {{.order_number}} cancelled",
			"{{.shop_name}}: order {{.order_number}} was cancelled. {{.reason}}",
			"Order {{.order_number}} at {{.shop_name}} has been cancelled.\n\nReason: {{.reason}}\n",
			VarShopName, VarOrderNumber, VarReason),
		notification.New(OrderCancelledSeller,
			"Order {{.order_number}} cancelled",
			"{{.shop_name}}: order {{.order_number}} cancelled. {{.reason}}",
			"Order {{.order_number}} at {{.shop_name}} was cancelled.\n\nReason: {{.reason}}\n",
			VarShopName, VarOrderNumber, VarReason),
		notification.New(OrderShipped,
			"Order {{.order_number}} shipped",
			"{{.shop_name}}: order {{.order_number}} shipped via {{.carrier}} {{.tracking_number}}.",
			"Your order {{.order_number}} from {{.shop_name}} is on its way.\n\n"+
				"Carrier: {{.carrier}}\nTracking: {{.tracking_number}}\n",
			VarShopName, VarOrderNumber, VarCarrier, VarTracking),
		notification.New(OrderDelivered,
			"Order {{.order_number}} delivered",
			"{{.shop_name}}: order {{.order_number}} was delivered. Thank you!",
			"Your order {{.order_number}} from {{.shop_name}} has been delivered. Thank you for shopping with us.\n",
			VarShopName, VarOrderNumber),
		notification.New(
			LedgerDayPosted,
			"{{.shop_name}} daily takings for {{.trading_day}}",
			"{{.shop_name}} {{.trading_day}}: {{.order_count}} orders, sales {{.currency}} {{.sales_amount}}, refunds {{.currency}} {{.refund_amount}}.",
			"Daily takings for {{.shop_name}} on {{.trading_day}} have been posted to the ledger.\n\n"+
				"Orders: {{.order_count}}\nSales: {{.currency}} {{.sales_amount}}\nRefunds: {{.currency}} {{.refund_amount}}\n",
			VarShopName,
			VarTradingDay,
			VarOrderCount,
			VarCurrency,
			VarSalesAmount,
			VarRefundAmount,
		),
	)
}

// Registry returns the template catalogue for setup-time registration.
func Registry() *notification.Registry { return registry }
