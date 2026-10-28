import 'dart:io';

import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

/// The permissions service_commerce declares in its proto.
Set<String> _declared() {
  final proto = File(
    '../../proto/commerce/v1/commerce.proto',
  ).readAsStringSync();
  final list = RegExp(
    r'namespace:\s*"service_commerce"\s*permissions:\s*\[([^\]]*)\]',
  ).firstMatch(proto)!.group(1)!;
  return RegExp(r'"(\w+)"').allMatches(list).map((m) => m.group(1)!).toSet();
}

void main() {
  test('every permission the module names is declared in the proto', () {
    final module = PricingRouteModule(shopId: 's');
    final named = <String>{
      for (final perms in module.routePermissions.values) ...perms,
      for (final item in module.buildNavItems()) ...item.requiredPermissions,
      for (final entry in module.permissionManifest.permissions) entry.key,
    };
    expect(named, isNotEmpty);
    expect(named.difference(_declared()), isEmpty);
    expect(module.permissionManifest.namespace, 'service_commerce');
  });
}
