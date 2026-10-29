import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../widgets/customer_override_tile.dart';
import '../widgets/pricing_section_nav.dart';
import 'customer_price_override_form.dart';

/// Screen listing customer price overrides, filterable by customer and
/// variant, with create/edit.
class PriceOverridesScreen extends ConsumerStatefulWidget {
  const PriceOverridesScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<PriceOverridesScreen> createState() =>
      _PriceOverridesScreenState();
}

class _PriceOverridesScreenState extends ConsumerState<PriceOverridesScreen> {
  final _customerFilter = TextEditingController();
  final _variantFilter = TextEditingController();
  String? _customerId;
  String? _variantId;

  @override
  void dispose() {
    _customerFilter.dispose();
    _variantFilter.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final c = _customerFilter.text.trim();
    final v = _variantFilter.text.trim();
    setState(() {
      _customerId = c.isEmpty ? null : c;
      _variantId = v.isEmpty ? null : v;
    });
  }

  void _clearFilters() {
    _customerFilter.clear();
    _variantFilter.clear();
    setState(() {
      _customerId = null;
      _variantId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final params = (customerId: _customerId, variantId: _variantId);
    final asyncOverrides = ref.watch(customerOverrideListProvider(params));
    final filtered = _customerId != null || _variantId != null;

    return Scaffold(
      floatingActionButton: PermissionGuard(
        permissions: const {'customer_price_override'},
        child: FloatingActionButton.extended(
          onPressed: () => showCustomerPriceOverrideForm(
            context: context,
            ref: ref,
            shopId: widget.shopId,
          ),
          icon: const Icon(Icons.add),
          label: const Text('New Override'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PricingSectionNav(current: PricingSection.overrides),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Price Overrides',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'A fixed unit price for one customer and variant',
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _customerFilter,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID',
                      isDense: true,
                      prefixIcon: Icon(Icons.person_search, size: 18),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _variantFilter,
                    decoration: const InputDecoration(
                      labelText: 'Variant ID',
                      isDense: true,
                      prefixIcon: Icon(Icons.sell_outlined, size: 18),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
                if (filtered)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            asyncOverrides.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                      'Failed to load overrides',
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
                          ref.invalidate(customerOverrideListProvider(params)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (overrides) {
                if (overrides.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(
                              120,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            filtered
                                ? 'No overrides match these filters'
                                : 'No customer overrides',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: overrides
                        .map(
                          (o) => CustomerOverrideTile(
                            override_: o,
                            onTap: () => showCustomerPriceOverrideForm(
                              context: context,
                              ref: ref,
                              shopId: widget.shopId,
                              existing: o,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
