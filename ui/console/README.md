# Console

Back-office Flutter application that composes the commerce and manufacturing
widget packages (plus payments, notifications, identity, auth, profile) into a
single shell with a dashboard, role-aware navigation, and a `GoRouter`-based
module composition.

## Composition

The app pulls `RouteModule` implementations from each domain package and merges
their routes under a single `GoRouter`. See `lib/app.dart` and
`lib/core/router/app_router.dart`. The app shell follows the thesa pattern:
`lib/core/{auth,router,theme,widgets,services,config}` for cross-cutting
infrastructure and `lib/features/{auth,dashboard,settings}` for top-level
screens.

| Domain          | Package                       | Route prefix              |
| --------------- | ----------------------------- | ------------------------- |
| Catalog         | `antinvestor_ui_catalog`      | `/catalog`                |
| Customers       | `antinvestor_ui_customers`    | `/customers`              |
| Orders          | `antinvestor_ui_orders`       | `/orders`                 |
| Pricing         | `antinvestor_ui_pricing`      | `/pricing`                |
| Procurement     | `antinvestor_ui_procurement`  | `/procurement`            |
| Inventory       | `antinvestor_ui_inventory`    | `/inventory`              |
| Recipes         | `antinvestor_ui_recipes`      | `/recipes`                |
| Production      | `antinvestor_ui_production`   | `/production`             |
| Equipment       | `antinvestor_ui_equipment`    | `/equipment`              |
| Cold chain      | `antinvestor_ui_coldchain`    | `/coldchain`              |
| Quality         | `antinvestor_ui_quality`      | `/quality`                |
| Waste           | `antinvestor_ui_waste`        | `/waste`                  |
| Costing         | `antinvestor_ui_costing`      | `/costing`                |
| Demand          | `antinvestor_ui_demand`       | `/demand`                 |
| Traceability    | `antinvestor_ui_traceability` | `/traceability`           |
| Shelf life      | `antinvestor_ui_shelflife`    | `/shelflife`              |
| Profile         | `antinvestor_ui_profile`      | `/profiles`               |
| Auth activity   | `antinvestor_ui_auth`         | `/services/auth`          |
| Notifications   | `antinvestor_ui_notification` | `/notifications`          |
| Payments        | `antinvestor_ui_payment`      | `/payments`               |
| Identity        | `antinvestor_ui_identity`     | (screens only — no module) |

`shopId` and `propertyId` are exposed by `tenantScopeProvider`
(`lib/core/auth/tenant_context_provider.dart`):

- **Shop** — shop ids are generated server-side by `CreateShop`, so the console
  lists the caller's shops with the commerce `ListShops` RPC
  (`lib/core/auth/active_shop_provider.dart`) and uses the first active one.
  When the operator can see several shops, the switcher in the app header (and
  in **Settings → Shop**) changes the active shop.
- **Property** — the active branch, falling back to the organization, then the
  partition (from the tenancy context or the `partition_id` claim).

Route modules are built for that scope in `buildConsoleModules`; the router is
rebuilt, keeping the current location, whenever the shop or property changes.

The shop itself is managed from **Settings → Shop**, which wires the commerce
`ListShops` / `CreateShop` / `UpdateShop` RPCs. A newly created shop becomes the
active shop.

Deep links survive sign-in: while auth resolves (or the user signs in) the
requested location rides along as `?from=` on `/splash` / `/login`, and the
router returns there once the user is authenticated.

## Run

```bash
cd ui/console
flutter create . --platforms=web,android
flutter pub get
flutter run -d chrome
```
