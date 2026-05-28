//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//

import "package:connectrpc/connect.dart" as connect;
import "procurement.pb.dart" as v1procurement;
import "procurement.connect.spec.dart" as specs;

extension type ProcurementServiceClient (connect.Transport _transport) {
  /// ---- Suppliers ----
  Future<v1procurement.SupplierSaveResponse> supplierSave(
    v1procurement.SupplierSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.supplierSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.SupplierGetResponse> supplierGet(
    v1procurement.SupplierGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.supplierGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.SupplierSearchResponse> supplierSearch(
    v1procurement.SupplierSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.supplierSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ---- Supplier Items ----
  Future<v1procurement.SupplierItemSaveResponse> supplierItemSave(
    v1procurement.SupplierItemSaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.supplierItemSave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.SupplierItemSearchResponse> supplierItemSearch(
    v1procurement.SupplierItemSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.supplierItemSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ---- Purchase Orders ----
  Future<v1procurement.PurchaseOrderCreateResponse> purchaseOrderCreate(
    v1procurement.PurchaseOrderCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.purchaseOrderCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.PurchaseOrderGetResponse> purchaseOrderGet(
    v1procurement.PurchaseOrderGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.purchaseOrderGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.PurchaseOrderSearchResponse> purchaseOrderSearch(
    v1procurement.PurchaseOrderSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.purchaseOrderSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.PurchaseOrderSubmitResponse> purchaseOrderSubmit(
    v1procurement.PurchaseOrderSubmitRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.purchaseOrderSubmit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.PurchaseOrderCancelResponse> purchaseOrderCancel(
    v1procurement.PurchaseOrderCancelRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.purchaseOrderCancel,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ---- Goods Receipts ----
  Future<v1procurement.GoodsReceiptCreateResponse> goodsReceiptCreate(
    v1procurement.GoodsReceiptCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.goodsReceiptCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.GoodsReceiptGetResponse> goodsReceiptGet(
    v1procurement.GoodsReceiptGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.goodsReceiptGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<v1procurement.GoodsReceiptSearchResponse> goodsReceiptSearch(
    v1procurement.GoodsReceiptSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.goodsReceiptSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ---- Suggestions ----
  Future<v1procurement.SuggestPurchaseOrdersResponse> suggestPurchaseOrders(
    v1procurement.SuggestPurchaseOrdersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProcurementService.suggestPurchaseOrders,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
