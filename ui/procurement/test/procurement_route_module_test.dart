import 'dart:io';

import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Resolves [location] against the module's routes and returns the matched
/// route pattern, or null when nothing matches.
String? matchedPattern(GoRouter router, String location) {
  final match = router.configuration.findMatch(Uri.parse(location));
  if (match.isError || match.matches.isEmpty) return null;
  return match.fullPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProcurementRouteModule module;
  late GoRouter router;

  setUp(() {
    module = ProcurementRouteModule(propertyId: 'p-1');
    router = GoRouter(routes: module.buildRoutes());
  });

  tearDown(() => router.dispose());

  group('ProcurementRouteModule', () {
    test('exposes moduleId', () {
      expect(module.moduleId, 'procurement');
    });

    test('registers a single /procurement root', () {
      final routes = module.buildRoutes();
      expect(routes, hasLength(1));
      expect((routes.single as GoRoute).path, ProcurementPaths.root);
    });

    test('resolves every screen to the expected route pattern', () {
      const expected = {
        '/procurement': '/procurement',
        '/procurement/suppliers': '/procurement/suppliers',
        '/procurement/suppliers/sup-1': '/procurement/suppliers/:supplierId',
        '/procurement/orders': '/procurement/orders',
        '/procurement/orders/new': '/procurement/orders/new',
        '/procurement/orders/po-1': '/procurement/orders/:poId',
        '/procurement/orders/po-1/receive': '/procurement/orders/:poId/receive',
        '/procurement/receipts/gr-1': '/procurement/receipts/:receiptId',
      };
      for (final entry in expected.entries) {
        expect(
          matchedPattern(router, entry.key),
          entry.value,
          reason: '${entry.key} should resolve to ${entry.value}',
        );
      }
    });

    test('does not register the retired top-level paths', () {
      for (final location in [
        '/suppliers',
        '/purchase-orders',
        '/purchase-orders/new',
        '/purchase-orders/po-1/receive',
      ]) {
        expect(matchedPattern(router, location), isNull, reason: location);
      }
    });

    test('every ProcurementPaths link resolves to a registered route', () {
      final links = {
        ProcurementPaths.root: '/procurement',
        ProcurementPaths.suppliers: '/procurement/suppliers',
        ProcurementPaths.supplier('sup-1'):
            '/procurement/suppliers/:supplierId',
        ProcurementPaths.orders: '/procurement/orders',
        ProcurementPaths.newOrder: '/procurement/orders/new',
        ProcurementPaths.order('po-1'): '/procurement/orders/:poId',
        ProcurementPaths.receiveOrder('po-1'):
            '/procurement/orders/:poId/receive',
        ProcurementPaths.receipt('gr-1'): '/procurement/receipts/:receiptId',
      };
      for (final entry in links.entries) {
        expect(
          matchedPattern(router, entry.key),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('path helpers encode IDs into a single segment', () {
      expect(ProcurementPaths.order('a/b'), '/procurement/orders/a%2Fb');
      expect(
        matchedPattern(router, ProcurementPaths.receiveOrder('a/b')),
        '/procurement/orders/:poId/receive',
      );
    });

    test('nav items point at registered routes', () {
      final items = module.buildNavItems();
      expect(items.map((i) => i.id), [
        'procurement_suppliers',
        'procurement_purchase_orders',
      ]);
      for (final item in items) {
        expect(
          matchedPattern(router, item.route!),
          isNotNull,
          reason: '${item.id} -> ${item.route}',
        );
      }
    });

    test('route permission prefixes are registered routes under the root', () {
      for (final prefix in module.routePermissions.keys) {
        expect(prefix, startsWith(ProcurementPaths.root));
        if (prefix == ProcurementPaths.receipts) continue; // prefix only
        expect(matchedPattern(router, prefix), isNotNull, reason: prefix);
      }
    });

    test('declares procurement permissions', () {
      final perms = module.permissionManifest.permissions.map((p) => p.key);
      expect(perms, contains('supplier_view'));
      expect(perms, contains('purchase_order_view'));
      expect(perms, contains('goods_receipt_create'));
    });
  });

  group('source links', () {
    // Screens must navigate through ProcurementPaths; a hand-written string
    // path is how the old /procurement/... links drifted from the router.
    final literalNav = RegExp(
      r'''\.(go|push|replace|pushReplacement)\(\s*['"]''',
    );

    test('no screen or widget navigates with a string literal', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (literalNav.hasMatch(lines[i])) {
            offenders.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
