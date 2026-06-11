import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/pricing_providers.dart';
import '../widgets/price_list_entry_tile.dart';
import 'price_list_entry_form.dart';
import 'price_list_form.dart';

/// Detail screen for a price list, showing its entries with add/edit/delete.
class PriceListDetailScreen extends ConsumerWidget {
  const PriceListDetailScreen({
    super.key,
    required this.priceListId,
    required this.shopId,
  });

  final String priceListId;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncPriceList = ref.watch(priceListByIdProvider(priceListId));
    final asyncEntries = ref.watch(priceListEntryListProvider(priceListId));

    return Scaffold(
      body: asyncPriceList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load price list',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        data: (priceList) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/pricing'),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.price_change_outlined,
                      size: 28, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceList.name.isNotEmpty
                              ? priceList.name
                              : 'Price List',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(priceList.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go(
                        '/pricing/$priceListId/assignments'),
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Assignments'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => showPriceListForm(
                      context: context,
                      ref: ref,
                      shopId: shopId,
                      existing: priceList,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details
              _DetailRow(label: 'Currency', value: priceList.currency),
              _DetailRow(label: 'Priority', value: '${priceList.priority}'),
              _DetailRow(label: 'Status', value: priceList.status.name),
              const SizedBox(height: 20),

              // Entries
              Row(
                children: [
                  Expanded(
                    child: Text('Entries',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  TextButton.icon(
                    onPressed: () => showPriceListEntryForm(
                      context: context,
                      ref: ref,
                      priceListId: priceListId,
                      currency: priceList.currency,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Entry'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              asyncEntries.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Failed to load entries: $e'),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Text('No entries yet',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant));
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: entries
                          .map((e) => PriceListEntryTile(
                                entry: e,
                                onEdit: () => showPriceListEntryForm(
                                  context: context,
                                  ref: ref,
                                  priceListId: priceListId,
                                  currency: priceList.currency,
                                  existing: e,
                                ),
                                onDelete: () => deletePriceListEntry(
                                  context: context,
                                  ref: ref,
                                  priceListId: priceListId,
                                  entry: e,
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
