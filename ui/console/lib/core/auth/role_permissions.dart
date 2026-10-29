/// Console permissions from partition roles, and which permissions a route
/// needs. Pure Dart: no providers, no service packages.
library;

/// What each partition role may do in the console, by permission name.
///
/// The roles are the signed-in user's partition access roles, which the
/// access token carries in its `roles` claim (the same roles the services
/// resolve in Keto through the partition bridge). The permissions are the
/// `role_bindings` of the `service_permissions` option on CommerceService
/// (proto/commerce/v1/commerce.proto) and ProcurementService
/// (proto/procurement/v1/procurement.proto); `console_permissions_test`
/// fails if they drift from the protos.
///
/// A `member` is a buyer: the per-shop OPL (opl/commerce) gives members no
/// staff view of a shop's orders, fulfilments or price lists, so the
/// console does not either ([memberShopExclusions]).
const Map<String, Set<String>> commerceRoleBindings = {
  'owner': _commerceAdmin,
  'admin': _commerceAdmin,
  'service': _commerceAdmin,
  'operator': {
    'shop_view',
    'product_view',
    'product_manage',
    'cart_view',
    'order_view',
    'order_manage',
    'fulfilment_view',
    'fulfilment_manage',
    'price_list_view',
    'discount_manage',
    'shops_list',
  },
  'viewer': {
    'shop_view',
    'product_view',
    'cart_view',
    'order_view',
    'fulfilment_view',
    'price_list_view',
    'shops_list',
  },
  'member': {
    'shop_view',
    'product_view',
    'cart_view',
    'cart_manage',
    'order_view',
    'order_manage',
    'price_list_view',
    'shops_list',
  },
};

const Set<String> _commerceAdmin = {
  'shop_view',
  'shop_create',
  'shop_update',
  'product_view',
  'product_manage',
  'cart_view',
  'cart_manage',
  'order_view',
  'order_manage',
  'fulfilment_view',
  'fulfilment_manage',
  'price_list_view',
  'price_list_manage',
  'customer_price_override',
  'discount_manage',
  'discount_approve',
  'shops_list',
  'ledger_post',
};

/// Commerce permissions a member holds at the partition but not on a shop
/// (opl/commerce/commerce_resources.opl.ts): buyers read only their own
/// orders, never the shop's.
const Set<String> memberShopExclusions = {
  'order_view',
  'order_manage',
  'fulfilment_view',
  'price_list_view',
};

/// ProcurementService role bindings; members get nothing.
const Map<String, Set<String>> procurementRoleBindings = {
  'owner': _procurementAdmin,
  'admin': _procurementAdmin,
  'service': _procurementAdmin,
  'operator': {
    'supplier_view',
    'purchase_order_view',
    'purchase_order_create',
    'purchase_order_submit',
    'goods_receipt_view',
    'goods_receipt_create',
  },
  'viewer': {'supplier_view', 'purchase_order_view', 'goods_receipt_view'},
};

const Set<String> _procurementAdmin = {
  'supplier_view',
  'supplier_manage',
  'purchase_order_view',
  'purchase_order_create',
  'purchase_order_submit',
  'purchase_order_cancel',
  'goods_receipt_view',
  'goods_receipt_create',
  'goods_receipt_deliver',
  'goods_receipt_resolve',
};

/// The console permissions [roles] grant: the union of each role's
/// commerce and procurement bindings. Unknown roles grant nothing.
Set<String> permissionsForRoles(Iterable<String> roles) {
  final granted = <String>{};
  for (final raw in roles) {
    final role = raw.trim().toLowerCase();
    final commerce = commerceRoleBindings[role];
    if (commerce != null) {
      granted.addAll(
        role == 'member' ? commerce.difference(memberShopExclusions) : commerce,
      );
    }
    granted.addAll(procurementRoleBindings[role] ?? const {});
  }
  return granted;
}

/// The permissions (any of) [location] needs, empty when it needs none.
///
/// The most specific declared route wins; a `:param` segment matches any
/// single segment, so `/orders/:orderId/fulfilment` covers every order.
Set<String> permissionsForRoute(
  String location,
  Map<String, Set<String>> table,
) {
  final path = Uri.parse(location).path;
  final segments = _segments(path);
  String? best;
  var bestLength = -1;
  var bestLiterals = -1;
  for (final pattern in table.keys) {
    final parts = _segments(pattern);
    if (parts.length > segments.length) continue;
    var matches = true;
    var literals = 0;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].startsWith(':')) continue;
      if (parts[i] != segments[i]) {
        matches = false;
        break;
      }
      literals++;
    }
    if (!matches) continue;
    if (parts.length > bestLength ||
        (parts.length == bestLength && literals > bestLiterals)) {
      best = pattern;
      bestLength = parts.length;
      bestLiterals = literals;
    }
  }
  return best == null ? const {} : table[best]!;
}

List<String> _segments(String path) =>
    path.split('/').where((s) => s.isNotEmpty).toList();

/// Whether [granted] opens [location] under [table].
bool canOpenRouteIn(
  Map<String, Set<String>> table,
  String location,
  Set<String> granted,
) {
  final needed = permissionsForRoute(location, table);
  return needed.isEmpty || needed.intersection(granted).isNotEmpty;
}
