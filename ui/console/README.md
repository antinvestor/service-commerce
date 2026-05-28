# Console

Back-office Flutter application that composes the commerce and manufacturing
widget packages (plus payments, notifications, identity, auth, profile) into a
single shell with a dashboard, role-aware navigation, and a `GoRouter`-based
module composition.

## Composition

The app pulls `RouteModule` implementations from each domain package and merges
their routes under a single `GoRouter`. See `lib/src/app.dart`.

| Domain          | Package                       | Route prefix              |
| --------------- | ----------------------------- | ------------------------- |
| Catalog         | `antinvestor_ui_catalog`      | `/catalog`                |
| Customers       | `antinvestor_ui_customers`    | `/customers`              |
| Orders          | `antinvestor_ui_orders`       | `/orders`                 |
| Pricing         | `antinvestor_ui_pricing`      | `/pricing`                |
| Procurement     | `antinvestor_ui_procurement`  | `/procurement` (TODO)     |
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

`shopId` and `propertyId` are placeholders today (`'shop-1'`, `'property-1'`);
the production version will resolve them from user context.

## Run

```bash
cd ui/console
flutter create . --platforms=web,android
flutter pub get
flutter run -d chrome
```
