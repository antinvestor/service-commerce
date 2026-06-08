import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/pricing_providers.dart';
import '../widgets/price_list_card.dart';

/// Screen listing all price lists for a shop.
class PriceListScreen extends ConsumerWidget {
  const PriceListScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncLists = ref.watch(priceListProvider(shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to price list create form
        },
        icon: const Icon(Icons.add),
        label: const Text('New Price List'),
      ),
      body: asyncLists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load price lists',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(priceListProvider(shopId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (priceLists) {
          if (priceLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.price_change_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha(120)),
                  const SizedBox(height: 12),
                  Text('No price lists yet',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.price_change_outlined,
                        size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price Lists',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${priceLists.length} price lists',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...priceLists.map((pl) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PriceListCard(
                        priceList: pl,
                        onTap: () =>
                            context.go('/pricing/${pl.id}'),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
