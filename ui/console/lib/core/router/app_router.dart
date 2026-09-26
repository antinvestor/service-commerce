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

/// Composes the 16 commerce + manufacturing route modules plus the
/// three cross-cutting modules for the active tenant scope.
///
/// `shopId` is the commerce-side tenant; `propertyId` is the
/// operational site (factory, kitchen, warehouse). Both come from
/// [tenantScopeProvider].
List<RouteModule> buildConsoleModules(TenantScope scope) => <RouteModule>[
      // Commerce
      CatalogRouteModule(shopId: scope.shopId),
      CustomerRouteModule(shopId: scope.shopId),
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

/// Query parameter that carries the location requested before auth
/// resolved, so a fresh load of a deep link lands back on it.
const String kReturnToParam = 'from';

const Set<String> _authPaths = {
  '/splash',
  '/login',
  '/logout',
  '/auth/callback',
};

/// Returns [location] when it is a safe in-app destination to return to
/// after sign-in, or `null` for the dashboard, auth routes, and anything
/// that is not a same-origin absolute path.
String? sanitizeReturnTo(String? location) {
  if (location == null || location.isEmpty) return null;
  if (!location.startsWith('/') || location.startsWith('//')) return null;
  final uri = Uri.tryParse(location);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (uri.path.contains(r'\')) return null;
  if (uri.path == '/' || _authPaths.contains(uri.path)) return null;
  return location;
}

String _withReturnTo(String path, String? returnTo) => returnTo == null
    ? path
    : Uri(path: path, queryParameters: {kReturnToParam: returnTo}).toString();

/// Auth-aware redirect decision, mirroring thesa's three-state pattern.
///
/// - **Loading**: auth is being determined → splash, remembering the
///   requested location in `?from=`.
/// - **Unauthenticated**: → /login, still remembering the location.
/// - **Authenticated**: away from /login, /auth/callback and /splash to
///   the remembered location, or `/` when there is none.
///
/// Returns `null` when no redirect is needed.
String? resolveAuthRedirect({
  required Uri uri,
  required bool isLoading,
  required bool isAuthenticated,
}) {
  final path = uri.path;
  final isLoginRoute = path == '/login';
  final isAuthCallback = path == '/auth/callback';
  final isSplash = path == '/splash';
  final returnTo = _authPaths.contains(path)
      ? sanitizeReturnTo(uri.queryParameters[kReturnToParam])
      : sanitizeReturnTo(uri.toString());

  // While auth is loading, send to splash unless already there or on the
  // callback route (which needs to complete the OAuth flow).
  if (isLoading) {
    if (isAuthCallback || isSplash) return null;
    return _withReturnTo('/splash', returnTo);
  }

  // Auth callback while unauthenticated — let it through so the OAuth
  // exchange can complete.
  if (isAuthCallback && !isAuthenticated) return null;

  // Unauthenticated user on any protected route → login.
  if (!isAuthenticated) {
    if (isLoginRoute) return null;
    return _withReturnTo('/login', returnTo);
  }

  // Authenticated user on login, callback, or splash → where they were
  // headed, else the dashboard.
  if (isLoginRoute || isAuthCallback || isSplash) return returnTo ?? '/';

  return null;
}

/// Creates the app router with auth-aware redirect logic; see
/// [resolveAuthRedirect].
GoRouter createAppRouter(Ref ref, {String initialLocation = '/'}) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'root'),
    initialLocation: initialLocation,
    redirect: (context, state) {
      // Handle logout — always process immediately.
      if (state.uri.path == '/logout') {
        ref.read(consoleAuthStateProvider.notifier).logout();
        return '/login';
      }

      final authState = ref.read(consoleAuthStateProvider);
      return resolveAuthRedirect(
        uri: state.uri,
        isLoading: authState.isLoading,
        isAuthenticated: authState.whenOrNull(
              data: (s) => s == AuthState.authenticated,
            ) ??
            false,
      );
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
          // captured here; appRouterProvider rebuilds the router when it
          // changes.
          for (final module in buildConsoleModules(ref.read(tenantScopeProvider)))
            ...module.buildRoutes(),
        ],
      ),
    ],
  );
}

/// Remembers the router location across router rebuilds.
class _RouterLocationMemo {
  String? location;
}

final _routerLocationMemoProvider =
    Provider<_RouterLocationMemo>((ref) => _RouterLocationMemo());

/// Provider for the app router, reactive to auth + tenant-scope
/// transitions.
///
/// Route modules capture `shopId` / `propertyId` when their routes are
/// built, so the router is rebuilt whenever either changes (shops finish
/// loading, the operator switches shop). The current location is carried
/// over so the operator stays on the page they were on.
final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(tenantScopeProvider.select((s) => (s.shopId, s.propertyId)));
  final memo = ref.watch(_routerLocationMemoProvider);
  final router = createAppRouter(ref, initialLocation: memo.location ?? '/');

  // Re-evaluate redirects when auth state changes.
  ref.listen(consoleAuthStateProvider, (previous, next) {
    router.refresh();
  });

  ref.onDispose(() {
    final uri = router.routerDelegate.currentConfiguration.uri;
    if (uri.path.isNotEmpty) memo.location = uri.toString();
    // The widget tree still holds the old router until the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => router.dispose());
  });

  return router;
});
