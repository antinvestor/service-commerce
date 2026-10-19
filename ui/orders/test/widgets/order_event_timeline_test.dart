import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/providers/order_transport_provider.dart';
import 'package:antinvestor_ui_orders/src/utils/instalments.dart';
import 'package:antinvestor_ui_orders/src/widgets/order_event_timeline.dart';
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) => Money(currencyCode: 'KES', units: Int64(units));

List<OrderEvent> _events() => [
  OrderEvent(
    id: 'ev-1',
    orderId: 'ord-1',
    orderNumber: '1001',
    type: OrderEventType.ORDER_EVENT_TYPE_DEPOSIT_PAID,
    paidPercent: 30,
    paymentAmount: _kes(300),
    amountPaid: _kes(300),
    balance: _kes(700),
    delivery: OrderEventDelivery.ORDER_EVENT_DELIVERY_DELIVERED,
    createdAt: Timestamp.fromDateTime(DateTime.utc(2026, 9, 1)),
  ),
  OrderEvent(
    id: 'ev-2',
    orderId: 'ord-1',
    orderNumber: '1001',
    type: OrderEventType.ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
    thresholdPercent: 50,
    paidPercent: 60,
    delivery: OrderEventDelivery.ORDER_EVENT_DELIVERY_FAILED,
  ),
  OrderEvent(
    id: 'ev-3',
    orderId: 'ord-1',
    orderNumber: '1001',
    type: OrderEventType.ORDER_EVENT_TYPE_FULLY_PAID,
    paidPercent: 100,
    delivery: OrderEventDelivery.ORDER_EVENT_DELIVERY_PENDING,
  ),
];

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('renders events in order with type, percentages and delivery', (
    tester,
  ) async {
    await _pump(tester, OrderEventTimeline(events: _events()));

    expect(find.text('Deposit paid'), findsOneWidget);
    expect(find.text('Threshold reached'), findsOneWidget);
    expect(find.text('Fully paid'), findsOneWidget);

    // Oldest first, newest last.
    final deposit = tester.getTopLeft(find.text('Deposit paid')).dy;
    final threshold = tester.getTopLeft(find.text('Threshold reached')).dy;
    final full = tester.getTopLeft(find.text('Fully paid')).dy;
    expect(deposit < threshold && threshold < full, isTrue);

    expect(
      find.text(
        '30% paid · Instalment KES 300.00 · Paid KES 300.00 · '
        'Balance KES 700.00',
      ),
      findsOneWidget,
    );
    expect(find.text('Threshold 50% · 60% paid'), findsOneWidget);
    expect(find.text('100% paid'), findsOneWidget);

    expect(find.text('Webhook delivered'), findsOneWidget);
    expect(find.text('Webhook failed'), findsOneWidget);
    expect(find.text('Webhook pending'), findsOneWidget);

    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    // Per-order timeline does not repeat the order number.
    expect(find.text('Order #1001'), findsNothing);
  });

  testWidgets('shop feed names each order and opens it on tap', (tester) async {
    final tapped = <String>[];
    await _pump(
      tester,
      OrderEventTimeline(
        events: _events(),
        showOrder: true,
        onOrderTap: (e) => tapped.add(e.id),
      ),
    );

    expect(find.text('Order #1001'), findsNWidgets(3));
    await tester.tap(find.text('Fully paid'));
    expect(tapped, ['ev-3']);
  });

  testWidgets('shows an empty state', (tester) async {
    await _pump(tester, const OrderEventTimeline(events: []));
    expect(find.text('No events yet'), findsOneWidget);
  });

  testWidgets('order section loads events by order id', (tester) async {
    ListOrderEventsRequest? sent;
    final client = CommerceServiceClient(
      FakeTransportBuilder().unary(CommerceService.listOrderEvents, (req, _) {
        sent = req;
        return ListOrderEventsResponse(events: _events());
      }).build(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [orderServiceClientProvider.overrideWithValue(client)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderEventsSection(orderId: 'ord-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(sent!.orderId, 'ord-1');
    expect(sent!.shopId, isEmpty);
    expect(find.text('Deposit paid'), findsOneWidget);
    expect(find.text('Fully paid'), findsOneWidget);
  });
}
