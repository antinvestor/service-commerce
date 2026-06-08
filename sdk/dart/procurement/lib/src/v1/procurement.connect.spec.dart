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

  /// ---- Suggestions ----
  static const suggestPurchaseOrders = connect.Spec(
    '/$name/SuggestPurchaseOrders',
    connect.StreamType.unary,
    v1procurement.SuggestPurchaseOrdersRequest.new,
    v1procurement.SuggestPurchaseOrdersResponse.new,
  );
}
