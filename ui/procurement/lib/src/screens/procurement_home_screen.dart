import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';

/// Procurement landing page: entry cards for suppliers and purchase orders
/// with live counts.
class ProcurementHomeScreen extends ConsumerWidget {
  const ProcurementHomeScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncSuppliers = ref.watch(supplierListProvider(allSuppliers));
    final asyncOrders = ref.watch(purchaseOrderListProvider(propertyId));

    final openOrders = asyncOrders.whenData(
      (orders) => orders
          .where(
            (o) => switch (o.status) {
              PurchaseOrderStatus.PURCHASE_ORDER_STATUS_RECEIVED ||
              PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CANCELLED ||
              PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CLOSED => false,
              _ => true,
            },
          )
          .length,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Procurement',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _EntryCard(
                  key: const Key('procurement_home_suppliers'),
                  icon: Icons.business_outlined,
                  title: 'Suppliers',
                  count: asyncSuppliers.whenData((s) => s.length),
                  subtitle: 'Vendors and the items they supply',
                  onTap: () => context.go(ProcurementPaths.suppliers),
                ),
                _EntryCard(
                  key: const Key('procurement_home_orders'),
                  icon: Icons.assignment_outlined,
                  title: 'Purchase orders',
                  count: asyncOrders.whenData((o) => o.length),
                  subtitle: switch (openOrders) {
                    AsyncData(:final value) => '$value open',
                    _ => 'Orders placed with suppliers',
                  },
                  onTap: () => context.go(ProcurementPaths.orders),
                ),
                _EntryCard(
                  key: const Key('procurement_home_suggestions'),
                  icon: Icons.auto_awesome_outlined,
                  title: 'Suggestions',
                  count: null,
                  subtitle: 'Orders that cover a production plan',
                  onTap: () => context.go(ProcurementPaths.suggestions),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PermissionGuard(
              permissions: const {'purchase_order_create'},
              child: OutlinedButton.icon(
                onPressed: () => context.go(ProcurementPaths.newOrder),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New purchase order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    super.key,
    required this.icon,
    required this.title,
    this.count,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;

  /// Null for entries that have no count to show.
  final AsyncValue<int>? count;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (count case final count?)
                        Text(
                          switch (count) {
                            AsyncData(:final value) => '$value',
                            AsyncError() => '-',
                            _ => '...',
                          },
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
