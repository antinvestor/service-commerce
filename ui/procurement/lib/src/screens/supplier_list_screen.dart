import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../widgets/supplier_card.dart';
import 'supplier_form.dart';

/// Screen listing all suppliers.
class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncSuppliers = ref.watch(supplierListProvider(null));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSupplierForm(context: context, ref: ref),
        icon: const Icon(Icons.add),
        label: const Text('New Supplier'),
      ),
      body: asyncSuppliers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load suppliers',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(supplierListProvider(null)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha(120)),
                  const SizedBox(height: 12),
                  Text('No suppliers yet',
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
                    Icon(Icons.business_outlined,
                        size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Suppliers',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${suppliers.length} suppliers',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme
                                      .colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...suppliers.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SupplierCard(
                        supplier: s,
                        onTap: () => context
                            .go('/procurement/suppliers/${s.id}'),
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
