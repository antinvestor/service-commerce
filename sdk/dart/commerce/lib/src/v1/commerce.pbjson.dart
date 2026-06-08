//
//  Generated code. Do not modify.
//  source: v1/commerce.proto
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
import '../google/protobuf/field_mask.pbjson.dart' as $1;
import '../google/protobuf/struct.pbjson.dart' as $6;
import '../google/protobuf/timestamp.pbjson.dart' as $2;

@$core.Deprecated('Use shopStatusDescriptor instead')
const ShopStatus$json = {
  '1': 'ShopStatus',
  '2': [
    {'1': 'SHOP_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SHOP_STATUS_ACTIVE', '2': 1},
    {'1': 'SHOP_STATUS_DISABLED', '2': 2},
  ],
};

/// Descriptor for `ShopStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List shopStatusDescriptor = $convert.base64Decode(
    'CgpTaG9wU3RhdHVzEhsKF1NIT1BfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFgoSU0hPUF9TVEFUVV'
    'NfQUNUSVZFEAESGAoUU0hPUF9TVEFUVVNfRElTQUJMRUQQAg==');

@$core.Deprecated('Use productStatusDescriptor instead')
const ProductStatus$json = {
  '1': 'ProductStatus',
  '2': [
    {'1': 'PRODUCT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PRODUCT_STATUS_ACTIVE', '2': 1},
    {'1': 'PRODUCT_STATUS_INACTIVE', '2': 2},
    {'1': 'PRODUCT_STATUS_ARCHIVED', '2': 3},
  ],
};

/// Descriptor for `ProductStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List productStatusDescriptor = $convert.base64Decode(
    'Cg1Qcm9kdWN0U3RhdHVzEh4KGlBST0RVQ1RfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGQoVUFJPRF'
    'VDVF9TVEFUVVNfQUNUSVZFEAESGwoXUFJPRFVDVF9TVEFUVVNfSU5BQ1RJVkUQAhIbChdQUk9E'
    'VUNUX1NUQVRVU19BUkNISVZFRBAD');

@$core.Deprecated('Use fulfilmentTypeDescriptor instead')
const FulfilmentType$json = {
  '1': 'FulfilmentType',
  '2': [
    {'1': 'FULFILMENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FULFILMENT_TYPE_PHYSICAL', '2': 1},
    {'1': 'FULFILMENT_TYPE_DIGITAL', '2': 2},
    {'1': 'FULFILMENT_TYPE_NONE', '2': 3},
  ],
};

/// Descriptor for `FulfilmentType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fulfilmentTypeDescriptor = $convert.base64Decode(
    'Cg5GdWxmaWxtZW50VHlwZRIfChtGVUxGSUxNRU5UX1RZUEVfVU5TUEVDSUZJRUQQABIcChhGVU'
    'xGSUxNRU5UX1RZUEVfUEhZU0lDQUwQARIbChdGVUxGSUxNRU5UX1RZUEVfRElHSVRBTBACEhgK'
    'FEZVTEZJTE1FTlRfVFlQRV9OT05FEAM=');

@$core.Deprecated('Use productVariantStatusDescriptor instead')
const ProductVariantStatus$json = {
  '1': 'ProductVariantStatus',
  '2': [
    {'1': 'PRODUCT_VARIANT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PRODUCT_VARIANT_STATUS_ACTIVE', '2': 1},
    {'1': 'PRODUCT_VARIANT_STATUS_DISABLED', '2': 2},
  ],
};

/// Descriptor for `ProductVariantStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List productVariantStatusDescriptor = $convert.base64Decode(
    'ChRQcm9kdWN0VmFyaWFudFN0YXR1cxImCiJQUk9EVUNUX1ZBUklBTlRfU1RBVFVTX1VOU1BFQ0'
    'lGSUVEEAASIQodUFJPRFVDVF9WQVJJQU5UX1NUQVRVU19BQ1RJVkUQARIjCh9QUk9EVUNUX1ZB'
    'UklBTlRfU1RBVFVTX0RJU0FCTEVEEAI=');

@$core.Deprecated('Use cartStatusDescriptor instead')
const CartStatus$json = {
  '1': 'CartStatus',
  '2': [
    {'1': 'CART_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CART_STATUS_ACTIVE', '2': 1},
    {'1': 'CART_STATUS_CONVERTED', '2': 2},
    {'1': 'CART_STATUS_ABANDONED', '2': 3},
    {'1': 'CART_STATUS_EXPIRED', '2': 4},
  ],
};

/// Descriptor for `CartStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cartStatusDescriptor = $convert.base64Decode(
    'CgpDYXJ0U3RhdHVzEhsKF0NBUlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFgoSQ0FSVF9TVEFUVV'
    'NfQUNUSVZFEAESGQoVQ0FSVF9TVEFUVVNfQ09OVkVSVEVEEAISGQoVQ0FSVF9TVEFUVVNfQUJB'
    'TkRPTkVEEAMSFwoTQ0FSVF9TVEFUVVNfRVhQSVJFRBAE');

@$core.Deprecated('Use orderStatusDescriptor instead')
const OrderStatus$json = {
  '1': 'OrderStatus',
  '2': [
    {'1': 'ORDER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_STATUS_CONFIRMED', '2': 1},
    {'1': 'ORDER_STATUS_CANCELLED', '2': 2},
    {'1': 'ORDER_STATUS_FULFILLED', '2': 3},
  ],
};

/// Descriptor for `OrderStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderStatusDescriptor = $convert.base64Decode(
    'CgtPcmRlclN0YXR1cxIcChhPUkRFUl9TVEFUVVNfVU5TUEVDSUZJRUQQABIaChZPUkRFUl9TVE'
    'FUVVNfQ09ORklSTUVEEAESGgoWT1JERVJfU1RBVFVTX0NBTkNFTExFRBACEhoKFk9SREVSX1NU'
    'QVRVU19GVUxGSUxMRUQQAw==');

@$core.Deprecated('Use paymentStatusDescriptor instead')
const PaymentStatus$json = {
  '1': 'PaymentStatus',
  '2': [
    {'1': 'PAYMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PAYMENT_STATUS_PENDING', '2': 1},
    {'1': 'PAYMENT_STATUS_PAID', '2': 2},
    {'1': 'PAYMENT_STATUS_FAILED', '2': 3},
    {'1': 'PAYMENT_STATUS_REFUNDED', '2': 4},
  ],
};

/// Descriptor for `PaymentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List paymentStatusDescriptor = $convert.base64Decode(
    'Cg1QYXltZW50U3RhdHVzEh4KGlBBWU1FTlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGgoWUEFZTU'
    'VOVF9TVEFUVVNfUEVORElORxABEhcKE1BBWU1FTlRfU1RBVFVTX1BBSUQQAhIZChVQQVlNRU5U'
    'X1NUQVRVU19GQUlMRUQQAxIbChdQQVlNRU5UX1NUQVRVU19SRUZVTkRFRBAE');

@$core.Deprecated('Use fulfilmentStatusDescriptor instead')
const FulfilmentStatus$json = {
  '1': 'FulfilmentStatus',
  '2': [
    {'1': 'FULFILMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'FULFILMENT_STATUS_PENDING', '2': 1},
    {'1': 'FULFILMENT_STATUS_PREPARING', '2': 2},
    {'1': 'FULFILMENT_STATUS_PACKED', '2': 3},
    {'1': 'FULFILMENT_STATUS_SHIPPED', '2': 4},
    {'1': 'FULFILMENT_STATUS_DELIVERED', '2': 5},
    {'1': 'FULFILMENT_STATUS_CANCELLED', '2': 6},
  ],
};

/// Descriptor for `FulfilmentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fulfilmentStatusDescriptor = $convert.base64Decode(
    'ChBGdWxmaWxtZW50U3RhdHVzEiEKHUZVTEZJTE1FTlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHQ'
    'oZRlVMRklMTUVOVF9TVEFUVVNfUEVORElORxABEh8KG0ZVTEZJTE1FTlRfU1RBVFVTX1BSRVBB'
    'UklORxACEhwKGEZVTEZJTE1FTlRfU1RBVFVTX1BBQ0tFRBADEh0KGUZVTEZJTE1FTlRfU1RBVF'
    'VTX1NISVBQRUQQBBIfChtGVUxGSUxNRU5UX1NUQVRVU19ERUxJVkVSRUQQBRIfChtGVUxGSUxN'
    'RU5UX1NUQVRVU19DQU5DRUxMRUQQBg==');

@$core.Deprecated('Use priceListStatusDescriptor instead')
const PriceListStatus$json = {
  '1': 'PriceListStatus',
  '2': [
    {'1': 'PRICE_LIST_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PRICE_LIST_STATUS_ACTIVE', '2': 1},
    {'1': 'PRICE_LIST_STATUS_DRAFT', '2': 2},
    {'1': 'PRICE_LIST_STATUS_EXPIRED', '2': 3},
  ],
};

/// Descriptor for `PriceListStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List priceListStatusDescriptor = $convert.base64Decode(
    'Cg9QcmljZUxpc3RTdGF0dXMSIQodUFJJQ0VfTElTVF9TVEFUVVNfVU5TUEVDSUZJRUQQABIcCh'
    'hQUklDRV9MSVNUX1NUQVRVU19BQ1RJVkUQARIbChdQUklDRV9MSVNUX1NUQVRVU19EUkFGVBAC'
    'Eh0KGVBSSUNFX0xJU1RfU1RBVFVTX0VYUElSRUQQAw==');

@$core.Deprecated('Use priceSourceDescriptor instead')
const PriceSource$json = {
  '1': 'PriceSource',
  '2': [
    {'1': 'PRICE_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'PRICE_SOURCE_CATALOG', '2': 1},
    {'1': 'PRICE_SOURCE_PRICE_LIST', '2': 2},
    {'1': 'PRICE_SOURCE_CUSTOMER_OVERRIDE', '2': 3},
  ],
};

/// Descriptor for `PriceSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List priceSourceDescriptor = $convert.base64Decode(
    'CgtQcmljZVNvdXJjZRIcChhQUklDRV9TT1VSQ0VfVU5TUEVDSUZJRUQQABIYChRQUklDRV9TT1'
    'VSQ0VfQ0FUQUxPRxABEhsKF1BSSUNFX1NPVVJDRV9QUklDRV9MSVNUEAISIgoeUFJJQ0VfU09V'
    'UkNFX0NVU1RPTUVSX09WRVJSSURFEAM=');

@$core.Deprecated('Use discountTypeDescriptor instead')
const DiscountType$json = {
  '1': 'DiscountType',
  '2': [
    {'1': 'DISCOUNT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DISCOUNT_TYPE_PERCENTAGE', '2': 1},
    {'1': 'DISCOUNT_TYPE_FIXED_AMOUNT', '2': 2},
  ],
};

/// Descriptor for `DiscountType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List discountTypeDescriptor = $convert.base64Decode(
    'CgxEaXNjb3VudFR5cGUSHQoZRElTQ09VTlRfVFlQRV9VTlNQRUNJRklFRBAAEhwKGERJU0NPVU'
    '5UX1RZUEVfUEVSQ0VOVEFHRRABEh4KGkRJU0NPVU5UX1RZUEVfRklYRURfQU1PVU5UEAI=');

@$core.Deprecated('Use discountAppliesToDescriptor instead')
const DiscountAppliesTo$json = {
  '1': 'DiscountAppliesTo',
  '2': [
    {'1': 'DISCOUNT_APPLIES_TO_UNSPECIFIED', '2': 0},
    {'1': 'DISCOUNT_APPLIES_TO_ORDER', '2': 1},
    {'1': 'DISCOUNT_APPLIES_TO_LINE_ITEM', '2': 2},
  ],
};

/// Descriptor for `DiscountAppliesTo`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List discountAppliesToDescriptor = $convert.base64Decode(
    'ChFEaXNjb3VudEFwcGxpZXNUbxIjCh9ESVNDT1VOVF9BUFBMSUVTX1RPX1VOU1BFQ0lGSUVEEA'
    'ASHQoZRElTQ09VTlRfQVBQTElFU19UT19PUkRFUhABEiEKHURJU0NPVU5UX0FQUExJRVNfVE9f'
    'TElORV9JVEVNEAI=');

@$core.Deprecated('Use discountRuleStatusDescriptor instead')
const DiscountRuleStatus$json = {
  '1': 'DiscountRuleStatus',
  '2': [
    {'1': 'DISCOUNT_RULE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DISCOUNT_RULE_STATUS_ACTIVE', '2': 1},
    {'1': 'DISCOUNT_RULE_STATUS_INACTIVE', '2': 2},
  ],
};

/// Descriptor for `DiscountRuleStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List discountRuleStatusDescriptor = $convert.base64Decode(
    'ChJEaXNjb3VudFJ1bGVTdGF0dXMSJAogRElTQ09VTlRfUlVMRV9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIfChtESVNDT1VOVF9SVUxFX1NUQVRVU19BQ1RJVkUQARIhCh1ESVNDT1VOVF9SVUxFX1NU'
    'QVRVU19JTkFDVElWRRAC');

@$core.Deprecated('Use customerPriceOverrideStatusDescriptor instead')
const CustomerPriceOverrideStatus$json = {
  '1': 'CustomerPriceOverrideStatus',
  '2': [
    {'1': 'CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE', '2': 1},
    {'1': 'CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED', '2': 2},
  ],
};

/// Descriptor for `CustomerPriceOverrideStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideStatusDescriptor = $convert.base64Decode(
    'ChtDdXN0b21lclByaWNlT3ZlcnJpZGVTdGF0dXMSLgoqQ1VTVE9NRVJfUFJJQ0VfT1ZFUlJJRE'
    'VfU1RBVFVTX1VOU1BFQ0lGSUVEEAASKQolQ1VTVE9NRVJfUFJJQ0VfT1ZFUlJJREVfU1RBVFVT'
    'X0FDVElWRRABEioKJkNVU1RPTUVSX1BSSUNFX09WRVJSSURFX1NUQVRVU19FWFBJUkVEEAI=');

@$core.Deprecated('Use customerPriceListAssignmentStatusDescriptor instead')
const CustomerPriceListAssignmentStatus$json = {
  '1': 'CustomerPriceListAssignmentStatus',
  '2': [
    {'1': 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE', '2': 1},
    {'1': 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE', '2': 2},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentStatusDescriptor = $convert.base64Decode(
    'CiFDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTdGF0dXMSNQoxQ1VTVE9NRVJfUFJJQ0VfTE'
    'lTVF9BU1NJR05NRU5UX1NUQVRVU19VTlNQRUNJRklFRBAAEjAKLENVU1RPTUVSX1BSSUNFX0xJ'
    'U1RfQVNTSUdOTUVOVF9TVEFUVVNfQUNUSVZFEAESMgouQ1VTVE9NRVJfUFJJQ0VfTElTVF9BU1'
    'NJR05NRU5UX1NUQVRVU19JTkFDVElWRRAC');

@$core.Deprecated('Use shopDescriptor instead')
const Shop$json = {
  '1': 'Shop',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 3, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.commerce.v1.ShopStatus', '10': 'status'},
    {'1': 'media_ids', '3': 6, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'extra', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'extra'},
  ],
};

/// Descriptor for `Shop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shopDescriptor = $convert.base64Decode(
    'CgRTaG9wEisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SAmlkEhIKBG'
    '5hbWUYAiABKAlSBG5hbWUSEgoEc2x1ZxgDIAEoCVIEc2x1ZxIgCgtkZXNjcmlwdGlvbhgEIAEo'
    'CVILZGVzY3JpcHRpb24SLwoGc3RhdHVzGAUgASgOMhcuY29tbWVyY2UudjEuU2hvcFN0YXR1c1'
    'IGc3RhdHVzEhsKCW1lZGlhX2lkcxgGIAMoCVIIbWVkaWFJZHMSOQoKY3JlYXRlZF9hdBgKIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBItCgVleHRyYRgPIAEoCz'
    'IXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSBWV4dHJh');

@$core.Deprecated('Use createShopRequestDescriptor instead')
const CreateShopRequest$json = {
  '1': 'CreateShopRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 2, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'media_ids', '3': 6, '4': 3, '5': 9, '10': 'mediaIds'},
  ],
};

/// Descriptor for `CreateShopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createShopRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVTaG9wUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHNsdWcYAiABKAlSBH'
    'NsdWcSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhsKCW1lZGlhX2lkcxgGIAMo'
    'CVIIbWVkaWFJZHM=');

@$core.Deprecated('Use createShopResponseDescriptor instead')
const CreateShopResponse$json = {
  '1': 'CreateShopResponse',
  '2': [
    {'1': 'shop', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Shop', '10': 'shop'},
  ],
};

/// Descriptor for `CreateShopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createShopResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVTaG9wUmVzcG9uc2USJQoEc2hvcBgBIAEoCzIRLmNvbW1lcmNlLnYxLlNob3BSBH'
    'Nob3A=');

@$core.Deprecated('Use updateShopRequestDescriptor instead')
const UpdateShopRequest$json = {
  '1': 'UpdateShopRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'media_ids', '3': 5, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.commerce.v1.ShopStatus', '10': 'status'},
    {'1': 'extra', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'extra'},
  ],
};

/// Descriptor for `UpdateShopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateShopRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVTaG9wUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZBI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1h'
    'c2tSCnVwZGF0ZU1hc2sSEgoEbmFtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCV'
    'ILZGVzY3JpcHRpb24SGwoJbWVkaWFfaWRzGAUgAygJUghtZWRpYUlkcxIvCgZzdGF0dXMYBiAB'
    'KA4yFy5jb21tZXJjZS52MS5TaG9wU3RhdHVzUgZzdGF0dXMSLQoFZXh0cmEYByABKAsyFy5nb2'
    '9nbGUucHJvdG9idWYuU3RydWN0UgVleHRyYQ==');

@$core.Deprecated('Use updateShopResponseDescriptor instead')
const UpdateShopResponse$json = {
  '1': 'UpdateShopResponse',
  '2': [
    {'1': 'shop', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Shop', '10': 'shop'},
  ],
};

/// Descriptor for `UpdateShopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateShopResponseDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVTaG9wUmVzcG9uc2USJQoEc2hvcBgBIAEoCzIRLmNvbW1lcmNlLnYxLlNob3BSBH'
    'Nob3A=');

@$core.Deprecated('Use getShopRequestDescriptor instead')
const GetShopRequest$json = {
  '1': 'GetShopRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `GetShopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShopRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRTaG9wUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsND'
    'B9UgJpZA==');

@$core.Deprecated('Use getShopResponseDescriptor instead')
const GetShopResponse$json = {
  '1': 'GetShopResponse',
  '2': [
    {'1': 'shop', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Shop', '10': 'shop'},
  ],
};

/// Descriptor for `GetShopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShopResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRTaG9wUmVzcG9uc2USJQoEc2hvcBgBIAEoCzIRLmNvbW1lcmNlLnYxLlNob3BSBHNob3'
    'A=');

@$core.Deprecated('Use productDescriptor instead')
const Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'attributes', '3': 5, '4': 3, '5': 11, '6': '.commerce.v1.Product.AttributesEntry', '10': 'attributes'},
    {'1': 'fulfilment_type', '3': 10, '4': 1, '5': 14, '6': '.commerce.v1.FulfilmentType', '10': 'fulfilmentType'},
    {'1': 'status', '3': 15, '4': 1, '5': 14, '6': '.commerce.v1.ProductStatus', '10': 'status'},
    {'1': 'media_ids', '3': 16, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'created_at', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
  '3': [Product_AttributesEntry$json],
};

@$core.Deprecated('Use productDescriptor instead')
const Product_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Product`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productDescriptor = $convert.base64Decode(
    'CgdQcm9kdWN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SAmlkEj'
    'QKB3Nob3BfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVIGc2hvcElkEhIK'
    'BG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEkQKCm'
    'F0dHJpYnV0ZXMYBSADKAsyJC5jb21tZXJjZS52MS5Qcm9kdWN0LkF0dHJpYnV0ZXNFbnRyeVIK'
    'YXR0cmlidXRlcxJECg9mdWxmaWxtZW50X3R5cGUYCiABKA4yGy5jb21tZXJjZS52MS5GdWxmaW'
    'xtZW50VHlwZVIOZnVsZmlsbWVudFR5cGUSMgoGc3RhdHVzGA8gASgOMhouY29tbWVyY2UudjEu'
    'UHJvZHVjdFN0YXR1c1IGc3RhdHVzEhsKCW1lZGlhX2lkcxgQIAMoCVIIbWVkaWFJZHMSOQoKY3'
    'JlYXRlZF9hdBgRIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBo9'
    'Cg9BdHRyaWJ1dGVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbH'
    'VlOgI4AQ==');

@$core.Deprecated('Use productVariantDescriptor instead')
const ProductVariant$json = {
  '1': 'ProductVariant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'sku', '3': 3, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'price', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'price'},
    {'1': 'stock_quantity', '3': 7, '4': 1, '5': 3, '10': 'stockQuantity'},
    {'1': 'attributes', '3': 6, '4': 3, '5': 11, '6': '.commerce.v1.ProductVariant.AttributesEntry', '10': 'attributes'},
    {'1': 'media_ids', '3': 10, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.ProductVariantStatus', '10': 'status'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
  '3': [ProductVariant_AttributesEntry$json],
};

@$core.Deprecated('Use productVariantDescriptor instead')
const ProductVariant_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ProductVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productVariantDescriptor = $convert.base64Decode(
    'Cg5Qcm9kdWN0VmFyaWFudBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsND'
    'B9UgJpZBI6Cgpwcm9kdWN0X2lkGAIgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1S'
    'CXByb2R1Y3RJZBIQCgNza3UYAyABKAlSA3NrdRISCgRuYW1lGAQgASgJUgRuYW1lEiYKBXByaW'
    'NlGAUgASgLMhAuY29tbW9uLnYxLk1vbmV5UgVwcmljZRIlCg5zdG9ja19xdWFudGl0eRgHIAEo'
    'A1INc3RvY2tRdWFudGl0eRJLCgphdHRyaWJ1dGVzGAYgAygLMisuY29tbWVyY2UudjEuUHJvZH'
    'VjdFZhcmlhbnQuQXR0cmlidXRlc0VudHJ5UgphdHRyaWJ1dGVzEhsKCW1lZGlhX2lkcxgKIAMo'
    'CVIIbWVkaWFJZHMSOQoGc3RhdHVzGAggASgOMiEuY29tbWVyY2UudjEuUHJvZHVjdFZhcmlhbn'
    'RTdGF0dXNSBnN0YXR1cxI5CgpjcmVhdGVkX2F0GAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIJY3JlYXRlZEF0Gj0KD0F0dHJpYnV0ZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleR'
    'IUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use createProductRequestDescriptor instead')
const CreateProductRequest$json = {
  '1': 'CreateProductRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'media_ids', '3': 4, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'attributes', '3': 5, '4': 3, '5': 11, '6': '.commerce.v1.CreateProductRequest.AttributesEntry', '10': 'attributes'},
  ],
  '3': [CreateProductRequest_AttributesEntry$json],
};

@$core.Deprecated('Use createProductRequestDescriptor instead')
const CreateProductRequest_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateProductRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProductRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQcm9kdWN0UmVxdWVzdBI0CgdzaG9wX2lkGAEgASgJQhu6SBhyFhADGCgyEFswLT'
    'lhLXpfLV17Myw0MH1SBnNob3BJZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9u'
    'GAMgASgJUgtkZXNjcmlwdGlvbhIbCgltZWRpYV9pZHMYBCADKAlSCG1lZGlhSWRzElEKCmF0dH'
    'JpYnV0ZXMYBSADKAsyMS5jb21tZXJjZS52MS5DcmVhdGVQcm9kdWN0UmVxdWVzdC5BdHRyaWJ1'
    'dGVzRW50cnlSCmF0dHJpYnV0ZXMaPQoPQXR0cmlidXRlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2'
    'V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use createProductResponseDescriptor instead')
const CreateProductResponse$json = {
  '1': 'CreateProductResponse',
  '2': [
    {'1': 'product', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Product', '10': 'product'},
  ],
};

/// Descriptor for `CreateProductResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProductResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVQcm9kdWN0UmVzcG9uc2USLgoHcHJvZHVjdBgBIAEoCzIULmNvbW1lcmNlLnYxLl'
    'Byb2R1Y3RSB3Byb2R1Y3Q=');

@$core.Deprecated('Use getProductRequestDescriptor instead')
const GetProductRequest$json = {
  '1': 'GetProductRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `GetProductRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProductRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9kdWN0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZA==');

@$core.Deprecated('Use getProductResponseDescriptor instead')
const GetProductResponse$json = {
  '1': 'GetProductResponse',
  '2': [
    {'1': 'product', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Product', '10': 'product'},
  ],
};

/// Descriptor for `GetProductResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProductResponseDescriptor = $convert.base64Decode(
    'ChJHZXRQcm9kdWN0UmVzcG9uc2USLgoHcHJvZHVjdBgBIAEoCzIULmNvbW1lcmNlLnYxLlByb2'
    'R1Y3RSB3Byb2R1Y3Q=');

@$core.Deprecated('Use listProductsRequestDescriptor instead')
const ListProductsRequest$json = {
  '1': 'ListProductsRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'search', '3': 2, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `ListProductsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProductsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0UHJvZHVjdHNSZXF1ZXN0EjQKB3Nob3BfaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVIGc2hvcElkEjAKBnNlYXJjaBgCIAEoCzIYLmNvbW1vbi52MS5TZWFyY2hS'
    'ZXF1ZXN0UgZzZWFyY2g=');

@$core.Deprecated('Use listProductsResponseDescriptor instead')
const ListProductsResponse$json = {
  '1': 'ListProductsResponse',
  '2': [
    {'1': 'products', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.Product', '10': 'products'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `ListProductsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProductsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0UHJvZHVjdHNSZXNwb25zZRIwCghwcm9kdWN0cxgBIAMoCzIULmNvbW1lcmNlLnYxLl'
    'Byb2R1Y3RSCHByb2R1Y3RzEhsKCW5leHRfcGFnZRgCIAEoCVIIbmV4dFBhZ2USHwoLcHJldl9j'
    'dXJzb3IYAyABKAlSCnByZXZDdXJzb3I=');

@$core.Deprecated('Use createProductVariantRequestDescriptor instead')
const CreateProductVariantRequest$json = {
  '1': 'CreateProductVariantRequest',
  '2': [
    {'1': 'product_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'sku', '3': 2, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'price', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'price'},
    {'1': 'stock_quantity', '3': 6, '4': 1, '5': 3, '10': 'stockQuantity'},
    {'1': 'attributes', '3': 5, '4': 3, '5': 11, '6': '.commerce.v1.CreateProductVariantRequest.AttributesEntry', '10': 'attributes'},
    {'1': 'media_ids', '3': 7, '4': 3, '5': 9, '10': 'mediaIds'},
  ],
  '3': [CreateProductVariantRequest_AttributesEntry$json],
};

@$core.Deprecated('Use createProductVariantRequestDescriptor instead')
const CreateProductVariantRequest_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateProductVariantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProductVariantRequestDescriptor = $convert.base64Decode(
    'ChtDcmVhdGVQcm9kdWN0VmFyaWFudFJlcXVlc3QSOgoKcHJvZHVjdF9pZBgBIAEoCUIbukgYch'
    'YQAxgoMhBbMC05YS16Xy1dezMsNDB9Uglwcm9kdWN0SWQSEAoDc2t1GAIgASgJUgNza3USEgoE'
    'bmFtZRgDIAEoCVIEbmFtZRImCgVwcmljZRgEIAEoCzIQLmNvbW1vbi52MS5Nb25leVIFcHJpY2'
    'USJQoOc3RvY2tfcXVhbnRpdHkYBiABKANSDXN0b2NrUXVhbnRpdHkSWAoKYXR0cmlidXRlcxgF'
    'IAMoCzI4LmNvbW1lcmNlLnYxLkNyZWF0ZVByb2R1Y3RWYXJpYW50UmVxdWVzdC5BdHRyaWJ1dG'
    'VzRW50cnlSCmF0dHJpYnV0ZXMSGwoJbWVkaWFfaWRzGAcgAygJUghtZWRpYUlkcxo9Cg9BdHRy'
    'aWJ1dGVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ'
    '==');

@$core.Deprecated('Use createProductVariantResponseDescriptor instead')
const CreateProductVariantResponse$json = {
  '1': 'CreateProductVariantResponse',
  '2': [
    {'1': 'product_variant', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.ProductVariant', '10': 'productVariant'},
  ],
};

/// Descriptor for `CreateProductVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProductVariantResponseDescriptor = $convert.base64Decode(
    'ChxDcmVhdGVQcm9kdWN0VmFyaWFudFJlc3BvbnNlEkQKD3Byb2R1Y3RfdmFyaWFudBgBIAEoCz'
    'IbLmNvbW1lcmNlLnYxLlByb2R1Y3RWYXJpYW50Ug5wcm9kdWN0VmFyaWFudA==');

@$core.Deprecated('Use updateProductVariantRequestDescriptor instead')
const UpdateProductVariantRequest$json = {
  '1': 'UpdateProductVariantRequest',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '10': 'variantId'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'sku', '3': 3, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'price', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'price'},
    {'1': 'stock_quantity', '3': 7, '4': 1, '5': 3, '10': 'stockQuantity'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.ProductVariantStatus', '10': 'status'},
    {'1': 'attributes', '3': 6, '4': 3, '5': 11, '6': '.commerce.v1.UpdateProductVariantRequest.AttributesEntry', '10': 'attributes'},
    {'1': 'media_ids', '3': 9, '4': 3, '5': 9, '10': 'mediaIds'},
  ],
  '3': [UpdateProductVariantRequest_AttributesEntry$json],
};

@$core.Deprecated('Use updateProductVariantRequestDescriptor instead')
const UpdateProductVariantRequest_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UpdateProductVariantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProductVariantRequestDescriptor = $convert.base64Decode(
    'ChtVcGRhdGVQcm9kdWN0VmFyaWFudFJlcXVlc3QSHQoKdmFyaWFudF9pZBgBIAEoCVIJdmFyaW'
    'FudElkEjsKC3VwZGF0ZV9tYXNrGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLkZpZWxkTWFza1IK'
    'dXBkYXRlTWFzaxIQCgNza3UYAyABKAlSA3NrdRISCgRuYW1lGAQgASgJUgRuYW1lEiYKBXByaW'
    'NlGAUgASgLMhAuY29tbW9uLnYxLk1vbmV5UgVwcmljZRIlCg5zdG9ja19xdWFudGl0eRgHIAEo'
    'A1INc3RvY2tRdWFudGl0eRI5CgZzdGF0dXMYCCABKA4yIS5jb21tZXJjZS52MS5Qcm9kdWN0Vm'
    'FyaWFudFN0YXR1c1IGc3RhdHVzElgKCmF0dHJpYnV0ZXMYBiADKAsyOC5jb21tZXJjZS52MS5V'
    'cGRhdGVQcm9kdWN0VmFyaWFudFJlcXVlc3QuQXR0cmlidXRlc0VudHJ5UgphdHRyaWJ1dGVzEh'
    'sKCW1lZGlhX2lkcxgJIAMoCVIIbWVkaWFJZHMaPQoPQXR0cmlidXRlc0VudHJ5EhAKA2tleRgB'
    'IAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use updateProductVariantResponseDescriptor instead')
const UpdateProductVariantResponse$json = {
  '1': 'UpdateProductVariantResponse',
  '2': [
    {'1': 'product_variant', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.ProductVariant', '10': 'productVariant'},
  ],
};

/// Descriptor for `UpdateProductVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProductVariantResponseDescriptor = $convert.base64Decode(
    'ChxVcGRhdGVQcm9kdWN0VmFyaWFudFJlc3BvbnNlEkQKD3Byb2R1Y3RfdmFyaWFudBgBIAEoCz'
    'IbLmNvbW1lcmNlLnYxLlByb2R1Y3RWYXJpYW50Ug5wcm9kdWN0VmFyaWFudA==');

@$core.Deprecated('Use cartDescriptor instead')
const Cart$json = {
  '1': 'Cart',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.commerce.v1.CartStatus', '10': 'status'},
    {'1': 'profile_id', '3': 4, '4': 1, '5': 9, '10': 'profileId'},
    {'1': 'contact_id', '3': 5, '4': 1, '5': 9, '10': 'contactId'},
    {'1': 'lines', '3': 10, '4': 3, '5': 11, '6': '.commerce.v1.CartLine', '10': 'lines'},
    {'1': 'expires_at', '3': 16, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiresAt'},
    {'1': 'created_at', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 18, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `Cart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cartDescriptor = $convert.base64Decode(
    'CgRDYXJ0Eg4KAmlkGAEgASgJUgJpZBIXCgdzaG9wX2lkGAIgASgJUgZzaG9wSWQSLwoGc3RhdH'
    'VzGAMgASgOMhcuY29tbWVyY2UudjEuQ2FydFN0YXR1c1IGc3RhdHVzEh0KCnByb2ZpbGVfaWQY'
    'BCABKAlSCXByb2ZpbGVJZBIdCgpjb250YWN0X2lkGAUgASgJUgljb250YWN0SWQSKwoFbGluZX'
    'MYCiADKAsyFS5jb21tZXJjZS52MS5DYXJ0TGluZVIFbGluZXMSOQoKZXhwaXJlc19hdBgQIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdBI5CgpjcmVhdGVkX2F0GB'
    'EgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRf'
    'YXQYEiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use cartLineDescriptor instead')
const CartLine$json = {
  '1': 'CartLine',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_variant_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'quantity', '3': 3, '4': 1, '5': 3, '10': 'quantity'},
  ],
};

/// Descriptor for `CartLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cartLineDescriptor = $convert.base64Decode(
    'CghDYXJ0TGluZRIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgJpZB'
    'JJChJwcm9kdWN0X3ZhcmlhbnRfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQw'
    'fVIQcHJvZHVjdFZhcmlhbnRJZBIaCghxdWFudGl0eRgDIAEoA1IIcXVhbnRpdHk=');

@$core.Deprecated('Use createCartRequestDescriptor instead')
const CreateCartRequest$json = {
  '1': 'CreateCartRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'profile_id', '3': 2, '4': 1, '5': 9, '10': 'profileId'},
    {'1': 'contact_id', '3': 3, '4': 1, '5': 9, '10': 'contactId'},
  ],
};

/// Descriptor for `CreateCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCartRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVDYXJ0UmVxdWVzdBI0CgdzaG9wX2lkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SBnNob3BJZBIdCgpwcm9maWxlX2lkGAIgASgJUglwcm9maWxlSWQSHQoKY29u'
    'dGFjdF9pZBgDIAEoCVIJY29udGFjdElk');

@$core.Deprecated('Use createCartResponseDescriptor instead')
const CreateCartResponse$json = {
  '1': 'CreateCartResponse',
  '2': [
    {'1': 'cart', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Cart', '10': 'cart'},
  ],
};

/// Descriptor for `CreateCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCartResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVDYXJ0UmVzcG9uc2USJQoEY2FydBgBIAEoCzIRLmNvbW1lcmNlLnYxLkNhcnRSBG'
    'NhcnQ=');

@$core.Deprecated('Use getCartRequestDescriptor instead')
const GetCartRequest$json = {
  '1': 'GetCartRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `GetCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCartRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRDYXJ0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsND'
    'B9UgJpZA==');

@$core.Deprecated('Use getCartResponseDescriptor instead')
const GetCartResponse$json = {
  '1': 'GetCartResponse',
  '2': [
    {'1': 'cart', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Cart', '10': 'cart'},
  ],
};

/// Descriptor for `GetCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCartResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRDYXJ0UmVzcG9uc2USJQoEY2FydBgBIAEoCzIRLmNvbW1lcmNlLnYxLkNhcnRSBGNhcn'
    'Q=');

@$core.Deprecated('Use addCartLineRequestDescriptor instead')
const AddCartLineRequest$json = {
  '1': 'AddCartLineRequest',
  '2': [
    {'1': 'cart_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'cartId'},
    {'1': 'product_variant_id', '3': 2, '4': 1, '5': 9, '10': 'productVariantId'},
    {'1': 'quantity', '3': 3, '4': 1, '5': 3, '10': 'quantity'},
  ],
};

/// Descriptor for `AddCartLineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addCartLineRequestDescriptor = $convert.base64Decode(
    'ChJBZGRDYXJ0TGluZVJlcXVlc3QSNAoHY2FydF9pZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9UgZjYXJ0SWQSLAoScHJvZHVjdF92YXJpYW50X2lkGAIgASgJUhBwcm9kdWN0'
    'VmFyaWFudElkEhoKCHF1YW50aXR5GAMgASgDUghxdWFudGl0eQ==');

@$core.Deprecated('Use addCartLineResponseDescriptor instead')
const AddCartLineResponse$json = {
  '1': 'AddCartLineResponse',
  '2': [
    {'1': 'cart', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Cart', '10': 'cart'},
  ],
};

/// Descriptor for `AddCartLineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addCartLineResponseDescriptor = $convert.base64Decode(
    'ChNBZGRDYXJ0TGluZVJlc3BvbnNlEiUKBGNhcnQYASABKAsyES5jb21tZXJjZS52MS5DYXJ0Ug'
    'RjYXJ0');

@$core.Deprecated('Use removeCartLineRequestDescriptor instead')
const RemoveCartLineRequest$json = {
  '1': 'RemoveCartLineRequest',
  '2': [
    {'1': 'cart_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'cartId'},
    {'1': 'cart_line_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'cartLineId'},
  ],
};

/// Descriptor for `RemoveCartLineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeCartLineRequestDescriptor = $convert.base64Decode(
    'ChVSZW1vdmVDYXJ0TGluZVJlcXVlc3QSNAoHY2FydF9pZBgBIAEoCUIbukgYchYQAxgoMhBbMC'
    '05YS16Xy1dezMsNDB9UgZjYXJ0SWQSPQoMY2FydF9saW5lX2lkGAIgASgJQhu6SBhyFhADGCgy'
    'EFswLTlhLXpfLV17Myw0MH1SCmNhcnRMaW5lSWQ=');

@$core.Deprecated('Use removeCartLineResponseDescriptor instead')
const RemoveCartLineResponse$json = {
  '1': 'RemoveCartLineResponse',
  '2': [
    {'1': 'cart', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Cart', '10': 'cart'},
  ],
};

/// Descriptor for `RemoveCartLineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeCartLineResponseDescriptor = $convert.base64Decode(
    'ChZSZW1vdmVDYXJ0TGluZVJlc3BvbnNlEiUKBGNhcnQYASABKAsyES5jb21tZXJjZS52MS5DYX'
    'J0UgRjYXJ0');

@$core.Deprecated('Use createOrderFromCartRequestDescriptor instead')
const CreateOrderFromCartRequest$json = {
  '1': 'CreateOrderFromCartRequest',
  '2': [
    {'1': 'cart_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'cartId'},
    {'1': 'profile_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'contact_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'contactId'},
    {'1': 'address_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'addressId'},
  ],
};

/// Descriptor for `CreateOrderFromCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderFromCartRequestDescriptor = $convert.base64Decode(
    'ChpDcmVhdGVPcmRlckZyb21DYXJ0UmVxdWVzdBI0CgdjYXJ0X2lkGAEgASgJQhu6SBhyFhADGC'
    'gyEFswLTlhLXpfLV17Myw0MH1SBmNhcnRJZBI6Cgpwcm9maWxlX2lkGAUgASgJQhu6SBhyFhAD'
    'GCgyEFswLTlhLXpfLV17Myw0MH1SCXByb2ZpbGVJZBI6Cgpjb250YWN0X2lkGAYgASgJQhu6SB'
    'hyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SCWNvbnRhY3RJZBI6CgphZGRyZXNzX2lkGAcgASgJ'
    'Qhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SCWFkZHJlc3NJZA==');

@$core.Deprecated('Use createOrderFromCartResponseDescriptor instead')
const CreateOrderFromCartResponse$json = {
  '1': 'CreateOrderFromCartResponse',
  '2': [
    {'1': 'order', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Order', '10': 'order'},
  ],
};

/// Descriptor for `CreateOrderFromCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderFromCartResponseDescriptor = $convert.base64Decode(
    'ChtDcmVhdGVPcmRlckZyb21DYXJ0UmVzcG9uc2USKAoFb3JkZXIYASABKAsyEi5jb21tZXJjZS'
    '52MS5PcmRlclIFb3JkZXI=');

@$core.Deprecated('Use orderDescriptor instead')
const Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'order_number', '3': 3, '4': 1, '5': 9, '10': 'orderNumber'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.commerce.v1.OrderStatus', '10': 'status'},
    {'1': 'payment_status', '3': 15, '4': 1, '5': 14, '6': '.commerce.v1.PaymentStatus', '10': 'paymentStatus'},
    {'1': 'fulfilment_status', '3': 16, '4': 1, '5': 14, '6': '.commerce.v1.FulfilmentStatus', '10': 'fulfilmentStatus'},
    {'1': 'profile_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'contact_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'contactId'},
    {'1': 'address_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'addressId'},
    {'1': 'subtotal', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'subtotal'},
    {'1': 'total', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'total'},
    {'1': 'lines', '3': 10, '4': 3, '5': 11, '6': '.commerce.v1.OrderLine', '10': 'lines'},
    {'1': 'created_at', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `Order`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderDescriptor = $convert.base64Decode(
    'CgVPcmRlchIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgJpZBI0Cg'
    'dzaG9wX2lkGAIgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SBnNob3BJZBIhCgxv'
    'cmRlcl9udW1iZXIYAyABKAlSC29yZGVyTnVtYmVyEjAKBnN0YXR1cxgEIAEoDjIYLmNvbW1lcm'
    'NlLnYxLk9yZGVyU3RhdHVzUgZzdGF0dXMSQQoOcGF5bWVudF9zdGF0dXMYDyABKA4yGi5jb21t'
    'ZXJjZS52MS5QYXltZW50U3RhdHVzUg1wYXltZW50U3RhdHVzEkoKEWZ1bGZpbG1lbnRfc3RhdH'
    'VzGBAgASgOMh0uY29tbWVyY2UudjEuRnVsZmlsbWVudFN0YXR1c1IQZnVsZmlsbWVudFN0YXR1'
    'cxI6Cgpwcm9maWxlX2lkGAUgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SCXByb2'
    'ZpbGVJZBI6Cgpjb250YWN0X2lkGAYgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1S'
    'CWNvbnRhY3RJZBI6CgphZGRyZXNzX2lkGAcgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17My'
    'w0MH1SCWFkZHJlc3NJZBIsCghzdWJ0b3RhbBgIIAEoCzIQLmNvbW1vbi52MS5Nb25leVIIc3Vi'
    'dG90YWwSJgoFdG90YWwYCSABKAsyEC5jb21tb24udjEuTW9uZXlSBXRvdGFsEiwKBWxpbmVzGA'
    'ogAygLMhYuY29tbWVyY2UudjEuT3JkZXJMaW5lUgVsaW5lcxI5CgpjcmVhdGVkX2F0GAsgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use orderLineDescriptor instead')
const OrderLine$json = {
  '1': 'OrderLine',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_variant_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'sku_snapshot', '3': 3, '4': 1, '5': 9, '10': 'skuSnapshot'},
    {'1': 'name_snapshot', '3': 4, '4': 1, '5': 9, '10': 'nameSnapshot'},
    {'1': 'unit_price', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'quantity', '3': 6, '4': 1, '5': 3, '10': 'quantity'},
    {'1': 'total_price', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalPrice'},
  ],
};

/// Descriptor for `OrderLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderLineDescriptor = $convert.base64Decode(
    'CglPcmRlckxpbmUSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVICaW'
    'QSSQoScHJvZHVjdF92YXJpYW50X2lkGAIgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0'
    'MH1SEHByb2R1Y3RWYXJpYW50SWQSIQoMc2t1X3NuYXBzaG90GAMgASgJUgtza3VTbmFwc2hvdB'
    'IjCg1uYW1lX3NuYXBzaG90GAQgASgJUgxuYW1lU25hcHNob3QSLwoKdW5pdF9wcmljZRgFIAEo'
    'CzIQLmNvbW1vbi52MS5Nb25leVIJdW5pdFByaWNlEhoKCHF1YW50aXR5GAYgASgDUghxdWFudG'
    'l0eRIxCgt0b3RhbF9wcmljZRgHIAEoCzIQLmNvbW1vbi52MS5Nb25leVIKdG90YWxQcmljZQ==');

@$core.Deprecated('Use createOrderRequestDescriptor instead')
const CreateOrderRequest$json = {
  '1': 'CreateOrderRequest',
  '2': [
    {'1': 'idempotency_key', '3': 2, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'profile_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'contact_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'contactId'},
    {'1': 'address_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'addressId'},
    {'1': 'lines', '3': 10, '4': 3, '5': 11, '6': '.commerce.v1.CreateOrderLine', '10': 'lines'},
  ],
};

/// Descriptor for `CreateOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVPcmRlclJlcXVlc3QSJwoPaWRlbXBvdGVuY3lfa2V5GAIgASgJUg5pZGVtcG90ZW'
    '5jeUtleRIXCgdzaG9wX2lkGAEgASgJUgZzaG9wSWQSOgoKcHJvZmlsZV9pZBgFIAEoCUIbukgY'
    'chYQAxgoMhBbMC05YS16Xy1dezMsNDB9Uglwcm9maWxlSWQSOgoKY29udGFjdF9pZBgGIAEoCU'
    'IbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9Ugljb250YWN0SWQSOgoKYWRkcmVzc19pZBgH'
    'IAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UglhZGRyZXNzSWQSMgoFbGluZXMYCi'
    'ADKAsyHC5jb21tZXJjZS52MS5DcmVhdGVPcmRlckxpbmVSBWxpbmVz');

@$core.Deprecated('Use createOrderResponseDescriptor instead')
const CreateOrderResponse$json = {
  '1': 'CreateOrderResponse',
  '2': [
    {'1': 'order', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Order', '10': 'order'},
  ],
};

/// Descriptor for `CreateOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVPcmRlclJlc3BvbnNlEigKBW9yZGVyGAEgASgLMhIuY29tbWVyY2UudjEuT3JkZX'
    'JSBW9yZGVy');

@$core.Deprecated('Use createOrderLineDescriptor instead')
const CreateOrderLine$json = {
  '1': 'CreateOrderLine',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'variantId'},
    {'1': 'quantity', '3': 2, '4': 1, '5': 3, '10': 'quantity'},
  ],
};

/// Descriptor for `CreateOrderLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderLineDescriptor = $convert.base64Decode(
    'Cg9DcmVhdGVPcmRlckxpbmUSOgoKdmFyaWFudF9pZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9Ugl2YXJpYW50SWQSGgoIcXVhbnRpdHkYAiABKANSCHF1YW50aXR5');

@$core.Deprecated('Use getOrderRequestDescriptor instead')
const GetOrderRequest$json = {
  '1': 'GetOrderRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `GetOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrderRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRPcmRlclJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLD'
    'QwfVICaWQ=');

@$core.Deprecated('Use getOrderResponseDescriptor instead')
const GetOrderResponse$json = {
  '1': 'GetOrderResponse',
  '2': [
    {'1': 'order', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Order', '10': 'order'},
  ],
};

/// Descriptor for `GetOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrderResponseDescriptor = $convert.base64Decode(
    'ChBHZXRPcmRlclJlc3BvbnNlEigKBW9yZGVyGAEgASgLMhIuY29tbWVyY2UudjEuT3JkZXJSBW'
    '9yZGVy');

@$core.Deprecated('Use listOrdersRequestDescriptor instead')
const ListOrdersRequest$json = {
  '1': 'ListOrdersRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'search', '3': 2, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `ListOrdersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0T3JkZXJzUmVxdWVzdBI0CgdzaG9wX2lkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SBnNob3BJZBIwCgZzZWFyY2gYAiABKAsyGC5jb21tb24udjEuU2VhcmNoUmVx'
    'dWVzdFIGc2VhcmNo');

@$core.Deprecated('Use listOrdersResponseDescriptor instead')
const ListOrdersResponse$json = {
  '1': 'ListOrdersResponse',
  '2': [
    {'1': 'orders', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.Order', '10': 'orders'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `ListOrdersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0T3JkZXJzUmVzcG9uc2USKgoGb3JkZXJzGAEgAygLMhIuY29tbWVyY2UudjEuT3JkZX'
    'JSBm9yZGVycxIbCgluZXh0X3BhZ2UYAiABKAlSCG5leHRQYWdlEh8KC3ByZXZfY3Vyc29yGAMg'
    'ASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use fulfilmentDescriptor instead')
const Fulfilment$json = {
  '1': 'Fulfilment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'order_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.commerce.v1.FulfilmentStatus', '10': 'status'},
    {'1': 'carrier', '3': 4, '4': 1, '5': 9, '10': 'carrier'},
    {'1': 'tracking_number', '3': 5, '4': 1, '5': 9, '10': 'trackingNumber'},
    {'1': 'lines', '3': 6, '4': 3, '5': 11, '6': '.commerce.v1.FulfilmentLine', '10': 'lines'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'shipped_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'shippedAt'},
  ],
};

/// Descriptor for `Fulfilment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fulfilmentDescriptor = $convert.base64Decode(
    'CgpGdWxmaWxtZW50EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SAm'
    'lkEjYKCG9yZGVyX2lkGAIgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SB29yZGVy'
    'SWQSNQoGc3RhdHVzGAMgASgOMh0uY29tbWVyY2UudjEuRnVsZmlsbWVudFN0YXR1c1IGc3RhdH'
    'VzEhgKB2NhcnJpZXIYBCABKAlSB2NhcnJpZXISJwoPdHJhY2tpbmdfbnVtYmVyGAUgASgJUg50'
    'cmFja2luZ051bWJlchIxCgVsaW5lcxgGIAMoCzIbLmNvbW1lcmNlLnYxLkZ1bGZpbG1lbnRMaW'
    '5lUgVsaW5lcxI5CgpjcmVhdGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFt'
    'cFIJY3JlYXRlZEF0EjkKCnNoaXBwZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wUglzaGlwcGVkQXQ=');

@$core.Deprecated('Use fulfilmentLineDescriptor instead')
const FulfilmentLine$json = {
  '1': 'FulfilmentLine',
  '2': [
    {'1': 'order_line_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderLineId'},
    {'1': 'quantity', '3': 2, '4': 1, '5': 3, '10': 'quantity'},
  ],
};

/// Descriptor for `FulfilmentLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fulfilmentLineDescriptor = $convert.base64Decode(
    'Cg5GdWxmaWxtZW50TGluZRI/Cg1vcmRlcl9saW5lX2lkGAEgASgJQhu6SBhyFhADGCgyEFswLT'
    'lhLXpfLV17Myw0MH1SC29yZGVyTGluZUlkEhoKCHF1YW50aXR5GAIgASgDUghxdWFudGl0eQ==');

@$core.Deprecated('Use createFulfilmentRequestDescriptor instead')
const CreateFulfilmentRequest$json = {
  '1': 'CreateFulfilmentRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {'1': 'lines', '3': 2, '4': 3, '5': 11, '6': '.commerce.v1.FulfilmentLine', '10': 'lines'},
  ],
};

/// Descriptor for `CreateFulfilmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFulfilmentRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVGdWxmaWxtZW50UmVxdWVzdBI2CghvcmRlcl9pZBgBIAEoCUIbukgYchYQAxgoMh'
    'BbMC05YS16Xy1dezMsNDB9UgdvcmRlcklkEjEKBWxpbmVzGAIgAygLMhsuY29tbWVyY2UudjEu'
    'RnVsZmlsbWVudExpbmVSBWxpbmVz');

@$core.Deprecated('Use createFulfilmentResponseDescriptor instead')
const CreateFulfilmentResponse$json = {
  '1': 'CreateFulfilmentResponse',
  '2': [
    {'1': 'fulfilment', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Fulfilment', '10': 'fulfilment'},
  ],
};

/// Descriptor for `CreateFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFulfilmentResponseDescriptor = $convert.base64Decode(
    'ChhDcmVhdGVGdWxmaWxtZW50UmVzcG9uc2USNwoKZnVsZmlsbWVudBgBIAEoCzIXLmNvbW1lcm'
    'NlLnYxLkZ1bGZpbG1lbnRSCmZ1bGZpbG1lbnQ=');

@$core.Deprecated('Use updateFulfilmentRequestDescriptor instead')
const UpdateFulfilmentRequest$json = {
  '1': 'UpdateFulfilmentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.commerce.v1.FulfilmentStatus', '10': 'status'},
    {'1': 'carrier', '3': 4, '4': 1, '5': 9, '10': 'carrier'},
    {'1': 'tracking_number', '3': 5, '4': 1, '5': 9, '10': 'trackingNumber'},
    {'1': 'shipped_at', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'shippedAt'},
  ],
};

/// Descriptor for `UpdateFulfilmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFulfilmentRequestDescriptor = $convert.base64Decode(
    'ChdVcGRhdGVGdWxmaWxtZW50UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9UgJpZBI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5G'
    'aWVsZE1hc2tSCnVwZGF0ZU1hc2sSNQoGc3RhdHVzGAMgASgOMh0uY29tbWVyY2UudjEuRnVsZm'
    'lsbWVudFN0YXR1c1IGc3RhdHVzEhgKB2NhcnJpZXIYBCABKAlSB2NhcnJpZXISJwoPdHJhY2tp'
    'bmdfbnVtYmVyGAUgASgJUg50cmFja2luZ051bWJlchI5CgpzaGlwcGVkX2F0GAYgASgLMhouZ2'
    '9vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc2hpcHBlZEF0');

@$core.Deprecated('Use updateFulfilmentResponseDescriptor instead')
const UpdateFulfilmentResponse$json = {
  '1': 'UpdateFulfilmentResponse',
  '2': [
    {'1': 'fulfilment', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Fulfilment', '10': 'fulfilment'},
  ],
};

/// Descriptor for `UpdateFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFulfilmentResponseDescriptor = $convert.base64Decode(
    'ChhVcGRhdGVGdWxmaWxtZW50UmVzcG9uc2USNwoKZnVsZmlsbWVudBgBIAEoCzIXLmNvbW1lcm'
    'NlLnYxLkZ1bGZpbG1lbnRSCmZ1bGZpbG1lbnQ=');

@$core.Deprecated('Use getFulfilmentRequestDescriptor instead')
const GetFulfilmentRequest$json = {
  '1': 'GetFulfilmentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `GetFulfilmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFulfilmentRequestDescriptor = $convert.base64Decode(
    'ChRHZXRGdWxmaWxtZW50UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use getFulfilmentResponseDescriptor instead')
const GetFulfilmentResponse$json = {
  '1': 'GetFulfilmentResponse',
  '2': [
    {'1': 'fulfilment', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.Fulfilment', '10': 'fulfilment'},
  ],
};

/// Descriptor for `GetFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFulfilmentResponseDescriptor = $convert.base64Decode(
    'ChVHZXRGdWxmaWxtZW50UmVzcG9uc2USNwoKZnVsZmlsbWVudBgBIAEoCzIXLmNvbW1lcmNlLn'
    'YxLkZ1bGZpbG1lbnRSCmZ1bGZpbG1lbnQ=');

@$core.Deprecated('Use priceListDescriptor instead')
const PriceList$json = {
  '1': 'PriceList',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'priority', '3': 5, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'valid_from', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.PriceListStatus', '10': 'status'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `PriceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListDescriptor = $convert.base64Decode(
    'CglQcmljZUxpc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVICaW'
    'QSNAoHc2hvcF9pZBgCIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgZzaG9wSWQS'
    'EgoEbmFtZRgDIAEoCVIEbmFtZRIaCghjdXJyZW5jeRgEIAEoCVIIY3VycmVuY3kSGgoIcHJpb3'
    'JpdHkYBSABKAVSCHByaW9yaXR5EjkKCnZhbGlkX2Zyb20YBiABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUgl2YWxpZEZyb20SOwoLdmFsaWRfdW50aWwYByABKAsyGi5nb29nbGUucH'
    'JvdG9idWYuVGltZXN0YW1wUgp2YWxpZFVudGlsEjQKBnN0YXR1cxgIIAEoDjIcLmNvbW1lcmNl'
    'LnYxLlByaWNlTGlzdFN0YXR1c1IGc3RhdHVzEjkKCmNyZWF0ZWRfYXQYCiABKAsyGi5nb29nbG'
    'UucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use priceListEntryDescriptor instead')
const PriceListEntry$json = {
  '1': 'PriceListEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'price_list_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'priceListId'},
    {'1': 'product_variant_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'unit_price', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'min_quantity', '3': 5, '4': 1, '5': 5, '10': 'minQuantity'},
    {'1': 'max_quantity', '3': 6, '4': 1, '5': 5, '10': 'maxQuantity'},
  ],
};

/// Descriptor for `PriceListEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListEntryDescriptor = $convert.base64Decode(
    'Cg5QcmljZUxpc3RFbnRyeRIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsND'
    'B9UgJpZBI/Cg1wcmljZV9saXN0X2lkGAIgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0'
    'MH1SC3ByaWNlTGlzdElkEkkKEnByb2R1Y3RfdmFyaWFudF9pZBgDIAEoCUIbukgYchYQAxgoMh'
    'BbMC05YS16Xy1dezMsNDB9UhBwcm9kdWN0VmFyaWFudElkEi8KCnVuaXRfcHJpY2UYBCABKAsy'
    'EC5jb21tb24udjEuTW9uZXlSCXVuaXRQcmljZRIhCgxtaW5fcXVhbnRpdHkYBSABKAVSC21pbl'
    'F1YW50aXR5EiEKDG1heF9xdWFudGl0eRgGIAEoBVILbWF4UXVhbnRpdHk=');

@$core.Deprecated('Use customerPriceListAssignmentDescriptor instead')
const CustomerPriceListAssignment$json = {
  '1': 'CustomerPriceListAssignment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'customer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {'1': 'price_list_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'priceListId'},
    {'1': 'assigned_by', '3': 4, '4': 1, '5': 9, '10': 'assignedBy'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.commerce.v1.CustomerPriceListAssignmentStatus', '10': 'status'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `CustomerPriceListAssignment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentDescriptor = $convert.base64Decode(
    'ChtDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnQSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWz'
    'AtOWEtel8tXXszLDQwfVICaWQSPAoLY3VzdG9tZXJfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAt'
    'OWEtel8tXXszLDQwfVIKY3VzdG9tZXJJZBI/Cg1wcmljZV9saXN0X2lkGAMgASgJQhu6SBhyFh'
    'ADGCgyEFswLTlhLXpfLV17Myw0MH1SC3ByaWNlTGlzdElkEh8KC2Fzc2lnbmVkX2J5GAQgASgJ'
    'Ugphc3NpZ25lZEJ5EkYKBnN0YXR1cxgFIAEoDjIuLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2'
    'VMaXN0QXNzaWdubWVudFN0YXR1c1IGc3RhdHVzEjkKCmNyZWF0ZWRfYXQYCiABKAsyGi5nb29n'
    'bGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use customerPriceOverrideDescriptor instead')
const CustomerPriceOverride$json = {
  '1': 'CustomerPriceOverride',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'customer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {'1': 'product_variant_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'unit_price', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'valid_from', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'approved_by', '3': 7, '4': 1, '5': 9, '10': 'approvedBy'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.CustomerPriceOverrideStatus', '10': 'status'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `CustomerPriceOverride`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideDescriptor = $convert.base64Decode(
    'ChVDdXN0b21lclByaWNlT3ZlcnJpZGUSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQSPAoLY3VzdG9tZXJfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8t'
    'XXszLDQwfVIKY3VzdG9tZXJJZBJJChJwcm9kdWN0X3ZhcmlhbnRfaWQYAyABKAlCG7pIGHIWEA'
    'MYKDIQWzAtOWEtel8tXXszLDQwfVIQcHJvZHVjdFZhcmlhbnRJZBIvCgp1bml0X3ByaWNlGAQg'
    'ASgLMhAuY29tbW9uLnYxLk1vbmV5Ugl1bml0UHJpY2USOQoKdmFsaWRfZnJvbRgFIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXZhbGlkRnJvbRI7Cgt2YWxpZF91bnRpbBgGIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnZhbGlkVW50aWwSHwoLYXBwcm92ZWRfYn'
    'kYByABKAlSCmFwcHJvdmVkQnkSQAoGc3RhdHVzGAggASgOMiguY29tbWVyY2UudjEuQ3VzdG9t'
    'ZXJQcmljZU92ZXJyaWRlU3RhdHVzUgZzdGF0dXMSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use discountRuleDescriptor instead')
const DiscountRule$json = {
  '1': 'DiscountRule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'discount_type', '3': 4, '4': 1, '5': 14, '6': '.commerce.v1.DiscountType', '10': 'discountType'},
    {'1': 'value', '3': 5, '4': 1, '5': 1, '10': 'value'},
    {'1': 'applies_to', '3': 6, '4': 1, '5': 14, '6': '.commerce.v1.DiscountAppliesTo', '10': 'appliesTo'},
    {'1': 'conditions', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'conditions'},
    {'1': 'requires_approval', '3': 8, '4': 1, '5': 8, '10': 'requiresApproval'},
    {'1': 'max_discount_percent', '3': 9, '4': 1, '5': 1, '10': 'maxDiscountPercent'},
    {'1': 'valid_from', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'status', '3': 12, '4': 1, '5': 14, '6': '.commerce.v1.DiscountRuleStatus', '10': 'status'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `DiscountRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleDescriptor = $convert.base64Decode(
    'CgxEaXNjb3VudFJ1bGUSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfV'
    'ICaWQSNAoHc2hvcF9pZBgCIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgZzaG9w'
    'SWQSEgoEbmFtZRgDIAEoCVIEbmFtZRI+Cg1kaXNjb3VudF90eXBlGAQgASgOMhkuY29tbWVyY2'
    'UudjEuRGlzY291bnRUeXBlUgxkaXNjb3VudFR5cGUSFAoFdmFsdWUYBSABKAFSBXZhbHVlEj0K'
    'CmFwcGxpZXNfdG8YBiABKA4yHi5jb21tZXJjZS52MS5EaXNjb3VudEFwcGxpZXNUb1IJYXBwbG'
    'llc1RvEjcKCmNvbmRpdGlvbnMYByABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpjb25k'
    'aXRpb25zEisKEXJlcXVpcmVzX2FwcHJvdmFsGAggASgIUhByZXF1aXJlc0FwcHJvdmFsEjAKFG'
    '1heF9kaXNjb3VudF9wZXJjZW50GAkgASgBUhJtYXhEaXNjb3VudFBlcmNlbnQSOQoKdmFsaWRf'
    'ZnJvbRgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXZhbGlkRnJvbRI7Cgt2YW'
    'xpZF91bnRpbBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnZhbGlkVW50aWwS'
    'NwoGc3RhdHVzGAwgASgOMh8uY29tbWVyY2UudjEuRGlzY291bnRSdWxlU3RhdHVzUgZzdGF0dX'
    'MSOQoKY3JlYXRlZF9hdBgPIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0'
    'ZWRBdA==');

@$core.Deprecated('Use resolvedPriceDescriptor instead')
const ResolvedPrice$json = {
  '1': 'ResolvedPrice',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'variantId'},
    {'1': 'unit_price', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'price_source', '3': 3, '4': 1, '5': 14, '6': '.commerce.v1.PriceSource', '10': 'priceSource'},
    {'1': 'price_list_id', '3': 4, '4': 1, '5': 9, '10': 'priceListId'},
    {'1': 'override_id', '3': 5, '4': 1, '5': 9, '10': 'overrideId'},
    {'1': 'discount_amount', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'discountAmount'},
    {'1': 'discount_rule_id', '3': 7, '4': 1, '5': 9, '10': 'discountRuleId'},
    {'1': 'pre_discount_price', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'preDiscountPrice'},
  ],
};

/// Descriptor for `ResolvedPrice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolvedPriceDescriptor = $convert.base64Decode(
    'Cg1SZXNvbHZlZFByaWNlEjoKCnZhcmlhbnRfaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVIJdmFyaWFudElkEi8KCnVuaXRfcHJpY2UYAiABKAsyEC5jb21tb24udjEuTW9u'
    'ZXlSCXVuaXRQcmljZRI7CgxwcmljZV9zb3VyY2UYAyABKA4yGC5jb21tZXJjZS52MS5QcmljZV'
    'NvdXJjZVILcHJpY2VTb3VyY2USIgoNcHJpY2VfbGlzdF9pZBgEIAEoCVILcHJpY2VMaXN0SWQS'
    'HwoLb3ZlcnJpZGVfaWQYBSABKAlSCm92ZXJyaWRlSWQSOQoPZGlzY291bnRfYW1vdW50GAYgAS'
    'gLMhAuY29tbW9uLnYxLk1vbmV5Ug5kaXNjb3VudEFtb3VudBIoChBkaXNjb3VudF9ydWxlX2lk'
    'GAcgASgJUg5kaXNjb3VudFJ1bGVJZBI+ChJwcmVfZGlzY291bnRfcHJpY2UYCCABKAsyEC5jb2'
    '1tb24udjEuTW9uZXlSEHByZURpc2NvdW50UHJpY2U=');

@$core.Deprecated('Use priceListSaveRequestDescriptor instead')
const PriceListSaveRequest$json = {
  '1': 'PriceListSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'priority', '3': 5, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'valid_from', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.PriceListStatus', '10': 'status'},
  ],
};

/// Descriptor for `PriceListSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListSaveRequestDescriptor = $convert.base64Decode(
    'ChRQcmljZUxpc3RTYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSNAoHc2hvcF9pZBgCIAEoCU'
    'IbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgZzaG9wSWQSEgoEbmFtZRgDIAEoCVIEbmFt'
    'ZRIaCghjdXJyZW5jeRgEIAEoCVIIY3VycmVuY3kSGgoIcHJpb3JpdHkYBSABKAVSCHByaW9yaX'
    'R5EjkKCnZhbGlkX2Zyb20YBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl2YWxp'
    'ZEZyb20SOwoLdmFsaWRfdW50aWwYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    'p2YWxpZFVudGlsEjQKBnN0YXR1cxgIIAEoDjIcLmNvbW1lcmNlLnYxLlByaWNlTGlzdFN0YXR1'
    'c1IGc3RhdHVz');

@$core.Deprecated('Use priceListSaveResponseDescriptor instead')
const PriceListSaveResponse$json = {
  '1': 'PriceListSaveResponse',
  '2': [
    {'1': 'price_list', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.PriceList', '10': 'priceList'},
  ],
};

/// Descriptor for `PriceListSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListSaveResponseDescriptor = $convert.base64Decode(
    'ChVQcmljZUxpc3RTYXZlUmVzcG9uc2USNQoKcHJpY2VfbGlzdBgBIAEoCzIWLmNvbW1lcmNlLn'
    'YxLlByaWNlTGlzdFIJcHJpY2VMaXN0');

@$core.Deprecated('Use priceListGetRequestDescriptor instead')
const PriceListGetRequest$json = {
  '1': 'PriceListGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `PriceListGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListGetRequestDescriptor = $convert.base64Decode(
    'ChNQcmljZUxpc3RHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV'
    '17Myw0MH1SAmlk');

@$core.Deprecated('Use priceListGetResponseDescriptor instead')
const PriceListGetResponse$json = {
  '1': 'PriceListGetResponse',
  '2': [
    {'1': 'price_list', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.PriceList', '10': 'priceList'},
  ],
};

/// Descriptor for `PriceListGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListGetResponseDescriptor = $convert.base64Decode(
    'ChRQcmljZUxpc3RHZXRSZXNwb25zZRI1CgpwcmljZV9saXN0GAEgASgLMhYuY29tbWVyY2Uudj'
    'EuUHJpY2VMaXN0UglwcmljZUxpc3Q=');

@$core.Deprecated('Use priceListSearchRequestDescriptor instead')
const PriceListSearchRequest$json = {
  '1': 'PriceListSearchRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'search', '3': 2, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `PriceListSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListSearchRequestDescriptor = $convert.base64Decode(
    'ChZQcmljZUxpc3RTZWFyY2hSZXF1ZXN0EjQKB3Nob3BfaWQYASABKAlCG7pIGHIWEAMYKDIQWz'
    'AtOWEtel8tXXszLDQwfVIGc2hvcElkEjAKBnNlYXJjaBgCIAEoCzIYLmNvbW1vbi52MS5TZWFy'
    'Y2hSZXF1ZXN0UgZzZWFyY2g=');

@$core.Deprecated('Use priceListSearchResponseDescriptor instead')
const PriceListSearchResponse$json = {
  '1': 'PriceListSearchResponse',
  '2': [
    {'1': 'price_lists', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.PriceList', '10': 'priceLists'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `PriceListSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListSearchResponseDescriptor = $convert.base64Decode(
    'ChdQcmljZUxpc3RTZWFyY2hSZXNwb25zZRI3CgtwcmljZV9saXN0cxgBIAMoCzIWLmNvbW1lcm'
    'NlLnYxLlByaWNlTGlzdFIKcHJpY2VMaXN0cxIbCgluZXh0X3BhZ2UYAiABKAlSCG5leHRQYWdl'
    'Eh8KC3ByZXZfY3Vyc29yGAMgASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use priceListEntryBatchSaveRequestDescriptor instead')
const PriceListEntryBatchSaveRequest$json = {
  '1': 'PriceListEntryBatchSaveRequest',
  '2': [
    {'1': 'price_list_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'priceListId'},
    {'1': 'entries', '3': 2, '4': 3, '5': 11, '6': '.commerce.v1.PriceListEntry', '10': 'entries'},
  ],
};

/// Descriptor for `PriceListEntryBatchSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListEntryBatchSaveRequestDescriptor = $convert.base64Decode(
    'Ch5QcmljZUxpc3RFbnRyeUJhdGNoU2F2ZVJlcXVlc3QSPwoNcHJpY2VfbGlzdF9pZBgBIAEoCU'
    'IbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgtwcmljZUxpc3RJZBI1CgdlbnRyaWVzGAIg'
    'AygLMhsuY29tbWVyY2UudjEuUHJpY2VMaXN0RW50cnlSB2VudHJpZXM=');

@$core.Deprecated('Use priceListEntryBatchSaveResponseDescriptor instead')
const PriceListEntryBatchSaveResponse$json = {
  '1': 'PriceListEntryBatchSaveResponse',
  '2': [
    {'1': 'entries', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.PriceListEntry', '10': 'entries'},
  ],
};

/// Descriptor for `PriceListEntryBatchSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListEntryBatchSaveResponseDescriptor = $convert.base64Decode(
    'Ch9QcmljZUxpc3RFbnRyeUJhdGNoU2F2ZVJlc3BvbnNlEjUKB2VudHJpZXMYASADKAsyGy5jb2'
    '1tZXJjZS52MS5QcmljZUxpc3RFbnRyeVIHZW50cmllcw==');

@$core.Deprecated('Use customerPriceListAssignmentSaveRequestDescriptor instead')
const CustomerPriceListAssignmentSaveRequest$json = {
  '1': 'CustomerPriceListAssignmentSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'customer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {'1': 'price_list_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'priceListId'},
    {'1': 'assigned_by', '3': 4, '4': 1, '5': 9, '10': 'assignedBy'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.commerce.v1.CustomerPriceListAssignmentStatus', '10': 'status'},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSaveRequestDescriptor = $convert.base64Decode(
    'CiZDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaW'
    'QSPAoLY3VzdG9tZXJfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVIKY3Vz'
    'dG9tZXJJZBI/Cg1wcmljZV9saXN0X2lkGAMgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17My'
    'w0MH1SC3ByaWNlTGlzdElkEh8KC2Fzc2lnbmVkX2J5GAQgASgJUgphc3NpZ25lZEJ5EkYKBnN0'
    'YXR1cxgFIAEoDjIuLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFN0YX'
    'R1c1IGc3RhdHVz');

@$core.Deprecated('Use customerPriceListAssignmentSaveResponseDescriptor instead')
const CustomerPriceListAssignmentSaveResponse$json = {
  '1': 'CustomerPriceListAssignmentSaveResponse',
  '2': [
    {'1': 'assignment', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.CustomerPriceListAssignment', '10': 'assignment'},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSaveResponseDescriptor = $convert.base64Decode(
    'CidDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTYXZlUmVzcG9uc2USSAoKYXNzaWdubWVudB'
    'gBIAEoCzIoLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFIKYXNzaWdu'
    'bWVudA==');

@$core.Deprecated('Use customerPriceListAssignmentSearchRequestDescriptor instead')
const CustomerPriceListAssignmentSearchRequest$json = {
  '1': 'CustomerPriceListAssignmentSearchRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '10': 'customerId'},
    {'1': 'price_list_id', '3': 2, '4': 1, '5': 9, '10': 'priceListId'},
    {'1': 'search', '3': 3, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSearchRequestDescriptor = $convert.base64Decode(
    'CihDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTZWFyY2hSZXF1ZXN0Eh8KC2N1c3RvbWVyX2'
    'lkGAEgASgJUgpjdXN0b21lcklkEiIKDXByaWNlX2xpc3RfaWQYAiABKAlSC3ByaWNlTGlzdElk'
    'EjAKBnNlYXJjaBgDIAEoCzIYLmNvbW1vbi52MS5TZWFyY2hSZXF1ZXN0UgZzZWFyY2g=');

@$core.Deprecated('Use customerPriceListAssignmentSearchResponseDescriptor instead')
const CustomerPriceListAssignmentSearchResponse$json = {
  '1': 'CustomerPriceListAssignmentSearchResponse',
  '2': [
    {'1': 'assignments', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.CustomerPriceListAssignment', '10': 'assignments'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSearchResponseDescriptor = $convert.base64Decode(
    'CilDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTZWFyY2hSZXNwb25zZRJKCgthc3NpZ25tZW'
    '50cxgBIAMoCzIoLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFILYXNz'
    'aWdubWVudHMSGwoJbmV4dF9wYWdlGAIgASgJUghuZXh0UGFnZRIfCgtwcmV2X2N1cnNvchgDIA'
    'EoCVIKcHJldkN1cnNvcg==');

@$core.Deprecated('Use customerPriceOverrideSaveRequestDescriptor instead')
const CustomerPriceOverrideSaveRequest$json = {
  '1': 'CustomerPriceOverrideSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'customer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {'1': 'product_variant_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'unit_price', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unitPrice'},
    {'1': 'valid_from', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'approved_by', '3': 7, '4': 1, '5': 9, '10': 'approvedBy'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.commerce.v1.CustomerPriceOverrideStatus', '10': 'status'},
  ],
};

/// Descriptor for `CustomerPriceOverrideSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSaveRequestDescriptor = $convert.base64Decode(
    'CiBDdXN0b21lclByaWNlT3ZlcnJpZGVTYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSPAoLY3'
    'VzdG9tZXJfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVIKY3VzdG9tZXJJ'
    'ZBJJChJwcm9kdWN0X3ZhcmlhbnRfaWQYAyABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLD'
    'QwfVIQcHJvZHVjdFZhcmlhbnRJZBIvCgp1bml0X3ByaWNlGAQgASgLMhAuY29tbW9uLnYxLk1v'
    'bmV5Ugl1bml0UHJpY2USOQoKdmFsaWRfZnJvbRgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCXZhbGlkRnJvbRI7Cgt2YWxpZF91bnRpbBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSCnZhbGlkVW50aWwSHwoLYXBwcm92ZWRfYnkYByABKAlSCmFwcHJvdmVkQn'
    'kSQAoGc3RhdHVzGAggASgOMiguY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZU92ZXJyaWRlU3Rh'
    'dHVzUgZzdGF0dXM=');

@$core.Deprecated('Use customerPriceOverrideSaveResponseDescriptor instead')
const CustomerPriceOverrideSaveResponse$json = {
  '1': 'CustomerPriceOverrideSaveResponse',
  '2': [
    {'1': 'override', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.CustomerPriceOverride', '10': 'override'},
  ],
};

/// Descriptor for `CustomerPriceOverrideSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSaveResponseDescriptor = $convert.base64Decode(
    'CiFDdXN0b21lclByaWNlT3ZlcnJpZGVTYXZlUmVzcG9uc2USPgoIb3ZlcnJpZGUYASABKAsyIi'
    '5jb21tZXJjZS52MS5DdXN0b21lclByaWNlT3ZlcnJpZGVSCG92ZXJyaWRl');

@$core.Deprecated('Use customerPriceOverrideSearchRequestDescriptor instead')
const CustomerPriceOverrideSearchRequest$json = {
  '1': 'CustomerPriceOverrideSearchRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '10': 'customerId'},
    {'1': 'product_variant_id', '3': 2, '4': 1, '5': 9, '10': 'productVariantId'},
    {'1': 'search', '3': 3, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `CustomerPriceOverrideSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSearchRequestDescriptor = $convert.base64Decode(
    'CiJDdXN0b21lclByaWNlT3ZlcnJpZGVTZWFyY2hSZXF1ZXN0Eh8KC2N1c3RvbWVyX2lkGAEgAS'
    'gJUgpjdXN0b21lcklkEiwKEnByb2R1Y3RfdmFyaWFudF9pZBgCIAEoCVIQcHJvZHVjdFZhcmlh'
    'bnRJZBIwCgZzZWFyY2gYAyABKAsyGC5jb21tb24udjEuU2VhcmNoUmVxdWVzdFIGc2VhcmNo');

@$core.Deprecated('Use customerPriceOverrideSearchResponseDescriptor instead')
const CustomerPriceOverrideSearchResponse$json = {
  '1': 'CustomerPriceOverrideSearchResponse',
  '2': [
    {'1': 'overrides', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.CustomerPriceOverride', '10': 'overrides'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `CustomerPriceOverrideSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSearchResponseDescriptor = $convert.base64Decode(
    'CiNDdXN0b21lclByaWNlT3ZlcnJpZGVTZWFyY2hSZXNwb25zZRJACglvdmVycmlkZXMYASADKA'
    'syIi5jb21tZXJjZS52MS5DdXN0b21lclByaWNlT3ZlcnJpZGVSCW92ZXJyaWRlcxIbCgluZXh0'
    'X3BhZ2UYAiABKAlSCG5leHRQYWdlEh8KC3ByZXZfY3Vyc29yGAMgASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use discountRuleSaveRequestDescriptor instead')
const DiscountRuleSaveRequest$json = {
  '1': 'DiscountRuleSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'discount_type', '3': 4, '4': 1, '5': 14, '6': '.commerce.v1.DiscountType', '10': 'discountType'},
    {'1': 'value', '3': 5, '4': 1, '5': 1, '10': 'value'},
    {'1': 'applies_to', '3': 6, '4': 1, '5': 14, '6': '.commerce.v1.DiscountAppliesTo', '10': 'appliesTo'},
    {'1': 'conditions', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'conditions'},
    {'1': 'requires_approval', '3': 8, '4': 1, '5': 8, '10': 'requiresApproval'},
    {'1': 'max_discount_percent', '3': 9, '4': 1, '5': 1, '10': 'maxDiscountPercent'},
    {'1': 'valid_from', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validFrom'},
    {'1': 'valid_until', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'validUntil'},
    {'1': 'status', '3': 12, '4': 1, '5': 14, '6': '.commerce.v1.DiscountRuleStatus', '10': 'status'},
  ],
};

/// Descriptor for `DiscountRuleSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSaveRequestDescriptor = $convert.base64Decode(
    'ChdEaXNjb3VudFJ1bGVTYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSNAoHc2hvcF9pZBgCIA'
    'EoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgZzaG9wSWQSEgoEbmFtZRgDIAEoCVIE'
    'bmFtZRI+Cg1kaXNjb3VudF90eXBlGAQgASgOMhkuY29tbWVyY2UudjEuRGlzY291bnRUeXBlUg'
    'xkaXNjb3VudFR5cGUSFAoFdmFsdWUYBSABKAFSBXZhbHVlEj0KCmFwcGxpZXNfdG8YBiABKA4y'
    'Hi5jb21tZXJjZS52MS5EaXNjb3VudEFwcGxpZXNUb1IJYXBwbGllc1RvEjcKCmNvbmRpdGlvbn'
    'MYByABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpjb25kaXRpb25zEisKEXJlcXVpcmVz'
    'X2FwcHJvdmFsGAggASgIUhByZXF1aXJlc0FwcHJvdmFsEjAKFG1heF9kaXNjb3VudF9wZXJjZW'
    '50GAkgASgBUhJtYXhEaXNjb3VudFBlcmNlbnQSOQoKdmFsaWRfZnJvbRgKIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXZhbGlkRnJvbRI7Cgt2YWxpZF91bnRpbBgLIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnZhbGlkVW50aWwSNwoGc3RhdHVzGAwgASgOMh8u'
    'Y29tbWVyY2UudjEuRGlzY291bnRSdWxlU3RhdHVzUgZzdGF0dXM=');

@$core.Deprecated('Use discountRuleSaveResponseDescriptor instead')
const DiscountRuleSaveResponse$json = {
  '1': 'DiscountRuleSaveResponse',
  '2': [
    {'1': 'discount_rule', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.DiscountRule', '10': 'discountRule'},
  ],
};

/// Descriptor for `DiscountRuleSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSaveResponseDescriptor = $convert.base64Decode(
    'ChhEaXNjb3VudFJ1bGVTYXZlUmVzcG9uc2USPgoNZGlzY291bnRfcnVsZRgBIAEoCzIZLmNvbW'
    '1lcmNlLnYxLkRpc2NvdW50UnVsZVIMZGlzY291bnRSdWxl');

@$core.Deprecated('Use discountRuleSearchRequestDescriptor instead')
const DiscountRuleSearchRequest$json = {
  '1': 'DiscountRuleSearchRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'search', '3': 2, '4': 1, '5': 11, '6': '.common.v1.SearchRequest', '10': 'search'},
  ],
};

/// Descriptor for `DiscountRuleSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSearchRequestDescriptor = $convert.base64Decode(
    'ChlEaXNjb3VudFJ1bGVTZWFyY2hSZXF1ZXN0EjQKB3Nob3BfaWQYASABKAlCG7pIGHIWEAMYKD'
    'IQWzAtOWEtel8tXXszLDQwfVIGc2hvcElkEjAKBnNlYXJjaBgCIAEoCzIYLmNvbW1vbi52MS5T'
    'ZWFyY2hSZXF1ZXN0UgZzZWFyY2g=');

@$core.Deprecated('Use discountRuleSearchResponseDescriptor instead')
const DiscountRuleSearchResponse$json = {
  '1': 'DiscountRuleSearchResponse',
  '2': [
    {'1': 'discount_rules', '3': 1, '4': 3, '5': 11, '6': '.commerce.v1.DiscountRule', '10': 'discountRules'},
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `DiscountRuleSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSearchResponseDescriptor = $convert.base64Decode(
    'ChpEaXNjb3VudFJ1bGVTZWFyY2hSZXNwb25zZRJACg5kaXNjb3VudF9ydWxlcxgBIAMoCzIZLm'
    'NvbW1lcmNlLnYxLkRpc2NvdW50UnVsZVINZGlzY291bnRSdWxlcxIbCgluZXh0X3BhZ2UYAiAB'
    'KAlSCG5leHRQYWdlEh8KC3ByZXZfY3Vyc29yGAMgASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use resolvePriceRequestDescriptor instead')
const ResolvePriceRequest$json = {
  '1': 'ResolvePriceRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {'1': 'product_variant_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productVariantId'},
    {'1': 'quantity', '3': 3, '4': 1, '5': 5, '10': 'quantity'},
  ],
};

/// Descriptor for `ResolvePriceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolvePriceRequestDescriptor = $convert.base64Decode(
    'ChNSZXNvbHZlUHJpY2VSZXF1ZXN0EjwKC2N1c3RvbWVyX2lkGAEgASgJQhu6SBhyFhADGCgyEF'
    'swLTlhLXpfLV17Myw0MH1SCmN1c3RvbWVySWQSSQoScHJvZHVjdF92YXJpYW50X2lkGAIgASgJ'
    'Qhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SEHByb2R1Y3RWYXJpYW50SWQSGgoIcXVhbn'
    'RpdHkYAyABKAVSCHF1YW50aXR5');

@$core.Deprecated('Use resolvePriceResponseDescriptor instead')
const ResolvePriceResponse$json = {
  '1': 'ResolvePriceResponse',
  '2': [
    {'1': 'resolved_price', '3': 1, '4': 1, '5': 11, '6': '.commerce.v1.ResolvedPrice', '10': 'resolvedPrice'},
  ],
};

/// Descriptor for `ResolvePriceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolvePriceResponseDescriptor = $convert.base64Decode(
    'ChRSZXNvbHZlUHJpY2VSZXNwb25zZRJBCg5yZXNvbHZlZF9wcmljZRgBIAEoCzIaLmNvbW1lcm'
    'NlLnYxLlJlc29sdmVkUHJpY2VSDXJlc29sdmVkUHJpY2U=');

const $core.Map<$core.String, $core.dynamic> CommerceServiceBase$json = {
  '1': 'CommerceService',
  '2': [
    {'1': 'CreateShop', '2': '.commerce.v1.CreateShopRequest', '3': '.commerce.v1.CreateShopResponse', '4': {}},
    {'1': 'GetShop', '2': '.commerce.v1.GetShopRequest', '3': '.commerce.v1.GetShopResponse', '4': {}},
    {'1': 'UpdateShop', '2': '.commerce.v1.UpdateShopRequest', '3': '.commerce.v1.UpdateShopResponse', '4': {}},
    {'1': 'CreateProduct', '2': '.commerce.v1.CreateProductRequest', '3': '.commerce.v1.CreateProductResponse', '4': {}},
    {'1': 'GetProduct', '2': '.commerce.v1.GetProductRequest', '3': '.commerce.v1.GetProductResponse', '4': {}},
    {'1': 'ListProducts', '2': '.commerce.v1.ListProductsRequest', '3': '.commerce.v1.ListProductsResponse', '4': {}},
    {'1': 'CreateProductVariant', '2': '.commerce.v1.CreateProductVariantRequest', '3': '.commerce.v1.CreateProductVariantResponse', '4': {}},
    {'1': 'UpdateProductVariant', '2': '.commerce.v1.UpdateProductVariantRequest', '3': '.commerce.v1.UpdateProductVariantResponse', '4': {}},
    {'1': 'CreateCart', '2': '.commerce.v1.CreateCartRequest', '3': '.commerce.v1.CreateCartResponse', '4': {}},
    {'1': 'GetCart', '2': '.commerce.v1.GetCartRequest', '3': '.commerce.v1.GetCartResponse', '4': {}},
    {'1': 'AddCartLine', '2': '.commerce.v1.AddCartLineRequest', '3': '.commerce.v1.AddCartLineResponse', '4': {}},
    {'1': 'RemoveCartLine', '2': '.commerce.v1.RemoveCartLineRequest', '3': '.commerce.v1.RemoveCartLineResponse', '4': {}},
    {'1': 'CreateOrderFromCart', '2': '.commerce.v1.CreateOrderFromCartRequest', '3': '.commerce.v1.CreateOrderFromCartResponse', '4': {}},
    {'1': 'CreateOrder', '2': '.commerce.v1.CreateOrderRequest', '3': '.commerce.v1.CreateOrderResponse', '4': {}},
    {'1': 'GetOrder', '2': '.commerce.v1.GetOrderRequest', '3': '.commerce.v1.GetOrderResponse', '4': {}},
    {'1': 'ListOrders', '2': '.commerce.v1.ListOrdersRequest', '3': '.commerce.v1.ListOrdersResponse', '4': {}},
    {'1': 'CreateFulfilment', '2': '.commerce.v1.CreateFulfilmentRequest', '3': '.commerce.v1.CreateFulfilmentResponse', '4': {}},
    {'1': 'UpdateFulfilment', '2': '.commerce.v1.UpdateFulfilmentRequest', '3': '.commerce.v1.UpdateFulfilmentResponse', '4': {}},
    {'1': 'GetFulfilment', '2': '.commerce.v1.GetFulfilmentRequest', '3': '.commerce.v1.GetFulfilmentResponse', '4': {}},
    {'1': 'PriceListSave', '2': '.commerce.v1.PriceListSaveRequest', '3': '.commerce.v1.PriceListSaveResponse', '4': {}},
    {'1': 'PriceListGet', '2': '.commerce.v1.PriceListGetRequest', '3': '.commerce.v1.PriceListGetResponse', '4': {}},
    {'1': 'PriceListSearch', '2': '.commerce.v1.PriceListSearchRequest', '3': '.commerce.v1.PriceListSearchResponse', '4': {}},
    {'1': 'PriceListEntryBatchSave', '2': '.commerce.v1.PriceListEntryBatchSaveRequest', '3': '.commerce.v1.PriceListEntryBatchSaveResponse', '4': {}},
    {'1': 'CustomerPriceListAssignmentSave', '2': '.commerce.v1.CustomerPriceListAssignmentSaveRequest', '3': '.commerce.v1.CustomerPriceListAssignmentSaveResponse', '4': {}},
    {'1': 'CustomerPriceListAssignmentSearch', '2': '.commerce.v1.CustomerPriceListAssignmentSearchRequest', '3': '.commerce.v1.CustomerPriceListAssignmentSearchResponse', '4': {}},
    {'1': 'CustomerPriceOverrideSave', '2': '.commerce.v1.CustomerPriceOverrideSaveRequest', '3': '.commerce.v1.CustomerPriceOverrideSaveResponse', '4': {}},
    {'1': 'CustomerPriceOverrideSearch', '2': '.commerce.v1.CustomerPriceOverrideSearchRequest', '3': '.commerce.v1.CustomerPriceOverrideSearchResponse', '4': {}},
    {'1': 'DiscountRuleSave', '2': '.commerce.v1.DiscountRuleSaveRequest', '3': '.commerce.v1.DiscountRuleSaveResponse', '4': {}},
    {'1': 'DiscountRuleSearch', '2': '.commerce.v1.DiscountRuleSearchRequest', '3': '.commerce.v1.DiscountRuleSearchResponse', '4': {}},
    {'1': 'ResolvePrice', '2': '.commerce.v1.ResolvePriceRequest', '3': '.commerce.v1.ResolvePriceResponse', '4': {}},
  ],
  '3': {},
};

@$core.Deprecated('Use commerceServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> CommerceServiceBase$messageJson = {
  '.commerce.v1.CreateShopRequest': CreateShopRequest$json,
  '.commerce.v1.CreateShopResponse': CreateShopResponse$json,
  '.commerce.v1.Shop': Shop$json,
  '.google.protobuf.Timestamp': $2.Timestamp$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.commerce.v1.GetShopRequest': GetShopRequest$json,
  '.commerce.v1.GetShopResponse': GetShopResponse$json,
  '.commerce.v1.UpdateShopRequest': UpdateShopRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.commerce.v1.UpdateShopResponse': UpdateShopResponse$json,
  '.commerce.v1.CreateProductRequest': CreateProductRequest$json,
  '.commerce.v1.CreateProductRequest.AttributesEntry': CreateProductRequest_AttributesEntry$json,
  '.commerce.v1.CreateProductResponse': CreateProductResponse$json,
  '.commerce.v1.Product': Product$json,
  '.commerce.v1.Product.AttributesEntry': Product_AttributesEntry$json,
  '.commerce.v1.GetProductRequest': GetProductRequest$json,
  '.commerce.v1.GetProductResponse': GetProductResponse$json,
  '.commerce.v1.ListProductsRequest': ListProductsRequest$json,
  '.common.v1.SearchRequest': $8.SearchRequest$json,
  '.common.v1.PageCursor': $8.PageCursor$json,
  '.commerce.v1.ListProductsResponse': ListProductsResponse$json,
  '.commerce.v1.CreateProductVariantRequest': CreateProductVariantRequest$json,
  '.common.v1.Money': $7.Money$json,
  '.commerce.v1.CreateProductVariantRequest.AttributesEntry': CreateProductVariantRequest_AttributesEntry$json,
  '.commerce.v1.CreateProductVariantResponse': CreateProductVariantResponse$json,
  '.commerce.v1.ProductVariant': ProductVariant$json,
  '.commerce.v1.ProductVariant.AttributesEntry': ProductVariant_AttributesEntry$json,
  '.commerce.v1.UpdateProductVariantRequest': UpdateProductVariantRequest$json,
  '.commerce.v1.UpdateProductVariantRequest.AttributesEntry': UpdateProductVariantRequest_AttributesEntry$json,
  '.commerce.v1.UpdateProductVariantResponse': UpdateProductVariantResponse$json,
  '.commerce.v1.CreateCartRequest': CreateCartRequest$json,
  '.commerce.v1.CreateCartResponse': CreateCartResponse$json,
  '.commerce.v1.Cart': Cart$json,
  '.commerce.v1.CartLine': CartLine$json,
  '.commerce.v1.GetCartRequest': GetCartRequest$json,
  '.commerce.v1.GetCartResponse': GetCartResponse$json,
  '.commerce.v1.AddCartLineRequest': AddCartLineRequest$json,
  '.commerce.v1.AddCartLineResponse': AddCartLineResponse$json,
  '.commerce.v1.RemoveCartLineRequest': RemoveCartLineRequest$json,
  '.commerce.v1.RemoveCartLineResponse': RemoveCartLineResponse$json,
  '.commerce.v1.CreateOrderFromCartRequest': CreateOrderFromCartRequest$json,
  '.commerce.v1.CreateOrderFromCartResponse': CreateOrderFromCartResponse$json,
  '.commerce.v1.Order': Order$json,
  '.commerce.v1.OrderLine': OrderLine$json,
  '.commerce.v1.CreateOrderRequest': CreateOrderRequest$json,
  '.commerce.v1.CreateOrderLine': CreateOrderLine$json,
  '.commerce.v1.CreateOrderResponse': CreateOrderResponse$json,
  '.commerce.v1.GetOrderRequest': GetOrderRequest$json,
  '.commerce.v1.GetOrderResponse': GetOrderResponse$json,
  '.commerce.v1.ListOrdersRequest': ListOrdersRequest$json,
  '.commerce.v1.ListOrdersResponse': ListOrdersResponse$json,
  '.commerce.v1.CreateFulfilmentRequest': CreateFulfilmentRequest$json,
  '.commerce.v1.FulfilmentLine': FulfilmentLine$json,
  '.commerce.v1.CreateFulfilmentResponse': CreateFulfilmentResponse$json,
  '.commerce.v1.Fulfilment': Fulfilment$json,
  '.commerce.v1.UpdateFulfilmentRequest': UpdateFulfilmentRequest$json,
  '.commerce.v1.UpdateFulfilmentResponse': UpdateFulfilmentResponse$json,
  '.commerce.v1.GetFulfilmentRequest': GetFulfilmentRequest$json,
  '.commerce.v1.GetFulfilmentResponse': GetFulfilmentResponse$json,
  '.commerce.v1.PriceListSaveRequest': PriceListSaveRequest$json,
  '.commerce.v1.PriceListSaveResponse': PriceListSaveResponse$json,
  '.commerce.v1.PriceList': PriceList$json,
  '.commerce.v1.PriceListGetRequest': PriceListGetRequest$json,
  '.commerce.v1.PriceListGetResponse': PriceListGetResponse$json,
  '.commerce.v1.PriceListSearchRequest': PriceListSearchRequest$json,
  '.commerce.v1.PriceListSearchResponse': PriceListSearchResponse$json,
  '.commerce.v1.PriceListEntryBatchSaveRequest': PriceListEntryBatchSaveRequest$json,
  '.commerce.v1.PriceListEntry': PriceListEntry$json,
  '.commerce.v1.PriceListEntryBatchSaveResponse': PriceListEntryBatchSaveResponse$json,
  '.commerce.v1.CustomerPriceListAssignmentSaveRequest': CustomerPriceListAssignmentSaveRequest$json,
  '.commerce.v1.CustomerPriceListAssignmentSaveResponse': CustomerPriceListAssignmentSaveResponse$json,
  '.commerce.v1.CustomerPriceListAssignment': CustomerPriceListAssignment$json,
  '.commerce.v1.CustomerPriceListAssignmentSearchRequest': CustomerPriceListAssignmentSearchRequest$json,
  '.commerce.v1.CustomerPriceListAssignmentSearchResponse': CustomerPriceListAssignmentSearchResponse$json,
  '.commerce.v1.CustomerPriceOverrideSaveRequest': CustomerPriceOverrideSaveRequest$json,
  '.commerce.v1.CustomerPriceOverrideSaveResponse': CustomerPriceOverrideSaveResponse$json,
  '.commerce.v1.CustomerPriceOverride': CustomerPriceOverride$json,
  '.commerce.v1.CustomerPriceOverrideSearchRequest': CustomerPriceOverrideSearchRequest$json,
  '.commerce.v1.CustomerPriceOverrideSearchResponse': CustomerPriceOverrideSearchResponse$json,
  '.commerce.v1.DiscountRuleSaveRequest': DiscountRuleSaveRequest$json,
  '.commerce.v1.DiscountRuleSaveResponse': DiscountRuleSaveResponse$json,
  '.commerce.v1.DiscountRule': DiscountRule$json,
  '.commerce.v1.DiscountRuleSearchRequest': DiscountRuleSearchRequest$json,
  '.commerce.v1.DiscountRuleSearchResponse': DiscountRuleSearchResponse$json,
  '.commerce.v1.ResolvePriceRequest': ResolvePriceRequest$json,
  '.commerce.v1.ResolvePriceResponse': ResolvePriceResponse$json,
  '.commerce.v1.ResolvedPrice': ResolvedPrice$json,
};

/// Descriptor for `CommerceService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List commerceServiceDescriptor = $convert.base64Decode(
    'Cg9Db21tZXJjZVNlcnZpY2USYAoKQ3JlYXRlU2hvcBIeLmNvbW1lcmNlLnYxLkNyZWF0ZVNob3'
    'BSZXF1ZXN0Gh8uY29tbWVyY2UudjEuQ3JlYXRlU2hvcFJlc3BvbnNlIhGCtRgNCgtzaG9wX2Ny'
    'ZWF0ZRJVCgdHZXRTaG9wEhsuY29tbWVyY2UudjEuR2V0U2hvcFJlcXVlc3QaHC5jb21tZXJjZS'
    '52MS5HZXRTaG9wUmVzcG9uc2UiD4K1GAsKCXNob3BfdmlldxJgCgpVcGRhdGVTaG9wEh4uY29t'
    'bWVyY2UudjEuVXBkYXRlU2hvcFJlcXVlc3QaHy5jb21tZXJjZS52MS5VcGRhdGVTaG9wUmVzcG'
    '9uc2UiEYK1GA0KC3Nob3BfdXBkYXRlEmwKDUNyZWF0ZVByb2R1Y3QSIS5jb21tZXJjZS52MS5D'
    'cmVhdGVQcm9kdWN0UmVxdWVzdBoiLmNvbW1lcmNlLnYxLkNyZWF0ZVByb2R1Y3RSZXNwb25zZS'
    'IUgrUYEAoOcHJvZHVjdF9tYW5hZ2USYQoKR2V0UHJvZHVjdBIeLmNvbW1lcmNlLnYxLkdldFBy'
    'b2R1Y3RSZXF1ZXN0Gh8uY29tbWVyY2UudjEuR2V0UHJvZHVjdFJlc3BvbnNlIhKCtRgOCgxwcm'
    '9kdWN0X3ZpZXcSZwoMTGlzdFByb2R1Y3RzEiAuY29tbWVyY2UudjEuTGlzdFByb2R1Y3RzUmVx'
    'dWVzdBohLmNvbW1lcmNlLnYxLkxpc3RQcm9kdWN0c1Jlc3BvbnNlIhKCtRgOCgxwcm9kdWN0X3'
    'ZpZXcSgQEKFENyZWF0ZVByb2R1Y3RWYXJpYW50EiguY29tbWVyY2UudjEuQ3JlYXRlUHJvZHVj'
    'dFZhcmlhbnRSZXF1ZXN0GikuY29tbWVyY2UudjEuQ3JlYXRlUHJvZHVjdFZhcmlhbnRSZXNwb2'
    '5zZSIUgrUYEAoOcHJvZHVjdF9tYW5hZ2USgQEKFFVwZGF0ZVByb2R1Y3RWYXJpYW50EiguY29t'
    'bWVyY2UudjEuVXBkYXRlUHJvZHVjdFZhcmlhbnRSZXF1ZXN0GikuY29tbWVyY2UudjEuVXBkYX'
    'RlUHJvZHVjdFZhcmlhbnRSZXNwb25zZSIUgrUYEAoOcHJvZHVjdF9tYW5hZ2USYAoKQ3JlYXRl'
    'Q2FydBIeLmNvbW1lcmNlLnYxLkNyZWF0ZUNhcnRSZXF1ZXN0Gh8uY29tbWVyY2UudjEuQ3JlYX'
    'RlQ2FydFJlc3BvbnNlIhGCtRgNCgtjYXJ0X21hbmFnZRJVCgdHZXRDYXJ0EhsuY29tbWVyY2Uu'
    'djEuR2V0Q2FydFJlcXVlc3QaHC5jb21tZXJjZS52MS5HZXRDYXJ0UmVzcG9uc2UiD4K1GAsKCW'
    'NhcnRfdmlldxJjCgtBZGRDYXJ0TGluZRIfLmNvbW1lcmNlLnYxLkFkZENhcnRMaW5lUmVxdWVz'
    'dBogLmNvbW1lcmNlLnYxLkFkZENhcnRMaW5lUmVzcG9uc2UiEYK1GA0KC2NhcnRfbWFuYWdlEm'
    'wKDlJlbW92ZUNhcnRMaW5lEiIuY29tbWVyY2UudjEuUmVtb3ZlQ2FydExpbmVSZXF1ZXN0GiMu'
    'Y29tbWVyY2UudjEuUmVtb3ZlQ2FydExpbmVSZXNwb25zZSIRgrUYDQoLY2FydF9tYW5hZ2USfA'
    'oTQ3JlYXRlT3JkZXJGcm9tQ2FydBInLmNvbW1lcmNlLnYxLkNyZWF0ZU9yZGVyRnJvbUNhcnRS'
    'ZXF1ZXN0GiguY29tbWVyY2UudjEuQ3JlYXRlT3JkZXJGcm9tQ2FydFJlc3BvbnNlIhKCtRgOCg'
    'xvcmRlcl9tYW5hZ2USZAoLQ3JlYXRlT3JkZXISHy5jb21tZXJjZS52MS5DcmVhdGVPcmRlclJl'
    'cXVlc3QaIC5jb21tZXJjZS52MS5DcmVhdGVPcmRlclJlc3BvbnNlIhKCtRgOCgxvcmRlcl9tYW'
    '5hZ2USWQoIR2V0T3JkZXISHC5jb21tZXJjZS52MS5HZXRPcmRlclJlcXVlc3QaHS5jb21tZXJj'
    'ZS52MS5HZXRPcmRlclJlc3BvbnNlIhCCtRgMCgpvcmRlcl92aWV3El8KCkxpc3RPcmRlcnMSHi'
    '5jb21tZXJjZS52MS5MaXN0T3JkZXJzUmVxdWVzdBofLmNvbW1lcmNlLnYxLkxpc3RPcmRlcnNS'
    'ZXNwb25zZSIQgrUYDAoKb3JkZXJfdmlldxJ4ChBDcmVhdGVGdWxmaWxtZW50EiQuY29tbWVyY2'
    'UudjEuQ3JlYXRlRnVsZmlsbWVudFJlcXVlc3QaJS5jb21tZXJjZS52MS5DcmVhdGVGdWxmaWxt'
    'ZW50UmVzcG9uc2UiF4K1GBMKEWZ1bGZpbG1lbnRfbWFuYWdlEngKEFVwZGF0ZUZ1bGZpbG1lbn'
    'QSJC5jb21tZXJjZS52MS5VcGRhdGVGdWxmaWxtZW50UmVxdWVzdBolLmNvbW1lcmNlLnYxLlVw'
    'ZGF0ZUZ1bGZpbG1lbnRSZXNwb25zZSIXgrUYEwoRZnVsZmlsbWVudF9tYW5hZ2USbQoNR2V0Rn'
    'VsZmlsbWVudBIhLmNvbW1lcmNlLnYxLkdldEZ1bGZpbG1lbnRSZXF1ZXN0GiIuY29tbWVyY2Uu'
    'djEuR2V0RnVsZmlsbWVudFJlc3BvbnNlIhWCtRgRCg9mdWxmaWxtZW50X3ZpZXcSbwoNUHJpY2'
    'VMaXN0U2F2ZRIhLmNvbW1lcmNlLnYxLlByaWNlTGlzdFNhdmVSZXF1ZXN0GiIuY29tbWVyY2Uu'
    'djEuUHJpY2VMaXN0U2F2ZVJlc3BvbnNlIheCtRgTChFwcmljZV9saXN0X21hbmFnZRJqCgxQcm'
    'ljZUxpc3RHZXQSIC5jb21tZXJjZS52MS5QcmljZUxpc3RHZXRSZXF1ZXN0GiEuY29tbWVyY2Uu'
    'djEuUHJpY2VMaXN0R2V0UmVzcG9uc2UiFYK1GBEKD3ByaWNlX2xpc3RfdmlldxJzCg9QcmljZU'
    'xpc3RTZWFyY2gSIy5jb21tZXJjZS52MS5QcmljZUxpc3RTZWFyY2hSZXF1ZXN0GiQuY29tbWVy'
    'Y2UudjEuUHJpY2VMaXN0U2VhcmNoUmVzcG9uc2UiFYK1GBEKD3ByaWNlX2xpc3RfdmlldxKNAQ'
    'oXUHJpY2VMaXN0RW50cnlCYXRjaFNhdmUSKy5jb21tZXJjZS52MS5QcmljZUxpc3RFbnRyeUJh'
    'dGNoU2F2ZVJlcXVlc3QaLC5jb21tZXJjZS52MS5QcmljZUxpc3RFbnRyeUJhdGNoU2F2ZVJlc3'
    'BvbnNlIheCtRgTChFwcmljZV9saXN0X21hbmFnZRKrAQofQ3VzdG9tZXJQcmljZUxpc3RBc3Np'
    'Z25tZW50U2F2ZRIzLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFNhdm'
    'VSZXF1ZXN0GjQuY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZUxpc3RBc3NpZ25tZW50U2F2ZVJl'
    'c3BvbnNlIh2CtRgZChdjdXN0b21lcl9wcmljZV9vdmVycmlkZRKpAQohQ3VzdG9tZXJQcmljZU'
    'xpc3RBc3NpZ25tZW50U2VhcmNoEjUuY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZUxpc3RBc3Np'
    'Z25tZW50U2VhcmNoUmVxdWVzdBo2LmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaW'
    'dubWVudFNlYXJjaFJlc3BvbnNlIhWCtRgRCg9wcmljZV9saXN0X3ZpZXcSmQEKGUN1c3RvbWVy'
    'UHJpY2VPdmVycmlkZVNhdmUSLS5jb21tZXJjZS52MS5DdXN0b21lclByaWNlT3ZlcnJpZGVTYX'
    'ZlUmVxdWVzdBouLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VPdmVycmlkZVNhdmVSZXNwb25z'
    'ZSIdgrUYGQoXY3VzdG9tZXJfcHJpY2Vfb3ZlcnJpZGUSlwEKG0N1c3RvbWVyUHJpY2VPdmVycm'
    'lkZVNlYXJjaBIvLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VPdmVycmlkZVNlYXJjaFJlcXVl'
    'c3QaMC5jb21tZXJjZS52MS5DdXN0b21lclByaWNlT3ZlcnJpZGVTZWFyY2hSZXNwb25zZSIVgr'
    'UYEQoPcHJpY2VfbGlzdF92aWV3EnYKEERpc2NvdW50UnVsZVNhdmUSJC5jb21tZXJjZS52MS5E'
    'aXNjb3VudFJ1bGVTYXZlUmVxdWVzdBolLmNvbW1lcmNlLnYxLkRpc2NvdW50UnVsZVNhdmVSZX'
    'Nwb25zZSIVgrUYEQoPZGlzY291bnRfbWFuYWdlEnwKEkRpc2NvdW50UnVsZVNlYXJjaBImLmNv'
    'bW1lcmNlLnYxLkRpc2NvdW50UnVsZVNlYXJjaFJlcXVlc3QaJy5jb21tZXJjZS52MS5EaXNjb3'
    'VudFJ1bGVTZWFyY2hSZXNwb25zZSIVgrUYEQoPcHJpY2VfbGlzdF92aWV3EmoKDFJlc29sdmVQ'
    'cmljZRIgLmNvbW1lcmNlLnYxLlJlc29sdmVQcmljZVJlcXVlc3QaIS5jb21tZXJjZS52MS5SZX'
    'NvbHZlUHJpY2VSZXNwb25zZSIVgrUYEQoPcHJpY2VfbGlzdF92aWV3Gr4KgrUYuQoKEHNlcnZp'
    'Y2VfY29tbWVyY2USCXNob3BfdmlldxILc2hvcF9jcmVhdGUSC3Nob3BfdXBkYXRlEgxwcm9kdW'
    'N0X3ZpZXcSDnByb2R1Y3RfbWFuYWdlEgljYXJ0X3ZpZXcSC2NhcnRfbWFuYWdlEgpvcmRlcl92'
    'aWV3EgxvcmRlcl9tYW5hZ2USD2Z1bGZpbG1lbnRfdmlldxIRZnVsZmlsbWVudF9tYW5hZ2USD3'
    'ByaWNlX2xpc3RfdmlldxIRcHJpY2VfbGlzdF9tYW5hZ2USF2N1c3RvbWVyX3ByaWNlX292ZXJy'
    'aWRlEg9kaXNjb3VudF9tYW5hZ2USEGRpc2NvdW50X2FwcHJvdmUa+wEIARIJc2hvcF92aWV3Eg'
    'tzaG9wX2NyZWF0ZRILc2hvcF91cGRhdGUSDHByb2R1Y3RfdmlldxIOcHJvZHVjdF9tYW5hZ2US'
    'CWNhcnRfdmlldxILY2FydF9tYW5hZ2USCm9yZGVyX3ZpZXcSDG9yZGVyX21hbmFnZRIPZnVsZm'
    'lsbWVudF92aWV3EhFmdWxmaWxtZW50X21hbmFnZRIPcHJpY2VfbGlzdF92aWV3EhFwcmljZV9s'
    'aXN0X21hbmFnZRIXY3VzdG9tZXJfcHJpY2Vfb3ZlcnJpZGUSD2Rpc2NvdW50X21hbmFnZRIQZG'
    'lzY291bnRfYXBwcm92ZRr7AQgCEglzaG9wX3ZpZXcSC3Nob3BfY3JlYXRlEgtzaG9wX3VwZGF0'
    'ZRIMcHJvZHVjdF92aWV3Eg5wcm9kdWN0X21hbmFnZRIJY2FydF92aWV3EgtjYXJ0X21hbmFnZR'
    'IKb3JkZXJfdmlldxIMb3JkZXJfbWFuYWdlEg9mdWxmaWxtZW50X3ZpZXcSEWZ1bGZpbG1lbnRf'
    'bWFuYWdlEg9wcmljZV9saXN0X3ZpZXcSEXByaWNlX2xpc3RfbWFuYWdlEhdjdXN0b21lcl9wcm'
    'ljZV9vdmVycmlkZRIPZGlzY291bnRfbWFuYWdlEhBkaXNjb3VudF9hcHByb3ZlGpYBCAMSCXNo'
    'b3BfdmlldxIMcHJvZHVjdF92aWV3Eg5wcm9kdWN0X21hbmFnZRIJY2FydF92aWV3EgpvcmRlcl'
    '92aWV3EgxvcmRlcl9tYW5hZ2USD2Z1bGZpbG1lbnRfdmlldxIRZnVsZmlsbWVudF9tYW5hZ2US'
    'D3ByaWNlX2xpc3RfdmlldxIPZGlzY291bnRfbWFuYWdlGlQIBBIJc2hvcF92aWV3Egxwcm9kdW'
    'N0X3ZpZXcSCWNhcnRfdmlldxIKb3JkZXJfdmlldxIPZnVsZmlsbWVudF92aWV3Eg9wcmljZV9s'
    'aXN0X3ZpZXcaQwgFEglzaG9wX3ZpZXcSDHByb2R1Y3RfdmlldxIJY2FydF92aWV3EgpvcmRlcl'
    '92aWV3Eg9wcmljZV9saXN0X3ZpZXca+wEIBhIJc2hvcF92aWV3EgtzaG9wX2NyZWF0ZRILc2hv'
    'cF91cGRhdGUSDHByb2R1Y3RfdmlldxIOcHJvZHVjdF9tYW5hZ2USCWNhcnRfdmlldxILY2FydF'
    '9tYW5hZ2USCm9yZGVyX3ZpZXcSDG9yZGVyX21hbmFnZRIPZnVsZmlsbWVudF92aWV3EhFmdWxm'
    'aWxtZW50X21hbmFnZRIPcHJpY2VfbGlzdF92aWV3EhFwcmljZV9saXN0X21hbmFnZRIXY3VzdG'
    '9tZXJfcHJpY2Vfb3ZlcnJpZGUSD2Rpc2NvdW50X21hbmFnZRIQZGlzY291bnRfYXBwcm92ZQ==');

