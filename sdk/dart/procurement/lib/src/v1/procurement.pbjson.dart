//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../common/v1/common.pbjson.dart' as $8;
import '../common/v1/money.pbjson.dart' as $7;
import '../google/protobuf/struct.pbjson.dart' as $6;
import '../google/protobuf/timestamp.pbjson.dart' as $2;

@$core.Deprecated('Use supplierTypeDescriptor instead')
const SupplierType$json = {
  '1': 'SupplierType',
  '2': [
    {'1': 'SUPPLIER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SUPPLIER_TYPE_RAW_MATERIAL', '2': 1},
    {'1': 'SUPPLIER_TYPE_PACKAGING', '2': 2},
    {'1': 'SUPPLIER_TYPE_SERVICE', '2': 3},
    {'1': 'SUPPLIER_TYPE_EQUIPMENT', '2': 4},
  ],
};

/// Descriptor for `SupplierType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List supplierTypeDescriptor = $convert.base64Decode(
    'CgxTdXBwbGllclR5cGUSHQoZU1VQUExJRVJfVFlQRV9VTlNQRUNJRklFRBAAEh4KGlNVUFBMSU'
    'VSX1RZUEVfUkFXX01BVEVSSUFMEAESGwoXU1VQUExJRVJfVFlQRV9QQUNLQUdJTkcQAhIZChVT'
    'VVBQTElFUl9UWVBFX1NFUlZJQ0UQAxIbChdTVVBQTElFUl9UWVBFX0VRVUlQTUVOVBAE');

@$core.Deprecated('Use supplierStatusDescriptor instead')
const SupplierStatus$json = {
  '1': 'SupplierStatus',
  '2': [
    {'1': 'SUPPLIER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SUPPLIER_STATUS_ACTIVE', '2': 1},
    {'1': 'SUPPLIER_STATUS_SUSPENDED', '2': 2},
    {'1': 'SUPPLIER_STATUS_INACTIVE', '2': 3},
  ],
};

/// Descriptor for `SupplierStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List supplierStatusDescriptor = $convert.base64Decode(
    'Cg5TdXBwbGllclN0YXR1cxIfChtTVVBQTElFUl9TVEFUVVNfVU5TUEVDSUZJRUQQABIaChZTVV'
    'BQTElFUl9TVEFUVVNfQUNUSVZFEAESHQoZU1VQUExJRVJfU1RBVFVTX1NVU1BFTkRFRBACEhwK'
    'GFNVUFBMSUVSX1NUQVRVU19JTkFDVElWRRAD');

@$core.Deprecated('Use supplierRatingDescriptor instead')
const SupplierRating$json = {
  '1': 'SupplierRating',
  '2': [
    {'1': 'SUPPLIER_RATING_UNSPECIFIED', '2': 0},
    {'1': 'SUPPLIER_RATING_UNRATED', '2': 1},
    {'1': 'SUPPLIER_RATING_APPROVED', '2': 2},
    {'1': 'SUPPLIER_RATING_PREFERRED', '2': 3},
    {'1': 'SUPPLIER_RATING_PROBATION', '2': 4},
  ],
};

/// Descriptor for `SupplierRating`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List supplierRatingDescriptor = $convert.base64Decode(
    'Cg5TdXBwbGllclJhdGluZxIfChtTVVBQTElFUl9SQVRJTkdfVU5TUEVDSUZJRUQQABIbChdTVV'
    'BQTElFUl9SQVRJTkdfVU5SQVRFRBABEhwKGFNVUFBMSUVSX1JBVElOR19BUFBST1ZFRBACEh0K'
    'GVNVUFBMSUVSX1JBVElOR19QUkVGRVJSRUQQAxIdChlTVVBQTElFUl9SQVRJTkdfUFJPQkFUSU'
    '9OEAQ=');

@$core.Deprecated('Use supplierItemStatusDescriptor instead')
const SupplierItemStatus$json = {
  '1': 'SupplierItemStatus',
  '2': [
    {'1': 'SUPPLIER_ITEM_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SUPPLIER_ITEM_STATUS_ACTIVE', '2': 1},
    {'1': 'SUPPLIER_ITEM_STATUS_DISCONTINUED', '2': 2},
  ],
};

/// Descriptor for `SupplierItemStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List supplierItemStatusDescriptor = $convert.base64Decode(
    'ChJTdXBwbGllckl0ZW1TdGF0dXMSJAogU1VQUExJRVJfSVRFTV9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIfChtTVVBQTElFUl9JVEVNX1NUQVRVU19BQ1RJVkUQARIlCiFTVVBQTElFUl9JVEVNX1NU'
    'QVRVU19ESVNDT05USU5VRUQQAg==');

@$core.Deprecated('Use purchaseOrderStatusDescriptor instead')
const PurchaseOrderStatus$json = {
  '1': 'PurchaseOrderStatus',
  '2': [
    {'1': 'PURCHASE_ORDER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PURCHASE_ORDER_STATUS_DRAFT', '2': 1},
    {'1': 'PURCHASE_ORDER_STATUS_SUBMITTED', '2': 2},
    {'1': 'PURCHASE_ORDER_STATUS_CONFIRMED', '2': 3},
    {'1': 'PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED', '2': 4},
    {'1': 'PURCHASE_ORDER_STATUS_RECEIVED', '2': 5},
    {'1': 'PURCHASE_ORDER_STATUS_CANCELLED', '2': 6},
  ],
};

/// Descriptor for `PurchaseOrderStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List purchaseOrderStatusDescriptor = $convert.base64Decode(
    'ChNQdXJjaGFzZU9yZGVyU3RhdHVzEiUKIVBVUkNIQVNFX09SREVSX1NUQVRVU19VTlNQRUNJRk'
    'lFRBAAEh8KG1BVUkNIQVNFX09SREVSX1NUQVRVU19EUkFGVBABEiMKH1BVUkNIQVNFX09SREVS'
    'X1NUQVRVU19TVUJNSVRURUQQAhIjCh9QVVJDSEFTRV9PUkRFUl9TVEFUVVNfQ09ORklSTUVEEA'
    'MSLAooUFVSQ0hBU0VfT1JERVJfU1RBVFVTX1BBUlRJQUxMWV9SRUNFSVZFRBAEEiIKHlBVUkNI'
    'QVNFX09SREVSX1NUQVRVU19SRUNFSVZFRBAFEiMKH1BVUkNIQVNFX09SREVSX1NUQVRVU19DQU'
    '5DRUxMRUQQBg==');

@$core.Deprecated('Use purchaseOrderLineStatusDescriptor instead')
const PurchaseOrderLineStatus$json = {
  '1': 'PurchaseOrderLineStatus',
  '2': [
    {'1': 'PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PURCHASE_ORDER_LINE_STATUS_PENDING', '2': 1},
    {'1': 'PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED', '2': 2},
    {'1': 'PURCHASE_ORDER_LINE_STATUS_RECEIVED', '2': 3},
    {'1': 'PURCHASE_ORDER_LINE_STATUS_CANCELLED', '2': 4},
  ],
};

/// Descriptor for `PurchaseOrderLineStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List purchaseOrderLineStatusDescriptor = $convert.base64Decode(
    'ChdQdXJjaGFzZU9yZGVyTGluZVN0YXR1cxIqCiZQVVJDSEFTRV9PUkRFUl9MSU5FX1NUQVRVU1'
    '9VTlNQRUNJRklFRBAAEiYKIlBVUkNIQVNFX09SREVSX0xJTkVfU1RBVFVTX1BFTkRJTkcQARIx'
    'Ci1QVVJDSEFTRV9PUkRFUl9MSU5FX1NUQVRVU19QQVJUSUFMTFlfUkVDRUlWRUQQAhInCiNQVV'
    'JDSEFTRV9PUkRFUl9MSU5FX1NUQVRVU19SRUNFSVZFRBADEigKJFBVUkNIQVNFX09SREVSX0xJ'
    'TkVfU1RBVFVTX0NBTkNFTExFRBAE');

@$core.Deprecated('Use goodsReceiptStatusDescriptor instead')
const GoodsReceiptStatus$json = {
  '1': 'GoodsReceiptStatus',
  '2': [
    {'1': 'GOODS_RECEIPT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'GOODS_RECEIPT_STATUS_PENDING_INSPECTION', '2': 1},
    {'1': 'GOODS_RECEIPT_STATUS_ACCEPTED', '2': 2},
    {'1': 'GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED', '2': 3},
    {'1': 'GOODS_RECEIPT_STATUS_REJECTED', '2': 4},
  ],
};

/// Descriptor for `GoodsReceiptStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List goodsReceiptStatusDescriptor = $convert.base64Decode(
    'ChJHb29kc1JlY2VpcHRTdGF0dXMSJAogR09PRFNfUkVDRUlQVF9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIrCidHT09EU19SRUNFSVBUX1NUQVRVU19QRU5ESU5HX0lOU1BFQ1RJT04QARIhCh1HT09E'
    'U19SRUNFSVBUX1NUQVRVU19BQ0NFUFRFRBACEisKJ0dPT0RTX1JFQ0VJUFRfU1RBVFVTX1BBUl'
    'RJQUxMWV9BQ0NFUFRFRBADEiEKHUdPT0RTX1JFQ0VJUFRfU1RBVFVTX1JFSkVDVEVEEAQ=');

@$core.Deprecated('Use supplierDescriptor instead')
const Supplier$json = {
  '1': 'Supplier',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'profile_id', '3': 2, '4': 1, '5': 9, '10': 'profileId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'supplier_type', '3': 4, '4': 1, '5': 14, '6': '.procurement.v1.SupplierType', '10': 'supplierType'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.procurement.v1.SupplierStatus', '10': 'status'},
    {'1': 'payment_terms_days', '3': 6, '4': 1, '5': 5, '10': 'paymentTermsDays'},
    {'1': 'currency', '3': 7, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'lead_time_days', '3': 8, '4': 1, '5': 5, '10': 'leadTimeDays'},
    {'1': 'rating', '3': 9, '4': 1, '5': 14, '6': '.procurement.v1.SupplierRating', '10': 'rating'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `Supplier`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierDescriptor = $convert.base64Decode(
    'CghTdXBwbGllchIOCgJpZBgBIAEoCVICaWQSHQoKcHJvZmlsZV9pZBgCIAEoCVIJcHJvZmlsZU'
    'lkEhIKBG5hbWUYAyABKAlSBG5hbWUSQQoNc3VwcGxpZXJfdHlwZRgEIAEoDjIcLnByb2N1cmVt'
    'ZW50LnYxLlN1cHBsaWVyVHlwZVIMc3VwcGxpZXJUeXBlEjYKBnN0YXR1cxgFIAEoDjIeLnByb2'
    'N1cmVtZW50LnYxLlN1cHBsaWVyU3RhdHVzUgZzdGF0dXMSLAoScGF5bWVudF90ZXJtc19kYXlz'
    'GAYgASgFUhBwYXltZW50VGVybXNEYXlzEhoKCGN1cnJlbmN5GAcgASgJUghjdXJyZW5jeRIkCg'
    '5sZWFkX3RpbWVfZGF5cxgIIAEoBVIMbGVhZFRpbWVEYXlzEjYKBnJhdGluZxgJIAEoDjIeLnBy'
    'b2N1cmVtZW50LnYxLlN1cHBsaWVyUmF0aW5nUgZyYXRpbmcSFAoFbm90ZXMYCiABKAlSBW5vdG'
    'VzEjkKCmNyZWF0ZWRfYXQYDyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVh'
    'dGVkQXQ=');

@$core.Deprecated('Use supplierItemDescriptor instead')
const SupplierItem$json = {
  '1': 'SupplierItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'supplier_id', '3': 2, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'inventory_item_id', '3': 3, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'supplier_sku', '3': 4, '4': 1, '5': 9, '10': 'supplierSku'},
    {'1': 'unit_price', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'min_order_quantity', '3': 6, '4': 1, '5': 1, '10': 'minOrderQuantity'},
    {'1': 'unit', '3': 7, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'lead_time_days', '3': 8, '4': 1, '5': 5, '10': 'leadTimeDays'},
    {'1': 'status', '3': 9, '4': 1, '5': 14, '6': '.procurement.v1.SupplierItemStatus', '10': 'status'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `SupplierItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierItemDescriptor = $convert.base64Decode(
    'CgxTdXBwbGllckl0ZW0SDgoCaWQYASABKAlSAmlkEh8KC3N1cHBsaWVyX2lkGAIgASgJUgpzdX'
    'BwbGllcklkEioKEWludmVudG9yeV9pdGVtX2lkGAMgASgJUg9pbnZlbnRvcnlJdGVtSWQSIQoM'
    'c3VwcGxpZXJfc2t1GAQgASgJUgtzdXBwbGllclNrdRIvCgp1bml0X3ByaWNlGAUgASgLMhAuY2'
    '9tbW9uLnYxLk1vbmV5Ugl1bml0UHJpY2USLAoSbWluX29yZGVyX3F1YW50aXR5GAYgASgBUhBt'
    'aW5PcmRlclF1YW50aXR5EhIKBHVuaXQYByABKAlSBHVuaXQSJAoObGVhZF90aW1lX2RheXMYCC'
    'ABKAVSDGxlYWRUaW1lRGF5cxI6CgZzdGF0dXMYCSABKA4yIi5wcm9jdXJlbWVudC52MS5TdXBw'
    'bGllckl0ZW1TdGF0dXNSBnN0YXR1cxI5CgpjcmVhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use purchaseOrderDescriptor instead')
const PurchaseOrder$json = {
  '1': 'PurchaseOrder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'property_id', '3': 2, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'supplier_id', '3': 3, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'order_number', '3': 4, '4': 1, '5': 9, '10': 'orderNumber'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.procurement.v1.PurchaseOrderStatus', '10': 'status'},
    {'1': 'expected_delivery_date', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expectedDeliveryDate'},
    {'1': 'submitted_at', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'submittedAt'},
    {'1': 'submitted_by', '3': 8, '4': 1, '5': 9, '10': 'submittedBy'},
    {'1': 'total_amount', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalAmount'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'plan_id', '3': 11, '4': 1, '5': 9, '10': 'planId'},
    {'1': 'lines', '3': 12, '4': 3, '5': 11, '6': '.procurement.v1.PurchaseOrderLine', '10': 'lines'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `PurchaseOrder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderDescriptor = $convert.base64Decode(
    'Cg1QdXJjaGFzZU9yZGVyEg4KAmlkGAEgASgJUgJpZBIfCgtwcm9wZXJ0eV9pZBgCIAEoCVIKcH'
    'JvcGVydHlJZBIfCgtzdXBwbGllcl9pZBgDIAEoCVIKc3VwcGxpZXJJZBIhCgxvcmRlcl9udW1i'
    'ZXIYBCABKAlSC29yZGVyTnVtYmVyEjsKBnN0YXR1cxgFIAEoDjIjLnByb2N1cmVtZW50LnYxLl'
    'B1cmNoYXNlT3JkZXJTdGF0dXNSBnN0YXR1cxJQChZleHBlY3RlZF9kZWxpdmVyeV9kYXRlGAYg'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIUZXhwZWN0ZWREZWxpdmVyeURhdGUSPQ'
    'oMc3VibWl0dGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILc3VibWl0'
    'dGVkQXQSIQoMc3VibWl0dGVkX2J5GAggASgJUgtzdWJtaXR0ZWRCeRIzCgx0b3RhbF9hbW91bn'
    'QYCSABKAsyEC5jb21tb24udjEuTW9uZXlSC3RvdGFsQW1vdW50EhQKBW5vdGVzGAogASgJUgVu'
    'b3RlcxIXCgdwbGFuX2lkGAsgASgJUgZwbGFuSWQSNwoFbGluZXMYDCADKAsyIS5wcm9jdXJlbW'
    'VudC52MS5QdXJjaGFzZU9yZGVyTGluZVIFbGluZXMSOQoKY3JlYXRlZF9hdBgPIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use purchaseOrderLineDescriptor instead')
const PurchaseOrderLine$json = {
  '1': 'PurchaseOrderLine',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'purchase_order_id', '3': 2, '4': 1, '5': 9, '10': 'purchaseOrderId'},
    {'1': 'supplier_item_id', '3': 3, '4': 1, '5': 9, '10': 'supplierItemId'},
    {'1': 'inventory_item_id', '3': 4, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'ordered_quantity', '3': 5, '4': 1, '5': 1, '10': 'orderedQuantity'},
    {'1': 'received_quantity', '3': 6, '4': 1, '5': 1, '10': 'receivedQuantity'},
    {'1': 'unit_price', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'unit', '3': 8, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'status', '3': 9, '4': 1, '5': 14, '6': '.procurement.v1.PurchaseOrderLineStatus', '10': 'status'},
  ],
};

/// Descriptor for `PurchaseOrderLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderLineDescriptor = $convert.base64Decode(
    'ChFQdXJjaGFzZU9yZGVyTGluZRIOCgJpZBgBIAEoCVICaWQSKgoRcHVyY2hhc2Vfb3JkZXJfaW'
    'QYAiABKAlSD3B1cmNoYXNlT3JkZXJJZBIoChBzdXBwbGllcl9pdGVtX2lkGAMgASgJUg5zdXBw'
    'bGllckl0ZW1JZBIqChFpbnZlbnRvcnlfaXRlbV9pZBgEIAEoCVIPaW52ZW50b3J5SXRlbUlkEi'
    'kKEG9yZGVyZWRfcXVhbnRpdHkYBSABKAFSD29yZGVyZWRRdWFudGl0eRIrChFyZWNlaXZlZF9x'
    'dWFudGl0eRgGIAEoAVIQcmVjZWl2ZWRRdWFudGl0eRIvCgp1bml0X3ByaWNlGAcgASgLMhAuY2'
    '9tbW9uLnYxLk1vbmV5Ugl1bml0UHJpY2USEgoEdW5pdBgIIAEoCVIEdW5pdBI/CgZzdGF0dXMY'
    'CSABKA4yJy5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyTGluZVN0YXR1c1IGc3RhdHVz');

@$core.Deprecated('Use goodsReceiptDescriptor instead')
const GoodsReceipt$json = {
  '1': 'GoodsReceipt',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'purchase_order_id', '3': 2, '4': 1, '5': 9, '10': 'purchaseOrderId'},
    {'1': 'property_id', '3': 3, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'received_by', '3': 4, '4': 1, '5': 9, '10': 'receivedBy'},
    {'1': 'received_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'receivedAt'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.procurement.v1.GoodsReceiptStatus', '10': 'status'},
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'lines', '3': 8, '4': 3, '5': 11, '6': '.procurement.v1.GoodsReceiptLine', '10': 'lines'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `GoodsReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptDescriptor = $convert.base64Decode(
    'CgxHb29kc1JlY2VpcHQSDgoCaWQYASABKAlSAmlkEioKEXB1cmNoYXNlX29yZGVyX2lkGAIgAS'
    'gJUg9wdXJjaGFzZU9yZGVySWQSHwoLcHJvcGVydHlfaWQYAyABKAlSCnByb3BlcnR5SWQSHwoL'
    'cmVjZWl2ZWRfYnkYBCABKAlSCnJlY2VpdmVkQnkSOwoLcmVjZWl2ZWRfYXQYBSABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgpyZWNlaXZlZEF0EjoKBnN0YXR1cxgGIAEoDjIiLnBy'
    'b2N1cmVtZW50LnYxLkdvb2RzUmVjZWlwdFN0YXR1c1IGc3RhdHVzEhQKBW5vdGVzGAcgASgJUg'
    'Vub3RlcxI2CgVsaW5lcxgIIAMoCzIgLnByb2N1cmVtZW50LnYxLkdvb2RzUmVjZWlwdExpbmVS'
    'BWxpbmVzEjkKCmNyZWF0ZWRfYXQYDyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    'ljcmVhdGVkQXQ=');

@$core.Deprecated('Use goodsReceiptLineDescriptor instead')
const GoodsReceiptLine$json = {
  '1': 'GoodsReceiptLine',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'goods_receipt_id', '3': 2, '4': 1, '5': 9, '10': 'goodsReceiptId'},
    {'1': 'purchase_order_line_id', '3': 3, '4': 1, '5': 9, '10': 'purchaseOrderLineId'},
    {'1': 'inventory_item_id', '3': 4, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'received_quantity', '3': 5, '4': 1, '5': 1, '10': 'receivedQuantity'},
    {'1': 'accepted_quantity', '3': 6, '4': 1, '5': 1, '10': 'acceptedQuantity'},
    {'1': 'rejected_quantity', '3': 7, '4': 1, '5': 1, '10': 'rejectedQuantity'},
    {'1': 'rejection_reason', '3': 8, '4': 1, '5': 9, '10': 'rejectionReason'},
    {'1': 'lot_number', '3': 9, '4': 1, '5': 9, '10': 'lotNumber'},
    {'1': 'expiry_date', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiryDate'},
    {'1': 'unit', '3': 11, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `GoodsReceiptLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptLineDescriptor = $convert.base64Decode(
    'ChBHb29kc1JlY2VpcHRMaW5lEg4KAmlkGAEgASgJUgJpZBIoChBnb29kc19yZWNlaXB0X2lkGA'
    'IgASgJUg5nb29kc1JlY2VpcHRJZBIzChZwdXJjaGFzZV9vcmRlcl9saW5lX2lkGAMgASgJUhNw'
    'dXJjaGFzZU9yZGVyTGluZUlkEioKEWludmVudG9yeV9pdGVtX2lkGAQgASgJUg9pbnZlbnRvcn'
    'lJdGVtSWQSKwoRcmVjZWl2ZWRfcXVhbnRpdHkYBSABKAFSEHJlY2VpdmVkUXVhbnRpdHkSKwoR'
    'YWNjZXB0ZWRfcXVhbnRpdHkYBiABKAFSEGFjY2VwdGVkUXVhbnRpdHkSKwoRcmVqZWN0ZWRfcX'
    'VhbnRpdHkYByABKAFSEHJlamVjdGVkUXVhbnRpdHkSKQoQcmVqZWN0aW9uX3JlYXNvbhgIIAEo'
    'CVIPcmVqZWN0aW9uUmVhc29uEh0KCmxvdF9udW1iZXIYCSABKAlSCWxvdE51bWJlchI7CgtleH'
    'BpcnlfZGF0ZRgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmV4cGlyeURhdGUS'
    'EgoEdW5pdBgLIAEoCVIEdW5pdA==');

@$core.Deprecated('Use purchaseOrderSuggestionDescriptor instead')
const PurchaseOrderSuggestion$json = {
  '1': 'PurchaseOrderSuggestion',
  '2': [
    {'1': 'supplier_id', '3': 1, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'supplier_name', '3': 2, '4': 1, '5': 9, '10': 'supplierName'},
    {'1': 'lines', '3': 3, '4': 3, '5': 11, '6': '.procurement.v1.PurchaseOrderSuggestionLine', '10': 'lines'},
    {'1': 'estimated_total', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'estimatedTotal'},
  ],
};

/// Descriptor for `PurchaseOrderSuggestion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSuggestionDescriptor = $convert.base64Decode(
    'ChdQdXJjaGFzZU9yZGVyU3VnZ2VzdGlvbhIfCgtzdXBwbGllcl9pZBgBIAEoCVIKc3VwcGxpZX'
    'JJZBIjCg1zdXBwbGllcl9uYW1lGAIgASgJUgxzdXBwbGllck5hbWUSQQoFbGluZXMYAyADKAsy'
    'Ky5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyU3VnZ2VzdGlvbkxpbmVSBWxpbmVzEjkKD2'
    'VzdGltYXRlZF90b3RhbBgEIAEoCzIQLmNvbW1vbi52MS5Nb25leVIOZXN0aW1hdGVkVG90YWw=');

@$core.Deprecated('Use purchaseOrderSuggestionLineDescriptor instead')
const PurchaseOrderSuggestionLine$json = {
  '1': 'PurchaseOrderSuggestionLine',
  '2': [
    {'1': 'inventory_item_id', '3': 1, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'item_name', '3': 2, '4': 1, '5': 9, '10': 'itemName'},
    {'1': 'shortage_quantity', '3': 3, '4': 1, '5': 1, '10': 'shortageQuantity'},
    {'1': 'unit', '3': 4, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'supplier_item_id', '3': 5, '4': 1, '5': 9, '10': 'supplierItemId'},
    {'1': 'unit_price', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
  ],
};

/// Descriptor for `PurchaseOrderSuggestionLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSuggestionLineDescriptor = $convert.base64Decode(
    'ChtQdXJjaGFzZU9yZGVyU3VnZ2VzdGlvbkxpbmUSKgoRaW52ZW50b3J5X2l0ZW1faWQYASABKA'
    'lSD2ludmVudG9yeUl0ZW1JZBIbCglpdGVtX25hbWUYAiABKAlSCGl0ZW1OYW1lEisKEXNob3J0'
    'YWdlX3F1YW50aXR5GAMgASgBUhBzaG9ydGFnZVF1YW50aXR5EhIKBHVuaXQYBCABKAlSBHVuaX'
    'QSKAoQc3VwcGxpZXJfaXRlbV9pZBgFIAEoCVIOc3VwcGxpZXJJdGVtSWQSLwoKdW5pdF9wcmlj'
    'ZRgGIAEoCzIQLmNvbW1vbi52MS5Nb25leVIJdW5pdFByaWNl');

@$core.Deprecated('Use supplierSaveRequestDescriptor instead')
const SupplierSaveRequest$json = {
  '1': 'SupplierSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'profile_id', '3': 2, '4': 1, '5': 9, '10': 'profileId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'supplier_type', '3': 4, '4': 1, '5': 14, '6': '.procurement.v1.SupplierType', '10': 'supplierType'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.procurement.v1.SupplierStatus', '10': 'status'},
    {'1': 'payment_terms_days', '3': 6, '4': 1, '5': 5, '10': 'paymentTermsDays'},
    {'1': 'currency', '3': 7, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'lead_time_days', '3': 8, '4': 1, '5': 5, '10': 'leadTimeDays'},
    {'1': 'rating', '3': 9, '4': 1, '5': 14, '6': '.procurement.v1.SupplierRating', '10': 'rating'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `SupplierSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierSaveRequestDescriptor = $convert.base64Decode(
    'ChNTdXBwbGllclNhdmVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIdCgpwcm9maWxlX2lkGAIgAS'
    'gJUglwcm9maWxlSWQSEgoEbmFtZRgDIAEoCVIEbmFtZRJBCg1zdXBwbGllcl90eXBlGAQgASgO'
    'MhwucHJvY3VyZW1lbnQudjEuU3VwcGxpZXJUeXBlUgxzdXBwbGllclR5cGUSNgoGc3RhdHVzGA'
    'UgASgOMh4ucHJvY3VyZW1lbnQudjEuU3VwcGxpZXJTdGF0dXNSBnN0YXR1cxIsChJwYXltZW50'
    'X3Rlcm1zX2RheXMYBiABKAVSEHBheW1lbnRUZXJtc0RheXMSGgoIY3VycmVuY3kYByABKAlSCG'
    'N1cnJlbmN5EiQKDmxlYWRfdGltZV9kYXlzGAggASgFUgxsZWFkVGltZURheXMSNgoGcmF0aW5n'
    'GAkgASgOMh4ucHJvY3VyZW1lbnQudjEuU3VwcGxpZXJSYXRpbmdSBnJhdGluZxIUCgVub3Rlcx'
    'gKIAEoCVIFbm90ZXM=');

@$core.Deprecated('Use supplierSaveResponseDescriptor instead')
const SupplierSaveResponse$json = {
  '1': 'SupplierSaveResponse',
  '2': [
    {'1': 'supplier', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.Supplier', '10': 'supplier'},
  ],
};

/// Descriptor for `SupplierSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierSaveResponseDescriptor = $convert.base64Decode(
    'ChRTdXBwbGllclNhdmVSZXNwb25zZRI0CghzdXBwbGllchgBIAEoCzIYLnByb2N1cmVtZW50Ln'
    'YxLlN1cHBsaWVyUghzdXBwbGllcg==');

@$core.Deprecated('Use supplierGetRequestDescriptor instead')
const SupplierGetRequest$json = {
  '1': 'SupplierGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SupplierGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierGetRequestDescriptor = $convert.base64Decode(
    'ChJTdXBwbGllckdldFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use supplierGetResponseDescriptor instead')
const SupplierGetResponse$json = {
  '1': 'SupplierGetResponse',
  '2': [
    {'1': 'supplier', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.Supplier', '10': 'supplier'},
  ],
};

/// Descriptor for `SupplierGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierGetResponseDescriptor = $convert.base64Decode(
    'ChNTdXBwbGllckdldFJlc3BvbnNlEjQKCHN1cHBsaWVyGAEgASgLMhgucHJvY3VyZW1lbnQudj'
    'EuU3VwcGxpZXJSCHN1cHBsaWVy');

@$core.Deprecated('Use supplierSearchRequestDescriptor instead')
const SupplierSearchRequest$json = {
  '1': 'SupplierSearchRequest',
  '2': [
    {'1': 'search', '3': 1, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
    {'1': 'supplier_type', '3': 2, '4': 1, '5': 14, '6': '.procurement.v1.SupplierType', '10': 'supplierType'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.procurement.v1.SupplierStatus', '10': 'status'},
  ],
};

/// Descriptor for `SupplierSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierSearchRequestDescriptor = $convert.base64Decode(
    'ChVTdXBwbGllclNlYXJjaFJlcXVlc3QSMAoGc2VhcmNoGAEgASgLMhguY29tbW9uLnYxLlNlYX'
    'JjaFJlcXVlc3RSBnNlYXJjaBJBCg1zdXBwbGllcl90eXBlGAIgASgOMhwucHJvY3VyZW1lbnQu'
    'djEuU3VwcGxpZXJUeXBlUgxzdXBwbGllclR5cGUSNgoGc3RhdHVzGAMgASgOMh4ucHJvY3VyZW'
    '1lbnQudjEuU3VwcGxpZXJTdGF0dXNSBnN0YXR1cw==');

@$core.Deprecated('Use supplierSearchResponseDescriptor instead')
const SupplierSearchResponse$json = {
  '1': 'SupplierSearchResponse',
  '2': [
    {'1': 'suppliers', '3': 1, '4': 3, '5': 11, '6': '.procurement.v1.Supplier', '10': 'suppliers'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `SupplierSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierSearchResponseDescriptor = $convert.base64Decode(
    'ChZTdXBwbGllclNlYXJjaFJlc3BvbnNlEjYKCXN1cHBsaWVycxgBIAMoCzIYLnByb2N1cmVtZW'
    '50LnYxLlN1cHBsaWVyUglzdXBwbGllcnMSGwoJbmV4dF9wYWdlGAIgASgJUghuZXh0UGFnZQ==');

@$core.Deprecated('Use supplierItemSaveRequestDescriptor instead')
const SupplierItemSaveRequest$json = {
  '1': 'SupplierItemSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'supplier_id', '3': 2, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'inventory_item_id', '3': 3, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'supplier_sku', '3': 4, '4': 1, '5': 9, '10': 'supplierSku'},
    {'1': 'unit_price', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'min_order_quantity', '3': 6, '4': 1, '5': 1, '10': 'minOrderQuantity'},
    {'1': 'unit', '3': 7, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'lead_time_days', '3': 8, '4': 1, '5': 5, '10': 'leadTimeDays'},
    {'1': 'status', '3': 9, '4': 1, '5': 14, '6': '.procurement.v1.SupplierItemStatus', '10': 'status'},
  ],
};

/// Descriptor for `SupplierItemSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierItemSaveRequestDescriptor = $convert.base64Decode(
    'ChdTdXBwbGllckl0ZW1TYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSHwoLc3VwcGxpZXJfaW'
    'QYAiABKAlSCnN1cHBsaWVySWQSKgoRaW52ZW50b3J5X2l0ZW1faWQYAyABKAlSD2ludmVudG9y'
    'eUl0ZW1JZBIhCgxzdXBwbGllcl9za3UYBCABKAlSC3N1cHBsaWVyU2t1Ei8KCnVuaXRfcHJpY2'
    'UYBSABKAsyEC5jb21tb24udjEuTW9uZXlSCXVuaXRQcmljZRIsChJtaW5fb3JkZXJfcXVhbnRp'
    'dHkYBiABKAFSEG1pbk9yZGVyUXVhbnRpdHkSEgoEdW5pdBgHIAEoCVIEdW5pdBIkCg5sZWFkX3'
    'RpbWVfZGF5cxgIIAEoBVIMbGVhZFRpbWVEYXlzEjoKBnN0YXR1cxgJIAEoDjIiLnByb2N1cmVt'
    'ZW50LnYxLlN1cHBsaWVySXRlbVN0YXR1c1IGc3RhdHVz');

@$core.Deprecated('Use supplierItemSaveResponseDescriptor instead')
const SupplierItemSaveResponse$json = {
  '1': 'SupplierItemSaveResponse',
  '2': [
    {'1': 'supplier_item', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.SupplierItem', '10': 'supplierItem'},
  ],
};

/// Descriptor for `SupplierItemSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierItemSaveResponseDescriptor = $convert.base64Decode(
    'ChhTdXBwbGllckl0ZW1TYXZlUmVzcG9uc2USQQoNc3VwcGxpZXJfaXRlbRgBIAEoCzIcLnByb2'
    'N1cmVtZW50LnYxLlN1cHBsaWVySXRlbVIMc3VwcGxpZXJJdGVt');

@$core.Deprecated('Use supplierItemSearchRequestDescriptor instead')
const SupplierItemSearchRequest$json = {
  '1': 'SupplierItemSearchRequest',
  '2': [
    {'1': 'supplier_id', '3': 1, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'inventory_item_id', '3': 2, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'search', '3': 3, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `SupplierItemSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierItemSearchRequestDescriptor = $convert.base64Decode(
    'ChlTdXBwbGllckl0ZW1TZWFyY2hSZXF1ZXN0Eh8KC3N1cHBsaWVyX2lkGAEgASgJUgpzdXBwbG'
    'llcklkEioKEWludmVudG9yeV9pdGVtX2lkGAIgASgJUg9pbnZlbnRvcnlJdGVtSWQSMAoGc2Vh'
    'cmNoGAMgASgLMhguY29tbW9uLnYxLlNlYXJjaFJlcXVlc3RSBnNlYXJjaA==');

@$core.Deprecated('Use supplierItemSearchResponseDescriptor instead')
const SupplierItemSearchResponse$json = {
  '1': 'SupplierItemSearchResponse',
  '2': [
    {'1': 'supplier_items', '3': 1, '4': 3, '5': 11, '6': '.procurement.v1.SupplierItem', '10': 'supplierItems'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `SupplierItemSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplierItemSearchResponseDescriptor = $convert.base64Decode(
    'ChpTdXBwbGllckl0ZW1TZWFyY2hSZXNwb25zZRJDCg5zdXBwbGllcl9pdGVtcxgBIAMoCzIcLn'
    'Byb2N1cmVtZW50LnYxLlN1cHBsaWVySXRlbVINc3VwcGxpZXJJdGVtcxIbCgluZXh0X3BhZ2UY'
    'AiABKAlSCG5leHRQYWdl');

@$core.Deprecated('Use purchaseOrderCreateRequestDescriptor instead')
const PurchaseOrderCreateRequest$json = {
  '1': 'PurchaseOrderCreateRequest',
  '2': [
    {'1': 'idempotency_key', '3': 1, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'property_id', '3': 2, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'supplier_id', '3': 3, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'expected_delivery_date', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expectedDeliveryDate'},
    {'1': 'notes', '3': 5, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'plan_id', '3': 6, '4': 1, '5': 9, '10': 'planId'},
    {'1': 'lines', '3': 7, '4': 3, '5': 11, '6': '.procurement.v1.PurchaseOrderLineInput', '10': 'lines'},
  ],
};

/// Descriptor for `PurchaseOrderCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderCreateRequestDescriptor = $convert.base64Decode(
    'ChpQdXJjaGFzZU9yZGVyQ3JlYXRlUmVxdWVzdBInCg9pZGVtcG90ZW5jeV9rZXkYASABKAlSDm'
    'lkZW1wb3RlbmN5S2V5Eh8KC3Byb3BlcnR5X2lkGAIgASgJUgpwcm9wZXJ0eUlkEh8KC3N1cHBs'
    'aWVyX2lkGAMgASgJUgpzdXBwbGllcklkElAKFmV4cGVjdGVkX2RlbGl2ZXJ5X2RhdGUYBCABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhRleHBlY3RlZERlbGl2ZXJ5RGF0ZRIUCgVu'
    'b3RlcxgFIAEoCVIFbm90ZXMSFwoHcGxhbl9pZBgGIAEoCVIGcGxhbklkEjwKBWxpbmVzGAcgAy'
    'gLMiYucHJvY3VyZW1lbnQudjEuUHVyY2hhc2VPcmRlckxpbmVJbnB1dFIFbGluZXM=');

@$core.Deprecated('Use purchaseOrderLineInputDescriptor instead')
const PurchaseOrderLineInput$json = {
  '1': 'PurchaseOrderLineInput',
  '2': [
    {'1': 'supplier_item_id', '3': 1, '4': 1, '5': 9, '10': 'supplierItemId'},
    {'1': 'inventory_item_id', '3': 2, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'ordered_quantity', '3': 3, '4': 1, '5': 1, '10': 'orderedQuantity'},
    {'1': 'unit', '3': 4, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `PurchaseOrderLineInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderLineInputDescriptor = $convert.base64Decode(
    'ChZQdXJjaGFzZU9yZGVyTGluZUlucHV0EigKEHN1cHBsaWVyX2l0ZW1faWQYASABKAlSDnN1cH'
    'BsaWVySXRlbUlkEioKEWludmVudG9yeV9pdGVtX2lkGAIgASgJUg9pbnZlbnRvcnlJdGVtSWQS'
    'KQoQb3JkZXJlZF9xdWFudGl0eRgDIAEoAVIPb3JkZXJlZFF1YW50aXR5EhIKBHVuaXQYBCABKA'
    'lSBHVuaXQ=');

@$core.Deprecated('Use purchaseOrderCreateResponseDescriptor instead')
const PurchaseOrderCreateResponse$json = {
  '1': 'PurchaseOrderCreateResponse',
  '2': [
    {'1': 'purchase_order', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.PurchaseOrder', '10': 'purchaseOrder'},
  ],
};

/// Descriptor for `PurchaseOrderCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderCreateResponseDescriptor = $convert.base64Decode(
    'ChtQdXJjaGFzZU9yZGVyQ3JlYXRlUmVzcG9uc2USRAoOcHVyY2hhc2Vfb3JkZXIYASABKAsyHS'
    '5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyUg1wdXJjaGFzZU9yZGVy');

@$core.Deprecated('Use purchaseOrderGetRequestDescriptor instead')
const PurchaseOrderGetRequest$json = {
  '1': 'PurchaseOrderGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `PurchaseOrderGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderGetRequestDescriptor = $convert.base64Decode(
    'ChdQdXJjaGFzZU9yZGVyR2V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use purchaseOrderGetResponseDescriptor instead')
const PurchaseOrderGetResponse$json = {
  '1': 'PurchaseOrderGetResponse',
  '2': [
    {'1': 'purchase_order', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.PurchaseOrder', '10': 'purchaseOrder'},
  ],
};

/// Descriptor for `PurchaseOrderGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderGetResponseDescriptor = $convert.base64Decode(
    'ChhQdXJjaGFzZU9yZGVyR2V0UmVzcG9uc2USRAoOcHVyY2hhc2Vfb3JkZXIYASABKAsyHS5wcm'
    '9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyUg1wdXJjaGFzZU9yZGVy');

@$core.Deprecated('Use purchaseOrderSearchRequestDescriptor instead')
const PurchaseOrderSearchRequest$json = {
  '1': 'PurchaseOrderSearchRequest',
  '2': [
    {'1': 'property_id', '3': 1, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'supplier_id', '3': 2, '4': 1, '5': 9, '10': 'supplierId'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.procurement.v1.PurchaseOrderStatus', '10': 'status'},
    {'1': 'search', '3': 4, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `PurchaseOrderSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSearchRequestDescriptor = $convert.base64Decode(
    'ChpQdXJjaGFzZU9yZGVyU2VhcmNoUmVxdWVzdBIfCgtwcm9wZXJ0eV9pZBgBIAEoCVIKcHJvcG'
    'VydHlJZBIfCgtzdXBwbGllcl9pZBgCIAEoCVIKc3VwcGxpZXJJZBI7CgZzdGF0dXMYAyABKA4y'
    'Iy5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyU3RhdHVzUgZzdGF0dXMSMAoGc2VhcmNoGA'
    'QgASgLMhguY29tbW9uLnYxLlNlYXJjaFJlcXVlc3RSBnNlYXJjaA==');

@$core.Deprecated('Use purchaseOrderSearchResponseDescriptor instead')
const PurchaseOrderSearchResponse$json = {
  '1': 'PurchaseOrderSearchResponse',
  '2': [
    {'1': 'purchase_orders', '3': 1, '4': 3, '5': 11, '6': '.procurement.v1.PurchaseOrder', '10': 'purchaseOrders'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `PurchaseOrderSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSearchResponseDescriptor = $convert.base64Decode(
    'ChtQdXJjaGFzZU9yZGVyU2VhcmNoUmVzcG9uc2USRgoPcHVyY2hhc2Vfb3JkZXJzGAEgAygLMh'
    '0ucHJvY3VyZW1lbnQudjEuUHVyY2hhc2VPcmRlclIOcHVyY2hhc2VPcmRlcnMSGwoJbmV4dF9w'
    'YWdlGAIgASgJUghuZXh0UGFnZQ==');

@$core.Deprecated('Use purchaseOrderSubmitRequestDescriptor instead')
const PurchaseOrderSubmitRequest$json = {
  '1': 'PurchaseOrderSubmitRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `PurchaseOrderSubmitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSubmitRequestDescriptor = $convert.base64Decode(
    'ChpQdXJjaGFzZU9yZGVyU3VibWl0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use purchaseOrderSubmitResponseDescriptor instead')
const PurchaseOrderSubmitResponse$json = {
  '1': 'PurchaseOrderSubmitResponse',
  '2': [
    {'1': 'purchase_order', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.PurchaseOrder', '10': 'purchaseOrder'},
  ],
};

/// Descriptor for `PurchaseOrderSubmitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderSubmitResponseDescriptor = $convert.base64Decode(
    'ChtQdXJjaGFzZU9yZGVyU3VibWl0UmVzcG9uc2USRAoOcHVyY2hhc2Vfb3JkZXIYASABKAsyHS'
    '5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyUg1wdXJjaGFzZU9yZGVy');

@$core.Deprecated('Use purchaseOrderCancelRequestDescriptor instead')
const PurchaseOrderCancelRequest$json = {
  '1': 'PurchaseOrderCancelRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `PurchaseOrderCancelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderCancelRequestDescriptor = $convert.base64Decode(
    'ChpQdXJjaGFzZU9yZGVyQ2FuY2VsUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFgoGcmVhc29uGA'
    'IgASgJUgZyZWFzb24=');

@$core.Deprecated('Use purchaseOrderCancelResponseDescriptor instead')
const PurchaseOrderCancelResponse$json = {
  '1': 'PurchaseOrderCancelResponse',
  '2': [
    {'1': 'purchase_order', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.PurchaseOrder', '10': 'purchaseOrder'},
  ],
};

/// Descriptor for `PurchaseOrderCancelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseOrderCancelResponseDescriptor = $convert.base64Decode(
    'ChtQdXJjaGFzZU9yZGVyQ2FuY2VsUmVzcG9uc2USRAoOcHVyY2hhc2Vfb3JkZXIYASABKAsyHS'
    '5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyUg1wdXJjaGFzZU9yZGVy');

@$core.Deprecated('Use goodsReceiptCreateRequestDescriptor instead')
const GoodsReceiptCreateRequest$json = {
  '1': 'GoodsReceiptCreateRequest',
  '2': [
    {'1': 'idempotency_key', '3': 1, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'purchase_order_id', '3': 2, '4': 1, '5': 9, '10': 'purchaseOrderId'},
    {'1': 'property_id', '3': 3, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'notes', '3': 4, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'lines', '3': 5, '4': 3, '5': 11, '6': '.procurement.v1.GoodsReceiptLineInput', '10': 'lines'},
  ],
};

/// Descriptor for `GoodsReceiptCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptCreateRequestDescriptor = $convert.base64Decode(
    'ChlHb29kc1JlY2VpcHRDcmVhdGVSZXF1ZXN0EicKD2lkZW1wb3RlbmN5X2tleRgBIAEoCVIOaW'
    'RlbXBvdGVuY3lLZXkSKgoRcHVyY2hhc2Vfb3JkZXJfaWQYAiABKAlSD3B1cmNoYXNlT3JkZXJJ'
    'ZBIfCgtwcm9wZXJ0eV9pZBgDIAEoCVIKcHJvcGVydHlJZBIUCgVub3RlcxgEIAEoCVIFbm90ZX'
    'MSOwoFbGluZXMYBSADKAsyJS5wcm9jdXJlbWVudC52MS5Hb29kc1JlY2VpcHRMaW5lSW5wdXRS'
    'BWxpbmVz');

@$core.Deprecated('Use goodsReceiptLineInputDescriptor instead')
const GoodsReceiptLineInput$json = {
  '1': 'GoodsReceiptLineInput',
  '2': [
    {'1': 'purchase_order_line_id', '3': 1, '4': 1, '5': 9, '10': 'purchaseOrderLineId'},
    {'1': 'inventory_item_id', '3': 2, '4': 1, '5': 9, '10': 'inventoryItemId'},
    {'1': 'received_quantity', '3': 3, '4': 1, '5': 1, '10': 'receivedQuantity'},
    {'1': 'lot_number', '3': 4, '4': 1, '5': 9, '10': 'lotNumber'},
    {'1': 'expiry_date', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiryDate'},
    {'1': 'unit', '3': 6, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `GoodsReceiptLineInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptLineInputDescriptor = $convert.base64Decode(
    'ChVHb29kc1JlY2VpcHRMaW5lSW5wdXQSMwoWcHVyY2hhc2Vfb3JkZXJfbGluZV9pZBgBIAEoCV'
    'ITcHVyY2hhc2VPcmRlckxpbmVJZBIqChFpbnZlbnRvcnlfaXRlbV9pZBgCIAEoCVIPaW52ZW50'
    'b3J5SXRlbUlkEisKEXJlY2VpdmVkX3F1YW50aXR5GAMgASgBUhByZWNlaXZlZFF1YW50aXR5Eh'
    '0KCmxvdF9udW1iZXIYBCABKAlSCWxvdE51bWJlchI7CgtleHBpcnlfZGF0ZRgFIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmV4cGlyeURhdGUSEgoEdW5pdBgGIAEoCVIEdW5pdA'
    '==');

@$core.Deprecated('Use goodsReceiptCreateResponseDescriptor instead')
const GoodsReceiptCreateResponse$json = {
  '1': 'GoodsReceiptCreateResponse',
  '2': [
    {'1': 'goods_receipt', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.GoodsReceipt', '10': 'goodsReceipt'},
  ],
};

/// Descriptor for `GoodsReceiptCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptCreateResponseDescriptor = $convert.base64Decode(
    'ChpHb29kc1JlY2VpcHRDcmVhdGVSZXNwb25zZRJBCg1nb29kc19yZWNlaXB0GAEgASgLMhwucH'
    'JvY3VyZW1lbnQudjEuR29vZHNSZWNlaXB0Ugxnb29kc1JlY2VpcHQ=');

@$core.Deprecated('Use goodsReceiptGetRequestDescriptor instead')
const GoodsReceiptGetRequest$json = {
  '1': 'GoodsReceiptGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GoodsReceiptGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptGetRequestDescriptor = $convert.base64Decode(
    'ChZHb29kc1JlY2VpcHRHZXRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use goodsReceiptGetResponseDescriptor instead')
const GoodsReceiptGetResponse$json = {
  '1': 'GoodsReceiptGetResponse',
  '2': [
    {'1': 'goods_receipt', '3': 1, '4': 1, '5': 11, '6': '.procurement.v1.GoodsReceipt', '10': 'goodsReceipt'},
  ],
};

/// Descriptor for `GoodsReceiptGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptGetResponseDescriptor = $convert.base64Decode(
    'ChdHb29kc1JlY2VpcHRHZXRSZXNwb25zZRJBCg1nb29kc19yZWNlaXB0GAEgASgLMhwucHJvY3'
    'VyZW1lbnQudjEuR29vZHNSZWNlaXB0Ugxnb29kc1JlY2VpcHQ=');

@$core.Deprecated('Use goodsReceiptSearchRequestDescriptor instead')
const GoodsReceiptSearchRequest$json = {
  '1': 'GoodsReceiptSearchRequest',
  '2': [
    {'1': 'purchase_order_id', '3': 1, '4': 1, '5': 9, '10': 'purchaseOrderId'},
    {'1': 'property_id', '3': 2, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.procurement.v1.GoodsReceiptStatus', '10': 'status'},
    {'1': 'search', '3': 4, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `GoodsReceiptSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptSearchRequestDescriptor = $convert.base64Decode(
    'ChlHb29kc1JlY2VpcHRTZWFyY2hSZXF1ZXN0EioKEXB1cmNoYXNlX29yZGVyX2lkGAEgASgJUg'
    '9wdXJjaGFzZU9yZGVySWQSHwoLcHJvcGVydHlfaWQYAiABKAlSCnByb3BlcnR5SWQSOgoGc3Rh'
    'dHVzGAMgASgOMiIucHJvY3VyZW1lbnQudjEuR29vZHNSZWNlaXB0U3RhdHVzUgZzdGF0dXMSMA'
    'oGc2VhcmNoGAQgASgLMhguY29tbW9uLnYxLlNlYXJjaFJlcXVlc3RSBnNlYXJjaA==');

@$core.Deprecated('Use goodsReceiptSearchResponseDescriptor instead')
const GoodsReceiptSearchResponse$json = {
  '1': 'GoodsReceiptSearchResponse',
  '2': [
    {'1': 'goods_receipts', '3': 1, '4': 3, '5': 11, '6': '.procurement.v1.GoodsReceipt', '10': 'goodsReceipts'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `GoodsReceiptSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goodsReceiptSearchResponseDescriptor = $convert.base64Decode(
    'ChpHb29kc1JlY2VpcHRTZWFyY2hSZXNwb25zZRJDCg5nb29kc19yZWNlaXB0cxgBIAMoCzIcLn'
    'Byb2N1cmVtZW50LnYxLkdvb2RzUmVjZWlwdFINZ29vZHNSZWNlaXB0cxIbCgluZXh0X3BhZ2UY'
    'AiABKAlSCG5leHRQYWdl');

@$core.Deprecated('Use suggestPurchaseOrdersRequestDescriptor instead')
const SuggestPurchaseOrdersRequest$json = {
  '1': 'SuggestPurchaseOrdersRequest',
  '2': [
    {'1': 'property_id', '3': 1, '4': 1, '5': 9, '10': 'propertyId'},
    {'1': 'plan_id', '3': 2, '4': 1, '5': 9, '10': 'planId'},
  ],
};

/// Descriptor for `SuggestPurchaseOrdersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List suggestPurchaseOrdersRequestDescriptor = $convert.base64Decode(
    'ChxTdWdnZXN0UHVyY2hhc2VPcmRlcnNSZXF1ZXN0Eh8KC3Byb3BlcnR5X2lkGAEgASgJUgpwcm'
    '9wZXJ0eUlkEhcKB3BsYW5faWQYAiABKAlSBnBsYW5JZA==');

@$core.Deprecated('Use suggestPurchaseOrdersResponseDescriptor instead')
const SuggestPurchaseOrdersResponse$json = {
  '1': 'SuggestPurchaseOrdersResponse',
  '2': [
    {'1': 'suggestions', '3': 1, '4': 3, '5': 11, '6': '.procurement.v1.PurchaseOrderSuggestion', '10': 'suggestions'},
  ],
};

/// Descriptor for `SuggestPurchaseOrdersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List suggestPurchaseOrdersResponseDescriptor = $convert.base64Decode(
    'Ch1TdWdnZXN0UHVyY2hhc2VPcmRlcnNSZXNwb25zZRJJCgtzdWdnZXN0aW9ucxgBIAMoCzInLn'
    'Byb2N1cmVtZW50LnYxLlB1cmNoYXNlT3JkZXJTdWdnZXN0aW9uUgtzdWdnZXN0aW9ucw==');

const $core.Map<$core.String, $core.dynamic> ProcurementServiceBase$json = {
  '1': 'ProcurementService',
  '2': [
    {'1': 'SupplierSave', '2': '.procurement.v1.SupplierSaveRequest', '3': '.procurement.v1.SupplierSaveResponse', '4': {}},
    {'1': 'SupplierGet', '2': '.procurement.v1.SupplierGetRequest', '3': '.procurement.v1.SupplierGetResponse', '4': {}},
    {'1': 'SupplierSearch', '2': '.procurement.v1.SupplierSearchRequest', '3': '.procurement.v1.SupplierSearchResponse', '4': {}},
    {'1': 'SupplierItemSave', '2': '.procurement.v1.SupplierItemSaveRequest', '3': '.procurement.v1.SupplierItemSaveResponse', '4': {}},
    {'1': 'SupplierItemSearch', '2': '.procurement.v1.SupplierItemSearchRequest', '3': '.procurement.v1.SupplierItemSearchResponse', '4': {}},
    {'1': 'PurchaseOrderCreate', '2': '.procurement.v1.PurchaseOrderCreateRequest', '3': '.procurement.v1.PurchaseOrderCreateResponse', '4': {}},
    {'1': 'PurchaseOrderGet', '2': '.procurement.v1.PurchaseOrderGetRequest', '3': '.procurement.v1.PurchaseOrderGetResponse', '4': {}},
    {'1': 'PurchaseOrderSearch', '2': '.procurement.v1.PurchaseOrderSearchRequest', '3': '.procurement.v1.PurchaseOrderSearchResponse', '4': {}},
    {'1': 'PurchaseOrderSubmit', '2': '.procurement.v1.PurchaseOrderSubmitRequest', '3': '.procurement.v1.PurchaseOrderSubmitResponse', '4': {}},
    {'1': 'PurchaseOrderCancel', '2': '.procurement.v1.PurchaseOrderCancelRequest', '3': '.procurement.v1.PurchaseOrderCancelResponse', '4': {}},
    {'1': 'GoodsReceiptCreate', '2': '.procurement.v1.GoodsReceiptCreateRequest', '3': '.procurement.v1.GoodsReceiptCreateResponse', '4': {}},
    {'1': 'GoodsReceiptGet', '2': '.procurement.v1.GoodsReceiptGetRequest', '3': '.procurement.v1.GoodsReceiptGetResponse', '4': {}},
    {'1': 'GoodsReceiptSearch', '2': '.procurement.v1.GoodsReceiptSearchRequest', '3': '.procurement.v1.GoodsReceiptSearchResponse', '4': {}},
    {'1': 'SuggestPurchaseOrders', '2': '.procurement.v1.SuggestPurchaseOrdersRequest', '3': '.procurement.v1.SuggestPurchaseOrdersResponse', '4': {}},
  ],
  '3': {},
};

@$core.Deprecated('Use procurementServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ProcurementServiceBase$messageJson = {
  '.procurement.v1.SupplierSaveRequest': SupplierSaveRequest$json,
  '.procurement.v1.SupplierSaveResponse': SupplierSaveResponse$json,
  '.procurement.v1.Supplier': Supplier$json,
  '.google.protobuf.Timestamp': $2.Timestamp$json,
  '.procurement.v1.SupplierGetRequest': SupplierGetRequest$json,
  '.procurement.v1.SupplierGetResponse': SupplierGetResponse$json,
  '.procurement.v1.SupplierSearchRequest': SupplierSearchRequest$json,
  '.common.v1.SearchRequest': $8.SearchRequest$json,
  '.common.v1.PageCursor': $8.PageCursor$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.procurement.v1.SupplierSearchResponse': SupplierSearchResponse$json,
  '.procurement.v1.SupplierItemSaveRequest': SupplierItemSaveRequest$json,
  '.common.v1.Money': $7.Money$json,
  '.procurement.v1.SupplierItemSaveResponse': SupplierItemSaveResponse$json,
  '.procurement.v1.SupplierItem': SupplierItem$json,
  '.procurement.v1.SupplierItemSearchRequest': SupplierItemSearchRequest$json,
  '.procurement.v1.SupplierItemSearchResponse': SupplierItemSearchResponse$json,
  '.procurement.v1.PurchaseOrderCreateRequest': PurchaseOrderCreateRequest$json,
  '.procurement.v1.PurchaseOrderLineInput': PurchaseOrderLineInput$json,
  '.procurement.v1.PurchaseOrderCreateResponse': PurchaseOrderCreateResponse$json,
  '.procurement.v1.PurchaseOrder': PurchaseOrder$json,
  '.procurement.v1.PurchaseOrderLine': PurchaseOrderLine$json,
  '.procurement.v1.PurchaseOrderGetRequest': PurchaseOrderGetRequest$json,
  '.procurement.v1.PurchaseOrderGetResponse': PurchaseOrderGetResponse$json,
  '.procurement.v1.PurchaseOrderSearchRequest': PurchaseOrderSearchRequest$json,
  '.procurement.v1.PurchaseOrderSearchResponse': PurchaseOrderSearchResponse$json,
  '.procurement.v1.PurchaseOrderSubmitRequest': PurchaseOrderSubmitRequest$json,
  '.procurement.v1.PurchaseOrderSubmitResponse': PurchaseOrderSubmitResponse$json,
  '.procurement.v1.PurchaseOrderCancelRequest': PurchaseOrderCancelRequest$json,
  '.procurement.v1.PurchaseOrderCancelResponse': PurchaseOrderCancelResponse$json,
  '.procurement.v1.GoodsReceiptCreateRequest': GoodsReceiptCreateRequest$json,
  '.procurement.v1.GoodsReceiptLineInput': GoodsReceiptLineInput$json,
  '.procurement.v1.GoodsReceiptCreateResponse': GoodsReceiptCreateResponse$json,
  '.procurement.v1.GoodsReceipt': GoodsReceipt$json,
  '.procurement.v1.GoodsReceiptLine': GoodsReceiptLine$json,
  '.procurement.v1.GoodsReceiptGetRequest': GoodsReceiptGetRequest$json,
  '.procurement.v1.GoodsReceiptGetResponse': GoodsReceiptGetResponse$json,
  '.procurement.v1.GoodsReceiptSearchRequest': GoodsReceiptSearchRequest$json,
  '.procurement.v1.GoodsReceiptSearchResponse': GoodsReceiptSearchResponse$json,
  '.procurement.v1.SuggestPurchaseOrdersRequest': SuggestPurchaseOrdersRequest$json,
  '.procurement.v1.SuggestPurchaseOrdersResponse': SuggestPurchaseOrdersResponse$json,
  '.procurement.v1.PurchaseOrderSuggestion': PurchaseOrderSuggestion$json,
  '.procurement.v1.PurchaseOrderSuggestionLine': PurchaseOrderSuggestionLine$json,
};

/// Descriptor for `ProcurementService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List procurementServiceDescriptor = $convert.base64Decode(
    'ChJQcm9jdXJlbWVudFNlcnZpY2UScAoMU3VwcGxpZXJTYXZlEiMucHJvY3VyZW1lbnQudjEuU3'
    'VwcGxpZXJTYXZlUmVxdWVzdBokLnByb2N1cmVtZW50LnYxLlN1cHBsaWVyU2F2ZVJlc3BvbnNl'
    'IhWCtRgRCg9zdXBwbGllcl9tYW5hZ2USawoLU3VwcGxpZXJHZXQSIi5wcm9jdXJlbWVudC52MS'
    '5TdXBwbGllckdldFJlcXVlc3QaIy5wcm9jdXJlbWVudC52MS5TdXBwbGllckdldFJlc3BvbnNl'
    'IhOCtRgPCg1zdXBwbGllcl92aWV3EnQKDlN1cHBsaWVyU2VhcmNoEiUucHJvY3VyZW1lbnQudj'
    'EuU3VwcGxpZXJTZWFyY2hSZXF1ZXN0GiYucHJvY3VyZW1lbnQudjEuU3VwcGxpZXJTZWFyY2hS'
    'ZXNwb25zZSITgrUYDwoNc3VwcGxpZXJfdmlldxJ8ChBTdXBwbGllckl0ZW1TYXZlEicucHJvY3'
    'VyZW1lbnQudjEuU3VwcGxpZXJJdGVtU2F2ZVJlcXVlc3QaKC5wcm9jdXJlbWVudC52MS5TdXBw'
    'bGllckl0ZW1TYXZlUmVzcG9uc2UiFYK1GBEKD3N1cHBsaWVyX21hbmFnZRKAAQoSU3VwcGxpZX'
    'JJdGVtU2VhcmNoEikucHJvY3VyZW1lbnQudjEuU3VwcGxpZXJJdGVtU2VhcmNoUmVxdWVzdBoq'
    'LnByb2N1cmVtZW50LnYxLlN1cHBsaWVySXRlbVNlYXJjaFJlc3BvbnNlIhOCtRgPCg1zdXBwbG'
    'llcl92aWV3EosBChNQdXJjaGFzZU9yZGVyQ3JlYXRlEioucHJvY3VyZW1lbnQudjEuUHVyY2hh'
    'c2VPcmRlckNyZWF0ZVJlcXVlc3QaKy5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyQ3JlYX'
    'RlUmVzcG9uc2UiG4K1GBcKFXB1cmNoYXNlX29yZGVyX2NyZWF0ZRKAAQoQUHVyY2hhc2VPcmRl'
    'ckdldBInLnByb2N1cmVtZW50LnYxLlB1cmNoYXNlT3JkZXJHZXRSZXF1ZXN0GigucHJvY3VyZW'
    '1lbnQudjEuUHVyY2hhc2VPcmRlckdldFJlc3BvbnNlIhmCtRgVChNwdXJjaGFzZV9vcmRlcl92'
    'aWV3EokBChNQdXJjaGFzZU9yZGVyU2VhcmNoEioucHJvY3VyZW1lbnQudjEuUHVyY2hhc2VPcm'
    'RlclNlYXJjaFJlcXVlc3QaKy5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyU2VhcmNoUmVz'
    'cG9uc2UiGYK1GBUKE3B1cmNoYXNlX29yZGVyX3ZpZXcSiwEKE1B1cmNoYXNlT3JkZXJTdWJtaX'
    'QSKi5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyU3VibWl0UmVxdWVzdBorLnByb2N1cmVt'
    'ZW50LnYxLlB1cmNoYXNlT3JkZXJTdWJtaXRSZXNwb25zZSIbgrUYFwoVcHVyY2hhc2Vfb3JkZX'
    'Jfc3VibWl0EosBChNQdXJjaGFzZU9yZGVyQ2FuY2VsEioucHJvY3VyZW1lbnQudjEuUHVyY2hh'
    'c2VPcmRlckNhbmNlbFJlcXVlc3QaKy5wcm9jdXJlbWVudC52MS5QdXJjaGFzZU9yZGVyQ2FuY2'
    'VsUmVzcG9uc2UiG4K1GBcKFXB1cmNoYXNlX29yZGVyX2NhbmNlbBKHAQoSR29vZHNSZWNlaXB0'
    'Q3JlYXRlEikucHJvY3VyZW1lbnQudjEuR29vZHNSZWNlaXB0Q3JlYXRlUmVxdWVzdBoqLnByb2'
    'N1cmVtZW50LnYxLkdvb2RzUmVjZWlwdENyZWF0ZVJlc3BvbnNlIhqCtRgWChRnb29kc19yZWNl'
    'aXB0X2NyZWF0ZRJ8Cg9Hb29kc1JlY2VpcHRHZXQSJi5wcm9jdXJlbWVudC52MS5Hb29kc1JlY2'
    'VpcHRHZXRSZXF1ZXN0GicucHJvY3VyZW1lbnQudjEuR29vZHNSZWNlaXB0R2V0UmVzcG9uc2Ui'
    'GIK1GBQKEmdvb2RzX3JlY2VpcHRfdmlldxKFAQoSR29vZHNSZWNlaXB0U2VhcmNoEikucHJvY3'
    'VyZW1lbnQudjEuR29vZHNSZWNlaXB0U2VhcmNoUmVxdWVzdBoqLnByb2N1cmVtZW50LnYxLkdv'
    'b2RzUmVjZWlwdFNlYXJjaFJlc3BvbnNlIhiCtRgUChJnb29kc19yZWNlaXB0X3ZpZXcSkQEKFV'
    'N1Z2dlc3RQdXJjaGFzZU9yZGVycxIsLnByb2N1cmVtZW50LnYxLlN1Z2dlc3RQdXJjaGFzZU9y'
    'ZGVyc1JlcXVlc3QaLS5wcm9jdXJlbWVudC52MS5TdWdnZXN0UHVyY2hhc2VPcmRlcnNSZXNwb2'
    '5zZSIbgrUYFwoVcHVyY2hhc2Vfb3JkZXJfY3JlYXRlGvUGgrUY8AYKE3NlcnZpY2VfcHJvY3Vy'
    'ZW1lbnQSDXN1cHBsaWVyX3ZpZXcSD3N1cHBsaWVyX21hbmFnZRITcHVyY2hhc2Vfb3JkZXJfdm'
    'lldxIVcHVyY2hhc2Vfb3JkZXJfY3JlYXRlEhVwdXJjaGFzZV9vcmRlcl9zdWJtaXQSFXB1cmNo'
    'YXNlX29yZGVyX2NhbmNlbBISZ29vZHNfcmVjZWlwdF92aWV3EhRnb29kc19yZWNlaXB0X2NyZW'
    'F0ZRqmAQgBEg1zdXBwbGllcl92aWV3Eg9zdXBwbGllcl9tYW5hZ2USE3B1cmNoYXNlX29yZGVy'
    'X3ZpZXcSFXB1cmNoYXNlX29yZGVyX2NyZWF0ZRIVcHVyY2hhc2Vfb3JkZXJfc3VibWl0EhVwdX'
    'JjaGFzZV9vcmRlcl9jYW5jZWwSEmdvb2RzX3JlY2VpcHRfdmlldxIUZ29vZHNfcmVjZWlwdF9j'
    'cmVhdGUapgEIAhINc3VwcGxpZXJfdmlldxIPc3VwcGxpZXJfbWFuYWdlEhNwdXJjaGFzZV9vcm'
    'Rlcl92aWV3EhVwdXJjaGFzZV9vcmRlcl9jcmVhdGUSFXB1cmNoYXNlX29yZGVyX3N1Ym1pdBIV'
    'cHVyY2hhc2Vfb3JkZXJfY2FuY2VsEhJnb29kc19yZWNlaXB0X3ZpZXcSFGdvb2RzX3JlY2VpcH'
    'RfY3JlYXRlGn4IAxINc3VwcGxpZXJfdmlldxITcHVyY2hhc2Vfb3JkZXJfdmlldxIVcHVyY2hh'
    'c2Vfb3JkZXJfY3JlYXRlEhVwdXJjaGFzZV9vcmRlcl9zdWJtaXQSEmdvb2RzX3JlY2VpcHRfdm'
    'lldxIUZ29vZHNfcmVjZWlwdF9jcmVhdGUaOggEEg1zdXBwbGllcl92aWV3EhNwdXJjaGFzZV9v'
    'cmRlcl92aWV3EhJnb29kc19yZWNlaXB0X3ZpZXcapgEIBhINc3VwcGxpZXJfdmlldxIPc3VwcG'
    'xpZXJfbWFuYWdlEhNwdXJjaGFzZV9vcmRlcl92aWV3EhVwdXJjaGFzZV9vcmRlcl9jcmVhdGUS'
    'FXB1cmNoYXNlX29yZGVyX3N1Ym1pdBIVcHVyY2hhc2Vfb3JkZXJfY2FuY2VsEhJnb29kc19yZW'
    'NlaXB0X3ZpZXcSFGdvb2RzX3JlY2VpcHRfY3JlYXRl');

