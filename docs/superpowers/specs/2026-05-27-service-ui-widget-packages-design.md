# Service UI Widget Packages Design Spec

## 1. Overview

This spec defines 16 independently-usable Flutter widget packages for the
antinvestor manufacturing/commerce platform. Each package follows the exact
conventions established by `antinvestor_ui_profile`: barrel exports, Riverpod
providers, Connect RPC transport, `RouteModule`-based routing via
`antinvestor_ui_core`, and card-based action-oriented UX.

### Repositories

| Repository | Packages |
|---|---|
| `service-commerce/ui/` | `ui_catalog`, `ui_customers`, `ui_orders`, `ui_procurement`, `ui_pricing` |
| `service-manufacturing/ui/` | `ui_inventory`, `ui_recipes`, `ui_production`, `ui_equipment`, `ui_coldchain`, `ui_quality`, `ui_waste`, `ui_costing`, `ui_demand`, `ui_traceability`, `ui_shelflife` |

### Shared Dependencies (all 16 packages)

```yaml
dependencies:
  flutter:
    sdk: flutter
  antinvestor_ui_core: ^0.4.0
  connectrpc: ^1.0.0
  flutter_riverpod: ^3.3.1
  go_router: ^17.2.0
  protobuf: ^4.2.0
  riverpod_annotation: ^4.0.2
```

### Design Principles

- **Action-oriented** -- guided step-by-step flows, not CRUD tables
- **Card-based** -- stock, orders, batches shown as visual cards with status colors
- **Warning-driven** -- expiry alerts, low stock warnings, overdue payments are first-class widgets
- **Minimal typing** -- pickers, selectors, big buttons instead of text fields; auto-fill defaults (today's date, logged-in user, auto-generated IDs)
- **Confirmation screens** -- every destructive/important action gets a confirmation widget
- **Color status** -- Green (good), Yellow (warning), Red (problem), Grey (draft/inactive)
- **East Africa context** -- UGX/KES currency formatting via `AmountDisplay` from ui_core, phone number formatting, WhatsApp sharing

### File Path Convention

Every package follows this layout:

```
lib/
  antinvestor_ui_{name}.dart              # barrel export
  src/
    providers/
      {name}_transport_provider.dart      # Transport + ServiceClient providers
      {name}_providers.dart               # Domain providers (search, getById, notifiers)
    screens/
      {screen_name}_screen.dart           # Full-page screens
    widgets/
      {widget_name}.dart                  # Composable widgets
    routing/
      {name}_route_module.dart            # extends RouteModule
```

### Transport Provider Template

Every package creates its transport provider following this pattern:

```dart
import 'package:antinvestor_api_{service}/antinvestor_api_{service}.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _{name}Url = String.fromEnvironment(
  '{NAME}_URL',
  defaultValue: 'https://api.antinvestor.com/{service}',
);

final {name}TransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _{name}Url);
});

final {name}ServiceClientProvider = Provider<{Service}ServiceClient>((ref) {
  final transport = ref.watch({name}TransportProvider);
  return {Service}ServiceClient(transport);
});
```

### Widget Card Template

All card widgets follow this visual pattern:

```dart
class ThingCard extends StatelessWidget {
  const ThingCard({super.key, required this.thing, this.onTap});
  final ThingObject thing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: /* ... */,
        ),
      ),
    );
  }
}
```

---

## 2. Package 1 — `antinvestor_ui_catalog`

### 2.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_catalog` |
| Description | Product catalog display, variant selection, and catalog management |
| Location | `service-commerce/ui/catalog/` |
| Dart SDK prerequisite | `antinvestor_api_commerce` (exists at `sdk/dart/commerce/`) |
| Service URL env var | `COMMERCE_URL` |
| Service client | `CommerceServiceClient` |

### 2.2 Additional Dependencies

```yaml
antinvestor_api_commerce: ^1.0.0
```

### 2.3 Transport Provider

| Provider | Type | Purpose |
|---|---|---|
| `catalogTransportProvider` | `Provider<Transport>` | Connect transport for commerce service |
| `catalogServiceClientProvider` | `Provider<CommerceServiceClient>` | Typed RPC client |

File: `lib/src/providers/catalog_transport_provider.dart`

### 2.4 Providers

File: `lib/src/providers/catalog_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `productSearchProvider` | `FutureProvider.family<List<Product>, ({String shopId, String query})>` | Search products in a shop by name/description |
| `productByIdProvider` | `FutureProvider.family<Product, String>` | Get single product by ID |
| `productListProvider` | `FutureProvider.family<List<Product>, String>` | List all products for a shop ID |
| `productVariantsByProductProvider` | `FutureProvider.family<List<ProductVariant>, String>` | List variants for a product ID |
| `productNotifierProvider` | `NotifierProvider<ProductNotifier, AsyncValue<void>>` | Create/update products |
| `variantNotifierProvider` | `NotifierProvider<VariantNotifier, AsyncValue<void>>` | Create/update variants |

### 2.5 Screens

File prefix: `lib/src/screens/`

| Screen | File | Params | Purpose |
|---|---|---|---|
| `CatalogBrowseScreen` | `catalog_browse_screen.dart` | `shopId` | Card grid of products with search, status filter chips, and "Add Product" FAB |
| `ProductDetailScreen` | `product_detail_screen.dart` | `productId` | Product info, variant list as cards, stock summary per variant, edit/archive actions |
| `ProductCreateScreen` | `product_create_screen.dart` | `shopId` | Step flow: name/description -> attributes -> media upload -> review & create |
| `ProductEditScreen` | `product_edit_screen.dart` | `productId` | Edit product fields with confirmation before save |
| `VariantCreateScreen` | `variant_create_screen.dart` | `productId` | Guided flow: SKU auto-gen, name, price picker (numeric keypad), attributes -> review |
| `VariantEditScreen` | `variant_edit_screen.dart` | `variantId` | Edit variant fields; price change shows old vs new with confirmation |
| `CatalogAnalyticsScreen` | `catalog_analytics_screen.dart` | `shopId` | Product count, active/inactive breakdown, top variants by stock |

### 2.6 Widgets

File prefix: `lib/src/widgets/`

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `ProductCard` | `product_card.dart` | `Product product`, `VoidCallback? onTap` | Card with product image thumbnail, name, status badge (Green=active, Grey=inactive, Red=archived), variant count chip, fulfilment type icon |
| `ProductGrid` | `product_grid.dart` | `String shopId`, `ValueChanged<Product>? onProductSelected` | Responsive grid of `ProductCard` widgets with pull-to-refresh; uses `productListProvider` |
| `VariantCard` | `variant_card.dart` | `ProductVariant variant`, `VoidCallback? onTap` | Card showing SKU, variant name, price via `AmountDisplay`, stock quantity with color (Green >10, Yellow 1-10, Red 0), status badge |
| `VariantSelector` | `variant_selector.dart` | `String productId`, `ValueChanged<ProductVariant> onSelected`, `String? selectedVariantId` | Horizontal scrollable chip list of variants; tapping one shows detail bottom sheet with price and stock; "Select" button calls onSelected |
| `ProductStatusBadge` | `product_status_badge.dart` | `ProductStatus status` | Colored pill: Green=ACTIVE, Grey=INACTIVE, Red=ARCHIVED |
| `VariantStatusBadge` | `variant_status_badge.dart` | `ProductVariantStatus status` | Colored pill: Green=ACTIVE, Grey=DISABLED |
| `ProductSearchSelect` | `product_search_select.dart` | `String shopId`, `ValueChanged<Product> onSelected`, `String label` | Type-ahead search field with overlay dropdown showing `ProductCard` items (mirrors `ProfileSearchSelect` pattern) |
| `VariantPriceTile` | `variant_price_tile.dart` | `ProductVariant variant` | ListTile showing variant name, SKU as subtitle, trailing `AmountDisplay` with price |
| `FulfilmentTypeBadge` | `fulfilment_type_badge.dart` | `FulfilmentType type` | Icon + label: truck icon=PHYSICAL, cloud icon=DIGITAL, dash=NONE |
| `ProductQuickAdd` | `product_quick_add.dart` | `String shopId`, `VoidCallback? onCreated` | Bottom sheet with minimal fields (name, first variant name, price) for rapid product creation |

### 2.7 Route Module

File: `lib/src/routing/catalog_route_module.dart`

```dart
class CatalogRouteModule extends RouteModule {
  @override String get moduleId => 'catalog';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/catalog',
      builder: (_, state) => CatalogBrowseScreen(
        shopId: state.uri.queryParameters['shopId'] ?? '',
      ),
      routes: [
        GoRoute(path: 'analytics', builder: (_, state) => CatalogAnalyticsScreen(...)),
        GoRoute(path: 'new', builder: (_, state) => ProductCreateScreen(...)),
        GoRoute(
          path: ':productId',
          builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['productId']!),
          routes: [
            GoRoute(path: 'edit', builder: (_, state) => ProductEditScreen(...)),
            GoRoute(path: 'variants/new', builder: (_, state) => VariantCreateScreen(...)),
            GoRoute(path: 'variants/:variantId/edit', builder: (_, state) => VariantEditScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'catalog', label: 'Catalog', icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront, route: '/catalog',
      requiredPermissions: {'catalog_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/catalog': {'catalog_view'},
    '/catalog/new': {'catalog_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(key: 'catalog_view', label: 'View Catalog', scope: PermissionScope.service),
      PermissionEntry(key: 'catalog_manage', label: 'Manage Catalog', scope: PermissionScope.action),
      PermissionEntry(key: 'variant_manage', label: 'Manage Variants', scope: PermissionScope.action),
    ],
  );
}
```

### 2.8 Barrel Export

File: `lib/antinvestor_ui_catalog.dart`

```dart
// Routing
export 'src/routing/catalog_route_module.dart';
// Screens
export 'src/screens/catalog_browse_screen.dart';
export 'src/screens/product_detail_screen.dart';
export 'src/screens/product_create_screen.dart';
export 'src/screens/product_edit_screen.dart';
export 'src/screens/variant_create_screen.dart';
export 'src/screens/variant_edit_screen.dart';
export 'src/screens/catalog_analytics_screen.dart';
// Widgets
export 'src/widgets/product_card.dart';
export 'src/widgets/product_grid.dart';
export 'src/widgets/variant_card.dart';
export 'src/widgets/variant_selector.dart';
export 'src/widgets/product_status_badge.dart';
export 'src/widgets/variant_status_badge.dart';
export 'src/widgets/product_search_select.dart';
export 'src/widgets/variant_price_tile.dart';
export 'src/widgets/fulfilment_type_badge.dart';
export 'src/widgets/product_quick_add.dart';
// Providers
export 'src/providers/catalog_transport_provider.dart';
export 'src/providers/catalog_providers.dart';
```

### 2.9 Internal Reuse

None -- this is a leaf package with no UI dependencies on other service packages.

---

## 3. Package 2 — `antinvestor_ui_customers`

### 3.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_customers` |
| Description | Customer management wrapping profile UI with commerce-specific additions |
| Location | `service-commerce/ui/customers/` |
| Dart SDK prerequisite | `antinvestor_api_commerce` (exists) |
| Service URL env var | `COMMERCE_URL` |
| Service client | `CommerceServiceClient` (for commerce-specific queries) |

### 3.2 Additional Dependencies

```yaml
antinvestor_api_commerce: ^1.0.0
antinvestor_ui_profile: ^0.2.0   # REUSES profile widgets
```

### 3.3 Transport Provider

Reuses `catalogTransportProvider` for commerce calls. Profile transport is inherited from `antinvestor_ui_profile`.

File: `lib/src/providers/customer_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `customerTransportProvider` | `Provider<Transport>` | Connect transport for commerce service |
| `customerServiceClientProvider` | `Provider<CommerceServiceClient>` | Typed RPC client for customer-specific commerce queries |

### 3.4 Providers

File: `lib/src/providers/customer_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `customerSearchProvider` | `FutureProvider.family<List<ProfileObject>, String>` | Delegates to `profileSearchProvider` from ui_profile; filters to customer-type profiles |
| `customerByIdProvider` | `FutureProvider.family<ProfileObject, String>` | Delegates to `profileByIdProvider` |
| `customerOrderHistoryProvider` | `FutureProvider.family<List<Order>, String>` | List orders for a customer profile ID |
| `customerBalanceProvider` | `FutureProvider.family<Money, String>` | Outstanding balance for a customer |
| `customerNotifierProvider` | `NotifierProvider<CustomerNotifier, AsyncValue<void>>` | Create customer (creates profile + commerce link) |

### 3.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `CustomerListScreen` | `customer_list_screen.dart` | `shopId` | Card list of customers with search, balance warning badges, credit status filter chips |
| `CustomerDetailScreen` | `customer_detail_screen.dart` | `customerId` | Reuses `ProfileCard` at top; tabs for: Orders, Balance, Notes, Location |
| `CustomerCreateScreen` | `customer_create_screen.dart` | `shopId` | Step flow: search existing profile -> if not found, create new -> add customer-specific fields (credit limit, payment terms) -> confirm |
| `CustomerNotesScreen` | `customer_notes_screen.dart` | `customerId` | Timeline of customer interactions and notes |

### 3.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `CustomerCard` | `customer_card.dart` | `ProfileObject profile`, `Money? balance`, `VoidCallback? onTap` | Wraps `ProfileCard` from ui_profile; appends trailing balance display via `AmountDisplay` (Red if overdue), credit badge |
| `CustomerSearchSelect` | `customer_search_select.dart` | `ValueChanged<ProfileObject> onSelected`, `String label` | Wraps `ProfileSearchSelect` from ui_profile; adds customer-type filter; shows balance in results |
| `CustomerBalanceCard` | `customer_balance_card.dart` | `String customerId` | Card showing total owed, last payment date, days overdue; Green/Yellow/Red status stripe |
| `CustomerCreditBadge` | `customer_credit_badge.dart` | `Money balance`, `Money creditLimit` | Pill badge: Green if within limit, Yellow if >80%, Red if exceeded |
| `CustomerLocationPicker` | `customer_location_picker.dart` | `ValueChanged<String> onLocationSelected`, `String? initialAddress` | Map picker optimized for East Africa; falls back to address text input; reuses `AddressTile` from ui_profile for display |
| `PaymentHistoryTile` | `payment_history_tile.dart` | `Payment payment` | ListTile with date, amount via `AmountDisplay`, payment method icon, status badge |
| `WhatsAppShareButton` | `whatsapp_share_button.dart` | `String phoneNumber`, `String message` | Formatted "Share via WhatsApp" button that launches wa.me URL with pre-filled message; handles UG/KE phone formatting |
| `CustomerQuickActions` | `customer_quick_actions.dart` | `String customerId` | Row of action chips: "New Order", "Record Payment", "Send Message", "View Location" |

### 3.7 Route Module

File: `lib/src/routing/customer_route_module.dart`

```dart
class CustomerRouteModule extends RouteModule {
  @override String get moduleId => 'customers';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/customers',
      builder: (_, state) => CustomerListScreen(shopId: state.uri.queryParameters['shopId'] ?? ''),
      routes: [
        GoRoute(path: 'new', builder: (_, state) => CustomerCreateScreen(...)),
        GoRoute(
          path: ':customerId',
          builder: (_, state) => CustomerDetailScreen(customerId: state.pathParameters['customerId']!),
          routes: [
            GoRoute(path: 'notes', builder: (_, state) => CustomerNotesScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'customers', label: 'Customers', icon: Icons.groups_outlined,
      activeIcon: Icons.groups, route: '/customers',
      requiredPermissions: {'customer_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/customers': {'customer_view'},
    '/customers/new': {'customer_create'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(key: 'customer_view', label: 'View Customers', scope: PermissionScope.service),
      PermissionEntry(key: 'customer_create', label: 'Create Customers', scope: PermissionScope.action),
      PermissionEntry(key: 'customer_update', label: 'Update Customers', scope: PermissionScope.action),
    ],
  );
}
```

### 3.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_profile` | `ProfileCard`, `ContactListTile`, `AddressTile`, `ProfileSearchSelect`, `ProfileBadgeById`, `profileSearchProvider`, `profileByIdProvider` | `CustomerCard` wraps `ProfileCard` adding balance/credit. `CustomerSearchSelect` wraps `ProfileSearchSelect` with customer filtering. `CustomerDetailScreen` uses `ContactListTile` and `AddressTile` in the profile tab. |

---

## 4. Package 3 — `antinvestor_ui_orders`

### 4.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_orders` |
| Description | Cart, checkout, order management, and fulfilment tracking |
| Location | `service-commerce/ui/orders/` |
| Dart SDK prerequisite | `antinvestor_api_commerce` (exists) |
| Service URL env var | `COMMERCE_URL` |
| Service client | `CommerceServiceClient` |

### 4.2 Additional Dependencies

```yaml
antinvestor_api_commerce: ^1.0.0
antinvestor_ui_catalog: ^0.1.0    # product/variant widgets
antinvestor_ui_customers: ^0.1.0  # customer selection
```

### 4.3 Transport Provider

File: `lib/src/providers/order_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `orderTransportProvider` | `Provider<Transport>` | Connect transport for commerce service |
| `orderServiceClientProvider` | `Provider<CommerceServiceClient>` | Typed RPC client |

### 4.4 Providers

File: `lib/src/providers/order_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `orderSearchProvider` | `FutureProvider.family<List<Order>, ({String shopId, String query})>` | Search orders by number, customer name |
| `orderByIdProvider` | `FutureProvider.family<Order, String>` | Get single order |
| `orderListProvider` | `FutureProvider.family<List<Order>, ({String shopId, OrderStatus? status})>` | List orders with optional status filter |
| `cartByIdProvider` | `FutureProvider.family<Cart, String>` | Get active cart |
| `fulfilmentByIdProvider` | `FutureProvider.family<Fulfilment, String>` | Get fulfilment details |
| `orderNotifierProvider` | `NotifierProvider<OrderNotifier, AsyncValue<void>>` | Create order (direct or from cart), cancel |
| `cartNotifierProvider` | `NotifierProvider<CartNotifier, AsyncValue<void>>` | Create cart, add/remove lines |
| `fulfilmentNotifierProvider` | `NotifierProvider<FulfilmentNotifier, AsyncValue<void>>` | Create/update fulfilment |

File: `lib/src/providers/checkout_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `checkoutStateProvider` | `NotifierProvider<CheckoutNotifier, CheckoutState>` | Manages multi-step checkout flow state: customer, items, review, confirm |
| `checkoutTotalProvider` | `Provider<Money>` | Computed total from checkout items |

### 4.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `OrderListScreen` | `order_list_screen.dart` | `shopId` | Card list of orders grouped by status tabs (Confirmed, Fulfilled, Cancelled); search bar; date range filter |
| `OrderDetailScreen` | `order_detail_screen.dart` | `orderId` | Order header card (customer, date, status, total), line item cards, fulfilment timeline, action buttons |
| `CheckoutFlowScreen` | `checkout_flow_screen.dart` | `shopId` | Guided 4-step flow: (1) Select customer -> (2) Add items -> (3) Review order -> (4) Confirm. Uses `CustomerSearchSelect` + `ProductGrid`/`VariantSelector` |
| `CartScreen` | `cart_screen.dart` | `cartId` | Cart line list with quantity adjusters (big +/- buttons), swipe to remove, running total, "Place Order" button |
| `FulfilmentCreateScreen` | `fulfilment_create_screen.dart` | `orderId` | Select lines to fulfil with quantity pickers; adds tracking number; confirmation before creation |
| `FulfilmentDetailScreen` | `fulfilment_detail_screen.dart` | `fulfilmentId` | Fulfilment status timeline, line items, tracking info |
| `OrderAnalyticsScreen` | `order_analytics_screen.dart` | `shopId` | Revenue chart, orders per day, average order value, top products |

### 4.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `OrderCard` | `order_card.dart` | `Order order`, `VoidCallback? onTap` | Card with order number, customer name (via `ProfileBadgeById`), date, total via `AmountDisplay`, status badge strip (Green=Fulfilled, Yellow=Confirmed, Red=Cancelled) |
| `OrderStatusBadge` | `order_status_badge.dart` | `OrderStatus status` | Colored pill with icon: check=Fulfilled, clock=Confirmed, x=Cancelled |
| `OrderLineTile` | `order_line_tile.dart` | `OrderLine line` | ListTile: product name, quantity x unit price = line total, variant SKU subtitle |
| `CartLineTile` | `cart_line_tile.dart` | `CartLine line`, `ValueChanged<int> onQuantityChanged`, `VoidCallback onRemove` | Card with product name, variant info, big +/- quantity buttons, swipe-to-delete, line subtotal |
| `CheckoutStepIndicator` | `checkout_step_indicator.dart` | `int currentStep`, `int totalSteps` | Horizontal step dots with labels: Customer, Items, Review, Confirm; active step highlighted |
| `OrderSummaryCard` | `order_summary_card.dart` | `List<OrderLine> lines`, `Money total` | Card summarizing line count, total via `AmountDisplay`, currency display (UGX/KES) |
| `FulfilmentStatusTimeline` | `fulfilment_status_timeline.dart` | `Fulfilment fulfilment` | Vertical timeline: Pending -> Preparing -> Packed -> Shipped -> Delivered; completed steps Green, current Yellow, future Grey |
| `PaymentStatusBadge` | `payment_status_badge.dart` | `PaymentStatus status` | Colored pill: Green=Paid, Yellow=Pending, Red=Failed, Grey=Refunded |
| `OrderConfirmationDialog` | `order_confirmation_dialog.dart` | `Order order`, `VoidCallback onConfirm` | Full-screen confirmation showing all details before placing order; "Confirm Order" button |
| `QuickOrderButton` | `quick_order_button.dart` | `String shopId`, `VoidCallback? onOrderCreated` | Large action button that launches `CheckoutFlowScreen` |

### 4.7 Route Module

File: `lib/src/routing/order_route_module.dart`

```dart
class OrderRouteModule extends RouteModule {
  @override String get moduleId => 'orders';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/orders',
      builder: (_, state) => OrderListScreen(shopId: state.uri.queryParameters['shopId'] ?? ''),
      routes: [
        GoRoute(path: 'analytics', builder: (_, state) => OrderAnalyticsScreen(...)),
        GoRoute(path: 'checkout', builder: (_, state) => CheckoutFlowScreen(...)),
        GoRoute(
          path: ':orderId',
          builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          routes: [
            GoRoute(path: 'fulfil', builder: (_, state) => FulfilmentCreateScreen(...)),
            GoRoute(path: 'fulfilments/:fulfilmentId', builder: (_, state) => FulfilmentDetailScreen(...)),
          ],
        ),
      ],
    ),
    GoRoute(path: '/cart/:cartId', builder: (_, state) => CartScreen(cartId: state.pathParameters['cartId']!)),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'orders', label: 'Orders', icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long, route: '/orders',
      requiredPermissions: {'order_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/orders': {'order_view'},
    '/orders/checkout': {'order_create'},
    '/orders/:orderId/fulfil': {'fulfilment_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(key: 'order_view', label: 'View Orders', scope: PermissionScope.service),
      PermissionEntry(key: 'order_create', label: 'Create Orders', scope: PermissionScope.action),
      PermissionEntry(key: 'order_cancel', label: 'Cancel Orders', scope: PermissionScope.action),
      PermissionEntry(key: 'fulfilment_manage', label: 'Manage Fulfilments', scope: PermissionScope.action),
    ],
  );
}
```

### 4.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_catalog` | `ProductGrid`, `VariantSelector`, `VariantPriceTile`, `productByIdProvider` | `CheckoutFlowScreen` step 2 uses `ProductGrid` for item browsing and `VariantSelector` for variant picking. `OrderLineTile` uses variant data from `productByIdProvider`. |
| `antinvestor_ui_customers` | `CustomerSearchSelect`, `CustomerCard`, `customerByIdProvider` | `CheckoutFlowScreen` step 1 uses `CustomerSearchSelect`. `OrderCard` displays customer via `ProfileBadgeById`. `OrderDetailScreen` shows `CustomerCard` in header. |

---

## 5. Package 4 — `antinvestor_ui_procurement`

### 5.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_procurement` |
| Description | Supplier management, purchase orders, and goods receipts |
| Location | `service-commerce/ui/procurement/` |
| Dart SDK prerequisite | `antinvestor_api_procurement` (needs generation from `service-commerce/proto/procurement/v1/`) |
| Service URL env var | `PROCUREMENT_URL` |
| Service client | `ProcurementServiceClient` |

### 5.2 Additional Dependencies

```yaml
antinvestor_api_procurement: ^1.0.0   # needs generation
antinvestor_ui_inventory: ^0.1.0      # inventory item pickers
antinvestor_ui_profile: ^0.2.0        # supplier profile widgets
```

### 5.3 Transport Provider

File: `lib/src/providers/procurement_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `procurementTransportProvider` | `Provider<Transport>` | Connect transport |
| `procurementServiceClientProvider` | `Provider<ProcurementServiceClient>` | Typed RPC client |

### 5.4 Providers

File: `lib/src/providers/supplier_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `supplierSearchProvider` | `FutureProvider.family<List<Supplier>, String>` | Search suppliers by name |
| `supplierByIdProvider` | `FutureProvider.family<Supplier, String>` | Get single supplier |
| `supplierListProvider` | `FutureProvider.family<List<Supplier>, String>` | List suppliers for a property |
| `supplierItemsProvider` | `FutureProvider.family<List<SupplierItem>, String>` | List items a supplier provides |
| `supplierNotifierProvider` | `NotifierProvider<SupplierNotifier, AsyncValue<void>>` | Create/update suppliers |

File: `lib/src/providers/purchase_order_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `purchaseOrderSearchProvider` | `FutureProvider.family<List<PurchaseOrder>, ({String propertyId, String query})>` | Search POs |
| `purchaseOrderByIdProvider` | `FutureProvider.family<PurchaseOrder, String>` | Get PO with lines |
| `purchaseOrderListProvider` | `FutureProvider.family<List<PurchaseOrder>, ({String propertyId, PurchaseOrderStatus? status})>` | List POs with filter |
| `goodsReceiptByIdProvider` | `FutureProvider.family<GoodsReceipt, String>` | Get goods receipt |
| `purchaseOrderNotifierProvider` | `NotifierProvider<PurchaseOrderNotifier, AsyncValue<void>>` | Create/update/submit POs |
| `goodsReceiptNotifierProvider` | `NotifierProvider<GoodsReceiptNotifier, AsyncValue<void>>` | Create goods receipts |

### 5.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `SupplierListScreen` | `supplier_list_screen.dart` | `propertyId` | Card list of suppliers with rating filter chips (Preferred/Approved/Probation), type filter |
| `SupplierDetailScreen` | `supplier_detail_screen.dart` | `supplierId` | Supplier header using `ProfileCard`, items catalog, PO history, rating badge, payment terms |
| `SupplierCreateScreen` | `supplier_create_screen.dart` | `propertyId` | Step flow: search existing profile -> supplier type picker -> payment terms -> lead time -> confirm |
| `PurchaseOrderListScreen` | `po_list_screen.dart` | `propertyId` | PO cards grouped by status tabs; overdue POs highlighted Red; "New PO" FAB |
| `PurchaseOrderCreateScreen` | `po_create_screen.dart` | `propertyId`, `String? supplierId` | Guided flow: (1) Select supplier -> (2) Add items from supplier catalog with quantity/price -> (3) Set delivery date -> (4) Review & submit |
| `PurchaseOrderDetailScreen` | `po_detail_screen.dart` | `purchaseOrderId` | PO header, line items, receiving status per line, "Record Receipt" action button |
| `GoodsReceiptScreen` | `goods_receipt_screen.dart` | `purchaseOrderId` | Guided receiving: scan/select PO lines, enter received quantities (big number pad), flag damaged items, submit receipt |
| `ProcurementAnalyticsScreen` | `procurement_analytics_screen.dart` | `propertyId` | Spend by supplier, PO lead times, receiving accuracy, overdue POs |

### 5.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `SupplierCard` | `supplier_card.dart` | `Supplier supplier`, `VoidCallback? onTap` | Card with supplier name, type badge, rating stars/badge, lead time chip, outstanding PO count |
| `SupplierRatingBadge` | `supplier_rating_badge.dart` | `SupplierRating rating` | Colored pill: Gold=Preferred, Green=Approved, Yellow=Probation, Grey=Unrated |
| `SupplierSearchSelect` | `supplier_search_select.dart` | `ValueChanged<Supplier> onSelected` | Type-ahead search with overlay showing `SupplierCard` items |
| `PurchaseOrderCard` | `purchase_order_card.dart` | `PurchaseOrder po`, `VoidCallback? onTap` | Card with PO number, supplier name, total via `AmountDisplay`, expected date, status badge; Red border if overdue |
| `PurchaseOrderStatusBadge` | `po_status_badge.dart` | `PurchaseOrderStatus status` | Colored pill: Grey=Draft, Yellow=Submitted, Green=Confirmed/Received, Red=Cancelled |
| `PurchaseOrderLineTile` | `po_line_tile.dart` | `PurchaseOrderLine line` | ListTile: item name, ordered qty, received qty progress bar, unit price |
| `GoodsReceiptCard` | `goods_receipt_card.dart` | `GoodsReceipt receipt`, `VoidCallback? onTap` | Card with receipt date, received by, acceptance status badge, line count |
| `ReceivingQuantityInput` | `receiving_quantity_input.dart` | `double orderedQty`, `double alreadyReceived`, `ValueChanged<double> onChanged` | Large numeric display with +/- buttons, max capped at remaining quantity, visual progress bar |
| `OverduePOWarning` | `overdue_po_warning.dart` | `List<PurchaseOrder> overduePOs` | Dismissible warning banner: Red background, count of overdue POs, tap to filter |
| `SupplierItemPicker` | `supplier_item_picker.dart` | `String supplierId`, `ValueChanged<SupplierItem> onSelected` | List of available items from supplier with price and MOQ; tap to select |

### 5.7 Route Module

File: `lib/src/routing/procurement_route_module.dart`

```dart
class ProcurementRouteModule extends RouteModule {
  @override String get moduleId => 'procurement';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/procurement',
      builder: (_, state) => PurchaseOrderListScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'analytics', builder: (_, state) => ProcurementAnalyticsScreen(...)),
        GoRoute(path: 'suppliers', builder: (_, state) => SupplierListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => SupplierCreateScreen(...)),
            GoRoute(path: ':supplierId', builder: (_, state) => SupplierDetailScreen(...)),
          ],
        ),
        GoRoute(path: 'new', builder: (_, state) => PurchaseOrderCreateScreen(...)),
        GoRoute(
          path: ':poId',
          builder: (_, state) => PurchaseOrderDetailScreen(purchaseOrderId: state.pathParameters['poId']!),
          routes: [
            GoRoute(path: 'receive', builder: (_, state) => GoodsReceiptScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'procurement', label: 'Procurement', icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping, route: '/procurement',
      requiredPermissions: {'procurement_view'},
      children: [
        NavItem(id: 'purchase-orders', label: 'Purchase Orders', icon: Icons.description_outlined, route: '/procurement', requiredPermissions: {'procurement_view'}),
        NavItem(id: 'suppliers', label: 'Suppliers', icon: Icons.business_outlined, route: '/procurement/suppliers', requiredPermissions: {'supplier_view'}),
      ],
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/procurement': {'procurement_view'},
    '/procurement/new': {'procurement_create'},
    '/procurement/suppliers': {'supplier_view'},
    '/procurement/suppliers/new': {'supplier_create'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(key: 'procurement_view', label: 'View Procurement', scope: PermissionScope.service),
      PermissionEntry(key: 'procurement_create', label: 'Create Purchase Orders', scope: PermissionScope.action),
      PermissionEntry(key: 'procurement_receive', label: 'Record Goods Receipts', scope: PermissionScope.action),
      PermissionEntry(key: 'supplier_view', label: 'View Suppliers', scope: PermissionScope.feature),
      PermissionEntry(key: 'supplier_create', label: 'Manage Suppliers', scope: PermissionScope.action),
    ],
  );
}
```

### 5.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `InventoryItemPicker`, `StockLevelCard` | `PurchaseOrderCreateScreen` uses `InventoryItemPicker` when adding lines. `SupplierDetailScreen` shows current stock for supplier items. |
| `antinvestor_ui_profile` | `ProfileCard`, `ProfileSearchSelect` | `SupplierCreateScreen` uses `ProfileSearchSelect` to find/create the supplier's profile. `SupplierDetailScreen` header uses `ProfileCard`. |

---

## 6. Package 5 — `antinvestor_ui_pricing`

### 6.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_pricing` |
| Description | Price lists, discounts, overrides, and price resolution |
| Location | `service-commerce/ui/pricing/` |
| Dart SDK prerequisite | `antinvestor_api_pricing` (needs generation from `service-commerce/proto/pricing/v1/`) |
| Service URL env var | `PRICING_URL` |
| Service client | `PricingServiceClient` |

### 6.2 Additional Dependencies

```yaml
antinvestor_api_pricing: ^1.0.0       # needs generation
antinvestor_ui_catalog: ^0.1.0        # product/variant pickers
antinvestor_ui_customers: ^0.1.0      # customer group context
```

### 6.3 Transport Provider

File: `lib/src/providers/pricing_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `pricingTransportProvider` | `Provider<Transport>` | Connect transport |
| `pricingServiceClientProvider` | `Provider<PricingServiceClient>` | Typed RPC client |

### 6.4 Providers

File: `lib/src/providers/pricing_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `priceListsProvider` | `FutureProvider.family<List<PriceList>, String>` | List price lists for a shop |
| `priceListByIdProvider` | `FutureProvider.family<PriceList, String>` | Get price list with entries |
| `priceResolutionProvider` | `FutureProvider.family<ResolvedPrice, ({String variantId, String? customerId})>` | Resolve effective price for a variant+customer combination |
| `discountListProvider` | `FutureProvider.family<List<Discount>, String>` | List active discounts for a shop |
| `priceOverridesProvider` | `FutureProvider.family<List<PriceOverride>, String>` | Customer-specific price overrides |
| `priceListNotifierProvider` | `NotifierProvider<PriceListNotifier, AsyncValue<void>>` | Create/update price lists and entries |
| `discountNotifierProvider` | `NotifierProvider<DiscountNotifier, AsyncValue<void>>` | Create/update/deactivate discounts |

### 6.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `PriceListsScreen` | `price_lists_screen.dart` | `shopId` | Card list of price lists with effective date ranges, active/expired status badges |
| `PriceListDetailScreen` | `price_list_detail_screen.dart` | `priceListId` | List of price entries as cards; variant name, base price, list price, margin indicator; bulk edit mode |
| `PriceListCreateScreen` | `price_list_create_screen.dart` | `shopId` | Step flow: name -> effective dates -> add product variants with prices (uses `ProductSearchSelect`) -> review |
| `DiscountListScreen` | `discount_list_screen.dart` | `shopId` | Active discounts as cards: percentage/fixed amount, applicable products, date range, usage count |
| `DiscountCreateScreen` | `discount_create_screen.dart` | `shopId` | Form: discount type (percent/fixed), value, applicable products (multi-select from catalog), date range, usage limits |
| `PriceOverridesScreen` | `price_overrides_screen.dart` | `shopId` | Customer-specific overrides; grouped by customer; each showing variant, base price, override price |
| `PriceCheckerScreen` | `price_checker_screen.dart` | `shopId` | Select a product variant + optional customer -> shows resolved price with breakdown (base, list, discount, override) |

### 6.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `PriceListCard` | `price_list_card.dart` | `PriceList priceList`, `VoidCallback? onTap` | Card with name, date range, entry count, active/expired badge |
| `PriceEntryTile` | `price_entry_tile.dart` | `PriceEntry entry` | ListTile: variant name, base price crossed out if different, list price via `AmountDisplay`, margin percentage |
| `DiscountCard` | `discount_card.dart` | `Discount discount`, `VoidCallback? onTap` | Card: discount name, value (e.g. "15%" or "UGX 500"), remaining uses, expiry countdown |
| `DiscountBadge` | `discount_badge.dart` | `Discount discount` | Small pill showing discount value; Green if active, Grey if expired |
| `PriceBreakdownCard` | `price_breakdown_card.dart` | `ResolvedPrice resolved` | Card showing price resolution stack: Base -> List Price -> Discount -> Override -> Final Price; each layer with strikethrough of previous |
| `PriceComparisonTile` | `price_comparison_tile.dart` | `Money oldPrice`, `Money newPrice` | Side-by-side old (struck through) and new price; green arrow down if decrease, red arrow up if increase |
| `MarginIndicator` | `margin_indicator.dart` | `double marginPercent` | Colored bar: Green >30%, Yellow 10-30%, Red <10% |
| `BulkPriceEditor` | `bulk_price_editor.dart` | `List<PriceEntry> entries`, `ValueChanged<List<PriceEntry>> onChanged` | Editable card list with inline price input fields and percentage adjustment button |

### 6.7 Route Module

File: `lib/src/routing/pricing_route_module.dart`

```dart
class PricingRouteModule extends RouteModule {
  @override String get moduleId => 'pricing';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/pricing',
      builder: (_, state) => PriceListsScreen(shopId: state.uri.queryParameters['shopId'] ?? ''),
      routes: [
        GoRoute(path: 'new', builder: (_, state) => PriceListCreateScreen(...)),
        GoRoute(path: 'discounts', builder: (_, state) => DiscountListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => DiscountCreateScreen(...)),
          ],
        ),
        GoRoute(path: 'overrides', builder: (_, state) => PriceOverridesScreen(...)),
        GoRoute(path: 'checker', builder: (_, state) => PriceCheckerScreen(...)),
        GoRoute(path: ':priceListId', builder: (_, state) => PriceListDetailScreen(...)),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'pricing', label: 'Pricing', icon: Icons.sell_outlined,
      activeIcon: Icons.sell, route: '/pricing',
      requiredPermissions: {'pricing_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/pricing': {'pricing_view'},
    '/pricing/new': {'pricing_manage'},
    '/pricing/discounts/new': {'discount_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(key: 'pricing_view', label: 'View Pricing', scope: PermissionScope.service),
      PermissionEntry(key: 'pricing_manage', label: 'Manage Price Lists', scope: PermissionScope.action),
      PermissionEntry(key: 'discount_manage', label: 'Manage Discounts', scope: PermissionScope.action),
      PermissionEntry(key: 'override_manage', label: 'Manage Price Overrides', scope: PermissionScope.action),
    ],
  );
}
```

### 6.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_catalog` | `ProductSearchSelect`, `VariantPriceTile`, `productByIdProvider` | `PriceListCreateScreen` uses `ProductSearchSelect` to add variants. `PriceEntryTile` references variant data. |
| `antinvestor_ui_customers` | `CustomerSearchSelect`, `customerByIdProvider` | `PriceOverridesScreen` uses `CustomerSearchSelect` for customer-specific pricing. `PriceCheckerScreen` uses it for price resolution context. |

---

## 7. Package 6 — `antinvestor_ui_inventory`

### 7.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_inventory` |
| Description | Stock levels, add stock, adjustments, lot management, and expiry alerts |
| Location | `service-manufacturing/ui/inventory/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation from `service-manufacturing/proto/manufacturing/v1/`) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 7.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0   # needs generation
```

### 7.3 Transport Provider

File: `lib/src/providers/inventory_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `inventoryTransportProvider` | `Provider<Transport>` | Connect transport for manufacturing service |
| `inventoryServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 7.4 Providers

File: `lib/src/providers/inventory_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `inventoryItemSearchProvider` | `FutureProvider.family<List<InventoryItem>, ({String propertyId, String query})>` | Search inventory items |
| `inventoryItemByIdProvider` | `FutureProvider.family<InventoryItem, String>` | Get single item with current stock |
| `inventoryItemListProvider` | `FutureProvider.family<List<InventoryItem>, ({String propertyId, InventoryCategory? category})>` | List items with optional category filter |
| `stockBalanceProvider` | `FutureProvider.family<StockBalance, String>` | Current stock balance for an item |
| `stockLotsProvider` | `FutureProvider.family<List<StockLot>, String>` | Active lots for an item (with expiry dates) |
| `stockMovementsProvider` | `FutureProvider.family<List<StockMovement>, ({String itemId, int limit})>` | Recent stock movements for an item |
| `lowStockItemsProvider` | `FutureProvider.family<List<InventoryItem>, String>` | Items below reorder threshold for a property |
| `expiringLotsProvider` | `FutureProvider.family<List<StockLot>, ({String propertyId, int daysAhead})>` | Lots expiring within N days |
| `inventoryNotifierProvider` | `NotifierProvider<InventoryNotifier, AsyncValue<void>>` | Create/update inventory items |
| `stockAdjustmentNotifierProvider` | `NotifierProvider<StockAdjustmentNotifier, AsyncValue<void>>` | Record stock adjustments (add, remove, count correction) |

### 7.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `InventoryDashboardScreen` | `inventory_dashboard_screen.dart` | `propertyId` | Card grid: total items count, low stock warning count (Red), expiring lots count (Yellow), recent movements list; category filter chips |
| `InventoryItemListScreen` | `inventory_item_list_screen.dart` | `propertyId` | Card list of items: name, current stock, unit, category badge, stock level color bar |
| `InventoryItemDetailScreen` | `inventory_item_detail_screen.dart` | `itemId` | Item header card, stock level gauge, lot list with expiry dates, movement history timeline, action buttons |
| `InventoryItemCreateScreen` | `inventory_item_create_screen.dart` | `propertyId` | Step flow: name/SKU -> category picker -> unit picker -> reorder threshold -> opening stock -> confirm |
| `StockAdjustmentScreen` | `stock_adjustment_screen.dart` | `itemId` | Guided flow: select adjustment type (Add/Remove/Count) -> quantity (big number pad) -> reason picker -> lot selection (if applicable) -> confirm with signature |
| `StockAddScreen` | `stock_add_screen.dart` | `propertyId` | Scan/search item -> enter quantity (big buttons) -> optional lot/expiry -> confirm; designed for speed |
| `LotManagementScreen` | `lot_management_screen.dart` | `itemId` | List of lots as cards: lot number, quantity, expiry date, days remaining color bar; create new lot |
| `InventoryAnalyticsScreen` | `inventory_analytics_screen.dart` | `propertyId` | Stock value, turnover rate, shrinkage %, category breakdown chart |

### 7.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `StockLevelCard` | `stock_level_card.dart` | `InventoryItem item`, `StockBalance balance`, `VoidCallback? onTap` | Card: item name, large stock number, unit, progress bar to reorder point; Green if healthy, Yellow if approaching reorder, Red if below |
| `StockLevelBadge` | `stock_level_badge.dart` | `int quantity`, `int reorderPoint` | Small pill: quantity + color (Green/Yellow/Red based on threshold) |
| `InventoryItemPicker` | `inventory_item_picker.dart` | `String propertyId`, `ValueChanged<InventoryItem> onSelected`, `InventoryCategory? filterCategory` | Type-ahead search with overlay; shows item name, SKU, current stock; filtered by optional category |
| `InventoryItemCard` | `inventory_item_card.dart` | `InventoryItem item`, `VoidCallback? onTap` | Card: item name, SKU subtitle, category badge, stock level badge, unit chip |
| `LotCard` | `lot_card.dart` | `StockLot lot`, `VoidCallback? onTap` | Card: lot number, quantity, expiry date with countdown; Green if >30d, Yellow if 7-30d, Red if <7d or expired |
| `ExpiryAlertBanner` | `expiry_alert_banner.dart` | `List<StockLot> expiringLots` | Dismissible warning banner: Yellow/Red background, count of expiring lots, tap to see detail list |
| `LowStockAlertBanner` | `low_stock_alert_banner.dart` | `List<InventoryItem> lowStockItems` | Dismissible warning banner: Red background, count of low stock items, tap to navigate |
| `StockMovementTile` | `stock_movement_tile.dart` | `StockMovement movement` | ListTile: movement type icon (in=green arrow, out=red arrow, adjust=yellow), quantity, date, reference |
| `StockGauge` | `stock_gauge.dart` | `int current`, `int reorderPoint`, `int maxCapacity` | Circular gauge: current level vs max capacity, reorder point marked; Green/Yellow/Red fill |
| `CategoryBadge` | `category_badge.dart` | `InventoryCategory category` | Colored chip: RAW_MATERIAL=brown, PACKAGING=blue, FINISHED_GOOD=green, CONSUMABLE=grey |
| `QuantityInput` | `quantity_input.dart` | `double initialValue`, `String unit`, `ValueChanged<double> onChanged` | Large number display with big +/- buttons, unit label, optional decimal toggle |
| `AdjustmentReasonPicker` | `adjustment_reason_picker.dart` | `ValueChanged<String> onSelected` | Bottom sheet with predefined reasons: Received, Produced, Damaged, Expired, Count Correction, Other |

### 7.7 Route Module

File: `lib/src/routing/inventory_route_module.dart`

```dart
class InventoryRouteModule extends RouteModule {
  @override String get moduleId => 'inventory';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/inventory',
      builder: (_, state) => InventoryDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'analytics', builder: (_, state) => InventoryAnalyticsScreen(...)),
        GoRoute(path: 'items', builder: (_, state) => InventoryItemListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => InventoryItemCreateScreen(...)),
          ],
        ),
        GoRoute(path: 'add-stock', builder: (_, state) => StockAddScreen(...)),
        GoRoute(
          path: ':itemId',
          builder: (_, state) => InventoryItemDetailScreen(itemId: state.pathParameters['itemId']!),
          routes: [
            GoRoute(path: 'adjust', builder: (_, state) => StockAdjustmentScreen(...)),
            GoRoute(path: 'lots', builder: (_, state) => LotManagementScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'inventory', label: 'Inventory', icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2, route: '/inventory',
      requiredPermissions: {'inventory_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/inventory': {'inventory_view'},
    '/inventory/items/new': {'inventory_manage'},
    '/inventory/add-stock': {'inventory_manage'},
    '/inventory/:itemId/adjust': {'inventory_adjust'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'inventory_view', label: 'View Inventory', scope: PermissionScope.service),
      PermissionEntry(key: 'inventory_manage', label: 'Manage Inventory Items', scope: PermissionScope.action),
      PermissionEntry(key: 'inventory_adjust', label: 'Adjust Stock', scope: PermissionScope.action),
    ],
  );
}
```

### 7.8 Internal Reuse

None -- this is a leaf package. Many other manufacturing packages depend on it.

---

## 8. Package 7 — `antinvestor_ui_recipes`

### 8.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_recipes` |
| Description | Recipe CRUD, version management, BOM editor, and template library |
| Location | `service-manufacturing/ui/recipes/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 8.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_inventory: ^0.1.0      # BOM material selection
```

### 8.3 Transport Provider

File: `lib/src/providers/recipe_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `recipeTransportProvider` | `Provider<Transport>` | Connect transport |
| `recipeServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 8.4 Providers

File: `lib/src/providers/recipe_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `recipeSearchProvider` | `FutureProvider.family<List<Recipe>, ({String propertyId, String query})>` | Search recipes |
| `recipeByIdProvider` | `FutureProvider.family<Recipe, String>` | Get recipe with active version summary |
| `recipeListProvider` | `FutureProvider.family<List<Recipe>, ({String propertyId, RecipeStatus? status})>` | List recipes with status filter |
| `recipeVersionProvider` | `FutureProvider.family<RecipeVersion, String>` | Get version with full steps + materials |
| `recipeVersionListProvider` | `FutureProvider.family<List<RecipeVersion>, String>` | Version history for a recipe |
| `recipeTemplateListProvider` | `FutureProvider<List<RecipeTemplate>>` | Browse the template library |
| `recipeNotifierProvider` | `NotifierProvider<RecipeNotifier, AsyncValue<void>>` | Create recipe, update draft, publish version, clone template |

### 8.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `RecipeListScreen` | `recipe_list_screen.dart` | `propertyId` | Card list of recipes: name, output (e.g. "100L"), status badge, active version number; filter by status (Draft/Active/Archived) |
| `RecipeDetailScreen` | `recipe_detail_screen.dart` | `recipeId` | Recipe header, active version steps as vertical timeline, BOM materials list, version history tab, "Edit Draft" and "Publish" action buttons |
| `RecipeCreateScreen` | `recipe_create_screen.dart` | `propertyId` | Choice: start blank or clone from template; then: name -> output product (uses `InventoryItemPicker`) -> output quantity/unit -> creates with empty draft |
| `RecipeDraftEditorScreen` | `recipe_draft_editor_screen.dart` | `recipeId` | Full editor: reorderable step list, step detail editor (name, description, duration, checkpoint toggle, readings config), BOM editor below; save draft button |
| `RecipeStepEditorScreen` | `recipe_step_editor_screen.dart` | `recipeId`, `int stepSequence` | Focused editor for a single step: all fields, reading spec builder (type picker, unit, min/max), alarm rule builder |
| `BomEditorScreen` | `bom_editor_screen.dart` | `recipeId` | BOM line list with add button that launches `InventoryItemPicker`; per-line: quantity input, unit, tolerance slider, optional toggle |
| `TemplateLibraryScreen` | `template_library_screen.dart` | none | Browse templates: category filter chips, template cards with name/description/category, "Clone" button per template |
| `RecipeVersionCompareScreen` | `recipe_version_compare_screen.dart` | `String versionId1`, `String versionId2` | Side-by-side diff of two versions: added/removed/changed steps and materials highlighted |

### 8.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `RecipeCard` | `recipe_card.dart` | `Recipe recipe`, `VoidCallback? onTap` | Card: recipe name, output description (e.g. "100 liters"), status badge (Green=Active, Grey=Draft, Red=Archived), version number chip, step count |
| `RecipeStepList` | `recipe_step_list.dart` | `List<RecipeStep> steps`, `ValueChanged<RecipeStep>? onStepTap` | Vertical numbered list: each step as card with name, duration chip, checkpoint icon (lock=checkpoint, unlock=normal), required readings count badge |
| `RecipeStepCard` | `recipe_step_card.dart` | `RecipeStep step`, `int sequence`, `VoidCallback? onTap` | Card: sequence number circle, step name, description preview, duration chip, checkpoint badge, reading count pill |
| `RecipeMaterialTile` | `recipe_material_tile.dart` | `RecipeMaterial material` | ListTile: material name, quantity + unit, tolerance badge, optional/required badge |
| `RecipeStatusBadge` | `recipe_status_badge.dart` | `RecipeStatus status` | Colored pill: Green=ACTIVE, Grey=DRAFT, Red=ARCHIVED |
| `VersionBadge` | `version_badge.dart` | `int versionNumber`, `VersionStatus status` | Chip: "v3" with color (Green=Published, Yellow=Draft, Grey=Superseded) |
| `BomSummaryCard` | `bom_summary_card.dart` | `List<RecipeMaterial> materials` | Card: material count, total cost estimate (if costing available), "View BOM" action |
| `TemplateCard` | `template_card.dart` | `RecipeTemplate template`, `VoidCallback? onClone` | Card: template name, category badge, description, output summary, "Use Template" button |
| `ReadingSpecChip` | `reading_spec_chip.dart` | `ReadingSpec spec` | Chip: reading type icon (thermometer=temp, droplet=pH), unit, range (e.g. "42-46 C") |
| `RecipeSearchSelect` | `recipe_search_select.dart` | `String propertyId`, `ValueChanged<Recipe> onSelected` | Type-ahead search with overlay showing `RecipeCard` items |

### 8.7 Route Module

File: `lib/src/routing/recipe_route_module.dart`

```dart
class RecipeRouteModule extends RouteModule {
  @override String get moduleId => 'recipes';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/recipes',
      builder: (_, state) => RecipeListScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'templates', builder: (_, state) => TemplateLibraryScreen()),
        GoRoute(path: 'new', builder: (_, state) => RecipeCreateScreen(...)),
        GoRoute(
          path: ':recipeId',
          builder: (_, state) => RecipeDetailScreen(recipeId: state.pathParameters['recipeId']!),
          routes: [
            GoRoute(path: 'edit', builder: (_, state) => RecipeDraftEditorScreen(...)),
            GoRoute(path: 'steps/:stepSequence', builder: (_, state) => RecipeStepEditorScreen(...)),
            GoRoute(path: 'bom', builder: (_, state) => BomEditorScreen(...)),
            GoRoute(path: 'compare', builder: (_, state) => RecipeVersionCompareScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'recipes', label: 'Recipes', icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book, route: '/recipes',
      requiredPermissions: {'recipe_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/recipes': {'recipe_view'},
    '/recipes/new': {'recipe_manage'},
    '/recipes/:recipeId/edit': {'recipe_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'recipe_view', label: 'View Recipes', scope: PermissionScope.service),
      PermissionEntry(key: 'recipe_manage', label: 'Manage Recipes', scope: PermissionScope.action),
    ],
  );
}
```

### 8.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `InventoryItemPicker`, `inventoryItemByIdProvider` | `BomEditorScreen` uses `InventoryItemPicker` to select materials for BOM lines. `RecipeMaterialTile` can resolve item names via `inventoryItemByIdProvider`. |

---

## 9. Package 8 — `antinvestor_ui_production`

### 9.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_production` |
| Description | Production plans, batch wizard, step tracker, and packing execution |
| Location | `service-manufacturing/ui/production/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 9.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_recipes: ^0.1.0       # recipe cards, step list
antinvestor_ui_inventory: ^0.1.0     # stock level cards, item picker
```

### 9.3 Transport Provider

File: `lib/src/providers/production_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `productionTransportProvider` | `Provider<Transport>` | Connect transport |
| `productionServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 9.4 Providers

File: `lib/src/providers/plan_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `planSearchProvider` | `FutureProvider.family<List<ProductionPlan>, ({String propertyId, String query})>` | Search plans |
| `planByIdProvider` | `FutureProvider.family<ProductionPlan, String>` | Get plan with lines + packing specs |
| `planListProvider` | `FutureProvider.family<List<ProductionPlan>, ({String propertyId, PlanStatus? status})>` | List plans with status filter |
| `materialRequirementsProvider` | `FutureProvider.family<List<MaterialRequirement>, String>` | Computed requirements for a plan |
| `planNotifierProvider` | `NotifierProvider<PlanNotifier, AsyncValue<void>>` | Create/update plans, add/remove lines, set packing specs, validate, schedule |

File: `lib/src/providers/batch_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `batchByIdProvider` | `FutureProvider.family<Batch, String>` | Get batch with current step state |
| `batchListProvider` | `FutureProvider.family<List<Batch>, ({String propertyId, BatchStatus? status})>` | List batches |
| `batchStepsProvider` | `FutureProvider.family<List<BatchStepExecution>, String>` | Step executions for a batch |
| `batchAlarmsProvider` | `FutureProvider.family<List<BatchAlarm>, String>` | Active alarms for a batch |
| `batchMaterialUsageProvider` | `FutureProvider.family<List<BatchMaterialUsage>, String>` | Material usage for a batch |
| `activeBatchesProvider` | `FutureProvider.family<List<Batch>, String>` | Currently running batches for a property |
| `batchNotifierProvider` | `NotifierProvider<BatchNotifier, AsyncValue<void>>` | Start, complete step, skip step, pause, resume, record reading, confirm materials, record packing, complete, abort |

### 9.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `ProductionDashboardScreen` | `production_dashboard_screen.dart` | `propertyId` | Today's plan cards, active batch cards with live step progress, upcoming plans list, "Start New Plan" action |
| `PlanListScreen` | `plan_list_screen.dart` | `propertyId` | Plan cards with status tabs (Draft/Validated/Scheduled/InProgress/Completed); date range filter |
| `PlanCreateScreen` | `plan_create_screen.dart` | `propertyId` | Guided wizard: (1) Name + date -> (2) Select base recipe (uses `RecipeSearchSelect`) + base quantity -> (3) Add plan lines (recipe + input quantity per line) -> (4) Add packing specs per line -> (5) Review -> Create |
| `PlanDetailScreen` | `plan_detail_screen.dart` | `planId` | Plan header, plan lines as cards (each showing recipe, allocation, packing specs), material requirements list (Green=available, Red=shortage), validation action button |
| `PlanValidationScreen` | `plan_validation_screen.dart` | `planId` | Material requirements table with stock status; shortages highlighted Red; "Override and Schedule" button (requires permission) |
| `BatchListScreen` | `batch_list_screen.dart` | `propertyId` | Batch cards with status, current step indicator, started time, operator |
| `BatchExecutionScreen` | `batch_execution_screen.dart` | `batchId` | **The core operator screen.** Full-screen guided flow: current step prominently displayed, instructions text, reading input buttons (big tap targets), timer, alarm banner, "Complete Step" button, step progress sidebar |
| `BatchStepScreen` | `batch_step_screen.dart` | `batchId`, `int stepSequence` | Focused view of a single step: instructions, readings recorded, alarms, notes, timer, complete/skip actions |
| `BatchCompletionScreen` | `batch_completion_screen.dart` | `batchId` | Guided completion: (1) Confirm output quantity -> (2) Confirm material consumption (pre-filled, adjustable) -> (3) Record packing counts -> (4) Review -> Complete |
| `PackingExecutionScreen` | `packing_execution_screen.dart` | `batchId` | Per-SKU packing entry: planned count, actual count (big number input), spoiled count, "Done Packing" per spec |

### 9.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `PlanCard` | `plan_card.dart` | `ProductionPlan plan`, `VoidCallback? onTap` | Card: plan name, date, base recipe chip, line count, status badge, shortage warning icon if applicable |
| `PlanStatusBadge` | `plan_status_badge.dart` | `PlanStatus status` | Colored pill: Grey=Draft, Yellow=Validated, Blue=Scheduled, Green=Completed, Red=Cancelled |
| `PlanLineCard` | `plan_line_card.dart` | `ProductionPlanLine line`, `VoidCallback? onTap` | Card: recipe name (via `RecipeCard` mini), input/output quantities, packing spec summary, operator badge, status |
| `PackingSpecTile` | `packing_spec_tile.dart` | `PlanLinePackingSpec spec` | ListTile: SKU name, container size, planned count, remainder badge if applicable |
| `MaterialRequirementTile` | `material_requirement_tile.dart` | `MaterialRequirement req` | ListTile: material name, required vs available quantities, shortage highlighted Red, source badge (BASE/LINE/PACKAGING) |
| `ShortageWarningCard` | `shortage_warning_card.dart` | `List<MaterialRequirement> shortages` | Red-bordered card: shortage count, "N items have insufficient stock", tap to see detail |
| `BatchCard` | `batch_card.dart` | `Batch batch`, `VoidCallback? onTap` | Card: batch number, recipe name, status badge, step progress bar (e.g. "3/7"), operator name, started time |
| `BatchStatusBadge` | `batch_status_badge.dart` | `BatchStatus status` | Colored pill: Grey=Created, Blue=Started, Yellow=Paused, Green=Completed, Red=Aborted |
| `BatchStepTracker` | `batch_step_tracker.dart` | `List<BatchStepExecution> steps`, `int currentStep` | Vertical stepper: completed steps Green with checkmark, current step Blue with pulse, pending Grey, skipped with strikethrough |
| `BatchAlarmBanner` | `batch_alarm_banner.dart` | `List<BatchAlarm> alarms` | Persistent top banner: Red for critical, Yellow for warning; alarm count, "Acknowledge" button; blocks step completion until acknowledged |
| `ReadingInputCard` | `reading_input_card.dart` | `ReadingSpec spec`, `ValueChanged<double> onRecorded` | Large card: reading type label and icon, big numeric input, unit, acceptable range shown as green band, out-of-range turns Red |
| `BatchTimerWidget` | `batch_timer_widget.dart` | `DateTime startedAt`, `int? maxMinutes` | Live countdown/countup timer: shows elapsed time, Yellow when approaching max, Red when exceeded |
| `PackingCountInput` | `packing_count_input.dart` | `int plannedCount`, `ValueChanged<int> onActualChanged`, `ValueChanged<int> onSpoiledChanged` | Card: planned count display, actual count with big +/- buttons, spoiled count input, progress indicator |
| `BatchProgressRing` | `batch_progress_ring.dart` | `int completedSteps`, `int totalSteps` | Circular progress ring with fraction text in center |

### 9.7 Route Module

File: `lib/src/routing/production_route_module.dart`

```dart
class ProductionRouteModule extends RouteModule {
  @override String get moduleId => 'production';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/production',
      builder: (_, state) => ProductionDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'plans', builder: (_, state) => PlanListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => PlanCreateScreen(...)),
            GoRoute(path: ':planId', builder: (_, state) => PlanDetailScreen(...),
              routes: [
                GoRoute(path: 'validate', builder: (_, state) => PlanValidationScreen(...)),
              ],
            ),
          ],
        ),
        GoRoute(path: 'batches', builder: (_, state) => BatchListScreen(...),
          routes: [
            GoRoute(path: ':batchId', builder: (_, state) => BatchExecutionScreen(...),
              routes: [
                GoRoute(path: 'steps/:stepSequence', builder: (_, state) => BatchStepScreen(...)),
                GoRoute(path: 'complete', builder: (_, state) => BatchCompletionScreen(...)),
                GoRoute(path: 'packing', builder: (_, state) => PackingExecutionScreen(...)),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'production', label: 'Production', icon: Icons.precision_manufacturing_outlined,
      activeIcon: Icons.precision_manufacturing, route: '/production',
      requiredPermissions: {'batch_view'},
      children: [
        NavItem(id: 'production-dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/production', requiredPermissions: {'batch_view'}),
        NavItem(id: 'plans', label: 'Plans', icon: Icons.event_note_outlined, route: '/production/plans', requiredPermissions: {'plan_view'}),
        NavItem(id: 'batches', label: 'Batches', icon: Icons.play_circle_outline, route: '/production/batches', requiredPermissions: {'batch_view'}),
      ],
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/production': {'batch_view'},
    '/production/plans': {'plan_view'},
    '/production/plans/new': {'plan_manage'},
    '/production/batches/:batchId': {'batch_operate'},
    '/production/batches/:batchId/complete': {'batch_complete'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'plan_view', label: 'View Plans', scope: PermissionScope.feature),
      PermissionEntry(key: 'plan_manage', label: 'Manage Plans', scope: PermissionScope.action),
      PermissionEntry(key: 'plan_validate', label: 'Validate Plans', scope: PermissionScope.action),
      PermissionEntry(key: 'batch_view', label: 'View Batches', scope: PermissionScope.service),
      PermissionEntry(key: 'batch_operate', label: 'Operate Batches', scope: PermissionScope.action),
      PermissionEntry(key: 'batch_complete', label: 'Complete Batches', scope: PermissionScope.action),
      PermissionEntry(key: 'batch_override', label: 'Override Batch Controls', scope: PermissionScope.action),
    ],
  );
}
```

### 9.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_recipes` | `RecipeCard`, `RecipeStepList`, `RecipeSearchSelect`, `recipeByIdProvider`, `recipeVersionProvider` | `PlanCreateScreen` uses `RecipeSearchSelect` for base recipe and line recipe selection. `BatchExecutionScreen` displays step instructions from the pinned recipe version via `RecipeStepList`. `PlanLineCard` embeds a mini `RecipeCard`. |
| `antinvestor_ui_inventory` | `StockLevelCard`, `InventoryItemPicker`, `inventoryItemByIdProvider`, `stockBalanceProvider` | `PlanValidationScreen` shows stock levels via `StockLevelCard` for each material requirement. `PlanDetailScreen` uses `InventoryItemPicker` contextually. Material requirement tiles reference item data via `inventoryItemByIdProvider`. |

---

## 10. Package 9 — `antinvestor_ui_equipment`

### 10.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_equipment` |
| Description | Equipment CRUD, cleaning (CIP) workflow, and maintenance records |
| Location | `service-manufacturing/ui/equipment/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 10.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
```

### 10.3 Transport Provider

File: `lib/src/providers/equipment_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `equipmentTransportProvider` | `Provider<Transport>` | Connect transport |
| `equipmentServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 10.4 Providers

File: `lib/src/providers/equipment_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `equipmentSearchProvider` | `FutureProvider.family<List<Equipment>, ({String propertyId, String query})>` | Search equipment |
| `equipmentByIdProvider` | `FutureProvider.family<Equipment, String>` | Get single equipment |
| `equipmentListProvider` | `FutureProvider.family<List<Equipment>, ({String propertyId, EquipmentStatus? status})>` | List equipment with filter |
| `equipmentDueMaintenanceProvider` | `FutureProvider.family<List<Equipment>, String>` | Equipment due for maintenance in a property |
| `cleaningRecordsProvider` | `FutureProvider.family<List<CleaningRecord>, String>` | Cleaning history for an equipment ID |
| `maintenanceRecordsProvider` | `FutureProvider.family<List<MaintenanceRecord>, String>` | Maintenance history |
| `equipmentNotifierProvider` | `NotifierProvider<EquipmentNotifier, AsyncValue<void>>` | Create/update equipment |
| `cleaningNotifierProvider` | `NotifierProvider<CleaningNotifier, AsyncValue<void>>` | Record cleaning cycles |
| `maintenanceNotifierProvider` | `NotifierProvider<MaintenanceNotifier, AsyncValue<void>>` | Record maintenance |

### 10.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `EquipmentListScreen` | `equipment_list_screen.dart` | `propertyId` | Card grid of equipment: image/icon, name, status badge, last cleaned date, maintenance due warning |
| `EquipmentDetailScreen` | `equipment_detail_screen.dart` | `equipmentId` | Equipment header card, cleaning history timeline, maintenance history, schedule next maintenance, status actions |
| `EquipmentCreateScreen` | `equipment_create_screen.dart` | `propertyId` | Step flow: name -> type picker (Tank, Mixer, Filler, Cooler, Other) -> serial number -> cleaning schedule -> confirm |
| `CleaningRecordScreen` | `cleaning_record_screen.dart` | `equipmentId` | Guided CIP flow: start cleaning -> record chemicals used -> rinse confirmation -> sanitization -> final check -> complete with signature |
| `MaintenanceRecordScreen` | `maintenance_record_screen.dart` | `equipmentId` | Record: maintenance type picker (Preventive/Corrective/Calibration), description, parts replaced, next scheduled, downtime hours -> confirm |
| `EquipmentDashboardScreen` | `equipment_dashboard_screen.dart` | `propertyId` | Summary: total equipment, due for cleaning count (Yellow), overdue maintenance count (Red), equipment utilization |

### 10.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `EquipmentCard` | `equipment_card.dart` | `Equipment equipment`, `VoidCallback? onTap` | Card: equipment icon (by type), name, serial number, status badge, last cleaned time, maintenance due indicator |
| `EquipmentStatusBadge` | `equipment_status_badge.dart` | `EquipmentStatus status` | Colored pill: Green=Operational, Yellow=NeedsCleaning, Red=UnderMaintenance, Grey=Decommissioned |
| `CleaningDueBadge` | `cleaning_due_badge.dart` | `DateTime? lastCleaned`, `int cleaningIntervalHours` | Badge: Green if within schedule, Yellow if approaching, Red if overdue; shows hours remaining/overdue |
| `CleaningRecordTile` | `cleaning_record_tile.dart` | `CleaningRecord record` | ListTile: date, operator, duration, chemicals used, completion status |
| `MaintenanceRecordTile` | `maintenance_record_tile.dart` | `MaintenanceRecord record` | ListTile: date, type badge (Preventive=Blue, Corrective=Red, Calibration=Yellow), description, downtime hours |
| `MaintenanceDueWarning` | `maintenance_due_warning.dart` | `List<Equipment> dueEquipment` | Dismissible banner: Yellow/Red, count of equipment needing maintenance |
| `CipStepIndicator` | `cip_step_indicator.dart` | `int currentStep`, `int totalSteps`, `List<String> stepNames` | Horizontal stepper: Pre-rinse -> Wash -> Post-rinse -> Sanitize -> Verify |
| `EquipmentTypeBadge` | `equipment_type_badge.dart` | `EquipmentType type` | Icon chip: specific icon per type (tank, mixer, filler, cooler) |

### 10.7 Route Module

File: `lib/src/routing/equipment_route_module.dart`

```dart
class EquipmentRouteModule extends RouteModule {
  @override String get moduleId => 'equipment';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/equipment',
      builder: (_, state) => EquipmentDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'list', builder: (_, state) => EquipmentListScreen(...)),
        GoRoute(path: 'new', builder: (_, state) => EquipmentCreateScreen(...)),
        GoRoute(
          path: ':equipmentId',
          builder: (_, state) => EquipmentDetailScreen(equipmentId: state.pathParameters['equipmentId']!),
          routes: [
            GoRoute(path: 'clean', builder: (_, state) => CleaningRecordScreen(...)),
            GoRoute(path: 'maintenance', builder: (_, state) => MaintenanceRecordScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'equipment', label: 'Equipment', icon: Icons.build_outlined,
      activeIcon: Icons.build, route: '/equipment',
      requiredPermissions: {'equipment_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/equipment': {'equipment_view'},
    '/equipment/new': {'equipment_manage'},
    '/equipment/:equipmentId/clean': {'equipment_operate'},
    '/equipment/:equipmentId/maintenance': {'equipment_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'equipment_view', label: 'View Equipment', scope: PermissionScope.service),
      PermissionEntry(key: 'equipment_manage', label: 'Manage Equipment', scope: PermissionScope.action),
      PermissionEntry(key: 'equipment_operate', label: 'Record Cleaning/Maintenance', scope: PermissionScope.action),
    ],
  );
}
```

### 10.8 Internal Reuse

None -- this is a standalone package.

---

## 11. Package 10 — `antinvestor_ui_coldchain`

### 11.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_coldchain` |
| Description | Monitoring points, temperature/humidity readings, alarms, and compliance reporting |
| Location | `service-manufacturing/ui/coldchain/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 11.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
```

### 11.3 Transport Provider

File: `lib/src/providers/coldchain_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `coldchainTransportProvider` | `Provider<Transport>` | Connect transport |
| `coldchainServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 11.4 Providers

File: `lib/src/providers/coldchain_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `monitoringPointListProvider` | `FutureProvider.family<List<MonitoringPoint>, String>` | List monitoring points for a property |
| `monitoringPointByIdProvider` | `FutureProvider.family<MonitoringPoint, String>` | Get point with current reading |
| `readingsProvider` | `FutureProvider.family<List<ColdChainReading>, ({String pointId, DateTime from, DateTime to})>` | Readings for a point in time range |
| `activeAlarmsProvider` | `FutureProvider.family<List<ColdChainAlarm>, String>` | Active/unacknowledged alarms for a property |
| `alarmsByPointProvider` | `FutureProvider.family<List<ColdChainAlarm>, String>` | Alarm history for a monitoring point |
| `complianceReportProvider` | `FutureProvider.family<ComplianceReport, ({String propertyId, DateTime from, DateTime to})>` | Compliance summary for period |
| `coldchainNotifierProvider` | `NotifierProvider<ColdChainNotifier, AsyncValue<void>>` | Create/update monitoring points, record readings, acknowledge alarms |

### 11.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `ColdChainDashboardScreen` | `coldchain_dashboard_screen.dart` | `propertyId` | Grid of monitoring point cards with live temperature/humidity readings, active alarm count banner, overall compliance score |
| `MonitoringPointDetailScreen` | `monitoring_point_detail_screen.dart` | `pointId` | Point header, line chart of readings over time, alarm history, "Record Reading" button, thresholds display |
| `MonitoringPointCreateScreen` | `monitoring_point_create_screen.dart` | `propertyId` | Step flow: name -> location picker (zone in facility) -> reading type (temp/humidity/both) -> thresholds (min/max) -> reading interval -> confirm |
| `ReadingRecordScreen` | `reading_record_screen.dart` | `pointId` | Quick entry: large temperature/humidity input (big number pad), auto-validates against thresholds, shows Green/Red feedback, submit |
| `AlarmListScreen` | `alarm_list_screen.dart` | `propertyId` | Active alarms as cards (Red=critical, Yellow=warning), sorted by severity; "Acknowledge" action per alarm; acknowledged alarms in separate tab |
| `ComplianceReportScreen` | `compliance_report_screen.dart` | `propertyId` | Date range picker, compliance percentage gauge, excursion count, reading coverage %, exportable report |

### 11.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `MonitoringPointCard` | `monitoring_point_card.dart` | `MonitoringPoint point`, `ColdChainReading? latestReading`, `VoidCallback? onTap` | Card: point name, location zone, large temperature display, status indicator (Green if in range, Red if excursion), last reading time |
| `TemperatureDisplay` | `temperature_display.dart` | `double value`, `double min`, `double max`, `String unit` | Large number with unit; Green if within range, Yellow if near boundary, Red if out of range; background color shifts |
| `ColdChainAlarmCard` | `coldchain_alarm_card.dart` | `ColdChainAlarm alarm`, `VoidCallback? onAcknowledge` | Card: Red/Yellow border, alarm message, point name, reading value that triggered it, time, "Acknowledge" button |
| `ReadingChart` | `reading_chart.dart` | `List<ColdChainReading> readings`, `double minThreshold`, `double maxThreshold` | Line chart: readings over time, threshold lines shown as dashed red, excursions highlighted with red dots |
| `ComplianceGauge` | `compliance_gauge.dart` | `double compliancePercent` | Circular gauge: Green >95%, Yellow 80-95%, Red <80%, percentage text in center |
| `ExcursionBanner` | `excursion_banner.dart` | `int excursionCount`, `VoidCallback? onTap` | Red dismissible banner: "N temperature excursions detected", tap to view |
| `ReadingHistoryTile` | `reading_history_tile.dart` | `ColdChainReading reading` | ListTile: timestamp, value with unit, in-range/out-of-range badge, recorded by |

### 11.7 Route Module

File: `lib/src/routing/coldchain_route_module.dart`

```dart
class ColdChainRouteModule extends RouteModule {
  @override String get moduleId => 'coldchain';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/coldchain',
      builder: (_, state) => ColdChainDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'compliance', builder: (_, state) => ComplianceReportScreen(...)),
        GoRoute(path: 'alarms', builder: (_, state) => AlarmListScreen(...)),
        GoRoute(path: 'new', builder: (_, state) => MonitoringPointCreateScreen(...)),
        GoRoute(
          path: ':pointId',
          builder: (_, state) => MonitoringPointDetailScreen(pointId: state.pathParameters['pointId']!),
          routes: [
            GoRoute(path: 'record', builder: (_, state) => ReadingRecordScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'coldchain', label: 'Cold Chain', icon: Icons.thermostat_outlined,
      activeIcon: Icons.thermostat, route: '/coldchain',
      requiredPermissions: {'coldchain_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/coldchain': {'coldchain_view'},
    '/coldchain/new': {'coldchain_manage'},
    '/coldchain/:pointId/record': {'coldchain_record'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'coldchain_view', label: 'View Cold Chain', scope: PermissionScope.service),
      PermissionEntry(key: 'coldchain_manage', label: 'Manage Monitoring Points', scope: PermissionScope.action),
      PermissionEntry(key: 'coldchain_record', label: 'Record Readings', scope: PermissionScope.action),
    ],
  );
}
```

### 11.8 Internal Reuse

None -- standalone package.

---

## 12. Package 11 — `antinvestor_ui_quality`

### 12.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_quality` |
| Description | Inspection templates, receiving inspection wizard, quality readings, and hold/release |
| Location | `service-manufacturing/ui/quality/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 12.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_inventory: ^0.1.0      # inventory item context
```

### 12.3 Transport Provider

File: `lib/src/providers/quality_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `qualityTransportProvider` | `Provider<Transport>` | Connect transport |
| `qualityServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 12.4 Providers

File: `lib/src/providers/quality_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `inspectionTemplateListProvider` | `FutureProvider.family<List<InspectionTemplate>, String>` | Templates for a property |
| `inspectionTemplateByIdProvider` | `FutureProvider.family<InspectionTemplate, String>` | Get template with checks |
| `inspectionListProvider` | `FutureProvider.family<List<Inspection>, ({String propertyId, InspectionStatus? status})>` | Inspections with status filter |
| `inspectionByIdProvider` | `FutureProvider.family<Inspection, String>` | Get inspection with results |
| `pendingInspectionsProvider` | `FutureProvider.family<List<Inspection>, String>` | Pending inspections for a property |
| `qualityNotifierProvider` | `NotifierProvider<QualityNotifier, AsyncValue<void>>` | Create templates, start inspection, record check results, complete inspection, hold/release lot |

### 12.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `QualityDashboardScreen` | `quality_dashboard_screen.dart` | `propertyId` | Pending inspections count (Yellow), held lots count (Red), recent inspection cards, pass rate gauge |
| `InspectionTemplateListScreen` | `inspection_template_list_screen.dart` | `propertyId` | Template cards: name, check count, applicable categories, edit/duplicate actions |
| `InspectionTemplateEditorScreen` | `inspection_template_editor_screen.dart` | `String? templateId` | Create/edit: name, applicable categories, add quality checks (type: visual/measurement/pass-fail, spec range) |
| `InspectionWizardScreen` | `inspection_wizard_screen.dart` | `String inspectionId` | Guided flow through each check: large display of what to inspect, expected values, input (pass/fail toggle or measurement input), photo capture, notes; auto-advances |
| `InspectionDetailScreen` | `inspection_detail_screen.dart` | `inspectionId` | Inspection header, check results list (Green=pass, Red=fail), overall result, hold/release actions for associated lots |
| `InspectionListScreen` | `inspection_list_screen.dart` | `propertyId` | Inspection cards with status tabs (Pending/InProgress/Passed/Failed), date filter |

### 12.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `InspectionCard` | `inspection_card.dart` | `Inspection inspection`, `VoidCallback? onTap` | Card: inspection type, item name, date, result badge (Green=Passed, Red=Failed, Yellow=Pending), check count progress |
| `InspectionStatusBadge` | `inspection_status_badge.dart` | `InspectionStatus status` | Colored pill: Green=Passed, Red=Failed, Yellow=Pending, Grey=InProgress |
| `QualityCheckTile` | `quality_check_tile.dart` | `QualityCheck check`, `QualityCheckResult? result` | ListTile: check name, type icon (eye=visual, ruler=measurement, check=pass-fail), result badge, spec range |
| `QualityCheckInput` | `quality_check_input.dart` | `QualityCheck check`, `ValueChanged<QualityCheckResult> onResult` | Contextual input: pass/fail toggle buttons for pass-fail type, numeric input with range for measurement, accept/reject for visual |
| `HoldReleaseBadge` | `hold_release_badge.dart` | `bool isOnHold` | Badge: Red "ON HOLD" or Green "RELEASED" |
| `PassRateGauge` | `pass_rate_gauge.dart` | `double passRate` | Circular gauge: Green >90%, Yellow 70-90%, Red <70% |
| `PendingInspectionBanner` | `pending_inspection_banner.dart` | `int pendingCount` | Yellow banner: "N items awaiting inspection", tap to navigate |
| `InspectionTemplatePicker` | `inspection_template_picker.dart` | `String propertyId`, `ValueChanged<InspectionTemplate> onSelected` | Bottom sheet list of applicable templates for quick selection |

### 12.7 Route Module

File: `lib/src/routing/quality_route_module.dart`

```dart
class QualityRouteModule extends RouteModule {
  @override String get moduleId => 'quality';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/quality',
      builder: (_, state) => QualityDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'templates', builder: (_, state) => InspectionTemplateListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => InspectionTemplateEditorScreen(templateId: null)),
            GoRoute(path: ':templateId/edit', builder: (_, state) => InspectionTemplateEditorScreen(...)),
          ],
        ),
        GoRoute(path: 'inspections', builder: (_, state) => InspectionListScreen(...)),
        GoRoute(
          path: ':inspectionId',
          builder: (_, state) => InspectionDetailScreen(inspectionId: state.pathParameters['inspectionId']!),
          routes: [
            GoRoute(path: 'execute', builder: (_, state) => InspectionWizardScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'quality', label: 'Quality', icon: Icons.verified_outlined,
      activeIcon: Icons.verified, route: '/quality',
      requiredPermissions: {'quality_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/quality': {'quality_view'},
    '/quality/templates/new': {'quality_manage'},
    '/quality/:inspectionId/execute': {'quality_inspect'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'quality_view', label: 'View Quality', scope: PermissionScope.service),
      PermissionEntry(key: 'quality_manage', label: 'Manage Templates', scope: PermissionScope.action),
      PermissionEntry(key: 'quality_inspect', label: 'Perform Inspections', scope: PermissionScope.action),
      PermissionEntry(key: 'quality_hold', label: 'Hold/Release Lots', scope: PermissionScope.action),
    ],
  );
}
```

### 12.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `InventoryItemPicker`, `LotCard`, `inventoryItemByIdProvider` | `InspectionWizardScreen` shows the item being inspected via `inventoryItemByIdProvider`. Templates reference inventory categories. `InspectionDetailScreen` shows affected `LotCard`s for hold/release. |

---

## 13. Package 12 — `antinvestor_ui_waste`

### 13.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_waste` |
| Description | Waste records, disposition, by-products, and waste summaries |
| Location | `service-manufacturing/ui/waste/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 13.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_inventory: ^0.1.0      # inventory item context
```

### 13.3 Transport Provider

File: `lib/src/providers/waste_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `wasteTransportProvider` | `Provider<Transport>` | Connect transport |
| `wasteServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 13.4 Providers

File: `lib/src/providers/waste_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `wasteRecordListProvider` | `FutureProvider.family<List<WasteRecord>, ({String propertyId, DateTime? from, DateTime? to})>` | List waste records with date range |
| `wasteRecordByIdProvider` | `FutureProvider.family<WasteRecord, String>` | Get single record |
| `wasteSummaryProvider` | `FutureProvider.family<WasteSummary, ({String propertyId, DateTime from, DateTime to})>` | Aggregated waste summary for period |
| `byProductListProvider` | `FutureProvider.family<List<ByProduct>, String>` | By-products for a property |
| `wasteNotifierProvider` | `NotifierProvider<WasteNotifier, AsyncValue<void>>` | Record waste, record by-product, update disposition |

### 13.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `WasteDashboardScreen` | `waste_dashboard_screen.dart` | `propertyId` | Today's waste total, waste by category chart (expired/damaged/process loss/rejected), trend line, by-product recovery card |
| `WasteRecordScreen` | `waste_record_screen.dart` | `propertyId` | Guided flow: select item (uses `InventoryItemPicker`) -> waste type picker (Expired/Damaged/ProcessLoss/Rejected/Other) -> quantity (big input) -> disposition picker (Discard/Recycle/Donate/ByProduct) -> reason -> confirm |
| `WasteListScreen` | `waste_list_screen.dart` | `propertyId` | Waste record cards: item name, quantity, type badge, disposition, date; filterable by type and date |
| `WasteSummaryScreen` | `waste_summary_screen.dart` | `propertyId` | Date range picker, waste % of total input, breakdown by type pie chart, top wasted items, cost impact |
| `ByProductScreen` | `by_product_screen.dart` | `propertyId` | By-product cards: source item, output item, conversion rate, total recovered |

### 13.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `WasteRecordCard` | `waste_record_card.dart` | `WasteRecord record`, `VoidCallback? onTap` | Card: item name, quantity + unit, waste type badge (color-coded), disposition badge, date, cost impact if available |
| `WasteTypeBadge` | `waste_type_badge.dart` | `WasteType type` | Colored pill: Red=Expired, Orange=Damaged, Yellow=ProcessLoss, Grey=Rejected |
| `DispositionBadge` | `disposition_badge.dart` | `Disposition disposition` | Chip: Discard=Red, Recycle=Green, Donate=Blue, ByProduct=Purple |
| `WasteSummaryCard` | `waste_summary_card.dart` | `WasteSummary summary` | Card: total waste quantity, waste % of input, breakdown bar chart by type, period label |
| `ByProductCard` | `by_product_card.dart` | `ByProduct byProduct`, `VoidCallback? onTap` | Card: source material, output material, conversion rate %, total recovered quantity |
| `WasteTrendChart` | `waste_trend_chart.dart` | `List<WasteSummary> summaries` | Line chart: waste quantities over time periods, trend arrow (up=bad Red, down=good Green) |
| `WasteTypePicker` | `waste_type_picker.dart` | `ValueChanged<WasteType> onSelected` | Bottom sheet with large icon buttons for each waste type for quick selection |

### 13.7 Route Module

File: `lib/src/routing/waste_route_module.dart`

```dart
class WasteRouteModule extends RouteModule {
  @override String get moduleId => 'waste';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/waste',
      builder: (_, state) => WasteDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'record', builder: (_, state) => WasteRecordScreen(...)),
        GoRoute(path: 'list', builder: (_, state) => WasteListScreen(...)),
        GoRoute(path: 'summary', builder: (_, state) => WasteSummaryScreen(...)),
        GoRoute(path: 'byproducts', builder: (_, state) => ByProductScreen(...)),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'waste', label: 'Waste', icon: Icons.delete_outline,
      activeIcon: Icons.delete, route: '/waste',
      requiredPermissions: {'waste_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/waste': {'waste_view'},
    '/waste/record': {'waste_record'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'waste_view', label: 'View Waste Records', scope: PermissionScope.service),
      PermissionEntry(key: 'waste_record', label: 'Record Waste', scope: PermissionScope.action),
    ],
  );
}
```

### 13.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `InventoryItemPicker`, `inventoryItemByIdProvider` | `WasteRecordScreen` uses `InventoryItemPicker` to select the wasted item. `WasteRecordCard` resolves item name via `inventoryItemByIdProvider`. |

---

## 14. Package 13 — `antinvestor_ui_costing`

### 14.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_costing` |
| Description | Cost components, batch cost snapshots, and margin/variance reports |
| Location | `service-manufacturing/ui/costing/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 14.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
```

### 14.3 Transport Provider

File: `lib/src/providers/costing_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `costingTransportProvider` | `Provider<Transport>` | Connect transport |
| `costingServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 14.4 Providers

File: `lib/src/providers/costing_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `costComponentListProvider` | `FutureProvider.family<List<CostComponent>, String>` | List cost components for a property (raw materials, labor, overhead, packaging) |
| `costComponentByIdProvider` | `FutureProvider.family<CostComponent, String>` | Get single component |
| `batchCostSnapshotProvider` | `FutureProvider.family<BatchCostSnapshot, String>` | Get cost snapshot for a completed batch |
| `batchCostListProvider` | `FutureProvider.family<List<BatchCostSnapshot>, ({String propertyId, DateTime? from, DateTime? to})>` | List batch costs with date range |
| `productCostProvider` | `FutureProvider.family<ProductCost, String>` | Average production cost for an inventory item |
| `marginReportProvider` | `FutureProvider.family<MarginReport, ({String propertyId, DateTime from, DateTime to})>` | Margin analysis for period |
| `varianceReportProvider` | `FutureProvider.family<VarianceReport, ({String propertyId, DateTime from, DateTime to})>` | Cost variance analysis |
| `costingNotifierProvider` | `NotifierProvider<CostingNotifier, AsyncValue<void>>` | Create/update cost components |

### 14.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `CostingDashboardScreen` | `costing_dashboard_screen.dart` | `propertyId` | Average cost per unit by product, margin summary card, recent batch costs, cost trend chart |
| `CostComponentListScreen` | `cost_component_list_screen.dart` | `propertyId` | Card list of cost components: name, type (Material/Labor/Overhead/Packaging), rate, unit; edit per component |
| `CostComponentEditorScreen` | `cost_component_editor_screen.dart` | `String? componentId` | Create/edit: name, type picker, rate input (with currency), unit, applicable products; confirm |
| `BatchCostDetailScreen` | `batch_cost_detail_screen.dart` | `batchId` | Breakdown: material costs (each line), labor, overhead, packaging, total cost, cost per unit, comparison to standard |
| `MarginReportScreen` | `margin_report_screen.dart` | `propertyId` | Date range, product-by-product margin table: cost, selling price, gross margin, margin %; sortable by margin |
| `VarianceReportScreen` | `variance_report_screen.dart` | `propertyId` | Planned vs actual cost per batch, variance breakdown by component, top variances highlighted Red |

### 14.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `CostComponentCard` | `cost_component_card.dart` | `CostComponent component`, `VoidCallback? onTap` | Card: name, type badge, rate via `AmountDisplay`, unit |
| `CostComponentTypeBadge` | `cost_component_type_badge.dart` | `CostComponentType type` | Colored chip: Brown=Material, Blue=Labor, Purple=Overhead, Orange=Packaging |
| `BatchCostCard` | `batch_cost_card.dart` | `BatchCostSnapshot snapshot`, `VoidCallback? onTap` | Card: batch number, product name, total cost via `AmountDisplay`, cost per unit, date |
| `CostBreakdownChart` | `cost_breakdown_chart.dart` | `BatchCostSnapshot snapshot` | Stacked bar or pie: material %, labor %, overhead %, packaging % |
| `MarginBar` | `margin_bar.dart` | `double marginPercent` | Horizontal bar: Green >25%, Yellow 10-25%, Red <10% with percentage label |
| `VarianceIndicator` | `variance_indicator.dart` | `Money planned`, `Money actual` | Side-by-side with delta: Green if under budget, Red if over, amount and percentage shown |
| `CostTrendChart` | `cost_trend_chart.dart` | `List<BatchCostSnapshot> snapshots` | Line chart: cost per unit over time by product, trend line |
| `ProductCostSummary` | `product_cost_summary.dart` | `ProductCost cost` | Card: product name, avg cost per unit, breakdown list, last updated |

### 14.7 Route Module

File: `lib/src/routing/costing_route_module.dart`

```dart
class CostingRouteModule extends RouteModule {
  @override String get moduleId => 'costing';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/costing',
      builder: (_, state) => CostingDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'components', builder: (_, state) => CostComponentListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => CostComponentEditorScreen(componentId: null)),
            GoRoute(path: ':componentId/edit', builder: (_, state) => CostComponentEditorScreen(...)),
          ],
        ),
        GoRoute(path: 'margins', builder: (_, state) => MarginReportScreen(...)),
        GoRoute(path: 'variances', builder: (_, state) => VarianceReportScreen(...)),
        GoRoute(path: 'batches/:batchId', builder: (_, state) => BatchCostDetailScreen(...)),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'costing', label: 'Costing', icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate, route: '/costing',
      requiredPermissions: {'costing_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/costing': {'costing_view'},
    '/costing/components/new': {'costing_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'costing_view', label: 'View Costing', scope: PermissionScope.service),
      PermissionEntry(key: 'costing_manage', label: 'Manage Cost Components', scope: PermissionScope.action),
    ],
  );
}
```

### 14.8 Internal Reuse

None -- standalone package. Reads batch and inventory data via its own service client.

---

## 15. Package 14 — `antinvestor_ui_demand`

### 15.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_demand` |
| Description | Demand signals, forecasts, production suggestions, and forecast configuration |
| Location | `service-manufacturing/ui/demand/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 15.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_inventory: ^0.1.0      # stock level context
```

### 15.3 Transport Provider

File: `lib/src/providers/demand_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `demandTransportProvider` | `Provider<Transport>` | Connect transport |
| `demandServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 15.4 Providers

File: `lib/src/providers/demand_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `demandSignalListProvider` | `FutureProvider.family<List<DemandSignal>, ({String propertyId, DateTime? from, DateTime? to})>` | List demand signals (order-driven, manual, forecast) |
| `forecastListProvider` | `FutureProvider.family<List<Forecast>, ({String propertyId, String? productItemId})>` | Active forecasts for property, optionally filtered by product |
| `forecastByIdProvider` | `FutureProvider.family<Forecast, String>` | Get forecast with projections |
| `productionSuggestionsProvider` | `FutureProvider.family<List<ProductionSuggestion>, String>` | System-generated suggestions: what to produce, when, how much; based on forecast + current stock |
| `forecastConfigProvider` | `FutureProvider.family<ForecastConfig, String>` | Forecast configuration for a property |
| `demandNotifierProvider` | `NotifierProvider<DemandNotifier, AsyncValue<void>>` | Create manual demand signal, update forecast config, accept/reject suggestion |

### 15.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `DemandDashboardScreen` | `demand_dashboard_screen.dart` | `propertyId` | Demand signals timeline, active forecasts summary, production suggestions cards (actionable), stock vs demand comparison |
| `DemandSignalListScreen` | `demand_signal_list_screen.dart` | `propertyId` | Signal cards: source (Order/Manual/Forecast), product, quantity, date; filter by source type |
| `ForecastDetailScreen` | `forecast_detail_screen.dart` | `forecastId` | Forecast chart (projected demand over time), current stock overlay, recommended production dates, accuracy metrics |
| `ProductionSuggestionsScreen` | `production_suggestions_screen.dart` | `propertyId` | Suggestion cards: product to produce, recommended quantity, recommended date, stock days remaining; "Create Plan" action per suggestion |
| `ForecastConfigScreen` | `forecast_config_screen.dart` | `propertyId` | Configure: forecast horizon (days), safety stock days, reorder point multiplier, excluded products; save |
| `ManualDemandScreen` | `manual_demand_screen.dart` | `propertyId` | Quick entry: select product (uses `InventoryItemPicker`), quantity, date, reason; for events/promotions |

### 15.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `DemandSignalCard` | `demand_signal_card.dart` | `DemandSignal signal`, `VoidCallback? onTap` | Card: product name, quantity, date, source badge (Blue=Order, Green=Manual, Purple=Forecast) |
| `DemandSourceBadge` | `demand_source_badge.dart` | `DemandSource source` | Colored pill: Blue=Order, Green=Manual, Purple=Forecast |
| `ForecastCard` | `forecast_card.dart` | `Forecast forecast`, `VoidCallback? onTap` | Card: product name, forecast horizon, projected total demand, confidence indicator, last updated |
| `ProductionSuggestionCard` | `production_suggestion_card.dart` | `ProductionSuggestion suggestion`, `VoidCallback? onAccept`, `VoidCallback? onDismiss` | Actionable card: product name, recommended quantity + date, days of stock remaining gauge, "Plan Production" and "Dismiss" buttons |
| `StockVsDemandChart` | `stock_vs_demand_chart.dart` | `List<StockProjection> projections` | Line chart: current stock level declining over time, demand consumption line, reorder point dashed line, stockout date marked Red |
| `DemandTimeline` | `demand_timeline.dart` | `List<DemandSignal> signals` | Vertical timeline: signals ordered by date, color-coded by source, quantity shown |
| `StockDaysIndicator` | `stock_days_indicator.dart` | `int daysRemaining`, `int safetyDays` | Badge/bar: Green if >safety, Yellow if <safety, Red if <3 days; shows "X days of stock" |
| `ForecastAccuracyBadge` | `forecast_accuracy_badge.dart` | `double accuracyPercent` | Pill: Green >80%, Yellow 50-80%, Red <50% |

### 15.7 Route Module

File: `lib/src/routing/demand_route_module.dart`

```dart
class DemandRouteModule extends RouteModule {
  @override String get moduleId => 'demand';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/demand',
      builder: (_, state) => DemandDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'signals', builder: (_, state) => DemandSignalListScreen(...)),
        GoRoute(path: 'suggestions', builder: (_, state) => ProductionSuggestionsScreen(...)),
        GoRoute(path: 'forecasts/:forecastId', builder: (_, state) => ForecastDetailScreen(...)),
        GoRoute(path: 'config', builder: (_, state) => ForecastConfigScreen(...)),
        GoRoute(path: 'manual', builder: (_, state) => ManualDemandScreen(...)),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'demand', label: 'Demand', icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up, route: '/demand',
      requiredPermissions: {'demand_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/demand': {'demand_view'},
    '/demand/config': {'demand_manage'},
    '/demand/manual': {'demand_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'demand_view', label: 'View Demand', scope: PermissionScope.service),
      PermissionEntry(key: 'demand_manage', label: 'Manage Demand & Forecasts', scope: PermissionScope.action),
    ],
  );
}
```

### 15.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `InventoryItemPicker`, `StockLevelBadge`, `inventoryItemByIdProvider`, `stockBalanceProvider` | `ManualDemandScreen` uses `InventoryItemPicker` for product selection. `ProductionSuggestionCard` shows current stock via `StockLevelBadge`. `StockVsDemandChart` uses `stockBalanceProvider` for current levels. |

---

## 16. Package 15 — `antinvestor_ui_traceability`

### 16.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_traceability` |
| Description | Forward/reverse trace, recall management, and lot provenance |
| Location | `service-manufacturing/ui/traceability/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 16.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_inventory: ^0.1.0      # lot and item context
```

### 16.3 Transport Provider

File: `lib/src/providers/traceability_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `traceabilityTransportProvider` | `Provider<Transport>` | Connect transport |
| `traceabilityServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 16.4 Providers

File: `lib/src/providers/traceability_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `forwardTraceProvider` | `FutureProvider.family<TraceResult, String>` | Forward trace from a lot: where did this lot go? |
| `reverseTraceProvider` | `FutureProvider.family<TraceResult, String>` | Reverse trace from a lot: where did this lot come from? |
| `lotProvenanceProvider` | `FutureProvider.family<LotProvenance, String>` | Full provenance chain for a lot |
| `recallListProvider` | `FutureProvider.family<List<Recall>, ({String propertyId, RecallStatus? status})>` | List recalls |
| `recallByIdProvider` | `FutureProvider.family<Recall, String>` | Get recall with affected lots |
| `recallNotifierProvider` | `NotifierProvider<RecallNotifier, AsyncValue<void>>` | Create recall, update status, add affected lots |

### 16.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `TraceabilityDashboardScreen` | `traceability_dashboard_screen.dart` | `propertyId` | Search by lot number/batch number, recent traces, active recalls count (Red), quick trace buttons |
| `ForwardTraceScreen` | `forward_trace_screen.dart` | `lotId` | Visual tree: lot -> batches that used it -> output lots -> orders that sold them; interactive, expandable nodes |
| `ReverseTraceScreen` | `reverse_trace_screen.dart` | `lotId` | Visual tree: lot -> batch that produced it -> input lots -> supplier/PO sources; interactive nodes |
| `LotProvenanceScreen` | `lot_provenance_screen.dart` | `lotId` | Full history: creation (receipt/production), transformations (batches), movements, current location, quality results |
| `RecallListScreen` | `recall_list_screen.dart` | `propertyId` | Recall cards: reason, status (Active/Resolved), affected lot count, date initiated |
| `RecallCreateScreen` | `recall_create_screen.dart` | `propertyId` | Guided flow: reason -> select source lot -> system auto-traces affected lots -> review affected products + orders -> confirm recall |
| `RecallDetailScreen` | `recall_detail_screen.dart` | `recallId` | Recall header, affected lots list, affected orders list, resolution actions, timeline |

### 16.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `TraceTreeWidget` | `trace_tree_widget.dart` | `TraceResult trace`, `TraceDirection direction` | Interactive tree visualization: nodes for lots, batches, orders; edges show flow; color coded (Green=good, Yellow=in-progress, Red=recalled) |
| `TraceNodeCard` | `trace_node_card.dart` | `TraceNode node`, `VoidCallback? onTap` | Small card used in tree: entity type icon, identifier, date, status dot |
| `LotProvenanceTimeline` | `lot_provenance_timeline.dart` | `LotProvenance provenance` | Vertical timeline: creation -> quality check -> batch input -> batch output -> stock -> sale; each event as a node |
| `RecallCard` | `recall_card.dart` | `Recall recall`, `VoidCallback? onTap` | Card: Red border, recall reason, status badge, affected lot count, initiated date, "View Details" action |
| `RecallStatusBadge` | `recall_status_badge.dart` | `RecallStatus status` | Colored pill: Red=Active, Yellow=InProgress, Green=Resolved |
| `AffectedLotTile` | `affected_lot_tile.dart` | `StockLot lot`, `bool isRecalled` | ListTile: lot number, item name, quantity, recalled badge if applicable |
| `LotSearchBar` | `lot_search_bar.dart` | `ValueChanged<String> onSearch` | Search field with scan icon (future barcode support); searches lot numbers and batch numbers |
| `ActiveRecallBanner` | `active_recall_banner.dart` | `int activeRecallCount` | Red persistent banner: "N active recalls", tap to navigate to recall list |

### 16.7 Route Module

File: `lib/src/routing/traceability_route_module.dart`

```dart
class TraceabilityRouteModule extends RouteModule {
  @override String get moduleId => 'traceability';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/traceability',
      builder: (_, state) => TraceabilityDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'forward/:lotId', builder: (_, state) => ForwardTraceScreen(lotId: state.pathParameters['lotId']!)),
        GoRoute(path: 'reverse/:lotId', builder: (_, state) => ReverseTraceScreen(lotId: state.pathParameters['lotId']!)),
        GoRoute(path: 'provenance/:lotId', builder: (_, state) => LotProvenanceScreen(lotId: state.pathParameters['lotId']!)),
        GoRoute(path: 'recalls', builder: (_, state) => RecallListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => RecallCreateScreen(...)),
            GoRoute(path: ':recallId', builder: (_, state) => RecallDetailScreen(...)),
          ],
        ),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'traceability', label: 'Traceability', icon: Icons.account_tree_outlined,
      activeIcon: Icons.account_tree, route: '/traceability',
      requiredPermissions: {'traceability_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/traceability': {'traceability_view'},
    '/traceability/recalls/new': {'recall_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'traceability_view', label: 'View Traceability', scope: PermissionScope.service),
      PermissionEntry(key: 'recall_manage', label: 'Manage Recalls', scope: PermissionScope.action),
    ],
  );
}
```

### 16.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_inventory` | `LotCard`, `inventoryItemByIdProvider`, `stockLotsProvider` | `ForwardTraceScreen` and `ReverseTraceScreen` display lots via `LotCard`. `RecallCreateScreen` looks up lots via `stockLotsProvider`. Trace node details use `inventoryItemByIdProvider`. |

---

## 17. Package 16 — `antinvestor_ui_shelflife`

### 17.1 Identity

| Field | Value |
|---|---|
| Package name | `antinvestor_ui_shelflife` |
| Description | Shelf life rules, label data, expiry calculation, and label generation |
| Location | `service-manufacturing/ui/shelflife/` |
| Dart SDK prerequisite | `antinvestor_api_manufacturing` (needs generation) |
| Service URL env var | `MANUFACTURING_URL` |
| Service client | `ManufacturingServiceClient` |

### 17.2 Additional Dependencies

```yaml
antinvestor_api_manufacturing: ^1.0.0
antinvestor_ui_recipes: ^0.1.0        # recipe context for shelf life rules
```

### 17.3 Transport Provider

File: `lib/src/providers/shelflife_transport_provider.dart`

| Provider | Type | Purpose |
|---|---|---|
| `shelflifeTransportProvider` | `Provider<Transport>` | Connect transport |
| `shelflifeServiceClientProvider` | `Provider<ManufacturingServiceClient>` | Typed RPC client |

### 17.4 Providers

File: `lib/src/providers/shelflife_providers.dart`

| Provider | Type Signature | Purpose |
|---|---|---|
| `shelfLifeRuleListProvider` | `FutureProvider.family<List<ShelfLifeRule>, String>` | Rules for a property |
| `shelfLifeRuleByIdProvider` | `FutureProvider.family<ShelfLifeRule, String>` | Get single rule |
| `labelDataProvider` | `FutureProvider.family<LabelData, ({String ruleId, DateTime productionDate})>` | Computed label data (expiry date, storage instructions) for a production date |
| `expiryCalendarProvider` | `FutureProvider.family<List<ExpiryEvent>, ({String propertyId, DateTime from, DateTime to})>` | Calendar of upcoming expiries |
| `shelflifeNotifierProvider` | `NotifierProvider<ShelfLifeNotifier, AsyncValue<void>>` | Create/update shelf life rules |

### 17.5 Screens

| Screen | File | Params | Purpose |
|---|---|---|---|
| `ShelfLifeRuleListScreen` | `shelflife_rule_list_screen.dart` | `propertyId` | Rule cards: product name, shelf life days, storage conditions, applicable recipes; create/edit actions |
| `ShelfLifeRuleEditorScreen` | `shelflife_rule_editor_screen.dart` | `String? ruleId` | Create/edit: select product/recipe, shelf life days (by storage condition: ambient/refrigerated/frozen), storage instructions, label text template |
| `LabelPreviewScreen` | `label_preview_screen.dart` | `String ruleId`, `DateTime productionDate` | Visual label preview: product name, production date, expiry date (computed), storage icon, batch number placeholder, "Print" action |
| `ExpiryCalendarScreen` | `expiry_calendar_screen.dart` | `propertyId` | Calendar view: days with expiring products highlighted (Yellow=soon, Red=expired); tap date to see list of expiring lots |
| `ShelfLifeDashboardScreen` | `shelflife_dashboard_screen.dart` | `propertyId` | Expiring this week count, expired count, rules coverage (% of products with rules), upcoming expirations timeline |

### 17.6 Widgets

| Widget | File | Props | Visual Description |
|---|---|---|---|
| `ShelfLifeRuleCard` | `shelflife_rule_card.dart` | `ShelfLifeRule rule`, `VoidCallback? onTap` | Card: product name, shelf life per condition (e.g. "14d refrigerated, 7d ambient"), storage icons, recipe link |
| `ExpiryDateDisplay` | `expiry_date_display.dart` | `DateTime expiryDate` | Large date display with countdown: Green if >7d, Yellow if 3-7d, Red if <3d or expired |
| `StorageConditionBadge` | `storage_condition_badge.dart` | `StorageCondition condition` | Icon chip: snowflake=Frozen, thermometer=Refrigerated, sun=Ambient |
| `LabelPreviewCard` | `label_preview_card.dart` | `LabelData data` | Card styled as a product label: product name, production date, expiry date, storage instructions, batch number |
| `ExpiryCalendarDay` | `expiry_calendar_day.dart` | `DateTime date`, `int expiryCount`, `bool hasExpired` | Calendar cell: date number, dot indicators (Yellow=expiring, Red=expired), count badge |
| `ShelfLifeProgressBar` | `shelflife_progress_bar.dart` | `DateTime productionDate`, `DateTime expiryDate` | Horizontal bar: elapsed % of shelf life, Green/Yellow/Red fill based on remaining |
| `ExpiryEventTile` | `expiry_event_tile.dart` | `ExpiryEvent event` | ListTile: product name, lot number, expiry date, days remaining badge, quantity affected |

### 17.7 Route Module

File: `lib/src/routing/shelflife_route_module.dart`

```dart
class ShelfLifeRouteModule extends RouteModule {
  @override String get moduleId => 'shelflife';

  @override List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/shelflife',
      builder: (_, state) => ShelfLifeDashboardScreen(propertyId: state.uri.queryParameters['propertyId'] ?? ''),
      routes: [
        GoRoute(path: 'rules', builder: (_, state) => ShelfLifeRuleListScreen(...),
          routes: [
            GoRoute(path: 'new', builder: (_, state) => ShelfLifeRuleEditorScreen(ruleId: null)),
            GoRoute(path: ':ruleId/edit', builder: (_, state) => ShelfLifeRuleEditorScreen(...)),
            GoRoute(path: ':ruleId/label', builder: (_, state) => LabelPreviewScreen(...)),
          ],
        ),
        GoRoute(path: 'calendar', builder: (_, state) => ExpiryCalendarScreen(...)),
      ],
    ),
  ];

  @override List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'shelflife', label: 'Shelf Life', icon: Icons.event_outlined,
      activeIcon: Icons.event, route: '/shelflife',
      requiredPermissions: {'shelflife_view'},
    ),
  ];

  @override Map<String, Set<String>> get routePermissions => {
    '/shelflife': {'shelflife_view'},
    '/shelflife/rules/new': {'shelflife_manage'},
  };

  @override PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_manufacturing',
    permissions: [
      PermissionEntry(key: 'shelflife_view', label: 'View Shelf Life', scope: PermissionScope.service),
      PermissionEntry(key: 'shelflife_manage', label: 'Manage Shelf Life Rules', scope: PermissionScope.action),
    ],
  );
}
```

### 17.8 Internal Reuse

| Imported From | Widgets/Providers Used | How |
|---|---|---|
| `antinvestor_ui_recipes` | `RecipeSearchSelect`, `recipeByIdProvider` | `ShelfLifeRuleEditorScreen` uses `RecipeSearchSelect` to associate a rule with a recipe. Rule display shows recipe name via `recipeByIdProvider`. |

---

## 18. Dependency Graph

```
antinvestor_ui_core (common)
  |
  +-- antinvestor_ui_profile (profile service)
  |     |
  |     +-- antinvestor_ui_customers (wraps profile)
  |     |     |
  |     |     +-- antinvestor_ui_orders (uses customers + catalog)
  |     |     +-- antinvestor_ui_pricing (uses customers + catalog)
  |     |
  |     +-- antinvestor_ui_procurement (uses profile + inventory)
  |
  +-- antinvestor_ui_catalog (leaf, commerce)
  |     |
  |     +-- antinvestor_ui_orders
  |     +-- antinvestor_ui_pricing
  |
  +-- antinvestor_ui_inventory (leaf, manufacturing)
  |     |
  |     +-- antinvestor_ui_recipes (uses inventory)
  |     |     |
  |     |     +-- antinvestor_ui_production (uses recipes + inventory)
  |     |     +-- antinvestor_ui_shelflife (uses recipes)
  |     |
  |     +-- antinvestor_ui_procurement (uses inventory)
  |     +-- antinvestor_ui_quality (uses inventory)
  |     +-- antinvestor_ui_waste (uses inventory)
  |     +-- antinvestor_ui_demand (uses inventory)
  |     +-- antinvestor_ui_traceability (uses inventory)
  |
  +-- antinvestor_ui_equipment (leaf, standalone)
  +-- antinvestor_ui_coldchain (leaf, standalone)
  +-- antinvestor_ui_costing (leaf, standalone)
```

### Dependency Rules

1. No circular dependencies. The graph is a DAG.
2. Leaf packages (`ui_catalog`, `ui_inventory`, `ui_equipment`, `ui_coldchain`, `ui_costing`) depend only on `ui_core` and their proto SDK.
3. Maximum dependency depth is 3: `ui_core` -> `ui_inventory` -> `ui_recipes` -> `ui_production`.
4. Cross-repository dependencies are allowed: `ui_procurement` (commerce) depends on `ui_inventory` (manufacturing).

---

## 19. Proto SDK Generation Requirements

### SDKs that already exist

| SDK | Location | Used By |
|---|---|---|
| `antinvestor_api_commerce` | `service-commerce/sdk/dart/commerce/` | ui_catalog, ui_customers, ui_orders |
| `antinvestor_api_profile` | `service-profile/sdk/dart/profile/` | ui_customers (via ui_profile) |

### SDKs that need generation

| SDK | Proto Source | Used By |
|---|---|---|
| `antinvestor_api_manufacturing` | `service-manufacturing/proto/manufacturing/v1/manufacturing.proto` | ui_inventory, ui_recipes, ui_production, ui_equipment, ui_coldchain, ui_quality, ui_waste, ui_costing, ui_demand, ui_traceability, ui_shelflife |
| `antinvestor_api_procurement` | `service-commerce/proto/procurement/v1/procurement.proto` | ui_procurement |
| `antinvestor_api_pricing` | `service-commerce/proto/pricing/v1/pricing.proto` | ui_pricing |

---

## 20. Implementation Order

Recommended build order respecting dependencies:

**Phase 1 -- Leaf packages (no inter-package UI deps)**
1. `ui_catalog`
2. `ui_inventory`
3. `ui_equipment`
4. `ui_coldchain`
5. `ui_costing`

**Phase 2 -- First-level dependents**
6. `ui_customers` (depends on ui_profile)
7. `ui_recipes` (depends on ui_inventory)
8. `ui_quality` (depends on ui_inventory)
9. `ui_waste` (depends on ui_inventory)
10. `ui_demand` (depends on ui_inventory)
11. `ui_traceability` (depends on ui_inventory)

**Phase 3 -- Second-level dependents**
12. `ui_orders` (depends on ui_catalog + ui_customers)
13. `ui_pricing` (depends on ui_catalog + ui_customers)
14. `ui_procurement` (depends on ui_inventory + ui_profile)
15. `ui_production` (depends on ui_recipes + ui_inventory)
16. `ui_shelflife` (depends on ui_recipes)

---

## 21. Host App Composition

The host application composes all packages using `RouteModule`:

```dart
final modules = <RouteModule>[
  // Commerce
  CatalogRouteModule(),
  CustomerRouteModule(),
  OrderRouteModule(),
  ProcurementRouteModule(),
  PricingRouteModule(),
  // Manufacturing
  InventoryRouteModule(),
  RecipeRouteModule(),
  ProductionRouteModule(),
  EquipmentRouteModule(),
  ColdChainRouteModule(),
  QualityRouteModule(),
  WasteRouteModule(),
  CostingRouteModule(),
  DemandRouteModule(),
  TraceabilityRouteModule(),
  ShelfLifeRouteModule(),
  // Profile (from existing package)
  ProfileRouteModule(),
];

// Build router
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        ...ownRoutes,
        for (final m in modules) ...m.buildRoutes(),
      ],
    ),
  ],
);

// Build navigation
final navItems = modules.expand((m) => m.buildNavItems()).toList();

// Collect permissions
final permissionManifests = modules
    .map((m) => m.permissionManifest)
    .whereType<PermissionManifest>()
    .toList();
```

Each module is independently testable, deployable, and can be included or
excluded from the host app without affecting others.
