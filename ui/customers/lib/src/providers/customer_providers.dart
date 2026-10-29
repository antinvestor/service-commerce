import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart'
    show ProfileObject;
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_transport_provider.dart';

/// Get a customer (profile) by ID. Delegates to the profile service.
final customerByIdProvider = FutureProvider.family<ProfileObject, String>((
  ref,
  customerId,
) async {
  return ref.watch(profileByIdProvider(customerId).future);
});

/// Search customers (profiles) by query. Delegates to the profile service.
final customerSearchProvider =
    FutureProvider.family<List<ProfileObject>, String>((ref, query) async {
      return ref.watch(profileSearchProvider(query).future);
    });

/// Which customer's orders, in which shop.
typedef CustomerOrdersQuery = ({String shopId, String customerId});

/// A customer's orders loaded so far, newest first, and the cursor of the
/// next page (empty on the last).
class CustomerOrders {
  const CustomerOrders({
    this.orders = const [],
    this.nextPage = '',
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<Order> orders;
  final String nextPage;
  final bool loadingMore;
  final Object? loadMoreError;

  bool get hasMore => nextPage.isNotEmpty;
}

/// One customer's order history in a shop, filtered by the server
/// (ListOrders `profile_id`) and paged with its cursor.
class CustomerOrdersController extends AsyncNotifier<CustomerOrders> {
  CustomerOrdersController(this.query);

  final CustomerOrdersQuery query;

  static const pageSize = 25;

  Future<ListOrdersResponse> _fetch(String page) {
    final cursor = PageCursor(limit: pageSize);
    if (page.isNotEmpty) cursor.page = page;
    return ref
        .read(customerServiceClientProvider)
        .listOrders(
          ListOrdersRequest(
            shopId: query.shopId,
            profileId: query.customerId,
            search: SearchRequest(cursor: cursor),
          ),
        );
  }

  @override
  Future<CustomerOrders> build() async {
    ref.watch(customerServiceClientProvider);
    final page = await _fetch('');
    return CustomerOrders(orders: page.orders, nextPage: page.nextPage);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      CustomerOrders(
        orders: current.orders,
        nextPage: current.nextPage,
        loadingMore: true,
      ),
    );
    try {
      final page = await _fetch(current.nextPage);
      state = AsyncData(
        CustomerOrders(
          orders: [...current.orders, ...page.orders],
          nextPage: page.nextPage,
        ),
      );
    } catch (e) {
      state = AsyncData(
        CustomerOrders(
          orders: current.orders,
          nextPage: current.nextPage,
          loadMoreError: e,
        ),
      );
    }
  }
}

final customerOrdersProvider =
    AsyncNotifierProvider.family<
      CustomerOrdersController,
      CustomerOrders,
      CustomerOrdersQuery
    >(CustomerOrdersController.new);
