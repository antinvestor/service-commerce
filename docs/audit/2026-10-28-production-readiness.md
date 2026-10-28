# Production readiness audit: commerce and procurement, 2026-10-28

**Scope:** whether a shop can run end to end on this system and whether its money stays correct. That covers:
- catalogue, pricing, carts and orders;
- the public storefront and guest checkout;
- hosted payment, instalments, reconciliation and refunds;
- the end-of-day ledger;
- procurement (suppliers, purchase orders, goods receipts);
- the staff console, the Hugo storefront widget, tenancy and authorization.

**Method:** four adversarial read-only stage reviews:
1. the buyer flow;
2. the money path;
3. security, tenancy and operations;
4. procurement and the UI.

Each finding was checked against the code before being fixed on branch `fix/production-readiness`. Commits `e7d9a6b`..`9167447`.

## Production state found

`platform-commerce` (stawi-platform, europe-west1) has been down since about 19 Oct:

- **Database quota.** The commerce Neon project exceeded its compute quota (SQLSTATE 53000), so the service cannot connect to its database.
- **Startup panic.** On that failure, the deployed v0.4.3 (frame v2) dereferences a nil pool in `NewShopRepository` and panics on every start.
- **Releases never shipped.** v0.5.0 and v0.5.1 did not reach production because the setup Job could not reach the database either.
- **Quota drain.** The quota was used up by a `ReconcilePayments` call every 5 minutes. Neon suspends a database only after 5 idle minutes, so it never slept. The code now runs reconciliation every 30 minutes, and an idle run costs one indexed `EXISTS`.
- **Remaining fix is outside the code.** Restoring compute is a Neon plan or quota matter.

## Verdict

**Before: NOT READY.**
- Row-level security did nothing, because the runtime connected as the BYPASSRLS owner.
- Buyers could read every order in their partition.
- A late payment was taken but never recorded or refunded.
- Refunds were only marked, never paid out.
- 13 of 14 procurement RPCs returned Unimplemented.
- No property permission was ever granted.
- Goods receipts changed no stock.
- The storefront could be used to lock inventory and send unlimited messages to any contact.
- The console's "Receive payment" screen was fake.
- The Hugo widget published a bearer token in its page.

**After: READY WITH CONDITIONS.** Every finding below is fixed and tested. The conditions are the deployment changes and the sibling-repo work listed at the end.

## What was fixed

### Startup, isolation, authorization
- **Startup without a database:** both apps exit with an error (`dbmigrate.Ready`) instead of panicking. The setup Job is covered too.
- **Runtime role** (`pkg/dbrole`, ported from service-fintech):
  - The setup Job maintains a role that row-level security applies to.
  - `MustVerify` refuses a BYPASSRLS role when `DATABASE_REQUIRE_RLS=true`.
  - Tenancy fails closed: a query without a tenant fails.
  - Only these may read across tenants, through `dbrole.AcrossTenants`: the storefront slug lookup, the payment return page, and the scheduler's reconcile and ledger runs when called by an internal service account.
- **Keto (OPL):** partition members lost `orders_view`, `fulfilment_view` and `price_list_view` on shops. A buyer reads only their own orders.
- **Pricing:** a price list can only price variants of its own shop.
- **Procurement handlers:**
  - Handlers carry the published RPC names, and a missing RPC fails the build.
  - A property permission is granted by a direct grant on that property, or by the matching permission on the caller's own partition.
  - Permission checks never write Keto tuples.
  - Goods receipts are authorised on the purchase order's own property.
- **Idempotency:**
  - Order, purchase-order and receipt idempotency keys are unique per tenancy.
  - A replay must match the original request.
- **Existence leaks:**
  - A record the caller may not see answers NotFound.
  - A slug taken by another tenant answers AlreadyExists.
- **Required config:** missing `WEBHOOK_SECRET_KEY`, `PROFILE_SERVICE_URI` (when the storefront is on) or `PAYMENT_SERVICE_URI` (when checkout is on) stops startup when running securely.

### Money path
- **Payment window:**
  - Checkout extends an unpaid order's window to cover its session.
  - A failed session that still has a prompt counts as in flight.
  - Expired or cancelled orders keep being checked for `LATE_PAYMENT_WINDOW` (24h). A late payment is applied and refunded.
- **Refunds:**
  - A refund is a payout through payment `Send` to the buyer's profile (and contact). Payment picks the route.
  - The reference is fixed per cause. The refund is claimed before it is sent, and a lost answer is resolved by looking up the reference.
  - The order shows `REFUND_PENDING` until payment confirms, then `REFUNDED`.
  - Overpayments and payments on cancelled orders take the same path.
- **Cancel, pay and overdue races:**
  - Cancelling decides inside a version-checked transaction, so a payment landing mid-cancel is refunded, never dropped.
  - The overdue path never restocks shipped goods.
- **Reconciler:**
  - Orders that cannot settle are backed off (`next_reconcile_at`), so they no longer block the queue.
  - A session that charged the wrong amount goes to `payment_review`.
- **End-of-day ledger:**
  - Only finished days are posted.
  - Failed days from the last 7 are retried.
  - Shops are paged, with no 500-shop ceiling.
  - Zero net is skipped.
  - Items are stamped before posting, so a retry sends the same payload.
- **Sessions:** one open payment session per order.
- **Return page:**
  - `return_url` is allowlisted and must be https.
  - The return page checks the session ref before calling checkout.
- **Webhooks:** delivered from the events queue, claimed before sending, signed over `<timestamp>.<body>`, and never sent unsigned.

### Buyer flow and storefront
- **Checkout limits:** a shared, Postgres-backed limit per visitor (IPv6 grouped by /64), per contact (stored hashed) and per shop. It fails closed.
- **Stock held by guests:** each shop has a cap on units held by unpaid guest orders.
- **Guest messages:** a guest is messaged only after paying.
- **Query cost:** the storefront page and order pricing run a bounded number of queries (batch variant loads, `QuotePrices`). A cart holds at most 50 lines.
- **Replica lag:** reads that follow a write, and idempotency lookups, use the primary.
- **Validation:**
  - Price-list bands may not overlap, and tie-breaks are deterministic.
  - Fixed discounts carry a currency.
  - All money input is validated against the shop's currency.
  - A deposit is validated before stock is reserved.
- **Messages:** anonymous visitors see fixed messages, with no stock levels or ids.
- **Contacts:** a buyer cannot choose a contact id. Notification uses the profile's default.
- **Hugo widget:** rebuilt on `GET /shop/{slug}/catalogue` and the guest form. It has no token and builds every element through the DOM.

### Procurement
- **Supplier items** declare a `supply_kind`:
  - Resale variants raise commerce stock through the internal `ReceiveStock` call, once per receipt line reference.
  - Raw materials wait as `PENDING_TRANSFER` (see conditions).
- **Delivery:**
  - Delivery state is saved with the receipt.
  - Failures are retried hourly by Trustage (`GoodsReceiptDeliver`).
  - Staff resolve stuck lines with `GoodsReceiptLineResolve` (booked manually, or retry).
- **Purchase orders:**
  - Receipts are accepted only on submitted orders, checked under a row lock.
  - `PurchaseOrderClose` closes short.
  - Quantities are NUMERIC(20,6).
  - Line totals use arbitrary precision.
  - Supplier prices are validated, and a purchase order needs an active supplier.
- **Suggestions:** never compare across currencies, use one query, and are capped at 500 shortages.
- **Searches:** cursor-paged, filters combine, and page size is capped at 200.

### Console and SDKs
- **Fake screens removed:**
  - "Receive payment", notes and balance were fake and are gone.
  - Payments go through `RecordOrderPayment`.
- **Orders:**
  - Refund and review states are shown.
  - Cancelling a paid order explains the automatic refund.
- **Procurement screens:** supply-kind pickers, close short, per-line delivery status with resolve, and cursor paging.
- **Permissions:** routes, menus and tiles are gated on the real permission names, mapped from token roles and tested against the protos.
- **Server filters:** `ListOrders` filters by `profile_id`, `statuses` and `payment_statuses` on the server.
- **Phone width:** lists render as cards on narrow screens.
- **Dart SDKs:** on protobuf 6 / connect-dart 2 (commerce 2.0.0, procurement 0.2.0, property 2.0.0). Build output is no longer tracked.

## Conditions

### Deployment (cloud.deployment, auth tenancy migrations)

**Both apps:**
- Wire `modules/runtime-db-role` as for the fintech apps:
  - the setup Job gets `DATABASE_RUNTIME_ROLE` and `DATABASE_RUNTIME_PASSWORD`;
  - the runtime uses the runtime-role URL;
  - then set `DATABASE_REQUIRE_RLS=true`.

**Commerce:**
- Secret `WEBHOOK_SECRET_KEY`.
- Peer URIs: `PROFILE_SERVICE_URI` and `PAYMENT_SERVICE_URI`.
- Audience `/payment`.
- Grants in `service_payment`: `payment_send`, `payment_status_view`, `payment_search`.
- Optional storefront limits: `STOREFRONT_*`, `LATE_PAYMENT_WINDOW`.

**Procurement:**
- `COMMERCE_SERVICE_URI`.
- Setup Job: `TRUSTAGE_SERVICE_URI` and `PROCUREMENT_SERVICE_URI`.
- Audiences `/commerce` and `/trustage`, plus `/manufacturing` if suggestions are used.
- Grant `stock_receive` in `service_commerce`.

**Trustage:**
- Audience `/procurement`.
- Grant `goods_receipt_deliver`.
- Must call `ReconcilePayments`, `RunEndOfDayLedger` and `GoodsReceiptDeliver` as an internal service account.

**Release:**
- Push the OPL (release workflow).
- Run both setup Jobs (migrations, runtime role, workflows).

**Neon:** commerce's project needs compute restored before anything above can run.

### Other repositories
- **service-manufacturing:**
  - `RecordStockIn` needs a service-account path: take the tenant from the request, write no tuples in the check, and keep the idempotency key. Raw-material receipts can then be pushed instead of booked by hand.
  - Its property check writes Keto tuples from a request-supplied id; the same issue was removed here.
- **Payment Send:** `Send` ignores `reference_id`. Commerce's claim-and-lookup is the only guard against a double refund. Payment should deduplicate on the reference.
- **Console dependencies:** the console cannot resolve its dependencies until service-manufacturing (Dart SDK and UI packages), service-payment/ui/payment and service-notification/ui release protobuf 6 versions. After that, run console `pub get`, analyze, tests and `flutter build web`.
- **Procurement SDK publish:** `antinvestor_api_procurement` needs its first pub.dev publish done by hand before tag publishing works.

### Data and integrations
- **Old refunds:** orders cancelled as REFUNDED before this change were never paid back, and the ledger no longer reverses them. Review them.
- **Currency mismatches:** variants or price lists in a currency other than their shop's cannot be re-saved until corrected.
- **Webhook receivers:** they must verify the new `<timestamp>.<body>` signature and must have a secret.
- **Hugo shortcode:** it now takes `slug`, `apiUrl` and `mediaBaseUrl`.

### Known limits
- **Stuck refunds:** a refund payment that fails stays `REFUND_PENDING` for staff. There is no automatic resend.
- **Ledger booking day:** checkout sessions carry no completion time, so a payment is booked on the day commerce noticed it.
- **Page-load limit:** the storefront GET limit (120 per minute per visitor) is per instance. Checkout limits are shared.
- **Console permissions:** they reflect partition roles in the token only. Per-shop grants are enforced by the server but not reflected in the UI.
