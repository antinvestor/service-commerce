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

package notifications_test

import (
	"context"
	"testing"
	"time"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/antinvestor/common/notification"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/pkg/messages"
)

type capturingSender struct {
	sent []*notificationv1.Notification
}

func (c *capturingSender) Send(_ context.Context, n *notificationv1.Notification) error {
	c.sent = append(c.sent, n)
	return nil
}

// Every message the notifier sends must name a registered template and carry
// every variable that template renders, so a sync'd template and the code
// that fills it can never drift apart unnoticed.
func TestNotifierPayloadsMatchTemplates(t *testing.T) {
	t.Parallel()
	sender := &capturingSender{}
	n := notifications.New(sender)
	ctx := context.Background()

	due := time.Date(2026, 10, 6, 0, 0, 0, 0, time.UTC)
	shop := &models.Shop{Name: "Duka", ContactID: "seller-contact"}
	order := &models.Order{
		OrderNumber: "ORD-000001", ProfileID: "buyer", ContactID: "buyer-contact",
		TotalCurrency: "KES", TotalUnits: 21, AmountPaidNanos: 7_000_000_000, BalanceDueAt: &due,
		CheckoutURL: "https://pay.example/c/1",
	}
	payment := &models.OrderPayment{AmountNanos: 7_000_000_000}
	fulfilment := &models.Fulfilment{Carrier: "G4S", TrackingNumber: "T-1"}
	posting := &models.LedgerPosting{TradingDay: "2026-09-29", Currency: "KES", SalesNanos: 21_000_000_000}

	n.OrderPlaced(ctx, shop, order)
	n.OrderPaid(ctx, shop, order)
	n.OrderPaymentExpired(ctx, shop, order)
	n.OrderCancelled(ctx, shop, order, "out of stock")
	n.OrderShipped(ctx, shop, order, fulfilment)
	n.OrderDelivered(ctx, shop, order)
	n.LedgerDayPosted(ctx, shop, posting)
	n.InstalmentReceived(ctx, shop, order, payment)
	n.PaymentThresholdReached(ctx, shop, order, 50)
	n.BalanceOverdue(ctx, shop, order)

	reg := messages.Registry()
	used := map[string]bool{}
	for _, msg := range sender.sent {
		tpl, ok := reg.Lookup(msg.GetTemplate())
		require.True(t, ok, "unregistered template %s", msg.GetTemplate())
		used[msg.GetTemplate()] = true

		vars := msg.GetPayload().AsMap()
		for _, channel := range []string{notification.ChannelSMS, notification.ChannelEmail} {
			out, err := tpl.Render(channel, vars)
			require.NoError(t, err)
			require.NotContains(t, out, "<no value>", "%s/%s", tpl.Name, channel)
		}
		require.NotEmpty(t, msg.GetRecipient().GetContactId()+msg.GetRecipient().GetProfileId())
	}
	require.Len(t, used, reg.Len(), "every registered template is sent by some notifier method")
}

func TestNotifierWithoutSenderIsSilent(t *testing.T) {
	t.Parallel()
	require.NotPanics(t, func() {
		notifications.New(nil).OrderPaid(context.Background(), &models.Shop{}, &models.Order{})
	})
}

// A storefront guest's contact is only what someone typed; nothing is sent
// to it until money has been paid towards the order. The seller still
// hears of the order.
func TestGuestHearsNothingUntilTheyPay(t *testing.T) {
	t.Parallel()
	sender := &capturingSender{}
	n := notifications.New(sender)
	ctx := context.Background()
	shop := &models.Shop{Name: "Duka", ContactID: "seller-contact"}
	order := &models.Order{
		OrderNumber: "ORD-000002", ProfileID: "guest", ContactID: "typed-contact", Guest: true,
		TotalCurrency: "KES", TotalUnits: 21, CheckoutURL: "https://pay.example/c/2",
	}

	n.OrderPlaced(ctx, shop, order)
	n.OrderPaymentExpired(ctx, shop, order)
	n.OrderCancelled(ctx, shop, order, "expired")
	for _, msg := range sender.sent {
		require.Equal(t, "seller-contact", msg.GetRecipient().GetContactId(), msg.GetTemplate())
		require.Empty(t, msg.GetRecipient().GetProfileId(), msg.GetTemplate())
	}

	sender.sent = nil
	order.AmountPaidNanos = 21_000_000_000
	n.OrderPaid(ctx, shop, order)
	var toBuyer int
	for _, msg := range sender.sent {
		if msg.GetRecipient().GetProfileId() == "guest" {
			toBuyer++
		}
	}
	require.Equal(t, 1, toBuyer, "once paid, the buyer gets their receipt")
}
