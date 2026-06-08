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

/// List entries for a given price list.
final priceListEntryListProvider = FutureProvider.family<
    List<PriceListEntry>, String>((ref, priceListId) async {
  // Entries are fetched via batch save with an empty list to get current state.
  // For now, we return an empty list until a dedicated search RPC exists.
  return [];
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
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(pricingServiceClientProvider);

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

  Future<List<PriceListEntry>> batchSaveEntries(
      PriceListEntryBatchSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.priceListEntryBatchSave(request);
      state = const AsyncValue.data(null);
      return response.entries;
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
}

final pricingNotifierProvider =
    NotifierProvider<PricingNotifier, AsyncValue<void>>(PricingNotifier.new);
