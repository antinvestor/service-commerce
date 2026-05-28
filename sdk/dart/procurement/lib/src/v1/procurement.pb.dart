//
//  Generated code. Do not modify.
//  source: v1/procurement.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/v1/common.pb.dart' as $8;
import '../common/v1/money.pb.dart' as $7;
import '../google/protobuf/timestamp.pb.dart' as $2;
import 'procurement.pbenum.dart';

export 'procurement.pbenum.dart';

class Supplier extends $pb.GeneratedMessage {
  factory Supplier({
    $core.String? id,
    $core.String? profileId,
    $core.String? name,
    SupplierType? supplierType,
    SupplierStatus? status,
    $core.int? paymentTermsDays,
    $core.String? currency,
    $core.int? leadTimeDays,
    SupplierRating? rating,
    $core.String? notes,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (supplierType != null) {
      $result.supplierType = supplierType;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentTermsDays != null) {
      $result.paymentTermsDays = paymentTermsDays;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (leadTimeDays != null) {
      $result.leadTimeDays = leadTimeDays;
    }
    if (rating != null) {
      $result.rating = rating;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  Supplier._() : super();
  factory Supplier.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Supplier.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Supplier', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<SupplierType>(4, _omitFieldNames ? '' : 'supplierType', $pb.PbFieldType.OE, defaultOrMaker: SupplierType.SUPPLIER_TYPE_UNSPECIFIED, valueOf: SupplierType.valueOf, enumValues: SupplierType.values)
    ..e<SupplierStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SupplierStatus.SUPPLIER_STATUS_UNSPECIFIED, valueOf: SupplierStatus.valueOf, enumValues: SupplierStatus.values)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'paymentTermsDays', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'leadTimeDays', $pb.PbFieldType.O3)
    ..e<SupplierRating>(9, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.OE, defaultOrMaker: SupplierRating.SUPPLIER_RATING_UNSPECIFIED, valueOf: SupplierRating.valueOf, enumValues: SupplierRating.values)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Supplier clone() => Supplier()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Supplier copyWith(void Function(Supplier) updates) => super.copyWith((message) => updates(message as Supplier)) as Supplier;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Supplier create() => Supplier._();
  Supplier createEmptyInstance() => create();
  static $pb.PbList<Supplier> createRepeated() => $pb.PbList<Supplier>();
  @$core.pragma('dart2js:noInline')
  static Supplier getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Supplier>(create);
  static Supplier? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  SupplierType get supplierType => $_getN(3);
  @$pb.TagNumber(4)
  set supplierType(SupplierType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSupplierType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierType() => clearField(4);

  @$pb.TagNumber(5)
  SupplierStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SupplierStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get paymentTermsDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set paymentTermsDays($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentTermsDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaymentTermsDays() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => clearField(8);

  @$pb.TagNumber(9)
  SupplierRating get rating => $_getN(8);
  @$pb.TagNumber(9)
  set rating(SupplierRating v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasRating() => $_has(8);
  @$pb.TagNumber(9)
  void clearRating() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => clearField(10);

  @$pb.TagNumber(15)
  $2.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(15)
  set createdAt($2.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $2.Timestamp ensureCreatedAt() => $_ensure(10);
}

class SupplierItem extends $pb.GeneratedMessage {
  factory SupplierItem({
    $core.String? id,
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $core.String? supplierSku,
    $7.Money? unitPrice,
    $core.double? minOrderQuantity,
    $core.String? unit,
    $core.int? leadTimeDays,
    SupplierItemStatus? status,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (supplierSku != null) {
      $result.supplierSku = supplierSku;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (minOrderQuantity != null) {
      $result.minOrderQuantity = minOrderQuantity;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    if (leadTimeDays != null) {
      $result.leadTimeDays = leadTimeDays;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  SupplierItem._() : super();
  factory SupplierItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierItem', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..aOS(3, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(4, _omitFieldNames ? '' : 'supplierSku')
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'unitPrice', subBuilder: $7.Money.create)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'minOrderQuantity', $pb.PbFieldType.OD)
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'leadTimeDays', $pb.PbFieldType.O3)
    ..e<SupplierItemStatus>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SupplierItemStatus.SUPPLIER_ITEM_STATUS_UNSPECIFIED, valueOf: SupplierItemStatus.valueOf, enumValues: SupplierItemStatus.values)
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierItem clone() => SupplierItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierItem copyWith(void Function(SupplierItem) updates) => super.copyWith((message) => updates(message as SupplierItem)) as SupplierItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierItem create() => SupplierItem._();
  SupplierItem createEmptyInstance() => create();
  static $pb.PbList<SupplierItem> createRepeated() => $pb.PbList<SupplierItem>();
  @$core.pragma('dart2js:noInline')
  static SupplierItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItem>(create);
  static SupplierItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get inventoryItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set inventoryItemId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInventoryItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInventoryItemId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get supplierSku => $_getSZ(3);
  @$pb.TagNumber(4)
  set supplierSku($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSupplierSku() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierSku() => clearField(4);

  @$pb.TagNumber(5)
  $7.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get minOrderQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set minOrderQuantity($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMinOrderQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinOrderQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => clearField(8);

  @$pb.TagNumber(9)
  SupplierItemStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SupplierItemStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);

  @$pb.TagNumber(15)
  $2.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(15)
  set createdAt($2.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $2.Timestamp ensureCreatedAt() => $_ensure(9);
}

class PurchaseOrder extends $pb.GeneratedMessage {
  factory PurchaseOrder({
    $core.String? id,
    $core.String? propertyId,
    $core.String? supplierId,
    $core.String? orderNumber,
    PurchaseOrderStatus? status,
    $2.Timestamp? expectedDeliveryDate,
    $2.Timestamp? submittedAt,
    $core.String? submittedBy,
    $7.Money? totalAmount,
    $core.String? notes,
    $core.String? planId,
    $core.Iterable<PurchaseOrderLine>? lines,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (orderNumber != null) {
      $result.orderNumber = orderNumber;
    }
    if (status != null) {
      $result.status = status;
    }
    if (expectedDeliveryDate != null) {
      $result.expectedDeliveryDate = expectedDeliveryDate;
    }
    if (submittedAt != null) {
      $result.submittedAt = submittedAt;
    }
    if (submittedBy != null) {
      $result.submittedBy = submittedBy;
    }
    if (totalAmount != null) {
      $result.totalAmount = totalAmount;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (planId != null) {
      $result.planId = planId;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  PurchaseOrder._() : super();
  factory PurchaseOrder.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrder.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrder', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierId')
    ..aOS(4, _omitFieldNames ? '' : 'orderNumber')
    ..e<PurchaseOrderStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_UNSPECIFIED, valueOf: PurchaseOrderStatus.valueOf, enumValues: PurchaseOrderStatus.values)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'expectedDeliveryDate', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'submittedAt', subBuilder: $2.Timestamp.create)
    ..aOS(8, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'totalAmount', subBuilder: $7.Money.create)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOS(11, _omitFieldNames ? '' : 'planId')
    ..pc<PurchaseOrderLine>(12, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: PurchaseOrderLine.create)
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrder clone() => PurchaseOrder()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrder copyWith(void Function(PurchaseOrder) updates) => super.copyWith((message) => updates(message as PurchaseOrder)) as PurchaseOrder;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrder create() => PurchaseOrder._();
  PurchaseOrder createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrder> createRepeated() => $pb.PbList<PurchaseOrder>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrder getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrder>(create);
  static PurchaseOrder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSupplierId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get orderNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set orderNumber($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrderNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderNumber() => clearField(4);

  @$pb.TagNumber(5)
  PurchaseOrderStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(PurchaseOrderStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get expectedDeliveryDate => $_getN(5);
  @$pb.TagNumber(6)
  set expectedDeliveryDate($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasExpectedDeliveryDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedDeliveryDate() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureExpectedDeliveryDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.Timestamp get submittedAt => $_getN(6);
  @$pb.TagNumber(7)
  set submittedAt($2.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasSubmittedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubmittedAt() => clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureSubmittedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get submittedBy => $_getSZ(7);
  @$pb.TagNumber(8)
  set submittedBy($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSubmittedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubmittedBy() => clearField(8);

  @$pb.TagNumber(9)
  $7.Money get totalAmount => $_getN(8);
  @$pb.TagNumber(9)
  set totalAmount($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasTotalAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalAmount() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensureTotalAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get planId => $_getSZ(10);
  @$pb.TagNumber(11)
  set planId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPlanId() => $_has(10);
  @$pb.TagNumber(11)
  void clearPlanId() => clearField(11);

  @$pb.TagNumber(12)
  $core.List<PurchaseOrderLine> get lines => $_getList(11);

  @$pb.TagNumber(15)
  $2.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(15)
  set createdAt($2.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $2.Timestamp ensureCreatedAt() => $_ensure(12);
}

class PurchaseOrderLine extends $pb.GeneratedMessage {
  factory PurchaseOrderLine({
    $core.String? id,
    $core.String? purchaseOrderId,
    $core.String? supplierItemId,
    $core.String? inventoryItemId,
    $core.double? orderedQuantity,
    $core.double? receivedQuantity,
    $7.Money? unitPrice,
    $core.String? unit,
    PurchaseOrderLineStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (purchaseOrderId != null) {
      $result.purchaseOrderId = purchaseOrderId;
    }
    if (supplierItemId != null) {
      $result.supplierItemId = supplierItemId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (orderedQuantity != null) {
      $result.orderedQuantity = orderedQuantity;
    }
    if (receivedQuantity != null) {
      $result.receivedQuantity = receivedQuantity;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  PurchaseOrderLine._() : super();
  factory PurchaseOrderLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierItemId')
    ..aOS(4, _omitFieldNames ? '' : 'inventoryItemId')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'orderedQuantity', $pb.PbFieldType.OD)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'receivedQuantity', $pb.PbFieldType.OD)
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'unitPrice', subBuilder: $7.Money.create)
    ..aOS(8, _omitFieldNames ? '' : 'unit')
    ..e<PurchaseOrderLineStatus>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED, valueOf: PurchaseOrderLineStatus.valueOf, enumValues: PurchaseOrderLineStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderLine clone() => PurchaseOrderLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderLine copyWith(void Function(PurchaseOrderLine) updates) => super.copyWith((message) => updates(message as PurchaseOrderLine)) as PurchaseOrderLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLine create() => PurchaseOrderLine._();
  PurchaseOrderLine createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderLine> createRepeated() => $pb.PbList<PurchaseOrderLine>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderLine>(create);
  static PurchaseOrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierItemId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSupplierItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierItemId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get inventoryItemId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inventoryItemId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasInventoryItemId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInventoryItemId() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get orderedQuantity => $_getN(4);
  @$pb.TagNumber(5)
  set orderedQuantity($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOrderedQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrderedQuantity() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get receivedQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set receivedQuantity($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReceivedQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $7.Money get unitPrice => $_getN(6);
  @$pb.TagNumber(7)
  set unitPrice($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasUnitPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnitPrice() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureUnitPrice() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get unit => $_getSZ(7);
  @$pb.TagNumber(8)
  set unit($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUnit() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnit() => clearField(8);

  @$pb.TagNumber(9)
  PurchaseOrderLineStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(PurchaseOrderLineStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);
}

class GoodsReceipt extends $pb.GeneratedMessage {
  factory GoodsReceipt({
    $core.String? id,
    $core.String? purchaseOrderId,
    $core.String? propertyId,
    $core.String? receivedBy,
    $2.Timestamp? receivedAt,
    GoodsReceiptStatus? status,
    $core.String? notes,
    $core.Iterable<GoodsReceiptLine>? lines,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (purchaseOrderId != null) {
      $result.purchaseOrderId = purchaseOrderId;
    }
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (receivedBy != null) {
      $result.receivedBy = receivedBy;
    }
    if (receivedAt != null) {
      $result.receivedAt = receivedAt;
    }
    if (status != null) {
      $result.status = status;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  GoodsReceipt._() : super();
  factory GoodsReceipt.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceipt.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceipt', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'propertyId')
    ..aOS(4, _omitFieldNames ? '' : 'receivedBy')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'receivedAt', subBuilder: $2.Timestamp.create)
    ..e<GoodsReceiptStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: GoodsReceiptStatus.GOODS_RECEIPT_STATUS_UNSPECIFIED, valueOf: GoodsReceiptStatus.valueOf, enumValues: GoodsReceiptStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..pc<GoodsReceiptLine>(8, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: GoodsReceiptLine.create)
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceipt clone() => GoodsReceipt()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceipt copyWith(void Function(GoodsReceipt) updates) => super.copyWith((message) => updates(message as GoodsReceipt)) as GoodsReceipt;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceipt create() => GoodsReceipt._();
  GoodsReceipt createEmptyInstance() => create();
  static $pb.PbList<GoodsReceipt> createRepeated() => $pb.PbList<GoodsReceipt>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceipt getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceipt>(create);
  static GoodsReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get propertyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set propertyId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPropertyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPropertyId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get receivedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set receivedBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReceivedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearReceivedBy() => clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get receivedAt => $_getN(4);
  @$pb.TagNumber(5)
  set receivedAt($2.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasReceivedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedAt() => clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureReceivedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  GoodsReceiptStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(GoodsReceiptStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<GoodsReceiptLine> get lines => $_getList(7);

  @$pb.TagNumber(15)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(15)
  set createdAt($2.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);
}

class GoodsReceiptLine extends $pb.GeneratedMessage {
  factory GoodsReceiptLine({
    $core.String? id,
    $core.String? goodsReceiptId,
    $core.String? purchaseOrderLineId,
    $core.String? inventoryItemId,
    $core.double? receivedQuantity,
    $core.double? acceptedQuantity,
    $core.double? rejectedQuantity,
    $core.String? rejectionReason,
    $core.String? lotNumber,
    $2.Timestamp? expiryDate,
    $core.String? unit,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (goodsReceiptId != null) {
      $result.goodsReceiptId = goodsReceiptId;
    }
    if (purchaseOrderLineId != null) {
      $result.purchaseOrderLineId = purchaseOrderLineId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (receivedQuantity != null) {
      $result.receivedQuantity = receivedQuantity;
    }
    if (acceptedQuantity != null) {
      $result.acceptedQuantity = acceptedQuantity;
    }
    if (rejectedQuantity != null) {
      $result.rejectedQuantity = rejectedQuantity;
    }
    if (rejectionReason != null) {
      $result.rejectionReason = rejectionReason;
    }
    if (lotNumber != null) {
      $result.lotNumber = lotNumber;
    }
    if (expiryDate != null) {
      $result.expiryDate = expiryDate;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  GoodsReceiptLine._() : super();
  factory GoodsReceiptLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'goodsReceiptId')
    ..aOS(3, _omitFieldNames ? '' : 'purchaseOrderLineId')
    ..aOS(4, _omitFieldNames ? '' : 'inventoryItemId')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'receivedQuantity', $pb.PbFieldType.OD)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'acceptedQuantity', $pb.PbFieldType.OD)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'rejectedQuantity', $pb.PbFieldType.OD)
    ..aOS(8, _omitFieldNames ? '' : 'rejectionReason')
    ..aOS(9, _omitFieldNames ? '' : 'lotNumber')
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'expiryDate', subBuilder: $2.Timestamp.create)
    ..aOS(11, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptLine clone() => GoodsReceiptLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptLine copyWith(void Function(GoodsReceiptLine) updates) => super.copyWith((message) => updates(message as GoodsReceiptLine)) as GoodsReceiptLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLine create() => GoodsReceiptLine._();
  GoodsReceiptLine createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptLine> createRepeated() => $pb.PbList<GoodsReceiptLine>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLine>(create);
  static GoodsReceiptLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get goodsReceiptId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goodsReceiptId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGoodsReceiptId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoodsReceiptId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get purchaseOrderLineId => $_getSZ(2);
  @$pb.TagNumber(3)
  set purchaseOrderLineId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPurchaseOrderLineId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPurchaseOrderLineId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get inventoryItemId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inventoryItemId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasInventoryItemId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInventoryItemId() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get receivedQuantity => $_getN(4);
  @$pb.TagNumber(5)
  set receivedQuantity($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReceivedQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedQuantity() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get acceptedQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set acceptedQuantity($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAcceptedQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearAcceptedQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get rejectedQuantity => $_getN(6);
  @$pb.TagNumber(7)
  set rejectedQuantity($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRejectedQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearRejectedQuantity() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get rejectionReason => $_getSZ(7);
  @$pb.TagNumber(8)
  set rejectionReason($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRejectionReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearRejectionReason() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get lotNumber => $_getSZ(8);
  @$pb.TagNumber(9)
  set lotNumber($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLotNumber() => $_has(8);
  @$pb.TagNumber(9)
  void clearLotNumber() => clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get expiryDate => $_getN(9);
  @$pb.TagNumber(10)
  set expiryDate($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasExpiryDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpiryDate() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureExpiryDate() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get unit => $_getSZ(10);
  @$pb.TagNumber(11)
  set unit($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasUnit() => $_has(10);
  @$pb.TagNumber(11)
  void clearUnit() => clearField(11);
}

class PurchaseOrderSuggestion extends $pb.GeneratedMessage {
  factory PurchaseOrderSuggestion({
    $core.String? supplierId,
    $core.String? supplierName,
    $core.Iterable<PurchaseOrderSuggestionLine>? lines,
    $7.Money? estimatedTotal,
  }) {
    final $result = create();
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (supplierName != null) {
      $result.supplierName = supplierName;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (estimatedTotal != null) {
      $result.estimatedTotal = estimatedTotal;
    }
    return $result;
  }
  PurchaseOrderSuggestion._() : super();
  factory PurchaseOrderSuggestion.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSuggestion.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSuggestion', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'supplierId')
    ..aOS(2, _omitFieldNames ? '' : 'supplierName')
    ..pc<PurchaseOrderSuggestionLine>(3, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: PurchaseOrderSuggestionLine.create)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'estimatedTotal', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSuggestion clone() => PurchaseOrderSuggestion()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSuggestion copyWith(void Function(PurchaseOrderSuggestion) updates) => super.copyWith((message) => updates(message as PurchaseOrderSuggestion)) as PurchaseOrderSuggestion;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestion create() => PurchaseOrderSuggestion._();
  PurchaseOrderSuggestion createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSuggestion> createRepeated() => $pb.PbList<PurchaseOrderSuggestion>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestion getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSuggestion>(create);
  static PurchaseOrderSuggestion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplierId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierName => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupplierName() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<PurchaseOrderSuggestionLine> get lines => $_getList(2);

  @$pb.TagNumber(4)
  $7.Money get estimatedTotal => $_getN(3);
  @$pb.TagNumber(4)
  set estimatedTotal($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasEstimatedTotal() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimatedTotal() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureEstimatedTotal() => $_ensure(3);
}

class PurchaseOrderSuggestionLine extends $pb.GeneratedMessage {
  factory PurchaseOrderSuggestionLine({
    $core.String? inventoryItemId,
    $core.String? itemName,
    $core.double? shortageQuantity,
    $core.String? unit,
    $core.String? supplierItemId,
    $7.Money? unitPrice,
  }) {
    final $result = create();
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (itemName != null) {
      $result.itemName = itemName;
    }
    if (shortageQuantity != null) {
      $result.shortageQuantity = shortageQuantity;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    if (supplierItemId != null) {
      $result.supplierItemId = supplierItemId;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    return $result;
  }
  PurchaseOrderSuggestionLine._() : super();
  factory PurchaseOrderSuggestionLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSuggestionLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSuggestionLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(2, _omitFieldNames ? '' : 'itemName')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'shortageQuantity', $pb.PbFieldType.OD)
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..aOS(5, _omitFieldNames ? '' : 'supplierItemId')
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'unitPrice', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSuggestionLine clone() => PurchaseOrderSuggestionLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSuggestionLine copyWith(void Function(PurchaseOrderSuggestionLine) updates) => super.copyWith((message) => updates(message as PurchaseOrderSuggestionLine)) as PurchaseOrderSuggestionLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestionLine create() => PurchaseOrderSuggestionLine._();
  PurchaseOrderSuggestionLine createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSuggestionLine> createRepeated() => $pb.PbList<PurchaseOrderSuggestionLine>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestionLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSuggestionLine>(create);
  static PurchaseOrderSuggestionLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inventoryItemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set inventoryItemId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInventoryItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInventoryItemId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get itemName => $_getSZ(1);
  @$pb.TagNumber(2)
  set itemName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasItemName() => $_has(1);
  @$pb.TagNumber(2)
  void clearItemName() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get shortageQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set shortageQuantity($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasShortageQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearShortageQuantity() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get supplierItemId => $_getSZ(4);
  @$pb.TagNumber(5)
  set supplierItemId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSupplierItemId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSupplierItemId() => clearField(5);

  @$pb.TagNumber(6)
  $7.Money get unitPrice => $_getN(5);
  @$pb.TagNumber(6)
  set unitPrice($7.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasUnitPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnitPrice() => clearField(6);
  @$pb.TagNumber(6)
  $7.Money ensureUnitPrice() => $_ensure(5);
}

class SupplierSaveRequest extends $pb.GeneratedMessage {
  factory SupplierSaveRequest({
    $core.String? id,
    $core.String? profileId,
    $core.String? name,
    SupplierType? supplierType,
    SupplierStatus? status,
    $core.int? paymentTermsDays,
    $core.String? currency,
    $core.int? leadTimeDays,
    SupplierRating? rating,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (supplierType != null) {
      $result.supplierType = supplierType;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentTermsDays != null) {
      $result.paymentTermsDays = paymentTermsDays;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (leadTimeDays != null) {
      $result.leadTimeDays = leadTimeDays;
    }
    if (rating != null) {
      $result.rating = rating;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  SupplierSaveRequest._() : super();
  factory SupplierSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<SupplierType>(4, _omitFieldNames ? '' : 'supplierType', $pb.PbFieldType.OE, defaultOrMaker: SupplierType.SUPPLIER_TYPE_UNSPECIFIED, valueOf: SupplierType.valueOf, enumValues: SupplierType.values)
    ..e<SupplierStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SupplierStatus.SUPPLIER_STATUS_UNSPECIFIED, valueOf: SupplierStatus.valueOf, enumValues: SupplierStatus.values)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'paymentTermsDays', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'leadTimeDays', $pb.PbFieldType.O3)
    ..e<SupplierRating>(9, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.OE, defaultOrMaker: SupplierRating.SUPPLIER_RATING_UNSPECIFIED, valueOf: SupplierRating.valueOf, enumValues: SupplierRating.values)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierSaveRequest clone() => SupplierSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierSaveRequest copyWith(void Function(SupplierSaveRequest) updates) => super.copyWith((message) => updates(message as SupplierSaveRequest)) as SupplierSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierSaveRequest create() => SupplierSaveRequest._();
  SupplierSaveRequest createEmptyInstance() => create();
  static $pb.PbList<SupplierSaveRequest> createRepeated() => $pb.PbList<SupplierSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static SupplierSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierSaveRequest>(create);
  static SupplierSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  SupplierType get supplierType => $_getN(3);
  @$pb.TagNumber(4)
  set supplierType(SupplierType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSupplierType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierType() => clearField(4);

  @$pb.TagNumber(5)
  SupplierStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SupplierStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get paymentTermsDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set paymentTermsDays($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentTermsDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaymentTermsDays() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => clearField(8);

  @$pb.TagNumber(9)
  SupplierRating get rating => $_getN(8);
  @$pb.TagNumber(9)
  set rating(SupplierRating v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasRating() => $_has(8);
  @$pb.TagNumber(9)
  void clearRating() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => clearField(10);
}

class SupplierSaveResponse extends $pb.GeneratedMessage {
  factory SupplierSaveResponse({
    Supplier? supplier,
  }) {
    final $result = create();
    if (supplier != null) {
      $result.supplier = supplier;
    }
    return $result;
  }
  SupplierSaveResponse._() : super();
  factory SupplierSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<Supplier>(1, _omitFieldNames ? '' : 'supplier', subBuilder: Supplier.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierSaveResponse clone() => SupplierSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierSaveResponse copyWith(void Function(SupplierSaveResponse) updates) => super.copyWith((message) => updates(message as SupplierSaveResponse)) as SupplierSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierSaveResponse create() => SupplierSaveResponse._();
  SupplierSaveResponse createEmptyInstance() => create();
  static $pb.PbList<SupplierSaveResponse> createRepeated() => $pb.PbList<SupplierSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static SupplierSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierSaveResponse>(create);
  static SupplierSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Supplier get supplier => $_getN(0);
  @$pb.TagNumber(1)
  set supplier(Supplier v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplier() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplier() => clearField(1);
  @$pb.TagNumber(1)
  Supplier ensureSupplier() => $_ensure(0);
}

class SupplierGetRequest extends $pb.GeneratedMessage {
  factory SupplierGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  SupplierGetRequest._() : super();
  factory SupplierGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierGetRequest clone() => SupplierGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierGetRequest copyWith(void Function(SupplierGetRequest) updates) => super.copyWith((message) => updates(message as SupplierGetRequest)) as SupplierGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierGetRequest create() => SupplierGetRequest._();
  SupplierGetRequest createEmptyInstance() => create();
  static $pb.PbList<SupplierGetRequest> createRepeated() => $pb.PbList<SupplierGetRequest>();
  @$core.pragma('dart2js:noInline')
  static SupplierGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierGetRequest>(create);
  static SupplierGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class SupplierGetResponse extends $pb.GeneratedMessage {
  factory SupplierGetResponse({
    Supplier? supplier,
  }) {
    final $result = create();
    if (supplier != null) {
      $result.supplier = supplier;
    }
    return $result;
  }
  SupplierGetResponse._() : super();
  factory SupplierGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<Supplier>(1, _omitFieldNames ? '' : 'supplier', subBuilder: Supplier.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierGetResponse clone() => SupplierGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierGetResponse copyWith(void Function(SupplierGetResponse) updates) => super.copyWith((message) => updates(message as SupplierGetResponse)) as SupplierGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierGetResponse create() => SupplierGetResponse._();
  SupplierGetResponse createEmptyInstance() => create();
  static $pb.PbList<SupplierGetResponse> createRepeated() => $pb.PbList<SupplierGetResponse>();
  @$core.pragma('dart2js:noInline')
  static SupplierGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierGetResponse>(create);
  static SupplierGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Supplier get supplier => $_getN(0);
  @$pb.TagNumber(1)
  set supplier(Supplier v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplier() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplier() => clearField(1);
  @$pb.TagNumber(1)
  Supplier ensureSupplier() => $_ensure(0);
}

class SupplierSearchRequest extends $pb.GeneratedMessage {
  factory SupplierSearchRequest({
    $8.SearchRequest? search,
    SupplierType? supplierType,
    SupplierStatus? status,
  }) {
    final $result = create();
    if (search != null) {
      $result.search = search;
    }
    if (supplierType != null) {
      $result.supplierType = supplierType;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  SupplierSearchRequest._() : super();
  factory SupplierSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<$8.SearchRequest>(1, _omitFieldNames ? '' : 'search', subBuilder: $8.SearchRequest.create)
    ..e<SupplierType>(2, _omitFieldNames ? '' : 'supplierType', $pb.PbFieldType.OE, defaultOrMaker: SupplierType.SUPPLIER_TYPE_UNSPECIFIED, valueOf: SupplierType.valueOf, enumValues: SupplierType.values)
    ..e<SupplierStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SupplierStatus.SUPPLIER_STATUS_UNSPECIFIED, valueOf: SupplierStatus.valueOf, enumValues: SupplierStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierSearchRequest clone() => SupplierSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierSearchRequest copyWith(void Function(SupplierSearchRequest) updates) => super.copyWith((message) => updates(message as SupplierSearchRequest)) as SupplierSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierSearchRequest create() => SupplierSearchRequest._();
  SupplierSearchRequest createEmptyInstance() => create();
  static $pb.PbList<SupplierSearchRequest> createRepeated() => $pb.PbList<SupplierSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static SupplierSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierSearchRequest>(create);
  static SupplierSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $8.SearchRequest get search => $_getN(0);
  @$pb.TagNumber(1)
  set search($8.SearchRequest v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSearch() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearch() => clearField(1);
  @$pb.TagNumber(1)
  $8.SearchRequest ensureSearch() => $_ensure(0);

  @$pb.TagNumber(2)
  SupplierType get supplierType => $_getN(1);
  @$pb.TagNumber(2)
  set supplierType(SupplierType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupplierType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierType() => clearField(2);

  @$pb.TagNumber(3)
  SupplierStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(SupplierStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);
}

class SupplierSearchResponse extends $pb.GeneratedMessage {
  factory SupplierSearchResponse({
    $core.Iterable<Supplier>? suppliers,
    $core.String? nextPage,
  }) {
    final $result = create();
    if (suppliers != null) {
      $result.suppliers.addAll(suppliers);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    return $result;
  }
  SupplierSearchResponse._() : super();
  factory SupplierSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..pc<Supplier>(1, _omitFieldNames ? '' : 'suppliers', $pb.PbFieldType.PM, subBuilder: Supplier.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierSearchResponse clone() => SupplierSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierSearchResponse copyWith(void Function(SupplierSearchResponse) updates) => super.copyWith((message) => updates(message as SupplierSearchResponse)) as SupplierSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierSearchResponse create() => SupplierSearchResponse._();
  SupplierSearchResponse createEmptyInstance() => create();
  static $pb.PbList<SupplierSearchResponse> createRepeated() => $pb.PbList<SupplierSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static SupplierSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierSearchResponse>(create);
  static SupplierSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Supplier> get suppliers => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);
}

class SupplierItemSaveRequest extends $pb.GeneratedMessage {
  factory SupplierItemSaveRequest({
    $core.String? id,
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $core.String? supplierSku,
    $7.Money? unitPrice,
    $core.double? minOrderQuantity,
    $core.String? unit,
    $core.int? leadTimeDays,
    SupplierItemStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (supplierSku != null) {
      $result.supplierSku = supplierSku;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (minOrderQuantity != null) {
      $result.minOrderQuantity = minOrderQuantity;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    if (leadTimeDays != null) {
      $result.leadTimeDays = leadTimeDays;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  SupplierItemSaveRequest._() : super();
  factory SupplierItemSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierItemSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierItemSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..aOS(3, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(4, _omitFieldNames ? '' : 'supplierSku')
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'unitPrice', subBuilder: $7.Money.create)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'minOrderQuantity', $pb.PbFieldType.OD)
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'leadTimeDays', $pb.PbFieldType.O3)
    ..e<SupplierItemStatus>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SupplierItemStatus.SUPPLIER_ITEM_STATUS_UNSPECIFIED, valueOf: SupplierItemStatus.valueOf, enumValues: SupplierItemStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierItemSaveRequest clone() => SupplierItemSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierItemSaveRequest copyWith(void Function(SupplierItemSaveRequest) updates) => super.copyWith((message) => updates(message as SupplierItemSaveRequest)) as SupplierItemSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveRequest create() => SupplierItemSaveRequest._();
  SupplierItemSaveRequest createEmptyInstance() => create();
  static $pb.PbList<SupplierItemSaveRequest> createRepeated() => $pb.PbList<SupplierItemSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItemSaveRequest>(create);
  static SupplierItemSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get inventoryItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set inventoryItemId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInventoryItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInventoryItemId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get supplierSku => $_getSZ(3);
  @$pb.TagNumber(4)
  set supplierSku($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSupplierSku() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierSku() => clearField(4);

  @$pb.TagNumber(5)
  $7.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get minOrderQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set minOrderQuantity($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMinOrderQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinOrderQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => clearField(8);

  @$pb.TagNumber(9)
  SupplierItemStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SupplierItemStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);
}

class SupplierItemSaveResponse extends $pb.GeneratedMessage {
  factory SupplierItemSaveResponse({
    SupplierItem? supplierItem,
  }) {
    final $result = create();
    if (supplierItem != null) {
      $result.supplierItem = supplierItem;
    }
    return $result;
  }
  SupplierItemSaveResponse._() : super();
  factory SupplierItemSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierItemSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierItemSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<SupplierItem>(1, _omitFieldNames ? '' : 'supplierItem', subBuilder: SupplierItem.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierItemSaveResponse clone() => SupplierItemSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierItemSaveResponse copyWith(void Function(SupplierItemSaveResponse) updates) => super.copyWith((message) => updates(message as SupplierItemSaveResponse)) as SupplierItemSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveResponse create() => SupplierItemSaveResponse._();
  SupplierItemSaveResponse createEmptyInstance() => create();
  static $pb.PbList<SupplierItemSaveResponse> createRepeated() => $pb.PbList<SupplierItemSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItemSaveResponse>(create);
  static SupplierItemSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SupplierItem get supplierItem => $_getN(0);
  @$pb.TagNumber(1)
  set supplierItem(SupplierItem v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplierItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierItem() => clearField(1);
  @$pb.TagNumber(1)
  SupplierItem ensureSupplierItem() => $_ensure(0);
}

class SupplierItemSearchRequest extends $pb.GeneratedMessage {
  factory SupplierItemSearchRequest({
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $8.SearchRequest? search,
  }) {
    final $result = create();
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  SupplierItemSearchRequest._() : super();
  factory SupplierItemSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierItemSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierItemSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'supplierId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOM<$8.SearchRequest>(3, _omitFieldNames ? '' : 'search', subBuilder: $8.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierItemSearchRequest clone() => SupplierItemSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierItemSearchRequest copyWith(void Function(SupplierItemSearchRequest) updates) => super.copyWith((message) => updates(message as SupplierItemSearchRequest)) as SupplierItemSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchRequest create() => SupplierItemSearchRequest._();
  SupplierItemSearchRequest createEmptyInstance() => create();
  static $pb.PbList<SupplierItemSearchRequest> createRepeated() => $pb.PbList<SupplierItemSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItemSearchRequest>(create);
  static SupplierItemSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplierId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => clearField(2);

  @$pb.TagNumber(3)
  $8.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($8.SearchRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => clearField(3);
  @$pb.TagNumber(3)
  $8.SearchRequest ensureSearch() => $_ensure(2);
}

class SupplierItemSearchResponse extends $pb.GeneratedMessage {
  factory SupplierItemSearchResponse({
    $core.Iterable<SupplierItem>? supplierItems,
    $core.String? nextPage,
  }) {
    final $result = create();
    if (supplierItems != null) {
      $result.supplierItems.addAll(supplierItems);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    return $result;
  }
  SupplierItemSearchResponse._() : super();
  factory SupplierItemSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplierItemSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplierItemSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..pc<SupplierItem>(1, _omitFieldNames ? '' : 'supplierItems', $pb.PbFieldType.PM, subBuilder: SupplierItem.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplierItemSearchResponse clone() => SupplierItemSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplierItemSearchResponse copyWith(void Function(SupplierItemSearchResponse) updates) => super.copyWith((message) => updates(message as SupplierItemSearchResponse)) as SupplierItemSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchResponse create() => SupplierItemSearchResponse._();
  SupplierItemSearchResponse createEmptyInstance() => create();
  static $pb.PbList<SupplierItemSearchResponse> createRepeated() => $pb.PbList<SupplierItemSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItemSearchResponse>(create);
  static SupplierItemSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SupplierItem> get supplierItems => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);
}

class PurchaseOrderCreateRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderCreateRequest({
    $core.String? idempotencyKey,
    $core.String? propertyId,
    $core.String? supplierId,
    $2.Timestamp? expectedDeliveryDate,
    $core.String? notes,
    $core.String? planId,
    $core.Iterable<PurchaseOrderLineInput>? lines,
  }) {
    final $result = create();
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (expectedDeliveryDate != null) {
      $result.expectedDeliveryDate = expectedDeliveryDate;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (planId != null) {
      $result.planId = planId;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    return $result;
  }
  PurchaseOrderCreateRequest._() : super();
  factory PurchaseOrderCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierId')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'expectedDeliveryDate', subBuilder: $2.Timestamp.create)
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..aOS(6, _omitFieldNames ? '' : 'planId')
    ..pc<PurchaseOrderLineInput>(7, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: PurchaseOrderLineInput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderCreateRequest clone() => PurchaseOrderCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderCreateRequest copyWith(void Function(PurchaseOrderCreateRequest) updates) => super.copyWith((message) => updates(message as PurchaseOrderCreateRequest)) as PurchaseOrderCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateRequest create() => PurchaseOrderCreateRequest._();
  PurchaseOrderCreateRequest createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderCreateRequest> createRepeated() => $pb.PbList<PurchaseOrderCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCreateRequest>(create);
  static PurchaseOrderCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get idempotencyKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set idempotencyKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIdempotencyKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdempotencyKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSupplierId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierId() => clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get expectedDeliveryDate => $_getN(3);
  @$pb.TagNumber(4)
  set expectedDeliveryDate($2.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasExpectedDeliveryDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedDeliveryDate() => clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureExpectedDeliveryDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get planId => $_getSZ(5);
  @$pb.TagNumber(6)
  set planId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPlanId() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlanId() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<PurchaseOrderLineInput> get lines => $_getList(6);
}

class PurchaseOrderLineInput extends $pb.GeneratedMessage {
  factory PurchaseOrderLineInput({
    $core.String? supplierItemId,
    $core.String? inventoryItemId,
    $core.double? orderedQuantity,
    $core.String? unit,
  }) {
    final $result = create();
    if (supplierItemId != null) {
      $result.supplierItemId = supplierItemId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (orderedQuantity != null) {
      $result.orderedQuantity = orderedQuantity;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  PurchaseOrderLineInput._() : super();
  factory PurchaseOrderLineInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderLineInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderLineInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'supplierItemId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'orderedQuantity', $pb.PbFieldType.OD)
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderLineInput clone() => PurchaseOrderLineInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderLineInput copyWith(void Function(PurchaseOrderLineInput) updates) => super.copyWith((message) => updates(message as PurchaseOrderLineInput)) as PurchaseOrderLineInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLineInput create() => PurchaseOrderLineInput._();
  PurchaseOrderLineInput createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderLineInput> createRepeated() => $pb.PbList<PurchaseOrderLineInput>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLineInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderLineInput>(create);
  static PurchaseOrderLineInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierItemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierItemId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSupplierItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierItemId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get orderedQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set orderedQuantity($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrderedQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderedQuantity() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => clearField(4);
}

class PurchaseOrderCreateResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderCreateResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final $result = create();
    if (purchaseOrder != null) {
      $result.purchaseOrder = purchaseOrder;
    }
    return $result;
  }
  PurchaseOrderCreateResponse._() : super();
  factory PurchaseOrderCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder', subBuilder: PurchaseOrder.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderCreateResponse clone() => PurchaseOrderCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderCreateResponse copyWith(void Function(PurchaseOrderCreateResponse) updates) => super.copyWith((message) => updates(message as PurchaseOrderCreateResponse)) as PurchaseOrderCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateResponse create() => PurchaseOrderCreateResponse._();
  PurchaseOrderCreateResponse createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderCreateResponse> createRepeated() => $pb.PbList<PurchaseOrderCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCreateResponse>(create);
  static PurchaseOrderCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderGetRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PurchaseOrderGetRequest._() : super();
  factory PurchaseOrderGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderGetRequest clone() => PurchaseOrderGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderGetRequest copyWith(void Function(PurchaseOrderGetRequest) updates) => super.copyWith((message) => updates(message as PurchaseOrderGetRequest)) as PurchaseOrderGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetRequest create() => PurchaseOrderGetRequest._();
  PurchaseOrderGetRequest createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderGetRequest> createRepeated() => $pb.PbList<PurchaseOrderGetRequest>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderGetRequest>(create);
  static PurchaseOrderGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PurchaseOrderGetResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderGetResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final $result = create();
    if (purchaseOrder != null) {
      $result.purchaseOrder = purchaseOrder;
    }
    return $result;
  }
  PurchaseOrderGetResponse._() : super();
  factory PurchaseOrderGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder', subBuilder: PurchaseOrder.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderGetResponse clone() => PurchaseOrderGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderGetResponse copyWith(void Function(PurchaseOrderGetResponse) updates) => super.copyWith((message) => updates(message as PurchaseOrderGetResponse)) as PurchaseOrderGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetResponse create() => PurchaseOrderGetResponse._();
  PurchaseOrderGetResponse createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderGetResponse> createRepeated() => $pb.PbList<PurchaseOrderGetResponse>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderGetResponse>(create);
  static PurchaseOrderGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderSearchRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderSearchRequest({
    $core.String? propertyId,
    $core.String? supplierId,
    PurchaseOrderStatus? status,
    $8.SearchRequest? search,
  }) {
    final $result = create();
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (supplierId != null) {
      $result.supplierId = supplierId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  PurchaseOrderSearchRequest._() : super();
  factory PurchaseOrderSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'propertyId')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..e<PurchaseOrderStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PurchaseOrderStatus.PURCHASE_ORDER_STATUS_UNSPECIFIED, valueOf: PurchaseOrderStatus.valueOf, enumValues: PurchaseOrderStatus.values)
    ..aOM<$8.SearchRequest>(4, _omitFieldNames ? '' : 'search', subBuilder: $8.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSearchRequest clone() => PurchaseOrderSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSearchRequest copyWith(void Function(PurchaseOrderSearchRequest) updates) => super.copyWith((message) => updates(message as PurchaseOrderSearchRequest)) as PurchaseOrderSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchRequest create() => PurchaseOrderSearchRequest._();
  PurchaseOrderSearchRequest createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSearchRequest> createRepeated() => $pb.PbList<PurchaseOrderSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSearchRequest>(create);
  static PurchaseOrderSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get propertyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set propertyId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPropertyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPropertyId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => clearField(2);

  @$pb.TagNumber(3)
  PurchaseOrderStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(PurchaseOrderStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $8.SearchRequest get search => $_getN(3);
  @$pb.TagNumber(4)
  set search($8.SearchRequest v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSearch() => $_has(3);
  @$pb.TagNumber(4)
  void clearSearch() => clearField(4);
  @$pb.TagNumber(4)
  $8.SearchRequest ensureSearch() => $_ensure(3);
}

class PurchaseOrderSearchResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderSearchResponse({
    $core.Iterable<PurchaseOrder>? purchaseOrders,
    $core.String? nextPage,
  }) {
    final $result = create();
    if (purchaseOrders != null) {
      $result.purchaseOrders.addAll(purchaseOrders);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    return $result;
  }
  PurchaseOrderSearchResponse._() : super();
  factory PurchaseOrderSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..pc<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrders', $pb.PbFieldType.PM, subBuilder: PurchaseOrder.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSearchResponse clone() => PurchaseOrderSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSearchResponse copyWith(void Function(PurchaseOrderSearchResponse) updates) => super.copyWith((message) => updates(message as PurchaseOrderSearchResponse)) as PurchaseOrderSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchResponse create() => PurchaseOrderSearchResponse._();
  PurchaseOrderSearchResponse createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSearchResponse> createRepeated() => $pb.PbList<PurchaseOrderSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSearchResponse>(create);
  static PurchaseOrderSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PurchaseOrder> get purchaseOrders => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);
}

class PurchaseOrderSubmitRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderSubmitRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PurchaseOrderSubmitRequest._() : super();
  factory PurchaseOrderSubmitRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSubmitRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSubmitRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSubmitRequest clone() => PurchaseOrderSubmitRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSubmitRequest copyWith(void Function(PurchaseOrderSubmitRequest) updates) => super.copyWith((message) => updates(message as PurchaseOrderSubmitRequest)) as PurchaseOrderSubmitRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitRequest create() => PurchaseOrderSubmitRequest._();
  PurchaseOrderSubmitRequest createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSubmitRequest> createRepeated() => $pb.PbList<PurchaseOrderSubmitRequest>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSubmitRequest>(create);
  static PurchaseOrderSubmitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PurchaseOrderSubmitResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderSubmitResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final $result = create();
    if (purchaseOrder != null) {
      $result.purchaseOrder = purchaseOrder;
    }
    return $result;
  }
  PurchaseOrderSubmitResponse._() : super();
  factory PurchaseOrderSubmitResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderSubmitResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderSubmitResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder', subBuilder: PurchaseOrder.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderSubmitResponse clone() => PurchaseOrderSubmitResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderSubmitResponse copyWith(void Function(PurchaseOrderSubmitResponse) updates) => super.copyWith((message) => updates(message as PurchaseOrderSubmitResponse)) as PurchaseOrderSubmitResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitResponse create() => PurchaseOrderSubmitResponse._();
  PurchaseOrderSubmitResponse createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderSubmitResponse> createRepeated() => $pb.PbList<PurchaseOrderSubmitResponse>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSubmitResponse>(create);
  static PurchaseOrderSubmitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderCancelRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  PurchaseOrderCancelRequest._() : super();
  factory PurchaseOrderCancelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderCancelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderCancelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderCancelRequest clone() => PurchaseOrderCancelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderCancelRequest copyWith(void Function(PurchaseOrderCancelRequest) updates) => super.copyWith((message) => updates(message as PurchaseOrderCancelRequest)) as PurchaseOrderCancelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelRequest create() => PurchaseOrderCancelRequest._();
  PurchaseOrderCancelRequest createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderCancelRequest> createRepeated() => $pb.PbList<PurchaseOrderCancelRequest>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCancelRequest>(create);
  static PurchaseOrderCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class PurchaseOrderCancelResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderCancelResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final $result = create();
    if (purchaseOrder != null) {
      $result.purchaseOrder = purchaseOrder;
    }
    return $result;
  }
  PurchaseOrderCancelResponse._() : super();
  factory PurchaseOrderCancelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PurchaseOrderCancelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PurchaseOrderCancelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder', subBuilder: PurchaseOrder.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PurchaseOrderCancelResponse clone() => PurchaseOrderCancelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PurchaseOrderCancelResponse copyWith(void Function(PurchaseOrderCancelResponse) updates) => super.copyWith((message) => updates(message as PurchaseOrderCancelResponse)) as PurchaseOrderCancelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelResponse create() => PurchaseOrderCancelResponse._();
  PurchaseOrderCancelResponse createEmptyInstance() => create();
  static $pb.PbList<PurchaseOrderCancelResponse> createRepeated() => $pb.PbList<PurchaseOrderCancelResponse>();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCancelResponse>(create);
  static PurchaseOrderCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class GoodsReceiptCreateRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptCreateRequest({
    $core.String? idempotencyKey,
    $core.String? purchaseOrderId,
    $core.String? propertyId,
    $core.String? notes,
    $core.Iterable<GoodsReceiptLineInput>? lines,
  }) {
    final $result = create();
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (purchaseOrderId != null) {
      $result.purchaseOrderId = purchaseOrderId;
    }
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    return $result;
  }
  GoodsReceiptCreateRequest._() : super();
  factory GoodsReceiptCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'propertyId')
    ..aOS(4, _omitFieldNames ? '' : 'notes')
    ..pc<GoodsReceiptLineInput>(5, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: GoodsReceiptLineInput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptCreateRequest clone() => GoodsReceiptCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptCreateRequest copyWith(void Function(GoodsReceiptCreateRequest) updates) => super.copyWith((message) => updates(message as GoodsReceiptCreateRequest)) as GoodsReceiptCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateRequest create() => GoodsReceiptCreateRequest._();
  GoodsReceiptCreateRequest createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptCreateRequest> createRepeated() => $pb.PbList<GoodsReceiptCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptCreateRequest>(create);
  static GoodsReceiptCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get idempotencyKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set idempotencyKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIdempotencyKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdempotencyKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get propertyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set propertyId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPropertyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPropertyId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get notes => $_getSZ(3);
  @$pb.TagNumber(4)
  set notes($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNotes() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotes() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<GoodsReceiptLineInput> get lines => $_getList(4);
}

class GoodsReceiptLineInput extends $pb.GeneratedMessage {
  factory GoodsReceiptLineInput({
    $core.String? purchaseOrderLineId,
    $core.String? inventoryItemId,
    $core.double? receivedQuantity,
    $core.String? lotNumber,
    $2.Timestamp? expiryDate,
    $core.String? unit,
  }) {
    final $result = create();
    if (purchaseOrderLineId != null) {
      $result.purchaseOrderLineId = purchaseOrderLineId;
    }
    if (inventoryItemId != null) {
      $result.inventoryItemId = inventoryItemId;
    }
    if (receivedQuantity != null) {
      $result.receivedQuantity = receivedQuantity;
    }
    if (lotNumber != null) {
      $result.lotNumber = lotNumber;
    }
    if (expiryDate != null) {
      $result.expiryDate = expiryDate;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  GoodsReceiptLineInput._() : super();
  factory GoodsReceiptLineInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptLineInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptLineInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'purchaseOrderLineId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'receivedQuantity', $pb.PbFieldType.OD)
    ..aOS(4, _omitFieldNames ? '' : 'lotNumber')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'expiryDate', subBuilder: $2.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptLineInput clone() => GoodsReceiptLineInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptLineInput copyWith(void Function(GoodsReceiptLineInput) updates) => super.copyWith((message) => updates(message as GoodsReceiptLineInput)) as GoodsReceiptLineInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLineInput create() => GoodsReceiptLineInput._();
  GoodsReceiptLineInput createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptLineInput> createRepeated() => $pb.PbList<GoodsReceiptLineInput>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLineInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLineInput>(create);
  static GoodsReceiptLineInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get purchaseOrderLineId => $_getSZ(0);
  @$pb.TagNumber(1)
  set purchaseOrderLineId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrderLineId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrderLineId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get receivedQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set receivedQuantity($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReceivedQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedQuantity() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get lotNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set lotNumber($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLotNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearLotNumber() => clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get expiryDate => $_getN(4);
  @$pb.TagNumber(5)
  set expiryDate($2.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiryDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiryDate() => clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureExpiryDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get unit => $_getSZ(5);
  @$pb.TagNumber(6)
  set unit($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUnit() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnit() => clearField(6);
}

class GoodsReceiptCreateResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptCreateResponse({
    GoodsReceipt? goodsReceipt,
  }) {
    final $result = create();
    if (goodsReceipt != null) {
      $result.goodsReceipt = goodsReceipt;
    }
    return $result;
  }
  GoodsReceiptCreateResponse._() : super();
  factory GoodsReceiptCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipt', subBuilder: GoodsReceipt.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptCreateResponse clone() => GoodsReceiptCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptCreateResponse copyWith(void Function(GoodsReceiptCreateResponse) updates) => super.copyWith((message) => updates(message as GoodsReceiptCreateResponse)) as GoodsReceiptCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateResponse create() => GoodsReceiptCreateResponse._();
  GoodsReceiptCreateResponse createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptCreateResponse> createRepeated() => $pb.PbList<GoodsReceiptCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptCreateResponse>(create);
  static GoodsReceiptCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GoodsReceipt get goodsReceipt => $_getN(0);
  @$pb.TagNumber(1)
  set goodsReceipt(GoodsReceipt v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceipt() => clearField(1);
  @$pb.TagNumber(1)
  GoodsReceipt ensureGoodsReceipt() => $_ensure(0);
}

class GoodsReceiptGetRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GoodsReceiptGetRequest._() : super();
  factory GoodsReceiptGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptGetRequest clone() => GoodsReceiptGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptGetRequest copyWith(void Function(GoodsReceiptGetRequest) updates) => super.copyWith((message) => updates(message as GoodsReceiptGetRequest)) as GoodsReceiptGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetRequest create() => GoodsReceiptGetRequest._();
  GoodsReceiptGetRequest createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptGetRequest> createRepeated() => $pb.PbList<GoodsReceiptGetRequest>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptGetRequest>(create);
  static GoodsReceiptGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GoodsReceiptGetResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptGetResponse({
    GoodsReceipt? goodsReceipt,
  }) {
    final $result = create();
    if (goodsReceipt != null) {
      $result.goodsReceipt = goodsReceipt;
    }
    return $result;
  }
  GoodsReceiptGetResponse._() : super();
  factory GoodsReceiptGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipt', subBuilder: GoodsReceipt.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptGetResponse clone() => GoodsReceiptGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptGetResponse copyWith(void Function(GoodsReceiptGetResponse) updates) => super.copyWith((message) => updates(message as GoodsReceiptGetResponse)) as GoodsReceiptGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetResponse create() => GoodsReceiptGetResponse._();
  GoodsReceiptGetResponse createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptGetResponse> createRepeated() => $pb.PbList<GoodsReceiptGetResponse>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptGetResponse>(create);
  static GoodsReceiptGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GoodsReceipt get goodsReceipt => $_getN(0);
  @$pb.TagNumber(1)
  set goodsReceipt(GoodsReceipt v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceipt() => clearField(1);
  @$pb.TagNumber(1)
  GoodsReceipt ensureGoodsReceipt() => $_ensure(0);
}

class GoodsReceiptSearchRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptSearchRequest({
    $core.String? purchaseOrderId,
    $core.String? propertyId,
    GoodsReceiptStatus? status,
    $8.SearchRequest? search,
  }) {
    final $result = create();
    if (purchaseOrderId != null) {
      $result.purchaseOrderId = purchaseOrderId;
    }
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  GoodsReceiptSearchRequest._() : super();
  factory GoodsReceiptSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..e<GoodsReceiptStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: GoodsReceiptStatus.GOODS_RECEIPT_STATUS_UNSPECIFIED, valueOf: GoodsReceiptStatus.valueOf, enumValues: GoodsReceiptStatus.values)
    ..aOM<$8.SearchRequest>(4, _omitFieldNames ? '' : 'search', subBuilder: $8.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptSearchRequest clone() => GoodsReceiptSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptSearchRequest copyWith(void Function(GoodsReceiptSearchRequest) updates) => super.copyWith((message) => updates(message as GoodsReceiptSearchRequest)) as GoodsReceiptSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchRequest create() => GoodsReceiptSearchRequest._();
  GoodsReceiptSearchRequest createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptSearchRequest> createRepeated() => $pb.PbList<GoodsReceiptSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptSearchRequest>(create);
  static GoodsReceiptSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get purchaseOrderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set purchaseOrderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrderId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => clearField(2);

  @$pb.TagNumber(3)
  GoodsReceiptStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(GoodsReceiptStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $8.SearchRequest get search => $_getN(3);
  @$pb.TagNumber(4)
  set search($8.SearchRequest v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSearch() => $_has(3);
  @$pb.TagNumber(4)
  void clearSearch() => clearField(4);
  @$pb.TagNumber(4)
  $8.SearchRequest ensureSearch() => $_ensure(3);
}

class GoodsReceiptSearchResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptSearchResponse({
    $core.Iterable<GoodsReceipt>? goodsReceipts,
    $core.String? nextPage,
  }) {
    final $result = create();
    if (goodsReceipts != null) {
      $result.goodsReceipts.addAll(goodsReceipts);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    return $result;
  }
  GoodsReceiptSearchResponse._() : super();
  factory GoodsReceiptSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GoodsReceiptSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GoodsReceiptSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..pc<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipts', $pb.PbFieldType.PM, subBuilder: GoodsReceipt.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GoodsReceiptSearchResponse clone() => GoodsReceiptSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GoodsReceiptSearchResponse copyWith(void Function(GoodsReceiptSearchResponse) updates) => super.copyWith((message) => updates(message as GoodsReceiptSearchResponse)) as GoodsReceiptSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchResponse create() => GoodsReceiptSearchResponse._();
  GoodsReceiptSearchResponse createEmptyInstance() => create();
  static $pb.PbList<GoodsReceiptSearchResponse> createRepeated() => $pb.PbList<GoodsReceiptSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptSearchResponse>(create);
  static GoodsReceiptSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GoodsReceipt> get goodsReceipts => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);
}

class SuggestPurchaseOrdersRequest extends $pb.GeneratedMessage {
  factory SuggestPurchaseOrdersRequest({
    $core.String? propertyId,
    $core.String? planId,
  }) {
    final $result = create();
    if (propertyId != null) {
      $result.propertyId = propertyId;
    }
    if (planId != null) {
      $result.planId = planId;
    }
    return $result;
  }
  SuggestPurchaseOrdersRequest._() : super();
  factory SuggestPurchaseOrdersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SuggestPurchaseOrdersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SuggestPurchaseOrdersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'propertyId')
    ..aOS(2, _omitFieldNames ? '' : 'planId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SuggestPurchaseOrdersRequest clone() => SuggestPurchaseOrdersRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SuggestPurchaseOrdersRequest copyWith(void Function(SuggestPurchaseOrdersRequest) updates) => super.copyWith((message) => updates(message as SuggestPurchaseOrdersRequest)) as SuggestPurchaseOrdersRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersRequest create() => SuggestPurchaseOrdersRequest._();
  SuggestPurchaseOrdersRequest createEmptyInstance() => create();
  static $pb.PbList<SuggestPurchaseOrdersRequest> createRepeated() => $pb.PbList<SuggestPurchaseOrdersRequest>();
  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SuggestPurchaseOrdersRequest>(create);
  static SuggestPurchaseOrdersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get propertyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set propertyId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPropertyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPropertyId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get planId => $_getSZ(1);
  @$pb.TagNumber(2)
  set planId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPlanId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlanId() => clearField(2);
}

class SuggestPurchaseOrdersResponse extends $pb.GeneratedMessage {
  factory SuggestPurchaseOrdersResponse({
    $core.Iterable<PurchaseOrderSuggestion>? suggestions,
  }) {
    final $result = create();
    if (suggestions != null) {
      $result.suggestions.addAll(suggestions);
    }
    return $result;
  }
  SuggestPurchaseOrdersResponse._() : super();
  factory SuggestPurchaseOrdersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SuggestPurchaseOrdersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SuggestPurchaseOrdersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'), createEmptyInstance: create)
    ..pc<PurchaseOrderSuggestion>(1, _omitFieldNames ? '' : 'suggestions', $pb.PbFieldType.PM, subBuilder: PurchaseOrderSuggestion.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SuggestPurchaseOrdersResponse clone() => SuggestPurchaseOrdersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SuggestPurchaseOrdersResponse copyWith(void Function(SuggestPurchaseOrdersResponse) updates) => super.copyWith((message) => updates(message as SuggestPurchaseOrdersResponse)) as SuggestPurchaseOrdersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersResponse create() => SuggestPurchaseOrdersResponse._();
  SuggestPurchaseOrdersResponse createEmptyInstance() => create();
  static $pb.PbList<SuggestPurchaseOrdersResponse> createRepeated() => $pb.PbList<SuggestPurchaseOrdersResponse>();
  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SuggestPurchaseOrdersResponse>(create);
  static SuggestPurchaseOrdersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PurchaseOrderSuggestion> get suggestions => $_getList(0);
}

class ProcurementServiceApi {
  $pb.RpcClient _client;
  ProcurementServiceApi(this._client);

  $async.Future<SupplierSaveResponse> supplierSave($pb.ClientContext? ctx, SupplierSaveRequest request) =>
    _client.invoke<SupplierSaveResponse>(ctx, 'ProcurementService', 'SupplierSave', request, SupplierSaveResponse())
  ;
  $async.Future<SupplierGetResponse> supplierGet($pb.ClientContext? ctx, SupplierGetRequest request) =>
    _client.invoke<SupplierGetResponse>(ctx, 'ProcurementService', 'SupplierGet', request, SupplierGetResponse())
  ;
  $async.Future<SupplierSearchResponse> supplierSearch($pb.ClientContext? ctx, SupplierSearchRequest request) =>
    _client.invoke<SupplierSearchResponse>(ctx, 'ProcurementService', 'SupplierSearch', request, SupplierSearchResponse())
  ;
  $async.Future<SupplierItemSaveResponse> supplierItemSave($pb.ClientContext? ctx, SupplierItemSaveRequest request) =>
    _client.invoke<SupplierItemSaveResponse>(ctx, 'ProcurementService', 'SupplierItemSave', request, SupplierItemSaveResponse())
  ;
  $async.Future<SupplierItemSearchResponse> supplierItemSearch($pb.ClientContext? ctx, SupplierItemSearchRequest request) =>
    _client.invoke<SupplierItemSearchResponse>(ctx, 'ProcurementService', 'SupplierItemSearch', request, SupplierItemSearchResponse())
  ;
  $async.Future<PurchaseOrderCreateResponse> purchaseOrderCreate($pb.ClientContext? ctx, PurchaseOrderCreateRequest request) =>
    _client.invoke<PurchaseOrderCreateResponse>(ctx, 'ProcurementService', 'PurchaseOrderCreate', request, PurchaseOrderCreateResponse())
  ;
  $async.Future<PurchaseOrderGetResponse> purchaseOrderGet($pb.ClientContext? ctx, PurchaseOrderGetRequest request) =>
    _client.invoke<PurchaseOrderGetResponse>(ctx, 'ProcurementService', 'PurchaseOrderGet', request, PurchaseOrderGetResponse())
  ;
  $async.Future<PurchaseOrderSearchResponse> purchaseOrderSearch($pb.ClientContext? ctx, PurchaseOrderSearchRequest request) =>
    _client.invoke<PurchaseOrderSearchResponse>(ctx, 'ProcurementService', 'PurchaseOrderSearch', request, PurchaseOrderSearchResponse())
  ;
  $async.Future<PurchaseOrderSubmitResponse> purchaseOrderSubmit($pb.ClientContext? ctx, PurchaseOrderSubmitRequest request) =>
    _client.invoke<PurchaseOrderSubmitResponse>(ctx, 'ProcurementService', 'PurchaseOrderSubmit', request, PurchaseOrderSubmitResponse())
  ;
  $async.Future<PurchaseOrderCancelResponse> purchaseOrderCancel($pb.ClientContext? ctx, PurchaseOrderCancelRequest request) =>
    _client.invoke<PurchaseOrderCancelResponse>(ctx, 'ProcurementService', 'PurchaseOrderCancel', request, PurchaseOrderCancelResponse())
  ;
  $async.Future<GoodsReceiptCreateResponse> goodsReceiptCreate($pb.ClientContext? ctx, GoodsReceiptCreateRequest request) =>
    _client.invoke<GoodsReceiptCreateResponse>(ctx, 'ProcurementService', 'GoodsReceiptCreate', request, GoodsReceiptCreateResponse())
  ;
  $async.Future<GoodsReceiptGetResponse> goodsReceiptGet($pb.ClientContext? ctx, GoodsReceiptGetRequest request) =>
    _client.invoke<GoodsReceiptGetResponse>(ctx, 'ProcurementService', 'GoodsReceiptGet', request, GoodsReceiptGetResponse())
  ;
  $async.Future<GoodsReceiptSearchResponse> goodsReceiptSearch($pb.ClientContext? ctx, GoodsReceiptSearchRequest request) =>
    _client.invoke<GoodsReceiptSearchResponse>(ctx, 'ProcurementService', 'GoodsReceiptSearch', request, GoodsReceiptSearchResponse())
  ;
  $async.Future<SuggestPurchaseOrdersResponse> suggestPurchaseOrders($pb.ClientContext? ctx, SuggestPurchaseOrdersRequest request) =>
    _client.invoke<SuggestPurchaseOrdersResponse>(ctx, 'ProcurementService', 'SuggestPurchaseOrders', request, SuggestPurchaseOrdersResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
