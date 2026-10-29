import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/catalog_browse_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_create_screen.dart';
import '../screens/variant_create_screen.dart';

class CatalogRouteModule extends RouteModule {
  CatalogRouteModule({required this.shopId});

  final String shopId;

  @override
  String get moduleId => 'catalog';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/catalog',
      builder: (context, state) => CatalogBrowseScreen(shopId: shopId),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => ProductCreateScreen(shopId: shopId),
        ),
        GoRoute(
          path: ':productId',
          builder: (context, state) => ProductDetailScreen(
            productId: state.pathParameters['productId']!,
          ),
          routes: [
            GoRoute(
              path: 'variants/new',
              builder: (context, state) => VariantCreateScreen(
                productId: state.pathParameters['productId']!,
                shopId: shopId,
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
      id: 'catalog',
      label: 'Catalog',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      route: '/catalog',
      requiredPermissions: {'product_view'},
    ),
  ];

  /// Route prefixes and the permissions (any of) that open them; names are
  /// the service_commerce permissions in commerce.proto. `:param` segments
  /// match any value.
  @override
  Map<String, Set<String>> get routePermissions => {
    '/catalog': {'product_view'},
    '/catalog/new': {'product_manage'},
    '/catalog/:productId/variants/new': {'product_manage'},
  };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_commerce',
    permissions: [
      PermissionEntry(
        key: 'product_view',
        label: 'View Catalog',
        scope: PermissionScope.service,
      ),
      PermissionEntry(
        key: 'product_manage',
        label: 'Manage Products and Variants',
        scope: PermissionScope.action,
      ),
    ],
  );
}
