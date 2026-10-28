import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    hide Struct, Value;
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart'
    show ProfileObject, ProfileType, Struct, Value;
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Money _kes(int units) => Money(currencyCode: 'KES', units: Int64(units));

final _profile = ProfileObject(
  id: 'cust-1',
  type: ProfileType.PERSON,
  properties: Struct(fields: {'name': Value(stringValue: 'Jane Doe')}.entries),
);

class _Harness {
  _Harness({
    required this.pages,
    String initialLocation = '/customers/cust-1',
  }) {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ...CustomerRouteModule(shopId: 'shop-1').buildRoutes(),
        GoRoute(
          path: '/orders/:orderId',
          builder: (_, state) =>
              Text('order page ${state.pathParameters['orderId']}'),
        ),
      ],
    );
  }

  /// Order pages served in turn, keyed by the cursor that asks for them.
  final Map<String, ListOrdersResponse> pages;
  final requests = <ListOrdersRequest>[];
  late final GoRouter router;

  Widget build() => ProviderScope(
    overrides: [
      customerByIdProvider.overrideWith((ref, id) async => _profile),
      customerServiceClientProvider.overrideWithValue(
        CommerceServiceClient(
          FakeTransportBuilder().unary(CommerceService.listOrders, (req, _) {
            requests.add(req);
            return pages[req.search.cursor.page]!;
          }).build(),
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );

  String get location => router.routeInformationProvider.value.uri.path;
}

Future<_Harness> _pump(
  WidgetTester tester,
  Map<String, ListOrdersResponse> pages, {
  String initialLocation = '/customers/cust-1',
  Size size = const Size(1200, 1600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = _Harness(pages: pages, initialLocation: initialLocation);
  await tester.pumpWidget(h.build());
  await tester.pumpAndSettle();
  return h;
}

void main() {
  final owing = Order(
    id: 'ord-1',
    orderNumber: '1001',
    profileId: 'cust-1',
    status: OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
    paymentStatus: PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID,
    total: _kes(1000),
    balance: _kes(400),
  );
  final refunding = Order(
    id: 'ord-2',
    orderNumber: '1002',
    profileId: 'cust-1',
    status: OrderStatus.ORDER_STATUS_CANCELLED,
    paymentStatus: PaymentStatus.PAYMENT_STATUS_REFUND_PENDING,
    total: _kes(300),
    balance: _kes(0),
  );

  testWidgets('order history is filtered by the server, paged, and opens '
      'the order to record a payment', (tester) async {
    final h = await _pump(tester, {
      '': ListOrdersResponse(orders: [owing], nextPage: 'cursor-2'),
      'cursor-2': ListOrdersResponse(orders: [refunding]),
    });

    final first = h.requests.single;
    expect(first.shopId, 'shop-1');
    expect(first.profileId, 'cust-1');

    expect(find.text('#1001'), findsOneWidget);
    expect(find.textContaining('Part paid'), findsOneWidget);
    expect(find.textContaining('Owes'), findsOneWidget);
    expect(find.text('#1002'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('customer-orders-load-more')));
    await tester.pumpAndSettle();
    expect(h.requests.last.profileId, 'cust-1');
    expect(h.requests.last.search.cursor.page, 'cursor-2');
    expect(find.textContaining('Cancelled, refund pending'), findsOneWidget);

    await tester.tap(find.text('#1001'));
    await tester.pumpAndSettle();
    expect(h.location, '/orders/ord-1');
  });

  testWidgets('no pretend payments or notes', (tester) async {
    await _pump(tester, {
      '': ListOrdersResponse(orders: [owing]),
    });
    expect(find.text('Receive Payment'), findsNothing);
    expect(find.text('Notes'), findsNothing);
    expect(find.text('Balance'), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });

  testWidgets('the old payment link lands on the customer', (tester) async {
    final h = await _pump(tester, {
      '': ListOrdersResponse(orders: [owing]),
    }, initialLocation: '/customers/cust-1/payment');
    expect(h.location, '/customers/cust-1');
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('the customer page fits a phone', (tester) async {
    await _pump(tester, {
      '': ListOrdersResponse(orders: [owing, refunding]),
    }, size: const Size(360, 800));
    expect(find.text('#1001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
