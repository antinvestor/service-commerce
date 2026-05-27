import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_transport_provider.dart';

/// List orders for a given shop.
final orderListProvider =
    FutureProvider.family<List<Order>, String>((ref, shopId) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = ListOrdersRequest()..shopId = shopId;
  final response = await client.listOrders(request);
  return response.orders;
});

/// Get a single order by ID.
final orderByIdProvider =
    FutureProvider.family<Order, String>((ref, orderId) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetOrderRequest()..id = orderId;
  final response = await client.getOrder(request);
  return response.order;
});

/// Get a cart by ID.
final cartByIdProvider =
    FutureProvider.family<Cart, String>((ref, cartId) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetCartRequest()..id = cartId;
  final response = await client.getCart(request);
  return response.cart;
});

/// Get a fulfilment by ID.
final fulfilmentByIdProvider =
    FutureProvider.family<Fulfilment, String>((ref, fulfilmentId) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetFulfilmentRequest()..id = fulfilmentId;
  final response = await client.getFulfilment(request);
  return response.fulfilment;
});

/// Notifier for order mutations.
class OrderNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(orderServiceClientProvider);

  Future<Order> createOrder(CreateOrderRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createOrder(request);
      state = const AsyncValue.data(null);
      return response.order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Order> createFromCart(CreateOrderFromCartRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createOrderFromCart(request);
      state = const AsyncValue.data(null);
      return response.order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final orderNotifierProvider =
    NotifierProvider<OrderNotifier, AsyncValue<void>>(OrderNotifier.new);

/// Notifier for cart mutations.
class CartNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(orderServiceClientProvider);

  Future<Cart> createCart(CreateCartRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createCart(request);
      state = const AsyncValue.data(null);
      return response.cart;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Cart> addLine(AddCartLineRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.addCartLine(request);
      state = const AsyncValue.data(null);
      return response.cart;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Cart> removeLine(RemoveCartLineRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.removeCartLine(request);
      state = const AsyncValue.data(null);
      return response.cart;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, AsyncValue<void>>(CartNotifier.new);

/// Notifier for fulfilment mutations.
class FulfilmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client =>
      ref.read(orderServiceClientProvider);

  Future<Fulfilment> create(CreateFulfilmentRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createFulfilment(request);
      state = const AsyncValue.data(null);
      return response.fulfilment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Fulfilment> update(UpdateFulfilmentRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateFulfilment(request);
      state = const AsyncValue.data(null);
      return response.fulfilment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final fulfilmentNotifierProvider =
    NotifierProvider<FulfilmentNotifier, AsyncValue<void>>(
        FulfilmentNotifier.new);
