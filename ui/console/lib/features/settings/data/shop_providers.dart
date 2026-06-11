import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show
        CommerceServiceClient,
        CreateShopRequest,
        GetShopRequest,
        Shop,
        ShopStatus,
        UpdateShopRequest;
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise UpdateShop update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/tenant_context_provider.dart';
import '../../../core/services/commerce_client_provider.dart';

/// Loads the shop bound to the active tenant scope via `GetShop`.
///
/// Returns `null` when no shop exists yet for the scope (the backend
/// answers `notFound`), which the UI uses to offer a create flow rather
/// than surfacing an error.
final currentShopProvider = FutureProvider<Shop?>((ref) async {
  final scope = ref.watch(tenantScopeProvider);
  if (scope.shopId.isEmpty) return null;

  final client = ref.watch(commerceServiceClientProvider);
  try {
    final response = await client.getShop(
      GetShopRequest(id: scope.shopId),
    );
    return response.hasShop() ? response.shop : null;
  } on ConnectException catch (e) {
    // No shop provisioned for this scope yet — surface the create flow
    // instead of an error.
    if (e.code == Code.notFound) return null;
    rethrow;
  }
});

/// Drives shop create/update mutations and exposes their async state so
/// the settings UI can show progress and surface failures.
class ShopNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(commerceServiceClientProvider);

  /// Provisions a new shop. The authenticated user becomes its admin.
  Future<Shop> create({
    required String name,
    required String slug,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createShop(
        CreateShopRequest(
          name: name,
          slug: slug,
          description: description.isEmpty ? null : description,
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(currentShopProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates the editable fields of an existing shop. The update mask is
  /// scoped to the fields the settings form exposes so untouched fields
  /// are never clobbered.
  Future<Shop> update({
    required String id,
    required String name,
    required String description,
    required ShopStatus status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          name: name,
          description: description,
          status: status,
          updateMask: FieldMask(
            paths: const ['name', 'description', 'status'],
          ),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(currentShopProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final shopNotifierProvider =
    NotifierProvider<ShopNotifier, AsyncValue<void>>(ShopNotifier.new);

/// Human-readable label for a [ShopStatus] enum value.
String shopStatusLabel(ShopStatus status) {
  switch (status) {
    case ShopStatus.SHOP_STATUS_ACTIVE:
      return 'Active';
    case ShopStatus.SHOP_STATUS_DISABLED:
      return 'Disabled';
    default:
      return 'Unspecified';
  }
}

/// Maps an [shopStatusLabel] back onto its [ShopStatus] enum value.
ShopStatus shopStatusFromLabel(String label) {
  switch (label) {
    case 'Active':
      return ShopStatus.SHOP_STATUS_ACTIVE;
    case 'Disabled':
      return ShopStatus.SHOP_STATUS_DISABLED;
    default:
      return ShopStatus.SHOP_STATUS_UNSPECIFIED;
  }
}

/// Editable status labels offered in the shop edit dialog.
const List<String> shopStatusLabels = ['Active', 'Disabled'];
