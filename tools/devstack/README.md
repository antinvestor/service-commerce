# Running commerce locally

This directory runs commerce, the console and the public storefront on one
machine. Shops, products, orders, payments, Keto authorization and the
database are all real. A small program, `devstack`, stands in for the
platform services around them:

| Piece | Where | What it does |
|---|---|---|
| Postgres 17 | `127.0.0.1:5433` | commerce database (`service_commerce`) and Keto's (`keto`) |
| Keto | `127.0.0.1:4466` read, `:4467` write | commerce's OPL (`opl/commerce`), merged into one file |
| commerce | `127.0.0.1:8081` | this service, built from source |
| devstack | `http://localhost:8090` | sign-in, hosted checkout, profiles, and the API gateway |
| console | `http://localhost:5173` | the built console, served by devstack |

What devstack provides:

- **Sign-in** (`/oauth2/...`, `/.well-known/...`). A minimal OpenID provider.
  Anyone can sign in with any name and email. Each person becomes an owner of
  the one dev tenant (`d0devtenant000000000/d0devpartition000000`), and
  devstack writes the same Keto tuples identity writes for staff. Ids are
  derived from the email, so signing in again later makes you the same person.
- **Hosted checkout** (`checkout.v1.CheckoutService`, `/pay/{ref}`). A payment
  page with *Pay* and *Cancel* buttons. No money moves.
- **Profiles** (`profile.v1.ProfileService`). Look up a person by contact,
  create one, and read one back: the profile calls commerce makes.
- **Gateway** (`/commerce/...`). Proxies to commerce with the prefix stripped
  and with CORS for local browser apps, as `api.stawi.org` does in production.
- **`GET /dev/token?email=...`**. Mints an access token for curl and scripts.

Notifications, ledger, trustage, settings and devices are left unconfigured;
commerce logs that each is disabled and carries on. The console's
manufacturing and procurement screens have no backend here, so they show
dashes and errors.

## First run

```sh
make dev-deps       # Postgres and Keto in Docker
make dev-stack      # devstack on :8090; leave it running
make dev-migrate    # in another terminal: create commerce's tables
make dev-commerce   # commerce on :8081; leave it running
make dev-seed       # in another terminal: a public demo shop with products
make dev-console    # build the console (a few minutes); then restart dev-stack
```

devstack has to be up before commerce starts, because commerce reads its
signing keys from devstack at startup. After `make dev-console`, restart
`make dev-stack` so it serves the console on :5173.

## Try it

- **Sell.** Open <http://localhost:5173> and sign in. Your name and email are
  enough. In **Catalog**, add a product and a variant with a price and stock.
  **Settings → Shop** turns the public storefront on and shows its link.
- **Buy.** Open <http://localhost:8090/commerce/shop/corner>, pick quantities,
  give a name and an email or phone number, and continue to payment. *Pay*
  completes it and *Cancel* abandons it; either way you land back on the
  storefront with the outcome. The shop takes instalments, so you can pay a
  deposit and settle the balance later from the order in the console
  (**Sales**).
- **Script it.**

  ```sh
  TOKEN=$(curl -s 'localhost:8090/dev/token?email=owner@dev.local' | jq -r .access_token)
  curl -s localhost:8090/commerce/commerce.v1.CommerceService/ListShops \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{}'
  ```

## Notes

- Commerce's settings are in `commerce.env`. Its `WEBHOOK_SECRET_KEY` is a
  fixed, public value: fine for local data, never for a deployment.
- devstack keeps its signing key in `.tmp/devstack/` and everything else in
  memory. After a restart, sign in again. Profiles of earlier guest buyers are
  forgotten, but their orders are not.
- Payment reconciliation runs on trustage's schedule in production. Locally
  it runs only when called, so stock on unpaid orders stays reserved until you
  cancel the order or call `ReconcilePayments`.
- `make dev-down` stops the containers and keeps the data.
  `docker compose -f tools/devstack/compose.yaml down -v` wipes it.
- `console.sh` explains why the console is built in a scratch workspace with
  two sibling repositories pinned.
