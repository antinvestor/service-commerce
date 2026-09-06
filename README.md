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
   Stock is reserved and the order waits for payment for
   `ORDER_PAYMENT_WINDOW`.
2. `CheckoutOrder` creates a hosted checkout session at the payment service
   and returns the page URL; the buyer pays there. The buyer and the shop's
   contact are notified.
3. Payment is settled by `ConfirmOrderPayment` (from the return page or
   staff) or by the scheduled `ReconcilePayments`, which also releases stock
   from orders whose window lapsed. Both sides are notified when paid.
4. Staff record fulfilments; shipping and delivery notify the buyer.
   `CancelOrder` returns stock, and a staff cancel of a paid order records a
   refund.
5. Nightly, `RunEndOfDayLedger` merges each shop's paid and refunded orders
   into one balanced transaction in the shop's ledger book and tells the shop
   its takings.

Back-office sales (`CreateOrder`) start confirmed and skip the payment window.

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
| `CHECKOUT_RETURN_URL` | Default page buyers return to after paying; `{order_id}` is substituted. Shops can override it. |
| `ORDER_PAYMENT_WINDOW` | How long stock is held for an unpaid order (default 45m). |
| `PAYMENT_RECONCILE_BATCH_SIZE` | Orders examined per reconcile run (default 200). |
| `LEDGER_BOOK_TYPE` | Book type for shop books (default `merchant`). |
| `LEDGER_TIMEZONE` | Trading-day boundary (default `Africa/Nairobi`). |
| `WORKFLOWS_PATH` | Directory of workflow DSL files (default `./workflows`). |

The commerce service account needs these grants at the tenancy service:

| Namespace | Permissions |
|---|---|
| `service_checkout` | `checkout_session_create`, `checkout_session_view` |
| `service_ledger` | `ledger_manage`, `ledger_view` |
| `service_notification` | `notification_send`, `template_manage` |
| `service_workflow` (trustage) | workflow create, list, activate |

And trustage needs a credential named `api_token` carrying a commerce service
token with `ledger_post` so its scheduled calls pass the interceptors.

## Setup job versus runtime

The same binary runs as a setup job (`DO_SETUP=true`) and as the server. The
setup job migrates the schema, publishes the permission manifest, registers
the notification templates from `pkg/messages`, and registers the workflows
under `workflows/`. The runtime serves Connect RPC only.

## Development

```bash
make proto-generate   # OpenAPI, OPL, Dart SDKs from proto/
make proto-generate-go   # local Go code for the commerce module into gen/go
make format && make lint
go test -race ./...   # needs Docker: Postgres and Keto testcontainers
```

Go code for the commerce API is generated locally into `gen/go/commerce`
(`proto/buf.gen.local-go.yaml`) so new RPCs can be implemented before the
schema registry publishes a build. Peer APIs are consumed from the registry.
