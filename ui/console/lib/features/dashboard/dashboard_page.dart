import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/responsive_layout.dart';
import 'data/dashboard_providers.dart';
import 'widgets/kpi_card.dart';
import 'widgets/module_grid.dart';
import 'widgets/recent_activity.dart';

/// Console landing page.
///
/// Four sections stacked vertically:
/// 1. Welcome banner (driven by `userClaimsProvider`)
/// 2. KPI strip — commerce + manufacturing health
/// 3. Module grid — primary entry points into each domain
/// 4. Recent activity feed
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final claimsAsync = ref.watch(userClaimsProvider);
    final kpisAsync = ref.watch(dashboardKpisProvider);
    final activity = ref.watch(recentActivityProvider);
    final screenSize = screenSizeOf(context);

    // Render whatever data we have (including the empty sentinel before
    // the tenant scope resolves); error and loading states fall back to
    // the empty snapshot so the strip never disappears.
    final kpis = kpisAsync.when(
      data: (data) => data,
      loading: () => DashboardKpis.empty(),
      error: (_, _) => DashboardKpis.empty(),
    );

    final displayName = claimsAsync.maybeWhen(
      data: (claims) =>
          claims['name'] as String? ??
          claims['preferred_username'] as String? ??
          'Operator',
      orElse: () => 'Operator',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Welcome back, $displayName',
                subtitle:
                    'Here is what is happening across operations today.',
                breadcrumbs: const ['Dashboard'],
              ),
              const SizedBox(height: 24),
              _KpiStrip(kpis: kpis, screenSize: screenSize),
              const SizedBox(height: 32),
              Text(
                'Modules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ModuleGrid(tiles: _moduleTiles()),
              const SizedBox(height: 32),
              RecentActivityList(entries: activity),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<ModuleTile> _moduleTiles() => [
        const ModuleTile(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          route: '/orders',
          color: AppColors.tertiary,
        ),
        const ModuleTile(
          label: 'Production',
          icon: Icons.precision_manufacturing_outlined,
          route: '/production',
          color: AppColors.primary,
        ),
        const ModuleTile(
          label: 'Inventory',
          icon: Icons.inventory_2_outlined,
          route: '/inventory',
          color: AppColors.secondary,
        ),
        const ModuleTile(
          label: 'Customers',
          icon: Icons.people_outline,
          route: '/customers',
          color: AppColors.tertiary,
        ),
        const ModuleTile(
          label: 'Catalog',
          icon: Icons.category_outlined,
          route: '/catalog',
          color: AppColors.secondary,
        ),
        const ModuleTile(
          label: 'Pricing',
          icon: Icons.sell_outlined,
          route: '/pricing',
          color: AppColors.primary,
        ),
        const ModuleTile(
          label: 'Recipes',
          icon: Icons.menu_book_outlined,
          route: '/recipes',
          color: AppColors.tertiary,
        ),
        const ModuleTile(
          label: 'Quality',
          icon: Icons.verified_outlined,
          route: '/quality',
          color: AppColors.success,
        ),
        const ModuleTile(
          label: 'Cold chain',
          icon: Icons.ac_unit_outlined,
          route: '/coldchain',
          color: AppColors.info,
        ),
        const ModuleTile(
          label: 'Traceability',
          icon: Icons.timeline_outlined,
          route: '/traceability',
          color: AppColors.primary,
        ),
        const ModuleTile(
          label: 'Demand',
          icon: Icons.insights_outlined,
          route: '/demand',
          color: AppColors.secondary,
        ),
        const ModuleTile(
          label: 'Payments',
          icon: Icons.payments_outlined,
          route: '/payments',
          color: AppColors.tertiary,
        ),
      ];
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.kpis, required this.screenSize});

  final DashboardKpis kpis;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      KpiCard(
        label: "Today's sales",
        value: kpis.todaysSales,
        icon: Icons.attach_money,
        change: '+8% vs yesterday',
      ),
      KpiCard(
        label: 'Open POs',
        value: kpis.openPurchaseOrders.toString(),
        icon: Icons.local_shipping_outlined,
        change: '3 awaiting receipt',
      ),
      KpiCard(
        label: 'Active batches',
        value: kpis.activeBatches.toString(),
        icon: Icons.precision_manufacturing_outlined,
        change: '1 finishing soon',
      ),
      KpiCard(
        label: 'Low stock',
        value: kpis.lowStockItems.toString(),
        icon: Icons.warning_amber_outlined,
        change: 'Across 2 warehouses',
        changePositive: false,
      ),
      KpiCard(
        label: 'Expiring stock',
        value: kpis.expiringStockItems.toString(),
        icon: Icons.schedule_outlined,
        change: 'Within 7 days',
        changePositive: false,
      ),
    ];

    if (screenSize == ScreenSize.mobile) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
            .toList(),
      );
    }

    return Row(
      children: cards
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }
}
