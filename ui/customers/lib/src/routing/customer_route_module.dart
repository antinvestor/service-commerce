import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/customer_list_screen.dart';
import '../screens/customer_detail_screen.dart';
import '../screens/receive_payment_screen.dart';

class CustomerRouteModule extends RouteModule {
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
              ),
              routes: [
                GoRoute(
                  path: 'payment',
                  builder: (context, state) => ReceivePaymentScreen(
                    customerId: state.pathParameters['customerId']!,
                  ),
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
          requiredPermissions: {'customer_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => {
        '/customers': {'customer_view'},
        '/customers/:customerId/payment': {'payment_receive'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_commerce',
        permissions: [
          PermissionEntry(
            key: 'customer_view',
            label: 'View Customers',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'payment_receive',
            label: 'Receive Payments',
            scope: PermissionScope.action,
          ),
        ],
      );
}
