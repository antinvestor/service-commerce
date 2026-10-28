import 'dart:io';

import 'package:console/core/auth/role_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

/// The `role_bindings` of the service_permissions option in [protoPath], by
/// lower-case role name (`ROLE_OPERATOR` → `operator`).
Map<String, Set<String>> _protoRoleBindings(String protoPath) {
  final text = File(protoPath).readAsStringSync();
  final bindings = <String, Set<String>>{};
  final binding = RegExp(
    r'role:\s*ROLE_(\w+)\s*permissions:\s*\[([^\]]*)\]',
    multiLine: true,
  );
  for (final m in binding.allMatches(text)) {
    bindings[m.group(1)!.toLowerCase()] = RegExp(
      r'"(\w+)"',
    ).allMatches(m.group(2)!).map((p) => p.group(1)!).toSet();
  }
  return bindings;
}

void main() {
  group('role bindings match the protos', () {
    test('commerce', () {
      expect(
        commerceRoleBindings,
        _protoRoleBindings('../../proto/commerce/v1/commerce.proto'),
      );
    });

    test('procurement', () {
      expect(
        procurementRoleBindings,
        _protoRoleBindings('../../proto/procurement/v1/procurement.proto'),
      );
    });
  });

  group('permissionsForRoles', () {
    test('owners hold everything staff can do', () {
      final granted = permissionsForRoles(['owner']);
      expect(granted, containsAll(['order_manage', 'purchase_order_cancel']));
    });

    test('viewers read but change nothing', () {
      final granted = permissionsForRoles(['viewer']);
      expect(granted, containsAll(['order_view', 'purchase_order_view']));
      expect(granted, isNot(contains('order_manage')));
      expect(granted, isNot(contains('supplier_manage')));
    });

    test('operators receive goods but do not cancel or close orders', () {
      final granted = permissionsForRoles(['operator']);
      expect(granted, contains('goods_receipt_create'));
      expect(granted, isNot(contains('purchase_order_cancel')));
    });

    test('members are buyers and see no staff screens', () {
      final granted = permissionsForRoles(['member']);
      expect(granted, contains('product_view'));
      expect(granted, isNot(contains('order_view')));
      expect(granted, isNot(contains('price_list_view')));
      expect(granted, isNot(contains('supplier_view')));
    });

    test('roles combine; unknown roles grant nothing', () {
      expect(permissionsForRoles(['user']), isEmpty);
      expect(
        permissionsForRoles(['Viewer', 'member']),
        containsAll(['order_view', 'cart_manage']),
      );
    });
  });

  group('permissionsForRoute', () {
    const table = {
      '/orders': {'order_view'},
      '/orders/checkout': {'order_manage'},
      '/orders/events': {'order_view'},
      '/orders/:orderId/fulfilment': {'fulfilment_view'},
      '/procurement': {'supplier_view', 'purchase_order_view'},
      '/procurement/orders/:poId/receive': {'goods_receipt_create'},
    };

    test('the most specific route wins and params match any id', () {
      expect(permissionsForRoute('/orders', table), {'order_view'});
      expect(permissionsForRoute('/orders/ord-1', table), {'order_view'});
      expect(permissionsForRoute('/orders/checkout', table), {'order_manage'});
      expect(permissionsForRoute('/orders/ord-1/fulfilment', table), {
        'fulfilment_view',
      });
      expect(permissionsForRoute('/procurement/orders/po-1/receive', table), {
        'goods_receipt_create',
      });
      expect(permissionsForRoute('/procurement/orders/po-1', table), {
        'supplier_view',
        'purchase_order_view',
      });
    });

    test('routes nobody declared need nothing', () {
      expect(permissionsForRoute('/', table), isEmpty);
      expect(permissionsForRoute('/settings', table), isEmpty);
      expect(permissionsForRoute('/ordersx', table), isEmpty);
    });

    test('canOpenRouteIn needs any one of the permissions', () {
      final viewer = permissionsForRoles(['viewer']);
      expect(canOpenRouteIn(table, '/orders/ord-1', viewer), isTrue);
      expect(canOpenRouteIn(table, '/orders/checkout', viewer), isFalse);
      expect(
        canOpenRouteIn(table, '/procurement/orders/po-1/receive', viewer),
        isFalse,
      );
      expect(canOpenRouteIn(table, '/settings', const {}), isTrue);
    });
  });
}
