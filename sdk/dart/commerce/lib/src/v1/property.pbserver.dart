//
//  Generated code. Do not modify.
//  source: v1/property.proto
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

import 'property.pb.dart' as $10;
import 'property.pbjson.dart';

export 'property.pb.dart';

abstract class PropertyServiceBase extends $pb.GeneratedService {
  $async.Future<$10.AddPropertyTypeResponse> addPropertyType($pb.ServerContext ctx, $10.AddPropertyTypeRequest request);
  $async.Future<$10.ListPropertyTypeResponse> listPropertyType($pb.ServerContext ctx, $10.ListPropertyTypeRequest request);
  $async.Future<$10.AddLocalityResponse> addLocality($pb.ServerContext ctx, $10.AddLocalityRequest request);
  $async.Future<$10.DeleteLocalityResponse> deleteLocality($pb.ServerContext ctx, $10.DeleteLocalityRequest request);
  $async.Future<$10.CreatePropertyResponse> createProperty($pb.ServerContext ctx, $10.CreatePropertyRequest request);
  $async.Future<$10.UpdatePropertyResponse> updateProperty($pb.ServerContext ctx, $10.UpdatePropertyRequest request);
  $async.Future<$10.DeletePropertyResponse> deleteProperty($pb.ServerContext ctx, $10.DeletePropertyRequest request);
  $async.Future<$10.StateOfPropertyResponse> stateOfProperty($pb.ServerContext ctx, $10.StateOfPropertyRequest request);
  $async.Future<$10.HistoryOfPropertyResponse> historyOfProperty($pb.ServerContext ctx, $10.HistoryOfPropertyRequest request);
  $async.Future<$10.SearchPropertyResponse> searchProperty($pb.ServerContext ctx, $10.SearchPropertyRequest request);
  $async.Future<$10.ListSubscriptionResponse> listSubscription($pb.ServerContext ctx, $10.ListSubscriptionRequest request);
  $async.Future<$10.AddSubscriptionResponse> addSubscription($pb.ServerContext ctx, $10.AddSubscriptionRequest request);
  $async.Future<$10.DeleteSubscriptionResponse> deleteSubscription($pb.ServerContext ctx, $10.DeleteSubscriptionRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AddPropertyType': return $10.AddPropertyTypeRequest();
      case 'ListPropertyType': return $10.ListPropertyTypeRequest();
      case 'AddLocality': return $10.AddLocalityRequest();
      case 'DeleteLocality': return $10.DeleteLocalityRequest();
      case 'CreateProperty': return $10.CreatePropertyRequest();
      case 'UpdateProperty': return $10.UpdatePropertyRequest();
      case 'DeleteProperty': return $10.DeletePropertyRequest();
      case 'StateOfProperty': return $10.StateOfPropertyRequest();
      case 'HistoryOfProperty': return $10.HistoryOfPropertyRequest();
      case 'SearchProperty': return $10.SearchPropertyRequest();
      case 'ListSubscription': return $10.ListSubscriptionRequest();
      case 'AddSubscription': return $10.AddSubscriptionRequest();
      case 'DeleteSubscription': return $10.DeleteSubscriptionRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AddPropertyType': return this.addPropertyType(ctx, request as $10.AddPropertyTypeRequest);
      case 'ListPropertyType': return this.listPropertyType(ctx, request as $10.ListPropertyTypeRequest);
      case 'AddLocality': return this.addLocality(ctx, request as $10.AddLocalityRequest);
      case 'DeleteLocality': return this.deleteLocality(ctx, request as $10.DeleteLocalityRequest);
      case 'CreateProperty': return this.createProperty(ctx, request as $10.CreatePropertyRequest);
      case 'UpdateProperty': return this.updateProperty(ctx, request as $10.UpdatePropertyRequest);
      case 'DeleteProperty': return this.deleteProperty(ctx, request as $10.DeletePropertyRequest);
      case 'StateOfProperty': return this.stateOfProperty(ctx, request as $10.StateOfPropertyRequest);
      case 'HistoryOfProperty': return this.historyOfProperty(ctx, request as $10.HistoryOfPropertyRequest);
      case 'SearchProperty': return this.searchProperty(ctx, request as $10.SearchPropertyRequest);
      case 'ListSubscription': return this.listSubscription(ctx, request as $10.ListSubscriptionRequest);
      case 'AddSubscription': return this.addSubscription(ctx, request as $10.AddSubscriptionRequest);
      case 'DeleteSubscription': return this.deleteSubscription(ctx, request as $10.DeleteSubscriptionRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => PropertyServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => PropertyServiceBase$messageJson;
}

