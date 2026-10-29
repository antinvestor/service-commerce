import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/customer_list_screen.dart';
import '../screens/customer_detail_screen.dart';

class CustomerRouteModule extends RouteModule {
  CustomerRouteModule({required this.shopId});

  final String shopId;

  @override
  String get moduleId => 'customers';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
      routes: [
        GoRoute(
          path: ':customerId',
          builder: (context, state) => CustomerDetailScreen(
            customerId: state.pathParameters['customerId']!,
            shopId: shopId,
          ),
          routes: [
            // Payments are recorded on an order; old links land on the
            // customer, whose orders open the payment flow.
            GoRoute(
              path: 'payment',
              redirect: (context, state) =>
                  '/customers/${state.pathParameters['customerId']}',
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'customers',
      label: 'Customers',
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      route: '/customers',
      requiredPermissions: {'order_view'},
    ),
  ];

  /// Customers are the people who order from the shop: seeing them and
  /// their history needs `order_view` (commerce.proto service_commerce).
  @override
  Map<String, Set<String>> get routePermissions => {
    '/customers': {'order_view'},
  };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(
        key: 'order_view',
        label: 'View Customers and Orders',
        scope: PermissionScope.service,
      ),
    ],
  );
}
