import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_transport_provider.dart';

/// List products for a given shop.
final productListProvider =
    FutureProvider.family<List<Product>, String>((ref, shopId) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = ListProductsRequest()..shopId = shopId;
  final response = await client.listProducts(request);
  return response.products;
});

/// Get a single product by ID.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = GetProductRequest()..id = productId;
  final response = await client.getProduct(request);
  return response.product;
});

/// Search products by shop + query.
final productSearchProvider = FutureProvider.family<List<Product>,
    ({String shopId, String query})>((ref, params) async {
  final client = ref.watch(catalogServiceClientProvider);
  final search = SearchRequest()..query = params.query;
  final request = ListProductsRequest()
    ..shopId = params.shopId
    ..search = search;
  final response = await client.listProducts(request);
  return response.products;
});

/// Notifier for product mutations (create).
class ProductNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(catalogServiceClientProvider);

  Future<Product> create(CreateProductRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProduct(request);
      state = const AsyncValue.data(null);
      return response.product;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, AsyncValue<void>>(ProductNotifier.new);

/// Notifier for variant mutations (create, update).
class VariantNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(catalogServiceClientProvider);

  Future<ProductVariant> create(CreateProductVariantRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProductVariant(request);
      state = const AsyncValue.data(null);
      return response.productVariant;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<ProductVariant> update(UpdateProductVariantRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateProductVariant(request);
      state = const AsyncValue.data(null);
      return response.productVariant;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final variantNotifierProvider =
    NotifierProvider<VariantNotifier, AsyncValue<void>>(VariantNotifier.new);
