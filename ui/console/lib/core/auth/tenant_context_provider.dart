import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart'
    show userClaimsProvider;
import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_shop_provider.dart';

/// Resolved shop and property identifiers for the active session.
///
/// The shop is the commerce tenant the merchant operates, resolved from
/// the shops the caller can see (`ListShops`, see [activeShopProvider]).
/// The property is the operational site: the active branch, else the
/// organization, else the partition.
class TenantScope {
  const TenantScope({
    required this.shopId,
    required this.propertyId,
    required this.partitionId,
    required this.organizationId,
    required this.branchId,
    this.shopName = '',
  });

  /// Sentinel scope used before login completes.
  factory TenantScope.empty() => const TenantScope(
        shopId: '',
        propertyId: '',
        partitionId: '',
        organizationId: '',
        branchId: '',
      );

  final String shopId;
  final String shopName;
  final String propertyId;
  final String partitionId;
  final String organizationId;
  final String branchId;

  bool get isReady => shopId.isNotEmpty && propertyId.isNotEmpty;
}

/// Projects the active shop and the user's tenancy onto the console's
/// [TenantScope].
///
/// The partition comes from the selected [TenancyContext] when one is set,
/// falling back to the `partition_id` claim of the signed-in user.
final tenantScopeProvider = Provider<TenantScope>((ref) {
  final context = ref.watch(tenancyContextProvider);
  final shop = ref.watch(activeShopProvider);

  final organizationId = context.organizationId;
  final branchId = context.branchId;
  var partitionId = context.partitionId;
  if (partitionId.isEmpty) {
    final claim = ref.watch(userClaimsProvider).value?['partition_id'];
    if (claim is String) partitionId = claim;
  }

  // Property is the operational site — a branch when set, else the
  // organization. The partition is the catch-all fallback.
  final propertyId = branchId.isNotEmpty
      ? branchId
      : organizationId.isNotEmpty
          ? organizationId
          : partitionId;

  return TenantScope(
    shopId: shop?.id ?? '',
    shopName: shop?.name ?? '',
    propertyId: propertyId,
    partitionId: partitionId,
    organizationId: organizationId,
    branchId: branchId,
  );
});
