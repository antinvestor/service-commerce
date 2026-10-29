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

	"github.com/pitabwire/frame/v3/events"

	"github.com/antinvestor/service-commerce/pkg/dbrole"
)

// WebhookDeliveryEventName is the Frame event that delivers order-event
// webhooks off the request path.
const WebhookDeliveryEventName = "commerce.webhook.deliver"

// WebhookDeliveryPayload names the order events to deliver.
type WebhookDeliveryPayload struct {
	EventIDs []string `json:"event_ids"`
}

// NewFrameWebhookQueue queues deliveries on the service's events queue.
// manager is read when a delivery is queued, so it may be set up after the
// queue is built.
func NewFrameWebhookQueue(manager func() events.Manager) WebhookQueue {
	return frameWebhookQueue{manager: manager}
}

type frameWebhookQueue struct {
	manager func() events.Manager
}

var errNoEventsManager = errors.New("events manager is not running")

func (q frameWebhookQueue) Enqueue(ctx context.Context, eventIDs []string) error {
	m := q.manager()
	if m == nil {
		return errNoEventsManager
	}
	return m.Emit(ctx, WebhookDeliveryEventName, &WebhookDeliveryPayload{EventIDs: eventIDs})
}

// NewWebhookDeliveryEvent is the handler for queued deliveries. Event ids are
// commerce's own, emitted by commerce, so the lookup reads across tenants.
func NewWebhookDeliveryEvent(eventBusiness EventBusiness) events.EventI {
	return webhookDeliveryEvent{eventBusiness: eventBusiness}
}

type webhookDeliveryEvent struct {
	eventBusiness EventBusiness
}

func (webhookDeliveryEvent) Name() string { return WebhookDeliveryEventName }

func (webhookDeliveryEvent) PayloadType() any { return &WebhookDeliveryPayload{} }

func (webhookDeliveryEvent) Validate(_ context.Context, payload any) error {
	if p, ok := payload.(*WebhookDeliveryPayload); !ok || len(p.EventIDs) == 0 {
		return errors.New("webhook delivery names no events")
	}
	return nil
}

func (e webhookDeliveryEvent) Execute(ctx context.Context, payload any) error {
	p, ok := payload.(*WebhookDeliveryPayload)
	if !ok {
		return errors.New("unexpected webhook delivery payload")
	}
	// A failed attempt is recorded on the event and retried by the
	// reconcile run; the queue message itself is done.
	e.eventBusiness.Deliver(dbrole.AcrossTenants(ctx, "webhook delivery"), p.EventIDs)
	return nil
}
