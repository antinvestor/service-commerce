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
          builder: (context, state) =>
              CatalogBrowseScreen(shopId: shopId),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) =>
                  ProductCreateScreen(shopId: shopId),
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
          requiredPermissions: {'catalog_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => {
        '/catalog': {'catalog_view'},
        '/catalog/new': {'product_create'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_commerce',
        permissions: [
          PermissionEntry(
            key: 'catalog_view',
            label: 'View Catalog',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'product_create',
            label: 'Create Products',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'product_update',
            label: 'Update Products',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'variant_create',
            label: 'Create Variants',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'variant_update',
            label: 'Update Variants',
            scope: PermissionScope.action,
          ),
        ],
      );
}
