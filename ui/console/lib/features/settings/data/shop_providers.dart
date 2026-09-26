import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show
        CommerceServiceClient,
        CreateShopRequest,
        Shop,
        ShopStatus,
        UpdateShopRequest;
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise UpdateShop update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/active_shop_provider.dart';
import '../../../core/services/commerce_client_provider.dart';

/// The shop the console is operating on, resolved from `ListShops`.
///
/// Returns `null` when the caller has no shops yet, which the UI uses to
/// offer a create flow rather than surfacing an error. Load failures are
/// surfaced as errors.
final currentShopProvider = FutureProvider<Shop?>((ref) async {
  final shops = await ref.watch(shopListProvider.future);
  return resolveActiveShop(shops, ref.watch(selectedShopIdProvider));
});

/// Drives shop create/update mutations and exposes their async state so
/// the settings UI can show progress and surface failures.
class ShopNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(commerceServiceClientProvider);

  /// Provisions a new shop. The authenticated user becomes its admin and
  /// the new shop becomes the console's active shop.
  Future<Shop> create({
    required String name,
    required String slug,
    required String description,
    String currency = '',
    String contactId = '',
    String checkoutReturnUrl = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createShop(
        CreateShopRequest(
          name: name,
          slug: slug,
          description: description.isEmpty ? null : description,
          currency: currency.isEmpty ? null : currency,
          contactId: contactId.isEmpty ? null : contactId,
          checkoutReturnUrl:
              checkoutReturnUrl.isEmpty ? null : checkoutReturnUrl,
        ),
      );
      state = const AsyncValue.data(null);
      // The shop id is generated server-side: select it explicitly and
      // reload the listing so the whole console switches to it.
      ref.read(selectedShopIdProvider.notifier).select(response.shop.id);
      ref.invalidate(shopListProvider);
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
    required String currency,
    required String contactId,
    required String checkoutReturnUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          name: name,
          description: description,
          status: status,
          currency: currency,
          contactId: contactId,
          checkoutReturnUrl: checkoutReturnUrl,
          updateMask: FieldMask(
            paths: const [
              'name',
              'description',
              'status',
              'currency',
              'contact_id',
              'checkout_return_url',
            ],
          ),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(shopListProvider);
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
