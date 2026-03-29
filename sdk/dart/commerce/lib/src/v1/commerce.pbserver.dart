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
  $async.Future<$9.CreateProductResponse> createProduct($pb.ServerContext ctx, $9.CreateProductRequest request);
  $async.Future<$9.GetProductResponse> getProduct($pb.ServerContext ctx, $9.GetProductRequest request);
  $async.Future<$9.ListProductsResponse> listProducts($pb.ServerContext ctx, $9.ListProductsRequest request);
  $async.Future<$9.CreateProductVariantResponse> createProductVariant($pb.ServerContext ctx, $9.CreateProductVariantRequest request);
  $async.Future<$9.UpdateProductVariantResponse> updateProductVariant($pb.ServerContext ctx, $9.UpdateProductVariantRequest request);
  $async.Future<$9.CreateCartResponse> createCart($pb.ServerContext ctx, $9.CreateCartRequest request);
  $async.Future<$9.GetCartResponse> getCart($pb.ServerContext ctx, $9.GetCartRequest request);
  $async.Future<$9.AddCartLineResponse> addCartLine($pb.ServerContext ctx, $9.AddCartLineRequest request);
  $async.Future<$9.RemoveCartLineResponse> removeCartLine($pb.ServerContext ctx, $9.RemoveCartLineRequest request);
  $async.Future<$9.CreateOrderFromCartResponse> createOrderFromCart($pb.ServerContext ctx, $9.CreateOrderFromCartRequest request);
  $async.Future<$9.CreateOrderResponse> createOrder($pb.ServerContext ctx, $9.CreateOrderRequest request);
  $async.Future<$9.GetOrderResponse> getOrder($pb.ServerContext ctx, $9.GetOrderRequest request);
  $async.Future<$9.ListOrdersResponse> listOrders($pb.ServerContext ctx, $9.ListOrdersRequest request);
  $async.Future<$9.CreateFulfilmentResponse> createFulfilment($pb.ServerContext ctx, $9.CreateFulfilmentRequest request);
  $async.Future<$9.UpdateFulfilmentResponse> updateFulfilment($pb.ServerContext ctx, $9.UpdateFulfilmentRequest request);
  $async.Future<$9.GetFulfilmentResponse> getFulfilment($pb.ServerContext ctx, $9.GetFulfilmentRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateShop': return $9.CreateShopRequest();
      case 'GetShop': return $9.GetShopRequest();
      case 'UpdateShop': return $9.UpdateShopRequest();
      case 'CreateProduct': return $9.CreateProductRequest();
      case 'GetProduct': return $9.GetProductRequest();
      case 'ListProducts': return $9.ListProductsRequest();
      case 'CreateProductVariant': return $9.CreateProductVariantRequest();
      case 'UpdateProductVariant': return $9.UpdateProductVariantRequest();
      case 'CreateCart': return $9.CreateCartRequest();
      case 'GetCart': return $9.GetCartRequest();
      case 'AddCartLine': return $9.AddCartLineRequest();
      case 'RemoveCartLine': return $9.RemoveCartLineRequest();
      case 'CreateOrderFromCart': return $9.CreateOrderFromCartRequest();
      case 'CreateOrder': return $9.CreateOrderRequest();
      case 'GetOrder': return $9.GetOrderRequest();
      case 'ListOrders': return $9.ListOrdersRequest();
      case 'CreateFulfilment': return $9.CreateFulfilmentRequest();
      case 'UpdateFulfilment': return $9.UpdateFulfilmentRequest();
      case 'GetFulfilment': return $9.GetFulfilmentRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateShop': return this.createShop(ctx, request as $9.CreateShopRequest);
      case 'GetShop': return this.getShop(ctx, request as $9.GetShopRequest);
      case 'UpdateShop': return this.updateShop(ctx, request as $9.UpdateShopRequest);
      case 'CreateProduct': return this.createProduct(ctx, request as $9.CreateProductRequest);
      case 'GetProduct': return this.getProduct(ctx, request as $9.GetProductRequest);
      case 'ListProducts': return this.listProducts(ctx, request as $9.ListProductsRequest);
      case 'CreateProductVariant': return this.createProductVariant(ctx, request as $9.CreateProductVariantRequest);
      case 'UpdateProductVariant': return this.updateProductVariant(ctx, request as $9.UpdateProductVariantRequest);
      case 'CreateCart': return this.createCart(ctx, request as $9.CreateCartRequest);
      case 'GetCart': return this.getCart(ctx, request as $9.GetCartRequest);
      case 'AddCartLine': return this.addCartLine(ctx, request as $9.AddCartLineRequest);
      case 'RemoveCartLine': return this.removeCartLine(ctx, request as $9.RemoveCartLineRequest);
      case 'CreateOrderFromCart': return this.createOrderFromCart(ctx, request as $9.CreateOrderFromCartRequest);
      case 'CreateOrder': return this.createOrder(ctx, request as $9.CreateOrderRequest);
      case 'GetOrder': return this.getOrder(ctx, request as $9.GetOrderRequest);
      case 'ListOrders': return this.listOrders(ctx, request as $9.ListOrdersRequest);
      case 'CreateFulfilment': return this.createFulfilment(ctx, request as $9.CreateFulfilmentRequest);
      case 'UpdateFulfilment': return this.updateFulfilment(ctx, request as $9.UpdateFulfilmentRequest);
      case 'GetFulfilment': return this.getFulfilment(ctx, request as $9.GetFulfilmentRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CommerceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CommerceServiceBase$messageJson;
}

