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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/identity/identity_route_module.dart';
import '../auth/tenant_context_provider.dart';

/// Composes the 16 commerce + manufacturing route modules plus the
/// cross-cutting modules for the active tenant scope.
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
  IdentityRouteModule(),
];

/// Routes the console shell defines itself (see `createAppRouter`).
const Set<String> consoleShellPaths = {'/', '/settings', '/logout'};

/// Every full path declared by [routes], with nested relative paths joined
/// onto their parents (e.g. `/pricing` + `overrides` → `/pricing/overrides`).
Set<String> collectRoutePaths(List<RouteBase> routes, [String parent = '']) {
  final paths = <String>{};
  for (final route in routes) {
    var base = parent;
    if (route is GoRoute) {
      base = _joinPath(parent, route.path);
      paths.add(base);
    }
    paths.addAll(collectRoutePaths(route.routes, base));
  }
  return paths;
}

String _joinPath(String parent, String path) {
  if (path.startsWith('/')) return _normalise(path);
  if (parent.isEmpty || parent == '/') return _normalise('/$path');
  return _normalise('$parent/$path');
}

String _normalise(String path) => path.length > 1 && path.endsWith('/')
    ? path.substring(0, path.length - 1)
    : path;

/// Full paths the composed console router can serve. Route shapes do not
/// depend on the tenant scope, so an empty scope is used.
final registeredRoutePathsProvider = Provider<Set<String>>((ref) {
  final routes = [
    for (final module in buildConsoleModules(TenantScope.empty()))
      ...module.buildRoutes(),
  ];
  return {...consoleShellPaths, ...collectRoutePaths(routes)};
});

/// Whether a sidebar [route] (a concrete path, no parameters) is served by
/// the composed router.
bool isRouteRegistered(Set<String> registered, String route) =>
    registered.contains(_normalise(Uri.parse(route).path));
