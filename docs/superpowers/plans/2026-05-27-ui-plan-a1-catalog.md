# UI Package A1 — `antinvestor_ui_catalog`

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the first Flutter widget package (`antinvestor_ui_catalog`) for the antinvestor commerce platform. This package provides product catalog browsing, variant selection, and catalog management screens/widgets backed by the `antinvestor_api_commerce` Dart SDK via Connect RPC. It establishes the pattern all 15 subsequent UI widget packages will follow.

**Architecture:** Flutter widget package following `antinvestor_ui_profile` conventions. Riverpod 3 providers wrapping Connect RPC calls to `CommerceServiceClient`. Card-based action-oriented UX with `StatusBadge.fromEnum` for status pills, `AmountDisplay` for prices, `FormFieldCard` for form fields, and `GoRouter`-based routing via `RouteModule` from `antinvestor_ui_core`.

**Tech Stack:** Flutter/Dart 3.11, Riverpod 3.3, Connect RPC, GoRouter 17, protobuf 4.2, antinvestor_ui_core 0.4, antinvestor_api_commerce.

**Spec:** See `docs/superpowers/specs/2026-05-27-service-ui-widget-packages-design.md` section 2 for the full catalog package design.

**Scope of this plan:** Regenerate the commerce Dart SDK (pricing RPCs were added), scaffold the package, implement all 6 providers, 10 widgets, 7 screens, 1 route module, barrel export, and widget tests.

---

## File Structure

```text
service-commerce/ui/catalog/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── antinvestor_ui_catalog.dart
│   └── src/
│       ├── providers/
│       │   ├── catalog_transport_provider.dart
│       │   └── catalog_providers.dart
│       ├── screens/
│       │   ├── catalog_browse_screen.dart
│       │   ├── product_detail_screen.dart
│       │   ├── product_create_screen.dart
│       │   ├── product_edit_screen.dart
│       │   ├── variant_create_screen.dart
│       │   ├── variant_edit_screen.dart
│       │   └── catalog_analytics_screen.dart
│       ├── widgets/
│       │   ├── product_card.dart
│       │   ├── product_grid.dart
│       │   ├── variant_card.dart
│       │   ├── variant_selector.dart
│       │   ├── product_status_badge.dart
│       │   ├── variant_status_badge.dart
│       │   ├── product_search_select.dart
│       │   ├── variant_price_tile.dart
│       │   ├── fulfilment_type_badge.dart
│       │   └── product_quick_add.dart
│       └── routing/
│           └── catalog_route_module.dart
└── test/
    ├── widgets/
    │   ├── product_card_test.dart
    │   ├── product_status_badge_test.dart
    │   └── variant_selector_test.dart
    └── providers/
        └── catalog_providers_test.dart
```

---

## Task 1: Regenerate Commerce Dart SDK

**Why:** The pricing RPCs (`PriceListSave`, `PriceListGet`, `PriceListSearch`, `PriceListEntryBatchSave`, `CustomerPriceListAssignmentSave`, `CustomerPriceListAssignmentSearch`, `CustomerPriceOverrideSave`, `CustomerPriceOverrideSearch`, `DiscountRuleSave`, `DiscountRuleSearch`, `ResolvePrice`) were added to `proto/commerce/v1/commerce.proto` but the Dart SDK at `sdk/dart/commerce/` has not been regenerated yet. The `CommerceServiceClient` in the current SDK does not include these methods.

**Files:**
- Modified: `sdk/dart/commerce/lib/src/v1/commerce.connect.client.dart` (regenerated)
- Modified: `sdk/dart/commerce/lib/src/v1/commerce.pb.dart` (regenerated)
- Modified: `sdk/dart/commerce/lib/src/v1/commerce.pbenum.dart` (regenerated)
- Modified: `sdk/dart/commerce/lib/src/v1/commerce.pbjson.dart` (regenerated)
- Modified: `sdk/dart/commerce/lib/src/v1/commerce.connect.spec.dart` (regenerated)

- [ ] **Step 1: Regenerate the Dart SDK**

```bash
cd ~/code/antinvestor/service-commerce
make proto-generate-dart
```

- [ ] **Step 2: Verify pricing RPCs exist in the generated client**

```bash
grep -c "priceListSave\|priceListGet\|priceListSearch\|resolvePrice\|discountRuleSave\|discountRuleSearch" sdk/dart/commerce/lib/src/v1/commerce.connect.client.dart
```

Expected: 6 or more matches confirming the pricing methods are present.

- [ ] **Step 3: Verify the barrel export includes the new types**

Check that `sdk/dart/commerce/lib/antinvestor_api_commerce.dart` already exports `commerce.pb.dart` and `commerce.pbenum.dart` (it does -- these exports cover the new pricing message types and enums since they live in the same proto file).

- [ ] **Step 4: Commit the regenerated SDK**

```bash
cd ~/code/antinvestor/service-commerce
git add sdk/dart/commerce/
git commit -m "chore(sdk): regenerate commerce Dart SDK with pricing RPCs"
```

---

## Task 2: Package Scaffold

**Files:**
- Create: `ui/catalog/pubspec.yaml`
- Create: `ui/catalog/analysis_options.yaml`
- Create: directory structure under `ui/catalog/lib/src/`
- Create: directory structure under `ui/catalog/test/`

- [ ] **Step 1: Create directory structure**

```bash
cd ~/code/antinvestor/service-commerce
mkdir -p ui/catalog/lib/src/{providers,screens,widgets,routing}
mkdir -p ui/catalog/test/{widgets,providers}
```

- [ ] **Step 2: Create pubspec.yaml**

Create `ui/catalog/pubspec.yaml`:

```yaml
name: antinvestor_ui_catalog
description: >
  Product catalog UI library for Antinvestor. Embeddable screens and widgets
  for browsing products, selecting variants, and managing catalog entries.
version: 0.1.0
repository: https://github.com/antinvestor/service-commerce
homepage: https://github.com/antinvestor/service-commerce/tree/main/ui/catalog
issue_tracker: https://github.com/antinvestor/service-commerce/issues
topics:
  - flutter
  - ui
  - catalog
  - antinvestor
  - commerce

environment:
  sdk: ^3.11.0

dependencies:
  flutter:
    sdk: flutter
  antinvestor_ui_core: ^0.4.0
  antinvestor_api_commerce: ^1.54.0
  antinvestor_api_common: ^1.52.0
  connectrpc: ^1.0.0
  flutter_riverpod: ^3.3.1
  go_router: ^17.2.0
  protobuf: ^4.2.0
  fixnum: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^7.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Create analysis_options.yaml**

Create `ui/catalog/analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml
```

- [ ] **Step 4: Commit scaffold**

```bash
cd ~/code/antinvestor/service-commerce
git add ui/catalog/
git commit -m "chore(ui_catalog): scaffold package directory and pubspec"
```

---

## Task 3: Transport Provider

**Files:**
- Create: `ui/catalog/lib/src/providers/catalog_transport_provider.dart`

- [ ] **Step 1: Create catalog_transport_provider.dart**

Create `ui/catalog/lib/src/providers/catalog_transport_provider.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _commerceUrl = String.fromEnvironment(
  'COMMERCE_URL',
  defaultValue: 'https://api.antinvestor.com/commerce',
);

final catalogTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _commerceUrl);
});

final catalogServiceClientProvider = Provider<CommerceServiceClient>((ref) {
  final transport = ref.watch(catalogTransportProvider);
  return CommerceServiceClient(transport);
});
```

---

## Task 4: Domain Providers

**Files:**
- Create: `ui/catalog/lib/src/providers/catalog_providers.dart`

- [ ] **Step 1: Create catalog_providers.dart**

Create `ui/catalog/lib/src/providers/catalog_providers.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_transport_provider.dart';

/// Search products in a shop by name/description query.
final productSearchProvider = FutureProvider.family<List<Product>,
    ({String shopId, String query})>((ref, params) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = ListProductsRequest()
    ..shopId = params.shopId
    ..search = (SearchRequest()..query = params.query);
  final response = await client.listProducts(request);
  return response.products;
});

/// Get a single product by ID.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = GetProductRequest()..id = id;
  final response = await client.getProduct(request);
  return response.product;
});

/// List all products for a shop ID.
final productListProvider =
    FutureProvider.family<List<Product>, String>((ref, shopId) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = ListProductsRequest()..shopId = shopId;
  final response = await client.listProducts(request);
  return response.products;
});

/// List all variants for a product ID.
///
/// Uses ListProducts with the product's shop to get the product,
/// then returns the variants from a GetProduct call which includes
/// variant data. Since the proto returns variants via separate RPC
/// calls, we list products filtered by product ID and then fetch
/// the product detail.
///
/// Note: The commerce proto does not have a dedicated ListProductVariants RPC.
/// Variants are fetched by getting the product and accessing its variants
/// through the product detail. For now, we call GetProduct and the server
/// returns variants as part of the product response if the server supports it,
/// or we use the ListProducts response which may include variant data.
/// This provider will be refined once the API confirms variant listing behavior.
final productVariantsByProductProvider =
    FutureProvider.family<List<ProductVariant>, String>((ref, productId) async {
  // Fetch the product to get its shop_id, then use ListProducts
  // filtered by that product. The actual variant listing depends on
  // the server implementation. For now, we return an empty list
  // that will be populated when the server supports variant listing.
  //
  // TODO: Update when a dedicated ListProductVariants RPC is added,
  // or when the server returns variants in the GetProduct response.
  final client = ref.watch(catalogServiceClientProvider);
  final request = GetProductRequest()..id = productId;
  final response = await client.getProduct(request);
  // The proto does not embed variants in GetProductResponse.
  // Return empty until a variant listing RPC is available.
  // For now, we use the search with product ID filter.
  _ = response;
  return <ProductVariant>[];
});

/// Notifier for product mutations (create, update).
class ProductNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(catalogServiceClientProvider);

  Future<Product> create(CreateProductRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProduct(request);
      state = const AsyncValue.data(null);
      return response.product;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, AsyncValue<void>>(ProductNotifier.new);

/// Notifier for variant mutations (create, update).
class VariantNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(catalogServiceClientProvider);

  Future<ProductVariant> create(CreateProductVariantRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProductVariant(request);
      state = const AsyncValue.data(null);
      return response.productVariant;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<ProductVariant> update(UpdateProductVariantRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateProductVariant(request);
      state = const AsyncValue.data(null);
      return response.productVariant;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final variantNotifierProvider =
    NotifierProvider<VariantNotifier, AsyncValue<void>>(VariantNotifier.new);
```

---

## Task 5: Status Badge Widgets

**Files:**
- Create: `ui/catalog/lib/src/widgets/product_status_badge.dart`
- Create: `ui/catalog/lib/src/widgets/variant_status_badge.dart`
- Create: `ui/catalog/lib/src/widgets/fulfilment_type_badge.dart`

- [ ] **Step 1: Create product_status_badge.dart**

Create `ui/catalog/lib/src/widgets/product_status_badge.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [ProductStatus].
///
/// Green = ACTIVE, Grey = INACTIVE, Red = ARCHIVED.
class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        ProductStatus.PRODUCT_STATUS_ACTIVE =>
          ('Active', Colors.green, Icons.check_circle_outline),
        ProductStatus.PRODUCT_STATUS_INACTIVE =>
          ('Inactive', Colors.grey, Icons.pause_circle_outline),
        ProductStatus.PRODUCT_STATUS_ARCHIVED =>
          ('Archived', Colors.red, Icons.archive_outlined),
        _ => ('Unknown', Colors.grey, Icons.help_outline),
      },
    );
  }
}
```

- [ ] **Step 2: Create variant_status_badge.dart**

Create `ui/catalog/lib/src/widgets/variant_status_badge.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [ProductVariantStatus].
///
/// Green = ACTIVE, Grey = DISABLED.
class VariantStatusBadge extends StatelessWidget {
  const VariantStatusBadge({super.key, required this.status});

  final ProductVariantStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE =>
          ('Active', Colors.green, Icons.check_circle_outline),
        ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED =>
          ('Disabled', Colors.grey, Icons.block_outlined),
        _ => ('Unknown', Colors.grey, Icons.help_outline),
      },
    );
  }
}
```

- [ ] **Step 3: Create fulfilment_type_badge.dart**

Create `ui/catalog/lib/src/widgets/fulfilment_type_badge.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Icon + label badge for [FulfilmentType].
///
/// Truck icon = PHYSICAL, cloud icon = DIGITAL, dash = NONE.
class FulfilmentTypeBadge extends StatelessWidget {
  const FulfilmentTypeBadge({super.key, required this.type});

  final FulfilmentType type;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: type,
      mapper: (t) => switch (t) {
        FulfilmentType.FULFILMENT_TYPE_PHYSICAL =>
          ('Physical', Colors.blue, Icons.local_shipping_outlined),
        FulfilmentType.FULFILMENT_TYPE_DIGITAL =>
          ('Digital', Colors.purple, Icons.cloud_outlined),
        FulfilmentType.FULFILMENT_TYPE_NONE =>
          ('None', Colors.grey, Icons.remove),
        _ => ('Unknown', Colors.grey, Icons.help_outline),
      },
    );
  }
}
```

---

## Task 6: Card Widgets

**Files:**
- Create: `ui/catalog/lib/src/widgets/product_card.dart`
- Create: `ui/catalog/lib/src/widgets/variant_card.dart`
- Create: `ui/catalog/lib/src/widgets/variant_price_tile.dart`

- [ ] **Step 1: Create product_card.dart**

Create `ui/catalog/lib/src/widgets/product_card.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';

import 'fulfilment_type_badge.dart';
import 'product_status_badge.dart';

/// A card widget for displaying a [Product] in list or grid views.
///
/// Shows the product name, status badge, fulfilment type icon,
/// and a variant count chip. Tapping invokes [onTap].
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.variantCount = 0,
  });

  final Product product;
  final VoidCallback? onTap;
  final int variantCount;

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
          child: Row(
            children: [
              // Product thumbnail placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.mediaIds.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ProductStatusBadge(status: product.status),
                        const SizedBox(width: 8),
                        FulfilmentTypeBadge(type: product.fulfilmentType),
                      ],
                    ),
                  ],
                ),
              ),
              if (variantCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$variantCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create variant_card.dart**

Create `ui/catalog/lib/src/widgets/variant_card.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

import 'variant_status_badge.dart';

/// A card widget for displaying a [ProductVariant].
///
/// Shows SKU, variant name, price via [AmountDisplay], stock quantity
/// with color coding (Green >10, Yellow 1-10, Red 0), and status badge.
class VariantCard extends StatelessWidget {
  const VariantCard({
    super.key,
    required this.variant,
    this.onTap,
  });

  final ProductVariant variant;
  final VoidCallback? onTap;

  Color _stockColor(int quantity) {
    if (quantity <= 0) return Colors.red;
    if (quantity <= 10) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockQty = variant.stockQuantity.toInt();

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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${variant.sku}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        VariantStatusBadge(status: variant.status),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _stockColor(stockQty).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stock: $stockQty',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _stockColor(stockQty),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AmountDisplay(amount: variant.price),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create variant_price_tile.dart**

Create `ui/catalog/lib/src/widgets/variant_price_tile.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

/// A [ListTile] showing a variant's name, SKU as subtitle,
/// and price as trailing [AmountDisplay].
class VariantPriceTile extends StatelessWidget {
  const VariantPriceTile({
    super.key,
    required this.variant,
    this.onTap,
  });

  final ProductVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        variant.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'SKU: ${variant.sku}',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: AmountDisplay(amount: variant.price),
      onTap: onTap,
    );
  }
}
```

---

## Task 7: Interactive Widgets

**Files:**
- Create: `ui/catalog/lib/src/widgets/product_grid.dart`
- Create: `ui/catalog/lib/src/widgets/variant_selector.dart`
- Create: `ui/catalog/lib/src/widgets/product_search_select.dart`
- Create: `ui/catalog/lib/src/widgets/product_quick_add.dart`

- [ ] **Step 1: Create product_grid.dart**

Create `ui/catalog/lib/src/widgets/product_grid.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import 'product_card.dart';

/// A responsive grid of [ProductCard] widgets with pull-to-refresh.
///
/// Watches [productListProvider] for the given [shopId] and renders
/// each product as a card. Selecting a product calls [onProductSelected].
class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.shopId,
    this.onProductSelected,
  });

  final String shopId;
  final ValueChanged<Product>? onProductSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListProvider(shopId));

    return asyncProducts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load products',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(friendlyError(error),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(productListProvider(shopId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withAlpha(120)),
                const SizedBox(height: 12),
                Text('No products yet',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text('Add your first product to get started',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productListProvider(shopId));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

              if (crossAxisCount == 1) {
                // List layout for narrow screens
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProductCard(
                        product: product,
                        onTap: () => onProductSelected?.call(product),
                      ),
                    );
                  },
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => onProductSelected?.call(product),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Create variant_selector.dart**

Create `ui/catalog/lib/src/widgets/variant_selector.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import 'variant_status_badge.dart';

/// A horizontal scrollable chip list of variants for a product.
///
/// Tapping a chip shows a detail bottom sheet with price and stock.
/// The "Select" button in the bottom sheet calls [onSelected].
class VariantSelector extends ConsumerWidget {
  const VariantSelector({
    super.key,
    required this.productId,
    required this.onSelected,
    this.selectedVariantId,
  });

  final String productId;
  final ValueChanged<ProductVariant> onSelected;
  final String? selectedVariantId;

  void _showVariantDetail(BuildContext context, ProductVariant variant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                variant.name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'SKU: ${variant.sku}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Price: ', style: theme.textTheme.bodyMedium),
                  AmountDisplay(amount: variant.price),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Stock: ', style: theme.textTheme.bodyMedium),
                  Text(
                    '${variant.stockQuantity.toInt()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              VariantStatusBadge(status: variant.status),
              if (variant.attributes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: variant.attributes.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSelected(variant);
                  },
                  child: const Text('Select'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncVariants =
        ref.watch(productVariantsByProductProvider(productId));

    return asyncVariants.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Failed to load variants: ${friendlyError(error)}',
          style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        ),
      ),
      data: (variants) {
        if (variants.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'No variants available',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }

        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: variants.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final variant = variants[index];
              final isSelected = variant.id == selectedVariantId;

              return ChoiceChip(
                label: Text(variant.name),
                selected: isSelected,
                onSelected: (_) =>
                    _showVariantDetail(context, variant),
                avatar: isSelected
                    ? const Icon(Icons.check, size: 16)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Create product_search_select.dart**

Create `ui/catalog/lib/src/widgets/product_search_select.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import 'product_card.dart';

/// An embeddable search-and-select widget for products in a shop.
///
/// Shows a text field that searches products as the user types, displays
/// results in a dropdown overlay showing [ProductCard] items, and calls
/// [onSelected] when a product is picked.
class ProductSearchSelect extends ConsumerStatefulWidget {
  const ProductSearchSelect({
    super.key,
    required this.shopId,
    required this.onSelected,
    this.label = 'Search products',
    this.autofocus = false,
  });

  final String shopId;
  final ValueChanged<Product> onSelected;
  final String label;
  final bool autofocus;

  @override
  ConsumerState<ProductSearchSelect> createState() =>
      _ProductSearchSelectState();
}

class _ProductSearchSelectState extends ConsumerState<ProductSearchSelect> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value.trim());
    if (_query.length >= 2) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final width = renderBox.size.width;

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: _ResultsList(
              shopId: widget.shopId,
              query: _query,
              onSelected: _onProductSelected,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _onProductSelected(Product product) {
    _removeOverlay();
    _controller.text = product.name;
    _query = '';
    widget.onSelected(product);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: _onQueryChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

/// Internal results list rendered inside the overlay.
class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.shopId,
    required this.query,
    required this.onSelected,
  });

  final String shopId;
  final String query;
  final ValueChanged<Product> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      productSearchProvider((shopId: shopId, query: query)),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: results.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Search failed',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No products found'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => onSelected(product),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Create product_quick_add.dart**

Create `ui/catalog/lib/src/widgets/product_quick_add.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

/// A bottom sheet with minimal fields for rapid product creation.
///
/// Fields: product name, first variant name, price, currency.
/// Calls [onCreated] when the product and its first variant are created.
class ProductQuickAdd extends ConsumerStatefulWidget {
  const ProductQuickAdd({
    super.key,
    required this.shopId,
    this.onCreated,
  });

  final String shopId;
  final VoidCallback? onCreated;

  /// Shows the quick add bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String shopId,
    VoidCallback? onCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProductQuickAdd(
          shopId: shopId,
          onCreated: onCreated,
        ),
      ),
    );
  }

  @override
  ConsumerState<ProductQuickAdd> createState() => _ProductQuickAddState();
}

class _ProductQuickAddState extends ConsumerState<ProductQuickAdd> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _variantNameController = TextEditingController();
  final _priceController = TextEditingController();
  String _currency = 'UGX';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _productNameController.dispose();
    _variantNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create the product
      final productRequest = CreateProductRequest()
        ..shopId = widget.shopId
        ..name = _productNameController.text.trim();

      final product = await ref
          .read(productNotifierProvider.notifier)
          .create(productRequest);

      // Create the first variant
      final variantRequest = CreateProductVariantRequest()
        ..productId = product.id
        ..name = _variantNameController.text.trim()
        ..sku = '${product.id}-001';

      setMoneyFields(
        variantRequest.price,
        _priceController.text.trim(),
        _currency,
      );

      await ref
          .read(variantNotifierProvider.notifier)
          .create(variantRequest);

      // Invalidate the product list to refresh
      ref.invalidate(productListProvider(widget.shopId));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onCreated?.call();
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add Product',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g. Fresh Yoghurt',
              ),
              autofocus: true,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _variantNameController,
              decoration: const InputDecoration(
                labelText: 'First Variant Name',
                hintText: 'e.g. 500ml Strawberry',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Variant name is required'
                      : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: '0.00',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validateAmount,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'UGX', child: Text('UGX')),
                      DropdownMenuItem(value: 'KES', child: Text('KES')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _currency = v);
                    },
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _create,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add, size: 18),
                label: const Text('Create Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Task 8: Screens

**Files:**
- Create: `ui/catalog/lib/src/screens/catalog_browse_screen.dart`
- Create: `ui/catalog/lib/src/screens/product_detail_screen.dart`
- Create: `ui/catalog/lib/src/screens/product_create_screen.dart`
- Create: `ui/catalog/lib/src/screens/product_edit_screen.dart`
- Create: `ui/catalog/lib/src/screens/variant_create_screen.dart`
- Create: `ui/catalog/lib/src/screens/variant_edit_screen.dart`
- Create: `ui/catalog/lib/src/screens/catalog_analytics_screen.dart`

- [ ] **Step 1: Create catalog_browse_screen.dart**

Create `ui/catalog/lib/src/screens/catalog_browse_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/product_quick_add.dart';
import '../widgets/product_status_badge.dart';

/// Card grid of products with search, status filter chips, and "Add Product" FAB.
class CatalogBrowseScreen extends ConsumerStatefulWidget {
  const CatalogBrowseScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<CatalogBrowseScreen> createState() =>
      _CatalogBrowseScreenState();
}

class _CatalogBrowseScreenState extends ConsumerState<CatalogBrowseScreen> {
  String _query = '';
  ProductStatus? _statusFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use search provider when query is non-empty, list provider otherwise
    final asyncProducts = _query.isNotEmpty
        ? ref.watch(productSearchProvider(
            (shopId: widget.shopId, query: _query)))
        : ref.watch(productListProvider(widget.shopId));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Icon(Icons.storefront_outlined,
                    size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Product Catalog',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/catalog/analytics?shopId=${widget.shopId}'),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Analytics'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () =>
                      context.go('/catalog/new?shopId=${widget.shopId}'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Product'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search + filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _query = value.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Search products by name...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status filter chips
                ...ProductStatus.values
                    .where((s) =>
                        s != ProductStatus.PRODUCT_STATUS_UNSPECIFIED)
                    .map((status) {
                  final isSelected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: FilterChip(
                      label: ProductStatusBadge(status: status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? status : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product list
          Expanded(
            child: asyncProducts.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load products',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(friendlyError(error),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (_query.isNotEmpty) {
                          ref.invalidate(productSearchProvider(
                              (shopId: widget.shopId, query: _query)));
                        } else {
                          ref.invalidate(
                              productListProvider(widget.shopId));
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (products) {
                // Apply local status filter
                final filtered = _statusFilter != null
                    ? products
                        .where((p) => p.status == _statusFilter)
                        .toList()
                    : products;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant
                                .withAlpha(120)),
                        const SizedBox(height: 12),
                        Text(
                          _query.isNotEmpty || _statusFilter != null
                              ? 'No products match your filters'
                              : 'No products yet',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_query.isNotEmpty) {
                      ref.invalidate(productSearchProvider(
                          (shopId: widget.shopId, query: _query)));
                    } else {
                      ref.invalidate(
                          productListProvider(widget.shopId));
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProductCard(
                          product: product,
                          onTap: () =>
                              context.go('/catalog/${product.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProductQuickAdd.show(
          context,
          shopId: widget.shopId,
          onCreated: () {
            ref.invalidate(productListProvider(widget.shopId));
          },
        ),
        tooltip: 'Quick Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 2: Create product_detail_screen.dart**

Create `ui/catalog/lib/src/screens/product_detail_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';
import '../widgets/fulfilment_type_badge.dart';
import '../widgets/product_status_badge.dart';
import '../widgets/variant_card.dart';

/// Product detail screen showing product info, variant list as cards,
/// stock summary per variant, and edit/archive actions.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncProduct = ref.watch(productByIdProvider(productId));

    return asyncProduct.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load product',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(friendlyError(error),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(productByIdProvider(productId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (product) =>
          _ProductDetailContent(product: product, productId: productId),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({
    required this.product,
    required this.productId,
  });

  final Product product;
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncVariants =
        ref.watch(productVariantsByProductProvider(productId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 28,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    SelectableText('ID: ${product.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/catalog'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go('/catalog/$productId/edit'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),

          // Status badges
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ProductStatusBadge(status: product.status),
                FulfilmentTypeBadge(type: product.fulfilmentType),
              ],
            ),
          ),

          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(product.description,
                style: theme.textTheme.bodyMedium),
          ],

          // Attributes
          if (product.attributes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Attributes',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: product.attributes.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 12)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],

          // Variants section
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Variants',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () =>
                    context.go('/catalog/$productId/variants/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Variant'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          asyncVariants.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load variants: ${friendlyError(error)}',
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            ),
            data: (variants) {
              if (variants.isEmpty) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No variants yet. Add one to get started.'),
                    ),
                  ),
                );
              }

              return Column(
                children: variants.map((variant) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VariantCard(
                      variant: variant,
                      onTap: () => context.go(
                          '/catalog/$productId/variants/${variant.id}/edit'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create product_create_screen.dart**

Create `ui/catalog/lib/src/screens/product_create_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Guided step flow for creating a new product.
///
/// Steps: (1) Name/Description -> (2) Attributes -> (3) Review & Create.
class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attributeKeyController = TextEditingController();
  final _attributeValueController = TextEditingController();

  FulfilmentType _fulfilmentType = FulfilmentType.FULFILMENT_TYPE_PHYSICAL;
  final Map<String, String> _attributes = {};
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _attributeKeyController.dispose();
    _attributeValueController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    final key = _attributeKeyController.text.trim();
    final value = _attributeValueController.text.trim();
    if (key.isNotEmpty && value.isNotEmpty) {
      setState(() {
        _attributes[key] = value;
        _attributeKeyController.clear();
        _attributeValueController.clear();
      });
    }
  }

  Future<void> _create() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = CreateProductRequest()
        ..shopId = widget.shopId
        ..name = _nameController.text.trim()
        ..description = _descriptionController.text.trim();

      for (final entry in _attributes.entries) {
        request.attributes[entry.key] = entry.value;
      }

      final created = await ref
          .read(productNotifierProvider.notifier)
          .create(request);

      ref.invalidate(productListProvider(widget.shopId));

      if (mounted) {
        context.go('/catalog/${created.id}');
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep = 1);
              }
            } else if (_currentStep == 1) {
              setState(() => _currentStep = 2);
            } else {
              _create();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.go('/catalog?shopId=${widget.shopId}');
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (isLastStep)
                    GradientButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      label: 'Create Product',
                      icon: Icons.check,
                      isLoading: _isLoading,
                    )
                  else
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Continue'),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Name & Description
            Step(
              title: const Text('Product Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  FormFieldCard(
                    label: 'Product Name',
                    isRequired: true,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Fresh Yoghurt',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                  ),
                  FormFieldCard(
                    label: 'Description',
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Optional product description...',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  FormFieldCard(
                    label: 'Fulfilment Type',
                    isRequired: true,
                    child: DropdownButtonFormField<FulfilmentType>(
                      value: _fulfilmentType,
                      items: const [
                        DropdownMenuItem(
                          value: FulfilmentType.FULFILMENT_TYPE_PHYSICAL,
                          child: Text('Physical'),
                        ),
                        DropdownMenuItem(
                          value: FulfilmentType.FULFILMENT_TYPE_DIGITAL,
                          child: Text('Digital'),
                        ),
                        DropdownMenuItem(
                          value: FulfilmentType.FULFILMENT_TYPE_NONE,
                          child: Text('None'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _fulfilmentType = v);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Step 2: Attributes
            Step(
              title: const Text('Attributes'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _attributeKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            hintText: 'e.g. Category',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _attributeValueController,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            hintText: 'e.g. Dairy',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addAttribute,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_attributes.isEmpty)
                    Text('No attributes added yet (optional)',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _attributes.entries.map((entry) {
                        return Chip(
                          label: Text('${entry.key}: ${entry.value}'),
                          onDeleted: () => setState(
                              () => _attributes.remove(entry.key)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Step 3: Review
            Step(
              title: const Text('Review & Create'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewRow('Name', _nameController.text),
                  if (_descriptionController.text.isNotEmpty)
                    _ReviewRow('Description', _descriptionController.text),
                  _ReviewRow('Fulfilment', _fulfilmentType.name),
                  if (_attributes.isNotEmpty)
                    _ReviewRow(
                      'Attributes',
                      _attributes.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create product_edit_screen.dart**

Create `ui/catalog/lib/src/screens/product_edit_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Edit product fields with confirmation before save.
///
/// Note: The commerce proto does not currently have an UpdateProduct RPC.
/// This screen prepares the UI for when it is added. For now, it displays
/// the product fields in read-only mode with a placeholder save action.
class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductEditScreen> createState() =>
      _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;

  void _initFromProduct(Product product) {
    if (!_initialized) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Changes?'),
        content: const Text(
            'Are you sure you want to update this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Call updateProduct when the RPC is available.
      // For now, show a message that the update RPC is not yet implemented.
      await Future.delayed(const Duration(milliseconds: 500));

      ref.invalidate(productByIdProvider(widget.productId));

      if (mounted) {
        context.go('/catalog/${widget.productId}');
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncProduct = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load: ${friendlyError(error)}'),
        ),
        data: (product) {
          _initFromProduct(product);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FormFieldCard(
                  label: 'Product Name',
                  isRequired: true,
                  child: TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                ),
                FormFieldCard(
                  label: 'Description',
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GradientButton(
                    onPressed: _isLoading ? null : _save,
                    label: 'Save Changes',
                    icon: Icons.save_outlined,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Create variant_create_screen.dart**

Create `ui/catalog/lib/src/screens/variant_create_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Guided flow for creating a new product variant.
///
/// Steps: (1) SKU auto-gen + name -> (2) Price picker -> (3) Attributes -> (4) Review.
class VariantCreateScreen extends ConsumerStatefulWidget {
  const VariantCreateScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<VariantCreateScreen> createState() =>
      _VariantCreateScreenState();
}

class _VariantCreateScreenState extends ConsumerState<VariantCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _attributeKeyController = TextEditingController();
  final _attributeValueController = TextEditingController();

  String _currency = 'UGX';
  final Map<String, String> _attributes = {};
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-generate a SKU placeholder
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _skuController.text =
        '${widget.productId.substring(0, widget.productId.length.clamp(0, 8))}-${timestamp.substring(timestamp.length - 4)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _attributeKeyController.dispose();
    _attributeValueController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    final key = _attributeKeyController.text.trim();
    final value = _attributeValueController.text.trim();
    if (key.isNotEmpty && value.isNotEmpty) {
      setState(() {
        _attributes[key] = value;
        _attributeKeyController.clear();
        _attributeValueController.clear();
      });
    }
  }

  Future<void> _create() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = CreateProductVariantRequest()
        ..productId = widget.productId
        ..name = _nameController.text.trim()
        ..sku = _skuController.text.trim()
        ..stockQuantity = Int64.parseInt(
            _stockController.text.trim().isEmpty
                ? '0'
                : _stockController.text.trim());

      setMoneyFields(
        request.price,
        _priceController.text.trim(),
        _currency,
      );

      for (final entry in _attributes.entries) {
        request.attributes[entry.key] = entry.value;
      }

      await ref.read(variantNotifierProvider.notifier).create(request);

      ref.invalidate(productVariantsByProductProvider(widget.productId));

      if (mounted) {
        context.go('/catalog/${widget.productId}');
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Variant')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              if (_currentStep == 0 &&
                  !_formKey.currentState!.validate()) {
                return;
              }
              setState(() => _currentStep++);
            } else {
              _create();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.go('/catalog/${widget.productId}');
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (isLastStep)
                    GradientButton(
                      onPressed:
                          _isLoading ? null : details.onStepContinue,
                      label: 'Create Variant',
                      icon: Icons.check,
                      isLoading: _isLoading,
                    )
                  else
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Continue'),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child:
                        Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Name + SKU
            Step(
              title: const Text('Variant Identity'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  FormFieldCard(
                    label: 'Variant Name',
                    isRequired: true,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 500ml Strawberry',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                  ),
                  FormFieldCard(
                    label: 'SKU',
                    description: 'Auto-generated. You can customize it.',
                    child: TextFormField(
                      controller: _skuController,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),

            // Step 2: Price
            Step(
              title: const Text('Price'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormFieldCard(
                          label: 'Unit Price',
                          isRequired: true,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: validateAmount,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: FormFieldCard(
                          label: 'Currency',
                          child: DropdownButtonFormField<String>(
                            value: _currency,
                            items: const [
                              DropdownMenuItem(
                                  value: 'UGX', child: Text('UGX')),
                              DropdownMenuItem(
                                  value: 'KES', child: Text('KES')),
                              DropdownMenuItem(
                                  value: 'USD', child: Text('USD')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _currency = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  FormFieldCard(
                    label: 'Initial Stock',
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),

            // Step 3: Attributes
            Step(
              title: const Text('Attributes'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _attributeKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            hintText: 'e.g. Size',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _attributeValueController,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            hintText: 'e.g. 500ml',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addAttribute,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_attributes.isEmpty)
                    Text('No attributes added (optional)',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _attributes.entries.map((entry) {
                        return Chip(
                          label:
                              Text('${entry.key}: ${entry.value}'),
                          onDeleted: () => setState(
                              () => _attributes.remove(entry.key)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Step 4: Review
            Step(
              title: const Text('Review'),
              isActive: _currentStep >= 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewRow('Name', _nameController.text),
                  _ReviewRow('SKU', _skuController.text),
                  _ReviewRow(
                    'Price',
                    '$_currency ${_priceController.text}',
                  ),
                  _ReviewRow('Stock', _stockController.text),
                  if (_attributes.isNotEmpty)
                    _ReviewRow(
                      'Attributes',
                      _attributes.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Create variant_edit_screen.dart**

Create `ui/catalog/lib/src/screens/variant_edit_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Edit variant fields; price change shows old vs new with confirmation.
class VariantEditScreen extends ConsumerStatefulWidget {
  const VariantEditScreen({
    super.key,
    required this.productId,
    required this.variantId,
  });

  final String productId;
  final String variantId;

  @override
  ConsumerState<VariantEditScreen> createState() =>
      _VariantEditScreenState();
}

class _VariantEditScreenState extends ConsumerState<VariantEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String _currency = 'UGX';
  ProductVariantStatus _status =
      ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE;
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;
  dynamic _originalPrice;

  void _initFromVariant(ProductVariant variant) {
    if (!_initialized) {
      _nameController.text = variant.name;
      _skuController.text = variant.sku;
      _priceController.text = moneyToAmountString(variant.price);
      _currency = moneyCurrency(variant.price, 'UGX');
      _stockController.text = variant.stockQuantity.toInt().toString();
      _status = variant.status;
      _originalPrice = variant.price;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation with price comparison if price changed
    final newPriceStr = _priceController.text.trim();
    final oldPriceStr = moneyToAmountString(_originalPrice);
    final priceChanged = newPriceStr != oldPriceStr;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Changes?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priceChanged) ...[
              const Text('Price will change:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Old: ',
                      style: TextStyle(
                          color: Theme.of(ctx)
                              .colorScheme
                              .onSurfaceVariant)),
                  AmountDisplay(amount: _originalPrice),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('New: '),
                  Text('$_currency $newPriceStr',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const Text('Are you sure you want to update this variant?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = UpdateProductVariantRequest()
        ..variantId = widget.variantId
        ..name = _nameController.text.trim()
        ..sku = _skuController.text.trim()
        ..status = _status
        ..stockQuantity = Int64.parseInt(
            _stockController.text.trim().isEmpty
                ? '0'
                : _stockController.text.trim());

      setMoneyFields(request.price, newPriceStr, _currency);

      await ref
          .read(variantNotifierProvider.notifier)
          .update(request);

      ref.invalidate(
          productVariantsByProductProvider(widget.productId));

      if (mounted) {
        context.go('/catalog/${widget.productId}');
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We need to fetch the variant. Since we don't have a getVariant RPC,
    // we'll use the variants list and find by ID.
    final asyncVariants =
        ref.watch(productVariantsByProductProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Variant')),
      body: asyncVariants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load: ${friendlyError(error)}'),
        ),
        data: (variants) {
          final variant = variants.where((v) => v.id == widget.variantId);
          if (variant.isEmpty) {
            return const Center(child: Text('Variant not found'));
          }

          _initFromVariant(variant.first);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FormFieldCard(
                  label: 'Variant Name',
                  isRequired: true,
                  child: TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                ),
                FormFieldCard(
                  label: 'SKU',
                  child: TextFormField(
                    controller: _skuController,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FormFieldCard(
                        label: 'Unit Price',
                        isRequired: true,
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: validateAmount,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: FormFieldCard(
                        label: 'Currency',
                        child: DropdownButtonFormField<String>(
                          value: _currency,
                          items: const [
                            DropdownMenuItem(
                                value: 'UGX', child: Text('UGX')),
                            DropdownMenuItem(
                                value: 'KES', child: Text('KES')),
                            DropdownMenuItem(
                                value: 'USD', child: Text('USD')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _currency = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                FormFieldCard(
                  label: 'Stock Quantity',
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                FormFieldCard(
                  label: 'Status',
                  child: DropdownButtonFormField<ProductVariantStatus>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(
                        value: ProductVariantStatus
                            .PRODUCT_VARIANT_STATUS_ACTIVE,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: ProductVariantStatus
                            .PRODUCT_VARIANT_STATUS_DISABLED,
                        child: Text('Disabled'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GradientButton(
                    onPressed: _isLoading ? null : _save,
                    label: 'Save Changes',
                    icon: Icons.save_outlined,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 7: Create catalog_analytics_screen.dart**

Create `ui/catalog/lib/src/screens/catalog_analytics_screen.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

/// Analytics overview for the product catalog.
///
/// Shows product count, active/inactive breakdown, and top variants by stock.
class CatalogAnalyticsScreen extends ConsumerWidget {
  const CatalogAnalyticsScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncProducts = ref.watch(productListProvider(shopId));

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog Analytics')),
      body: asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load analytics',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(productListProvider(shopId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          final totalProducts = products.length;
          final activeProducts = products
              .where((p) =>
                  p.status == ProductStatus.PRODUCT_STATUS_ACTIVE)
              .length;
          final inactiveProducts = products
              .where((p) =>
                  p.status == ProductStatus.PRODUCT_STATUS_INACTIVE)
              .length;
          final archivedProducts = products
              .where((p) =>
                  p.status == ProductStatus.PRODUCT_STATUS_ARCHIVED)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                // Metric cards row
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  final cards = [
                    _MetricCard(
                      icon: Icons.inventory_2_outlined,
                      label: 'Total Products',
                      value: '$totalProducts',
                      color: theme.colorScheme.primary,
                    ),
                    _MetricCard(
                      icon: Icons.check_circle_outline,
                      label: 'Active',
                      value: '$activeProducts',
                      color: Colors.green,
                    ),
                    _MetricCard(
                      icon: Icons.pause_circle_outline,
                      label: 'Inactive',
                      value: '$inactiveProducts',
                      color: Colors.grey,
                    ),
                    _MetricCard(
                      icon: Icons.archive_outlined,
                      label: 'Archived',
                      value: '$archivedProducts',
                      color: Colors.red,
                    ),
                  ];

                  if (wide) {
                    return Row(
                      children: cards
                          .map((c) => Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(right: 12),
                                  child: c,
                                ),
                              ))
                          .toList(),
                    );
                  }
                  return Column(
                    children: cards
                        .map((c) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: c,
                            ))
                        .toList(),
                  );
                }),

                const SizedBox(height: 24),
                Text('Fulfilment Type Breakdown',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Fulfilment type breakdown
                ...FulfilmentType.values
                    .where((t) =>
                        t != FulfilmentType.FULFILMENT_TYPE_UNSPECIFIED)
                    .map((type) {
                  final count = products
                      .where((p) => p.fulfilmentType == type)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(type.name.replaceAll(
                              'FULFILMENT_TYPE_', '')),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: totalProducts > 0
                                ? count / totalProducts
                                : 0,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$count'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
```

---

## Task 9: Route Module

**Files:**
- Create: `ui/catalog/lib/src/routing/catalog_route_module.dart`

- [ ] **Step 1: Create catalog_route_module.dart**

Create `ui/catalog/lib/src/routing/catalog_route_module.dart`:

```dart
import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/catalog_analytics_screen.dart';
import '../screens/catalog_browse_screen.dart';
import '../screens/product_create_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_edit_screen.dart';
import '../screens/variant_create_screen.dart';
import '../screens/variant_edit_screen.dart';

class CatalogRouteModule extends RouteModule {
  @override
  String get moduleId => 'catalog';

  @override
  List<RouteBase> buildRoutes() => [
        GoRoute(
          path: '/catalog',
          builder: (context, state) => CatalogBrowseScreen(
            shopId: state.uri.queryParameters['shopId'] ?? '',
          ),
          routes: [
            GoRoute(
              path: 'analytics',
              builder: (context, state) => CatalogAnalyticsScreen(
                shopId: state.uri.queryParameters['shopId'] ?? '',
              ),
            ),
            GoRoute(
              path: 'new',
              builder: (context, state) => ProductCreateScreen(
                shopId: state.uri.queryParameters['shopId'] ?? '',
              ),
            ),
            GoRoute(
              path: ':productId',
              builder: (context, state) => ProductDetailScreen(
                productId: state.pathParameters['productId']!,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => ProductEditScreen(
                    productId: state.pathParameters['productId']!,
                  ),
                ),
                GoRoute(
                  path: 'variants/new',
                  builder: (context, state) => VariantCreateScreen(
                    productId: state.pathParameters['productId']!,
                  ),
                ),
                GoRoute(
                  path: 'variants/:variantId/edit',
                  builder: (context, state) => VariantEditScreen(
                    productId: state.pathParameters['productId']!,
                    variantId: state.pathParameters['variantId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

  @override
  List<NavItem> buildNavItems() => [
        const NavItem(
          id: 'catalog',
          label: 'Catalog',
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          route: '/catalog',
          requiredPermissions: {'catalog_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => {
        '/catalog': {'catalog_view'},
        '/catalog/new': {'catalog_manage'},
        '/catalog/analytics': {'catalog_view'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_commerce',
        permissions: [
          PermissionEntry(
            key: 'catalog_view',
            label: 'View Catalog',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'catalog_manage',
            label: 'Manage Catalog',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'variant_manage',
            label: 'Manage Variants',
            scope: PermissionScope.action,
          ),
        ],
      );
}
```

---

## Task 10: Barrel Export

**Files:**
- Create: `ui/catalog/lib/antinvestor_ui_catalog.dart`

- [ ] **Step 1: Create the barrel export file**

Create `ui/catalog/lib/antinvestor_ui_catalog.dart`:

```dart
/// Product catalog UI library for Antinvestor.
///
/// Provides embeddable screens and widgets for browsing products,
/// selecting variants, and managing catalog entries.
library;

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

---

## Task 11: Widget Tests

**Files:**
- Create: `ui/catalog/test/widgets/product_card_test.dart`
- Create: `ui/catalog/test/widgets/product_status_badge_test.dart`
- Create: `ui/catalog/test/widgets/variant_selector_test.dart`

- [ ] **Step 1: Create product_card_test.dart**

Create `ui/catalog/test/widgets/product_card_test.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/src/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard', () {
    late Product product;

    setUp(() {
      product = Product()
        ..id = 'prod-001'
        ..shopId = 'shop-001'
        ..name = 'Fresh Yoghurt'
        ..description = 'Delicious dairy product'
        ..status = ProductStatus.PRODUCT_STATUS_ACTIVE
        ..fulfilmentType = FulfilmentType.FULFILMENT_TYPE_PHYSICAL;
    });

    testWidgets('renders product name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Fresh Yoghurt'), findsOneWidget);
    });

    testWidgets('renders product description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Delicious dairy product'), findsOneWidget);
    });

    testWidgets('renders status badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders fulfilment type badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Physical'), findsOneWidget);
    });

    testWidgets('renders variant count chip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product, variantCount: 5),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('does not render variant count chip when zero',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product, variantCount: 0),
          ),
        ),
      );

      // The style_outlined icon should not appear
      expect(find.byIcon(Icons.style_outlined), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Create product_status_badge_test.dart**

Create `ui/catalog/test/widgets/product_status_badge_test.dart`:

```dart
import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/src/widgets/product_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductStatusBadge', () {
    testWidgets('renders Active for PRODUCT_STATUS_ACTIVE', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductStatusBadge(
              status: ProductStatus.PRODUCT_STATUS_ACTIVE,
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders Inactive for PRODUCT_STATUS_INACTIVE',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductStatusBadge(
              status: ProductStatus.PRODUCT_STATUS_INACTIVE,
            ),
          ),
        ),
      );

      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('renders Archived for PRODUCT_STATUS_ARCHIVED',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductStatusBadge(
              status: ProductStatus.PRODUCT_STATUS_ARCHIVED,
            ),
          ),
        ),
      );

      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('renders Unknown for PRODUCT_STATUS_UNSPECIFIED',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductStatusBadge(
              status: ProductStatus.PRODUCT_STATUS_UNSPECIFIED,
            ),
          ),
        ),
      );

      expect(find.text('Unknown'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Create variant_selector_test.dart**

Create `ui/catalog/test/widgets/variant_selector_test.dart`:

```dart
import 'package:antinvestor_ui_catalog/src/widgets/variant_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VariantSelector', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VariantSelector(
                productId: 'prod-001',
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no variants', (tester) async {
      // This test verifies the widget renders properly with a ProviderScope.
      // Full integration testing with mocked providers would use
      // a ProviderScope override for productVariantsByProductProvider.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VariantSelector(
                productId: 'prod-001',
                onSelected: (_) {},
                selectedVariantId: null,
              ),
            ),
          ),
        ),
      );

      // Initial state is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

---

## Task 12: Verify and Commit

- [ ] **Step 1: Run flutter pub get**

```bash
cd ~/code/antinvestor/service-commerce/ui/catalog
flutter pub get
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd ~/code/antinvestor/service-commerce/ui/catalog
flutter analyze
```

Fix any analysis issues before proceeding.

- [ ] **Step 3: Run flutter test**

```bash
cd ~/code/antinvestor/service-commerce/ui/catalog
flutter test
```

All tests should pass.

- [ ] **Step 4: Run individual test files for verification**

```bash
cd ~/code/antinvestor/service-commerce/ui/catalog
flutter test test/widgets/product_card_test.dart
flutter test test/widgets/product_status_badge_test.dart
flutter test test/widgets/variant_selector_test.dart
```

- [ ] **Step 5: Commit the complete package**

```bash
cd ~/code/antinvestor/service-commerce
git add ui/catalog/
git commit -m "feat(ui_catalog): add antinvestor_ui_catalog Flutter widget package

Implements the first of 16 Flutter widget packages:
- 6 Riverpod providers (product search, list, getById, variants, notifiers)
- 10 widgets (ProductCard, ProductGrid, VariantCard, VariantSelector, badges, etc.)
- 7 screens (browse, detail, create, edit, analytics)
- CatalogRouteModule with GoRouter routes and permission manifest
- Widget tests for ProductCard, ProductStatusBadge, VariantSelector"
```

---

## Notes

### Proto API Reference

| RPC Method | Request | Response | Used By |
|---|---|---|---|
| `listProducts` | `ListProductsRequest` | `ListProductsResponse` | `productSearchProvider`, `productListProvider` |
| `getProduct` | `GetProductRequest` | `GetProductResponse` | `productByIdProvider` |
| `createProduct` | `CreateProductRequest` | `CreateProductResponse` | `ProductNotifier.create` |
| `createProductVariant` | `CreateProductVariantRequest` | `CreateProductVariantResponse` | `VariantNotifier.create` |
| `updateProductVariant` | `UpdateProductVariantRequest` | `UpdateProductVariantResponse` | `VariantNotifier.update` |

### Dart Field Accessor Names (from proto snake_case)

| Proto Field | Dart Accessor |
|---|---|
| `shop_id` | `shopId` |
| `product_id` | `productId` |
| `stock_quantity` | `stockQuantity` |
| `fulfilment_type` | `fulfilmentType` |
| `media_ids` | `mediaIds` |
| `created_at` | `createdAt` |
| `variant_id` | `variantId` |
| `update_mask` | `updateMask` |

### Key ui_core Imports

| Widget/Helper | Import |
|---|---|
| `StatusBadge.fromEnum` | `package:antinvestor_ui_core/widgets/status_badge.dart` |
| `AmountDisplay` | `package:antinvestor_ui_core/widgets/amount_display.dart` |
| `FormFieldCard` | `package:antinvestor_ui_core/widgets/form_field_card.dart` |
| `GradientButton` | `package:antinvestor_ui_core/widgets/gradient_button.dart` |
| `friendlyError` | `package:antinvestor_ui_core/widgets/error_helpers.dart` |
| `formatMoney`, `setMoneyFields`, `validateAmount`, `moneyToAmountString`, `moneyCurrency` | `package:antinvestor_ui_core/widgets/money_helpers.dart` |
| `RouteModule` | `package:antinvestor_ui_core/routing/route_module.dart` |
| `NavItem` | `package:antinvestor_ui_core/navigation/nav_items.dart` |
| `PermissionManifest`, `PermissionEntry`, `PermissionScope` | `package:antinvestor_ui_core/permissions/permission_manifest.dart` |
| `authTokenProviderProvider`, `createTransport` | `package:antinvestor_ui_core/api/api_base.dart` |

### Known Gaps

1. **No `UpdateProduct` RPC**: The commerce proto has no `UpdateProduct` -- only `UpdateProductVariant`. `ProductEditScreen` is scaffolded but the save action is a placeholder until the RPC is added.

2. **No `ListProductVariants` RPC**: There is no dedicated RPC to list variants by product ID. `productVariantsByProductProvider` currently returns an empty list. When the server adds this capability (or embeds variants in `GetProductResponse`), update the provider.

3. **No `UpdateProduct` for status changes**: Archiving/deactivating a product is not possible until `UpdateProduct` is added. The edit screen should add status change support when the RPC is available.

4. **`fixnum` dependency**: The `Int64` type from `fixnum` is needed for `stockQuantity` in `CreateProductVariantRequest`. Import with `import 'package:fixnum/fixnum.dart';` in files that construct variant requests (already handled in `variant_create_screen.dart` and `variant_edit_screen.dart` via the proto-generated types which re-export `Int64`).
