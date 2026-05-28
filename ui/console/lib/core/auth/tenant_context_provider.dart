import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolved shop and property identifiers for the active session.
///
/// The console derives these from the authenticated user's tenancy
/// context. The current user's `partitionId` maps to a property, and
/// the active organization maps to a shop. Until full multi-shop
/// support lands, the partition acts as the property identifier and a
/// derived value identifies the shop.
class TenantScope {
  const TenantScope({
    required this.shopId,
    required this.propertyId,
    required this.partitionId,
    required this.organizationId,
    required this.branchId,
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
  final String propertyId;
  final String partitionId;
  final String organizationId;
  final String branchId;

  bool get isReady => shopId.isNotEmpty && propertyId.isNotEmpty;
}

/// Reads the active [TenancyContext] and projects it onto the
/// console's [TenantScope]. Returns [TenantScope.empty] when the user
/// has not yet selected an organization/branch.
final tenantScopeProvider = Provider<TenantScope>((ref) {
  final context = ref.watch(tenancyContextProvider);
  if (!context.hasPartition) return TenantScope.empty();

  final organizationId = context.organizationId;
  final branchId = context.branchId;
  final partitionId = context.partitionId;

  // Property is the operational site — a branch when set, else the
  // organization. The partition is the catch-all fallback.
  final propertyId = branchId.isNotEmpty
      ? branchId
      : organizationId.isNotEmpty
          ? organizationId
          : partitionId;

  // Shop is the commerce-facing tenant — currently 1:1 with the
  // organization (or partition until orgs are selected).
  final shopId =
      organizationId.isNotEmpty ? organizationId : partitionId;

  return TenantScope(
    shopId: shopId,
    propertyId: propertyId,
    partitionId: partitionId,
    organizationId: organizationId,
    branchId: branchId,
  );
});
