import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/checkout_flow_screen.dart';
import '../screens/fulfilment_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/order_list_screen.dart';

class OrderRouteModule extends RouteModule {
  OrderRouteModule({required this.shopId});

  final String shopId;

  @override
  String get moduleId => 'orders';

  @override
  List<RouteBase> buildRoutes() => [
        GoRoute(
          path: '/orders',
          builder: (context, state) =>
              OrderListScreen(shopId: shopId),
          routes: [
            GoRoute(
              path: 'checkout',
              builder: (context, state) =>
                  CheckoutFlowScreen(shopId: shopId),
            ),
            GoRoute(
              path: ':orderId',
              builder: (context, state) => OrderDetailScreen(
                orderId: state.pathParameters['orderId']!,
              ),
              routes: [
                GoRoute(
                  path: 'fulfilment',
                  builder: (context, state) => FulfilmentScreen(
                    orderId: state.pathParameters['orderId']!,
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
          id: 'orders',
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          route: '/orders',
          requiredPermissions: {'order_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => {
        '/orders': {'order_view'},
        '/orders/checkout': {'order_manage'},
        '/orders/:orderId/fulfilment': {'fulfilment_manage'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_commerce',
        permissions: [
          PermissionEntry(
            key: 'order_view',
            label: 'View Orders',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'order_manage',
            label: 'Manage Orders',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'cart_view',
            label: 'View Carts',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'cart_manage',
            label: 'Manage Carts',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'fulfilment_view',
            label: 'View Fulfilments',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'fulfilment_manage',
            label: 'Manage Fulfilments',
            scope: PermissionScope.action,
          ),
        ],
      );
}
