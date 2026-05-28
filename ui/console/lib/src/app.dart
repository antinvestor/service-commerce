import 'package:antinvestor_ui_auth/antinvestor_ui_auth.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_coldchain/antinvestor_ui_coldchain.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:antinvestor_ui_costing/antinvestor_ui_costing.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_demand/antinvestor_ui_demand.dart';
import 'package:antinvestor_ui_equipment/antinvestor_ui_equipment.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart';
import 'package:antinvestor_ui_notification/antinvestor_ui_notification.dart';
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart';
import 'package:antinvestor_ui_payment/antinvestor_ui_payment.dart';
import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart';
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:antinvestor_ui_quality/antinvestor_ui_quality.dart';
import 'package:antinvestor_ui_recipes/antinvestor_ui_recipes.dart';
import 'package:antinvestor_ui_shelflife/antinvestor_ui_shelflife.dart';
import 'package:antinvestor_ui_traceability/antinvestor_ui_traceability.dart';
import 'package:antinvestor_ui_waste/antinvestor_ui_waste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_guard.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'shell/console_shell.dart';
import 'theme/console_theme.dart';

/// Placeholder shop/property identifiers used until user-context wiring
/// lands. Replace these with values resolved from the current session.
const String _kShopId = 'shop-1';
const String _kPropertyId = 'property-1';

/// Collects every domain `RouteModule` the console composes into its
/// top-level router.
///
/// Each entry is built with the demo `shopId` / `propertyId` defaults.
/// In production these will be resolved per-tenant from
/// `userClaimsProvider` and the active workspace.
List<RouteModule> _buildModules() => <RouteModule>[
      // Commerce
      CatalogRouteModule(shopId: _kShopId),
      CustomerRouteModule(),
      OrderRouteModule(shopId: _kShopId),
      PricingRouteModule(shopId: _kShopId),

      // Manufacturing
      ColdChainRouteModule(propertyId: _kPropertyId),
      CostingRouteModule(propertyId: _kPropertyId),
      DemandRouteModule(propertyId: _kPropertyId),
      EquipmentRouteModule(propertyId: _kPropertyId),
      InventoryRouteModule(propertyId: _kPropertyId),
      ProductionRouteModule(propertyId: _kPropertyId),
      QualityRouteModule(propertyId: _kPropertyId),
      RecipesRouteModule(propertyId: _kPropertyId),
      ShelfLifeRouteModule(propertyId: _kPropertyId),
      TraceabilityRouteModule(propertyId: _kPropertyId),
      WasteRouteModule(propertyId: _kPropertyId),

      // Cross-cutting
      AuthRouteModule(),
      NotificationRouteModule(),
      PaymentRouteModule(),
      ProfileRouteModule(),

      // TODO(commerce): procurement (no RouteModule yet) and identity
      // (no RouteModule yet) are surfaced via stand-in screens below
      // until those packages export their own modules.
    ];

final _routerProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(consoleAuthListenableProvider);
  final modules = _buildModules();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final loggedIn = listenable.isLoggedIn;
      final loc = state.matchedLocation;
      final atLogin = loc == '/login';
      if (!loggedIn && !atLogin) return '/login';
      if (loggedIn && atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ConsoleShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          // Placeholder routes for packages that don't (yet) expose a
          // RouteModule. Replace with the real module once it ships.
          GoRoute(
            path: '/identity',
            builder: (context, state) => const _IdentityPlaceholder(),
          ),
          GoRoute(
            path: '/procurement',
            builder: (context, state) => const _ProcurementPlaceholder(),
          ),
          for (final module in modules) ...module.buildRoutes(),
        ],
      ),
    ],
  );
});

/// Root widget for the console back-office app.
class ConsoleApp extends ConsumerWidget {
  const ConsoleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'Antinvestor Console',
      debugShowCheckedModeBanner: false,
      theme: ConsoleTheme.light(),
      darkTheme: ConsoleTheme.dark(),
      routerConfig: router,
    );
  }
}

/// Stand-in for the identity module until it exposes a `RouteModule`.
class _IdentityPlaceholder extends StatelessWidget {
  const _IdentityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity')),
      body: const Center(
        // The package ships `OrganizationsScreen` etc. directly; once
        // it provides a route module we'll merge it like the others.
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Identity module is available as widgets but has no route '
            'module yet. Drop in the screens from antinvestor_ui_identity '
            'when wiring is needed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Stand-in for procurement until its `RouteModule` lands.
class _ProcurementPlaceholder extends StatelessWidget {
  const _ProcurementPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procurement')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Procurement screens exist (suppliers, POs, receipts) but no '
            'route module has been published yet. Add a '
            'ProcurementRouteModule to antinvestor_ui_procurement to '
            'compose them here.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
