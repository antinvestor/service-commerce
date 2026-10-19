# service-commerce

Multi-shop commerce for the Ant Investor platform: every seller runs inside its
own tenant partition, staff are managed through the identity service, buyers
join the partition as members, and payment, notifications, and bookkeeping
come from the platform services rather than being re-implemented here.

Two Frame services live in this repository:

| App | Purpose |
|---|---|
| `apps/default` | Commerce: shops, catalog, carts, orders, hosted checkout, fulfilment, B2B pricing, end-of-day ledger posting |
| `apps/procurement` | Buy side: suppliers, purchase orders, goods receipts |

Plus the contracts (`proto/`, `opl/`), generated Dart SDKs (`sdk/dart`),
Flutter widget packages and console (`ui/`), a Hugo storefront module
(`web/ai-shop-module`), and the scheduled automations (`workflows/`).

## How a sale flows

1. A buyer (a partition member) builds a cart and calls `CreateOrderFromCart`.
   Each line is priced by the pricing engine (customer override, then price
   list, then catalog, then the best automatic discount, rounded to the
   cent). A discount rule is applied automatically only when it does not
   require approval and its conditions use nothing but `variant_ids`,
   `product_ids` and `min_quantity`; a fixed amount off the whole order is
   never spread per unit. Stock is reserved and the order waits for payment
   for `ORDER_PAYMENT_WINDOW`.
2. `CheckoutOrder` creates a hosted checkout session at the payment service
   and returns the page URL; the buyer pays there. The buyer and the shop's
   contact are notified. Reloading reuses the live session, including after a
   declined attempt, which the buyer can retry on the same page.
3. Checkout sends the buyer back to commerce's `/payments/return` page, which
   verifies the payment with the checkout service and marks the order paid
   before forwarding the buyer to the storefront (the request's or shop's
   return URL, else `CHECKOUT_RETURN_URL`) or showing the status itself.
   `ConfirmOrderPayment` does the same on demand, and the scheduled
   `ReconcilePayments` catches buyers who never came back and releases stock
   from orders whose window lapsed. Every session ever issued for an order is
   checked, an order is only marked paid when the session charged exactly the
   order total in the order currency, and stock is held for
   `PAYMENT_SETTLE_GRACE` past the window while a prompt is still outstanding.
   Both sides are notified when paid.
4. Staff record fulfilments; shipping and delivery notify the buyer.
   `CancelOrder` returns stock, and a staff cancel of a paid order records a
   refund.
5. Nightly, `RunEndOfDayLedger` merges each shop's paid and refunded orders
   into one balanced transaction in the shop's ledger book and tells the shop
   its takings.

Back-office sales (`CreateOrder`) start confirmed and skip the payment window.

## Paying in instalments

A shop's `PaymentPolicy` (overridable per product) lets buyers pay in
instalments: a minimum deposit and instalment share, days to pay the balance,
the share that must be paid before fulfilment, signal thresholds, and whether
to cancel when the balance is overdue. An order fixes the strictest policy of
its lines when it is placed.

- `CheckoutOrder.amount` pays the next instalment (empty pays the balance);
  staff record cash or transfers with `RecordOrderPayment`. Each instalment is
  an `OrderPayment`; `Order.amount_paid` and `Order.balance` track progress.
- The first instalment confirms the order (`PARTIALLY_PAID`) and holds stock
  until the balance deadline instead of the payment window.
- Every step raises an `OrderEvent` in the same transaction: payment received,
  deposit paid, threshold crossed, fulfilment released, fully paid, overpaid,
  balance overdue, cancelled, expired. Events are POSTed to the shop's
  `webhook_url` signed with `X-Commerce-Signature: sha256=<HMAC of the body>`
  (https to public hosts only, retried with backoff by the reconciler), drive
  buyer/seller notifications, and are listed by `ListOrderEvents`.
- End of day books each instalment on the day it was received.

Payments are applied with optimistic concurrency (a version check plus a
unique payment reference per order), not row locks, so the repository layer
stays portable across the databases GORM supports.

## Discount approval

A rule with `requires_approval` is applied automatically only after
`DiscountRuleApprove` (`discount_approve` on the shop). Changing what an
approved rule gives away clears the approval. Waiving the requirement is an
explicit update (`update_mask: ["requires_approval"]`) that also needs
`discount_approve`. Pricing updates are always authorised against the record's
stored shop, price list or variant, never the one the client sends.

## Purchase order suggestions

Procurement's `SuggestPurchaseOrders` reads a production plan and its material
shortages from manufacturing (`MANUFACTURING_SERVICE_URI` on the procurement
app; the plan must belong to the requested property). Each shortage is bought
from its cheapest active supplier item (shorter lead time breaks ties),
raised to the supplier's minimum order, and grouped by supplier with an
estimated total. Shortages nobody supplies come back in a suggestion with no
supplier. The console turns a suggestion into a draft purchase order linked
to the plan. Calling manufacturing needs `common/v2` v2.0.9, whose service
catalog knows the `/manufacturing` audience.

## Default currency

`CreateShop` without a currency, and `ResolveDefaultCurrency`, use the
caller's `currency` setting (settings service, `object=profile`), else the
locale of the device they are signed in on, else the country of their first
profile address, else KES. Variants and price lists default to the shop's
currency.

## Authorization

Three layers, in order:

1. **Partition access** (`tenancy_access`), from the identity service.
2. **Functional permission** per RPC, declared in the proto and generated
   into `opl/commerce/service_commerce.opl.ts`. Partition roles are owner,
   admin, operator, viewer, and member. Members are buyers: they hold
   `cart_manage` and `order_manage` but handlers bind carts and orders to the
   caller, so they only ever reach their own.
3. **Per-shop permission** (`commerce_shop`), checked in every handler. Shop
   creation bridges the partition's roles onto the shop by subject set, so
   employees given a role through the identity service can work every shop in
   the partition without a per-shop grant.

## Configuration

Standard Frame settings apply. Commerce adds:

| Variable | Purpose |
|---|---|
| `CHECKOUT_SERVICE_URI` | Hosted checkout (service-payment `apps/checkout`). Empty disables online payment. |
| `LEDGER_SERVICE_URI` | Ledger for end-of-day posting. Empty disables posting. |
| `NOTIFICATION_SERVICE_URI` | Notification service. Empty disables messages. |
| `TRUSTAGE_SERVICE_URI` | Orchestrator that runs the scheduled workflows. Empty skips workflow sync. |
| `*_WORKLOAD_API_TARGET_PATH` | Workload identity path per peer (defaults match the platform layout). |
| `COMMERCE_SERVICE_URI` | Public address trustage calls back into; substituted into the workflow DSL. |
| `CHECKOUT_RETURN_URL` | Storefront page buyers are forwarded to after paying; `{order_id}` is substituted and `order_id`/`payment` are appended. Shops can override it. Empty shows commerce's own status page. |
| `PAYMENT_RETURN_BASE_URL` | Commerce's public address for `/payments/return` (default `COMMERCE_SERVICE_URI`). Empty on both sends buyers straight to the storefront URL. |
| `PAYMENT_SETTLE_GRACE` | Extra time stock stays reserved while a payment prompt is outstanding (default 1h). |
| `ORDER_PAYMENT_WINDOW` | How long stock is held for an unpaid order (default 45m). |
| `PAYMENT_RECONCILE_BATCH_SIZE` | Orders examined per reconcile run (default 200). |
| `LEDGER_BOOK_TYPE` | Book type for shop books (default `merchant`). |
| `LEDGER_TIMEZONE` | Trading-day boundary (default `Africa/Nairobi`). |
| `WEBHOOK_SECRET_KEY` | Base64 of 32 random bytes; seals shop webhook secrets at rest (AES-256-GCM). Empty stores them unencrypted and logs a warning. Rotating it means shops set their secrets again. |
| `SETTINGS_SERVICE_URI`, `DEVICE_SERVICE_URI`, `PROFILE_SERVICE_URI` | Where a caller's default currency is read from (see below). Each is optional; with none, new shops default to KES. |

Service-to-service calls use the platform's standard mechanism: each service
authenticates outbound requests with its own OAuth2 service account, and the
callee checks the token audience and the caller's Keto grants. The seeds live
in service-authentication's tenancy migrations (`service_commerce`,
`service_procurement`, and the trustage additions).

| Caller | Audience | Namespace | Permissions |
|---|---|---|---|
| commerce | `/checkout` | `service_checkout` | `checkout_session_create`, `checkout_session_view` |
| commerce | `/ledger` | `service_ledger` | ledger, account, transaction, and book view and manage |
| commerce | `/notification` | `service_notification` | `notification_send`, `template_manage`, `template_view` |
| commerce | `/trustage` | `service_trustage` | `workflow_view`, `workflow_manage` |
| commerce | `/settings` | `service_setting` | `setting_view` |
| commerce | `/devices` | `service_device` | `device_view` |
| commerce | `/profile` | `service_profile` | `profile_view` |
| trustage | `/commerce` | `service_commerce` | `ledger_post`, `shops_list` |

Nothing is stored in trustage for this: its scheduled `http.request` steps
carry trustage's own token, so the `service_commerce` grant above is what lets
`ReconcilePayments` and `RunEndOfDayLedger` through the interceptors.

## Setup job versus runtime

The same binary runs as a setup job (`DO_SETUP=true`) and as the server. The
setup job migrates the schema, publishes the permission manifest, registers
the notification templates from `pkg/messages`, and registers the trustage
workflows embedded from `workflows/` (archiving retired `commerce.*` ones);
it builds only the notification and trustage clients. Template and workflow
registration are warn-only so a peer outage never blocks a rollout. The
runtime serves Connect RPC only.

## Development

```bash
make proto-generate   # OpenAPI, OPL, Dart SDKs from proto/
make proto-generate-go   # local Go code for the commerce module into gen/go
git tag dart/commerce/v<version> && git push origin --tags   # publishes the Dart SDK (also automatic on release)
make format && make lint
go test -race ./...   # needs Docker: Postgres and Keto testcontainers
```

Go code for the commerce API is generated locally into `gen/go/commerce`
(`proto/buf.gen.local-go.yaml`) so new RPCs can be implemented before the
schema registry publishes a build. Peer APIs are consumed from the registry.
