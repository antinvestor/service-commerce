import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show ListShopsRequest, PageCursor, SearchRequest, Shop, ShopStatus;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_state_provider.dart';
import '../services/commerce_client_provider.dart';

/// Page size used when listing the caller's shops.
const int _shopPageSize = 50;

/// Upper bound on pages fetched so a misbehaving cursor cannot loop forever.
const int _maxShopPages = 20;

/// Every shop visible to the signed-in user, via the commerce `ListShops`
/// RPC. The backend scopes the listing to the caller's partition, so this
/// is the set of shops the merchant can operate from the console.
///
/// Shop ids are generated server-side by `CreateShop`; they are never
/// derived from the organisation or partition id.
final shopListProvider = FutureProvider<List<Shop>>((ref) async {
  final auth = ref.watch(consoleAuthStateProvider).value;
  if (auth != AuthState.authenticated) return const <Shop>[];

  final client = ref.watch(commerceServiceClientProvider);
  final shops = <Shop>[];
  var page = '';
  for (var i = 0; i < _maxShopPages; i++) {
    final cursor = PageCursor(limit: _shopPageSize);
    if (page.isNotEmpty) cursor.page = page;
    final response = await client.listShops(
      ListShopsRequest(search: SearchRequest(cursor: cursor)),
    );
    shops.addAll(response.shops);
    page = response.nextPage;
    if (page.isEmpty || response.shops.isEmpty) break;
  }
  return shops;
});

/// The shop id the operator explicitly picked, or `null` to fall back to
/// the default choice made by [resolveActiveShop].
class SelectedShopNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Makes [shopId] the active shop.
  void select(String shopId) => state = shopId.isEmpty ? null : shopId;

  /// Forgets the explicit choice so the default shop is used again.
  void clear() => state = null;
}

final selectedShopIdProvider =
    NotifierProvider<SelectedShopNotifier, String?>(SelectedShopNotifier.new);

/// Picks the shop the console operates on.
///
/// An explicit [selectedId] wins when it is still in [shops]; otherwise the
/// first active shop is used, then the first shop of any status (so a
/// disabled shop can still be re-enabled from settings). Returns `null`
/// when there are no shops.
Shop? resolveActiveShop(List<Shop> shops, String? selectedId) {
  if (shops.isEmpty) return null;
  if (selectedId != null && selectedId.isNotEmpty) {
    for (final shop in shops) {
      if (shop.id == selectedId) return shop;
    }
  }
  for (final shop in shops) {
    if (shop.status == ShopStatus.SHOP_STATUS_ACTIVE) return shop;
  }
  return shops.first;
}

/// The shop the console is currently operating on, or `null` while shops
/// are loading, failed to load, or none exist yet.
final activeShopProvider = Provider<Shop?>((ref) {
  final shops = ref.watch(shopListProvider).value ?? const <Shop>[];
  final selectedId = ref.watch(selectedShopIdProvider);
  return resolveActiveShop(shops, selectedId);
});
