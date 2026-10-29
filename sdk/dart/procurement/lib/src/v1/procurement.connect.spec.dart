//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//

import "package:connectrpc/connect.dart" as connect;
import "procurement.pb.dart" as v1procurement;

abstract final class ProcurementService {
  /// Fully-qualified name of the ProcurementService service.
  static const name = 'procurement.v1.ProcurementService';

  /// ---- Suppliers ----
  static const supplierSave = connect.Spec(
    '/$name/SupplierSave',
    connect.StreamType.unary,
    v1procurement.SupplierSaveRequest.new,
    v1procurement.SupplierSaveResponse.new,
  );

  static const supplierGet = connect.Spec(
    '/$name/SupplierGet',
    connect.StreamType.unary,
    v1procurement.SupplierGetRequest.new,
    v1procurement.SupplierGetResponse.new,
  );

  static const supplierSearch = connect.Spec(
    '/$name/SupplierSearch',
    connect.StreamType.unary,
    v1procurement.SupplierSearchRequest.new,
    v1procurement.SupplierSearchResponse.new,
  );

  /// ---- Supplier Items ----
  static const supplierItemSave = connect.Spec(
    '/$name/SupplierItemSave',
    connect.StreamType.unary,
    v1procurement.SupplierItemSaveRequest.new,
    v1procurement.SupplierItemSaveResponse.new,
  );

  static const supplierItemSearch = connect.Spec(
    '/$name/SupplierItemSearch',
    connect.StreamType.unary,
    v1procurement.SupplierItemSearchRequest.new,
    v1procurement.SupplierItemSearchResponse.new,
  );

  /// ---- Purchase Orders ----
  static const purchaseOrderCreate = connect.Spec(
    '/$name/PurchaseOrderCreate',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderCreateRequest.new,
    v1procurement.PurchaseOrderCreateResponse.new,
  );

  static const purchaseOrderGet = connect.Spec(
    '/$name/PurchaseOrderGet',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderGetRequest.new,
    v1procurement.PurchaseOrderGetResponse.new,
  );

  static const purchaseOrderSearch = connect.Spec(
    '/$name/PurchaseOrderSearch',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderSearchRequest.new,
    v1procurement.PurchaseOrderSearchResponse.new,
  );

  static const purchaseOrderSubmit = connect.Spec(
    '/$name/PurchaseOrderSubmit',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderSubmitRequest.new,
    v1procurement.PurchaseOrderSubmitResponse.new,
  );

  static const purchaseOrderCancel = connect.Spec(
    '/$name/PurchaseOrderCancel',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderCancelRequest.new,
    v1procurement.PurchaseOrderCancelResponse.new,
  );

  /// Closes a partially received order short: what was received stands, the
  /// remainder of every open line is cancelled and no further receipt is
  /// accepted.
  static const purchaseOrderClose = connect.Spec(
    '/$name/PurchaseOrderClose',
    connect.StreamType.unary,
    v1procurement.PurchaseOrderCloseRequest.new,
    v1procurement.PurchaseOrderCloseResponse.new,
  );

  /// ---- Goods Receipts ----
  static const goodsReceiptCreate = connect.Spec(
    '/$name/GoodsReceiptCreate',
    connect.StreamType.unary,
    v1procurement.GoodsReceiptCreateRequest.new,
    v1procurement.GoodsReceiptCreateResponse.new,
  );

  static const goodsReceiptGet = connect.Spec(
    '/$name/GoodsReceiptGet',
    connect.StreamType.unary,
    v1procurement.GoodsReceiptGetRequest.new,
    v1procurement.GoodsReceiptGetResponse.new,
  );

  static const goodsReceiptSearch = connect.Spec(
    '/$name/GoodsReceiptSearch',
    connect.StreamType.unary,
    v1procurement.GoodsReceiptSearchRequest.new,
    v1procurement.GoodsReceiptSearchResponse.new,
  );

  /// Pushes received stock that has not reached its destination yet (commerce
  /// product variants), oldest and least-tried first, at most limit lines.
  /// Each line lands once whatever the number of calls. Scheduled.
  static const goodsReceiptDeliver = connect.Spec(
    '/$name/GoodsReceiptDeliver',
    connect.StreamType.unary,
    v1procurement.GoodsReceiptDeliverRequest.new,
    v1procurement.GoodsReceiptDeliverResponse.new,
  );

  /// Settles a receipt line that needs a person: stock booked by hand
  /// (BOOKED_MANUALLY) is marked resolved with who, when and why; a FAILED
  /// product variant line is put back to PENDING and pushed once (RETRY).
  /// Authorised on the receipt's property (goods_receipt_manage).
  static const goodsReceiptLineResolve = connect.Spec(
    '/$name/GoodsReceiptLineResolve',
    connect.StreamType.unary,
    v1procurement.GoodsReceiptLineResolveRequest.new,
    v1procurement.GoodsReceiptLineResolveResponse.new,
  );

  /// ---- Suggestions ----
  static const suggestPurchaseOrders = connect.Spec(
    '/$name/SuggestPurchaseOrders',
    connect.StreamType.unary,
    v1procurement.SuggestPurchaseOrdersRequest.new,
    v1procurement.SuggestPurchaseOrdersResponse.new,
  );
}
