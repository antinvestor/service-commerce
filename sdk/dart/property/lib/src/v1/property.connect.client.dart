//
//  Generated code. Do not modify.
//  source: v1/property.proto
//

import "package:connectrpc/connect.dart" as connect;
import "property.pb.dart" as v1property;
import "property.connect.spec.dart" as specs;

/// PropertyService manages real estate and asset properties.
/// All RPCs require authentication via Bearer token.
extension type PropertyServiceClient (connect.Transport _transport) {
  /// AddPropertyType creates a new property type classification.
  Future<v1property.AddPropertyTypeResponse> addPropertyType(
    v1property.AddPropertyTypeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.addPropertyType,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ListPropertyType retrieves all property types.
  Stream<v1property.ListPropertyTypeResponse> listPropertyType(
    v1property.ListPropertyTypeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.PropertyService.listPropertyType,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// AddLocality creates a new geographic locality.
  Future<v1property.AddLocalityResponse> addLocality(
    v1property.AddLocalityRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.addLocality,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DeleteLocality removes a locality from the system.
  Future<v1property.DeleteLocalityResponse> deleteLocality(
    v1property.DeleteLocalityRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.deleteLocality,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CreateProperty creates a new property.
  Future<v1property.CreatePropertyResponse> createProperty(
    v1property.CreatePropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.createProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// UpdateProperty updates an existing property.
  Future<v1property.UpdatePropertyResponse> updateProperty(
    v1property.UpdatePropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.updateProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DeleteProperty removes a property from the system.
  Future<v1property.DeletePropertyResponse> deleteProperty(
    v1property.DeletePropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.deleteProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// StateOfProperty retrieves the current state of a property.
  Future<v1property.StateOfPropertyResponse> stateOfProperty(
    v1property.StateOfPropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.stateOfProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// HistoryOfProperty retrieves the complete state history.
  Stream<v1property.HistoryOfPropertyResponse> historyOfProperty(
    v1property.HistoryOfPropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.PropertyService.historyOfProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SearchProperty finds properties matching criteria.
  Stream<v1property.SearchPropertyResponse> searchProperty(
    v1property.SearchPropertyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.PropertyService.searchProperty,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ListSubscription retrieves subscriptions for a property.
  Stream<v1property.ListSubscriptionResponse> listSubscription(
    v1property.ListSubscriptionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.PropertyService.listSubscription,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// AddSubscription grants a profile access to a property.
  Future<v1property.AddSubscriptionResponse> addSubscription(
    v1property.AddSubscriptionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.addSubscription,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DeleteSubscription revokes a profile's access to a property.
  Future<v1property.DeleteSubscriptionResponse> deleteSubscription(
    v1property.DeleteSubscriptionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.PropertyService.deleteSubscription,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
