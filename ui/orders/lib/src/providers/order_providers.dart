import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/instalments.dart';
import 'order_transport_provider.dart';

/// List orders for a given shop.
final orderListProvider = FutureProvider.family<List<Order>, String>((
  ref,
  shopId,
) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = ListOrdersRequest()..shopId = shopId;
  final response = await client.listOrders(request);
  return response.orders;
});

/// One loaded page window of the order list: the orders fetched so far for
/// the current search and status filter, and the cursor for the next page
/// (empty at the end).
class OrderListState {
  const OrderListState({
    this.orders = const [],
    this.nextPage = '',
    this.query = '',
    this.status,
    this.loadingMore = false,
    this.loadMoreError,
    this.searching = false,
  });

  final List<Order> orders;
  final String nextPage;
  final String query;

  /// Only orders in this status, filtered by the server; null lists all.
  final OrderStatus? status;
  final bool loadingMore;

  /// A new search is in flight; [orders] still holds the previous results.
  final bool searching;
  final Object? loadMoreError;

  bool get hasMore => nextPage.isNotEmpty;

  OrderListState copyWith({
    List<Order>? orders,
    String? nextPage,
    bool? loadingMore,
    Object? loadMoreError,
  }) => OrderListState(
    orders: orders ?? this.orders,
    nextPage: nextPage ?? this.nextPage,
    query: query,
    status: status,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError,
  );
}

/// Server-side searched and status-filtered, cursor-paged order list for a
/// shop.
///
/// [search] and [filterStatus] restart from the first page; [loadMore]
/// appends the page named by the previous response's `next_page`.
class OrderListController extends AsyncNotifier<OrderListState> {
  OrderListController(this.shopId);

  final String shopId;

  static const pageSize = 50;

  /// Guards against an older search finishing after a newer one.
  int _generation = 0;

  @override
  Future<OrderListState> build() async {
    _generation++;
    final page = await _fetch('', null, '');
    return OrderListState(orders: page.orders, nextPage: page.nextPage);
  }

  Future<ListOrdersResponse> _fetch(
    String query,
    OrderStatus? status,
    String page,
  ) {
    final cursor = PageCursor(limit: pageSize);
    if (page.isNotEmpty) cursor.page = page;
    final search = SearchRequest(cursor: cursor);
    if (query.isNotEmpty) search.query = query;
    return ref
        .read(orderServiceClientProvider)
        .listOrders(
          ListOrdersRequest(
            shopId: shopId,
            search: search,
            statuses: [?status],
          ),
        );
  }

  /// Runs a new search (`search.query`) from the first page, keeping the
  /// status filter.
  Future<void> search(String query) =>
      _restart(query.trim(), state.value?.status);

  /// Shows only orders in [status] (null: every status), from the first
  /// page, keeping the search.
  Future<void> filterStatus(OrderStatus? status) =>
      _restart(state.value?.query ?? '', status);

  Future<void> _restart(String q, OrderStatus? status) async {
    final generation = ++_generation;
    final previous = state.value;
    state = previous == null
        ? const AsyncLoading<OrderListState>()
        : AsyncData(
            OrderListState(
              orders: previous.orders,
              nextPage: previous.nextPage,
              query: q,
              status: status,
              searching: true,
            ),
          );
    final next = await AsyncValue.guard(() async {
      final page = await _fetch(q, status, '');
      return OrderListState(
        orders: page.orders,
        nextPage: page.nextPage,
        query: q,
        status: status,
      );
    });
    if (generation == _generation) state = next;
  }

  /// Appends the next page, if any. Failures are kept on the state so the
  /// loaded orders stay visible.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await _fetch(
        current.query,
        current.status,
        current.nextPage,
      );
      state = AsyncData(
        current.copyWith(
          orders: [...current.orders, ...page.orders],
          nextPage: page.nextPage,
          loadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreError: e));
    }
  }
}

final orderListControllerProvider =
    AsyncNotifierProvider.family<OrderListController, OrderListState, String>(
      OrderListController.new,
    );

/// Upper bound on event pages fetched for one order.
const _maxOrderEventPages = 20;

/// Every event raised for one order, oldest first.
final orderEventsProvider = FutureProvider.family<List<OrderEvent>, String>((
  ref,
  orderId,
) async {
  final client = ref.watch(orderServiceClientProvider);
  final events = <OrderEvent>[];
  var page = '';
  for (var i = 0; i < _maxOrderEventPages; i++) {
    final cursor = PageCursor(limit: 100);
    if (page.isNotEmpty) cursor.page = page;
    final response = await client.listOrderEvents(
      ListOrderEventsRequest(
        orderId: orderId,
        search: SearchRequest(cursor: cursor),
      ),
    );
    events.addAll(response.events);
    page = response.nextPage;
    if (page.isEmpty) break;
  }
  return events;
});

/// A cursor-paged window of a shop's order events, oldest first.
class ShopEventsState {
  const ShopEventsState({
    this.events = const [],
    this.nextPage = '',
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<OrderEvent> events;
  final String nextPage;
  final bool loadingMore;
  final Object? loadMoreError;

  bool get hasMore => nextPage.isNotEmpty;
}

/// The shop-wide event feed (staff): ListOrderEvents by shop_id.
class ShopEventsController extends AsyncNotifier<ShopEventsState> {
  ShopEventsController(this.shopId);

  final String shopId;

  static const pageSize = 50;

  Future<ListOrderEventsResponse> _fetch(String page) {
    final cursor = PageCursor(limit: pageSize);
    if (page.isNotEmpty) cursor.page = page;
    return ref
        .read(orderServiceClientProvider)
        .listOrderEvents(
          ListOrderEventsRequest(
            shopId: shopId,
            search: SearchRequest(cursor: cursor),
          ),
        );
  }

  @override
  Future<ShopEventsState> build() async {
    final page = await _fetch('');
    return ShopEventsState(events: page.events, nextPage: page.nextPage);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      ShopEventsState(
        events: current.events,
        nextPage: current.nextPage,
        loadingMore: true,
      ),
    );
    try {
      final page = await _fetch(current.nextPage);
      state = AsyncData(
        ShopEventsState(
          events: [...current.events, ...page.events],
          nextPage: page.nextPage,
        ),
      );
    } catch (e) {
      state = AsyncData(
        ShopEventsState(
          events: current.events,
          nextPage: current.nextPage,
          loadMoreError: e,
        ),
      );
    }
  }
}

final shopEventsControllerProvider =
    AsyncNotifierProvider.family<ShopEventsController, ShopEventsState, String>(
      ShopEventsController.new,
    );

/// Every fulfilment created against one order.
final orderFulfilmentsProvider =
    FutureProvider.family<List<Fulfilment>, String>((ref, orderId) async {
      final client = ref.watch(orderServiceClientProvider);
      final response = await client.listFulfilments(
        ListFulfilmentsRequest(orderId: orderId),
      );
      return response.fulfilments;
    });

/// Get a single order by ID.
final orderByIdProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetOrderRequest()..id = orderId;
  final response = await client.getOrder(request);
  return response.order;
});

/// Get a cart by ID.
final cartByIdProvider = FutureProvider.family<Cart, String>((
  ref,
  cartId,
) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetCartRequest()..id = cartId;
  final response = await client.getCart(request);
  return response.cart;
});

/// Get a fulfilment by ID.
final fulfilmentByIdProvider = FutureProvider.family<Fulfilment, String>((
  ref,
  fulfilmentId,
) async {
  final client = ref.watch(orderServiceClientProvider);
  final request = GetFulfilmentRequest()..id = fulfilmentId;
  final response = await client.getFulfilment(request);
  return response.fulfilment;
});

/// Notifier for order mutations.
class OrderNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client => ref.read(orderServiceClientProvider);

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

  /// Starts hosted checkout for an order and returns the page URL the buyer
  /// completes payment on. Idempotent: an existing live session is reused.
  ///
  /// [amount] is the instalment to pay now; null pays the whole balance.
  Future<CheckoutOrderResponse> checkout(
    String orderId, {
    String? returnUrl,
    Money? amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final request = CheckoutOrderRequest()..orderId = orderId;
      if (returnUrl != null && returnUrl.isNotEmpty) {
        request.returnUrl = returnUrl;
      }
      if (amount != null) request.amount = amount;
      final response = await _client.checkoutOrder(request);
      state = const AsyncValue.data(null);
      ref.invalidate(orderByIdProvider(orderId));
      ref.invalidate(orderEventsProvider(orderId));
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Verifies the checkout session with the payment service and marks the
  /// order paid.
  Future<Order> confirmPayment(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.confirmOrderPayment(
        ConfirmOrderPaymentRequest()..orderId = orderId,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(orderByIdProvider(orderId));
      ref.invalidate(orderEventsProvider(orderId));
      return response.order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Applies a payment the shop took offline (cash, bank transfer, ...).
  /// [reference] is the shop's receipt reference, unique per order;
  /// repeating it is a no-op that returns the order.
  Future<Order> recordPayment(
    String orderId, {
    required Money amount,
    required String reference,
    String note = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final request = RecordOrderPaymentRequest(
        orderId: orderId,
        amount: amount,
        reference: reference,
      );
      if (note.isNotEmpty) request.note = note;
      final response = await _client.recordOrderPayment(request);
      state = const AsyncValue.data(null);
      ref.invalidate(orderByIdProvider(orderId));
      ref.invalidate(orderEventsProvider(orderId));
      return response.order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Cancels an unfulfilled order and returns its stock.
  Future<Order> cancel(String orderId, {String reason = ''}) async {
    state = const AsyncValue.loading();
    try {
      final request = CancelOrderRequest()..orderId = orderId;
      if (reason.isNotEmpty) request.reason = reason;
      final response = await _client.cancelOrder(request);
      state = const AsyncValue.data(null);
      ref.invalidate(orderByIdProvider(orderId));
      return response.order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final orderNotifierProvider = NotifierProvider<OrderNotifier, AsyncValue<void>>(
  OrderNotifier.new,
);

/// Notifier for cart mutations.
class CartNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client => ref.read(orderServiceClientProvider);

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

final cartNotifierProvider = NotifierProvider<CartNotifier, AsyncValue<void>>(
  CartNotifier.new,
);

/// Notifier for fulfilment mutations.
class FulfilmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client => ref.read(orderServiceClientProvider);

  Future<Fulfilment> create(CreateFulfilmentRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createFulfilment(request);
      state = const AsyncValue.data(null);
      ref.invalidate(orderFulfilmentsProvider(request.orderId));
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
      final fulfilment = response.fulfilment;
      ref.invalidate(fulfilmentByIdProvider(request.id));
      if (fulfilment.orderId.isNotEmpty) {
        ref.invalidate(orderFulfilmentsProvider(fulfilment.orderId));
        ref.invalidate(orderByIdProvider(fulfilment.orderId));
      }
      return fulfilment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final fulfilmentNotifierProvider =
    NotifierProvider<FulfilmentNotifier, AsyncValue<void>>(
      FulfilmentNotifier.new,
    );
