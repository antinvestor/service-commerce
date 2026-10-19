import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_transport_provider.dart';

/// List products for a given shop.
final productListProvider = FutureProvider.family<List<Product>, String>((
  ref,
  shopId,
) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = ListProductsRequest()..shopId = shopId;
  final response = await client.listProducts(request);
  return response.products;
});

/// Get a single product by ID.
final productByIdProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final client = ref.watch(catalogServiceClientProvider);
  final request = GetProductRequest()..id = productId;
  final response = await client.getProduct(request);
  return response.product;
});

/// List the variants of a product.
final productVariantsProvider =
    FutureProvider.family<List<ProductVariant>, String>((ref, productId) async {
      final client = ref.watch(catalogServiceClientProvider);
      final request = ListProductVariantsRequest()..productId = productId;
      final response = await client.listProductVariants(request);
      return response.productVariants;
    });

/// Search products of a shop by name.
///
/// `ListProducts` has no name search (its query only takes status keywords),
/// so this matches names and descriptions of the first page client-side.
final productSearchProvider =
    FutureProvider.family<List<Product>, ({String shopId, String query})>((
      ref,
      params,
    ) async {
      final client = ref.watch(catalogServiceClientProvider);
      final request = ListProductsRequest()..shopId = params.shopId;
      final response = await client.listProducts(request);
      return filterProductsByText(response.products, params.query);
    });

/// Keeps the products whose name or description contains [query]
/// (case-insensitive). An empty query keeps everything.
List<Product> filterProductsByText(Iterable<Product> products, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return products.toList();
  return products
      .where(
        (p) =>
            p.name.toLowerCase().contains(needle) ||
            p.description.toLowerCase().contains(needle),
      )
      .toList();
}

/// Get a shop by ID (used for its currency and payment policy).
final shopProvider = FutureProvider.family<Shop, String>((ref, shopId) async {
  final client = ref.watch(catalogServiceClientProvider);
  final response = await client.getShop(GetShopRequest()..id = shopId);
  return response.shop;
});

/// The currency a shop prices its products in ('' when the shop has none).
final shopCurrencyProvider = FutureProvider.family<String, String>((
  ref,
  shopId,
) async {
  final shop = await ref.watch(shopProvider(shopId).future);
  return shop.currency;
});

/// The currency of the shop that owns a product, for pricing its variants.
final productCurrencyProvider = FutureProvider.family<String, String>((
  ref,
  productId,
) async {
  final product = await ref.watch(productByIdProvider(productId).future);
  if (product.shopId.isEmpty) return '';
  return ref.watch(shopCurrencyProvider(product.shopId).future);
});

/// Status keywords `ListProducts` accepts in `search.query`.
abstract final class ProductStatusQuery {
  /// Active and inactive products (the server default).
  static const current = '';
  static const active = 'status:active';
  static const archived = 'status:archived';
  static const all = 'status:all';
}

/// Parameters of a paged product listing.
typedef ProductListQuery = ({String shopId, String statusQuery});

/// The pages of products loaded so far for a [ProductListQuery].
class ProductPages {
  const ProductPages({
    this.products = const [],
    this.nextPage = '',
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Product> products;

  /// Cursor of the next page; empty on the last page.
  final String nextPage;
  final bool isLoadingMore;
  final Object? loadMoreError;

  bool get hasMore => nextPage.isNotEmpty;

  ProductPages copyWith({
    List<Product>? products,
    String? nextPage,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) => ProductPages(
    products: products ?? this.products,
    nextPage: nextPage ?? this.nextPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: loadMoreError,
  );
}

/// Cursor-paged product listing: loads the first page, then appends pages
/// on [loadMore] using `ListProductsResponse.next_page`.
class ProductListNotifier extends AsyncNotifier<ProductPages> {
  ProductListNotifier(this.query);

  final ProductListQuery query;

  /// Products requested per page.
  static const pageSize = 50;

  CommerceServiceClient get _client => ref.read(catalogServiceClientProvider);

  Future<ListProductsResponse> _fetch(String cursor) {
    final search = SearchRequest(
      query: query.statusQuery,
      cursor: PageCursor(limit: pageSize, page: cursor),
    );
    return _client.listProducts(
      ListProductsRequest(shopId: query.shopId, search: search),
    );
  }

  @override
  Future<ProductPages> build() async {
    ref.watch(catalogServiceClientProvider);
    final response = await _fetch('');
    return ProductPages(
      products: response.products,
      nextPage: response.nextPage,
    );
  }

  /// Appends the next page. Does nothing on the last page or while a page
  /// is already loading.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final response = await _fetch(current.nextPage);
      state = AsyncValue.data(
        ProductPages(
          products: [...current.products, ...response.products],
          nextPage: response.nextPage,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }
}

final productPagesProvider =
    AsyncNotifierProvider.family<
      ProductListNotifier,
      ProductPages,
      ProductListQuery
    >(ProductListNotifier.new);

/// Notifier for product mutations (create, update).
class ProductNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client => ref.read(catalogServiceClientProvider);

  void _invalidateLists(String shopId) {
    ref.invalidate(productPagesProvider);
    if (shopId.isNotEmpty) ref.invalidate(productListProvider(shopId));
  }

  Future<Product> create(CreateProductRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProduct(request);
      state = const AsyncValue.data(null);
      _invalidateLists(request.shopId);
      return response.product;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Applies an `UpdateProduct` request and refreshes the cached product
  /// and the shop's listings.
  Future<Product> update(UpdateProductRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateProduct(request);
      state = const AsyncValue.data(null);
      ref.invalidate(productByIdProvider(request.id));
      _invalidateLists(response.product.shopId);
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

  CommerceServiceClient get _client => ref.read(catalogServiceClientProvider);

  Future<ProductVariant> create(CreateProductVariantRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createProductVariant(request);
      state = const AsyncValue.data(null);
      ref.invalidate(productVariantsProvider(request.productId));
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
      final productId = response.productVariant.productId;
      if (productId.isNotEmpty) {
        ref.invalidate(productVariantsProvider(productId));
      }
      return response.productVariant;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final variantNotifierProvider =
    NotifierProvider<VariantNotifier, AsyncValue<void>>(VariantNotifier.new);
