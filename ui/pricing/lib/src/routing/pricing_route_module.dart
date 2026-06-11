import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/discount_rules_screen.dart';
import '../screens/price_checker_screen.dart';
import '../screens/price_list_assignments_screen.dart';
import '../screens/price_list_detail_screen.dart';
import '../screens/price_list_screen.dart';
import '../screens/price_overrides_screen.dart';

class PricingRouteModule extends RouteModule {
  PricingRouteModule({required this.shopId});

  final String shopId;

  @override
  String get moduleId => 'pricing';

  @override
  List<RouteBase> buildRoutes() => [
        GoRoute(
          path: '/pricing',
          builder: (context, state) =>
              PriceListScreen(shopId: shopId),
          routes: [
            GoRoute(
              path: 'overrides',
              builder: (context, state) =>
                  PriceOverridesScreen(shopId: shopId),
            ),
            GoRoute(
              path: 'discounts',
              builder: (context, state) =>
                  DiscountRulesScreen(shopId: shopId),
            ),
            GoRoute(
              path: 'checker',
              builder: (context, state) =>
                  PriceCheckerScreen(shopId: shopId),
            ),
            GoRoute(
              path: ':priceListId',
              builder: (context, state) => PriceListDetailScreen(
                priceListId: state.pathParameters['priceListId']!,
                shopId: shopId,
              ),
              routes: [
                GoRoute(
                  path: 'assignments',
                  builder: (context, state) => PriceListAssignmentsScreen(
                    priceListId: state.pathParameters['priceListId']!,
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
          id: 'pricing',
          label: 'Pricing',
          icon: Icons.price_change_outlined,
          activeIcon: Icons.price_change,
          route: '/pricing',
          requiredPermissions: {'price_list_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => {
        '/pricing': {'price_list_view'},
        '/pricing/overrides': {'customer_price_override'},
        '/pricing/discounts': {'discount_manage'},
        '/pricing/checker': {'price_list_view'},
        '/pricing/assignments': {'price_list_manage'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_commerce',
        permissions: [
          PermissionEntry(
            key: 'price_list_view',
            label: 'View Price Lists',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'price_list_manage',
            label: 'Manage Price Lists',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'customer_price_override',
            label: 'Customer Price Overrides',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'discount_manage',
            label: 'Manage Discounts',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'discount_approve',
            label: 'Approve Discounts',
            scope: PermissionScope.action,
          ),
        ],
      );
}
