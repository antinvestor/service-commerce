import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';
import '../widgets/fulfilment_type_badge.dart';
import '../widgets/product_status_badge.dart';

/// Detail page for a single product showing product info and actions.
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

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({
    required this.product,
    required this.productId,
  });

  final Product product;
  final String productId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.isNotEmpty ? product.name : 'Unnamed Product',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
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
              FilledButton.icon(
                onPressed: () =>
                    context.go('/catalog/$productId/variants/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Variant'),
              ),
            ],
          ),

          // Status badges
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ProductStatusBadge(status: product.status),
                FulfilmentTypeBadge(type: product.fulfilmentType),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Product details card
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 700;
            final detailCard = _buildCard(
              context,
              title: 'Product Details',
              icon: Icons.info_outlined,
              child: Column(children: [
                _OvRow('Name',
                    product.name.isNotEmpty ? product.name : '—'),
                _OvRow('Description',
                    product.description.isNotEmpty
                        ? product.description
                        : '—'),
                _OvRow('Shop ID', product.shopId),
                _OvRow('Status', product.status.name),
                _OvRow('Fulfilment', product.fulfilmentType.name),
              ]),
            );

            final attrCard = product.attributes.isNotEmpty
                ? _buildCard(
                    context,
                    title: 'Attributes',
                    icon: Icons.label_outlined,
                    child: Column(
                      children: [
                        for (final e in product.attributes.entries)
                          _OvRow(e.key, e.value),
                      ],
                    ),
                  )
                : null;

            if (wide && attrCard != null) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: detailCard),
                  const SizedBox(width: 16),
                  Expanded(child: attrCard),
                ],
              );
            }
            return Column(children: [
              detailCard,
              if (attrCard != null) ...[const SizedBox(height: 16), attrCard],
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OvRow extends StatelessWidget {
  const _OvRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
            child: SelectableText(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
