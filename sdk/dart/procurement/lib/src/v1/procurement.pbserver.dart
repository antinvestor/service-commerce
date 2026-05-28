//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'procurement.pb.dart' as $9;
import 'procurement.pbjson.dart';

export 'procurement.pb.dart';

abstract class ProcurementServiceBase extends $pb.GeneratedService {
  $async.Future<$9.SupplierSaveResponse> supplierSave($pb.ServerContext ctx, $9.SupplierSaveRequest request);
  $async.Future<$9.SupplierGetResponse> supplierGet($pb.ServerContext ctx, $9.SupplierGetRequest request);
  $async.Future<$9.SupplierSearchResponse> supplierSearch($pb.ServerContext ctx, $9.SupplierSearchRequest request);
  $async.Future<$9.SupplierItemSaveResponse> supplierItemSave($pb.ServerContext ctx, $9.SupplierItemSaveRequest request);
  $async.Future<$9.SupplierItemSearchResponse> supplierItemSearch($pb.ServerContext ctx, $9.SupplierItemSearchRequest request);
  $async.Future<$9.PurchaseOrderCreateResponse> purchaseOrderCreate($pb.ServerContext ctx, $9.PurchaseOrderCreateRequest request);
  $async.Future<$9.PurchaseOrderGetResponse> purchaseOrderGet($pb.ServerContext ctx, $9.PurchaseOrderGetRequest request);
  $async.Future<$9.PurchaseOrderSearchResponse> purchaseOrderSearch($pb.ServerContext ctx, $9.PurchaseOrderSearchRequest request);
  $async.Future<$9.PurchaseOrderSubmitResponse> purchaseOrderSubmit($pb.ServerContext ctx, $9.PurchaseOrderSubmitRequest request);
  $async.Future<$9.PurchaseOrderCancelResponse> purchaseOrderCancel($pb.ServerContext ctx, $9.PurchaseOrderCancelRequest request);
  $async.Future<$9.GoodsReceiptCreateResponse> goodsReceiptCreate($pb.ServerContext ctx, $9.GoodsReceiptCreateRequest request);
  $async.Future<$9.GoodsReceiptGetResponse> goodsReceiptGet($pb.ServerContext ctx, $9.GoodsReceiptGetRequest request);
  $async.Future<$9.GoodsReceiptSearchResponse> goodsReceiptSearch($pb.ServerContext ctx, $9.GoodsReceiptSearchRequest request);
  $async.Future<$9.SuggestPurchaseOrdersResponse> suggestPurchaseOrders($pb.ServerContext ctx, $9.SuggestPurchaseOrdersRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SupplierSave': return $9.SupplierSaveRequest();
      case 'SupplierGet': return $9.SupplierGetRequest();
      case 'SupplierSearch': return $9.SupplierSearchRequest();
      case 'SupplierItemSave': return $9.SupplierItemSaveRequest();
      case 'SupplierItemSearch': return $9.SupplierItemSearchRequest();
      case 'PurchaseOrderCreate': return $9.PurchaseOrderCreateRequest();
      case 'PurchaseOrderGet': return $9.PurchaseOrderGetRequest();
      case 'PurchaseOrderSearch': return $9.PurchaseOrderSearchRequest();
      case 'PurchaseOrderSubmit': return $9.PurchaseOrderSubmitRequest();
      case 'PurchaseOrderCancel': return $9.PurchaseOrderCancelRequest();
      case 'GoodsReceiptCreate': return $9.GoodsReceiptCreateRequest();
      case 'GoodsReceiptGet': return $9.GoodsReceiptGetRequest();
      case 'GoodsReceiptSearch': return $9.GoodsReceiptSearchRequest();
      case 'SuggestPurchaseOrders': return $9.SuggestPurchaseOrdersRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SupplierSave': return this.supplierSave(ctx, request as $9.SupplierSaveRequest);
      case 'SupplierGet': return this.supplierGet(ctx, request as $9.SupplierGetRequest);
      case 'SupplierSearch': return this.supplierSearch(ctx, request as $9.SupplierSearchRequest);
      case 'SupplierItemSave': return this.supplierItemSave(ctx, request as $9.SupplierItemSaveRequest);
      case 'SupplierItemSearch': return this.supplierItemSearch(ctx, request as $9.SupplierItemSearchRequest);
      case 'PurchaseOrderCreate': return this.purchaseOrderCreate(ctx, request as $9.PurchaseOrderCreateRequest);
      case 'PurchaseOrderGet': return this.purchaseOrderGet(ctx, request as $9.PurchaseOrderGetRequest);
      case 'PurchaseOrderSearch': return this.purchaseOrderSearch(ctx, request as $9.PurchaseOrderSearchRequest);
      case 'PurchaseOrderSubmit': return this.purchaseOrderSubmit(ctx, request as $9.PurchaseOrderSubmitRequest);
      case 'PurchaseOrderCancel': return this.purchaseOrderCancel(ctx, request as $9.PurchaseOrderCancelRequest);
      case 'GoodsReceiptCreate': return this.goodsReceiptCreate(ctx, request as $9.GoodsReceiptCreateRequest);
      case 'GoodsReceiptGet': return this.goodsReceiptGet(ctx, request as $9.GoodsReceiptGetRequest);
      case 'GoodsReceiptSearch': return this.goodsReceiptSearch(ctx, request as $9.GoodsReceiptSearchRequest);
      case 'SuggestPurchaseOrders': return this.suggestPurchaseOrders(ctx, request as $9.SuggestPurchaseOrdersRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProcurementServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProcurementServiceBase$messageJson;
}

