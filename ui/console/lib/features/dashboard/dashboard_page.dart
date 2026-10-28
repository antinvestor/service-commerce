import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/data/auth_state_provider.dart' show consoleClaimsProvider;

import '../../core/auth/console_permissions.dart';
import '../../core/router/console_modules.dart';
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
/// 1. Welcome banner (driven by `consoleClaimsProvider`)
/// 2. KPI strip — commerce + manufacturing health
/// 3. Module grid — primary entry points into each domain
/// 4. Recent activity feed
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final claimsAsync = ref.watch(consoleClaimsProvider);
    final activity =
        ref.watch(recentActivityProvider).value ??
        const <RecentActivityEntry>[];
    final screenSize = screenSizeOf(context);
    final registered = ref.watch(registeredRoutePathsProvider);
    final granted = ref.watch(userPermissionsProvider).value ?? const {};

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
                subtitle: 'Here is what is happening across operations today.',
                breadcrumbs: const ['Dashboard'],
              ),
              const SizedBox(height: 24),
              _KpiStrip(screenSize: screenSize),
              const SizedBox(height: 32),
              Text(
                'Modules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ModuleGrid(
                tiles: [
                  for (final tile in _moduleTiles())
                    if (isRouteRegistered(registered, tile.route) &&
                        canOpenRoute(tile.route, granted))
                      tile,
                ],
              ),
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
      label: 'Procurement',
      icon: Icons.local_shipping_outlined,
      route: '/procurement',
      color: AppColors.secondary,
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

/// A count, or a dash when it could not be loaded.
String _count(int? value) => value?.toString() ?? '—';

class _KpiStrip extends ConsumerWidget {
  const _KpiStrip({required this.screenSize});

  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(todaysSalesProvider).value;
    final awaiting = ref.watch(awaitingPaymentProvider).value;
    final cards = <Widget>[
      KpiCard(
        key: const ValueKey('kpi-todays-sales'),
        label: "Today's sales",
        value: sales?.value ?? '—',
        note: sales?.note,
        icon: Icons.attach_money,
      ),
      KpiCard(
        key: const ValueKey('kpi-awaiting-payment'),
        label: 'Awaiting payment',
        value: awaiting?.value ?? '—',
        note: awaiting?.note,
        icon: Icons.hourglass_bottom_outlined,
      ),
      KpiCard(
        label: 'Open POs',
        value: _count(ref.watch(openPurchaseOrdersProvider).value),
        icon: Icons.local_shipping_outlined,
      ),
      KpiCard(
        label: 'Active batches',
        value: _count(ref.watch(activeBatchesProvider).value),
        icon: Icons.precision_manufacturing_outlined,
      ),
    ];

    if (screenSize == ScreenSize.mobile) {
      return Column(
        children: cards
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
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
