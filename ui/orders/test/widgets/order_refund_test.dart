import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart';
import 'package:antinvestor_ui_orders/src/utils/instalments.dart';
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) => Money(currencyCode: 'KES', units: Int64(units));

/// A paid, confirmed order that has not shipped yet.
Order _paid() => Order(
  id: 'ord-1',
  orderNumber: '1042',
  status: OrderStatus.ORDER_STATUS_CONFIRMED,
  paymentStatus: PaymentStatus.PAYMENT_STATUS_PAID,
  fulfilmentStatus: FulfilmentStatus.FULFILMENT_STATUS_PENDING,
  total: _kes(1500),
  amountPaid: _kes(1500),
  balance: _kes(0),
);

/// Serves the panel's order and records cancellations.
class _Backend {
  _Backend(this.order);

  Order order;
  final cancels = <CancelOrderRequest>[];
  final resolutions = <ResolveOrderRefundRequest>[];

  CommerceServiceClient client() => CommerceServiceClient(
    FakeTransportBuilder()
        .unary(CommerceService.getOrder, (req, _) {
          return GetOrderResponse(order: order);
        })
        .unary(CommerceService.cancelOrder, (req, _) {
          cancels.add(req);
          order = order.deepCopy()
            ..status = OrderStatus.ORDER_STATUS_CANCELLED
            ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUND_PENDING;
          return CancelOrderResponse(order: order);
        })
        .unary(CommerceService.resolveOrderRefund, (req, _) {
          resolutions.add(req);
          final paidBack =
              req.resolution ==
              OrderRefundResolution.ORDER_REFUND_RESOLUTION_PAID_BACK;
          order = order.deepCopy();
          order.refunds.first.status = paidBack
              ? OrderRefundStatus.ORDER_REFUND_STATUS_CONFIRMED
              : OrderRefundStatus.ORDER_REFUND_STATUS_SENT;
          if (paidBack) {
            order
              ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUNDED
              ..amountRefunded = order.refunds.first.amount;
          }
          return ResolveOrderRefundResponse(order: order);
        })
        .build(),
  );
}

class _Panel extends ConsumerWidget {
  const _Panel();

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(orderByIdProvider('ord-1'))
      .when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('error: $e'),
        data: (order) => Column(
          children: [
            PaymentStatusBadge(status: order.paymentStatus),
            OrderPaymentPanel(order: order),
          ],
        ),
      );
}

Future<_Backend> _pump(
  WidgetTester tester,
  Order order, {
  Set<String> permissions = const {'order_view', 'order_manage'},
  Size size = const Size(1200, 2000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final backend = _Backend(order);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderServiceClientProvider.overrideWithValue(backend.client()),
        userPermissionsProvider.overrideWith((ref) async => permissions),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: _Panel())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}

/// A cancelled, paid order whose refund the payment service failed.
Order _failedRefund() => _paid()
  ..status = OrderStatus.ORDER_STATUS_CANCELLED
  ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUND_PENDING
  ..refunds.add(
    OrderRefund(
      id: 'ref-1',
      amount: _kes(1500),
      status: OrderRefundStatus.ORDER_REFUND_STATUS_FAILED,
      lastError: 'wallet closed',
    ),
  );

void main() {
  group('failed refunds', () {
    testWidgets('say why and are not shown as on their way', (tester) async {
      await _pump(tester, _failedRefund());
      final card = find.byKey(const ValueKey('refund-failed-ref-1'));
      expect(card, findsOneWidget);
      expect(
        find.descendant(
          of: card,
          matching: find.textContaining('wallet closed'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('payment-refund-pending')),
        findsNothing,
      );
    });

    testWidgets('staff send one again', (tester) async {
      final backend = await _pump(tester, _failedRefund());
      await tester.tap(find.byKey(const ValueKey('refund-retry-ref-1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('refund_resolve_note')),
        '  wallet reopened ',
      );
      await tester.tap(find.byKey(const Key('refund_resolve_confirm')));
      await tester.pumpAndSettle();

      final request = backend.resolutions.single;
      expect(request.orderId, 'ord-1');
      expect(request.refundId, 'ref-1');
      expect(
        request.resolution,
        OrderRefundResolution.ORDER_REFUND_RESOLUTION_RETRY,
      );
      expect(request.note, 'wallet reopened');
      expect(find.text('Refund sent again'), findsOneWidget);
      // Back with the payment service: on its way again.
      expect(find.byKey(const ValueKey('refund-failed-ref-1')), findsNothing);
      expect(
        find.byKey(const ValueKey('payment-refund-pending')),
        findsOneWidget,
      );
    });

    testWidgets('staff record paying the buyer back', (tester) async {
      final backend = await _pump(tester, _failedRefund());
      await tester.tap(find.byKey(const ValueKey('refund-paid-back-ref-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('refund_resolve_confirm')));
      await tester.pumpAndSettle();

      expect(
        backend.resolutions.single.resolution,
        OrderRefundResolution.ORDER_REFUND_RESOLUTION_PAID_BACK,
      );
      expect(find.text('Refund recorded as paid back'), findsOneWidget);
      expect(find.byKey(const ValueKey('payment-refunded')), findsOneWidget);
    });

    testWidgets('without order_manage there is nothing to press', (
      tester,
    ) async {
      await _pump(tester, _failedRefund(), permissions: const {'order_view'});
      expect(find.byKey(const ValueKey('refund-failed-ref-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('refund-retry-ref-1')), findsNothing);
      expect(
        find.byKey(const ValueKey('refund-paid-back-ref-1')),
        findsNothing,
      );
    });
  });

  group('refunds', () {
    testWidgets('a refund in flight says it is on its way and automatic', (
      tester,
    ) async {
      await _pump(
        tester,
        _paid()
          ..status = OrderStatus.ORDER_STATUS_CANCELLED
          ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUND_PENDING,
      );
      expect(find.text('Refund pending'), findsOneWidget);
      final notice = find.byKey(const ValueKey('payment-refund-pending'));
      expect(notice, findsOneWidget);
      expect(
        find.descendant(
          of: notice,
          matching: find.textContaining('KES 1500.00 is on its way'),
        ),
        findsOneWidget,
      );
      // Nothing is left to cancel or collect.
      expect(find.textContaining('Cancel'), findsNothing);
      expect(find.text('Record payment'), findsNothing);
    });

    testWidgets('a confirmed refund shows how much went back', (tester) async {
      await _pump(
        tester,
        _paid()
          ..status = OrderStatus.ORDER_STATUS_CANCELLED
          ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUNDED
          ..amountRefunded = _kes(1500),
      );
      expect(find.text('Refunded'), findsWidgets);
      final row = find.byKey(const ValueKey('payment-refunded'));
      expect(
        find.descendant(of: row, matching: find.text('KES 1500.00')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('payment-refund-pending')),
        findsNothing,
      );
    });

    testWidgets('a payment under review is flagged for staff', (tester) async {
      await _pump(
        tester,
        _paid()..paymentReview = 'Checkout charged KES 1,400, not KES 1,500.',
      );
      final notice = find.byKey(const ValueKey('payment-review'));
      expect(notice, findsOneWidget);
      expect(
        find.descendant(
          of: notice,
          matching: find.textContaining('Checkout charged KES 1,400'),
        ),
        findsOneWidget,
      );
    });
  });

  group('cancelling a paid order', () {
    testWidgets('explains the automatic refund and sends the reason', (
      tester,
    ) async {
      final backend = await _pump(tester, _paid());

      await tester.tap(find.text('Cancel and refund'));
      await tester.pumpAndSettle();
      final explanation = tester.widget<Text>(
        find.byKey(const ValueKey('cancel-order-explanation')),
      );
      expect(explanation.data, contains('KES 1500.00'));
      expect(explanation.data, contains('refunds it to them automatically'));

      await tester.enterText(
        find.byKey(const ValueKey('cancel-order-reason')),
        ' Out of stock ',
      );
      await tester.tap(find.byKey(const ValueKey('cancel-order-confirm')));
      await tester.pumpAndSettle();

      expect(backend.cancels.single.orderId, 'ord-1');
      expect(backend.cancels.single.reason, 'Out of stock');
      expect(
        find.text('Order cancelled. The buyer is being refunded.'),
        findsOneWidget,
      );
      expect(find.text('Refund pending'), findsOneWidget);
    });

    testWidgets('an unpaid order is cancelled without a refund', (
      tester,
    ) async {
      await _pump(
        tester,
        Order(
          id: 'ord-1',
          status: OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
          paymentStatus: PaymentStatus.PAYMENT_STATUS_PENDING,
          total: _kes(1500),
          amountPaid: _kes(0),
          balance: _kes(1500),
        ),
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel order'));
      await tester.pumpAndSettle();
      final explanation = tester.widget<Text>(
        find.byKey(const ValueKey('cancel-order-explanation')),
      );
      expect(explanation.data, isNot(contains('refund')));
    });

    testWidgets('the cancel dialog fits a phone', (tester) async {
      await _pump(tester, _paid(), size: const Size(360, 800));
      await tester.tap(find.text('Cancel and refund'));
      await tester.pumpAndSettle();
      expect(find.byType(CancelOrderDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('permissions', () {
    testWidgets('without order_manage the panel is read-only', (tester) async {
      await _pump(
        tester,
        Order(
          id: 'ord-1',
          status: OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
          paymentStatus: PaymentStatus.PAYMENT_STATUS_PENDING,
          total: _kes(1500),
          amountPaid: _kes(0),
          balance: _kes(1500),
        ),
        permissions: const {'order_view'},
      );
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Pay now'), findsNothing);
      expect(find.text('Record payment'), findsNothing);
      expect(find.text('Cancel order'), findsNothing);
    });
  });

  testWidgets('the order list shows cards on a phone', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final client = CommerceServiceClient(
      FakeTransportBuilder()
          .unary(
            CommerceService.listOrders,
            (req, _) => ListOrdersResponse(
              orders: [
                _paid()
                  ..paymentStatus = PaymentStatus.PAYMENT_STATUS_REFUND_PENDING
                  ..status = OrderStatus.ORDER_STATUS_CANCELLED,
              ],
            ),
          )
          .build(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderServiceClientProvider.overrideWithValue(client),
          userPermissionsProvider.overrideWith((ref) async => {'order_view'}),
        ],
        child: const MaterialApp(home: OrderListScreen(shopId: 'shop-1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.text('Refund pending'), findsOneWidget);
    // Without order_manage there is no way to start an order.
    expect(find.text('New Order'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('the refunded event has its own label', () {
    final (label, _, _) = orderEventStyle(
      OrderEventType.ORDER_EVENT_TYPE_REFUNDED,
    );
    expect(label, 'Refunded');
  });

  test('minor units format the refund amount exactly', () {
    expect(formatMinor(moneyToMinor(_kes(1500)), 'KES'), 'KES 1500.00');
  });
}
