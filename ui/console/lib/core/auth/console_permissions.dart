import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart'
    as runtime;
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart'
    show CatalogRouteModule;
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart'
    show CustomerRouteModule;
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart'
    show OrderRouteModule;
import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart'
    show PricingRouteModule;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show ProcurementRouteModule;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_state_provider.dart';
import 'role_permissions.dart';

export 'role_permissions.dart';

/// The signed-in user's console permissions, from the roles in their access
/// token. Signed out, or when the roles cannot be read, nothing is granted
/// and every gated route and action stays closed; the services check every
/// call regardless.
final consolePermissionsProvider = FutureProvider<Set<String>>((ref) async {
  final auth = ref.watch(consoleAuthStateProvider).value;
  if (auth != AuthState.authenticated) return const <String>{};
  try {
    final roles = await ref.watch(runtime.authRuntimeProvider).getRoles();
    return permissionsForRoles(roles);
  } catch (e) {
    debugPrint('[Auth] Could not read roles: $e');
    return const <String>{};
  }
});

/// Route prefixes of the commerce and procurement screens and the
/// permissions (any of) that open them, as each module declares them.
final Map<String, Set<String>> consoleRoutePermissions = {
  for (final module in [
    CatalogRouteModule(shopId: ''),
    CustomerRouteModule(shopId: ''),
    OrderRouteModule(shopId: ''),
    PricingRouteModule(shopId: ''),
    ProcurementRouteModule(propertyId: ''),
  ])
    ...module.routePermissions,
};

/// Whether [granted] opens [location] in the console.
bool canOpenRoute(String location, Set<String> granted) =>
    canOpenRouteIn(consoleRoutePermissions, location, granted);

/// The permissions (any of) [location] needs in the console.
Set<String> consoleRoutePermissionsFor(String location) =>
    permissionsForRoute(location, consoleRoutePermissions);
