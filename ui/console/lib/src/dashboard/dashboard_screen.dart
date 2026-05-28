import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/dashboard_providers.dart';
import 'widgets/kpi_card.dart';
import 'widgets/module_grid.dart';
import 'widgets/recent_activity.dart';

/// Back-office landing page.
///
/// Three sections stacked vertically:
/// 1. Welcome banner (driven by `userClaimsProvider`)
/// 2. KPI strip — 4 cards summarizing the day
/// 3. Module grid — primary entry points into each domain
/// 4. Recent activity feed
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final claimsAsync = ref.watch(userClaimsProvider);
    final kpis = ref.watch(dashboardKpisProvider);
    final activity = ref.watch(recentActivityProvider);

    final displayName = claimsAsync.maybeWhen(
      data: (claims) =>
          claims['name'] as String? ??
          claims['preferred_username'] as String? ??
          'Operator',
      orElse: () => 'Operator',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(displayName: displayName),
              const SizedBox(height: 24),
              _KpiStrip(kpis: kpis),
              const SizedBox(height: 32),
              Text(
                'Modules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ModuleGrid(tiles: _moduleTiles(theme.colorScheme)),
              const SizedBox(height: 32),
              RecentActivityList(entries: activity),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<ModuleTile> _moduleTiles(ColorScheme c) => [
        ModuleTile(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          route: '/orders',
          color: c.primary,
        ),
        ModuleTile(
          label: 'Production',
          icon: Icons.precision_manufacturing_outlined,
          route: '/production',
          color: c.tertiary,
        ),
        ModuleTile(
          label: 'Inventory',
          icon: Icons.inventory_2_outlined,
          route: '/inventory',
          color: c.secondary,
        ),
        ModuleTile(
          label: 'Customers',
          icon: Icons.people_outline,
          route: '/customers',
          color: c.primary,
        ),
        ModuleTile(
          label: 'Catalog',
          icon: Icons.category_outlined,
          route: '/catalog',
          color: c.secondary,
        ),
        ModuleTile(
          label: 'Pricing',
          icon: Icons.sell_outlined,
          route: '/pricing',
          color: c.tertiary,
        ),
        ModuleTile(
          label: 'Recipes',
          icon: Icons.menu_book_outlined,
          route: '/recipes',
          color: c.primary,
        ),
        ModuleTile(
          label: 'Quality',
          icon: Icons.verified_outlined,
          route: '/quality',
          color: c.secondary,
        ),
        ModuleTile(
          label: 'Cold chain',
          icon: Icons.ac_unit_outlined,
          route: '/coldchain',
          color: c.tertiary,
        ),
        ModuleTile(
          label: 'Traceability',
          icon: Icons.timeline_outlined,
          route: '/traceability',
          color: c.primary,
        ),
        ModuleTile(
          label: 'Demand',
          icon: Icons.insights_outlined,
          route: '/demand',
          color: c.secondary,
        ),
        ModuleTile(
          label: 'Payments',
          icon: Icons.payments_outlined,
          route: '/payments',
          color: c.tertiary,
        ),
      ];
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $displayName',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is what is happening across operations today.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.kpis});

  final DashboardKpis kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            KpiCard(
              label: "Today's sales",
              value: kpis.todaysSales,
              icon: Icons.attach_money,
              trend: '+8% vs yesterday',
            ),
            KpiCard(
              label: 'Open POs',
              value: kpis.openPurchaseOrders.toString(),
              icon: Icons.local_shipping_outlined,
              trend: '3 awaiting receipt',
            ),
            KpiCard(
              label: 'Active batches',
              value: kpis.activeBatches.toString(),
              icon: Icons.precision_manufacturing_outlined,
              trend: '1 finishing soon',
            ),
            KpiCard(
              label: 'Low stock items',
              value: kpis.lowStockItems.toString(),
              icon: Icons.warning_amber_outlined,
              trend: 'Across 2 warehouses',
            ),
          ],
        );
      },
    );
  }
}
