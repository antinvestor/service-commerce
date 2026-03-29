//
//  Generated code. Do not modify.
//  source: v1/commerce.proto
//

import "package:connectrpc/connect.dart" as connect;
import "commerce.pb.dart" as v1commerce;
import "commerce.connect.spec.dart" as specs;

extension type CommerceServiceClient (connect.Transport _transport) {
  /// Creates a new shop. The authenticated user becomes the admin.
  Future<v1commerce.CreateShopResponse> createShop(
    v1commerce.CreateShopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createShop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Retrieves shop details by ID.
  Future<v1commerce.GetShopResponse> getShop(
    v1commerce.GetShopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.getShop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Updates shop details.
  Future<v1commerce.UpdateShopResponse> updateShop(
    v1commerce.UpdateShopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.updateShop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Creates a new product in the catalog.
  Future<v1commerce.CreateProductResponse> createProduct(
    v1commerce.CreateProductRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createProduct,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Retrieves a product by its ID.
  Future<v1commerce.GetProductResponse> getProduct(
    v1commerce.GetProductRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.getProduct,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists products belonging to a shop, with optional search and filtering.
  Future<v1commerce.ListProductsResponse> listProducts(
    v1commerce.ListProductsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.listProducts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Creates a new variant for a product.
  Future<v1commerce.CreateProductVariantResponse> createProductVariant(
    v1commerce.CreateProductVariantRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createProductVariant,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Updates an existing product variant.
  Future<v1commerce.UpdateProductVariantResponse> updateProductVariant(
    v1commerce.UpdateProductVariantRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.updateProductVariant,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1commerce.CreateCartResponse> createCart(
    v1commerce.CreateCartRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createCart,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1commerce.GetCartResponse> getCart(
    v1commerce.GetCartRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.getCart,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1commerce.AddCartLineResponse> addCartLine(
    v1commerce.AddCartLineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.addCartLine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1commerce.RemoveCartLineResponse> removeCartLine(
    v1commerce.RemoveCartLineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.removeCartLine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1commerce.CreateOrderFromCartResponse> createOrderFromCart(
    v1commerce.CreateOrderFromCartRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createOrderFromCart,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Creates an order and reserves stock atomically.
  /// The server MUST:
  /// - validate all variants belong to the shop
  /// - validate sufficient stock
  /// - decrement stock
  /// - snapshot price and name
  /// - compute totals
  /// The order is created in CONFIRMED state
  /// (since this API does not handle payments).
  Future<v1commerce.CreateOrderResponse> createOrder(
    v1commerce.CreateOrderRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createOrder,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Retrieves an order by ID.
  Future<v1commerce.GetOrderResponse> getOrder(
    v1commerce.GetOrderRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.getOrder,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists orders for a shop, with optional search and filtering.
  Future<v1commerce.ListOrdersResponse> listOrders(
    v1commerce.ListOrdersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.listOrders,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Creates a fulfilment for an order.
  /// A fulfilment may contain a subset of order lines.
  /// Quantity per line MUST NOT exceed remaining unfulfilled quantity.
  Future<v1commerce.CreateFulfilmentResponse> createFulfilment(
    v1commerce.CreateFulfilmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.createFulfilment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Updates a fulfilment (e.g. adding tracking number, marking as shipped).
  Future<v1commerce.UpdateFulfilmentResponse> updateFulfilment(
    v1commerce.UpdateFulfilmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.updateFulfilment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Retrieves a fulfilment by ID.
  Future<v1commerce.GetFulfilmentResponse> getFulfilment(
    v1commerce.GetFulfilmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CommerceService.getFulfilment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
