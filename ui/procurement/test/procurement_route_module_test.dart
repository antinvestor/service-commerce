import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProcurementRouteModule', () {
    test('exposes moduleId', () {
      final module = ProcurementRouteModule(propertyId: 'p-1');
      expect(module.moduleId, 'procurement');
    });

    test('builds routes for suppliers and purchase orders', () {
      final module = ProcurementRouteModule(propertyId: 'p-1');
      final routes = module.buildRoutes();
      expect(routes.length, greaterThanOrEqualTo(2));
    });

    test('builds nav items', () {
      final module = ProcurementRouteModule(propertyId: 'p-1');
      final items = module.buildNavItems();
      expect(items.length, 2);
      expect(items.first.id, 'procurement_suppliers');
      expect(items.last.id, 'procurement_purchase_orders');
    });

    test('declares procurement permissions', () {
      final module = ProcurementRouteModule(propertyId: 'p-1');
      final perms = module.permissionManifest.permissions.map((p) => p.key);
      expect(perms, contains('supplier_view'));
      expect(perms, contains('purchase_order_view'));
      expect(perms, contains('goods_receipt_create'));
    });
  });
}
