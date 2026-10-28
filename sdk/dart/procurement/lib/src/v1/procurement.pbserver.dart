// This is a generated file - do not edit.
//
// Generated from v1/procurement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'procurement.pb.dart' as $4;
import 'procurement.pbjson.dart';

export 'procurement.pb.dart';

abstract class ProcurementServiceBase extends $pb.GeneratedService {
  $async.Future<$4.SupplierSaveResponse> supplierSave(
      $pb.ServerContext ctx, $4.SupplierSaveRequest request);
  $async.Future<$4.SupplierGetResponse> supplierGet(
      $pb.ServerContext ctx, $4.SupplierGetRequest request);
  $async.Future<$4.SupplierSearchResponse> supplierSearch(
      $pb.ServerContext ctx, $4.SupplierSearchRequest request);
  $async.Future<$4.SupplierItemSaveResponse> supplierItemSave(
      $pb.ServerContext ctx, $4.SupplierItemSaveRequest request);
  $async.Future<$4.SupplierItemSearchResponse> supplierItemSearch(
      $pb.ServerContext ctx, $4.SupplierItemSearchRequest request);
  $async.Future<$4.PurchaseOrderCreateResponse> purchaseOrderCreate(
      $pb.ServerContext ctx, $4.PurchaseOrderCreateRequest request);
  $async.Future<$4.PurchaseOrderGetResponse> purchaseOrderGet(
      $pb.ServerContext ctx, $4.PurchaseOrderGetRequest request);
  $async.Future<$4.PurchaseOrderSearchResponse> purchaseOrderSearch(
      $pb.ServerContext ctx, $4.PurchaseOrderSearchRequest request);
  $async.Future<$4.PurchaseOrderSubmitResponse> purchaseOrderSubmit(
      $pb.ServerContext ctx, $4.PurchaseOrderSubmitRequest request);
  $async.Future<$4.PurchaseOrderCancelResponse> purchaseOrderCancel(
      $pb.ServerContext ctx, $4.PurchaseOrderCancelRequest request);
  $async.Future<$4.PurchaseOrderCloseResponse> purchaseOrderClose(
      $pb.ServerContext ctx, $4.PurchaseOrderCloseRequest request);
  $async.Future<$4.GoodsReceiptCreateResponse> goodsReceiptCreate(
      $pb.ServerContext ctx, $4.GoodsReceiptCreateRequest request);
  $async.Future<$4.GoodsReceiptGetResponse> goodsReceiptGet(
      $pb.ServerContext ctx, $4.GoodsReceiptGetRequest request);
  $async.Future<$4.GoodsReceiptSearchResponse> goodsReceiptSearch(
      $pb.ServerContext ctx, $4.GoodsReceiptSearchRequest request);
  $async.Future<$4.GoodsReceiptDeliverResponse> goodsReceiptDeliver(
      $pb.ServerContext ctx, $4.GoodsReceiptDeliverRequest request);
  $async.Future<$4.GoodsReceiptLineResolveResponse> goodsReceiptLineResolve(
      $pb.ServerContext ctx, $4.GoodsReceiptLineResolveRequest request);
  $async.Future<$4.SuggestPurchaseOrdersResponse> suggestPurchaseOrders(
      $pb.ServerContext ctx, $4.SuggestPurchaseOrdersRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SupplierSave':
        return $4.SupplierSaveRequest();
      case 'SupplierGet':
        return $4.SupplierGetRequest();
      case 'SupplierSearch':
        return $4.SupplierSearchRequest();
      case 'SupplierItemSave':
        return $4.SupplierItemSaveRequest();
      case 'SupplierItemSearch':
        return $4.SupplierItemSearchRequest();
      case 'PurchaseOrderCreate':
        return $4.PurchaseOrderCreateRequest();
      case 'PurchaseOrderGet':
        return $4.PurchaseOrderGetRequest();
      case 'PurchaseOrderSearch':
        return $4.PurchaseOrderSearchRequest();
      case 'PurchaseOrderSubmit':
        return $4.PurchaseOrderSubmitRequest();
      case 'PurchaseOrderCancel':
        return $4.PurchaseOrderCancelRequest();
      case 'PurchaseOrderClose':
        return $4.PurchaseOrderCloseRequest();
      case 'GoodsReceiptCreate':
        return $4.GoodsReceiptCreateRequest();
      case 'GoodsReceiptGet':
        return $4.GoodsReceiptGetRequest();
      case 'GoodsReceiptSearch':
        return $4.GoodsReceiptSearchRequest();
      case 'GoodsReceiptDeliver':
        return $4.GoodsReceiptDeliverRequest();
      case 'GoodsReceiptLineResolve':
        return $4.GoodsReceiptLineResolveRequest();
      case 'SuggestPurchaseOrders':
        return $4.SuggestPurchaseOrdersRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SupplierSave':
        return supplierSave(ctx, request as $4.SupplierSaveRequest);
      case 'SupplierGet':
        return supplierGet(ctx, request as $4.SupplierGetRequest);
      case 'SupplierSearch':
        return supplierSearch(ctx, request as $4.SupplierSearchRequest);
      case 'SupplierItemSave':
        return supplierItemSave(ctx, request as $4.SupplierItemSaveRequest);
      case 'SupplierItemSearch':
        return supplierItemSearch(ctx, request as $4.SupplierItemSearchRequest);
      case 'PurchaseOrderCreate':
        return purchaseOrderCreate(
            ctx, request as $4.PurchaseOrderCreateRequest);
      case 'PurchaseOrderGet':
        return purchaseOrderGet(ctx, request as $4.PurchaseOrderGetRequest);
      case 'PurchaseOrderSearch':
        return purchaseOrderSearch(
            ctx, request as $4.PurchaseOrderSearchRequest);
      case 'PurchaseOrderSubmit':
        return purchaseOrderSubmit(
            ctx, request as $4.PurchaseOrderSubmitRequest);
      case 'PurchaseOrderCancel':
        return purchaseOrderCancel(
            ctx, request as $4.PurchaseOrderCancelRequest);
      case 'PurchaseOrderClose':
        return purchaseOrderClose(ctx, request as $4.PurchaseOrderCloseRequest);
      case 'GoodsReceiptCreate':
        return goodsReceiptCreate(ctx, request as $4.GoodsReceiptCreateRequest);
      case 'GoodsReceiptGet':
        return goodsReceiptGet(ctx, request as $4.GoodsReceiptGetRequest);
      case 'GoodsReceiptSearch':
        return goodsReceiptSearch(ctx, request as $4.GoodsReceiptSearchRequest);
      case 'GoodsReceiptDeliver':
        return goodsReceiptDeliver(
            ctx, request as $4.GoodsReceiptDeliverRequest);
      case 'GoodsReceiptLineResolve':
        return goodsReceiptLineResolve(
            ctx, request as $4.GoodsReceiptLineResolveRequest);
      case 'SuggestPurchaseOrders':
        return suggestPurchaseOrders(
            ctx, request as $4.SuggestPurchaseOrdersRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      ProcurementServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ProcurementServiceBase$messageJson;
}
