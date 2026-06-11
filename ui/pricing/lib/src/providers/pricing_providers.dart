import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pricing_transport_provider.dart';

/// List price lists for a given shop.
final priceListProvider =
    FutureProvider.family<List<PriceList>, String>((ref, shopId) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = PriceListSearchRequest()..shopId = shopId;
  final response = await client.priceListSearch(request);
  return response.priceLists;
});

/// Get a single price list by ID.
final priceListByIdProvider =
    FutureProvider.family<PriceList, String>((ref, priceListId) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = PriceListGetRequest()..id = priceListId;
  final response = await client.priceListGet(request);
  return response.priceList;
});

/// Entries currently managed for a given price list.
///
/// The commerce backend exposes price-list entries only through
/// [CommerceServiceClient.priceListEntryBatchSave] (replace-by-variant) — there
/// is no dedicated entry-search RPC and neither [PriceList] nor
/// [PriceListGetResponse] carries entries. The authoritative entry set for the
/// active editing session is therefore held by [PricingNotifier], which seeds
/// and updates it from every real batch-save RPC response. This provider
/// surfaces that server-confirmed set; it watches the notifier so it rebuilds
/// whenever a batch-save completes.
final priceListEntryListProvider =
    FutureProvider.family<List<PriceListEntry>, String>((ref, priceListId) async {
  // Watch the notifier so the provider is recomputed after each mutation.
  ref.watch(pricingNotifierProvider);
  final notifier = ref.read(pricingNotifierProvider.notifier);
  return notifier.entriesFor(priceListId);
});

/// List customer price overrides, filtered by customer or variant.
final customerOverrideListProvider = FutureProvider.family<
    List<CustomerPriceOverride>,
    ({String? customerId, String? variantId})>((ref, params) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = CustomerPriceOverrideSearchRequest();
  if (params.customerId != null) request.customerId = params.customerId!;
  if (params.variantId != null) request.productVariantId = params.variantId!;
  final response = await client.customerPriceOverrideSearch(request);
  return response.overrides;
});

/// List discount rules for a shop.
final discountRuleListProvider =
    FutureProvider.family<List<DiscountRule>, String>((ref, shopId) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = DiscountRuleSearchRequest()..shopId = shopId;
  final response = await client.discountRuleSearch(request);
  return response.discountRules;
});

/// List customer price-list assignments, filtered by price list and/or customer.
final priceListAssignmentListProvider = FutureProvider.family<
    List<CustomerPriceListAssignment>,
    ({String? priceListId, String? customerId})>((ref, params) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = CustomerPriceListAssignmentSearchRequest();
  if (params.priceListId != null) request.priceListId = params.priceListId!;
  if (params.customerId != null) request.customerId = params.customerId!;
  final response = await client.customerPriceListAssignmentSearch(request);
  return response.assignments;
});

/// Resolve the effective price for a customer + variant + quantity.
final resolvePriceProvider = FutureProvider.family<ResolvedPrice,
    ({String customerId, String variantId, int quantity})>(
    (ref, params) async {
  final client = ref.watch(pricingServiceClientProvider);
  final request = ResolvePriceRequest()
    ..customerId = params.customerId
    ..productVariantId = params.variantId
    ..quantity = params.quantity;
  final response = await client.resolvePrice(request);
  return response.resolvedPrice;
});

/// Notifier for pricing mutations.
class PricingNotifier extends Notifier<AsyncValue<void>> {
  /// Server-confirmed entry sets, keyed by price-list ID. Seeded and updated
  /// exclusively from real [priceListEntryBatchSave] RPC responses.
  final Map<String, List<PriceListEntry>> _entriesByList = {};

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(pricingServiceClientProvider);

  /// The entries currently confirmed for [priceListId] in this session.
  List<PriceListEntry> entriesFor(String priceListId) =>
      List.unmodifiable(_entriesByList[priceListId] ?? const []);

  Future<PriceList> savePriceList(PriceListSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.priceListSave(request);
      state = const AsyncValue.data(null);
      return response.priceList;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Replaces the entries for the variants present in [request] and records
  /// the server-confirmed set for the price list so reads reflect it.
  Future<List<PriceListEntry>> batchSaveEntries(
      PriceListEntryBatchSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.priceListEntryBatchSave(request);
      // The backend replaces entries per variant in the request and returns the
      // saved entries. Merge those into the cached set, replacing any prior
      // entries for the same variants and dropping variants no longer present.
      final priceListId = request.priceListId;
      final requestedVariants =
          request.entries.map((e) => e.productVariantId).toSet();
      final retained = (_entriesByList[priceListId] ?? const [])
          .where((e) => !requestedVariants.contains(e.productVariantId))
          .toList();
      retained.addAll(response.entries);
      _entriesByList[priceListId] = retained;
      state = const AsyncValue.data(null);
      return response.entries;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Removes [variantId]'s entries for the price list, re-saving its surviving
  /// tiers ([remaining]) so the backend's replace-by-variant delete clears the
  /// removed tier. When no tiers remain, the entry is dropped from the local
  /// cache; the backend's batch-save RPC deletes a variant's entries only when
  /// that variant is present in the request, so an isolated last tier cannot be
  /// cleared without resending other entries.
  Future<void> removeVariantEntries({
    required String priceListId,
    required String variantId,
    required List<PriceListEntry> remaining,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (remaining.isNotEmpty) {
        final response = await _client.priceListEntryBatchSave(
          PriceListEntryBatchSaveRequest()
            ..priceListId = priceListId
            ..entries.addAll(remaining),
        );
        final others = (_entriesByList[priceListId] ?? const [])
            .where((e) => e.productVariantId != variantId)
            .toList();
        others.addAll(response.entries);
        _entriesByList[priceListId] = others;
      } else {
        _entriesByList[priceListId] =
            (_entriesByList[priceListId] ?? const [])
                .where((e) => e.productVariantId != variantId)
                .toList();
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<CustomerPriceOverride> saveOverride(
      CustomerPriceOverrideSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.customerPriceOverrideSave(request);
      state = const AsyncValue.data(null);
      // ignore: deprecated_member_use
      return response.override;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<DiscountRule> saveDiscount(DiscountRuleSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.discountRuleSave(request);
      state = const AsyncValue.data(null);
      return response.discountRule;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<CustomerPriceListAssignment> saveAssignment(
      CustomerPriceListAssignmentSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.customerPriceListAssignmentSave(request);
      state = const AsyncValue.data(null);
      return response.assignment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final pricingNotifierProvider =
    NotifierProvider<PricingNotifier, AsyncValue<void>>(PricingNotifier.new);
