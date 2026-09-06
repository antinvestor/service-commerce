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

## How the calls are authenticated

No credential is stored in trustage. Trustage's HTTP adapter uses the Frame
HTTP client, which attaches trustage's own service-account token (OAuth2
private-key JWT via Hydra) to every outbound request, exactly as every other
service-to-service call on the platform. Commerce accepts that identity when:

1. trustage's OAuth client lists `https://api.stawi.org/commerce` as a
   resource audience (tenancy: `oauth_client_recipients`), and its Cloud Run
   config requests `/commerce` in `OAUTH2_REQUESTED_AUDIENCES`;
2. trustage's service account holds `ledger_post` in the `service_commerce`
   namespace (tenancy: `service_account_authorization_grants`), which the
   tenancy reconciler turns into the Keto service tuples the interceptors
   check.

Both are seeded in service-authentication's tenancy migrations and in
cloud.deployment's `operations-trustage` app.
