import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import 'product_card.dart';

/// Responsive grid of [ProductCard]s driven by [productListProvider].
class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.shopId,
    this.onProductTap,
  });

  final String shopId;
  final void Function(Product product)? onProductTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncProducts = ref.watch(productListProvider(shopId));

    return asyncProducts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(productListProvider(shopId)),
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
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(120)),
                const SizedBox(height: 12),
                Text('No products yet', style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 80,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: onProductTap != null
                      ? () => onProductTap!(product)
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }
}
