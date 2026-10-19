import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/providers/order_providers.dart';
import 'package:antinvestor_ui_orders/src/providers/order_transport_provider.dart';
import 'package:antinvestor_ui_orders/src/utils/instalments.dart';
import 'package:antinvestor_ui_orders/src/widgets/order_payment_panel.dart';
import 'package:antinvestor_ui_orders/src/widgets/payment_status_badge.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';

Money _kes(int units) => Money(currencyCode: 'KES', units: Int64(units));

/// KES 1000 order with 400 paid by a recorded instalment and 600 owed,
/// under a 30% deposit / 20% instalment policy.
Order _partiallyPaid() => Order(
  id: 'ord-1',
  orderNumber: '1001',
  status: OrderStatus.ORDER_STATUS_CONFIRMED,
  paymentStatus: PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID,
  total: _kes(1000),
  amountPaid: _kes(400),
  balance: _kes(600),
  balanceDueAt: Timestamp.fromDateTime(
    DateTime.now().add(const Duration(days: 10)),
  ),
  paymentPolicy: PaymentPolicy(
    allowInstalments: true,
    minDepositPercent: 30,
    minInstalmentPercent: 20,
    balanceDueDays: 14,
  ),
  payments: [
    OrderPayment(
      id: 'pay-1',
      amount: _kes(400),
      source: OrderPaymentSource.ORDER_PAYMENT_SOURCE_RECORDED,
      reference: 'RCPT-77',
      recordedBy: 'staff-9',
      note: 'Deposit at the counter',
      paidAt: Timestamp.fromDateTime(DateTime.utc(2026, 9, 20, 10)),
    ),
  ],
);

class _FakeOrders {
  _FakeOrders(this.order);

  Order order;
  CheckoutOrderRequest? lastCheckout;
  RecordOrderPaymentRequest? lastRecord;
  Object? recordError;

  CommerceServiceClient client() => CommerceServiceClient(
    FakeTransportBuilder()
        .unary(
          CommerceService.getOrder,
          (req, _) => GetOrderResponse(order: order),
        )
        .unary(
          CommerceService.listOrderEvents,
          (req, _) => ListOrderEventsResponse(),
        )
        .unary(CommerceService.checkoutOrder, (req, _) {
          lastCheckout = req;
          order = order.deepCopy()
            ..paymentSessionRef = 'sess-2'
            ..checkoutUrl = 'https://pay.example/sess-2';
          return CheckoutOrderResponse(
            order: order,
            checkoutUrl: order.checkoutUrl,
            amount: req.hasAmount() ? req.amount : order.balance,
          );
        })
        .unary(CommerceService.recordOrderPayment, (req, _) {
          lastRecord = req;
          final error = recordError;
          if (error != null) throw error;
          order = order.deepCopy()
            ..paymentStatus = PaymentStatus.PAYMENT_STATUS_PAID
            ..amountPaid = _kes(1000)
            ..balance = _kes(0);
          return RecordOrderPaymentResponse(order: order);
        })
        .build(),
  );
}

class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider('ord-1'));
    return order.when(
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
}

Future<void> _pump(WidgetTester tester, _FakeOrders backend) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderServiceClientProvider.overrideWithValue(backend.client()),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: _Harness())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _rowText(WidgetTester tester, String key) => tester
    .widgetList<SelectableText>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(SelectableText),
      ),
    )
    .single
    .data!;

void main() {
  testWidgets('shows paid, balance, progress, deadline, terms and payments', (
    tester,
  ) async {
    await _pump(tester, _FakeOrders(_partiallyPaid()));

    expect(find.text('Partially paid'), findsOneWidget);
    expect(_rowText(tester, 'payment-amount-paid'), 'KES 400.00');
    expect(_rowText(tester, 'payment-balance'), 'KES 600.00');
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('payment-progress')),
          )
          .value,
      closeTo(0.4, 1e-9),
    );
    expect(find.text('40% paid'), findsOneWidget);
    expect(find.text('Balance due by'), findsOneWidget);
    expect(find.textContaining('Instalments allowed'), findsOneWidget);

    // The recorded instalment.
    expect(find.text('Payments (1)'), findsOneWidget);
    expect(find.text('Recorded'), findsOneWidget);
    expect(find.textContaining('Ref RCPT-77'), findsOneWidget);
    expect(find.textContaining('by staff-9'), findsOneWidget);
    expect(find.text('Deposit at the counter'), findsOneWidget);

    // Money is owed, so paying and recording are offered.
    expect(find.text('Pay instalment'), findsOneWidget);
    expect(find.text('Record payment'), findsOneWidget);
  });

  testWidgets('instalment below the policy minimum is rejected client-side', (
    tester,
  ) async {
    final backend = _FakeOrders(_partiallyPaid());
    await _pump(tester, backend);

    await tester.tap(find.text('Pay instalment'));
    await tester.pumpAndSettle();
    // Pre-filled with the minimum instalment: 20% of 1000.
    expect(find.widgetWithText(TextFormField, '200.00'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('instalment-amount')),
      '150',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('instalment must be at least 20%'),
      findsOneWidget,
    );
    expect(backend.lastCheckout, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('instalment-amount')),
      '700',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cannot exceed the balance'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('instalment-amount')),
      '250.50',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final sent = backend.lastCheckout!;
    expect(sent.hasAmount(), isTrue);
    expect(moneyToMinor(sent.amount), 25050);
    expect(sent.amount.currencyCode, 'KES');
  });

  testWidgets('paying the whole balance sends no amount', (tester) async {
    final backend = _FakeOrders(_partiallyPaid());
    await _pump(tester, backend);

    await tester.tap(find.text('Pay instalment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Whole balance'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(backend.lastCheckout, isNotNull);
    expect(backend.lastCheckout!.hasAmount(), isFalse);
  });

  testWidgets('record payment requires a reference and shows backend errors', (
    tester,
  ) async {
    final backend = _FakeOrders(_partiallyPaid())
      ..recordError = ConnectException(
        Code.failedPrecondition,
        'order is cancelled',
      );
    await _pump(tester, backend);

    await tester.tap(find.text('Record payment'));
    await tester.pumpAndSettle();
    // Pre-filled with the balance.
    expect(find.widgetWithText(TextFormField, '600.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Record payment'));
    await tester.pumpAndSettle();
    expect(find.text('Reference is required'), findsOneWidget);
    expect(backend.lastRecord, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('record-reference')),
      'RCPT-78',
    );
    await tester.enterText(find.byKey(const ValueKey('record-note')), 'Cash');
    await tester.tap(find.widgetWithText(FilledButton, 'Record payment'));
    await tester.pumpAndSettle();

    expect(backend.lastRecord!.reference, 'RCPT-78');
    expect(backend.lastRecord!.note, 'Cash');
    expect(moneyToMinor(backend.lastRecord!.amount), 60000);
    expect(find.text('order is cancelled'), findsOneWidget);

    backend.recordError = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Record payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment recorded.'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
  });
}
