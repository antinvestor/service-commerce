import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
// Money is not re-exported by the procurement barrel.
// ignore: implementation_imports
import 'package:antinvestor_api_procurement/src/common/v1/money.pb.dart'
    show Money;
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
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
  Future<PurchaseOrder> closePO(PurchaseOrderCloseRequest request) async {
    log.add(request);
    return PurchaseOrder()..id = request.id;
  }

  @override
  Future<SupplierItem> saveSupplierItem(SupplierItemSaveRequest request) async {
    log.add(request);
    return SupplierItem()..id = 'si-new';
  }

  @override
  Future<GoodsReceipt> createGoodsReceipt(
    GoodsReceiptCreateRequest request,
  ) async {
    log.add(request);
    return GoodsReceipt()..id = 'gr-new';
  }

  @override
  Future<GoodsReceipt> resolveGoodsReceiptLine(
    GoodsReceiptLineResolveRequest request,
  ) async {
    log.add(request);
    final booked =
        request.resolution ==
        GoodsReceiptLineResolution
            .GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY;
    return GoodsReceipt()
      ..id = request.goodsReceiptId
      ..lines.add(
        GoodsReceiptLine()
          ..id = request.lineId
          ..deliveryStatus = booked
              ? StockDeliveryStatus.STOCK_DELIVERY_STATUS_RESOLVED
              : StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED,
      );
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

/// Every procurement permission, as an owner holds them.
const _allPermissions = {
  'supplier_view',
  'supplier_manage',
  'purchase_order_view',
  'purchase_order_create',
  'purchase_order_submit',
  'purchase_order_cancel',
  'goods_receipt_view',
  'goods_receipt_create',
  'goods_receipt_resolve',
};

/// Answers the paged searches from the harness's fixtures, recording the
/// requests. [pages] splits purchase orders into pages of that many.
class _FakeApi implements ProcurementApi {
  _FakeApi(this.h);

  final _Harness h;

  @override
  Future<SupplierSearchResponse> supplierSearch(
    SupplierSearchRequest request,
  ) async {
    h.supplierQueries.add((
      type: request.supplierType == SupplierType.SUPPLIER_TYPE_UNSPECIFIED
          ? null
          : request.supplierType,
      status: request.status == SupplierStatus.SUPPLIER_STATUS_UNSPECIFIED
          ? null
          : request.status,
    ));
    return SupplierSearchResponse(suppliers: [_supplier]);
  }

  @override
  Future<SupplierItemSearchResponse> supplierItemSearch(
    SupplierItemSearchRequest request,
  ) async => SupplierItemSearchResponse(supplierItems: h.supplierItems);

  @override
  Future<PurchaseOrderSearchResponse> purchaseOrderSearch(
    PurchaseOrderSearchRequest request,
  ) async {
    h.orderQueries.add(request);
    final all = h.orders;
    final start = request.search.cursor.page.isEmpty
        ? 0
        : int.parse(request.search.cursor.page);
    final end = h.pageSize == null
        ? all.length
        : (start + h.pageSize!).clamp(0, all.length);
    return PurchaseOrderSearchResponse(
      purchaseOrders: all.sublist(start, end),
      nextPage: end < all.length ? '$end' : '',
    );
  }

  @override
  Future<GoodsReceiptSearchResponse> goodsReceiptSearch(
    GoodsReceiptSearchRequest request,
  ) async {
    h.receiptQueries.add(request.purchaseOrderId);
    return GoodsReceiptSearchResponse(goodsReceipts: [h.receipt]);
  }
}

class _Harness {
  _Harness({
    required String initialLocation,
    PurchaseOrder? order,
    GoodsReceipt? receipt,
    List<PurchaseOrder>? orders,
    List<SupplierItem>? supplierItems,
    this.pageSize,
    this.permissions = _allPermissions,
    this.pickers = const SupplyPickers(),
  }) : order = order ?? _order(),
       receipt = receipt ?? _receipt,
       supplierItems = supplierItems ?? [_supplierItem] {
    this.orders = orders ?? [this.order];
    router = GoRouter(
      initialLocation: initialLocation,
      routes: ProcurementRouteModule(propertyId: 'prop-9').buildRoutes(),
    );
  }

  final PurchaseOrder order;
  final GoodsReceipt receipt;
  late final List<PurchaseOrder> orders;
  final List<SupplierItem> supplierItems;
  final int? pageSize;
  final Set<String> permissions;
  final SupplyPickers pickers;
  final List<Object> log = [];
  final List<SupplierFilter> supplierQueries = [];
  final List<PurchaseOrderSearchRequest> orderQueries = [];
  final List<String> receiptQueries = [];
  final List<SuggestionQuery> suggestionQueries = [];
  late final GoRouter router;

  Widget build() => ProviderScope(
    overrides: [
      procurementNotifierProvider.overrideWith(() => RecordingNotifier(log)),
      procurementApiProvider.overrideWithValue(_FakeApi(this)),
      userPermissionsProvider.overrideWith((ref) async => permissions),
      supplyPickersProvider.overrideWithValue(pickers),
      supplierListProvider.overrideWith((ref, filter) {
        supplierQueries.add(filter);
        return [_supplier];
      }),
      supplierByIdProvider.overrideWith((ref, id) => _supplier),
      supplierItemListProvider.overrideWith((ref, id) => supplierItems),
      purchaseOrderListProvider.overrideWith((ref, id) => orders),
      purchaseOrderByIdProvider.overrideWith((ref, id) => order),
      goodsReceiptByIdProvider.overrideWith((ref, id) => receipt),
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
  GoodsReceipt? receipt,
  List<PurchaseOrder>? orders,
  List<SupplierItem>? supplierItems,
  int? pageSize,
  Set<String> permissions = _allPermissions,
  SupplyPickers pickers = const SupplyPickers(),
  Size size = const Size(1400, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final harness = _Harness(
    initialLocation: location,
    order: order,
    receipt: receipt,
    orders: orders,
    supplierItems: supplierItems,
    pageSize: pageSize,
    permissions: permissions,
    pickers: pickers,
  );
  await tester.pumpWidget(harness.build());
  await tester.pumpAndSettle();
  return harness;
}

/// A stock location picker that always picks the main store.
final _locationPicker = SupplyPickers(
  stockLocation: (context, onPicked) => TextButton(
    onPressed: () =>
        onPicked(const SupplyChoice(id: 'loc-main', label: 'Main store')),
    child: const Text('Pick location'),
  ),
);

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
        currencyCode: '',
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
      expect(h.receiptQueries.last, 'po-1');

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
      // Lands on the receipt, which shows where each line's stock went.
      expect(h.location, ProcurementPaths.receipt('gr-new'));
      // Without a location picker raw materials wait for one.
      expect(request.stockLocationId, isEmpty);
    });

    testWidgets('raw materials are put away where staff choose', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        ProcurementPaths.receiveOrder('po-1'),
        pickers: _locationPicker,
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '6');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('receipt_location_picker')), findsOneWidget);
      await tester.tap(find.text('Pick location'));
      await tester.pumpAndSettle();
      expect(find.text('Booked into Main store.'), findsOneWidget);
      await tester.tap(find.text('Create Receipt'));
      await tester.pumpAndSettle();

      final request = h.log.whereType<GoodsReceiptCreateRequest>().single;
      expect(request.stockLocationId, 'loc-main');
    });
  });

  group('closing short and cancelling', () {
    final partial = _order(
      status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
    );

    testWidgets('a partially received order is closed short with a reason', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        ProcurementPaths.order('po-1'),
        order: partial,
      );
      expect(find.text('Partial'), findsWidgets);
      // Receipts are on it, so it can no longer be cancelled.
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);

      await tester.tap(find.byKey(const Key('po_close_short')));
      await tester.pumpAndSettle();
      expect(find.textContaining('No longer expected: 6 bag'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('close_po_reason')),
        ' Supplier discontinued it ',
      );
      await tester.tap(find.byKey(const Key('close_po_confirm')));
      await tester.pumpAndSettle();

      final request = h.log.whereType<PurchaseOrderCloseRequest>().single;
      expect(request.id, 'po-1');
      expect(request.reason, 'Supplier discontinued it');
    });

    testWidgets('a closed order shows as closed and offers no actions', (
      tester,
    ) async {
      final closed = _order(
        status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CLOSED,
      );
      closed.lines.first.status =
          PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CLOSED;
      await _pump(tester, ProcurementPaths.order('po-1'), order: closed);

      expect(find.text('Closed short'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Receive goods'), findsNothing);
      expect(find.byKey(const Key('po_close_short')), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
    });

    test('cancel and close follow the order status', () {
      expect(canCancelPO(_order()), isTrue);
      expect(canCancelPO(partial), isFalse);
      expect(canClosePO(partial), isTrue);
      expect(canClosePO(_order()), isFalse);
      expect(
        canReceivePO(
          _order(status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CLOSED),
        ),
        isFalse,
      );
    });
  });

  group('permissions', () {
    const viewer = {
      'supplier_view',
      'purchase_order_view',
      'goods_receipt_view',
    };

    testWidgets('a viewer sees the order but none of its actions', (
      tester,
    ) async {
      await _pump(
        tester,
        ProcurementPaths.order('po-1'),
        order: _order(
          status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
        ),
        permissions: viewer,
      );
      expect(find.text('PO #1001'), findsOneWidget);
      expect(find.text('Receive goods'), findsNothing);
      expect(find.byKey(const Key('po_close_short')), findsNothing);
    });

    testWidgets('an operator receives goods but cannot close short', (
      tester,
    ) async {
      await _pump(
        tester,
        ProcurementPaths.order('po-1'),
        order: _order(
          status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
        ),
        permissions: {
          ...viewer,
          'goods_receipt_create',
          'purchase_order_create',
        },
      );
      expect(find.text('Receive goods'), findsOneWidget);
      expect(find.byKey(const Key('po_close_short')), findsNothing);
    });

    testWidgets('a viewer cannot add suppliers, items or orders', (
      tester,
    ) async {
      await _pump(tester, ProcurementPaths.orders, permissions: viewer);
      expect(find.text('New PO'), findsNothing);

      await _pump(
        tester,
        ProcurementPaths.supplier('sup-1'),
        permissions: viewer,
      );
      expect(find.byKey(const Key('supplier_add_item')), findsNothing);
      expect(find.byTooltip('Edit supplier'), findsNothing);
    });
  });

  group('goods receipt delivery', () {
    GoodsReceiptLine line(
      String id,
      SupplyKind kind,
      StockDeliveryStatus status, {
      String note = '',
    }) => GoodsReceiptLine()
      ..id = id
      ..supplyKind = kind
      ..inventoryItemId = kind == SupplyKind.SUPPLY_KIND_MATERIAL
          ? 'inv-$id'
          : ''
      ..productVariantId = kind == SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT
          ? 'var-$id'
          : ''
      ..receivedQuantity = 1
      ..acceptedQuantity = 1
      ..deliveryStatus = status
      ..deliveryNote = note;

    final mixed = GoodsReceipt()
      ..id = 'gr-1'
      ..purchaseOrderId = 'po-1'
      ..status = GoodsReceiptStatus.GOODS_RECEIPT_STATUS_ACCEPTED
      ..lines.addAll([
        line(
          'a',
          SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT,
          StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED,
        ),
        line(
          'b',
          SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT,
          StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING,
          note: 'commerce unavailable (2 attempts)',
        ),
        line(
          'c',
          SupplyKind.SUPPLY_KIND_MATERIAL,
          StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING_TRANSFER,
        ),
        line(
          'd',
          SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT,
          StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED,
          note: 'variant belongs to another tenant',
        ),
      ]);

    testWidgets('each line shows where its stock is and what to do', (
      tester,
    ) async {
      await _pump(tester, ProcurementPaths.receipt('gr-1'), receipt: mixed);

      expect(find.text('In stock'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Needs location'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('var-a'), findsOneWidget);
      expect(find.text('inv-c'), findsOneWidget);
      expect(find.text('variant belongs to another tenant'), findsOneWidget);
      expect(find.text('commerce unavailable (2 attempts)'), findsOneWidget);

      final summary = find.byKey(const Key('receipt_delivery_summary'));
      expect(summary, findsOneWidget);
      expect(
        find.descendant(
          of: summary,
          matching: find.textContaining(
            '1 line refused where the stock was sent',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summary,
          matching: find.textContaining(
            '1 line of raw material waiting for a stock',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summary,
          matching: find.textContaining('retried automatically'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('only lines that need a person offer Resolve', (tester) async {
      await _pump(tester, ProcurementPaths.receipt('gr-1'), receipt: mixed);
      expect(find.byKey(const Key('resolve_line_a')), findsNothing);
      expect(find.byKey(const Key('resolve_line_b')), findsNothing);
      expect(find.byKey(const Key('resolve_line_c')), findsOneWidget);
      expect(find.byKey(const Key('resolve_line_d')), findsOneWidget);
    });

    testWidgets('a raw material is marked booked by hand with a note', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
      );
      await tester.tap(find.byKey(const Key('resolve_line_c')));
      await tester.pumpAndSettle();

      expect(find.text('Resolve receipt line'), findsOneWidget);
      // Without a location picker a raw material can only be booked by hand.
      expect(find.byKey(const Key('resolve_line_retry')), findsNothing);
      await tester.enterText(
        find.byKey(const Key('resolve_line_note')),
        '  booked into the main store  ',
      );
      await tester.tap(find.byKey(const Key('resolve_line_booked')));
      await tester.pumpAndSettle();

      final request = h.log.single as GoodsReceiptLineResolveRequest;
      expect(request.goodsReceiptId, 'gr-1');
      expect(request.lineId, 'c');
      expect(
        request.resolution,
        GoodsReceiptLineResolution
            .GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY,
      );
      expect(request.note, 'booked into the main store');
      expect(find.text('Line marked booked by hand'), findsOneWidget);
    });

    testWidgets('a refused variant is retried', (tester) async {
      final h = await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
      );
      await tester.tap(find.byKey(const Key('resolve_line_d')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resolve_line_retry')));
      await tester.pumpAndSettle();

      final request = h.log.single as GoodsReceiptLineResolveRequest;
      expect(request.lineId, 'd');
      expect(
        request.resolution,
        GoodsReceiptLineResolution.GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
      );
      expect(find.text('Delivered to the shop'), findsOneWidget);
    });

    testWidgets('a raw material is booked into the location staff choose', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
        pickers: _locationPicker,
      );
      await tester.tap(find.byKey(const Key('resolve_line_c')));
      await tester.pumpAndSettle();

      final send = find.byKey(const Key('resolve_line_retry'));
      expect(
        tester.widget<OutlinedButton>(send).onPressed,
        isNull,
        reason: 'nothing is sent before a location is chosen',
      );
      await tester.tap(find.text('Pick location'));
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();

      final request = h.log.single as GoodsReceiptLineResolveRequest;
      expect(request.lineId, 'c');
      expect(
        request.resolution,
        GoodsReceiptLineResolution.GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
      );
      expect(request.locationId, 'loc-main');
      expect(find.text('Booked into manufacturing inventory'), findsOneWidget);
    });

    testWidgets('dismissing the dialog records nothing', (tester) async {
      final h = await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
      );
      await tester.tap(find.byKey(const Key('resolve_line_c')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(h.log, isEmpty);
    });

    testWidgets('without goods_receipt_resolve lines cannot be resolved', (
      tester,
    ) async {
      await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
        permissions: _allPermissions.difference({'goods_receipt_resolve'}),
      );
      expect(find.text('Failed'), findsOneWidget);
      expect(find.byKey(const Key('resolve_line_c')), findsNothing);
      expect(find.byKey(const Key('resolve_line_d')), findsNothing);
    });

    testWidgets('a resolved line says who booked it and needs nothing', (
      tester,
    ) async {
      await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: GoodsReceipt()
          ..id = 'gr-1'
          ..lines.add(
            line(
                'e',
                SupplyKind.SUPPLY_KIND_MATERIAL,
                StockDeliveryStatus.STOCK_DELIVERY_STATUS_RESOLVED,
              )
              ..resolvedBy = 'profile-store'
              ..resolutionNote = 'GRN 42',
          ),
      );
      expect(find.text('Booked by hand'), findsOneWidget);
      expect(
        find.text('Booked by hand by profile-store: GRN 42'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('resolve_line_e')), findsNothing);
      expect(find.byKey(const Key('receipt_delivery_summary')), findsNothing);
    });

    testWidgets('the resolve dialog fits a phone', (tester) async {
      await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: mixed,
        size: const Size(390, 844),
      );
      await tester.ensureVisible(find.byKey(const Key('resolve_line_d')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resolve_line_d')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('resolve_line_retry')), findsOneWidget);
      expect(find.byKey(const Key('resolve_line_booked')), findsOneWidget);
    });

    testWidgets('the order flags receipts that need action', (tester) async {
      await _pump(tester, ProcurementPaths.order('po-1'), receipt: mixed);
      expect(find.text('2 need action'), findsOneWidget);
    });

    testWidgets('a fully delivered receipt shows no summary', (tester) async {
      await _pump(
        tester,
        ProcurementPaths.receipt('gr-1'),
        receipt: GoodsReceipt()
          ..id = 'gr-1'
          ..lines.add(
            line(
              'a',
              SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT,
              StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED,
            ),
          ),
      );
      expect(find.byKey(const Key('receipt_delivery_summary')), findsNothing);
    });
  });

  group('supplier item form', () {
    final pickers = SupplyPickers(
      productVariant: (context, onPicked) => TextButton(
        onPressed: () =>
            onPicked(const SupplyChoice(id: 'var-tea', label: 'Tea 1kg')),
        child: const Text('Pick variant'),
      ),
    );

    testWidgets('a resale item is picked from the catalogue', (tester) async {
      final h = await _pump(
        tester,
        ProcurementPaths.supplier('sup-1'),
        pickers: pickers,
      );
      await tester.tap(find.byKey(const Key('supplier_add_item')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Product for resale'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick variant'));
      await tester.pumpAndSettle();
      expect(find.text('Selected: Tea 1kg'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('supplier_item_price')),
        '250',
      );
      await tester.enterText(
        find.byKey(const Key('supplier_item_currency')),
        'KES',
      );
      await tester.enterText(find.byKey(const Key('supplier_item_moq')), '1.5');
      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();
      expect(find.text('Products are bought in whole units'), findsOneWidget);
      expect(h.log.whereType<SupplierItemSaveRequest>(), isEmpty);

      await tester.enterText(find.byKey(const Key('supplier_item_moq')), '2');
      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();

      final request = h.log.whereType<SupplierItemSaveRequest>().single;
      expect(request.supplierId, 'sup-1');
      expect(request.supplyKind, SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT);
      expect(request.productVariantId, 'var-tea');
      expect(request.inventoryItemId, isEmpty);
      expect(request.unitPrice.currencyCode, 'KES');
      expect(request.unitPrice.units.toInt(), 250);
      expect(request.minOrderQuantity, 2);
    });

    testWidgets('a material without a picker takes a validated ID', (
      tester,
    ) async {
      final h = await _pump(tester, ProcurementPaths.supplier('sup-1'));
      await tester.tap(find.byKey(const Key('supplier_add_item')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();
      expect(find.text('Pick the inventory item'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('supplier_item_target')),
        'Not An ID!',
      );
      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();
      expect(find.text('Not a valid ID'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('supplier_item_target')),
        'inv-sugar',
      );
      await tester.enterText(
        find.byKey(const Key('supplier_item_price')),
        '80.50',
      );
      await tester.enterText(
        find.byKey(const Key('supplier_item_currency')),
        'kes',
      );
      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();

      final request = h.log.whereType<SupplierItemSaveRequest>().single;
      expect(request.supplyKind, SupplyKind.SUPPLY_KIND_MATERIAL);
      expect(request.inventoryItemId, 'inv-sugar');
      expect(request.productVariantId, isEmpty);
      expect(request.unitPrice.currencyCode, 'KES');
      expect(request.unitPrice.nanos, 500000000);
    });

    testWidgets('editing keeps what the item supplies', (tester) async {
      final h = await _pump(tester, ProcurementPaths.supplier('sup-1'));
      await tester.tap(find.byTooltip('Edit item'));
      await tester.pumpAndSettle();

      final target = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('supplier_item_target')),
          matching: find.byType(TextField),
        ),
      );
      expect(target.readOnly, isTrue);
      expect(target.controller!.text, 'inv-flour');

      await tester.enterText(
        find.byKey(const Key('supplier_item_price')),
        '310',
      );
      await tester.enterText(
        find.byKey(const Key('supplier_item_currency')),
        'KES',
      );
      await tester.tap(find.byKey(const Key('supplier_item_save')));
      await tester.pumpAndSettle();

      final request = h.log.whereType<SupplierItemSaveRequest>().single;
      expect(request.id, 'si-1');
      expect(request.inventoryItemId, isEmpty);
      expect(request.unitPrice.units.toInt(), 310);
    });
  });

  group('purchase order list', () {
    PurchaseOrder numbered(int n) => _order()
      ..id = 'po-$n'
      ..orderNumber = '$n';

    testWidgets('pages with the server cursor', (tester) async {
      await _pump(
        tester,
        ProcurementPaths.orders,
        orders: [numbered(1), numbered(2), numbered(3)],
        pageSize: 2,
      );
      expect(find.text('PO #1'), findsOneWidget);
      expect(find.text('PO #2'), findsOneWidget);
      expect(find.text('PO #3'), findsNothing);
      expect(find.text('2+ orders'), findsOneWidget);

      await tester.tap(find.byKey(const Key('load_more')));
      await tester.pumpAndSettle();
      expect(find.text('PO #3'), findsOneWidget);
      expect(find.byKey(const Key('load_more')), findsNothing);
    });

    testWidgets('the status filter is applied by the server', (tester) async {
      final h = await _pump(tester, ProcurementPaths.orders);
      await tester.tap(find.widgetWithText(FilterChip, 'Closed short'));
      await tester.pumpAndSettle();
      final last = h.orderQueries.last;
      expect(last.status, PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CLOSED);
      expect(last.propertyId, 'prop-9');
    });
  });

  group('phone width', () {
    testWidgets('order detail and close dialog fit a phone', (tester) async {
      await _pump(
        tester,
        ProcurementPaths.order('po-1'),
        order: _order(
          status: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
        ),
        size: const Size(360, 800),
      );
      await tester.tap(find.byKey(const Key('po_close_short')));
      await tester.pumpAndSettle();
      expect(find.byType(ClosePODialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supplier item form fits a phone', (tester) async {
      await _pump(
        tester,
        ProcurementPaths.supplier('sup-1'),
        size: const Size(360, 800),
      );
      await tester.tap(find.byKey(const Key('supplier_add_item')));
      await tester.pumpAndSettle();
      expect(find.byType(SupplierItemFormDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
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
