//
//  Generated code. Do not modify.
//  source: v1/property.proto
//

import "package:connectrpc/connect.dart" as connect;
import "property.pb.dart" as v1property;

/// PropertyService manages real estate and asset properties.
/// All RPCs require authentication via Bearer token.
abstract final class PropertyService {
  /// Fully-qualified name of the PropertyService service.
  static const name = 'property.v1.PropertyService';

  /// AddPropertyType creates a new property type classification.
  static const addPropertyType = connect.Spec(
    '/$name/AddPropertyType',
    connect.StreamType.unary,
    v1property.AddPropertyTypeRequest.new,
    v1property.AddPropertyTypeResponse.new,
  );

  /// ListPropertyType retrieves all property types.
  static const listPropertyType = connect.Spec(
    '/$name/ListPropertyType',
    connect.StreamType.server,
    v1property.ListPropertyTypeRequest.new,
    v1property.ListPropertyTypeResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// AddLocality creates a new geographic locality.
  static const addLocality = connect.Spec(
    '/$name/AddLocality',
    connect.StreamType.unary,
    v1property.AddLocalityRequest.new,
    v1property.AddLocalityResponse.new,
  );

  /// DeleteLocality removes a locality from the system.
  static const deleteLocality = connect.Spec(
    '/$name/DeleteLocality',
    connect.StreamType.unary,
    v1property.DeleteLocalityRequest.new,
    v1property.DeleteLocalityResponse.new,
  );

  /// CreateProperty creates a new property.
  static const createProperty = connect.Spec(
    '/$name/CreateProperty',
    connect.StreamType.unary,
    v1property.CreatePropertyRequest.new,
    v1property.CreatePropertyResponse.new,
  );

  /// UpdateProperty updates an existing property.
  static const updateProperty = connect.Spec(
    '/$name/UpdateProperty',
    connect.StreamType.unary,
    v1property.UpdatePropertyRequest.new,
    v1property.UpdatePropertyResponse.new,
  );

  /// DeleteProperty removes a property from the system.
  static const deleteProperty = connect.Spec(
    '/$name/DeleteProperty',
    connect.StreamType.unary,
    v1property.DeletePropertyRequest.new,
    v1property.DeletePropertyResponse.new,
  );

  /// StateOfProperty retrieves the current state of a property.
  static const stateOfProperty = connect.Spec(
    '/$name/StateOfProperty',
    connect.StreamType.unary,
    v1property.StateOfPropertyRequest.new,
    v1property.StateOfPropertyResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// HistoryOfProperty retrieves the complete state history.
  static const historyOfProperty = connect.Spec(
    '/$name/HistoryOfProperty',
    connect.StreamType.server,
    v1property.HistoryOfPropertyRequest.new,
    v1property.HistoryOfPropertyResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// SearchProperty finds properties matching criteria.
  static const searchProperty = connect.Spec(
    '/$name/SearchProperty',
    connect.StreamType.server,
    v1property.SearchPropertyRequest.new,
    v1property.SearchPropertyResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ListSubscription retrieves subscriptions for a property.
  static const listSubscription = connect.Spec(
    '/$name/ListSubscription',
    connect.StreamType.server,
    v1property.ListSubscriptionRequest.new,
    v1property.ListSubscriptionResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// AddSubscription grants a profile access to a property.
  static const addSubscription = connect.Spec(
    '/$name/AddSubscription',
    connect.StreamType.unary,
    v1property.AddSubscriptionRequest.new,
    v1property.AddSubscriptionResponse.new,
  );

  /// DeleteSubscription revokes a profile's access to a property.
  static const deleteSubscription = connect.Spec(
    '/$name/DeleteSubscription',
    connect.StreamType.unary,
    v1property.DeleteSubscriptionRequest.new,
    v1property.DeleteSubscriptionResponse.new,
  );
}
