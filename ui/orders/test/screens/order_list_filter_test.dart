import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(String id, OrderStatus status) =>
    Order(id: id, orderNumber: id, status: status);

/// Answers ListOrders by filtering [orders] as the server does, two per
/// page, and records each request.
class _Backend {
  _Backend(this.orders);

  final List<Order> orders;
  final requests = <ListOrdersRequest>[];

  CommerceServiceClient client() => CommerceServiceClient(
    FakeTransportBuilder().unary(CommerceService.listOrders, (req, _) {
      requests.add(req);
      final matching = orders
          .where((o) => req.statuses.isEmpty || req.statuses.contains(o.status))
          .toList();
      final start = req.search.cursor.page.isEmpty
          ? 0
          : int.parse(req.search.cursor.page);
      final end = (start + 2).clamp(0, matching.length);
      return ListOrdersResponse(
        orders: matching.sublist(start, end),
        nextPage: end < matching.length ? '$end' : '',
      );
    }).build(),
  );
}

Future<_Backend> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final backend = _Backend([
    _order('c1', OrderStatus.ORDER_STATUS_CONFIRMED),
    _order('x1', OrderStatus.ORDER_STATUS_CANCELLED),
    _order('c2', OrderStatus.ORDER_STATUS_CONFIRMED),
    _order('x2', OrderStatus.ORDER_STATUS_CANCELLED),
    _order('c3', OrderStatus.ORDER_STATUS_CONFIRMED),
  ]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderServiceClientProvider.overrideWithValue(backend.client()),
        userPermissionsProvider.overrideWith((ref) async => {'order_view'}),
      ],
      child: const MaterialApp(home: OrderListScreen(shopId: 'shop-1')),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  testWidgets('a status chip asks the server for that status only', (
    tester,
  ) async {
    final backend = await _pump(tester);
    expect(backend.requests.single.statuses, isEmpty);

    await tester.tap(
      find.byKey(
        ValueKey('order-status-${OrderStatus.ORDER_STATUS_CANCELLED.value}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(backend.requests.last.statuses, [
      OrderStatus.ORDER_STATUS_CANCELLED,
    ]);
    expect(backend.requests.last.search.cursor.page, isEmpty);
    expect(find.text('2 orders'), findsOneWidget);
    expect(find.byKey(const ValueKey('orders-load-more')), findsNothing);
  });

  testWidgets('load more keeps the status filter', (tester) async {
    final backend = await _pump(tester);
    await tester.tap(
      find.byKey(
        ValueKey('order-status-${OrderStatus.ORDER_STATUS_CONFIRMED.value}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 orders loaded'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('orders-load-more')));
    await tester.pumpAndSettle();

    final more = backend.requests.last;
    expect(more.statuses, [OrderStatus.ORDER_STATUS_CONFIRMED]);
    expect(more.search.cursor.page, '2');
    expect(find.text('3 orders'), findsOneWidget);

    // All clears the filter on the server too.
    await tester.tap(find.byKey(const ValueKey('order-status-all')));
    await tester.pumpAndSettle();
    expect(backend.requests.last.statuses, isEmpty);
    expect(find.text('2 orders loaded'), findsOneWidget);
  });

  testWidgets('an empty filtered page says so', (tester) async {
    await _pump(tester);
    await tester.tap(
      find.byKey(
        ValueKey('order-status-${OrderStatus.ORDER_STATUS_FULFILLED.value}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No orders with this status'), findsOneWidget);
  });
}
