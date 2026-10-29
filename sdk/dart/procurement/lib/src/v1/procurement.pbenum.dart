// This is a generated file - do not edit.
//
// Generated from v1/procurement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SupplierType extends $pb.ProtobufEnum {
  static const SupplierType SUPPLIER_TYPE_UNSPECIFIED =
      SupplierType._(0, _omitEnumNames ? '' : 'SUPPLIER_TYPE_UNSPECIFIED');
  static const SupplierType SUPPLIER_TYPE_RAW_MATERIAL =
      SupplierType._(1, _omitEnumNames ? '' : 'SUPPLIER_TYPE_RAW_MATERIAL');
  static const SupplierType SUPPLIER_TYPE_PACKAGING =
      SupplierType._(2, _omitEnumNames ? '' : 'SUPPLIER_TYPE_PACKAGING');
  static const SupplierType SUPPLIER_TYPE_SERVICE =
      SupplierType._(3, _omitEnumNames ? '' : 'SUPPLIER_TYPE_SERVICE');
  static const SupplierType SUPPLIER_TYPE_EQUIPMENT =
      SupplierType._(4, _omitEnumNames ? '' : 'SUPPLIER_TYPE_EQUIPMENT');

  static const $core.List<SupplierType> values = <SupplierType>[
    SUPPLIER_TYPE_UNSPECIFIED,
    SUPPLIER_TYPE_RAW_MATERIAL,
    SUPPLIER_TYPE_PACKAGING,
    SUPPLIER_TYPE_SERVICE,
    SUPPLIER_TYPE_EQUIPMENT,
  ];

  static final $core.List<SupplierType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SupplierType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplierType._(super.value, super.name);
}

class SupplierStatus extends $pb.ProtobufEnum {
  static const SupplierStatus SUPPLIER_STATUS_UNSPECIFIED =
      SupplierStatus._(0, _omitEnumNames ? '' : 'SUPPLIER_STATUS_UNSPECIFIED');
  static const SupplierStatus SUPPLIER_STATUS_ACTIVE =
      SupplierStatus._(1, _omitEnumNames ? '' : 'SUPPLIER_STATUS_ACTIVE');
  static const SupplierStatus SUPPLIER_STATUS_SUSPENDED =
      SupplierStatus._(2, _omitEnumNames ? '' : 'SUPPLIER_STATUS_SUSPENDED');
  static const SupplierStatus SUPPLIER_STATUS_INACTIVE =
      SupplierStatus._(3, _omitEnumNames ? '' : 'SUPPLIER_STATUS_INACTIVE');

  static const $core.List<SupplierStatus> values = <SupplierStatus>[
    SUPPLIER_STATUS_UNSPECIFIED,
    SUPPLIER_STATUS_ACTIVE,
    SUPPLIER_STATUS_SUSPENDED,
    SUPPLIER_STATUS_INACTIVE,
  ];

  static final $core.List<SupplierStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SupplierStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplierStatus._(super.value, super.name);
}

class SupplierRating extends $pb.ProtobufEnum {
  static const SupplierRating SUPPLIER_RATING_UNSPECIFIED =
      SupplierRating._(0, _omitEnumNames ? '' : 'SUPPLIER_RATING_UNSPECIFIED');
  static const SupplierRating SUPPLIER_RATING_UNRATED =
      SupplierRating._(1, _omitEnumNames ? '' : 'SUPPLIER_RATING_UNRATED');
  static const SupplierRating SUPPLIER_RATING_APPROVED =
      SupplierRating._(2, _omitEnumNames ? '' : 'SUPPLIER_RATING_APPROVED');
  static const SupplierRating SUPPLIER_RATING_PREFERRED =
      SupplierRating._(3, _omitEnumNames ? '' : 'SUPPLIER_RATING_PREFERRED');
  static const SupplierRating SUPPLIER_RATING_PROBATION =
      SupplierRating._(4, _omitEnumNames ? '' : 'SUPPLIER_RATING_PROBATION');

  static const $core.List<SupplierRating> values = <SupplierRating>[
    SUPPLIER_RATING_UNSPECIFIED,
    SUPPLIER_RATING_UNRATED,
    SUPPLIER_RATING_APPROVED,
    SUPPLIER_RATING_PREFERRED,
    SUPPLIER_RATING_PROBATION,
  ];

  static final $core.List<SupplierRating?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SupplierRating? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplierRating._(super.value, super.name);
}

class SupplierItemStatus extends $pb.ProtobufEnum {
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_UNSPECIFIED =
      SupplierItemStatus._(
          0, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_UNSPECIFIED');
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_ACTIVE =
      SupplierItemStatus._(
          1, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_ACTIVE');
  static const SupplierItemStatus SUPPLIER_ITEM_STATUS_DISCONTINUED =
      SupplierItemStatus._(
          2, _omitEnumNames ? '' : 'SUPPLIER_ITEM_STATUS_DISCONTINUED');

  static const $core.List<SupplierItemStatus> values = <SupplierItemStatus>[
    SUPPLIER_ITEM_STATUS_UNSPECIFIED,
    SUPPLIER_ITEM_STATUS_ACTIVE,
    SUPPLIER_ITEM_STATUS_DISCONTINUED,
  ];

  static final $core.List<SupplierItemStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SupplierItemStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplierItemStatus._(super.value, super.name);
}

class PurchaseOrderStatus extends $pb.ProtobufEnum {
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_UNSPECIFIED =
      PurchaseOrderStatus._(
          0, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_UNSPECIFIED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_DRAFT =
      PurchaseOrderStatus._(
          1, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_DRAFT');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_SUBMITTED =
      PurchaseOrderStatus._(
          2, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_SUBMITTED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_CONFIRMED =
      PurchaseOrderStatus._(
          3, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_CONFIRMED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED =
      PurchaseOrderStatus._(
          4, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_RECEIVED =
      PurchaseOrderStatus._(
          5, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_RECEIVED');
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_CANCELLED =
      PurchaseOrderStatus._(
          6, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_CANCELLED');

  /// Partially received and closed short: nothing more will be received.
  static const PurchaseOrderStatus PURCHASE_ORDER_STATUS_CLOSED =
      PurchaseOrderStatus._(
          7, _omitEnumNames ? '' : 'PURCHASE_ORDER_STATUS_CLOSED');

  static const $core.List<PurchaseOrderStatus> values = <PurchaseOrderStatus>[
    PURCHASE_ORDER_STATUS_UNSPECIFIED,
    PURCHASE_ORDER_STATUS_DRAFT,
    PURCHASE_ORDER_STATUS_SUBMITTED,
    PURCHASE_ORDER_STATUS_CONFIRMED,
    PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
    PURCHASE_ORDER_STATUS_RECEIVED,
    PURCHASE_ORDER_STATUS_CANCELLED,
    PURCHASE_ORDER_STATUS_CLOSED,
  ];

  static final $core.List<PurchaseOrderStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static PurchaseOrderStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PurchaseOrderStatus._(super.value, super.name);
}

class PurchaseOrderLineStatus extends $pb.ProtobufEnum {
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED =
      PurchaseOrderLineStatus._(
          0, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_PENDING =
      PurchaseOrderLineStatus._(
          1, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_PENDING');
  static const PurchaseOrderLineStatus
      PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED = PurchaseOrderLineStatus._(
          2,
          _omitEnumNames
              ? ''
              : 'PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_RECEIVED =
      PurchaseOrderLineStatus._(
          3, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_RECEIVED');
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_CANCELLED =
      PurchaseOrderLineStatus._(
          4, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_CANCELLED');

  /// The order was closed short; received_quantity is final.
  static const PurchaseOrderLineStatus PURCHASE_ORDER_LINE_STATUS_CLOSED =
      PurchaseOrderLineStatus._(
          5, _omitEnumNames ? '' : 'PURCHASE_ORDER_LINE_STATUS_CLOSED');

  static const $core.List<PurchaseOrderLineStatus> values =
      <PurchaseOrderLineStatus>[
    PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED,
    PURCHASE_ORDER_LINE_STATUS_PENDING,
    PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED,
    PURCHASE_ORDER_LINE_STATUS_RECEIVED,
    PURCHASE_ORDER_LINE_STATUS_CANCELLED,
    PURCHASE_ORDER_LINE_STATUS_CLOSED,
  ];

  static final $core.List<PurchaseOrderLineStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static PurchaseOrderLineStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PurchaseOrderLineStatus._(super.value, super.name);
}

class GoodsReceiptStatus extends $pb.ProtobufEnum {
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_UNSPECIFIED =
      GoodsReceiptStatus._(
          0, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_UNSPECIFIED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_PENDING_INSPECTION =
      GoodsReceiptStatus._(
          1, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_PENDING_INSPECTION');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_ACCEPTED =
      GoodsReceiptStatus._(
          2, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_ACCEPTED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED =
      GoodsReceiptStatus._(
          3, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED');
  static const GoodsReceiptStatus GOODS_RECEIPT_STATUS_REJECTED =
      GoodsReceiptStatus._(
          4, _omitEnumNames ? '' : 'GOODS_RECEIPT_STATUS_REJECTED');

  static const $core.List<GoodsReceiptStatus> values = <GoodsReceiptStatus>[
    GOODS_RECEIPT_STATUS_UNSPECIFIED,
    GOODS_RECEIPT_STATUS_PENDING_INSPECTION,
    GOODS_RECEIPT_STATUS_ACCEPTED,
    GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED,
    GOODS_RECEIPT_STATUS_REJECTED,
  ];

  static final $core.List<GoodsReceiptStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static GoodsReceiptStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GoodsReceiptStatus._(super.value, super.name);
}

/// What a supplier item supplies, and so where its received stock lands.
class SupplyKind extends $pb.ProtobufEnum {
  static const SupplyKind SUPPLY_KIND_UNSPECIFIED =
      SupplyKind._(0, _omitEnumNames ? '' : 'SUPPLY_KIND_UNSPECIFIED');

  /// A manufacturing inventory item (raw material, packaging), named by
  /// inventory_item_id. Received stock goes to manufacturing inventory.
  static const SupplyKind SUPPLY_KIND_MATERIAL =
      SupplyKind._(1, _omitEnumNames ? '' : 'SUPPLY_KIND_MATERIAL');

  /// A commerce product variant bought for resale, named by
  /// product_variant_id. Received stock raises the variant's stock.
  static const SupplyKind SUPPLY_KIND_PRODUCT_VARIANT =
      SupplyKind._(2, _omitEnumNames ? '' : 'SUPPLY_KIND_PRODUCT_VARIANT');

  static const $core.List<SupplyKind> values = <SupplyKind>[
    SUPPLY_KIND_UNSPECIFIED,
    SUPPLY_KIND_MATERIAL,
    SUPPLY_KIND_PRODUCT_VARIANT,
  ];

  static final $core.List<SupplyKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SupplyKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplyKind._(super.value, super.name);
}

/// Whether a receipt line's stock has reached its destination.
class StockDeliveryStatus extends $pb.ProtobufEnum {
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_UNSPECIFIED =
      StockDeliveryStatus._(
          0, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_UNSPECIFIED');

  /// Waiting to be pushed; GoodsReceiptDeliver retries it.
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_PENDING =
      StockDeliveryStatus._(
          1, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_PENDING');

  /// Landed at the destination exactly once.
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_DELIVERED =
      StockDeliveryStatus._(
          2, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_DELIVERED');

  /// A raw material received without a stock location: RETRY with one to
  /// book it into manufacturing inventory, or book it there by hand.
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_PENDING_TRANSFER =
      StockDeliveryStatus._(
          3, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_PENDING_TRANSFER');

  /// The destination refused it for good (see delivery_note); needs staff.
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_FAILED =
      StockDeliveryStatus._(
          4, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_FAILED');

  /// Booked at its destination by hand and marked so by staff (see
  /// resolved_by, resolved_at and resolution_note).
  static const StockDeliveryStatus STOCK_DELIVERY_STATUS_RESOLVED =
      StockDeliveryStatus._(
          5, _omitEnumNames ? '' : 'STOCK_DELIVERY_STATUS_RESOLVED');

  static const $core.List<StockDeliveryStatus> values = <StockDeliveryStatus>[
    STOCK_DELIVERY_STATUS_UNSPECIFIED,
    STOCK_DELIVERY_STATUS_PENDING,
    STOCK_DELIVERY_STATUS_DELIVERED,
    STOCK_DELIVERY_STATUS_PENDING_TRANSFER,
    STOCK_DELIVERY_STATUS_FAILED,
    STOCK_DELIVERY_STATUS_RESOLVED,
  ];

  static final $core.List<StockDeliveryStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static StockDeliveryStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StockDeliveryStatus._(super.value, super.name);
}

/// How staff settle a receipt line that needs action.
class GoodsReceiptLineResolution extends $pb.ProtobufEnum {
  static const GoodsReceiptLineResolution
      GOODS_RECEIPT_LINE_RESOLUTION_UNSPECIFIED = GoodsReceiptLineResolution._(
          0, _omitEnumNames ? '' : 'GOODS_RECEIPT_LINE_RESOLUTION_UNSPECIFIED');

  /// The stock was booked at its destination by hand (PENDING_TRANSFER or
  /// FAILED lines); the line becomes STOCK_DELIVERY_STATUS_RESOLVED.
  static const GoodsReceiptLineResolution
      GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY =
      GoodsReceiptLineResolution._(
          1,
          _omitEnumNames
              ? ''
              : 'GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY');

  /// Try a FAILED line again, or send a PENDING_TRANSFER raw material to the
  /// location given: it goes back to PENDING and is pushed once straight
  /// away; the sweep retries it if that fails.
  static const GoodsReceiptLineResolution GOODS_RECEIPT_LINE_RESOLUTION_RETRY =
      GoodsReceiptLineResolution._(
          2, _omitEnumNames ? '' : 'GOODS_RECEIPT_LINE_RESOLUTION_RETRY');

  static const $core.List<GoodsReceiptLineResolution> values =
      <GoodsReceiptLineResolution>[
    GOODS_RECEIPT_LINE_RESOLUTION_UNSPECIFIED,
    GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY,
    GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
  ];

  static final $core.List<GoodsReceiptLineResolution?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static GoodsReceiptLineResolution? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GoodsReceiptLineResolution._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
