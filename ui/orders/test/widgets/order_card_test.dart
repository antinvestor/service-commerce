import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/widgets/order_card.dart';
import 'package:antinvestor_ui_orders/src/widgets/order_status_badge.dart';
import 'package:antinvestor_ui_orders/src/widgets/payment_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderCard', () {
    late Order order;

    setUp(() {
      order = Order(
        id: 'ord-123',
        orderNumber: '1001',
        status: OrderStatus.ORDER_STATUS_CONFIRMED,
        paymentStatus: PaymentStatus.PAYMENT_STATUS_PENDING,
      );
    });

    Widget buildTestWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: OrderCard(
            order: order,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders order number', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('#1001'), findsOneWidget);
    });

    testWidgets('renders order status badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(OrderStatusBadge), findsOneWidget);
    });

    testWidgets('renders payment status badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(PaymentStatusBadge), findsOneWidget);
    });

    testWidgets('invokes onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(OrderCard));
      expect(tapped, isTrue);
    });

    testWidgets('falls back to ID when order number is empty',
        (tester) async {
      order = Order(
        id: 'ord-456',
        status: OrderStatus.ORDER_STATUS_CONFIRMED,
        paymentStatus: PaymentStatus.PAYMENT_STATUS_PAID,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OrderCard(order: order),
        ),
      ));
      expect(find.text('ord-456'), findsOneWidget);
    });

    testWidgets('uses Card with elevation 0 and border radius 12',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      final shape = card.shape as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        BorderRadius.circular(12),
      );
    });
  });
}
