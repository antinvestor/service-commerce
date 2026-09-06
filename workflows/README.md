# Scheduled automations

These workflow documents are registered with the trustage orchestrator by the
commerce setup job (`workflows.RegisterSync`) whenever `TRUSTAGE_SERVICE_URI`
is configured. Trustage runs them on the cron in each file and calls back into
commerce over Connect JSON.

| Workflow | Cron | Calls |
|---|---|---|
| `commerce.reconcile_payments` | every 5 minutes | `ReconcilePayments` — settles completed checkout sessions, expires unpaid reservations |
| `commerce.end_of_day_ledger` | 00:15 shop time | `RunEndOfDayLedger` — one balanced ledger transaction per shop per trading day |

`${COMMERCE_URI}` is substituted from `COMMERCE_SERVICE_URI` at registration.
The `credentials.api_token` reference resolves to the trustage credential that
holds a service token with the `service_commerce` `ledger_post` permission;
create it in trustage as `api_token` on the workflows' credential set.
