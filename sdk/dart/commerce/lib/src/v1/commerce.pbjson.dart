// This is a generated file - do not edit.
//
// Generated from v1/commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/field_mask.pbjson.dart'
    as $2;
import 'package:protobuf/well_known_types/google/protobuf/struct.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

import '../common/v1/common.pbjson.dart' as $3;
import '../common/v1/money.pbjson.dart' as $4;

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

@$core.Deprecated('Use currencySourceDescriptor instead')
const CurrencySource$json = {
  '1': 'CurrencySource',
  '2': [
    {'1': 'CURRENCY_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'CURRENCY_SOURCE_PREFERENCE', '2': 1},
    {'1': 'CURRENCY_SOURCE_DEVICE', '2': 2},
    {'1': 'CURRENCY_SOURCE_ADDRESS', '2': 3},
    {'1': 'CURRENCY_SOURCE_PLATFORM_DEFAULT', '2': 4},
  ],
};

/// Descriptor for `CurrencySource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List currencySourceDescriptor = $convert.base64Decode(
    'Cg5DdXJyZW5jeVNvdXJjZRIfChtDVVJSRU5DWV9TT1VSQ0VfVU5TUEVDSUZJRUQQABIeChpDVV'
    'JSRU5DWV9TT1VSQ0VfUFJFRkVSRU5DRRABEhoKFkNVUlJFTkNZX1NPVVJDRV9ERVZJQ0UQAhIb'
    'ChdDVVJSRU5DWV9TT1VSQ0VfQUREUkVTUxADEiQKIENVUlJFTkNZX1NPVVJDRV9QTEFURk9STV'
    '9ERUZBVUxUEAQ=');

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

@$core.Deprecated('Use orderRefundStatusDescriptor instead')
const OrderRefundStatus$json = {
  '1': 'OrderRefundStatus',
  '2': [
    {'1': 'ORDER_REFUND_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_REFUND_STATUS_PENDING', '2': 1},
    {'1': 'ORDER_REFUND_STATUS_SENT', '2': 2},
    {'1': 'ORDER_REFUND_STATUS_CONFIRMED', '2': 3},
    {'1': 'ORDER_REFUND_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `OrderRefundStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderRefundStatusDescriptor = $convert.base64Decode(
    'ChFPcmRlclJlZnVuZFN0YXR1cxIjCh9PUkRFUl9SRUZVTkRfU1RBVFVTX1VOU1BFQ0lGSUVEEA'
    'ASHwobT1JERVJfUkVGVU5EX1NUQVRVU19QRU5ESU5HEAESHAoYT1JERVJfUkVGVU5EX1NUQVRV'
    'U19TRU5UEAISIQodT1JERVJfUkVGVU5EX1NUQVRVU19DT05GSVJNRUQQAxIeChpPUkRFUl9SRU'
    'ZVTkRfU1RBVFVTX0ZBSUxFRBAE');

@$core.Deprecated('Use orderRefundResolutionDescriptor instead')
const OrderRefundResolution$json = {
  '1': 'OrderRefundResolution',
  '2': [
    {'1': 'ORDER_REFUND_RESOLUTION_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_REFUND_RESOLUTION_RETRY', '2': 1},
    {'1': 'ORDER_REFUND_RESOLUTION_PAID_BACK', '2': 2},
  ],
};

/// Descriptor for `OrderRefundResolution`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderRefundResolutionDescriptor = $convert.base64Decode(
    'ChVPcmRlclJlZnVuZFJlc29sdXRpb24SJwojT1JERVJfUkVGVU5EX1JFU09MVVRJT05fVU5TUE'
    'VDSUZJRUQQABIhCh1PUkRFUl9SRUZVTkRfUkVTT0xVVElPTl9SRVRSWRABEiUKIU9SREVSX1JF'
    'RlVORF9SRVNPTFVUSU9OX1BBSURfQkFDSxAC');

@$core.Deprecated('Use orderPaymentSourceDescriptor instead')
const OrderPaymentSource$json = {
  '1': 'OrderPaymentSource',
  '2': [
    {'1': 'ORDER_PAYMENT_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_PAYMENT_SOURCE_CHECKOUT', '2': 1},
    {'1': 'ORDER_PAYMENT_SOURCE_RECORDED', '2': 2},
  ],
};

/// Descriptor for `OrderPaymentSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderPaymentSourceDescriptor = $convert.base64Decode(
    'ChJPcmRlclBheW1lbnRTb3VyY2USJAogT1JERVJfUEFZTUVOVF9TT1VSQ0VfVU5TUEVDSUZJRU'
    'QQABIhCh1PUkRFUl9QQVlNRU5UX1NPVVJDRV9DSEVDS09VVBABEiEKHU9SREVSX1BBWU1FTlRf'
    'U09VUkNFX1JFQ09SREVEEAI=');

@$core.Deprecated('Use orderStatusDescriptor instead')
const OrderStatus$json = {
  '1': 'OrderStatus',
  '2': [
    {'1': 'ORDER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_STATUS_CONFIRMED', '2': 1},
    {'1': 'ORDER_STATUS_CANCELLED', '2': 2},
    {'1': 'ORDER_STATUS_FULFILLED', '2': 3},
    {'1': 'ORDER_STATUS_PENDING_PAYMENT', '2': 4},
  ],
};

/// Descriptor for `OrderStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderStatusDescriptor = $convert.base64Decode(
    'CgtPcmRlclN0YXR1cxIcChhPUkRFUl9TVEFUVVNfVU5TUEVDSUZJRUQQABIaChZPUkRFUl9TVE'
    'FUVVNfQ09ORklSTUVEEAESGgoWT1JERVJfU1RBVFVTX0NBTkNFTExFRBACEhoKFk9SREVSX1NU'
    'QVRVU19GVUxGSUxMRUQQAxIgChxPUkRFUl9TVEFUVVNfUEVORElOR19QQVlNRU5UEAQ=');

@$core.Deprecated('Use paymentStatusDescriptor instead')
const PaymentStatus$json = {
  '1': 'PaymentStatus',
  '2': [
    {'1': 'PAYMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PAYMENT_STATUS_PENDING', '2': 1},
    {'1': 'PAYMENT_STATUS_PAID', '2': 2},
    {'1': 'PAYMENT_STATUS_FAILED', '2': 3},
    {'1': 'PAYMENT_STATUS_REFUNDED', '2': 4},
    {'1': 'PAYMENT_STATUS_EXPIRED', '2': 5},
    {'1': 'PAYMENT_STATUS_PARTIALLY_PAID', '2': 6},
    {'1': 'PAYMENT_STATUS_REFUND_PENDING', '2': 7},
  ],
};

/// Descriptor for `PaymentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List paymentStatusDescriptor = $convert.base64Decode(
    'Cg1QYXltZW50U3RhdHVzEh4KGlBBWU1FTlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGgoWUEFZTU'
    'VOVF9TVEFUVVNfUEVORElORxABEhcKE1BBWU1FTlRfU1RBVFVTX1BBSUQQAhIZChVQQVlNRU5U'
    'X1NUQVRVU19GQUlMRUQQAxIbChdQQVlNRU5UX1NUQVRVU19SRUZVTkRFRBAEEhoKFlBBWU1FTl'
    'RfU1RBVFVTX0VYUElSRUQQBRIhCh1QQVlNRU5UX1NUQVRVU19QQVJUSUFMTFlfUEFJRBAGEiEK'
    'HVBBWU1FTlRfU1RBVFVTX1JFRlVORF9QRU5ESU5HEAc=');

@$core.Deprecated('Use orderEventTypeDescriptor instead')
const OrderEventType$json = {
  '1': 'OrderEventType',
  '2': [
    {'1': 'ORDER_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_EVENT_TYPE_PAYMENT_RECEIVED', '2': 1},
    {'1': 'ORDER_EVENT_TYPE_DEPOSIT_PAID', '2': 2},
    {'1': 'ORDER_EVENT_TYPE_THRESHOLD_CROSSED', '2': 3},
    {'1': 'ORDER_EVENT_TYPE_FULFILMENT_RELEASED', '2': 4},
    {'1': 'ORDER_EVENT_TYPE_FULLY_PAID', '2': 5},
    {'1': 'ORDER_EVENT_TYPE_BALANCE_OVERDUE', '2': 6},
    {'1': 'ORDER_EVENT_TYPE_OVERPAID', '2': 7},
    {'1': 'ORDER_EVENT_TYPE_CANCELLED', '2': 8},
    {'1': 'ORDER_EVENT_TYPE_EXPIRED', '2': 9},
    {'1': 'ORDER_EVENT_TYPE_REFUNDED', '2': 10},
  ],
};

/// Descriptor for `OrderEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderEventTypeDescriptor = $convert.base64Decode(
    'Cg5PcmRlckV2ZW50VHlwZRIgChxPUkRFUl9FVkVOVF9UWVBFX1VOU1BFQ0lGSUVEEAASJQohT1'
    'JERVJfRVZFTlRfVFlQRV9QQVlNRU5UX1JFQ0VJVkVEEAESIQodT1JERVJfRVZFTlRfVFlQRV9E'
    'RVBPU0lUX1BBSUQQAhImCiJPUkRFUl9FVkVOVF9UWVBFX1RIUkVTSE9MRF9DUk9TU0VEEAMSKA'
    'okT1JERVJfRVZFTlRfVFlQRV9GVUxGSUxNRU5UX1JFTEVBU0VEEAQSHwobT1JERVJfRVZFTlRf'
    'VFlQRV9GVUxMWV9QQUlEEAUSJAogT1JERVJfRVZFTlRfVFlQRV9CQUxBTkNFX09WRVJEVUUQBh'
    'IdChlPUkRFUl9FVkVOVF9UWVBFX09WRVJQQUlEEAcSHgoaT1JERVJfRVZFTlRfVFlQRV9DQU5D'
    'RUxMRUQQCBIcChhPUkRFUl9FVkVOVF9UWVBFX0VYUElSRUQQCRIdChlPUkRFUl9FVkVOVF9UWV'
    'BFX1JFRlVOREVEEAo=');

@$core.Deprecated('Use orderEventDeliveryDescriptor instead')
const OrderEventDelivery$json = {
  '1': 'OrderEventDelivery',
  '2': [
    {'1': 'ORDER_EVENT_DELIVERY_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_EVENT_DELIVERY_NOT_REQUIRED', '2': 1},
    {'1': 'ORDER_EVENT_DELIVERY_PENDING', '2': 2},
    {'1': 'ORDER_EVENT_DELIVERY_DELIVERED', '2': 3},
    {'1': 'ORDER_EVENT_DELIVERY_FAILED', '2': 4},
  ],
};

/// Descriptor for `OrderEventDelivery`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderEventDeliveryDescriptor = $convert.base64Decode(
    'ChJPcmRlckV2ZW50RGVsaXZlcnkSJAogT1JERVJfRVZFTlRfREVMSVZFUllfVU5TUEVDSUZJRU'
    'QQABIlCiFPUkRFUl9FVkVOVF9ERUxJVkVSWV9OT1RfUkVRVUlSRUQQARIgChxPUkRFUl9FVkVO'
    'VF9ERUxJVkVSWV9QRU5ESU5HEAISIgoeT1JERVJfRVZFTlRfREVMSVZFUllfREVMSVZFUkVEEA'
    'MSHwobT1JERVJfRVZFTlRfREVMSVZFUllfRkFJTEVEEAQ=');

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
final $typed_data.Uint8List customerPriceListAssignmentStatusDescriptor =
    $convert.base64Decode(
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
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ShopStatus',
      '10': 'status'
    },
    {'1': 'media_ids', '3': 6, '4': 3, '5': 9, '10': 'mediaIds'},
    {'1': 'currency', '3': 7, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'contact_id', '3': 8, '4': 1, '5': 9, '10': 'contactId'},
    {
      '1': 'checkout_return_url',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'checkoutReturnUrl'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'extra',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'extra'
    },
    {
      '1': 'payment_policy',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
    {'1': 'webhook_url', '3': 17, '4': 1, '5': 9, '10': 'webhookUrl'},
    {
      '1': 'webhook_secret_set',
      '3': 18,
      '4': 1,
      '5': 8,
      '10': 'webhookSecretSet'
    },
    {
      '1': 'public_storefront',
      '3': 19,
      '4': 1,
      '5': 8,
      '10': 'publicStorefront'
    },
    {'1': 'storefront_url', '3': 20, '4': 1, '5': 9, '10': 'storefrontUrl'},
  ],
};

/// Descriptor for `Shop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shopDescriptor = $convert.base64Decode(
    'CgRTaG9wEisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SAmlkEhIKBG'
    '5hbWUYAiABKAlSBG5hbWUSEgoEc2x1ZxgDIAEoCVIEc2x1ZxIgCgtkZXNjcmlwdGlvbhgEIAEo'
    'CVILZGVzY3JpcHRpb24SLwoGc3RhdHVzGAUgASgOMhcuY29tbWVyY2UudjEuU2hvcFN0YXR1c1'
    'IGc3RhdHVzEhsKCW1lZGlhX2lkcxgGIAMoCVIIbWVkaWFJZHMSGgoIY3VycmVuY3kYByABKAlS'
    'CGN1cnJlbmN5Eh0KCmNvbnRhY3RfaWQYCCABKAlSCWNvbnRhY3RJZBIuChNjaGVja291dF9yZX'
    'R1cm5fdXJsGAkgASgJUhFjaGVja291dFJldHVyblVybBI5CgpjcmVhdGVkX2F0GAogASgLMhou'
    'Z29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0Ei0KBWV4dHJhGA8gASgLMhcuZ2'
    '9vZ2xlLnByb3RvYnVmLlN0cnVjdFIFZXh0cmESQQoOcGF5bWVudF9wb2xpY3kYECABKAsyGi5j'
    'b21tZXJjZS52MS5QYXltZW50UG9saWN5Ug1wYXltZW50UG9saWN5Eh8KC3dlYmhvb2tfdXJsGB'
    'EgASgJUgp3ZWJob29rVXJsEiwKEndlYmhvb2tfc2VjcmV0X3NldBgSIAEoCFIQd2ViaG9va1Nl'
    'Y3JldFNldBIrChFwdWJsaWNfc3RvcmVmcm9udBgTIAEoCFIQcHVibGljU3RvcmVmcm9udBIlCg'
    '5zdG9yZWZyb250X3VybBgUIAEoCVINc3RvcmVmcm9udFVybA==');

@$core.Deprecated('Use paymentPolicyDescriptor instead')
const PaymentPolicy$json = {
  '1': 'PaymentPolicy',
  '2': [
    {
      '1': 'allow_instalments',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'allowInstalments'
    },
    {
      '1': 'min_deposit_percent',
      '3': 2,
      '4': 1,
      '5': 5,
      '8': {},
      '10': 'minDepositPercent'
    },
    {
      '1': 'min_instalment_percent',
      '3': 3,
      '4': 1,
      '5': 5,
      '8': {},
      '10': 'minInstalmentPercent'
    },
    {
      '1': 'balance_due_days',
      '3': 4,
      '4': 1,
      '5': 5,
      '8': {},
      '10': 'balanceDueDays'
    },
    {
      '1': 'fulfil_at_percent',
      '3': 5,
      '4': 1,
      '5': 5,
      '8': {},
      '10': 'fulfilAtPercent'
    },
    {
      '1': 'signal_thresholds',
      '3': 6,
      '4': 3,
      '5': 5,
      '8': {},
      '10': 'signalThresholds'
    },
    {
      '1': 'cancel_when_overdue',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'cancelWhenOverdue'
    },
  ],
};

/// Descriptor for `PaymentPolicy`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentPolicyDescriptor = $convert.base64Decode(
    'Cg1QYXltZW50UG9saWN5EisKEWFsbG93X2luc3RhbG1lbnRzGAEgASgIUhBhbGxvd0luc3RhbG'
    '1lbnRzEjkKE21pbl9kZXBvc2l0X3BlcmNlbnQYAiABKAVCCbpIBhoEGGQoAFIRbWluRGVwb3Np'
    'dFBlcmNlbnQSPwoWbWluX2luc3RhbG1lbnRfcGVyY2VudBgDIAEoBUIJukgGGgQYZCgAUhRtaW'
    '5JbnN0YWxtZW50UGVyY2VudBI0ChBiYWxhbmNlX2R1ZV9kYXlzGAQgASgFQgq6SAcaBRjCHCgA'
    'Ug5iYWxhbmNlRHVlRGF5cxI1ChFmdWxmaWxfYXRfcGVyY2VudBgFIAEoBUIJukgGGgQYZCgAUg'
    '9mdWxmaWxBdFBlcmNlbnQSOwoRc2lnbmFsX3RocmVzaG9sZHMYBiADKAVCDrpIC5IBCCIGGgQY'
    'ZCAAUhBzaWduYWxUaHJlc2hvbGRzEi4KE2NhbmNlbF93aGVuX292ZXJkdWUYByABKAhSEWNhbm'
    'NlbFdoZW5PdmVyZHVl');

@$core.Deprecated('Use createShopRequestDescriptor instead')
const CreateShopRequest$json = {
  '1': 'CreateShopRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 2, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'contact_id', '3': 5, '4': 1, '5': 9, '10': 'contactId'},
    {'1': 'media_ids', '3': 6, '4': 3, '5': 9, '10': 'mediaIds'},
    {
      '1': 'checkout_return_url',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'checkoutReturnUrl'
    },
    {
      '1': 'payment_policy',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
    {'1': 'webhook_url', '3': 9, '4': 1, '5': 9, '10': 'webhookUrl'},
    {'1': 'webhook_secret', '3': 10, '4': 1, '5': 9, '10': 'webhookSecret'},
    {
      '1': 'public_storefront',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'publicStorefront'
    },
  ],
};

/// Descriptor for `CreateShopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createShopRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVTaG9wUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHNsdWcYAiABKAlSBH'
    'NsdWcSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhoKCGN1cnJlbmN5GAQgASgJ'
    'UghjdXJyZW5jeRIdCgpjb250YWN0X2lkGAUgASgJUgljb250YWN0SWQSGwoJbWVkaWFfaWRzGA'
    'YgAygJUghtZWRpYUlkcxIuChNjaGVja291dF9yZXR1cm5fdXJsGAcgASgJUhFjaGVja291dFJl'
    'dHVyblVybBJBCg5wYXltZW50X3BvbGljeRgIIAEoCzIaLmNvbW1lcmNlLnYxLlBheW1lbnRQb2'
    'xpY3lSDXBheW1lbnRQb2xpY3kSHwoLd2ViaG9va191cmwYCSABKAlSCndlYmhvb2tVcmwSJQoO'
    'd2ViaG9va19zZWNyZXQYCiABKAlSDXdlYmhvb2tTZWNyZXQSKwoRcHVibGljX3N0b3JlZnJvbn'
    'QYCyABKAhSEHB1YmxpY1N0b3JlZnJvbnQ=');

@$core.Deprecated('Use createShopResponseDescriptor instead')
const CreateShopResponse$json = {
  '1': 'CreateShopResponse',
  '2': [
    {
      '1': 'shop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Shop',
      '10': 'shop'
    },
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
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'media_ids', '3': 5, '4': 3, '5': 9, '10': 'mediaIds'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ShopStatus',
      '10': 'status'
    },
    {
      '1': 'extra',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'extra'
    },
    {'1': 'currency', '3': 8, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'contact_id', '3': 9, '4': 1, '5': 9, '10': 'contactId'},
    {
      '1': 'checkout_return_url',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'checkoutReturnUrl'
    },
    {
      '1': 'payment_policy',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
    {'1': 'webhook_url', '3': 12, '4': 1, '5': 9, '10': 'webhookUrl'},
    {'1': 'webhook_secret', '3': 13, '4': 1, '5': 9, '10': 'webhookSecret'},
    {
      '1': 'public_storefront',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'publicStorefront'
    },
  ],
};

/// Descriptor for `UpdateShopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateShopRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVTaG9wUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZBI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1h'
    'c2tSCnVwZGF0ZU1hc2sSEgoEbmFtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCV'
    'ILZGVzY3JpcHRpb24SGwoJbWVkaWFfaWRzGAUgAygJUghtZWRpYUlkcxIvCgZzdGF0dXMYBiAB'
    'KA4yFy5jb21tZXJjZS52MS5TaG9wU3RhdHVzUgZzdGF0dXMSLQoFZXh0cmEYByABKAsyFy5nb2'
    '9nbGUucHJvdG9idWYuU3RydWN0UgVleHRyYRIaCghjdXJyZW5jeRgIIAEoCVIIY3VycmVuY3kS'
    'HQoKY29udGFjdF9pZBgJIAEoCVIJY29udGFjdElkEi4KE2NoZWNrb3V0X3JldHVybl91cmwYCi'
    'ABKAlSEWNoZWNrb3V0UmV0dXJuVXJsEkEKDnBheW1lbnRfcG9saWN5GAsgASgLMhouY29tbWVy'
    'Y2UudjEuUGF5bWVudFBvbGljeVINcGF5bWVudFBvbGljeRIfCgt3ZWJob29rX3VybBgMIAEoCV'
    'IKd2ViaG9va1VybBIlCg53ZWJob29rX3NlY3JldBgNIAEoCVINd2ViaG9va1NlY3JldBIrChFw'
    'dWJsaWNfc3RvcmVmcm9udBgOIAEoCFIQcHVibGljU3RvcmVmcm9udA==');

@$core.Deprecated('Use updateShopResponseDescriptor instead')
const UpdateShopResponse$json = {
  '1': 'UpdateShopResponse',
  '2': [
    {
      '1': 'shop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Shop',
      '10': 'shop'
    },
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

@$core.Deprecated('Use listShopsRequestDescriptor instead')
const ListShopsRequest$json = {
  '1': 'ListShopsRequest',
  '2': [
    {
      '1': 'search',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
  ],
};

/// Descriptor for `ListShopsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listShopsRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0U2hvcHNSZXF1ZXN0EjAKBnNlYXJjaBgBIAEoCzIYLmNvbW1vbi52MS5TZWFyY2hSZX'
    'F1ZXN0UgZzZWFyY2g=');

@$core.Deprecated('Use listShopsResponseDescriptor instead')
const ListShopsResponse$json = {
  '1': 'ListShopsResponse',
  '2': [
    {
      '1': 'shops',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.Shop',
      '10': 'shops'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `ListShopsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listShopsResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0U2hvcHNSZXNwb25zZRInCgVzaG9wcxgBIAMoCzIRLmNvbW1lcmNlLnYxLlNob3BSBX'
    'Nob3BzEhsKCW5leHRfcGFnZRgCIAEoCVIIbmV4dFBhZ2U=');

@$core.Deprecated('Use getShopResponseDescriptor instead')
const GetShopResponse$json = {
  '1': 'GetShopResponse',
  '2': [
    {
      '1': 'shop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Shop',
      '10': 'shop'
    },
  ],
};

/// Descriptor for `GetShopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShopResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRTaG9wUmVzcG9uc2USJQoEc2hvcBgBIAEoCzIRLmNvbW1lcmNlLnYxLlNob3BSBHNob3'
    'A=');

@$core.Deprecated('Use resolveDefaultCurrencyRequestDescriptor instead')
const ResolveDefaultCurrencyRequest$json = {
  '1': 'ResolveDefaultCurrencyRequest',
};

/// Descriptor for `ResolveDefaultCurrencyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveDefaultCurrencyRequestDescriptor =
    $convert.base64Decode('Ch1SZXNvbHZlRGVmYXVsdEN1cnJlbmN5UmVxdWVzdA==');

@$core.Deprecated('Use resolveDefaultCurrencyResponseDescriptor instead')
const ResolveDefaultCurrencyResponse$json = {
  '1': 'ResolveDefaultCurrencyResponse',
  '2': [
    {'1': 'currency', '3': 1, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'source',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CurrencySource',
      '10': 'source'
    },
  ],
};

/// Descriptor for `ResolveDefaultCurrencyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveDefaultCurrencyResponseDescriptor =
    $convert.base64Decode(
        'Ch5SZXNvbHZlRGVmYXVsdEN1cnJlbmN5UmVzcG9uc2USGgoIY3VycmVuY3kYASABKAlSCGN1cn'
        'JlbmN5EjMKBnNvdXJjZRgCIAEoDjIbLmNvbW1lcmNlLnYxLkN1cnJlbmN5U291cmNlUgZzb3Vy'
        'Y2U=');

@$core.Deprecated('Use productDescriptor instead')
const Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'attributes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.Product.AttributesEntry',
      '10': 'attributes'
    },
    {
      '1': 'fulfilment_type',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentType',
      '10': 'fulfilmentType'
    },
    {
      '1': 'status',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ProductStatus',
      '10': 'status'
    },
    {'1': 'media_ids', '3': 16, '4': 3, '5': 9, '10': 'mediaIds'},
    {
      '1': 'created_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'payment_policy',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
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
    'JlYXRlZF9hdBgRIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBJB'
    'Cg5wYXltZW50X3BvbGljeRgSIAEoCzIaLmNvbW1lcmNlLnYxLlBheW1lbnRQb2xpY3lSDXBheW'
    '1lbnRQb2xpY3kaPQoPQXR0cmlidXRlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVl'
    'GAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use productVariantDescriptor instead')
const ProductVariant$json = {
  '1': 'ProductVariant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'sku', '3': 3, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'price',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'price'
    },
    {'1': 'stock_quantity', '3': 7, '4': 1, '5': 3, '10': 'stockQuantity'},
    {
      '1': 'attributes',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.ProductVariant.AttributesEntry',
      '10': 'attributes'
    },
    {'1': 'media_ids', '3': 10, '4': 3, '5': 9, '10': 'mediaIds'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ProductVariantStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
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
    {
      '1': 'attributes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CreateProductRequest.AttributesEntry',
      '10': 'attributes'
    },
    {
      '1': 'fulfilment_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentType',
      '10': 'fulfilmentType'
    },
    {
      '1': 'payment_policy',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
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
    'dGVzRW50cnlSCmF0dHJpYnV0ZXMSRAoPZnVsZmlsbWVudF90eXBlGAYgASgOMhsuY29tbWVyY2'
    'UudjEuRnVsZmlsbWVudFR5cGVSDmZ1bGZpbG1lbnRUeXBlEkEKDnBheW1lbnRfcG9saWN5GAcg'
    'ASgLMhouY29tbWVyY2UudjEuUGF5bWVudFBvbGljeVINcGF5bWVudFBvbGljeRo9Cg9BdHRyaW'
    'J1dGVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use createProductResponseDescriptor instead')
const CreateProductResponse$json = {
  '1': 'CreateProductResponse',
  '2': [
    {
      '1': 'product',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Product',
      '10': 'product'
    },
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
    {
      '1': 'product',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Product',
      '10': 'product'
    },
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
    {
      '1': 'search',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
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
    {
      '1': 'products',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.Product',
      '10': 'products'
    },
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
    {
      '1': 'price',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'price'
    },
    {'1': 'stock_quantity', '3': 6, '4': 1, '5': 3, '10': 'stockQuantity'},
    {
      '1': 'attributes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CreateProductVariantRequest.AttributesEntry',
      '10': 'attributes'
    },
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
    {
      '1': 'product_variant',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.ProductVariant',
      '10': 'productVariant'
    },
  ],
};

/// Descriptor for `CreateProductVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProductVariantResponseDescriptor =
    $convert.base64Decode(
        'ChxDcmVhdGVQcm9kdWN0VmFyaWFudFJlc3BvbnNlEkQKD3Byb2R1Y3RfdmFyaWFudBgBIAEoCz'
        'IbLmNvbW1lcmNlLnYxLlByb2R1Y3RWYXJpYW50Ug5wcm9kdWN0VmFyaWFudA==');

@$core.Deprecated('Use updateProductVariantRequestDescriptor instead')
const UpdateProductVariantRequest$json = {
  '1': 'UpdateProductVariantRequest',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '10': 'variantId'},
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
    {'1': 'sku', '3': 3, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'price',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'price'
    },
    {'1': 'stock_quantity', '3': 7, '4': 1, '5': 3, '10': 'stockQuantity'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ProductVariantStatus',
      '10': 'status'
    },
    {
      '1': 'attributes',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.UpdateProductVariantRequest.AttributesEntry',
      '10': 'attributes'
    },
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

@$core.Deprecated('Use updateProductRequestDescriptor instead')
const UpdateProductRequest$json = {
  '1': 'UpdateProductRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'attributes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.UpdateProductRequest.AttributesEntry',
      '10': 'attributes'
    },
    {
      '1': 'fulfilment_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentType',
      '10': 'fulfilmentType'
    },
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.ProductStatus',
      '10': 'status'
    },
    {'1': 'media_ids', '3': 8, '4': 3, '5': 9, '10': 'mediaIds'},
    {
      '1': 'payment_policy',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
  ],
  '3': [UpdateProductRequest_AttributesEntry$json],
};

@$core.Deprecated('Use updateProductRequestDescriptor instead')
const UpdateProductRequest_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UpdateProductRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProductRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9kdWN0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZBI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVs'
    'ZE1hc2tSCnVwZGF0ZU1hc2sSEgoEbmFtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIA'
    'EoCVILZGVzY3JpcHRpb24SUQoKYXR0cmlidXRlcxgFIAMoCzIxLmNvbW1lcmNlLnYxLlVwZGF0'
    'ZVByb2R1Y3RSZXF1ZXN0LkF0dHJpYnV0ZXNFbnRyeVIKYXR0cmlidXRlcxJECg9mdWxmaWxtZW'
    '50X3R5cGUYBiABKA4yGy5jb21tZXJjZS52MS5GdWxmaWxtZW50VHlwZVIOZnVsZmlsbWVudFR5'
    'cGUSMgoGc3RhdHVzGAcgASgOMhouY29tbWVyY2UudjEuUHJvZHVjdFN0YXR1c1IGc3RhdHVzEh'
    'sKCW1lZGlhX2lkcxgIIAMoCVIIbWVkaWFJZHMSQQoOcGF5bWVudF9wb2xpY3kYCSABKAsyGi5j'
    'b21tZXJjZS52MS5QYXltZW50UG9saWN5Ug1wYXltZW50UG9saWN5Gj0KD0F0dHJpYnV0ZXNFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use updateProductResponseDescriptor instead')
const UpdateProductResponse$json = {
  '1': 'UpdateProductResponse',
  '2': [
    {
      '1': 'product',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Product',
      '10': 'product'
    },
  ],
};

/// Descriptor for `UpdateProductResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProductResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVQcm9kdWN0UmVzcG9uc2USLgoHcHJvZHVjdBgBIAEoCzIULmNvbW1lcmNlLnYxLl'
    'Byb2R1Y3RSB3Byb2R1Y3Q=');

@$core.Deprecated('Use listProductVariantsRequestDescriptor instead')
const ListProductVariantsRequest$json = {
  '1': 'ListProductVariantsRequest',
  '2': [
    {'1': 'product_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'productId'},
  ],
};

/// Descriptor for `ListProductVariantsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProductVariantsRequestDescriptor =
    $convert.base64Decode(
        'ChpMaXN0UHJvZHVjdFZhcmlhbnRzUmVxdWVzdBI6Cgpwcm9kdWN0X2lkGAEgASgJQhu6SBhyFh'
        'ADGCgyEFswLTlhLXpfLV17Myw0MH1SCXByb2R1Y3RJZA==');

@$core.Deprecated('Use listProductVariantsResponseDescriptor instead')
const ListProductVariantsResponse$json = {
  '1': 'ListProductVariantsResponse',
  '2': [
    {
      '1': 'product_variants',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.ProductVariant',
      '10': 'productVariants'
    },
  ],
};

/// Descriptor for `ListProductVariantsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProductVariantsResponseDescriptor =
    $convert.base64Decode(
        'ChtMaXN0UHJvZHVjdFZhcmlhbnRzUmVzcG9uc2USRgoQcHJvZHVjdF92YXJpYW50cxgBIAMoCz'
        'IbLmNvbW1lcmNlLnYxLlByb2R1Y3RWYXJpYW50Ug9wcm9kdWN0VmFyaWFudHM=');

@$core.Deprecated('Use receiveStockRequestDescriptor instead')
const ReceiveStockRequest$json = {
  '1': 'ReceiveStockRequest',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '10': 'variantId'},
    {'1': 'quantity', '3': 2, '4': 1, '5': 3, '10': 'quantity'},
    {'1': 'reference', '3': 3, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'tenant_id', '3': 4, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `ReceiveStockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveStockRequestDescriptor = $convert.base64Decode(
    'ChNSZWNlaXZlU3RvY2tSZXF1ZXN0Eh0KCnZhcmlhbnRfaWQYASABKAlSCXZhcmlhbnRJZBIaCg'
    'hxdWFudGl0eRgCIAEoA1IIcXVhbnRpdHkSHAoJcmVmZXJlbmNlGAMgASgJUglyZWZlcmVuY2US'
    'GwoJdGVuYW50X2lkGAQgASgJUgh0ZW5hbnRJZA==');

@$core.Deprecated('Use receiveStockResponseDescriptor instead')
const ReceiveStockResponse$json = {
  '1': 'ReceiveStockResponse',
  '2': [
    {'1': 'stock_quantity', '3': 1, '4': 1, '5': 3, '10': 'stockQuantity'},
    {'1': 'replayed', '3': 2, '4': 1, '5': 8, '10': 'replayed'},
  ],
};

/// Descriptor for `ReceiveStockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveStockResponseDescriptor = $convert.base64Decode(
    'ChRSZWNlaXZlU3RvY2tSZXNwb25zZRIlCg5zdG9ja19xdWFudGl0eRgBIAEoA1INc3RvY2tRdW'
    'FudGl0eRIaCghyZXBsYXllZBgCIAEoCFIIcmVwbGF5ZWQ=');

@$core.Deprecated('Use updateProductVariantResponseDescriptor instead')
const UpdateProductVariantResponse$json = {
  '1': 'UpdateProductVariantResponse',
  '2': [
    {
      '1': 'product_variant',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.ProductVariant',
      '10': 'productVariant'
    },
  ],
};

/// Descriptor for `UpdateProductVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProductVariantResponseDescriptor =
    $convert.base64Decode(
        'ChxVcGRhdGVQcm9kdWN0VmFyaWFudFJlc3BvbnNlEkQKD3Byb2R1Y3RfdmFyaWFudBgBIAEoCz'
        'IbLmNvbW1lcmNlLnYxLlByb2R1Y3RWYXJpYW50Ug5wcm9kdWN0VmFyaWFudA==');

@$core.Deprecated('Use cartDescriptor instead')
const Cart$json = {
  '1': 'Cart',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '10': 'shopId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CartStatus',
      '10': 'status'
    },
    {'1': 'profile_id', '3': 4, '4': 1, '5': 9, '10': 'profileId'},
    {'1': 'contact_id', '3': 5, '4': 1, '5': 9, '10': 'contactId'},
    {
      '1': 'lines',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CartLine',
      '10': 'lines'
    },
    {
      '1': 'expires_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {
      '1': 'created_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
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
    {
      '1': 'product_variant_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
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
    {
      '1': 'cart',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Cart',
      '10': 'cart'
    },
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
    {
      '1': 'cart',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Cart',
      '10': 'cart'
    },
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
    {
      '1': 'product_variant_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'productVariantId'
    },
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
    {
      '1': 'cart',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Cart',
      '10': 'cart'
    },
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
    {
      '1': 'cart',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Cart',
      '10': 'cart'
    },
  ],
};

/// Descriptor for `RemoveCartLineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeCartLineResponseDescriptor =
    $convert.base64Decode(
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
    'gyEFswLTlhLXpfLV17Myw0MH1SBmNhcnRJZBI9Cgpwcm9maWxlX2lkGAUgASgJQh66SBvYAQFy'
    'FhADGCgyEFswLTlhLXpfLV17Myw0MH1SCXByb2ZpbGVJZBI9Cgpjb250YWN0X2lkGAYgASgJQh'
    '66SBvYAQFyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SCWNvbnRhY3RJZBI9CgphZGRyZXNzX2lk'
    'GAcgASgJQh66SBvYAQFyFhADGCgyEFswLTlhLXpfLV17Myw0MH1SCWFkZHJlc3NJZA==');

@$core.Deprecated('Use createOrderFromCartResponseDescriptor instead')
const CreateOrderFromCartResponse$json = {
  '1': 'CreateOrderFromCartResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `CreateOrderFromCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderFromCartResponseDescriptor =
    $convert.base64Decode(
        'ChtDcmVhdGVPcmRlckZyb21DYXJ0UmVzcG9uc2USKAoFb3JkZXIYASABKAsyEi5jb21tZXJjZS'
        '52MS5PcmRlclIFb3JkZXI=');

@$core.Deprecated('Use orderDescriptor instead')
const Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'order_number', '3': 3, '4': 1, '5': 9, '10': 'orderNumber'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderStatus',
      '10': 'status'
    },
    {
      '1': 'payment_status',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.PaymentStatus',
      '10': 'paymentStatus'
    },
    {
      '1': 'fulfilment_status',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentStatus',
      '10': 'fulfilmentStatus'
    },
    {'1': 'profile_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'contact_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'contactId'},
    {'1': 'address_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'addressId'},
    {
      '1': 'subtotal',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'subtotal'
    },
    {
      '1': 'total',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'total'
    },
    {
      '1': 'lines',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.OrderLine',
      '10': 'lines'
    },
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'payment_session_ref',
      '3': 12,
      '4': 1,
      '5': 9,
      '10': 'paymentSessionRef'
    },
    {'1': 'checkout_url', '3': 13, '4': 1, '5': 9, '10': 'checkoutUrl'},
    {'1': 'payment_id', '3': 14, '4': 1, '5': 9, '10': 'paymentId'},
    {
      '1': 'paid_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'paidAt'
    },
    {
      '1': 'cancelled_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'cancelledAt'
    },
    {'1': 'cancel_reason', '3': 19, '4': 1, '5': 9, '10': 'cancelReason'},
    {
      '1': 'ledger_transaction_id',
      '3': 20,
      '4': 1,
      '5': 9,
      '10': 'ledgerTransactionId'
    },
    {
      '1': 'amount_paid',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amountPaid'
    },
    {
      '1': 'balance',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'balance'
    },
    {
      '1': 'balance_due_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'balanceDueAt'
    },
    {
      '1': 'payment_policy',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PaymentPolicy',
      '10': 'paymentPolicy'
    },
    {
      '1': 'payments',
      '3': 25,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.OrderPayment',
      '10': 'payments'
    },
    {
      '1': 'payment_due_at',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'paymentDueAt'
    },
    {
      '1': 'amount_refunded',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amountRefunded'
    },
    {'1': 'payment_review', '3': 28, '4': 1, '5': 9, '10': 'paymentReview'},
    {
      '1': 'refunds',
      '3': 29,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.OrderRefund',
      '10': 'refunds'
    },
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
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0Ei4KE3BheW1lbnRfc2Vzc2'
    'lvbl9yZWYYDCABKAlSEXBheW1lbnRTZXNzaW9uUmVmEiEKDGNoZWNrb3V0X3VybBgNIAEoCVIL'
    'Y2hlY2tvdXRVcmwSHQoKcGF5bWVudF9pZBgOIAEoCVIJcGF5bWVudElkEjMKB3BhaWRfYXQYES'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgZwYWlkQXQSPQoMY2FuY2VsbGVkX2F0'
    'GBIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILY2FuY2VsbGVkQXQSIwoNY2FuY2'
    'VsX3JlYXNvbhgTIAEoCVIMY2FuY2VsUmVhc29uEjIKFWxlZGdlcl90cmFuc2FjdGlvbl9pZBgU'
    'IAEoCVITbGVkZ2VyVHJhbnNhY3Rpb25JZBIxCgthbW91bnRfcGFpZBgVIAEoCzIQLmNvbW1vbi'
    '52MS5Nb25leVIKYW1vdW50UGFpZBIqCgdiYWxhbmNlGBYgASgLMhAuY29tbW9uLnYxLk1vbmV5'
    'UgdiYWxhbmNlEkAKDmJhbGFuY2VfZHVlX2F0GBcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIMYmFsYW5jZUR1ZUF0EkEKDnBheW1lbnRfcG9saWN5GBggASgLMhouY29tbWVyY2Uu'
    'djEuUGF5bWVudFBvbGljeVINcGF5bWVudFBvbGljeRI1CghwYXltZW50cxgZIAMoCzIZLmNvbW'
    '1lcmNlLnYxLk9yZGVyUGF5bWVudFIIcGF5bWVudHMSQAoOcGF5bWVudF9kdWVfYXQYGiABKAsy'
    'Gi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgxwYXltZW50RHVlQXQSOQoPYW1vdW50X3JlZn'
    'VuZGVkGBsgASgLMhAuY29tbW9uLnYxLk1vbmV5Ug5hbW91bnRSZWZ1bmRlZBIlCg5wYXltZW50'
    'X3JldmlldxgcIAEoCVINcGF5bWVudFJldmlldxIyCgdyZWZ1bmRzGB0gAygLMhguY29tbWVyY2'
    'UudjEuT3JkZXJSZWZ1bmRSB3JlZnVuZHM=');

@$core.Deprecated('Use orderRefundDescriptor instead')
const OrderRefund$json = {
  '1': 'OrderRefund',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderRefundStatus',
      '10': 'status'
    },
    {'1': 'last_error', '3': 4, '4': 1, '5': 9, '10': 'lastError'},
    {
      '1': 'confirmed_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'confirmedAt'
    },
    {'1': 'resolved_by', '3': 6, '4': 1, '5': 9, '10': 'resolvedBy'},
    {'1': 'note', '3': 7, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `OrderRefund`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderRefundDescriptor = $convert.base64Decode(
    'CgtPcmRlclJlZnVuZBIOCgJpZBgBIAEoCVICaWQSKAoGYW1vdW50GAIgASgLMhAuY29tbW9uLn'
    'YxLk1vbmV5UgZhbW91bnQSNgoGc3RhdHVzGAMgASgOMh4uY29tbWVyY2UudjEuT3JkZXJSZWZ1'
    'bmRTdGF0dXNSBnN0YXR1cxIdCgpsYXN0X2Vycm9yGAQgASgJUglsYXN0RXJyb3ISPQoMY29uZm'
    'lybWVkX2F0GAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILY29uZmlybWVkQXQS'
    'HwoLcmVzb2x2ZWRfYnkYBiABKAlSCnJlc29sdmVkQnkSEgoEbm90ZRgHIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use orderPaymentDescriptor instead')
const OrderPayment$json = {
  '1': 'OrderPayment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {
      '1': 'source',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderPaymentSource',
      '10': 'source'
    },
    {'1': 'reference', '3': 4, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'payment_id', '3': 5, '4': 1, '5': 9, '10': 'paymentId'},
    {
      '1': 'paid_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'paidAt'
    },
    {'1': 'recorded_by', '3': 7, '4': 1, '5': 9, '10': 'recordedBy'},
    {'1': 'note', '3': 8, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `OrderPayment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderPaymentDescriptor = $convert.base64Decode(
    'CgxPcmRlclBheW1lbnQSDgoCaWQYASABKAlSAmlkEigKBmFtb3VudBgCIAEoCzIQLmNvbW1vbi'
    '52MS5Nb25leVIGYW1vdW50EjcKBnNvdXJjZRgDIAEoDjIfLmNvbW1lcmNlLnYxLk9yZGVyUGF5'
    'bWVudFNvdXJjZVIGc291cmNlEhwKCXJlZmVyZW5jZRgEIAEoCVIJcmVmZXJlbmNlEh0KCnBheW'
    '1lbnRfaWQYBSABKAlSCXBheW1lbnRJZBIzCgdwYWlkX2F0GAYgASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIGcGFpZEF0Eh8KC3JlY29yZGVkX2J5GAcgASgJUgpyZWNvcmRlZEJ5Eh'
    'IKBG5vdGUYCCABKAlSBG5vdGU=');

@$core.Deprecated('Use orderLineDescriptor instead')
const OrderLine$json = {
  '1': 'OrderLine',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {
      '1': 'product_variant_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
    {'1': 'sku_snapshot', '3': 3, '4': 1, '5': 9, '10': 'skuSnapshot'},
    {'1': 'name_snapshot', '3': 4, '4': 1, '5': 9, '10': 'nameSnapshot'},
    {
      '1': 'unit_price',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unitPrice'
    },
    {'1': 'quantity', '3': 6, '4': 1, '5': 3, '10': 'quantity'},
    {
      '1': 'total_price',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'totalPrice'
    },
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
    {
      '1': 'lines',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CreateOrderLine',
      '10': 'lines'
    },
  ],
};

/// Descriptor for `CreateOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createOrderRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVPcmRlclJlcXVlc3QSJwoPaWRlbXBvdGVuY3lfa2V5GAIgASgJUg5pZGVtcG90ZW'
    '5jeUtleRIXCgdzaG9wX2lkGAEgASgJUgZzaG9wSWQSPQoKcHJvZmlsZV9pZBgFIAEoCUIeukgb'
    '2AEBchYQAxgoMhBbMC05YS16Xy1dezMsNDB9Uglwcm9maWxlSWQSPQoKY29udGFjdF9pZBgGIA'
    'EoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy1dezMsNDB9Ugljb250YWN0SWQSPQoKYWRkcmVz'
    'c19pZBgHIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UglhZGRyZXNzSWQSMg'
    'oFbGluZXMYCiADKAsyHC5jb21tZXJjZS52MS5DcmVhdGVPcmRlckxpbmVSBWxpbmVz');

@$core.Deprecated('Use createOrderResponseDescriptor instead')
const CreateOrderResponse$json = {
  '1': 'CreateOrderResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
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
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
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
    {
      '1': 'search',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
    {'1': 'profile_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {
      '1': 'statuses',
      '3': 4,
      '4': 3,
      '5': 14,
      '6': '.commerce.v1.OrderStatus',
      '8': {},
      '10': 'statuses'
    },
    {
      '1': 'payment_statuses',
      '3': 5,
      '4': 3,
      '5': 14,
      '6': '.commerce.v1.PaymentStatus',
      '8': {},
      '10': 'paymentStatuses'
    },
  ],
};

/// Descriptor for `ListOrdersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0T3JkZXJzUmVxdWVzdBI0CgdzaG9wX2lkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SBnNob3BJZBIwCgZzZWFyY2gYAiABKAsyGC5jb21tb24udjEuU2VhcmNoUmVx'
    'dWVzdFIGc2VhcmNoEiYKCnByb2ZpbGVfaWQYAyABKAlCB7pIBHICGChSCXByb2ZpbGVJZBJFCg'
    'hzdGF0dXNlcxgEIAMoDjIYLmNvbW1lcmNlLnYxLk9yZGVyU3RhdHVzQg+6SAySAQkQCiIFggEC'
    'EAFSCHN0YXR1c2VzElYKEHBheW1lbnRfc3RhdHVzZXMYBSADKA4yGi5jb21tZXJjZS52MS5QYX'
    'ltZW50U3RhdHVzQg+6SAySAQkQCiIFggECEAFSD3BheW1lbnRTdGF0dXNlcw==');

@$core.Deprecated('Use listOrdersResponseDescriptor instead')
const ListOrdersResponse$json = {
  '1': 'ListOrdersResponse',
  '2': [
    {
      '1': 'orders',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'orders'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `ListOrdersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0T3JkZXJzUmVzcG9uc2USKgoGb3JkZXJzGAEgAygLMhIuY29tbWVyY2UudjEuT3JkZX'
    'JSBm9yZGVycxIbCgluZXh0X3BhZ2UYAiABKAlSCG5leHRQYWdlEh8KC3ByZXZfY3Vyc29yGAMg'
    'ASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use checkoutOrderRequestDescriptor instead')
const CheckoutOrderRequest$json = {
  '1': 'CheckoutOrderRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {'1': 'return_url', '3': 2, '4': 1, '5': 9, '10': 'returnUrl'},
    {'1': 'methods', '3': 3, '4': 3, '5': 9, '10': 'methods'},
    {
      '1': 'amount',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
  ],
};

/// Descriptor for `CheckoutOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkoutOrderRequestDescriptor = $convert.base64Decode(
    'ChRDaGVja291dE9yZGVyUmVxdWVzdBI2CghvcmRlcl9pZBgBIAEoCUIbukgYchYQAxgoMhBbMC'
    '05YS16Xy1dezMsNDB9UgdvcmRlcklkEh0KCnJldHVybl91cmwYAiABKAlSCXJldHVyblVybBIY'
    'CgdtZXRob2RzGAMgAygJUgdtZXRob2RzEigKBmFtb3VudBgEIAEoCzIQLmNvbW1vbi52MS5Nb2'
    '5leVIGYW1vdW50');

@$core.Deprecated('Use checkoutOrderResponseDescriptor instead')
const CheckoutOrderResponse$json = {
  '1': 'CheckoutOrderResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
    {'1': 'checkout_url', '3': 2, '4': 1, '5': 9, '10': 'checkoutUrl'},
    {'1': 'session_ref', '3': 3, '4': 1, '5': 9, '10': 'sessionRef'},
    {
      '1': 'amount',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
  ],
};

/// Descriptor for `CheckoutOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkoutOrderResponseDescriptor = $convert.base64Decode(
    'ChVDaGVja291dE9yZGVyUmVzcG9uc2USKAoFb3JkZXIYASABKAsyEi5jb21tZXJjZS52MS5Pcm'
    'RlclIFb3JkZXISIQoMY2hlY2tvdXRfdXJsGAIgASgJUgtjaGVja291dFVybBIfCgtzZXNzaW9u'
    'X3JlZhgDIAEoCVIKc2Vzc2lvblJlZhIoCgZhbW91bnQYBCABKAsyEC5jb21tb24udjEuTW9uZX'
    'lSBmFtb3VudA==');

@$core.Deprecated('Use confirmOrderPaymentRequestDescriptor instead')
const ConfirmOrderPaymentRequest$json = {
  '1': 'ConfirmOrderPaymentRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
  ],
};

/// Descriptor for `ConfirmOrderPaymentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmOrderPaymentRequestDescriptor =
    $convert.base64Decode(
        'ChpDb25maXJtT3JkZXJQYXltZW50UmVxdWVzdBI2CghvcmRlcl9pZBgBIAEoCUIbukgYchYQAx'
        'goMhBbMC05YS16Xy1dezMsNDB9UgdvcmRlcklk');

@$core.Deprecated('Use confirmOrderPaymentResponseDescriptor instead')
const ConfirmOrderPaymentResponse$json = {
  '1': 'ConfirmOrderPaymentResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `ConfirmOrderPaymentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmOrderPaymentResponseDescriptor =
    $convert.base64Decode(
        'ChtDb25maXJtT3JkZXJQYXltZW50UmVzcG9uc2USKAoFb3JkZXIYASABKAsyEi5jb21tZXJjZS'
        '52MS5PcmRlclIFb3JkZXI=');

@$core.Deprecated('Use cancelOrderRequestDescriptor instead')
const CancelOrderRequest$json = {
  '1': 'CancelOrderRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `CancelOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelOrderRequestDescriptor = $convert.base64Decode(
    'ChJDYW5jZWxPcmRlclJlcXVlc3QSNgoIb3JkZXJfaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVIHb3JkZXJJZBIWCgZyZWFzb24YAiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use cancelOrderResponseDescriptor instead')
const CancelOrderResponse$json = {
  '1': 'CancelOrderResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `CancelOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelOrderResponseDescriptor = $convert.base64Decode(
    'ChNDYW5jZWxPcmRlclJlc3BvbnNlEigKBW9yZGVyGAEgASgLMhIuY29tbWVyY2UudjEuT3JkZX'
    'JSBW9yZGVy');

@$core.Deprecated('Use recordOrderPaymentRequestDescriptor instead')
const RecordOrderPaymentRequest$json = {
  '1': 'RecordOrderPaymentRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'amount'
    },
    {'1': 'reference', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'reference'},
    {'1': 'note', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'note'},
  ],
};

/// Descriptor for `RecordOrderPaymentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordOrderPaymentRequestDescriptor = $convert.base64Decode(
    'ChlSZWNvcmRPcmRlclBheW1lbnRSZXF1ZXN0EjYKCG9yZGVyX2lkGAEgASgJQhu6SBhyFhADGC'
    'gyEFswLTlhLXpfLV17Myw0MH1SB29yZGVySWQSMAoGYW1vdW50GAIgASgLMhAuY29tbW9uLnYx'
    'Lk1vbmV5Qga6SAPIAQFSBmFtb3VudBInCglyZWZlcmVuY2UYAyABKAlCCbpIBnIEEAEYZFIJcm'
    'VmZXJlbmNlEhwKBG5vdGUYBCABKAlCCLpIBXIDGPQDUgRub3Rl');

@$core.Deprecated('Use recordOrderPaymentResponseDescriptor instead')
const RecordOrderPaymentResponse$json = {
  '1': 'RecordOrderPaymentResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `RecordOrderPaymentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordOrderPaymentResponseDescriptor =
    $convert.base64Decode(
        'ChpSZWNvcmRPcmRlclBheW1lbnRSZXNwb25zZRIoCgVvcmRlchgBIAEoCzISLmNvbW1lcmNlLn'
        'YxLk9yZGVyUgVvcmRlcg==');

@$core.Deprecated('Use resolveOrderRefundRequestDescriptor instead')
const ResolveOrderRefundRequest$json = {
  '1': 'ResolveOrderRefundRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {'1': 'refund_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'refundId'},
    {
      '1': 'resolution',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderRefundResolution',
      '8': {},
      '10': 'resolution'
    },
    {'1': 'note', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'note'},
  ],
};

/// Descriptor for `ResolveOrderRefundRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveOrderRefundRequestDescriptor = $convert.base64Decode(
    'ChlSZXNvbHZlT3JkZXJSZWZ1bmRSZXF1ZXN0EjYKCG9yZGVyX2lkGAEgASgJQhu6SBhyFhADGC'
    'gyEFswLTlhLXpfLV17Myw0MH1SB29yZGVySWQSJgoJcmVmdW5kX2lkGAIgASgJQgm6SAZyBBAD'
    'GChSCHJlZnVuZElkEk4KCnJlc29sdXRpb24YAyABKA4yIi5jb21tZXJjZS52MS5PcmRlclJlZn'
    'VuZFJlc29sdXRpb25CCrpIB4IBBBABIABSCnJlc29sdXRpb24SHAoEbm90ZRgEIAEoCUIIukgF'
    'cgMY9ANSBG5vdGU=');

@$core.Deprecated('Use resolveOrderRefundResponseDescriptor instead')
const ResolveOrderRefundResponse$json = {
  '1': 'ResolveOrderRefundResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `ResolveOrderRefundResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveOrderRefundResponseDescriptor =
    $convert.base64Decode(
        'ChpSZXNvbHZlT3JkZXJSZWZ1bmRSZXNwb25zZRIoCgVvcmRlchgBIAEoCzISLmNvbW1lcmNlLn'
        'YxLk9yZGVyUgVvcmRlcg==');

@$core.Deprecated('Use orderEventDescriptor instead')
const OrderEvent$json = {
  '1': 'OrderEvent',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'order_id', '3': 3, '4': 1, '5': 9, '10': 'orderId'},
    {'1': 'order_number', '3': 4, '4': 1, '5': 9, '10': 'orderNumber'},
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderEventType',
      '10': 'type'
    },
    {
      '1': 'threshold_percent',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'thresholdPercent'
    },
    {'1': 'paid_percent', '3': 7, '4': 1, '5': 5, '10': 'paidPercent'},
    {
      '1': 'amount_paid',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amountPaid'
    },
    {
      '1': 'balance',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'balance'
    },
    {
      '1': 'payment_amount',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'paymentAmount'
    },
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'delivery',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.OrderEventDelivery',
      '10': 'delivery'
    },
  ],
};

/// Descriptor for `OrderEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderEventDescriptor = $convert.base64Decode(
    'CgpPcmRlckV2ZW50Eg4KAmlkGAEgASgJUgJpZBIXCgdzaG9wX2lkGAIgASgJUgZzaG9wSWQSGQ'
    'oIb3JkZXJfaWQYAyABKAlSB29yZGVySWQSIQoMb3JkZXJfbnVtYmVyGAQgASgJUgtvcmRlck51'
    'bWJlchIvCgR0eXBlGAUgASgOMhsuY29tbWVyY2UudjEuT3JkZXJFdmVudFR5cGVSBHR5cGUSKw'
    'oRdGhyZXNob2xkX3BlcmNlbnQYBiABKAVSEHRocmVzaG9sZFBlcmNlbnQSIQoMcGFpZF9wZXJj'
    'ZW50GAcgASgFUgtwYWlkUGVyY2VudBIxCgthbW91bnRfcGFpZBgIIAEoCzIQLmNvbW1vbi52MS'
    '5Nb25leVIKYW1vdW50UGFpZBIqCgdiYWxhbmNlGAkgASgLMhAuY29tbW9uLnYxLk1vbmV5Ugdi'
    'YWxhbmNlEjcKDnBheW1lbnRfYW1vdW50GAogASgLMhAuY29tbW9uLnYxLk1vbmV5Ug1wYXltZW'
    '50QW1vdW50EjkKCmNyZWF0ZWRfYXQYCyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1w'
    'UgljcmVhdGVkQXQSOwoIZGVsaXZlcnkYDCABKA4yHy5jb21tZXJjZS52MS5PcmRlckV2ZW50RG'
    'VsaXZlcnlSCGRlbGl2ZXJ5');

@$core.Deprecated('Use listOrderEventsRequestDescriptor instead')
const ListOrderEventsRequest$json = {
  '1': 'ListOrderEventsRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'order_id', '3': 2, '4': 1, '5': 9, '10': 'orderId'},
    {
      '1': 'search',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
  ],
};

/// Descriptor for `ListOrderEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrderEventsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0T3JkZXJFdmVudHNSZXF1ZXN0EhcKB3Nob3BfaWQYASABKAlSBnNob3BJZBIZCghvcm'
    'Rlcl9pZBgCIAEoCVIHb3JkZXJJZBIwCgZzZWFyY2gYAyABKAsyGC5jb21tb24udjEuU2VhcmNo'
    'UmVxdWVzdFIGc2VhcmNo');

@$core.Deprecated('Use listOrderEventsResponseDescriptor instead')
const ListOrderEventsResponse$json = {
  '1': 'ListOrderEventsResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.OrderEvent',
      '10': 'events'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
  ],
};

/// Descriptor for `ListOrderEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrderEventsResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0T3JkZXJFdmVudHNSZXNwb25zZRIvCgZldmVudHMYASADKAsyFy5jb21tZXJjZS52MS'
        '5PcmRlckV2ZW50UgZldmVudHMSGwoJbmV4dF9wYWdlGAIgASgJUghuZXh0UGFnZQ==');

@$core.Deprecated('Use reconcilePaymentsRequestDescriptor instead')
const ReconcilePaymentsRequest$json = {
  '1': 'ReconcilePaymentsRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `ReconcilePaymentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconcilePaymentsRequestDescriptor =
    $convert.base64Decode(
        'ChhSZWNvbmNpbGVQYXltZW50c1JlcXVlc3QSFwoHc2hvcF9pZBgBIAEoCVIGc2hvcElkEhQKBW'
        'xpbWl0GAIgASgFUgVsaW1pdA==');

@$core.Deprecated('Use reconcilePaymentsResponseDescriptor instead')
const ReconcilePaymentsResponse$json = {
  '1': 'ReconcilePaymentsResponse',
  '2': [
    {'1': 'examined', '3': 1, '4': 1, '5': 5, '10': 'examined'},
    {'1': 'paid', '3': 2, '4': 1, '5': 5, '10': 'paid'},
    {'1': 'expired', '3': 3, '4': 1, '5': 5, '10': 'expired'},
    {'1': 'failed', '3': 4, '4': 1, '5': 5, '10': 'failed'},
    {'1': 'overdue', '3': 5, '4': 1, '5': 5, '10': 'overdue'},
    {'1': 'events_delivered', '3': 6, '4': 1, '5': 5, '10': 'eventsDelivered'},
    {'1': 'refunds_sent', '3': 7, '4': 1, '5': 5, '10': 'refundsSent'},
    {
      '1': 'refunds_confirmed',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'refundsConfirmed'
    },
  ],
};

/// Descriptor for `ReconcilePaymentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconcilePaymentsResponseDescriptor = $convert.base64Decode(
    'ChlSZWNvbmNpbGVQYXltZW50c1Jlc3BvbnNlEhoKCGV4YW1pbmVkGAEgASgFUghleGFtaW5lZB'
    'ISCgRwYWlkGAIgASgFUgRwYWlkEhgKB2V4cGlyZWQYAyABKAVSB2V4cGlyZWQSFgoGZmFpbGVk'
    'GAQgASgFUgZmYWlsZWQSGAoHb3ZlcmR1ZRgFIAEoBVIHb3ZlcmR1ZRIpChBldmVudHNfZGVsaX'
    'ZlcmVkGAYgASgFUg9ldmVudHNEZWxpdmVyZWQSIQoMcmVmdW5kc19zZW50GAcgASgFUgtyZWZ1'
    'bmRzU2VudBIrChFyZWZ1bmRzX2NvbmZpcm1lZBgIIAEoBVIQcmVmdW5kc0NvbmZpcm1lZA==');

@$core.Deprecated('Use runEndOfDayLedgerRequestDescriptor instead')
const RunEndOfDayLedgerRequest$json = {
  '1': 'RunEndOfDayLedgerRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'date', '3': 2, '4': 1, '5': 9, '10': 'date'},
  ],
};

/// Descriptor for `RunEndOfDayLedgerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runEndOfDayLedgerRequestDescriptor =
    $convert.base64Decode(
        'ChhSdW5FbmRPZkRheUxlZGdlclJlcXVlc3QSFwoHc2hvcF9pZBgBIAEoCVIGc2hvcElkEhIKBG'
        'RhdGUYAiABKAlSBGRhdGU=');

@$core.Deprecated('Use ledgerPostingDescriptor instead')
const LedgerPosting$json = {
  '1': 'LedgerPosting',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '10': 'shopId'},
    {'1': 'date', '3': 2, '4': 1, '5': 9, '10': 'date'},
    {'1': 'transaction_id', '3': 3, '4': 1, '5': 9, '10': 'transactionId'},
    {
      '1': 'sales',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'sales'
    },
    {
      '1': 'refunds',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'refunds'
    },
    {'1': 'orders', '3': 6, '4': 1, '5': 5, '10': 'orders'},
    {'1': 'skipped', '3': 7, '4': 1, '5': 8, '10': 'skipped'},
    {'1': 'error', '3': 8, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `LedgerPosting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerPostingDescriptor = $convert.base64Decode(
    'Cg1MZWRnZXJQb3N0aW5nEhcKB3Nob3BfaWQYASABKAlSBnNob3BJZBISCgRkYXRlGAIgASgJUg'
    'RkYXRlEiUKDnRyYW5zYWN0aW9uX2lkGAMgASgJUg10cmFuc2FjdGlvbklkEiYKBXNhbGVzGAQg'
    'ASgLMhAuY29tbW9uLnYxLk1vbmV5UgVzYWxlcxIqCgdyZWZ1bmRzGAUgASgLMhAuY29tbW9uLn'
    'YxLk1vbmV5UgdyZWZ1bmRzEhYKBm9yZGVycxgGIAEoBVIGb3JkZXJzEhgKB3NraXBwZWQYByAB'
    'KAhSB3NraXBwZWQSFAoFZXJyb3IYCCABKAlSBWVycm9y');

@$core.Deprecated('Use runEndOfDayLedgerResponseDescriptor instead')
const RunEndOfDayLedgerResponse$json = {
  '1': 'RunEndOfDayLedgerResponse',
  '2': [
    {
      '1': 'postings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.LedgerPosting',
      '10': 'postings'
    },
  ],
};

/// Descriptor for `RunEndOfDayLedgerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runEndOfDayLedgerResponseDescriptor =
    $convert.base64Decode(
        'ChlSdW5FbmRPZkRheUxlZGdlclJlc3BvbnNlEjYKCHBvc3RpbmdzGAEgAygLMhouY29tbWVyY2'
        'UudjEuTGVkZ2VyUG9zdGluZ1IIcG9zdGluZ3M=');

@$core.Deprecated('Use fulfilmentDescriptor instead')
const Fulfilment$json = {
  '1': 'Fulfilment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'order_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentStatus',
      '10': 'status'
    },
    {'1': 'carrier', '3': 4, '4': 1, '5': 9, '10': 'carrier'},
    {'1': 'tracking_number', '3': 5, '4': 1, '5': 9, '10': 'trackingNumber'},
    {
      '1': 'lines',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.FulfilmentLine',
      '10': 'lines'
    },
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'shipped_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'shippedAt'
    },
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
    {
      '1': 'order_line_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'orderLineId'
    },
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
    {
      '1': 'lines',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.FulfilmentLine',
      '10': 'lines'
    },
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
    {
      '1': 'fulfilment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Fulfilment',
      '10': 'fulfilment'
    },
  ],
};

/// Descriptor for `CreateFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFulfilmentResponseDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVGdWxmaWxtZW50UmVzcG9uc2USNwoKZnVsZmlsbWVudBgBIAEoCzIXLmNvbW1lcm'
        'NlLnYxLkZ1bGZpbG1lbnRSCmZ1bGZpbG1lbnQ=');

@$core.Deprecated('Use updateFulfilmentRequestDescriptor instead')
const UpdateFulfilmentRequest$json = {
  '1': 'UpdateFulfilmentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.FulfilmentStatus',
      '10': 'status'
    },
    {'1': 'carrier', '3': 4, '4': 1, '5': 9, '10': 'carrier'},
    {'1': 'tracking_number', '3': 5, '4': 1, '5': 9, '10': 'trackingNumber'},
    {
      '1': 'shipped_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'shippedAt'
    },
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
    {
      '1': 'fulfilment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Fulfilment',
      '10': 'fulfilment'
    },
  ],
};

/// Descriptor for `UpdateFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFulfilmentResponseDescriptor =
    $convert.base64Decode(
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
    {
      '1': 'fulfilment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.Fulfilment',
      '10': 'fulfilment'
    },
  ],
};

/// Descriptor for `GetFulfilmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFulfilmentResponseDescriptor = $convert.base64Decode(
    'ChVHZXRGdWxmaWxtZW50UmVzcG9uc2USNwoKZnVsZmlsbWVudBgBIAEoCzIXLmNvbW1lcmNlLn'
    'YxLkZ1bGZpbG1lbnRSCmZ1bGZpbG1lbnQ=');

@$core.Deprecated('Use listFulfilmentsRequestDescriptor instead')
const ListFulfilmentsRequest$json = {
  '1': 'ListFulfilmentsRequest',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'orderId'},
  ],
};

/// Descriptor for `ListFulfilmentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFulfilmentsRequestDescriptor =
    $convert.base64Decode(
        'ChZMaXN0RnVsZmlsbWVudHNSZXF1ZXN0EjYKCG9yZGVyX2lkGAEgASgJQhu6SBhyFhADGCgyEF'
        'swLTlhLXpfLV17Myw0MH1SB29yZGVySWQ=');

@$core.Deprecated('Use listFulfilmentsResponseDescriptor instead')
const ListFulfilmentsResponse$json = {
  '1': 'ListFulfilmentsResponse',
  '2': [
    {
      '1': 'fulfilments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.Fulfilment',
      '10': 'fulfilments'
    },
  ],
};

/// Descriptor for `ListFulfilmentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFulfilmentsResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0RnVsZmlsbWVudHNSZXNwb25zZRI5CgtmdWxmaWxtZW50cxgBIAMoCzIXLmNvbW1lcm'
        'NlLnYxLkZ1bGZpbG1lbnRSC2Z1bGZpbG1lbnRz');

@$core.Deprecated('Use priceListDescriptor instead')
const PriceList$json = {
  '1': 'PriceList',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'shop_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'priority', '3': 5, '4': 1, '5': 5, '10': 'priority'},
    {
      '1': 'valid_from',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.PriceListStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
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
    {
      '1': 'price_list_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'priceListId'
    },
    {
      '1': 'product_variant_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
    {
      '1': 'unit_price',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unitPrice'
    },
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
    {
      '1': 'price_list_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'priceListId'
    },
    {'1': 'assigned_by', '3': 4, '4': 1, '5': 9, '10': 'assignedBy'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CustomerPriceListAssignmentStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
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
    {
      '1': 'product_variant_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
    {
      '1': 'unit_price',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unitPrice'
    },
    {
      '1': 'valid_from',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {'1': 'approved_by', '3': 7, '4': 1, '5': 9, '10': 'approvedBy'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CustomerPriceOverrideStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
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
    {
      '1': 'discount_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountType',
      '10': 'discountType'
    },
    {'1': 'value', '3': 5, '4': 1, '5': 1, '10': 'value'},
    {
      '1': 'applies_to',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountAppliesTo',
      '10': 'appliesTo'
    },
    {
      '1': 'conditions',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'conditions'
    },
    {
      '1': 'requires_approval',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'requiresApproval'
    },
    {
      '1': 'max_discount_percent',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'maxDiscountPercent'
    },
    {
      '1': 'valid_from',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountRuleStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'approved_by', '3': 16, '4': 1, '5': 9, '10': 'approvedBy'},
    {
      '1': 'approved_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'approvedAt'
    },
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
    'ZWRBdBIfCgthcHByb3ZlZF9ieRgQIAEoCVIKYXBwcm92ZWRCeRI7CgthcHByb3ZlZF9hdBgRIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmFwcHJvdmVkQXQ=');

@$core.Deprecated('Use resolvedPriceDescriptor instead')
const ResolvedPrice$json = {
  '1': 'ResolvedPrice',
  '2': [
    {'1': 'variant_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'variantId'},
    {
      '1': 'unit_price',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unitPrice'
    },
    {
      '1': 'price_source',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.PriceSource',
      '10': 'priceSource'
    },
    {'1': 'price_list_id', '3': 4, '4': 1, '5': 9, '10': 'priceListId'},
    {'1': 'override_id', '3': 5, '4': 1, '5': 9, '10': 'overrideId'},
    {
      '1': 'discount_amount',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'discountAmount'
    },
    {'1': 'discount_rule_id', '3': 7, '4': 1, '5': 9, '10': 'discountRuleId'},
    {
      '1': 'pre_discount_price',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'preDiscountPrice'
    },
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
    {
      '1': 'valid_from',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.PriceListStatus',
      '10': 'status'
    },
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
    {
      '1': 'price_list',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PriceList',
      '10': 'priceList'
    },
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
    {
      '1': 'price_list',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.PriceList',
      '10': 'priceList'
    },
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
    {
      '1': 'search',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
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
    {
      '1': 'price_lists',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.PriceList',
      '10': 'priceLists'
    },
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
    {
      '1': 'price_list_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'priceListId'
    },
    {
      '1': 'entries',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.PriceListEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `PriceListEntryBatchSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListEntryBatchSaveRequestDescriptor =
    $convert.base64Decode(
        'Ch5QcmljZUxpc3RFbnRyeUJhdGNoU2F2ZVJlcXVlc3QSPwoNcHJpY2VfbGlzdF9pZBgBIAEoCU'
        'IbukgYchYQAxgoMhBbMC05YS16Xy1dezMsNDB9UgtwcmljZUxpc3RJZBI1CgdlbnRyaWVzGAIg'
        'AygLMhsuY29tbWVyY2UudjEuUHJpY2VMaXN0RW50cnlSB2VudHJpZXM=');

@$core.Deprecated('Use priceListEntryBatchSaveResponseDescriptor instead')
const PriceListEntryBatchSaveResponse$json = {
  '1': 'PriceListEntryBatchSaveResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.PriceListEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `PriceListEntryBatchSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceListEntryBatchSaveResponseDescriptor =
    $convert.base64Decode(
        'Ch9QcmljZUxpc3RFbnRyeUJhdGNoU2F2ZVJlc3BvbnNlEjUKB2VudHJpZXMYASADKAsyGy5jb2'
        '1tZXJjZS52MS5QcmljZUxpc3RFbnRyeVIHZW50cmllcw==');

@$core
    .Deprecated('Use customerPriceListAssignmentSaveRequestDescriptor instead')
const CustomerPriceListAssignmentSaveRequest$json = {
  '1': 'CustomerPriceListAssignmentSaveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'customer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {
      '1': 'price_list_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'priceListId'
    },
    {'1': 'assigned_by', '3': 4, '4': 1, '5': 9, '10': 'assignedBy'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CustomerPriceListAssignmentStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSaveRequestDescriptor =
    $convert.base64Decode(
        'CiZDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTYXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaW'
        'QSPAoLY3VzdG9tZXJfaWQYAiABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXXszLDQwfVIKY3Vz'
        'dG9tZXJJZBI/Cg1wcmljZV9saXN0X2lkGAMgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV17My'
        'w0MH1SC3ByaWNlTGlzdElkEh8KC2Fzc2lnbmVkX2J5GAQgASgJUgphc3NpZ25lZEJ5EkYKBnN0'
        'YXR1cxgFIAEoDjIuLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFN0YX'
        'R1c1IGc3RhdHVz');

@$core
    .Deprecated('Use customerPriceListAssignmentSaveResponseDescriptor instead')
const CustomerPriceListAssignmentSaveResponse$json = {
  '1': 'CustomerPriceListAssignmentSaveResponse',
  '2': [
    {
      '1': 'assignment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.CustomerPriceListAssignment',
      '10': 'assignment'
    },
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSaveResponseDescriptor =
    $convert.base64Decode(
        'CidDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTYXZlUmVzcG9uc2USSAoKYXNzaWdubWVudB'
        'gBIAEoCzIoLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VMaXN0QXNzaWdubWVudFIKYXNzaWdu'
        'bWVudA==');

@$core.Deprecated(
    'Use customerPriceListAssignmentSearchRequestDescriptor instead')
const CustomerPriceListAssignmentSearchRequest$json = {
  '1': 'CustomerPriceListAssignmentSearchRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '10': 'customerId'},
    {'1': 'price_list_id', '3': 2, '4': 1, '5': 9, '10': 'priceListId'},
    {
      '1': 'search',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceListAssignmentSearchRequestDescriptor =
    $convert.base64Decode(
        'CihDdXN0b21lclByaWNlTGlzdEFzc2lnbm1lbnRTZWFyY2hSZXF1ZXN0Eh8KC2N1c3RvbWVyX2'
        'lkGAEgASgJUgpjdXN0b21lcklkEiIKDXByaWNlX2xpc3RfaWQYAiABKAlSC3ByaWNlTGlzdElk'
        'EjAKBnNlYXJjaBgDIAEoCzIYLmNvbW1vbi52MS5TZWFyY2hSZXF1ZXN0UgZzZWFyY2g=');

@$core.Deprecated(
    'Use customerPriceListAssignmentSearchResponseDescriptor instead')
const CustomerPriceListAssignmentSearchResponse$json = {
  '1': 'CustomerPriceListAssignmentSearchResponse',
  '2': [
    {
      '1': 'assignments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CustomerPriceListAssignment',
      '10': 'assignments'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `CustomerPriceListAssignmentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    customerPriceListAssignmentSearchResponseDescriptor = $convert.base64Decode(
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
    {
      '1': 'product_variant_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
    {
      '1': 'unit_price',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unitPrice'
    },
    {
      '1': 'valid_from',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {'1': 'approved_by', '3': 7, '4': 1, '5': 9, '10': 'approvedBy'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.CustomerPriceOverrideStatus',
      '10': 'status'
    },
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
    {
      '1': 'override',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.CustomerPriceOverride',
      '10': 'override'
    },
  ],
};

/// Descriptor for `CustomerPriceOverrideSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSaveResponseDescriptor =
    $convert.base64Decode(
        'CiFDdXN0b21lclByaWNlT3ZlcnJpZGVTYXZlUmVzcG9uc2USPgoIb3ZlcnJpZGUYASABKAsyIi'
        '5jb21tZXJjZS52MS5DdXN0b21lclByaWNlT3ZlcnJpZGVSCG92ZXJyaWRl');

@$core.Deprecated('Use customerPriceOverrideSearchRequestDescriptor instead')
const CustomerPriceOverrideSearchRequest$json = {
  '1': 'CustomerPriceOverrideSearchRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '10': 'customerId'},
    {
      '1': 'product_variant_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'productVariantId'
    },
    {
      '1': 'search',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
  ],
};

/// Descriptor for `CustomerPriceOverrideSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSearchRequestDescriptor =
    $convert.base64Decode(
        'CiJDdXN0b21lclByaWNlT3ZlcnJpZGVTZWFyY2hSZXF1ZXN0Eh8KC2N1c3RvbWVyX2lkGAEgAS'
        'gJUgpjdXN0b21lcklkEiwKEnByb2R1Y3RfdmFyaWFudF9pZBgCIAEoCVIQcHJvZHVjdFZhcmlh'
        'bnRJZBIwCgZzZWFyY2gYAyABKAsyGC5jb21tb24udjEuU2VhcmNoUmVxdWVzdFIGc2VhcmNo');

@$core.Deprecated('Use customerPriceOverrideSearchResponseDescriptor instead')
const CustomerPriceOverrideSearchResponse$json = {
  '1': 'CustomerPriceOverrideSearchResponse',
  '2': [
    {
      '1': 'overrides',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.CustomerPriceOverride',
      '10': 'overrides'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `CustomerPriceOverrideSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customerPriceOverrideSearchResponseDescriptor =
    $convert.base64Decode(
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
    {
      '1': 'discount_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountType',
      '10': 'discountType'
    },
    {'1': 'value', '3': 5, '4': 1, '5': 1, '10': 'value'},
    {
      '1': 'applies_to',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountAppliesTo',
      '10': 'appliesTo'
    },
    {
      '1': 'conditions',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'conditions'
    },
    {
      '1': 'requires_approval',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'requiresApproval'
    },
    {
      '1': 'max_discount_percent',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'maxDiscountPercent'
    },
    {
      '1': 'valid_from',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.commerce.v1.DiscountRuleStatus',
      '10': 'status'
    },
    {
      '1': 'update_mask',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
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
    'Y29tbWVyY2UudjEuRGlzY291bnRSdWxlU3RhdHVzUgZzdGF0dXMSOwoLdXBkYXRlX21hc2sYDS'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYXNrUgp1cGRhdGVNYXNr');

@$core.Deprecated('Use discountRuleSaveResponseDescriptor instead')
const DiscountRuleSaveResponse$json = {
  '1': 'DiscountRuleSaveResponse',
  '2': [
    {
      '1': 'discount_rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.DiscountRule',
      '10': 'discountRule'
    },
  ],
};

/// Descriptor for `DiscountRuleSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSaveResponseDescriptor =
    $convert.base64Decode(
        'ChhEaXNjb3VudFJ1bGVTYXZlUmVzcG9uc2USPgoNZGlzY291bnRfcnVsZRgBIAEoCzIZLmNvbW'
        '1lcmNlLnYxLkRpc2NvdW50UnVsZVIMZGlzY291bnRSdWxl');

@$core.Deprecated('Use discountRuleSearchRequestDescriptor instead')
const DiscountRuleSearchRequest$json = {
  '1': 'DiscountRuleSearchRequest',
  '2': [
    {'1': 'shop_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'shopId'},
    {
      '1': 'search',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.SearchRequest',
      '10': 'search'
    },
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
    {
      '1': 'discount_rules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.commerce.v1.DiscountRule',
      '10': 'discountRules'
    },
    {'1': 'next_page', '3': 2, '4': 1, '5': 9, '10': 'nextPage'},
    {'1': 'prev_cursor', '3': 3, '4': 1, '5': 9, '10': 'prevCursor'},
  ],
};

/// Descriptor for `DiscountRuleSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleSearchResponseDescriptor =
    $convert.base64Decode(
        'ChpEaXNjb3VudFJ1bGVTZWFyY2hSZXNwb25zZRJACg5kaXNjb3VudF9ydWxlcxgBIAMoCzIZLm'
        'NvbW1lcmNlLnYxLkRpc2NvdW50UnVsZVINZGlzY291bnRSdWxlcxIbCgluZXh0X3BhZ2UYAiAB'
        'KAlSCG5leHRQYWdlEh8KC3ByZXZfY3Vyc29yGAMgASgJUgpwcmV2Q3Vyc29y');

@$core.Deprecated('Use discountRuleApproveRequestDescriptor instead')
const DiscountRuleApproveRequest$json = {
  '1': 'DiscountRuleApproveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `DiscountRuleApproveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleApproveRequestDescriptor =
    $convert.base64Decode(
        'ChpEaXNjb3VudFJ1bGVBcHByb3ZlUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC'
        '05YS16Xy1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use discountRuleApproveResponseDescriptor instead')
const DiscountRuleApproveResponse$json = {
  '1': 'DiscountRuleApproveResponse',
  '2': [
    {
      '1': 'discount_rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.DiscountRule',
      '10': 'discountRule'
    },
  ],
};

/// Descriptor for `DiscountRuleApproveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discountRuleApproveResponseDescriptor =
    $convert.base64Decode(
        'ChtEaXNjb3VudFJ1bGVBcHByb3ZlUmVzcG9uc2USPgoNZGlzY291bnRfcnVsZRgBIAEoCzIZLm'
        'NvbW1lcmNlLnYxLkRpc2NvdW50UnVsZVIMZGlzY291bnRSdWxl');

@$core.Deprecated('Use resolvePriceRequestDescriptor instead')
const ResolvePriceRequest$json = {
  '1': 'ResolvePriceRequest',
  '2': [
    {'1': 'customer_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'customerId'},
    {
      '1': 'product_variant_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'productVariantId'
    },
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
    {
      '1': 'resolved_price',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.commerce.v1.ResolvedPrice',
      '10': 'resolvedPrice'
    },
  ],
};

/// Descriptor for `ResolvePriceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolvePriceResponseDescriptor = $convert.base64Decode(
    'ChRSZXNvbHZlUHJpY2VSZXNwb25zZRJBCg5yZXNvbHZlZF9wcmljZRgBIAEoCzIaLmNvbW1lcm'
    'NlLnYxLlJlc29sdmVkUHJpY2VSDXJlc29sdmVkUHJpY2U=');

const $core.Map<$core.String, $core.dynamic> CommerceServiceBase$json = {
  '1': 'CommerceService',
  '2': [
    {
      '1': 'CreateShop',
      '2': '.commerce.v1.CreateShopRequest',
      '3': '.commerce.v1.CreateShopResponse',
      '4': {}
    },
    {
      '1': 'GetShop',
      '2': '.commerce.v1.GetShopRequest',
      '3': '.commerce.v1.GetShopResponse',
      '4': {}
    },
    {
      '1': 'UpdateShop',
      '2': '.commerce.v1.UpdateShopRequest',
      '3': '.commerce.v1.UpdateShopResponse',
      '4': {}
    },
    {
      '1': 'ListShops',
      '2': '.commerce.v1.ListShopsRequest',
      '3': '.commerce.v1.ListShopsResponse',
      '4': {}
    },
    {
      '1': 'ResolveDefaultCurrency',
      '2': '.commerce.v1.ResolveDefaultCurrencyRequest',
      '3': '.commerce.v1.ResolveDefaultCurrencyResponse',
      '4': {}
    },
    {
      '1': 'CreateProduct',
      '2': '.commerce.v1.CreateProductRequest',
      '3': '.commerce.v1.CreateProductResponse',
      '4': {}
    },
    {
      '1': 'GetProduct',
      '2': '.commerce.v1.GetProductRequest',
      '3': '.commerce.v1.GetProductResponse',
      '4': {}
    },
    {
      '1': 'ListProducts',
      '2': '.commerce.v1.ListProductsRequest',
      '3': '.commerce.v1.ListProductsResponse',
      '4': {}
    },
    {
      '1': 'CreateProductVariant',
      '2': '.commerce.v1.CreateProductVariantRequest',
      '3': '.commerce.v1.CreateProductVariantResponse',
      '4': {}
    },
    {
      '1': 'UpdateProductVariant',
      '2': '.commerce.v1.UpdateProductVariantRequest',
      '3': '.commerce.v1.UpdateProductVariantResponse',
      '4': {}
    },
    {
      '1': 'UpdateProduct',
      '2': '.commerce.v1.UpdateProductRequest',
      '3': '.commerce.v1.UpdateProductResponse',
      '4': {}
    },
    {
      '1': 'ListProductVariants',
      '2': '.commerce.v1.ListProductVariantsRequest',
      '3': '.commerce.v1.ListProductVariantsResponse',
      '4': {}
    },
    {
      '1': 'ReceiveStock',
      '2': '.commerce.v1.ReceiveStockRequest',
      '3': '.commerce.v1.ReceiveStockResponse',
      '4': {}
    },
    {
      '1': 'CreateCart',
      '2': '.commerce.v1.CreateCartRequest',
      '3': '.commerce.v1.CreateCartResponse',
      '4': {}
    },
    {
      '1': 'GetCart',
      '2': '.commerce.v1.GetCartRequest',
      '3': '.commerce.v1.GetCartResponse',
      '4': {}
    },
    {
      '1': 'AddCartLine',
      '2': '.commerce.v1.AddCartLineRequest',
      '3': '.commerce.v1.AddCartLineResponse',
      '4': {}
    },
    {
      '1': 'RemoveCartLine',
      '2': '.commerce.v1.RemoveCartLineRequest',
      '3': '.commerce.v1.RemoveCartLineResponse',
      '4': {}
    },
    {
      '1': 'CreateOrderFromCart',
      '2': '.commerce.v1.CreateOrderFromCartRequest',
      '3': '.commerce.v1.CreateOrderFromCartResponse',
      '4': {}
    },
    {
      '1': 'CreateOrder',
      '2': '.commerce.v1.CreateOrderRequest',
      '3': '.commerce.v1.CreateOrderResponse',
      '4': {}
    },
    {
      '1': 'GetOrder',
      '2': '.commerce.v1.GetOrderRequest',
      '3': '.commerce.v1.GetOrderResponse',
      '4': {}
    },
    {
      '1': 'ListOrders',
      '2': '.commerce.v1.ListOrdersRequest',
      '3': '.commerce.v1.ListOrdersResponse',
      '4': {}
    },
    {
      '1': 'CheckoutOrder',
      '2': '.commerce.v1.CheckoutOrderRequest',
      '3': '.commerce.v1.CheckoutOrderResponse',
      '4': {}
    },
    {
      '1': 'ConfirmOrderPayment',
      '2': '.commerce.v1.ConfirmOrderPaymentRequest',
      '3': '.commerce.v1.ConfirmOrderPaymentResponse',
      '4': {}
    },
    {
      '1': 'CancelOrder',
      '2': '.commerce.v1.CancelOrderRequest',
      '3': '.commerce.v1.CancelOrderResponse',
      '4': {}
    },
    {
      '1': 'RecordOrderPayment',
      '2': '.commerce.v1.RecordOrderPaymentRequest',
      '3': '.commerce.v1.RecordOrderPaymentResponse',
      '4': {}
    },
    {
      '1': 'ResolveOrderRefund',
      '2': '.commerce.v1.ResolveOrderRefundRequest',
      '3': '.commerce.v1.ResolveOrderRefundResponse',
      '4': {}
    },
    {
      '1': 'ListOrderEvents',
      '2': '.commerce.v1.ListOrderEventsRequest',
      '3': '.commerce.v1.ListOrderEventsResponse',
      '4': {}
    },
    {
      '1': 'ReconcilePayments',
      '2': '.commerce.v1.ReconcilePaymentsRequest',
      '3': '.commerce.v1.ReconcilePaymentsResponse',
      '4': {}
    },
    {
      '1': 'RunEndOfDayLedger',
      '2': '.commerce.v1.RunEndOfDayLedgerRequest',
      '3': '.commerce.v1.RunEndOfDayLedgerResponse',
      '4': {}
    },
    {
      '1': 'CreateFulfilment',
      '2': '.commerce.v1.CreateFulfilmentRequest',
      '3': '.commerce.v1.CreateFulfilmentResponse',
      '4': {}
    },
    {
      '1': 'UpdateFulfilment',
      '2': '.commerce.v1.UpdateFulfilmentRequest',
      '3': '.commerce.v1.UpdateFulfilmentResponse',
      '4': {}
    },
    {
      '1': 'GetFulfilment',
      '2': '.commerce.v1.GetFulfilmentRequest',
      '3': '.commerce.v1.GetFulfilmentResponse',
      '4': {}
    },
    {
      '1': 'ListFulfilments',
      '2': '.commerce.v1.ListFulfilmentsRequest',
      '3': '.commerce.v1.ListFulfilmentsResponse',
      '4': {}
    },
    {
      '1': 'PriceListSave',
      '2': '.commerce.v1.PriceListSaveRequest',
      '3': '.commerce.v1.PriceListSaveResponse',
      '4': {}
    },
    {
      '1': 'PriceListGet',
      '2': '.commerce.v1.PriceListGetRequest',
      '3': '.commerce.v1.PriceListGetResponse',
      '4': {}
    },
    {
      '1': 'PriceListSearch',
      '2': '.commerce.v1.PriceListSearchRequest',
      '3': '.commerce.v1.PriceListSearchResponse',
      '4': {}
    },
    {
      '1': 'PriceListEntryBatchSave',
      '2': '.commerce.v1.PriceListEntryBatchSaveRequest',
      '3': '.commerce.v1.PriceListEntryBatchSaveResponse',
      '4': {}
    },
    {
      '1': 'CustomerPriceListAssignmentSave',
      '2': '.commerce.v1.CustomerPriceListAssignmentSaveRequest',
      '3': '.commerce.v1.CustomerPriceListAssignmentSaveResponse',
      '4': {}
    },
    {
      '1': 'CustomerPriceListAssignmentSearch',
      '2': '.commerce.v1.CustomerPriceListAssignmentSearchRequest',
      '3': '.commerce.v1.CustomerPriceListAssignmentSearchResponse',
      '4': {}
    },
    {
      '1': 'CustomerPriceOverrideSave',
      '2': '.commerce.v1.CustomerPriceOverrideSaveRequest',
      '3': '.commerce.v1.CustomerPriceOverrideSaveResponse',
      '4': {}
    },
    {
      '1': 'CustomerPriceOverrideSearch',
      '2': '.commerce.v1.CustomerPriceOverrideSearchRequest',
      '3': '.commerce.v1.CustomerPriceOverrideSearchResponse',
      '4': {}
    },
    {
      '1': 'DiscountRuleSave',
      '2': '.commerce.v1.DiscountRuleSaveRequest',
      '3': '.commerce.v1.DiscountRuleSaveResponse',
      '4': {}
    },
    {
      '1': 'DiscountRuleSearch',
      '2': '.commerce.v1.DiscountRuleSearchRequest',
      '3': '.commerce.v1.DiscountRuleSearchResponse',
      '4': {}
    },
    {
      '1': 'DiscountRuleApprove',
      '2': '.commerce.v1.DiscountRuleApproveRequest',
      '3': '.commerce.v1.DiscountRuleApproveResponse',
      '4': {}
    },
    {
      '1': 'ResolvePrice',
      '2': '.commerce.v1.ResolvePriceRequest',
      '3': '.commerce.v1.ResolvePriceResponse',
      '4': {}
    },
  ],
  '3': {},
};

@$core.Deprecated('Use commerceServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    CommerceServiceBase$messageJson = {
  '.commerce.v1.CreateShopRequest': CreateShopRequest$json,
  '.commerce.v1.PaymentPolicy': PaymentPolicy$json,
  '.commerce.v1.CreateShopResponse': CreateShopResponse$json,
  '.commerce.v1.Shop': Shop$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.google.protobuf.Struct': $1.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $1.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $1.Value$json,
  '.google.protobuf.ListValue': $1.ListValue$json,
  '.commerce.v1.GetShopRequest': GetShopRequest$json,
  '.commerce.v1.GetShopResponse': GetShopResponse$json,
  '.commerce.v1.UpdateShopRequest': UpdateShopRequest$json,
  '.google.protobuf.FieldMask': $2.FieldMask$json,
  '.commerce.v1.UpdateShopResponse': UpdateShopResponse$json,
  '.commerce.v1.ListShopsRequest': ListShopsRequest$json,
  '.common.v1.SearchRequest': $3.SearchRequest$json,
  '.common.v1.PageCursor': $3.PageCursor$json,
  '.commerce.v1.ListShopsResponse': ListShopsResponse$json,
  '.commerce.v1.ResolveDefaultCurrencyRequest':
      ResolveDefaultCurrencyRequest$json,
  '.commerce.v1.ResolveDefaultCurrencyResponse':
      ResolveDefaultCurrencyResponse$json,
  '.commerce.v1.CreateProductRequest': CreateProductRequest$json,
  '.commerce.v1.CreateProductRequest.AttributesEntry':
      CreateProductRequest_AttributesEntry$json,
  '.commerce.v1.CreateProductResponse': CreateProductResponse$json,
  '.commerce.v1.Product': Product$json,
  '.commerce.v1.Product.AttributesEntry': Product_AttributesEntry$json,
  '.commerce.v1.GetProductRequest': GetProductRequest$json,
  '.commerce.v1.GetProductResponse': GetProductResponse$json,
  '.commerce.v1.ListProductsRequest': ListProductsRequest$json,
  '.commerce.v1.ListProductsResponse': ListProductsResponse$json,
  '.commerce.v1.CreateProductVariantRequest': CreateProductVariantRequest$json,
  '.common.v1.Money': $4.Money$json,
  '.commerce.v1.CreateProductVariantRequest.AttributesEntry':
      CreateProductVariantRequest_AttributesEntry$json,
  '.commerce.v1.CreateProductVariantResponse':
      CreateProductVariantResponse$json,
  '.commerce.v1.ProductVariant': ProductVariant$json,
  '.commerce.v1.ProductVariant.AttributesEntry':
      ProductVariant_AttributesEntry$json,
  '.commerce.v1.UpdateProductVariantRequest': UpdateProductVariantRequest$json,
  '.commerce.v1.UpdateProductVariantRequest.AttributesEntry':
      UpdateProductVariantRequest_AttributesEntry$json,
  '.commerce.v1.UpdateProductVariantResponse':
      UpdateProductVariantResponse$json,
  '.commerce.v1.UpdateProductRequest': UpdateProductRequest$json,
  '.commerce.v1.UpdateProductRequest.AttributesEntry':
      UpdateProductRequest_AttributesEntry$json,
  '.commerce.v1.UpdateProductResponse': UpdateProductResponse$json,
  '.commerce.v1.ListProductVariantsRequest': ListProductVariantsRequest$json,
  '.commerce.v1.ListProductVariantsResponse': ListProductVariantsResponse$json,
  '.commerce.v1.ReceiveStockRequest': ReceiveStockRequest$json,
  '.commerce.v1.ReceiveStockResponse': ReceiveStockResponse$json,
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
  '.commerce.v1.OrderPayment': OrderPayment$json,
  '.commerce.v1.OrderRefund': OrderRefund$json,
  '.commerce.v1.CreateOrderRequest': CreateOrderRequest$json,
  '.commerce.v1.CreateOrderLine': CreateOrderLine$json,
  '.commerce.v1.CreateOrderResponse': CreateOrderResponse$json,
  '.commerce.v1.GetOrderRequest': GetOrderRequest$json,
  '.commerce.v1.GetOrderResponse': GetOrderResponse$json,
  '.commerce.v1.ListOrdersRequest': ListOrdersRequest$json,
  '.commerce.v1.ListOrdersResponse': ListOrdersResponse$json,
  '.commerce.v1.CheckoutOrderRequest': CheckoutOrderRequest$json,
  '.commerce.v1.CheckoutOrderResponse': CheckoutOrderResponse$json,
  '.commerce.v1.ConfirmOrderPaymentRequest': ConfirmOrderPaymentRequest$json,
  '.commerce.v1.ConfirmOrderPaymentResponse': ConfirmOrderPaymentResponse$json,
  '.commerce.v1.CancelOrderRequest': CancelOrderRequest$json,
  '.commerce.v1.CancelOrderResponse': CancelOrderResponse$json,
  '.commerce.v1.RecordOrderPaymentRequest': RecordOrderPaymentRequest$json,
  '.commerce.v1.RecordOrderPaymentResponse': RecordOrderPaymentResponse$json,
  '.commerce.v1.ResolveOrderRefundRequest': ResolveOrderRefundRequest$json,
  '.commerce.v1.ResolveOrderRefundResponse': ResolveOrderRefundResponse$json,
  '.commerce.v1.ListOrderEventsRequest': ListOrderEventsRequest$json,
  '.commerce.v1.ListOrderEventsResponse': ListOrderEventsResponse$json,
  '.commerce.v1.OrderEvent': OrderEvent$json,
  '.commerce.v1.ReconcilePaymentsRequest': ReconcilePaymentsRequest$json,
  '.commerce.v1.ReconcilePaymentsResponse': ReconcilePaymentsResponse$json,
  '.commerce.v1.RunEndOfDayLedgerRequest': RunEndOfDayLedgerRequest$json,
  '.commerce.v1.RunEndOfDayLedgerResponse': RunEndOfDayLedgerResponse$json,
  '.commerce.v1.LedgerPosting': LedgerPosting$json,
  '.commerce.v1.CreateFulfilmentRequest': CreateFulfilmentRequest$json,
  '.commerce.v1.FulfilmentLine': FulfilmentLine$json,
  '.commerce.v1.CreateFulfilmentResponse': CreateFulfilmentResponse$json,
  '.commerce.v1.Fulfilment': Fulfilment$json,
  '.commerce.v1.UpdateFulfilmentRequest': UpdateFulfilmentRequest$json,
  '.commerce.v1.UpdateFulfilmentResponse': UpdateFulfilmentResponse$json,
  '.commerce.v1.GetFulfilmentRequest': GetFulfilmentRequest$json,
  '.commerce.v1.GetFulfilmentResponse': GetFulfilmentResponse$json,
  '.commerce.v1.ListFulfilmentsRequest': ListFulfilmentsRequest$json,
  '.commerce.v1.ListFulfilmentsResponse': ListFulfilmentsResponse$json,
  '.commerce.v1.PriceListSaveRequest': PriceListSaveRequest$json,
  '.commerce.v1.PriceListSaveResponse': PriceListSaveResponse$json,
  '.commerce.v1.PriceList': PriceList$json,
  '.commerce.v1.PriceListGetRequest': PriceListGetRequest$json,
  '.commerce.v1.PriceListGetResponse': PriceListGetResponse$json,
  '.commerce.v1.PriceListSearchRequest': PriceListSearchRequest$json,
  '.commerce.v1.PriceListSearchResponse': PriceListSearchResponse$json,
  '.commerce.v1.PriceListEntryBatchSaveRequest':
      PriceListEntryBatchSaveRequest$json,
  '.commerce.v1.PriceListEntry': PriceListEntry$json,
  '.commerce.v1.PriceListEntryBatchSaveResponse':
      PriceListEntryBatchSaveResponse$json,
  '.commerce.v1.CustomerPriceListAssignmentSaveRequest':
      CustomerPriceListAssignmentSaveRequest$json,
  '.commerce.v1.CustomerPriceListAssignmentSaveResponse':
      CustomerPriceListAssignmentSaveResponse$json,
  '.commerce.v1.CustomerPriceListAssignment': CustomerPriceListAssignment$json,
  '.commerce.v1.CustomerPriceListAssignmentSearchRequest':
      CustomerPriceListAssignmentSearchRequest$json,
  '.commerce.v1.CustomerPriceListAssignmentSearchResponse':
      CustomerPriceListAssignmentSearchResponse$json,
  '.commerce.v1.CustomerPriceOverrideSaveRequest':
      CustomerPriceOverrideSaveRequest$json,
  '.commerce.v1.CustomerPriceOverrideSaveResponse':
      CustomerPriceOverrideSaveResponse$json,
  '.commerce.v1.CustomerPriceOverride': CustomerPriceOverride$json,
  '.commerce.v1.CustomerPriceOverrideSearchRequest':
      CustomerPriceOverrideSearchRequest$json,
  '.commerce.v1.CustomerPriceOverrideSearchResponse':
      CustomerPriceOverrideSearchResponse$json,
  '.commerce.v1.DiscountRuleSaveRequest': DiscountRuleSaveRequest$json,
  '.commerce.v1.DiscountRuleSaveResponse': DiscountRuleSaveResponse$json,
  '.commerce.v1.DiscountRule': DiscountRule$json,
  '.commerce.v1.DiscountRuleSearchRequest': DiscountRuleSearchRequest$json,
  '.commerce.v1.DiscountRuleSearchResponse': DiscountRuleSearchResponse$json,
  '.commerce.v1.DiscountRuleApproveRequest': DiscountRuleApproveRequest$json,
  '.commerce.v1.DiscountRuleApproveResponse': DiscountRuleApproveResponse$json,
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
    '9uc2UiEYK1GA0KC3Nob3BfdXBkYXRlElwKCUxpc3RTaG9wcxIdLmNvbW1lcmNlLnYxLkxpc3RT'
    'aG9wc1JlcXVlc3QaHi5jb21tZXJjZS52MS5MaXN0U2hvcHNSZXNwb25zZSIQgrUYDAoKc2hvcH'
    'NfbGlzdBKDAQoWUmVzb2x2ZURlZmF1bHRDdXJyZW5jeRIqLmNvbW1lcmNlLnYxLlJlc29sdmVE'
    'ZWZhdWx0Q3VycmVuY3lSZXF1ZXN0GisuY29tbWVyY2UudjEuUmVzb2x2ZURlZmF1bHRDdXJyZW'
    '5jeVJlc3BvbnNlIhCCtRgMCgpzaG9wc19saXN0EmwKDUNyZWF0ZVByb2R1Y3QSIS5jb21tZXJj'
    'ZS52MS5DcmVhdGVQcm9kdWN0UmVxdWVzdBoiLmNvbW1lcmNlLnYxLkNyZWF0ZVByb2R1Y3RSZX'
    'Nwb25zZSIUgrUYEAoOcHJvZHVjdF9tYW5hZ2USYQoKR2V0UHJvZHVjdBIeLmNvbW1lcmNlLnYx'
    'LkdldFByb2R1Y3RSZXF1ZXN0Gh8uY29tbWVyY2UudjEuR2V0UHJvZHVjdFJlc3BvbnNlIhKCtR'
    'gOCgxwcm9kdWN0X3ZpZXcSZwoMTGlzdFByb2R1Y3RzEiAuY29tbWVyY2UudjEuTGlzdFByb2R1'
    'Y3RzUmVxdWVzdBohLmNvbW1lcmNlLnYxLkxpc3RQcm9kdWN0c1Jlc3BvbnNlIhKCtRgOCgxwcm'
    '9kdWN0X3ZpZXcSgQEKFENyZWF0ZVByb2R1Y3RWYXJpYW50EiguY29tbWVyY2UudjEuQ3JlYXRl'
    'UHJvZHVjdFZhcmlhbnRSZXF1ZXN0GikuY29tbWVyY2UudjEuQ3JlYXRlUHJvZHVjdFZhcmlhbn'
    'RSZXNwb25zZSIUgrUYEAoOcHJvZHVjdF9tYW5hZ2USgQEKFFVwZGF0ZVByb2R1Y3RWYXJpYW50'
    'EiguY29tbWVyY2UudjEuVXBkYXRlUHJvZHVjdFZhcmlhbnRSZXF1ZXN0GikuY29tbWVyY2Uudj'
    'EuVXBkYXRlUHJvZHVjdFZhcmlhbnRSZXNwb25zZSIUgrUYEAoOcHJvZHVjdF9tYW5hZ2USbAoN'
    'VXBkYXRlUHJvZHVjdBIhLmNvbW1lcmNlLnYxLlVwZGF0ZVByb2R1Y3RSZXF1ZXN0GiIuY29tbW'
    'VyY2UudjEuVXBkYXRlUHJvZHVjdFJlc3BvbnNlIhSCtRgQCg5wcm9kdWN0X21hbmFnZRJ8ChNM'
    'aXN0UHJvZHVjdFZhcmlhbnRzEicuY29tbWVyY2UudjEuTGlzdFByb2R1Y3RWYXJpYW50c1JlcX'
    'Vlc3QaKC5jb21tZXJjZS52MS5MaXN0UHJvZHVjdFZhcmlhbnRzUmVzcG9uc2UiEoK1GA4KDHBy'
    'b2R1Y3RfdmlldxJoCgxSZWNlaXZlU3RvY2sSIC5jb21tZXJjZS52MS5SZWNlaXZlU3RvY2tSZX'
    'F1ZXN0GiEuY29tbWVyY2UudjEuUmVjZWl2ZVN0b2NrUmVzcG9uc2UiE4K1GA8KDXN0b2NrX3Jl'
    'Y2VpdmUSYAoKQ3JlYXRlQ2FydBIeLmNvbW1lcmNlLnYxLkNyZWF0ZUNhcnRSZXF1ZXN0Gh8uY2'
    '9tbWVyY2UudjEuQ3JlYXRlQ2FydFJlc3BvbnNlIhGCtRgNCgtjYXJ0X21hbmFnZRJVCgdHZXRD'
    'YXJ0EhsuY29tbWVyY2UudjEuR2V0Q2FydFJlcXVlc3QaHC5jb21tZXJjZS52MS5HZXRDYXJ0Um'
    'VzcG9uc2UiD4K1GAsKCWNhcnRfdmlldxJjCgtBZGRDYXJ0TGluZRIfLmNvbW1lcmNlLnYxLkFk'
    'ZENhcnRMaW5lUmVxdWVzdBogLmNvbW1lcmNlLnYxLkFkZENhcnRMaW5lUmVzcG9uc2UiEYK1GA'
    '0KC2NhcnRfbWFuYWdlEmwKDlJlbW92ZUNhcnRMaW5lEiIuY29tbWVyY2UudjEuUmVtb3ZlQ2Fy'
    'dExpbmVSZXF1ZXN0GiMuY29tbWVyY2UudjEuUmVtb3ZlQ2FydExpbmVSZXNwb25zZSIRgrUYDQ'
    'oLY2FydF9tYW5hZ2USfAoTQ3JlYXRlT3JkZXJGcm9tQ2FydBInLmNvbW1lcmNlLnYxLkNyZWF0'
    'ZU9yZGVyRnJvbUNhcnRSZXF1ZXN0GiguY29tbWVyY2UudjEuQ3JlYXRlT3JkZXJGcm9tQ2FydF'
    'Jlc3BvbnNlIhKCtRgOCgxvcmRlcl9tYW5hZ2USZAoLQ3JlYXRlT3JkZXISHy5jb21tZXJjZS52'
    'MS5DcmVhdGVPcmRlclJlcXVlc3QaIC5jb21tZXJjZS52MS5DcmVhdGVPcmRlclJlc3BvbnNlIh'
    'KCtRgOCgxvcmRlcl9tYW5hZ2USWQoIR2V0T3JkZXISHC5jb21tZXJjZS52MS5HZXRPcmRlclJl'
    'cXVlc3QaHS5jb21tZXJjZS52MS5HZXRPcmRlclJlc3BvbnNlIhCCtRgMCgpvcmRlcl92aWV3El'
    '8KCkxpc3RPcmRlcnMSHi5jb21tZXJjZS52MS5MaXN0T3JkZXJzUmVxdWVzdBofLmNvbW1lcmNl'
    'LnYxLkxpc3RPcmRlcnNSZXNwb25zZSIQgrUYDAoKb3JkZXJfdmlldxJqCg1DaGVja291dE9yZG'
    'VyEiEuY29tbWVyY2UudjEuQ2hlY2tvdXRPcmRlclJlcXVlc3QaIi5jb21tZXJjZS52MS5DaGVj'
    'a291dE9yZGVyUmVzcG9uc2UiEoK1GA4KDG9yZGVyX21hbmFnZRJ8ChNDb25maXJtT3JkZXJQYX'
    'ltZW50EicuY29tbWVyY2UudjEuQ29uZmlybU9yZGVyUGF5bWVudFJlcXVlc3QaKC5jb21tZXJj'
    'ZS52MS5Db25maXJtT3JkZXJQYXltZW50UmVzcG9uc2UiEoK1GA4KDG9yZGVyX21hbmFnZRJkCg'
    'tDYW5jZWxPcmRlchIfLmNvbW1lcmNlLnYxLkNhbmNlbE9yZGVyUmVxdWVzdBogLmNvbW1lcmNl'
    'LnYxLkNhbmNlbE9yZGVyUmVzcG9uc2UiEoK1GA4KDG9yZGVyX21hbmFnZRJ5ChJSZWNvcmRPcm'
    'RlclBheW1lbnQSJi5jb21tZXJjZS52MS5SZWNvcmRPcmRlclBheW1lbnRSZXF1ZXN0GicuY29t'
    'bWVyY2UudjEuUmVjb3JkT3JkZXJQYXltZW50UmVzcG9uc2UiEoK1GA4KDG9yZGVyX21hbmFnZR'
    'J5ChJSZXNvbHZlT3JkZXJSZWZ1bmQSJi5jb21tZXJjZS52MS5SZXNvbHZlT3JkZXJSZWZ1bmRS'
    'ZXF1ZXN0GicuY29tbWVyY2UudjEuUmVzb2x2ZU9yZGVyUmVmdW5kUmVzcG9uc2UiEoK1GA4KDG'
    '9yZGVyX21hbmFnZRJuCg9MaXN0T3JkZXJFdmVudHMSIy5jb21tZXJjZS52MS5MaXN0T3JkZXJF'
    'dmVudHNSZXF1ZXN0GiQuY29tbWVyY2UudjEuTGlzdE9yZGVyRXZlbnRzUmVzcG9uc2UiEIK1GA'
    'wKCm9yZGVyX3ZpZXcSdQoRUmVjb25jaWxlUGF5bWVudHMSJS5jb21tZXJjZS52MS5SZWNvbmNp'
    'bGVQYXltZW50c1JlcXVlc3QaJi5jb21tZXJjZS52MS5SZWNvbmNpbGVQYXltZW50c1Jlc3Bvbn'
    'NlIhGCtRgNCgtsZWRnZXJfcG9zdBJ1ChFSdW5FbmRPZkRheUxlZGdlchIlLmNvbW1lcmNlLnYx'
    'LlJ1bkVuZE9mRGF5TGVkZ2VyUmVxdWVzdBomLmNvbW1lcmNlLnYxLlJ1bkVuZE9mRGF5TGVkZ2'
    'VyUmVzcG9uc2UiEYK1GA0KC2xlZGdlcl9wb3N0EngKEENyZWF0ZUZ1bGZpbG1lbnQSJC5jb21t'
    'ZXJjZS52MS5DcmVhdGVGdWxmaWxtZW50UmVxdWVzdBolLmNvbW1lcmNlLnYxLkNyZWF0ZUZ1bG'
    'ZpbG1lbnRSZXNwb25zZSIXgrUYEwoRZnVsZmlsbWVudF9tYW5hZ2USeAoQVXBkYXRlRnVsZmls'
    'bWVudBIkLmNvbW1lcmNlLnYxLlVwZGF0ZUZ1bGZpbG1lbnRSZXF1ZXN0GiUuY29tbWVyY2Uudj'
    'EuVXBkYXRlRnVsZmlsbWVudFJlc3BvbnNlIheCtRgTChFmdWxmaWxtZW50X21hbmFnZRJtCg1H'
    'ZXRGdWxmaWxtZW50EiEuY29tbWVyY2UudjEuR2V0RnVsZmlsbWVudFJlcXVlc3QaIi5jb21tZX'
    'JjZS52MS5HZXRGdWxmaWxtZW50UmVzcG9uc2UiFYK1GBEKD2Z1bGZpbG1lbnRfdmlldxJzCg9M'
    'aXN0RnVsZmlsbWVudHMSIy5jb21tZXJjZS52MS5MaXN0RnVsZmlsbWVudHNSZXF1ZXN0GiQuY2'
    '9tbWVyY2UudjEuTGlzdEZ1bGZpbG1lbnRzUmVzcG9uc2UiFYK1GBEKD2Z1bGZpbG1lbnRfdmll'
    'dxJvCg1QcmljZUxpc3RTYXZlEiEuY29tbWVyY2UudjEuUHJpY2VMaXN0U2F2ZVJlcXVlc3QaIi'
    '5jb21tZXJjZS52MS5QcmljZUxpc3RTYXZlUmVzcG9uc2UiF4K1GBMKEXByaWNlX2xpc3RfbWFu'
    'YWdlEmoKDFByaWNlTGlzdEdldBIgLmNvbW1lcmNlLnYxLlByaWNlTGlzdEdldFJlcXVlc3QaIS'
    '5jb21tZXJjZS52MS5QcmljZUxpc3RHZXRSZXNwb25zZSIVgrUYEQoPcHJpY2VfbGlzdF92aWV3'
    'EnMKD1ByaWNlTGlzdFNlYXJjaBIjLmNvbW1lcmNlLnYxLlByaWNlTGlzdFNlYXJjaFJlcXVlc3'
    'QaJC5jb21tZXJjZS52MS5QcmljZUxpc3RTZWFyY2hSZXNwb25zZSIVgrUYEQoPcHJpY2VfbGlz'
    'dF92aWV3Eo0BChdQcmljZUxpc3RFbnRyeUJhdGNoU2F2ZRIrLmNvbW1lcmNlLnYxLlByaWNlTG'
    'lzdEVudHJ5QmF0Y2hTYXZlUmVxdWVzdBosLmNvbW1lcmNlLnYxLlByaWNlTGlzdEVudHJ5QmF0'
    'Y2hTYXZlUmVzcG9uc2UiF4K1GBMKEXByaWNlX2xpc3RfbWFuYWdlEqsBCh9DdXN0b21lclByaW'
    'NlTGlzdEFzc2lnbm1lbnRTYXZlEjMuY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZUxpc3RBc3Np'
    'Z25tZW50U2F2ZVJlcXVlc3QaNC5jb21tZXJjZS52MS5DdXN0b21lclByaWNlTGlzdEFzc2lnbm'
    '1lbnRTYXZlUmVzcG9uc2UiHYK1GBkKF2N1c3RvbWVyX3ByaWNlX292ZXJyaWRlEqkBCiFDdXN0'
    'b21lclByaWNlTGlzdEFzc2lnbm1lbnRTZWFyY2gSNS5jb21tZXJjZS52MS5DdXN0b21lclByaW'
    'NlTGlzdEFzc2lnbm1lbnRTZWFyY2hSZXF1ZXN0GjYuY29tbWVyY2UudjEuQ3VzdG9tZXJQcmlj'
    'ZUxpc3RBc3NpZ25tZW50U2VhcmNoUmVzcG9uc2UiFYK1GBEKD3ByaWNlX2xpc3RfdmlldxKZAQ'
    'oZQ3VzdG9tZXJQcmljZU92ZXJyaWRlU2F2ZRItLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VP'
    'dmVycmlkZVNhdmVSZXF1ZXN0Gi4uY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZU92ZXJyaWRlU2'
    'F2ZVJlc3BvbnNlIh2CtRgZChdjdXN0b21lcl9wcmljZV9vdmVycmlkZRKXAQobQ3VzdG9tZXJQ'
    'cmljZU92ZXJyaWRlU2VhcmNoEi8uY29tbWVyY2UudjEuQ3VzdG9tZXJQcmljZU92ZXJyaWRlU2'
    'VhcmNoUmVxdWVzdBowLmNvbW1lcmNlLnYxLkN1c3RvbWVyUHJpY2VPdmVycmlkZVNlYXJjaFJl'
    'c3BvbnNlIhWCtRgRCg9wcmljZV9saXN0X3ZpZXcSdgoQRGlzY291bnRSdWxlU2F2ZRIkLmNvbW'
    '1lcmNlLnYxLkRpc2NvdW50UnVsZVNhdmVSZXF1ZXN0GiUuY29tbWVyY2UudjEuRGlzY291bnRS'
    'dWxlU2F2ZVJlc3BvbnNlIhWCtRgRCg9kaXNjb3VudF9tYW5hZ2USfAoSRGlzY291bnRSdWxlU2'
    'VhcmNoEiYuY29tbWVyY2UudjEuRGlzY291bnRSdWxlU2VhcmNoUmVxdWVzdBonLmNvbW1lcmNl'
    'LnYxLkRpc2NvdW50UnVsZVNlYXJjaFJlc3BvbnNlIhWCtRgRCg9wcmljZV9saXN0X3ZpZXcSgA'
    'EKE0Rpc2NvdW50UnVsZUFwcHJvdmUSJy5jb21tZXJjZS52MS5EaXNjb3VudFJ1bGVBcHByb3Zl'
    'UmVxdWVzdBooLmNvbW1lcmNlLnYxLkRpc2NvdW50UnVsZUFwcHJvdmVSZXNwb25zZSIWgrUYEg'
    'oQZGlzY291bnRfYXBwcm92ZRJqCgxSZXNvbHZlUHJpY2USIC5jb21tZXJjZS52MS5SZXNvbHZl'
    'UHJpY2VSZXF1ZXN0GiEuY29tbWVyY2UudjEuUmVzb2x2ZVByaWNlUmVzcG9uc2UiFYK1GBEKD3'
    'ByaWNlX2xpc3RfdmlldxrwC4K1GOsLChBzZXJ2aWNlX2NvbW1lcmNlEglzaG9wX3ZpZXcSC3No'
    'b3BfY3JlYXRlEgtzaG9wX3VwZGF0ZRIMcHJvZHVjdF92aWV3Eg5wcm9kdWN0X21hbmFnZRIJY2'
    'FydF92aWV3EgtjYXJ0X21hbmFnZRIKb3JkZXJfdmlldxIMb3JkZXJfbWFuYWdlEg9mdWxmaWxt'
    'ZW50X3ZpZXcSEWZ1bGZpbG1lbnRfbWFuYWdlEg9wcmljZV9saXN0X3ZpZXcSEXByaWNlX2xpc3'
    'RfbWFuYWdlEhdjdXN0b21lcl9wcmljZV9vdmVycmlkZRIPZGlzY291bnRfbWFuYWdlEhBkaXNj'
    'b3VudF9hcHByb3ZlEgpzaG9wc19saXN0EgtsZWRnZXJfcG9zdBINc3RvY2tfcmVjZWl2ZRqUAg'
    'gBEglzaG9wX3ZpZXcSC3Nob3BfY3JlYXRlEgtzaG9wX3VwZGF0ZRIMcHJvZHVjdF92aWV3Eg5w'
    'cm9kdWN0X21hbmFnZRIJY2FydF92aWV3EgtjYXJ0X21hbmFnZRIKb3JkZXJfdmlldxIMb3JkZX'
    'JfbWFuYWdlEg9mdWxmaWxtZW50X3ZpZXcSEWZ1bGZpbG1lbnRfbWFuYWdlEg9wcmljZV9saXN0'
    'X3ZpZXcSEXByaWNlX2xpc3RfbWFuYWdlEhdjdXN0b21lcl9wcmljZV9vdmVycmlkZRIPZGlzY2'
    '91bnRfbWFuYWdlEhBkaXNjb3VudF9hcHByb3ZlEgpzaG9wc19saXN0EgtsZWRnZXJfcG9zdBqU'
    'AggCEglzaG9wX3ZpZXcSC3Nob3BfY3JlYXRlEgtzaG9wX3VwZGF0ZRIMcHJvZHVjdF92aWV3Eg'
    '5wcm9kdWN0X21hbmFnZRIJY2FydF92aWV3EgtjYXJ0X21hbmFnZRIKb3JkZXJfdmlldxIMb3Jk'
    'ZXJfbWFuYWdlEg9mdWxmaWxtZW50X3ZpZXcSEWZ1bGZpbG1lbnRfbWFuYWdlEg9wcmljZV9saX'
    'N0X3ZpZXcSEXByaWNlX2xpc3RfbWFuYWdlEhdjdXN0b21lcl9wcmljZV9vdmVycmlkZRIPZGlz'
    'Y291bnRfbWFuYWdlEhBkaXNjb3VudF9hcHByb3ZlEgpzaG9wc19saXN0EgtsZWRnZXJfcG9zdB'
    'qiAQgDEglzaG9wX3ZpZXcSDHByb2R1Y3RfdmlldxIOcHJvZHVjdF9tYW5hZ2USCWNhcnRfdmll'
    'dxIKb3JkZXJfdmlldxIMb3JkZXJfbWFuYWdlEg9mdWxmaWxtZW50X3ZpZXcSEWZ1bGZpbG1lbn'
    'RfbWFuYWdlEg9wcmljZV9saXN0X3ZpZXcSD2Rpc2NvdW50X21hbmFnZRIKc2hvcHNfbGlzdBpg'
    'CAQSCXNob3BfdmlldxIMcHJvZHVjdF92aWV3EgljYXJ0X3ZpZXcSCm9yZGVyX3ZpZXcSD2Z1bG'
    'ZpbG1lbnRfdmlldxIPcHJpY2VfbGlzdF92aWV3EgpzaG9wc19saXN0GmoIBRIJc2hvcF92aWV3'
    'Egxwcm9kdWN0X3ZpZXcSCWNhcnRfdmlldxILY2FydF9tYW5hZ2USCm9yZGVyX3ZpZXcSDG9yZG'
    'VyX21hbmFnZRIPcHJpY2VfbGlzdF92aWV3EgpzaG9wc19saXN0GpQCCAYSCXNob3BfdmlldxIL'
    'c2hvcF9jcmVhdGUSC3Nob3BfdXBkYXRlEgxwcm9kdWN0X3ZpZXcSDnByb2R1Y3RfbWFuYWdlEg'
    'ljYXJ0X3ZpZXcSC2NhcnRfbWFuYWdlEgpvcmRlcl92aWV3EgxvcmRlcl9tYW5hZ2USD2Z1bGZp'
    'bG1lbnRfdmlldxIRZnVsZmlsbWVudF9tYW5hZ2USD3ByaWNlX2xpc3RfdmlldxIRcHJpY2VfbG'
    'lzdF9tYW5hZ2USF2N1c3RvbWVyX3ByaWNlX292ZXJyaWRlEg9kaXNjb3VudF9tYW5hZ2USEGRp'
    'c2NvdW50X2FwcHJvdmUSCnNob3BzX2xpc3QSC2xlZGdlcl9wb3N0');
