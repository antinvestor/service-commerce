import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
// Money is not re-exported by the procurement barrel.
// ignore: implementation_imports
import 'package:antinvestor_api_procurement/src/common/v1/money.pb.dart'
    show Money;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Records mutation requests instead of calling the procurement service.
class RecordingNotifier extends ProcurementNotifier {
  RecordingNotifier(this.log);

  final List<Object> log;

  @override
  Future<PurchaseOrder> createPO(PurchaseOrderCreateRequest request) async {
    log.add(request);
    return PurchaseOrder()
      ..id = 'po-new'
      ..status = PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT;
  }

  @override
  Future<PurchaseOrder> cancelPO(PurchaseOrderCancelRequest request) async {
    log.add(request);
    return PurchaseOrder()..id = request.id;
  }

  @override
  Future<PurchaseOrder> submitPO(PurchaseOrderSubmitRequest request) async {
    log.add(request);
    return PurchaseOrder()..id = request.id;
  }

  @override
  Future<GoodsReceipt> createGoodsReceipt(
    GoodsReceiptCreateRequest request,
  ) async {
    log.add(request);
    return GoodsReceipt()..id = 'gr-new';
  }
}

final _supplier = Supplier()
  ..id = 'sup-1'
  ..name = 'Acme Mills'
  ..status = SupplierStatus.SUPPLIER_STATUS_ACTIVE
  ..supplierType = SupplierType.SUPPLIER_TYPE_RAW_MATERIAL;

final _supplierItem = SupplierItem()
  ..id = 'si-1'
  ..supplierId = 'sup-1'
  ..inventoryItemId = 'inv-flour'
  ..supplierSku = 'FLOUR-25'
  ..unit = 'bag'
  ..status = SupplierItemStatus.SUPPLIER_ITEM_STATUS_ACTIVE;

PurchaseOrder _order({
  PurchaseOrderStatus status =
      PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED,
}) => PurchaseOrder()
  ..id = 'po-1'
  ..orderNumber = '1001'
  ..propertyId = 'prop-9'
  ..supplierId = 'sup-1'
  ..status = status
  ..lines.add(
    PurchaseOrderLine()
      ..id = 'line-1'
      ..supplierItemId = 'si-1'
      ..inventoryItemId = 'inv-flour'
      ..orderedQuantity = 10
      ..receivedQuantity = 4
      ..unit = 'bag'
      ..status =
          PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED,
  );

final _receipt = GoodsReceipt()
  ..id = 'gr-1'
  ..purchaseOrderId = 'po-1'
  ..status = GoodsReceiptStatus.GOODS_RECEIPT_STATUS_ACCEPTED
  ..lines.add(
    GoodsReceiptLine()
      ..id = 'grl-1'
      ..inventoryItemId = 'inv-flour'
      ..receivedQuantity = 4
      ..acceptedQuantity = 4
      ..lotNumber = 'LOT-7',
  );

final _suggestions = [
  PurchaseOrderSuggestion()
    ..supplierId = 'sup-1'
    ..supplierName = 'Acme Mills'
    ..estimatedTotal = (Money()
      ..currencyCode = 'KES'
      ..units = Int64(1200))
    ..lines.add(
      PurchaseOrderSuggestionLine()
        ..inventoryItemId = 'inv-flour'
        ..itemName = 'Flour'
        ..shortageQuantity = 4
        ..unit = 'bag'
        ..supplierItemId = 'si-1'
        ..unitPrice = (Money()
          ..currencyCode = 'KES'
          ..units = Int64(300)),
    ),
  PurchaseOrderSuggestion()
    ..lines.add(
      PurchaseOrderSuggestionLine()
        ..inventoryItemId = 'inv-cultures'
        ..itemName = 'Cultures'
        ..shortageQuantity = 2
        ..unit = 'kg',
    ),
];

class _Harness {
  _Harness({required String initialLocation, PurchaseOrder? order})
    : order = order ?? _order() {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: ProcurementRouteModule(propertyId: 'prop-9').buildRoutes(),
    );
  }

  final PurchaseOrder order;
  final List<Object> log = [];
  final List<SupplierFilter> supplierQueries = [];
  final List<({String? propertyId, String? purchaseOrderId})> receiptQueries =
      [];
  final List<SuggestionQuery> suggestionQueries = [];
  late final GoRouter router;

  Widget build() => ProviderScope(
    overrides: [
      procurementNotifierProvider.overrideWith(() => RecordingNotifier(log)),
      supplierListProvider.overrideWith((ref, filter) {
        supplierQueries.add(filter);
        return [_supplier];
      }),
      supplierByIdProvider.overrideWith((ref, id) => _supplier),
      supplierItemListProvider.overrideWith((ref, id) => [_supplierItem]),
      purchaseOrderListProvider.overrideWith((ref, id) => [order]),
      purchaseOrderByIdProvider.overrideWith((ref, id) => order),
      goodsReceiptListProvider.overrideWith((ref, params) {
        receiptQueries.add(params);
        return [_receipt];
      }),
      goodsReceiptByIdProvider.overrideWith((ref, id) => _receipt),
      purchaseOrderSuggestionsProvider.overrideWith((ref, query) {
        suggestionQueries.add(query);
        return _suggestions;
      }),
    ],
    child: MaterialApp.router(routerConfig: router),
  );

  String get location => router.routeInformationProvider.value.uri.path;
}

Future<_Harness> _pump(
  WidgetTester tester,
  String location, {
  PurchaseOrder? order,
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final harness = _Harness(initialLocation: location, order: order);
  await tester.pumpWidget(harness.build());
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  group('purchase order suggestions', () {
    test('a suggestion becomes a plan-linked draft order', () {
      final request = suggestionToRequest(
        _suggestions.first,
        propertyId: 'prop-9',
        planId: 'plan-1',
        idempotencyKey: 'k-1',
      );
      expect(request.supplierId, 'sup-1');
      expect(request.planId, 'plan-1');
      expect(request.propertyId, 'prop-9');
      expect(request.idempotencyKey, 'k-1');
      expect(request.lines.single.supplierItemId, 'si-1');
      expect(request.lines.single.orderedQuantity, 4);
      expect(request.lines.single.unit, 'bag');
    });

    testWidgets('lists suggestions for a plan and creates the order', (
      tester,
    ) async {
      final h = await _pump(tester, ProcurementPaths.suggestions);
      await tester.enterText(
        find.byKey(const Key('suggestion_plan_id')),
        'plan-1',
      );
      await tester.tap(find.byKey(const Key('suggestion_submit')));
      await tester.pumpAndSettle();

      expect(h.suggestionQueries.single, (
        propertyId: 'prop-9',
        planId: 'plan-1',
      ));
      expect(find.text('Acme Mills'), findsOneWidget);
      expect(find.text('No supplier yet'), findsOneWidget);
      expect(find.text('Cultures'), findsOneWidget);

      await tester.tap(find.byKey(const Key('suggestion_create_sup-1')));
      await tester.pumpAndSettle();

      final created = h.log.single as PurchaseOrderCreateRequest;
      expect(created.planId, 'plan-1');
      expect(created.supplierId, 'sup-1');
      expect(created.idempotencyKey, isNotEmpty);
      expect(h.location, ProcurementPaths.order('po-new'));
    });

    testWidgets('the home screen links to suggestions', (tester) async {
      final h = await _pump(tester, ProcurementPaths.root);
      await tester.tap(find.byKey(const Key('procurement_home_suggestions')));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.suggestions);
    });
  });

  group('procurement home', () {
    testWidgets('shows counts and links to suppliers and orders', (
      tester,
    ) async {
      final h = await _pump(tester, ProcurementPaths.root);
      expect(find.text('Procurement'), findsOneWidget);
      expect(find.text('1 open'), findsOneWidget);

      await tester.tap(find.byKey(const Key('procurement_home_orders')));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.orders);
      expect(find.text('PO #1001'), findsOneWidget);

      await tester.tap(find.text('PO #1001'));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.order('po-1'));
    });
  });

  group('supplier list', () {
    testWidgets('type and status filters are sent to SupplierSearch', (
      tester,
    ) async {
      final h = await _pump(tester, ProcurementPaths.suppliers);
      expect(h.supplierQueries.last, allSuppliers);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Packaging'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Suspended'));
      await tester.pumpAndSettle();
      expect(h.supplierQueries.last, (
        type: SupplierType.SUPPLIER_TYPE_PACKAGING,
        status: SupplierStatus.SUPPLIER_STATUS_SUSPENDED,
      ));

      await tester.tap(find.text('Acme Mills'));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.supplier('sup-1'));
    });
  });

  group('purchase order detail', () {
    testWidgets('shows lines, receipts and links to a receipt', (tester) async {
      final h = await _pump(tester, ProcurementPaths.order('po-1'));
      expect(find.text('PO #1001'), findsOneWidget);
      expect(
        find.textContaining('Ordered: 10.0 bag | Received: 4.0'),
        findsOneWidget,
      );
      expect(find.text('Receive goods'), findsOneWidget);
      expect(h.receiptQueries.last, (
        propertyId: null,
        purchaseOrderId: 'po-1',
      ));

      await tester.tap(find.text('GR gr-1'));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.receipt('gr-1'));
      expect(find.text('Goods Receipt'), findsOneWidget);
      expect(find.textContaining('Lot: LOT-7'), findsOneWidget);
    });

    testWidgets('receive goods opens the receipt wizard', (tester) async {
      final h = await _pump(tester, ProcurementPaths.order('po-1'));
      await tester.tap(find.text('Receive goods'));
      await tester.pumpAndSettle();
      expect(h.location, ProcurementPaths.receiveOrder('po-1'));
      expect(find.text('Receive Goods'), findsOneWidget);
    });

    testWidgets('cancel requires a reason and sends it', (tester) async {
      final h = await _pump(tester, ProcurementPaths.order('po-1'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      final confirm = find.widgetWithText(ElevatedButton, 'Cancel PO');
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('cancel_po_reason')),
        '  Supplier out of stock ',
      );
      await tester.pump();
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      final request = h.log.whereType<PurchaseOrderCancelRequest>().single;
      expect(request.id, 'po-1');
      expect(request.reason, 'Supplier out of stock');
    });

    testWidgets('draft orders offer submit but not receive', (tester) async {
      final h = await _pump(
        tester,
        ProcurementPaths.order('po-1'),
        order: _order(status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT),
      );
      expect(find.text('Receive goods'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();
      expect(h.log.whereType<PurchaseOrderSubmitRequest>().single.id, 'po-1');
    });
  });

  group('purchase order wizard', () {
    testWidgets(
      'sends idempotency key, delivery date and supplier item per line',
      (tester) async {
        final h = await _pump(tester, ProcurementPaths.newOrder);

        await tester.tap(find.text('Acme Mills'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<SupplierItem>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('FLOUR-25 (inv-flour)').last);
        await tester.pumpAndSettle();
        await tester.enterText(find.widgetWithText(TextField, 'Qty'), '3');
        await tester.tap(find.byTooltip('Add line'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create PO'));
        await tester.pumpAndSettle();

        final request = h.log.whereType<PurchaseOrderCreateRequest>().single;
        expect(request.idempotencyKey, isNotEmpty);
        expect(request.propertyId, 'prop-9');
        expect(request.supplierId, 'sup-1');
        expect(request.hasExpectedDeliveryDate(), isTrue);
        expect(request.lines, hasLength(1));
        expect(request.lines.single.supplierItemId, 'si-1');
        expect(request.lines.single.inventoryItemId, 'inv-flour');
        expect(request.lines.single.orderedQuantity, 3);
        expect(request.lines.single.unit, 'bag');
        // Lands on the new order's detail page.
        expect(h.location, ProcurementPaths.order('po-new'));
      },
    );
  });

  group('goods receipt wizard', () {
    testWidgets('sends property, idempotency key and lot', (tester) async {
      final h = await _pump(tester, ProcurementPaths.receiveOrder('po-1'));

      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '6');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Lot Number'),
        'LOT-8',
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Receipt'));
      await tester.pumpAndSettle();

      final request = h.log.whereType<GoodsReceiptCreateRequest>().single;
      expect(request.idempotencyKey, isNotEmpty);
      expect(request.purchaseOrderId, 'po-1');
      expect(request.propertyId, 'prop-9');
      expect(request.lines.single.purchaseOrderLineId, 'line-1');
      expect(request.lines.single.receivedQuantity, 6);
      expect(request.lines.single.lotNumber, 'LOT-8');
      expect(h.location, ProcurementPaths.order('po-1'));
    });
  });

  group('idempotency keys', () {
    test('are v4 UUIDs and unique', () {
      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      final keys = List.generate(200, (_) => newIdempotencyKey());
      for (final k in keys) {
        expect(k, matches(uuid));
      }
      expect(keys.toSet(), hasLength(keys.length));
    });
  });
}
