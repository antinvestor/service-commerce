import 'dart:io';

import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
import 'package:flutter_test/flutter_test.dart';

/// The permissions service_procurement declares in its proto.
Set<String> _declared() {
  final proto = File(
    '../../proto/procurement/v1/procurement.proto',
  ).readAsStringSync();
  final list = RegExp(
    r'namespace:\s*"service_procurement"\s*permissions:\s*\[([^\]]*)\]',
  ).firstMatch(proto)!.group(1)!;
  return RegExp(r'"(\w+)"').allMatches(list).map((m) => m.group(1)!).toSet();
}

void main() {
  test('every permission the module names is declared in the proto', () {
    final module = ProcurementRouteModule(propertyId: 'p');
    final named = <String>{
      for (final perms in module.routePermissions.values) ...perms,
      for (final item in module.buildNavItems()) ...item.requiredPermissions,
      for (final entry in module.permissionManifest.permissions) entry.key,
    };
    expect(named, isNotEmpty);
    expect(named.difference(_declared()), isEmpty);
    expect(module.permissionManifest.namespace, 'service_procurement');
  });
}
