// This is a generated file - do not edit.
//
// Generated from v1/commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'commerce.pb.dart' as $5;
import 'commerce.pbjson.dart';

export 'commerce.pb.dart';

abstract class CommerceServiceBase extends $pb.GeneratedService {
  $async.Future<$5.CreateShopResponse> createShop(
      $pb.ServerContext ctx, $5.CreateShopRequest request);
  $async.Future<$5.GetShopResponse> getShop(
      $pb.ServerContext ctx, $5.GetShopRequest request);
  $async.Future<$5.UpdateShopResponse> updateShop(
      $pb.ServerContext ctx, $5.UpdateShopRequest request);
  $async.Future<$5.ListShopsResponse> listShops(
      $pb.ServerContext ctx, $5.ListShopsRequest request);
  $async.Future<$5.ResolveDefaultCurrencyResponse> resolveDefaultCurrency(
      $pb.ServerContext ctx, $5.ResolveDefaultCurrencyRequest request);
  $async.Future<$5.CreateProductResponse> createProduct(
      $pb.ServerContext ctx, $5.CreateProductRequest request);
  $async.Future<$5.GetProductResponse> getProduct(
      $pb.ServerContext ctx, $5.GetProductRequest request);
  $async.Future<$5.ListProductsResponse> listProducts(
      $pb.ServerContext ctx, $5.ListProductsRequest request);
  $async.Future<$5.CreateProductVariantResponse> createProductVariant(
      $pb.ServerContext ctx, $5.CreateProductVariantRequest request);
  $async.Future<$5.UpdateProductVariantResponse> updateProductVariant(
      $pb.ServerContext ctx, $5.UpdateProductVariantRequest request);
  $async.Future<$5.UpdateProductResponse> updateProduct(
      $pb.ServerContext ctx, $5.UpdateProductRequest request);
  $async.Future<$5.ListProductVariantsResponse> listProductVariants(
      $pb.ServerContext ctx, $5.ListProductVariantsRequest request);
  $async.Future<$5.ReceiveStockResponse> receiveStock(
      $pb.ServerContext ctx, $5.ReceiveStockRequest request);
  $async.Future<$5.CreateCartResponse> createCart(
      $pb.ServerContext ctx, $5.CreateCartRequest request);
  $async.Future<$5.GetCartResponse> getCart(
      $pb.ServerContext ctx, $5.GetCartRequest request);
  $async.Future<$5.AddCartLineResponse> addCartLine(
      $pb.ServerContext ctx, $5.AddCartLineRequest request);
  $async.Future<$5.RemoveCartLineResponse> removeCartLine(
      $pb.ServerContext ctx, $5.RemoveCartLineRequest request);
  $async.Future<$5.CreateOrderFromCartResponse> createOrderFromCart(
      $pb.ServerContext ctx, $5.CreateOrderFromCartRequest request);
  $async.Future<$5.CreateOrderResponse> createOrder(
      $pb.ServerContext ctx, $5.CreateOrderRequest request);
  $async.Future<$5.GetOrderResponse> getOrder(
      $pb.ServerContext ctx, $5.GetOrderRequest request);
  $async.Future<$5.ListOrdersResponse> listOrders(
      $pb.ServerContext ctx, $5.ListOrdersRequest request);
  $async.Future<$5.CheckoutOrderResponse> checkoutOrder(
      $pb.ServerContext ctx, $5.CheckoutOrderRequest request);
  $async.Future<$5.ConfirmOrderPaymentResponse> confirmOrderPayment(
      $pb.ServerContext ctx, $5.ConfirmOrderPaymentRequest request);
  $async.Future<$5.CancelOrderResponse> cancelOrder(
      $pb.ServerContext ctx, $5.CancelOrderRequest request);
  $async.Future<$5.RecordOrderPaymentResponse> recordOrderPayment(
      $pb.ServerContext ctx, $5.RecordOrderPaymentRequest request);
  $async.Future<$5.ListOrderEventsResponse> listOrderEvents(
      $pb.ServerContext ctx, $5.ListOrderEventsRequest request);
  $async.Future<$5.ReconcilePaymentsResponse> reconcilePayments(
      $pb.ServerContext ctx, $5.ReconcilePaymentsRequest request);
  $async.Future<$5.RunEndOfDayLedgerResponse> runEndOfDayLedger(
      $pb.ServerContext ctx, $5.RunEndOfDayLedgerRequest request);
  $async.Future<$5.CreateFulfilmentResponse> createFulfilment(
      $pb.ServerContext ctx, $5.CreateFulfilmentRequest request);
  $async.Future<$5.UpdateFulfilmentResponse> updateFulfilment(
      $pb.ServerContext ctx, $5.UpdateFulfilmentRequest request);
  $async.Future<$5.GetFulfilmentResponse> getFulfilment(
      $pb.ServerContext ctx, $5.GetFulfilmentRequest request);
  $async.Future<$5.ListFulfilmentsResponse> listFulfilments(
      $pb.ServerContext ctx, $5.ListFulfilmentsRequest request);
  $async.Future<$5.PriceListSaveResponse> priceListSave(
      $pb.ServerContext ctx, $5.PriceListSaveRequest request);
  $async.Future<$5.PriceListGetResponse> priceListGet(
      $pb.ServerContext ctx, $5.PriceListGetRequest request);
  $async.Future<$5.PriceListSearchResponse> priceListSearch(
      $pb.ServerContext ctx, $5.PriceListSearchRequest request);
  $async.Future<$5.PriceListEntryBatchSaveResponse> priceListEntryBatchSave(
      $pb.ServerContext ctx, $5.PriceListEntryBatchSaveRequest request);
  $async.Future<$5.CustomerPriceListAssignmentSaveResponse>
      customerPriceListAssignmentSave($pb.ServerContext ctx,
          $5.CustomerPriceListAssignmentSaveRequest request);
  $async.Future<$5.CustomerPriceListAssignmentSearchResponse>
      customerPriceListAssignmentSearch($pb.ServerContext ctx,
          $5.CustomerPriceListAssignmentSearchRequest request);
  $async.Future<$5.CustomerPriceOverrideSaveResponse> customerPriceOverrideSave(
      $pb.ServerContext ctx, $5.CustomerPriceOverrideSaveRequest request);
  $async.Future<$5.CustomerPriceOverrideSearchResponse>
      customerPriceOverrideSearch(
          $pb.ServerContext ctx, $5.CustomerPriceOverrideSearchRequest request);
  $async.Future<$5.DiscountRuleSaveResponse> discountRuleSave(
      $pb.ServerContext ctx, $5.DiscountRuleSaveRequest request);
  $async.Future<$5.DiscountRuleSearchResponse> discountRuleSearch(
      $pb.ServerContext ctx, $5.DiscountRuleSearchRequest request);
  $async.Future<$5.DiscountRuleApproveResponse> discountRuleApprove(
      $pb.ServerContext ctx, $5.DiscountRuleApproveRequest request);
  $async.Future<$5.ResolvePriceResponse> resolvePrice(
      $pb.ServerContext ctx, $5.ResolvePriceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateShop':
        return $5.CreateShopRequest();
      case 'GetShop':
        return $5.GetShopRequest();
      case 'UpdateShop':
        return $5.UpdateShopRequest();
      case 'ListShops':
        return $5.ListShopsRequest();
      case 'ResolveDefaultCurrency':
        return $5.ResolveDefaultCurrencyRequest();
      case 'CreateProduct':
        return $5.CreateProductRequest();
      case 'GetProduct':
        return $5.GetProductRequest();
      case 'ListProducts':
        return $5.ListProductsRequest();
      case 'CreateProductVariant':
        return $5.CreateProductVariantRequest();
      case 'UpdateProductVariant':
        return $5.UpdateProductVariantRequest();
      case 'UpdateProduct':
        return $5.UpdateProductRequest();
      case 'ListProductVariants':
        return $5.ListProductVariantsRequest();
      case 'ReceiveStock':
        return $5.ReceiveStockRequest();
      case 'CreateCart':
        return $5.CreateCartRequest();
      case 'GetCart':
        return $5.GetCartRequest();
      case 'AddCartLine':
        return $5.AddCartLineRequest();
      case 'RemoveCartLine':
        return $5.RemoveCartLineRequest();
      case 'CreateOrderFromCart':
        return $5.CreateOrderFromCartRequest();
      case 'CreateOrder':
        return $5.CreateOrderRequest();
      case 'GetOrder':
        return $5.GetOrderRequest();
      case 'ListOrders':
        return $5.ListOrdersRequest();
      case 'CheckoutOrder':
        return $5.CheckoutOrderRequest();
      case 'ConfirmOrderPayment':
        return $5.ConfirmOrderPaymentRequest();
      case 'CancelOrder':
        return $5.CancelOrderRequest();
      case 'RecordOrderPayment':
        return $5.RecordOrderPaymentRequest();
      case 'ListOrderEvents':
        return $5.ListOrderEventsRequest();
      case 'ReconcilePayments':
        return $5.ReconcilePaymentsRequest();
      case 'RunEndOfDayLedger':
        return $5.RunEndOfDayLedgerRequest();
      case 'CreateFulfilment':
        return $5.CreateFulfilmentRequest();
      case 'UpdateFulfilment':
        return $5.UpdateFulfilmentRequest();
      case 'GetFulfilment':
        return $5.GetFulfilmentRequest();
      case 'ListFulfilments':
        return $5.ListFulfilmentsRequest();
      case 'PriceListSave':
        return $5.PriceListSaveRequest();
      case 'PriceListGet':
        return $5.PriceListGetRequest();
      case 'PriceListSearch':
        return $5.PriceListSearchRequest();
      case 'PriceListEntryBatchSave':
        return $5.PriceListEntryBatchSaveRequest();
      case 'CustomerPriceListAssignmentSave':
        return $5.CustomerPriceListAssignmentSaveRequest();
      case 'CustomerPriceListAssignmentSearch':
        return $5.CustomerPriceListAssignmentSearchRequest();
      case 'CustomerPriceOverrideSave':
        return $5.CustomerPriceOverrideSaveRequest();
      case 'CustomerPriceOverrideSearch':
        return $5.CustomerPriceOverrideSearchRequest();
      case 'DiscountRuleSave':
        return $5.DiscountRuleSaveRequest();
      case 'DiscountRuleSearch':
        return $5.DiscountRuleSearchRequest();
      case 'DiscountRuleApprove':
        return $5.DiscountRuleApproveRequest();
      case 'ResolvePrice':
        return $5.ResolvePriceRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateShop':
        return createShop(ctx, request as $5.CreateShopRequest);
      case 'GetShop':
        return getShop(ctx, request as $5.GetShopRequest);
      case 'UpdateShop':
        return updateShop(ctx, request as $5.UpdateShopRequest);
      case 'ListShops':
        return listShops(ctx, request as $5.ListShopsRequest);
      case 'ResolveDefaultCurrency':
        return resolveDefaultCurrency(
            ctx, request as $5.ResolveDefaultCurrencyRequest);
      case 'CreateProduct':
        return createProduct(ctx, request as $5.CreateProductRequest);
      case 'GetProduct':
        return getProduct(ctx, request as $5.GetProductRequest);
      case 'ListProducts':
        return listProducts(ctx, request as $5.ListProductsRequest);
      case 'CreateProductVariant':
        return createProductVariant(
            ctx, request as $5.CreateProductVariantRequest);
      case 'UpdateProductVariant':
        return updateProductVariant(
            ctx, request as $5.UpdateProductVariantRequest);
      case 'UpdateProduct':
        return updateProduct(ctx, request as $5.UpdateProductRequest);
      case 'ListProductVariants':
        return listProductVariants(
            ctx, request as $5.ListProductVariantsRequest);
      case 'ReceiveStock':
        return receiveStock(ctx, request as $5.ReceiveStockRequest);
      case 'CreateCart':
        return createCart(ctx, request as $5.CreateCartRequest);
      case 'GetCart':
        return getCart(ctx, request as $5.GetCartRequest);
      case 'AddCartLine':
        return addCartLine(ctx, request as $5.AddCartLineRequest);
      case 'RemoveCartLine':
        return removeCartLine(ctx, request as $5.RemoveCartLineRequest);
      case 'CreateOrderFromCart':
        return createOrderFromCart(
            ctx, request as $5.CreateOrderFromCartRequest);
      case 'CreateOrder':
        return createOrder(ctx, request as $5.CreateOrderRequest);
      case 'GetOrder':
        return getOrder(ctx, request as $5.GetOrderRequest);
      case 'ListOrders':
        return listOrders(ctx, request as $5.ListOrdersRequest);
      case 'CheckoutOrder':
        return checkoutOrder(ctx, request as $5.CheckoutOrderRequest);
      case 'ConfirmOrderPayment':
        return confirmOrderPayment(
            ctx, request as $5.ConfirmOrderPaymentRequest);
      case 'CancelOrder':
        return cancelOrder(ctx, request as $5.CancelOrderRequest);
      case 'RecordOrderPayment':
        return recordOrderPayment(ctx, request as $5.RecordOrderPaymentRequest);
      case 'ListOrderEvents':
        return listOrderEvents(ctx, request as $5.ListOrderEventsRequest);
      case 'ReconcilePayments':
        return reconcilePayments(ctx, request as $5.ReconcilePaymentsRequest);
      case 'RunEndOfDayLedger':
        return runEndOfDayLedger(ctx, request as $5.RunEndOfDayLedgerRequest);
      case 'CreateFulfilment':
        return createFulfilment(ctx, request as $5.CreateFulfilmentRequest);
      case 'UpdateFulfilment':
        return updateFulfilment(ctx, request as $5.UpdateFulfilmentRequest);
      case 'GetFulfilment':
        return getFulfilment(ctx, request as $5.GetFulfilmentRequest);
      case 'ListFulfilments':
        return listFulfilments(ctx, request as $5.ListFulfilmentsRequest);
      case 'PriceListSave':
        return priceListSave(ctx, request as $5.PriceListSaveRequest);
      case 'PriceListGet':
        return priceListGet(ctx, request as $5.PriceListGetRequest);
      case 'PriceListSearch':
        return priceListSearch(ctx, request as $5.PriceListSearchRequest);
      case 'PriceListEntryBatchSave':
        return priceListEntryBatchSave(
            ctx, request as $5.PriceListEntryBatchSaveRequest);
      case 'CustomerPriceListAssignmentSave':
        return customerPriceListAssignmentSave(
            ctx, request as $5.CustomerPriceListAssignmentSaveRequest);
      case 'CustomerPriceListAssignmentSearch':
        return customerPriceListAssignmentSearch(
            ctx, request as $5.CustomerPriceListAssignmentSearchRequest);
      case 'CustomerPriceOverrideSave':
        return customerPriceOverrideSave(
            ctx, request as $5.CustomerPriceOverrideSaveRequest);
      case 'CustomerPriceOverrideSearch':
        return customerPriceOverrideSearch(
            ctx, request as $5.CustomerPriceOverrideSearchRequest);
      case 'DiscountRuleSave':
        return discountRuleSave(ctx, request as $5.DiscountRuleSaveRequest);
      case 'DiscountRuleSearch':
        return discountRuleSearch(ctx, request as $5.DiscountRuleSearchRequest);
      case 'DiscountRuleApprove':
        return discountRuleApprove(
            ctx, request as $5.DiscountRuleApproveRequest);
      case 'ResolvePrice':
        return resolvePrice(ctx, request as $5.ResolvePriceRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CommerceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CommerceServiceBase$messageJson;
}
