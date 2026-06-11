import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_coldchain/antinvestor_ui_coldchain.dart';
import 'package:antinvestor_ui_costing/antinvestor_ui_costing.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_demand/antinvestor_ui_demand.dart';
import 'package:antinvestor_ui_equipment/antinvestor_ui_equipment.dart';
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart';
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart';
import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart';
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart';
import 'package:antinvestor_ui_quality/antinvestor_ui_quality.dart';
import 'package:antinvestor_ui_recipes/antinvestor_ui_recipes.dart';
import 'package:antinvestor_ui_shelflife/antinvestor_ui_shelflife.dart';
import 'package:antinvestor_ui_traceability/antinvestor_ui_traceability.dart';
import 'package:antinvestor_ui_waste/antinvestor_ui_waste.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies every domain RouteModule the console composes exposes at
/// least one route and one nav item. This is a fast structural check —
/// it doesn't mount widgets (which would need a live transport), it
/// only confirms the modules are constructible and self-describing.
void main() {
  group('RouteModule contracts', () {
    test('CatalogRouteModule exposes routes', () {
      final module = CatalogRouteModule(shopId: 'shop-1');
      expect(module.moduleId, 'catalog');
      expect(module.buildRoutes(), isNotEmpty);
      expect(module.buildNavItems(), isNotEmpty);
      expect(module.permissionManifest.permissions, isNotEmpty);
    });

    test('CustomerRouteModule exposes routes', () {
      final module = CustomerRouteModule(shopId: 'shop-1');
      expect(module.buildRoutes(), isNotEmpty);
      expect(module.buildNavItems(), isNotEmpty);
    });

    test('OrderRouteModule exposes routes', () {
      final module = OrderRouteModule(shopId: 'shop-1');
      expect(module.moduleId, 'orders');
      expect(module.buildRoutes(), isNotEmpty);
    });

    test('PricingRouteModule exposes routes', () {
      final module = PricingRouteModule(shopId: 'shop-1');
      expect(module.buildRoutes(), isNotEmpty);
    });

    test('ProcurementRouteModule exposes routes', () {
      final module = ProcurementRouteModule(propertyId: 'property-1');
      expect(module.moduleId, 'procurement');
      expect(module.buildRoutes(), isNotEmpty);
      expect(module.buildNavItems().length, greaterThanOrEqualTo(2));
    });

    test('Manufacturing modules expose routes', () {
      final modules = [
        ColdChainRouteModule(propertyId: 'p-1'),
        CostingRouteModule(propertyId: 'p-1'),
        DemandRouteModule(propertyId: 'p-1'),
        EquipmentRouteModule(propertyId: 'p-1'),
        InventoryRouteModule(propertyId: 'p-1'),
        ProductionRouteModule(propertyId: 'p-1'),
        QualityRouteModule(propertyId: 'p-1'),
        RecipesRouteModule(propertyId: 'p-1'),
        ShelfLifeRouteModule(propertyId: 'p-1'),
        TraceabilityRouteModule(propertyId: 'p-1'),
        WasteRouteModule(propertyId: 'p-1'),
      ];

      for (final module in modules) {
        expect(
          module.buildRoutes(),
          isNotEmpty,
          reason: '${module.moduleId} should expose at least one route',
        );
        expect(
          module.buildNavItems(),
          isNotEmpty,
          reason: '${module.moduleId} should expose at least one nav item',
        );
      }
    });

    test('Module IDs are unique', () {
      final modules = [
        CatalogRouteModule(shopId: 'shop-1'),
        OrderRouteModule(shopId: 'shop-1'),
        PricingRouteModule(shopId: 'shop-1'),
        ProcurementRouteModule(propertyId: 'p-1'),
        ColdChainRouteModule(propertyId: 'p-1'),
        CostingRouteModule(propertyId: 'p-1'),
        DemandRouteModule(propertyId: 'p-1'),
        EquipmentRouteModule(propertyId: 'p-1'),
        InventoryRouteModule(propertyId: 'p-1'),
        ProductionRouteModule(propertyId: 'p-1'),
        QualityRouteModule(propertyId: 'p-1'),
        RecipesRouteModule(propertyId: 'p-1'),
        ShelfLifeRouteModule(propertyId: 'p-1'),
        TraceabilityRouteModule(propertyId: 'p-1'),
        WasteRouteModule(propertyId: 'p-1'),
      ];
      final ids = modules.map((m) => m.moduleId).toList();
      final uniqueIds = ids.toSet();
      expect(
        ids.length,
        uniqueIds.length,
        reason: 'duplicate module IDs found: $ids',
      );
    });
  });
}
