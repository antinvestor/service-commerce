# Scheduled automations

These workflow documents are embedded into the commerce binary
(`workflows/embed.go`) and registered with the trustage orchestrator by the
setup job (`apps/default/service/workflows`), the same way the notification
templates in `pkg/messages` are: declared once in the repository, synced
idempotently on every deploy. Trustage runs them on the cron in each file and
calls back into commerce over Connect JSON.

| Workflow | Cron | Calls |
|---|---|---|
| `commerce.reconcile_payments` | every 30 minutes | `ReconcilePayments`: applies completed checkout sessions (whole orders and instalments), expires unpaid reservations, flags or cancels part-paid orders past their balance deadline, retries order-event webhooks |
| `commerce.end_of_day_ledger` | 00:15 shop time | `RunEndOfDayLedger`: one balanced ledger transaction per shop per trading day, booking every instalment on the day it was received |
| `procurement.deliver_received_stock` (`procurement/`) | hourly | procurement's `GoodsReceiptDeliver`: pushes goods receipt lines whose stock has not reached commerce yet; each line lands once |

Procurement's documents live in `procurement/`, are embedded into the
procurement binary and synced by its setup job with the same code
(`pkg/workflows`), named `procurement.*` and calling back into
`${PROCUREMENT_URI}` (`PROCUREMENT_SERVICE_URI`). Trustage needs the
`/procurement` audience and `goods_receipt_deliver` in `service_procurement`.

## What the sync does

1. Loads every `*.json` document and validates all of them before sending
   anything: the name must start with `commerce.`, names must be unique,
   there must be at least one entry under `schedules` with a `cron_expr`
   (trustage's `ScheduleSpec`; without one a workflow activates and never
   runs), and no `${...}` placeholder may remain.
2. Substitutes `${COMMERCE_URI}` from `COMMERCE_SERVICE_URI`. An empty
   address is refused rather than registering callbacks that cannot work.
3. Submits each document. `CreateWorkflow` is idempotent by name: an
   unchanged document returns the live version, a changed one becomes the
   next version, which the sync activates (retiring the previous version and
   arming its schedules).
4. Archives active `commerce.*` workflows that are no longer shipped, so
   deleting a document here stops its schedule on the next deploy. Other
   services' workflows are never touched.

The step is named `trustage-workflows` and is warn-only: a trustage outage is
logged at ERROR and the setup plan continues, so it never blocks a rollout
(pass `workflows.Required()` to make it fatal). Without `TRUSTAGE_SERVICE_URI`
it logs and skips. The setup job builds only the trustage client.

Editing a document here and re-running the setup job is the whole rollout.
Step input templates only see the trigger payload, not earlier steps'
output, so keep each workflow to a single HTTP step.

## How the calls are authenticated

No credential is stored in trustage. Trustage's HTTP adapter uses the Frame
HTTP client, which attaches trustage's own service-account token (OAuth2
private-key JWT via Hydra) to every outbound request, exactly as every other
service-to-service call on the platform. Commerce accepts that identity when:

1. trustage's OAuth client lists `https://api.stawi.org/commerce` as a
   resource audience (tenancy: `oauth_client_recipients`), and its Cloud Run
   config requests `/commerce` in `OAUTH2_REQUESTED_AUDIENCES`;
2. trustage's service account holds `ledger_post` and `shops_list` in the
   `service_commerce` namespace (tenancy:
   `service_account_authorization_grants`), which the tenancy reconciler
   turns into the Keto service tuples the interceptors check.

Both are seeded in service-authentication's tenancy migrations and in
cloud.deployment's `operations-trustage` app.
