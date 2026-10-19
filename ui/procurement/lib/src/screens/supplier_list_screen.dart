import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../widgets/supplier_card.dart';
import 'supplier_form.dart';

/// Screen listing suppliers, filterable by type and status.
class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  SupplierType? _type;
  SupplierStatus? _status;

  SupplierFilter get _filter => (type: _type, status: _status);

  bool get _isFiltered => _type != null || _status != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncSuppliers = ref.watch(supplierListProvider(_filter));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSupplierForm(context: context, ref: ref),
        icon: const Icon(Icons.add),
        label: const Text('New Supplier'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Procurement',
                  onPressed: () => context.go(ProcurementPaths.root),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.business_outlined,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suppliers',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (asyncSuppliers.hasValue)
                        Text(
                          '${asyncSuppliers.requireValue.length} suppliers',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FilterRow<SupplierType>(
              label: 'Type',
              labels: supplierTypeLabels,
              selected: _type,
              onSelected: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 8),
            _FilterRow<SupplierStatus>(
              label: 'Status',
              labels: supplierStatusLabels,
              selected: _status,
              onSelected: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 16),
            asyncSuppliers.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load suppliers',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      friendlyError(error),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(supplierListProvider(_filter)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (suppliers) {
                if (suppliers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(
                              120,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isFiltered
                                ? 'No suppliers match these filters'
                                : 'No suppliers yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final s in suppliers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SupplierCard(
                          supplier: s,
                          onTap: () =>
                              context.go(ProcurementPaths.supplier(s.id)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled row of choice chips: "All" plus one chip per enum value.
class _FilterRow<T> extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Map<String, T> labels;
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: selected == null,
                onSelected: (_) => onSelected(null),
              ),
              for (final entry in labels.entries)
                ChoiceChip(
                  label: Text(entry.key),
                  selected: selected == entry.value,
                  onSelected: (_) => onSelected(entry.value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
