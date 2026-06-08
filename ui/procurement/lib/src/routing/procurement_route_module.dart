import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/goods_receipt_wizard_screen.dart';
import '../screens/po_create_wizard_screen.dart';
import '../screens/purchase_order_list_screen.dart';
import '../screens/supplier_detail_screen.dart';
import '../screens/supplier_list_screen.dart';

class ProcurementRouteModule extends RouteModule {
  ProcurementRouteModule({required this.propertyId});

  final String propertyId;

  @override
  String get moduleId => 'procurement';

  @override
  List<RouteBase> buildRoutes() => [
        GoRoute(
          path: '/suppliers',
          builder: (context, state) => const SupplierListScreen(),
          routes: [
            GoRoute(
              path: ':supplierId',
              builder: (context, state) => SupplierDetailScreen(
                supplierId: state.pathParameters['supplierId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/purchase-orders',
          builder: (context, state) =>
              PurchaseOrderListScreen(propertyId: propertyId),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) =>
                  POCreateWizardScreen(propertyId: propertyId),
            ),
            GoRoute(
              path: ':poId/receive',
              builder: (context, state) => GoodsReceiptWizardScreen(
                poId: state.pathParameters['poId']!,
              ),
            ),
          ],
        ),
      ];

  @override
  List<NavItem> buildNavItems() => const [
        NavItem(
          id: 'procurement_suppliers',
          label: 'Suppliers',
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          route: '/suppliers',
          requiredPermissions: {'supplier_view'},
        ),
        NavItem(
          id: 'procurement_purchase_orders',
          label: 'Purchase Orders',
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          route: '/purchase-orders',
          requiredPermissions: {'purchase_order_view'},
        ),
      ];

  @override
  Map<String, Set<String>> get routePermissions => const {
        '/suppliers': {'supplier_view'},
        '/purchase-orders': {'purchase_order_view'},
        '/purchase-orders/new': {'purchase_order_create'},
      };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
        namespace: 'service_procurement',
        permissions: [
          PermissionEntry(
            key: 'supplier_view',
            label: 'View Suppliers',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'supplier_manage',
            label: 'Manage Suppliers',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'purchase_order_view',
            label: 'View Purchase Orders',
            scope: PermissionScope.service,
          ),
          PermissionEntry(
            key: 'purchase_order_create',
            label: 'Create Purchase Orders',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'purchase_order_submit',
            label: 'Submit Purchase Orders',
            scope: PermissionScope.action,
          ),
          PermissionEntry(
            key: 'goods_receipt_create',
            label: 'Create Goods Receipts',
            scope: PermissionScope.action,
          ),
        ],
      );
}
