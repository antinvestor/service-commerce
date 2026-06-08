//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SupplierType extends $pb.ProtobufEnum {
  static const SupplierType SUPPLIER_TYPE_UNSPECIFIED = SupplierType._(0, _omitEnumNames ? '' : 'SUPPLIER_TYPE_UNSPECIFIED');
  static const SupplierType SUPPLIER_TYPE_RAW_MATERIAL = SupplierType._(1, _omitEnumNames ? '' : 'SUPPLIER_TYPE_RAW_MATERIAL');
  static const SupplierType SUPPLIER_TYPE_PACKAGING = SupplierType._(2, _omitEnumNames ? '' : 'SUPPLIER_TYPE_PACKAGING');
  static const SupplierType SUPPLIER_TYPE_SERVICE = SupplierType._(3, _omitEnumNames ? '' : 'SUPPLIER_TYPE_SERVICE');
  static const SupplierType SUPPLIER_TYPE_EQUIPMENT = SupplierType._(4, _omitEnumNames ? '' : 'SUPPLIER_TYPE_EQUIPMENT');

  static const $core.List<SupplierType> values = <SupplierType> [
    SUPPLIER_TYPE_UNSPECIFIED,
    SUPPLIER_TYPE_RAW_MATERIAL,
    SUPPLIER_TYPE_PACKAGING,
    SUPPLIER_TYPE_SERVICE,
    SUPPLIER_TYPE_EQUIPMENT,
  ];

  static final $core.Map<$core.int, SupplierType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SupplierType? valueOf($core.int value) => _byValue[value];

  const SupplierType._($core.int v, $core.String n) : super(v, n);
}

class SupplierStatus extends $pb.ProtobufEnum {
  static const SupplierStatus SUPPLIER_STATUS_UNSPECIFIED = SupplierStatus._(0, _omitEnumNames ? '' : 'SUPPLIER_STATUS_UNSPECIFIED');
  static const SupplierStatus SUPPLIER_STATUS_ACTIVE = SupplierStatus._(1, _omitEnumNames ? '' : 'SUPPLIER_STATUS_ACTIVE');
  static const SupplierStatus SUPPLIER_STATUS_SUSPENDED = SupplierStatus._(2, _omitEnumNames ? '' : 'SUPPLIER_STATUS_SUSPENDED');
  static const SupplierStatus SUPPLIER_STATUS_INACTIVE = SupplierStatus._(3, _omitEnumNames ? '' : 'SUPPLIER_STATUS_INACTIVE');

  static const $core.List<SupplierStatus> values = <SupplierStatus> [
    SUPPLIER_STATUS_UNSPECIFIED,
    SUPPLIER_STATUS_ACTIVE,
    SUPPLIER_STATUS_SUSPENDED,
    SUPPLIER_STATUS_INACTIVE,
  ];

  static final $core.Map<$core.int, SupplierStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SupplierStatus? valueOf($core.int value) => _byValue[value];

  const SupplierStatus._($core.int v, $core.String n) : super(v, n);
}

class SupplierRating extends $pb.ProtobufEnum {
  static const SupplierRating SUPPLIER_RATING_UNSPECIFIED = SupplierRating._(0, _omitEnumNames ? '' : 'SUPPLIER_RATING_UNSPECIFIED');
  static const SupplierRating SUPPLIER_RATING_UNRATED = SupplierRating._(1, _omitEnumNames ? '' : 'SUPPLIER_RATING_UNRATED');
  static const SupplierRating SUPPLIER_RATING_APPROVED = SupplierRating._(2, _omitEnumNames ? '' : 'SUPPLIER_RATING_APPROVED');
  static const SupplierRating SUPPLIER_RATING_PREFERRED = SupplierRating._(3, _omitEnumNames ? '' : 'SUPPLIER_RATING_PREFERRED');
  static const SupplierRating SUPPLIER_RATING_PROBATION = SupplierRating._(4, _omitEnumNames ? '' : 'SUPPLIER_RATING_PROBATION');

  static const $core.List<SupplierRating> values = <SupplierRating> [
    SUPPLIER_RATING_UNSPECIFIED,
    SUPPLIER_RATING_UNRATED,
    SUPPLIER_RATING_APPROVED,
    SUPPLIER_RATING_PREFERRED,
    SUPPLIER_RATING_PROBATION,
  ];

  static final $core.Map<$core.int, SupplierRating> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SupplierRating? valueOf($core.int value) => _byValue[value];

  const SupplierRating._($core.int v, $core.String n) : super(v, n);
}

class SupplierItemStatus extends $pb.ProtobufEnum {
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_UNSPECIFIED = SupplierItemStatus._(0, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_UNSPECIFIED');
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_ACTIVE = SupplierItemStatus._(1, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_ACTIVE');
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_DISCONTINUED = SupplierItemStatus._(2, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_DISCONTINUED');

  static const $core.List<SupplierItemStatus> values = <SupplierItemStatus> [
    SUPPLIER_ITEM_STATUS_UNSPECIFIED,
    SUPPLIER_ITEM_STATUS_ACTIVE,
    SUPPLIER_ITEM_STATUS_DISCONTINUED,
  ];

  static final $core.Map<$core.int, SupplierItemStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SupplierItemStatus? valueOf($core.int value) => _byValue[value];

  const SupplierItemStatus._($core.int v, $core.String n) : super(v, n);
}

class PurchaseOrderStatus extends $pb.ProtobufEnum {
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_UNSPECIFIED = PurchaseOrderStatus._(0, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_UNSPECIFIED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_DRAFT = PurchaseOrderStatus._(1, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_DRAFT');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_SUBMITTED = PurchaseOrderStatus._(2, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_SUBMITTED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_CONFIRMED = PurchaseOrderStatus._(3, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_CONFIRMED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED = PurchaseOrderStatus._(4, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_RECEIVED = PurchaseOrderStatus._(5, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_RECEIVED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_CANCELLED = PurchaseOrderStatus._(6, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_CANCELLED');

  static const $core.List<PurchaseOrderStatus> values = <PurchaseOrderStatus> [
    PURCHASE_ORDER_STATUS_UNSPECIFIED,
    PURCHASE_ORDER_STATUS_DRAFT,
    PURCHASE_ORDER_STATUS_SUBMITTED,
    PURCHASE_ORDER_STATUS_CONFIRMED,
    PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
    PURCHASE_ORDER_STATUS_RECEIVED,
    PURCHASE_ORDER_STATUS_CANCELLED,
  ];

  static final $core.Map<$core.int, PurchaseOrderStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PurchaseOrderStatus? valueOf($core.int value) => _byValue[value];

  const PurchaseOrderStatus._($core.int v, $core.String n) : super(v, n);
}

class PurchaseOrderLineStatus extends $pb.ProtobufEnum {
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED = PurchaseOrderLineStatus._(0, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_PENDING = PurchaseOrderLineStatus._(1, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_PENDING');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED = PurchaseOrderLineStatus._(2, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_RECEIVED = PurchaseOrderLineStatus._(3, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_RECEIVED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_CANCELLED = PurchaseOrderLineStatus._(4, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_CANCELLED');

  static const $core.List<PurchaseOrderLineStatus> values = <PurchaseOrderLineStatus> [
    PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED,
    PURCHASE_ORDER_LINE_STATUS_PENDING,
    PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED,
    PURCHASE_ORDER_LINE_STATUS_RECEIVED,
    PURCHASE_ORDER_LINE_STATUS_CANCELLED,
  ];

  static final $core.Map<$core.int, PurchaseOrderLineStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PurchaseOrderLineStatus? valueOf($core.int value) => _byValue[value];

  const PurchaseOrderLineStatus._($core.int v, $core.String n) : super(v, n);
}

class GoodsReceiptStatus extends $pb.ProtobufEnum {
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_UNSPECIFIED = GoodsReceiptStatus._(0, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_UNSPECIFIED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_PENDING_INSPECTION = GoodsReceiptStatus._(1, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_PENDING_INSPECTION');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_ACCEPTED = GoodsReceiptStatus._(2, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_ACCEPTED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED = GoodsReceiptStatus._(3, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_REJECTED = GoodsReceiptStatus._(4, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_REJECTED');

  static const $core.List<GoodsReceiptStatus> values = <GoodsReceiptStatus> [
    GOODS_RECEIPT_STATUS_UNSPECIFIED,
    GOODS_RECEIPT_STATUS_PENDING_INSPECTION,
    GOODS_RECEIPT_STATUS_ACCEPTED,
    GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED,
    GOODS_RECEIPT_STATUS_REJECTED,
  ];

  static final $core.Map<$core.int, GoodsReceiptStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GoodsReceiptStatus? valueOf($core.int value) => _byValue[value];

  const GoodsReceiptStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
