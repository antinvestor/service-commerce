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

// Package notifications chooses which message to send for a commerce event
// and delivers it through the notification service. It never fails the
// business operation that triggered it: delivery problems are logged.
package notifications

import (
	"context"
	"fmt"
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/antinvestor/common/notification"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/pkg/messages"
)

// Notifier is what the business layer talks to. The zero value is safe and
// sends nothing, so callers never guard on it.
type Notifier interface {
	OrderPlaced(ctx context.Context, shop *models.Shop, order *models.Order)
	OrderPaid(ctx context.Context, shop *models.Shop, order *models.Order)
	OrderPaymentExpired(ctx context.Context, shop *models.Shop, order *models.Order)
	OrderCancelled(ctx context.Context, shop *models.Shop, order *models.Order, reason string)
	OrderShipped(ctx context.Context, shop *models.Shop, order *models.Order, fulfilment *models.Fulfilment)
	OrderDelivered(ctx context.Context, shop *models.Shop, order *models.Order)
	LedgerDayPosted(ctx context.Context, shop *models.Shop, posting *models.LedgerPosting)
}

// notifier sends through a notification.Sender.
type notifier struct {
	sender notification.Sender
}

// New returns a Notifier. A nil sender yields a no-op notifier.
func New(sender notification.Sender) Notifier {
	return &notifier{sender: sender}
}

// Notification types used for routing and analytics on the notification side.
const (
	typeOrder      = "commerce_order"
	typeFulfilment = "commerce_fulfilment"
	typeLedger     = "commerce_ledger"
)

func (n *notifier) OrderPlaced(ctx context.Context, shop *models.Shop, order *models.Order) {
	vars := orderVars(shop, order)
	vars[messages.VarCheckoutURL] = order.CheckoutURL
	n.toBuyer(ctx, messages.OrderPlacedBuyer, typeOrder, order, vars, notificationv1.PRIORITY_HIGH)
	n.toSeller(ctx, messages.OrderPlacedSeller, typeOrder, shop, vars, notificationv1.PRIORITY_LOW)
}

func (n *notifier) OrderPaid(ctx context.Context, shop *models.Shop, order *models.Order) {
	vars := orderVars(shop, order)
	n.toBuyer(ctx, messages.OrderPaidBuyer, typeOrder, order, vars, notificationv1.PRIORITY_HIGH)
	n.toSeller(ctx, messages.OrderPaidSeller, typeOrder, shop, vars, notificationv1.PRIORITY_HIGH)
}

func (n *notifier) OrderPaymentExpired(ctx context.Context, shop *models.Shop, order *models.Order) {
	n.toBuyer(ctx, messages.OrderPaymentExpired, typeOrder, order, orderVars(shop, order), notificationv1.PRIORITY_LOW)
}

func (n *notifier) OrderCancelled(ctx context.Context, shop *models.Shop, order *models.Order, reason string) {
	vars := orderVars(shop, order)
	vars[messages.VarReason] = reason
	n.toBuyer(ctx, messages.OrderCancelledBuyer, typeOrder, order, vars, notificationv1.PRIORITY_HIGH)
	n.toSeller(ctx, messages.OrderCancelledSeller, typeOrder, shop, vars, notificationv1.PRIORITY_LOW)
}

func (n *notifier) OrderShipped(
	ctx context.Context,
	shop *models.Shop,
	order *models.Order,
	fulfilment *models.Fulfilment,
) {
	vars := orderVars(shop, order)
	vars[messages.VarCarrier] = fulfilment.Carrier
	vars[messages.VarTracking] = fulfilment.TrackingNumber
	n.toBuyer(ctx, messages.OrderShipped, typeFulfilment, order, vars, notificationv1.PRIORITY_HIGH)
}

func (n *notifier) OrderDelivered(ctx context.Context, shop *models.Shop, order *models.Order) {
	n.toBuyer(ctx, messages.OrderDelivered, typeFulfilment, order, orderVars(shop, order), notificationv1.PRIORITY_LOW)
}

func (n *notifier) LedgerDayPosted(ctx context.Context, shop *models.Shop, posting *models.LedgerPosting) {
	vars := map[string]any{
		messages.VarShopName:     shop.Name,
		messages.VarTradingDay:   posting.TradingDay,
		messages.VarOrderCount:   strconv.Itoa(int(posting.OrderCount)),
		messages.VarCurrency:     posting.Currency,
		messages.VarSalesAmount:  formatNanos(posting.SalesNanos),
		messages.VarRefundAmount: formatNanos(posting.RefundNanos),
	}
	n.toSeller(ctx, messages.LedgerDayPosted, typeLedger, shop, vars, notificationv1.PRIORITY_LOW)
}

// --- delivery ---

func (n *notifier) toBuyer(
	ctx context.Context,
	template, kind string,
	order *models.Order,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	if order.ProfileID == "" && order.ContactID == "" {
		return
	}
	n.send(ctx, template, kind, commonv1.ContactLink_builder{
		ProfileId: order.ProfileID,
		ContactId: order.ContactID,
	}.Build(), vars, priority)
}

func (n *notifier) toSeller(
	ctx context.Context,
	template, kind string,
	shop *models.Shop,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	if shop.ContactID == "" {
		return
	}
	n.send(ctx, template, kind, commonv1.ContactLink_builder{
		ContactId: shop.ContactID,
	}.Build(), vars, priority)
}

func (n *notifier) send(
	ctx context.Context,
	template, kind string,
	recipient *commonv1.ContactLink,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	if n == nil || n.sender == nil {
		return
	}
	log := util.Log(ctx).WithField("template", template)

	payload, err := structpb.NewStruct(vars)
	if err != nil {
		log.WithError(err).Warn("could not build notification payload")
		return
	}

	msg := notificationv1.Notification_builder{
		Type:        kind,
		Template:    template,
		Payload:     payload,
		Recipient:   recipient,
		Language:    notification.DefaultLanguage,
		OutBound:    true,
		AutoRelease: true,
		Priority:    priority,
	}.Build()

	if sendErr := n.sender.Send(ctx, msg); sendErr != nil {
		log.WithError(sendErr).Warn("could not send notification")
	}
}

func orderVars(shop *models.Shop, order *models.Order) map[string]any {
	return map[string]any{
		messages.VarShopName:    shop.Name,
		messages.VarOrderNumber: order.OrderNumber,
		messages.VarCurrency:    order.TotalCurrency,
		messages.VarAmount:      formatNanos(order.TotalNanosValue()),
	}
}

// formatNanos renders a nanos amount with two decimals for humans.
func formatNanos(nanos int64) string {
	sign := ""
	if nanos < 0 {
		sign = "-"
		nanos = -nanos
	}
	cents := (nanos + 5_000_000) / 10_000_000                   //nolint:mnd // round to cents
	return fmt.Sprintf("%s%d.%02d", sign, cents/100, cents%100) //nolint:mnd // cents
}
