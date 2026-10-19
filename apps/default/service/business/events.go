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

package business

import (
	"context"
	"errors"
	"time"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/encoding/protojson"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// Webhook delivery policy: attempts back off exponentially from a minute up
// to six hours, and stop after maxDeliveryAttempts.
const (
	maxDeliveryAttempts = 10
	firstRetryDelay     = time.Minute
	maxRetryDelay       = 6 * time.Hour
	deliveryBatchSize   = 100
)

// EventPage is one page of order events plus the next cursor.
type EventPage struct {
	Events   []*commercev1.OrderEvent
	NextPage string
}

// EventBusiness delivers the signals recorded alongside order changes and
// serves them back to clients.
type EventBusiness interface {
	// Publish sends notifications for freshly committed events and makes a
	// first webhook delivery attempt. payment is the instalment that raised
	// them, when there is one. It never fails the caller: undelivered
	// webhooks are retried by DeliverDue.
	Publish(
		ctx context.Context,
		shop *models.Shop,
		order *models.Order,
		payment *models.OrderPayment,
		events []*models.OrderEvent,
	)
	// DeliverDue retries webhook deliveries whose time has come and reports
	// how many were delivered.
	DeliverDue(ctx context.Context, now time.Time) int
	// List pages the events of a shop or an order, oldest first.
	List(ctx context.Context, shopID, orderID string, page repository.Page) (*EventPage, error)
}

// NewEventBusiness builds the event dispatcher. A nil sender disables
// webhooks; events are still recorded and listed.
func NewEventBusiness(
	eventRepo repository.OrderEventRepository,
	shopRepo repository.ShopRepository,
	notifier notifications.Notifier,
	sender WebhookSender,
	secrets SecretBox,
) EventBusiness {
	if secrets == nil {
		secrets = plainBox{}
	}
	return &eventBusiness{
		eventRepo: eventRepo, shopRepo: shopRepo, notifier: notifier, sender: sender, secrets: secrets,
	}
}

type eventBusiness struct {
	eventRepo repository.OrderEventRepository
	shopRepo  repository.ShopRepository
	notifier  notifications.Notifier
	sender    WebhookSender
	secrets   SecretBox
}

func (eb *eventBusiness) Publish(
	ctx context.Context,
	shop *models.Shop,
	order *models.Order,
	payment *models.OrderPayment,
	events []*models.OrderEvent,
) {
	if shop == nil || len(events) == 0 {
		return
	}
	fullyPaid := false
	for _, event := range events {
		switch commercev1.OrderEventType(event.Type) { //nolint:exhaustive // only these notify on their own
		case commercev1.OrderEventType_ORDER_EVENT_TYPE_FULLY_PAID:
			fullyPaid = true
		case commercev1.OrderEventType_ORDER_EVENT_TYPE_THRESHOLD_CROSSED:
			eb.notifier.PaymentThresholdReached(ctx, shop, order, event.ThresholdPercent)
		case commercev1.OrderEventType_ORDER_EVENT_TYPE_BALANCE_OVERDUE:
			eb.notifier.BalanceOverdue(ctx, shop, order)
		default:
		}
	}
	// The full-payment message covers the last instalment; earlier ones get
	// the running balance.
	if fullyPaid {
		eb.notifier.OrderPaid(ctx, shop, order)
	} else if payment != nil && order.Status != int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		eb.notifier.InstalmentReceived(ctx, shop, order, payment)
	}

	now := time.Now()
	for _, event := range events {
		if event.Delivery == models.EventDeliveryPending {
			eb.deliver(ctx, shop, event, now)
		}
	}
}

func (eb *eventBusiness) DeliverDue(ctx context.Context, now time.Time) int {
	events, err := eb.eventRepo.ListDue(ctx, now, deliveryBatchSize)
	if err != nil {
		util.Log(ctx).WithError(err).Warn("could not list order events due for delivery")
		return 0
	}
	shops := map[string]*models.Shop{}
	var orphaned []string
	delivered := 0
	for _, event := range events {
		if ctx.Err() != nil {
			break
		}
		shop, ok := shops[event.ShopID]
		if !ok {
			shop, err = eb.shopRepo.GetByID(ctx, event.ShopID)
			if err != nil {
				util.Log(ctx).WithError(err).WithField("shop_id", event.ShopID).Warn("could not load shop for webhook")
				continue
			}
			shops[event.ShopID] = shop
		}
		if shop.WebhookURL == "" {
			orphaned = append(orphaned, event.GetID())
			continue
		}
		if eb.deliver(ctx, shop, event, now) {
			delivered++
		}
	}
	if markErr := eb.eventRepo.MarkNotRequired(ctx, orphaned); markErr != nil {
		util.Log(ctx).WithError(markErr).Warn("could not stop delivery for shops without a webhook")
	}
	return delivered
}

// deliver makes one webhook attempt and records its outcome.
func (eb *eventBusiness) deliver(ctx context.Context, shop *models.Shop, event *models.OrderEvent, now time.Time) bool {
	if eb.sender == nil {
		return false
	}
	log := util.Log(ctx).WithField("event_id", event.GetID()).WithField("shop_id", shop.GetID())
	body, err := protojson.Marshal(event.ToAPI())
	if err != nil {
		log.WithError(err).Error("could not encode order event")
		return false
	}

	secret, err := eb.secrets.Open(shop.WebhookSecret)
	if err != nil {
		// Unsigned delivery would let anyone forge events; keep it pending
		// until the key is configured.
		log.WithError(err).Error("could not open the shop's webhook secret")
		return false
	}

	event.DeliveryAttempts++
	sendErr := eb.sender.Send(ctx, WebhookDelivery{
		URL:        shop.WebhookURL,
		Secret:     secret,
		EventType:  commercev1.OrderEventType(event.Type).String(),
		DeliveryID: event.GetID(),
		Body:       body,
	})
	if sendErr == nil {
		event.Delivery = models.EventDeliveryDelivered
		delivered := now
		event.DeliveredAt = &delivered
		event.NextAttemptAt = nil
		event.LastError = ""
	} else {
		log.WithError(sendErr).Warn("webhook delivery failed")
		event.LastError = truncateRunes(sendErr.Error(), maxErrorLength)
		if event.DeliveryAttempts >= maxDeliveryAttempts {
			event.Delivery = models.EventDeliveryFailed
			event.NextAttemptAt = nil
		} else {
			next := now.Add(retryDelay(event.DeliveryAttempts))
			event.NextAttemptAt = &next
		}
	}
	if recordErr := eb.eventRepo.RecordDelivery(ctx, event); recordErr != nil {
		log.WithError(recordErr).Warn("could not record webhook delivery")
	}
	return sendErr == nil
}

const maxErrorLength = 500

// retryDelay doubles from firstRetryDelay per attempt, capped.
func retryDelay(attempts int32) time.Duration {
	delay := firstRetryDelay
	for i := int32(1); i < attempts && delay < maxRetryDelay; i++ {
		delay *= 2
	}
	return min(delay, maxRetryDelay)
}

func (eb *eventBusiness) List(
	ctx context.Context,
	shopID, orderID string,
	page repository.Page,
) (*EventPage, error) {
	if shopID == "" && orderID == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("shop_id or order_id is required"))
	}
	events, next, err := eb.eventRepo.List(ctx, shopID, orderID, page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &EventPage{Events: make([]*commercev1.OrderEvent, 0, len(events)), NextPage: nextCursor(next)}
	for _, event := range events {
		result.Events = append(result.Events, event.ToAPI())
	}
	return result, nil
}
