//
//  Generated code. Do not modify.
//  source: v1/commerce.proto
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

import 'commerce.pb.dart' as $9;
import 'commerce.pbjson.dart';

export 'commerce.pb.dart';

abstract class CommerceServiceBase extends $pb.GeneratedService {
  $async.Future<$9.CreateShopResponse> createShop($pb.ServerContext ctx, $9.CreateShopRequest request);
  $async.Future<$9.GetShopResponse> getShop($pb.ServerContext ctx, $9.GetShopRequest request);
  $async.Future<$9.UpdateShopResponse> updateShop($pb.ServerContext ctx, $9.UpdateShopRequest request);
  $async.Future<$9.ListShopsResponse> listShops($pb.ServerContext ctx, $9.ListShopsRequest request);
  $async.Future<$9.CreateProductResponse> createProduct($pb.ServerContext ctx, $9.CreateProductRequest request);
  $async.Future<$9.GetProductResponse> getProduct($pb.ServerContext ctx, $9.GetProductRequest request);
  $async.Future<$9.ListProductsResponse> listProducts($pb.ServerContext ctx, $9.ListProductsRequest request);
  $async.Future<$9.CreateProductVariantResponse> createProductVariant($pb.ServerContext ctx, $9.CreateProductVariantRequest request);
  $async.Future<$9.UpdateProductVariantResponse> updateProductVariant($pb.ServerContext ctx, $9.UpdateProductVariantRequest request);
  $async.Future<$9.ListProductVariantsResponse> listProductVariants($pb.ServerContext ctx, $9.ListProductVariantsRequest request);
  $async.Future<$9.CreateCartResponse> createCart($pb.ServerContext ctx, $9.CreateCartRequest request);
  $async.Future<$9.GetCartResponse> getCart($pb.ServerContext ctx, $9.GetCartRequest request);
  $async.Future<$9.AddCartLineResponse> addCartLine($pb.ServerContext ctx, $9.AddCartLineRequest request);
  $async.Future<$9.RemoveCartLineResponse> removeCartLine($pb.ServerContext ctx, $9.RemoveCartLineRequest request);
  $async.Future<$9.CreateOrderFromCartResponse> createOrderFromCart($pb.ServerContext ctx, $9.CreateOrderFromCartRequest request);
  $async.Future<$9.CreateOrderResponse> createOrder($pb.ServerContext ctx, $9.CreateOrderRequest request);
  $async.Future<$9.GetOrderResponse> getOrder($pb.ServerContext ctx, $9.GetOrderRequest request);
  $async.Future<$9.ListOrdersResponse> listOrders($pb.ServerContext ctx, $9.ListOrdersRequest request);
  $async.Future<$9.CheckoutOrderResponse> checkoutOrder($pb.ServerContext ctx, $9.CheckoutOrderRequest request);
  $async.Future<$9.ConfirmOrderPaymentResponse> confirmOrderPayment($pb.ServerContext ctx, $9.ConfirmOrderPaymentRequest request);
  $async.Future<$9.CancelOrderResponse> cancelOrder($pb.ServerContext ctx, $9.CancelOrderRequest request);
  $async.Future<$9.ReconcilePaymentsResponse> reconcilePayments($pb.ServerContext ctx, $9.ReconcilePaymentsRequest request);
  $async.Future<$9.RunEndOfDayLedgerResponse> runEndOfDayLedger($pb.ServerContext ctx, $9.RunEndOfDayLedgerRequest request);
  $async.Future<$9.CreateFulfilmentResponse> createFulfilment($pb.ServerContext ctx, $9.CreateFulfilmentRequest request);
  $async.Future<$9.UpdateFulfilmentResponse> updateFulfilment($pb.ServerContext ctx, $9.UpdateFulfilmentRequest request);
  $async.Future<$9.GetFulfilmentResponse> getFulfilment($pb.ServerContext ctx, $9.GetFulfilmentRequest request);
  $async.Future<$9.PriceListSaveResponse> priceListSave($pb.ServerContext ctx, $9.PriceListSaveRequest request);
  $async.Future<$9.PriceListGetResponse> priceListGet($pb.ServerContext ctx, $9.PriceListGetRequest request);
  $async.Future<$9.PriceListSearchResponse> priceListSearch($pb.ServerContext ctx, $9.PriceListSearchRequest request);
  $async.Future<$9.PriceListEntryBatchSaveResponse> priceListEntryBatchSave($pb.ServerContext ctx, $9.PriceListEntryBatchSaveRequest request);
  $async.Future<$9.CustomerPriceListAssignmentSaveResponse> customerPriceListAssignmentSave($pb.ServerContext ctx, $9.CustomerPriceListAssignmentSaveRequest request);
  $async.Future<$9.CustomerPriceListAssignmentSearchResponse> customerPriceListAssignmentSearch($pb.ServerContext ctx, $9.CustomerPriceListAssignmentSearchRequest request);
  $async.Future<$9.CustomerPriceOverrideSaveResponse> customerPriceOverrideSave($pb.ServerContext ctx, $9.CustomerPriceOverrideSaveRequest request);
  $async.Future<$9.CustomerPriceOverrideSearchResponse> customerPriceOverrideSearch($pb.ServerContext ctx, $9.CustomerPriceOverrideSearchRequest request);
  $async.Future<$9.DiscountRuleSaveResponse> discountRuleSave($pb.ServerContext ctx, $9.DiscountRuleSaveRequest request);
  $async.Future<$9.DiscountRuleSearchResponse> discountRuleSearch($pb.ServerContext ctx, $9.DiscountRuleSearchRequest request);
  $async.Future<$9.ResolvePriceResponse> resolvePrice($pb.ServerContext ctx, $9.ResolvePriceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateShop': return $9.CreateShopRequest();
      case 'GetShop': return $9.GetShopRequest();
      case 'UpdateShop': return $9.UpdateShopRequest();
      case 'ListShops': return $9.ListShopsRequest();
      case 'CreateProduct': return $9.CreateProductRequest();
      case 'GetProduct': return $9.GetProductRequest();
      case 'ListProducts': return $9.ListProductsRequest();
      case 'CreateProductVariant': return $9.CreateProductVariantRequest();
      case 'UpdateProductVariant': return $9.UpdateProductVariantRequest();
      case 'ListProductVariants': return $9.ListProductVariantsRequest();
      case 'CreateCart': return $9.CreateCartRequest();
      case 'GetCart': return $9.GetCartRequest();
      case 'AddCartLine': return $9.AddCartLineRequest();
      case 'RemoveCartLine': return $9.RemoveCartLineRequest();
      case 'CreateOrderFromCart': return $9.CreateOrderFromCartRequest();
      case 'CreateOrder': return $9.CreateOrderRequest();
      case 'GetOrder': return $9.GetOrderRequest();
      case 'ListOrders': return $9.ListOrdersRequest();
      case 'CheckoutOrder': return $9.CheckoutOrderRequest();
      case 'ConfirmOrderPayment': return $9.ConfirmOrderPaymentRequest();
      case 'CancelOrder': return $9.CancelOrderRequest();
      case 'ReconcilePayments': return $9.ReconcilePaymentsRequest();
      case 'RunEndOfDayLedger': return $9.RunEndOfDayLedgerRequest();
      case 'CreateFulfilment': return $9.CreateFulfilmentRequest();
      case 'UpdateFulfilment': return $9.UpdateFulfilmentRequest();
      case 'GetFulfilment': return $9.GetFulfilmentRequest();
      case 'PriceListSave': return $9.PriceListSaveRequest();
      case 'PriceListGet': return $9.PriceListGetRequest();
      case 'PriceListSearch': return $9.PriceListSearchRequest();
      case 'PriceListEntryBatchSave': return $9.PriceListEntryBatchSaveRequest();
      case 'CustomerPriceListAssignmentSave': return $9.CustomerPriceListAssignmentSaveRequest();
      case 'CustomerPriceListAssignmentSearch': return $9.CustomerPriceListAssignmentSearchRequest();
      case 'CustomerPriceOverrideSave': return $9.CustomerPriceOverrideSaveRequest();
      case 'CustomerPriceOverrideSearch': return $9.CustomerPriceOverrideSearchRequest();
      case 'DiscountRuleSave': return $9.DiscountRuleSaveRequest();
      case 'DiscountRuleSearch': return $9.DiscountRuleSearchRequest();
      case 'ResolvePrice': return $9.ResolvePriceRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateShop': return this.createShop(ctx, request as $9.CreateShopRequest);
      case 'GetShop': return this.getShop(ctx, request as $9.GetShopRequest);
      case 'UpdateShop': return this.updateShop(ctx, request as $9.UpdateShopRequest);
      case 'ListShops': return this.listShops(ctx, request as $9.ListShopsRequest);
      case 'CreateProduct': return this.createProduct(ctx, request as $9.CreateProductRequest);
      case 'GetProduct': return this.getProduct(ctx, request as $9.GetProductRequest);
      case 'ListProducts': return this.listProducts(ctx, request as $9.ListProductsRequest);
      case 'CreateProductVariant': return this.createProductVariant(ctx, request as $9.CreateProductVariantRequest);
      case 'UpdateProductVariant': return this.updateProductVariant(ctx, request as $9.UpdateProductVariantRequest);
      case 'ListProductVariants': return this.listProductVariants(ctx, request as $9.ListProductVariantsRequest);
      case 'CreateCart': return this.createCart(ctx, request as $9.CreateCartRequest);
      case 'GetCart': return this.getCart(ctx, request as $9.GetCartRequest);
      case 'AddCartLine': return this.addCartLine(ctx, request as $9.AddCartLineRequest);
      case 'RemoveCartLine': return this.removeCartLine(ctx, request as $9.RemoveCartLineRequest);
      case 'CreateOrderFromCart': return this.createOrderFromCart(ctx, request as $9.CreateOrderFromCartRequest);
      case 'CreateOrder': return this.createOrder(ctx, request as $9.CreateOrderRequest);
      case 'GetOrder': return this.getOrder(ctx, request as $9.GetOrderRequest);
      case 'ListOrders': return this.listOrders(ctx, request as $9.ListOrdersRequest);
      case 'CheckoutOrder': return this.checkoutOrder(ctx, request as $9.CheckoutOrderRequest);
      case 'ConfirmOrderPayment': return this.confirmOrderPayment(ctx, request as $9.ConfirmOrderPaymentRequest);
      case 'CancelOrder': return this.cancelOrder(ctx, request as $9.CancelOrderRequest);
      case 'ReconcilePayments': return this.reconcilePayments(ctx, request as $9.ReconcilePaymentsRequest);
      case 'RunEndOfDayLedger': return this.runEndOfDayLedger(ctx, request as $9.RunEndOfDayLedgerRequest);
      case 'CreateFulfilment': return this.createFulfilment(ctx, request as $9.CreateFulfilmentRequest);
      case 'UpdateFulfilment': return this.updateFulfilment(ctx, request as $9.UpdateFulfilmentRequest);
      case 'GetFulfilment': return this.getFulfilment(ctx, request as $9.GetFulfilmentRequest);
      case 'PriceListSave': return this.priceListSave(ctx, request as $9.PriceListSaveRequest);
      case 'PriceListGet': return this.priceListGet(ctx, request as $9.PriceListGetRequest);
      case 'PriceListSearch': return this.priceListSearch(ctx, request as $9.PriceListSearchRequest);
      case 'PriceListEntryBatchSave': return this.priceListEntryBatchSave(ctx, request as $9.PriceListEntryBatchSaveRequest);
      case 'CustomerPriceListAssignmentSave': return this.customerPriceListAssignmentSave(ctx, request as $9.CustomerPriceListAssignmentSaveRequest);
      case 'CustomerPriceListAssignmentSearch': return this.customerPriceListAssignmentSearch(ctx, request as $9.CustomerPriceListAssignmentSearchRequest);
      case 'CustomerPriceOverrideSave': return this.customerPriceOverrideSave(ctx, request as $9.CustomerPriceOverrideSaveRequest);
      case 'CustomerPriceOverrideSearch': return this.customerPriceOverrideSearch(ctx, request as $9.CustomerPriceOverrideSearchRequest);
      case 'DiscountRuleSave': return this.discountRuleSave(ctx, request as $9.DiscountRuleSaveRequest);
      case 'DiscountRuleSearch': return this.discountRuleSearch(ctx, request as $9.DiscountRuleSearchRequest);
      case 'ResolvePrice': return this.resolvePrice(ctx, request as $9.ResolvePriceRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CommerceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CommerceServiceBase$messageJson;
}

