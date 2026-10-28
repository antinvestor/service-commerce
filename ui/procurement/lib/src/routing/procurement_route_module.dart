import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/goods_receipt_detail_screen.dart';
import '../screens/goods_receipt_wizard_screen.dart';
import '../screens/po_create_wizard_screen.dart';
import '../screens/procurement_home_screen.dart';
import '../screens/purchase_order_detail_screen.dart';
import '../screens/purchase_order_list_screen.dart';
import '../screens/purchase_order_suggestions_screen.dart';
import '../screens/supplier_detail_screen.dart';
import '../screens/supplier_list_screen.dart';
import 'procurement_paths.dart';

/// Registers every procurement screen under a single `/procurement` root.
///
/// | Path                                   | Screen                     |
/// |----------------------------------------|----------------------------|
/// | /procurement                           | ProcurementHomeScreen      |
/// | /procurement/suppliers                 | SupplierListScreen         |
/// | /procurement/suppliers/:supplierId     | SupplierDetailScreen       |
/// | /procurement/orders                    | PurchaseOrderListScreen    |
/// | /procurement/orders/new                | POCreateWizardScreen       |
/// | /procurement/orders/:poId              | PurchaseOrderDetailScreen  |
/// | /procurement/orders/:poId/receive      | GoodsReceiptWizardScreen   |
/// | /procurement/suggestions               | PurchaseOrderSuggestionsScreen |
/// | /procurement/receipts/:receiptId       | GoodsReceiptDetailScreen   |
///
/// Screens link through [ProcurementPaths] so they stay in step with this
/// table.
class ProcurementRouteModule extends RouteModule {
  ProcurementRouteModule({required this.propertyId});

  final String propertyId;

  @override
  String get moduleId => 'procurement';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: ProcurementPaths.root,
      builder: (context, state) =>
          ProcurementHomeScreen(propertyId: propertyId),
      routes: [
        GoRoute(
          path: 'suppliers',
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
          path: 'orders',
          builder: (context, state) =>
              PurchaseOrderListScreen(propertyId: propertyId),
          routes: [
            // Must precede ':poId' so "new" is not taken as an ID.
            GoRoute(
              path: 'new',
              builder: (context, state) =>
                  POCreateWizardScreen(propertyId: propertyId),
            ),
            GoRoute(
              path: ':poId',
              builder: (context, state) => PurchaseOrderDetailScreen(
                poId: state.pathParameters['poId']!,
              ),
              routes: [
                GoRoute(
                  path: 'receive',
                  builder: (context, state) => GoodsReceiptWizardScreen(
                    poId: state.pathParameters['poId']!,
                    propertyId: propertyId,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'suggestions',
          builder: (context, state) =>
              PurchaseOrderSuggestionsScreen(propertyId: propertyId),
        ),
        GoRoute(
          path: 'receipts/:receiptId',
          builder: (context, state) => GoodsReceiptDetailScreen(
            receiptId: state.pathParameters['receiptId']!,
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
      route: ProcurementPaths.suppliers,
      requiredPermissions: {'supplier_view'},
    ),
    NavItem(
      id: 'procurement_purchase_orders',
      label: 'Purchase Orders',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      route: ProcurementPaths.orders,
      requiredPermissions: {'purchase_order_view'},
    ),
  ];

  /// Route prefixes and the permissions (any of) that open them; names are
  /// the service_procurement permissions in procurement.proto. `:param`
  /// segments match any value.
  @override
  Map<String, Set<String>> get routePermissions => const {
    ProcurementPaths.root: {'supplier_view', 'purchase_order_view'},
    ProcurementPaths.suppliers: {'supplier_view'},
    ProcurementPaths.orders: {'purchase_order_view'},
    ProcurementPaths.newOrder: {'purchase_order_create'},
    '${ProcurementPaths.orders}/:poId/receive': {'goods_receipt_create'},
    ProcurementPaths.receipts: {'goods_receipt_view'},
    ProcurementPaths.suggestions: {'purchase_order_create'},
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
        key: 'purchase_order_cancel',
        label: 'Cancel or Close Purchase Orders',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'goods_receipt_view',
        label: 'View Goods Receipts',
        scope: PermissionScope.service,
      ),
      PermissionEntry(
        key: 'goods_receipt_create',
        label: 'Receive Goods',
        scope: PermissionScope.action,
      ),
    ],
  );
}
