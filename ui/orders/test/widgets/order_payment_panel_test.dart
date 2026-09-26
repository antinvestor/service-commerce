import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/providers/order_providers.dart';
import 'package:antinvestor_ui_orders/src/providers/order_transport_provider.dart';
import 'package:antinvestor_ui_orders/src/widgets/order_payment_panel.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';

const _checkStatus = "I've paid — check status";

/// In-memory stand-in for the commerce order RPCs the panel uses.
class _FakeOrders {
  _FakeOrders(this.order);

  Order order;
  int getOrderCalls = 0;
  int confirmCalls = 0;
  Object? confirmError;

  CommerceServiceClient client() => CommerceServiceClient(
        FakeTransportBuilder()
            .unary(CommerceService.getOrder, (req, _) {
              getOrderCalls++;
              return GetOrderResponse(order: order);
            })
            .unary(CommerceService.checkoutOrder, (req, _) {
              order = order.deepCopy()
                ..paymentSessionRef = 'sess-1'
                ..checkoutUrl = 'https://pay.example/sess-1';
              return CheckoutOrderResponse(
                checkoutUrl: order.checkoutUrl,
                order: order,
              );
            })
            .unary(CommerceService.confirmOrderPayment, (req, _) {
              confirmCalls++;
              final error = confirmError;
              if (error != null) throw error;
              order = order.deepCopy()
                ..status = OrderStatus.ORDER_STATUS_CONFIRMED
                ..paymentStatus = PaymentStatus.PAYMENT_STATUS_PAID;
              return ConfirmOrderPaymentResponse(order: order);
            })
            .build(),
      );
}

/// Renders the panel for the order loaded through [orderByIdProvider], as
/// the order detail screen does.
class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider('ord-1'));
    return order.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('error: $e'),
      data: (order) => OrderPaymentPanel(order: order),
    );
  }
}

Future<void> _pump(WidgetTester tester, _FakeOrders backend) async {
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

Order _pendingOrder({String sessionRef = 'sess-1'}) => Order(
      id: 'ord-1',
      status: OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
      paymentStatus: PaymentStatus.PAYMENT_STATUS_PENDING,
      paymentSessionRef: sessionRef,
      checkoutUrl: sessionRef.isEmpty ? '' : 'https://pay.example/$sessionRef',
    );

void main() {
  testWidgets('check status explains an unfinished payment without an error',
      (tester) async {
    final backend = _FakeOrders(_pendingOrder())
      ..confirmError = ConnectException(
        Code.failedPrecondition,
        'checkout session is open, not completed',
      );
    await _pump(tester, backend);

    await tester.tap(find.text(_checkStatus));
    await tester.pumpAndSettle();

    expect(backend.confirmCalls, 1);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, isNull);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(kPaymentNotCompletedMessage),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('payment-status-note'))).data,
      kPaymentNotCompletedMessage,
    );
    // Still awaiting payment: the operator can check again.
    expect(find.text(_checkStatus), findsOneWidget);
  });

  testWidgets('check status confirms a completed payment', (tester) async {
    final backend = _FakeOrders(_pendingOrder());
    await _pump(tester, backend);

    await tester.tap(find.text(_checkStatus));
    await tester.pumpAndSettle();

    expect(find.text('Payment confirmed.'), findsOneWidget);
    // The reloaded order is no longer awaiting payment.
    expect(find.text(_checkStatus), findsNothing);
  });

  testWidgets('other failures are reported as errors', (tester) async {
    final backend = _FakeOrders(_pendingOrder())
      ..confirmError = ConnectException(Code.unavailable, 'payment down');
    await _pump(tester, backend);

    await tester.tap(find.text(_checkStatus));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, isNotNull);
  });

  testWidgets('opening the payment page offers the status check',
      (tester) async {
    final backend = _FakeOrders(_pendingOrder(sessionRef: ''));
    await _pump(tester, backend);
    expect(find.text(_checkStatus), findsNothing);

    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();

    expect(find.text(_checkStatus), findsOneWidget);
    expect(find.text('Open payment page'), findsOneWidget);
  });

  testWidgets('reloads the order when the app regains focus', (tester) async {
    final backend = _FakeOrders(_pendingOrder());
    await _pump(tester, backend);
    final before = backend.getOrderCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(backend.getOrderCalls, before + 1);
  });

  testWidgets('does not reload a settled order on focus', (tester) async {
    final backend = _FakeOrders(Order(
      id: 'ord-1',
      status: OrderStatus.ORDER_STATUS_CONFIRMED,
      paymentStatus: PaymentStatus.PAYMENT_STATUS_PAID,
    ));
    await _pump(tester, backend);
    final before = backend.getOrderCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(backend.getOrderCalls, before);
  });
}
