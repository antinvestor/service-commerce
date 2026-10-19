# Instalment payments, payment signals, and default currency

Date: 2026-09-29, updated 2026-10-19. Status: implemented on `feat/default-currency-from-profile`, pending review.

## Goals

1. A new shop's currency defaults to what the creating user trades in.
2. Buyers can pay an order in instalments ("in bits") when the shop or the
   products allow it, and every meaningful step raises a signal the shop can
   act on: a webhook callback, a notification, and a pollable event feed.
3. Close the UI gaps found in the 2026-09-29 audit (see the end).

## Default currency

`ResolveDefaultCurrency` (permission `shops_list`) and `CreateShop` without a
currency use the first of:

1. the caller's `currency` setting in the settings service
   (`name=currency, object=profile, object_id=<profile id>`);
2. the locale currency of the caller's device (`device_id` claim, else
   `session_id` claim) from the device service;
3. the currency of the country on the caller's first profile address;
4. the platform default, KES.

A peer that is down or unconfigured is skipped. The response carries a
`CurrencySource` so the UI can say where the value came from.

Variant and price-list currencies are not per-user: they default to the
shop's currency, because every product in a shop is priced in it.

## Payment policy

`PaymentPolicy` lives on the shop (`Shop.payment_policy`) and may be
overridden per product (`Product.payment_policy`, unset = use the shop's).

| Field | Meaning |
|---|---|
| `allow_instalments` | Buyers may pay in more than one instalment. |
| `min_deposit_percent` | First instalment must reach this share of the total. |
| `min_instalment_percent` | Every instalment but the last must reach this share. |
| `balance_due_days` | Days to pay the balance after the first instalment; 0 = no deadline. |
| `fulfil_at_percent` | Share that must be paid before fulfilment; 0 = 100. |
| `signal_thresholds` | Paid-share marks (1–100) that raise `THRESHOLD_CROSSED`. |
| `cancel_when_overdue` | Cancel, restock and record a refund when the deadline passes. |

When an order is placed, the policies of its lines (product override, else
shop) are merged into the strictest one and snapshotted on the order
(`Order.payment_policy`): instalments only if every line allows them; the
highest deposit, instalment and fulfilment marks; the shortest non-zero
deadline; the union of thresholds; cancel if any line says so. Later policy
edits do not change existing orders.

## Paying

- `CheckoutOrder.amount` (optional) is the instalment to pay now. Empty pays
  the whole balance. A partial amount requires `allow_instalments`, must not
  exceed the balance, must meet `min_deposit_percent` when nothing is paid
  yet, and `min_instalment_percent` otherwise, unless it is the whole
  balance. The response returns the session's `amount`.
- A live session is reused only when it charges the same amount.
- `RecordOrderPayment` (staff, `order_manage` on the shop) applies an offline
  instalment with a per-order unique `reference`; repeating a reference is a
  no-op that returns the order.
- Each applied instalment is an `OrderPayment` (`Order.payments`). An online
  session only counts when it charged exactly the amount recorded for that
  session. `Order.amount_paid` and `Order.balance` are always present.

### Order state

| After | `status` | `payment_status` |
|---|---|---|
| order placed by buyer | PENDING_PAYMENT (stock held for the payment window) | PENDING |
| first instalment < total | CONFIRMED (stock held until `balance_due_at`) | PARTIALLY_PAID |
| paid in full | CONFIRMED | PAID |
| window lapsed, nothing paid | CANCELLED | EXPIRED |
| deadline lapsed, `cancel_when_overdue` | CANCELLED | REFUNDED (of what was paid) |

Fulfilment of a PARTIALLY_PAID order needs `paid% >= fulfil_at_percent`
(default 100). Buyers cannot cancel once anything is paid; staff can, which
records a refund of `amount_paid`.

## Signals

Every step writes an `OrderEvent` in the same transaction as the state change:

| Type | When |
|---|---|
| PAYMENT_RECEIVED | each instalment |
| DEPOSIT_PAID | first instalment of an order that is not yet fully paid |
| THRESHOLD_CROSSED | once per policy threshold crossed (`threshold_percent`) |
| FULFILMENT_RELEASED | paid share reaches `fulfil_at_percent` before full payment |
| FULLY_PAID | balance reaches zero |
| OVERPAID | paid exceeds total (two live sessions both paid) |
| BALANCE_OVERDUE | deadline passed with a balance (raised once) |
| CANCELLED / EXPIRED | order cancelled / payment window lapsed |

Events are delivered three ways:

1. **Webhook**: when the shop has `webhook_url`, commerce POSTs the event as
   JSON (the `OrderEvent` in protojson) with headers
   `X-Commerce-Event: <type>`, `X-Commerce-Delivery: <event id>`, and
   `X-Commerce-Signature: sha256=<hex HMAC-SHA256 of the body with the
   webhook secret>`. Only `https` URLs to public addresses are accepted.
   Delivery is attempted right after the change and retried with backoff by
   every `ReconcilePayments` run, up to 10 attempts; `OrderEvent.delivery`
   shows the state.
2. **Notifications** to buyer and seller (instalment received with balance,
   threshold reached, balance overdue).
3. **`ListOrderEvents`** (`order_view`): by `order_id` (buyers may read their
   own order) or by `shop_id` (staff), oldest first, cursor-paged.

## Ledger

End-of-day posting books money when it is received: the day's sales are the
instalments paid that day (plus legacy orders paid in full before instalments
existed). Refunds are the amount actually paid on refunded orders.

## Discount approval

`DiscountRuleApprove` (`discount_approve`) stamps `approved_by`/`approved_at`.
A rule with `requires_approval` is applied automatically only once approved;
saving changes to its value, type or conditions clears the approval. The
requirement can be waived only with `update_mask: ["requires_approval"]`,
which also needs `discount_approve`.

## Webhook secrets at rest

Shop webhook secrets are sealed with AES-256-GCM under `WEBHOOK_SECRET_KEY`
(generated by tofu into Secret Manager). Values stored before sealing are
still read; an event whose secret cannot be opened stays pending rather than
going out unsigned.

## Console authentication

The auth runtime never exposes the access token, so every service transport
the console uses is built on `runtime.fetch` (`runtime_transport.dart`),
which attaches the token, refreshes it on 401 and retries once. All 23 UI
package transports are overridden at start-up.

## Product updates

`UpdateProduct` (`product_manage`) edits name, description, attributes,
fulfilment type, status, media and the payment policy override.
`CreateProduct` accepts `fulfilment_type` and `payment_policy`.

## UI work (from the audit)

- Console: currency pre-filled from `ResolveDefaultCurrency` with its source;
  payment policy and webhook settings on the shop; working procurement
  navigation; links to pricing overrides, discounts, and price checker;
  dashboard money in the shop's currency; staff actions to run payment
  reconciliation and end-of-day posting.
- Catalog: `PaymentPolicyEditor` widget (exported, reused by console);
  product create/edit with fulfilment type and policy override; decimal
  prices; variant currency from the shop; editable SKU and attributes.
- Orders: payment panel with amount paid, balance, deadline, instalment list,
  "pay an instalment" amount, record offline payment, event timeline;
  fulfilment status/carrier/tracking updates; back-office checkout sends real
  contact/address and applies the chosen payment method; list paging/search.
- Pricing: customer override editor; validity dates; discount conditions
  (`variant_ids`, `product_ids`, `min_quantity`); approve button; price-list
  currency from the shop.
- Procurement: route paths fixed; purchase order detail; goods receipt entry
  and history; cancel reason.
- Storefront widget: pay a deposit or instalment when the policy allows,
  show amount paid and balance.
