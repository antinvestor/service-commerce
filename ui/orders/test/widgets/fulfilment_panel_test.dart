import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/providers/order_transport_provider.dart';
import 'package:antinvestor_ui_orders/src/widgets/fulfilment_panel.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';

void main() {
  test('fulfilment status only moves forward or to cancelled', () {
    expect(nextFulfilmentStatuses(FulfilmentStatus.FULFILMENT_STATUS_PACKED), [
      FulfilmentStatus.FULFILMENT_STATUS_SHIPPED,
      FulfilmentStatus.FULFILMENT_STATUS_DELIVERED,
      FulfilmentStatus.FULFILMENT_STATUS_CANCELLED,
    ]);
    expect(
      nextFulfilmentStatuses(FulfilmentStatus.FULFILMENT_STATUS_DELIVERED),
      isEmpty,
    );
    expect(
      nextFulfilmentStatuses(FulfilmentStatus.FULFILMENT_STATUS_CANCELLED),
      isEmpty,
    );
  });

  testWidgets('lists fulfilments and updates only the changed fields', (
    tester,
  ) async {
    var fulfilment = Fulfilment(
      id: 'ful-1',
      orderId: 'ord-1',
      status: FulfilmentStatus.FULFILMENT_STATUS_PACKED,
      carrier: 'G4S',
    );
    UpdateFulfilmentRequest? sent;
    final client = CommerceServiceClient(
      FakeTransportBuilder()
          .unary(
            CommerceService.listFulfilments,
            (req, _) => ListFulfilmentsResponse(fulfilments: [fulfilment]),
          )
          .unary(CommerceService.updateFulfilment, (req, _) {
            sent = req;
            fulfilment = fulfilment.deepCopy()
              ..status = req.status
              ..trackingNumber = req.trackingNumber;
            return UpdateFulfilmentResponse(fulfilment: fulfilment);
          })
          .unary(
            CommerceService.getOrder,
            (req, _) => GetOrderResponse(order: Order(id: 'ord-1')),
          )
          .build(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [orderServiceClientProvider.overrideWithValue(client)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderFulfilmentsPanel(orderId: 'ord-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ful-1'), findsOneWidget);
    expect(find.text('Packed'), findsOneWidget);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fulfilment-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shipped').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('fulfilment-tracking')),
      'TRK-1',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sent!.id, 'ful-1');
    expect(sent!.updateMask.paths, ['status', 'tracking_number']);
    expect(sent!.status, FulfilmentStatus.FULFILMENT_STATUS_SHIPPED);
    expect(sent!.trackingNumber, 'TRK-1');
    // The list reloads with the new status.
    expect(find.text('Shipped'), findsOneWidget);
  });
}
