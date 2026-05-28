import 'package:antinvestor_ui_auth/antinvestor_ui_auth.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_coldchain/antinvestor_ui_coldchain.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:antinvestor_ui_costing/antinvestor_ui_costing.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_demand/antinvestor_ui_demand.dart';
import 'package:antinvestor_ui_equipment/antinvestor_ui_equipment.dart';
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart';
import 'package:antinvestor_ui_notification/antinvestor_ui_notification.dart';
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart';
import 'package:antinvestor_ui_payment/antinvestor_ui_payment.dart';
import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart';
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
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

import '../../features/auth/data/auth_state_provider.dart';
import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/splash_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/settings/settings_page.dart';
import '../auth/tenant_context_provider.dart';
import '../widgets/responsive_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Composes the 16 commerce + manufacturing route modules plus the
/// three cross-cutting modules for the active tenant scope.
///
/// `shopId` is the commerce-side tenant; `propertyId` is the
/// operational site (factory, kitchen, warehouse). Both come from
/// [tenantScopeProvider].
List<RouteModule> buildConsoleModules(TenantScope scope) => <RouteModule>[
      // Commerce
      CatalogRouteModule(shopId: scope.shopId),
      CustomerRouteModule(),
      OrderRouteModule(shopId: scope.shopId),
      PricingRouteModule(shopId: scope.shopId),
      ProcurementRouteModule(propertyId: scope.propertyId),

      // Manufacturing
      ColdChainRouteModule(propertyId: scope.propertyId),
      CostingRouteModule(propertyId: scope.propertyId),
      DemandRouteModule(propertyId: scope.propertyId),
      EquipmentRouteModule(propertyId: scope.propertyId),
      InventoryRouteModule(propertyId: scope.propertyId),
      ProductionRouteModule(propertyId: scope.propertyId),
      QualityRouteModule(propertyId: scope.propertyId),
      RecipesRouteModule(propertyId: scope.propertyId),
      ShelfLifeRouteModule(propertyId: scope.propertyId),
      TraceabilityRouteModule(propertyId: scope.propertyId),
      WasteRouteModule(propertyId: scope.propertyId),

      // Cross-cutting
      AuthRouteModule(),
      NotificationRouteModule(),
      PaymentRouteModule(),
      ProfileRouteModule(),
    ];

/// Creates the app router with auth-aware redirect logic, mirroring
/// thesa's three-state pattern.
///
/// - **Loading**: auth is being determined → show splash (no redirect)
/// - **Unauthenticated**: redirect to /login
/// - **Authenticated**: redirect away from /login and /auth/callback to /
GoRouter createAppRouter(Ref ref, {String initialLocation = '/'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) {
      final authState = ref.read(consoleAuthStateProvider);
      final routePath = state.uri.path;
      final isLoginRoute = routePath == '/login';
      final isLogoutRoute = routePath == '/logout';
      final isAuthCallback = routePath == '/auth/callback';
      final isSplash = routePath == '/splash';

      // Handle logout — always process immediately.
      if (isLogoutRoute) {
        ref.read(consoleAuthStateProvider.notifier).logout();
        return '/login';
      }

      final isLoading = authState.isLoading;
      final isAuthenticated = authState.whenOrNull(
            data: (s) => s == AuthState.authenticated,
          ) ??
          false;

      // While auth is loading, send to splash unless already there or
      // on the callback route (which needs to complete the OAuth flow).
      if (isLoading) {
        if (isAuthCallback || isSplash) return null;
        return '/splash';
      }

      // Auth callback while unauthenticated — let it through so the
      // OAuth exchange can complete.
      if (isAuthCallback && !isAuthenticated) return null;

      // Unauthenticated user on any protected route → login.
      if (!isAuthenticated && !isLoginRoute) return '/login';

      // Authenticated user on login, callback, or splash → dashboard.
      if (isAuthenticated &&
          (isLoginRoute || isAuthCallback || isSplash)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/logout',
        redirect: (context, state) => '/login',
      ),
      // Web OAuth redirect callback — shows splash while processing.
      GoRoute(
        path: '/auth/callback',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashPage()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveScaffold(
            currentRoute: state.uri.toString(),
            onNavigate: (route) => context.go(route),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
          // Compose every domain-owned RouteModule. Tenant scope is
          // resolved lazily at router-construction time via Riverpod.
          for (final module in buildConsoleModules(ref.read(tenantScopeProvider)))
            ...module.buildRoutes(),
        ],
      ),
    ],
  );
}

/// Provider for the app router, reactive to auth + tenant-scope
/// transitions.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(ref);

  // Re-evaluate redirects when auth state changes.
  ref.listen(consoleAuthStateProvider, (previous, next) {
    router.refresh();
  });

  // Re-evaluate when the tenant scope changes (e.g. user switches
  // organization). Today this triggers a redirect-only refresh; a
  // future revision will rebuild route modules so per-tenant routes
  // pick up the new scope.
  ref.listen(tenantScopeProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
