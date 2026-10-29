// This is a generated file - do not edit.
//
// Generated from v1/procurement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import '../common/v1/common.pb.dart' as $2;
import '../common/v1/money.pb.dart' as $1;
import 'procurement.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    $0.Timestamp? createdAt,
  }) {
    final result = Supplier._();
    if (id != null) result.id = id;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (supplierType != null) result.supplierType = supplierType;
    if (status != null) result.status = status;
    if (paymentTermsDays != null) result.paymentTermsDays = paymentTermsDays;
    if (currency != null) result.currency = currency;
    if (leadTimeDays != null) result.leadTimeDays = leadTimeDays;
    if (rating != null) result.rating = rating;
    if (notes != null) result.notes = notes;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Supplier._();

  factory Supplier.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Supplier()..mergeFromBuffer(data, registry);
  factory Supplier.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Supplier()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Supplier',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: Supplier.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<SupplierType>(4, _omitFieldNames ? '' : 'supplierType',
        enumValues: SupplierType.values)
    ..aE<SupplierStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: SupplierStatus.values)
    ..aI(6, _omitFieldNames ? '' : 'paymentTermsDays')
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..aI(8, _omitFieldNames ? '' : 'leadTimeDays')
    ..aE<SupplierRating>(9, _omitFieldNames ? '' : 'rating',
        enumValues: SupplierRating.values)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Supplier clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Supplier copyWith(void Function(Supplier) updates) =>
      super.copyWith((message) => updates(message as Supplier)) as Supplier;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Supplier() / Supplier.new instead')
  static Supplier create() => Supplier._();
  static $pb.GeneratedMessage $_createMessage() => Supplier._();
  @$core.override
  Supplier createEmptyInstance() => Supplier._();
  @$core.pragma('dart2js:noInline')
  static Supplier getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Supplier>(Supplier.$_createMessage);
  static Supplier? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  SupplierType get supplierType => $_getN(3);
  @$pb.TagNumber(4)
  set supplierType(SupplierType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSupplierType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierType() => $_clearField(4);

  @$pb.TagNumber(5)
  SupplierStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SupplierStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get paymentTermsDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set paymentTermsDays($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentTermsDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaymentTermsDays() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => $_clearField(8);

  @$pb.TagNumber(9)
  SupplierRating get rating => $_getN(8);
  @$pb.TagNumber(9)
  set rating(SupplierRating value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasRating() => $_has(8);
  @$pb.TagNumber(9)
  void clearRating() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);
}

class SupplierItem extends $pb.GeneratedMessage {
  factory SupplierItem({
    $core.String? id,
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $core.String? supplierSku,
    $1.Money? unitPrice,
    $core.double? minOrderQuantity,
    $core.String? unit,
    $core.int? leadTimeDays,
    SupplierItemStatus? status,
    SupplyKind? supplyKind,
    $core.String? productVariantId,
    $0.Timestamp? createdAt,
  }) {
    final result = SupplierItem._();
    if (id != null) result.id = id;
    if (supplierId != null) result.supplierId = supplierId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (supplierSku != null) result.supplierSku = supplierSku;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (minOrderQuantity != null) result.minOrderQuantity = minOrderQuantity;
    if (unit != null) result.unit = unit;
    if (leadTimeDays != null) result.leadTimeDays = leadTimeDays;
    if (status != null) result.status = status;
    if (supplyKind != null) result.supplyKind = supplyKind;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SupplierItem._();

  factory SupplierItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItem()..mergeFromBuffer(data, registry);
  factory SupplierItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierItem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..aOS(3, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(4, _omitFieldNames ? '' : 'supplierSku')
    ..aOM<$1.Money>(5, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $1.Money.$_createMessage)
    ..aD(6, _omitFieldNames ? '' : 'minOrderQuantity')
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..aI(8, _omitFieldNames ? '' : 'leadTimeDays')
    ..aE<SupplierItemStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: SupplierItemStatus.values)
    ..aE<SupplyKind>(10, _omitFieldNames ? '' : 'supplyKind',
        enumValues: SupplyKind.values)
    ..aOS(11, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItem copyWith(void Function(SupplierItem) updates) =>
      super.copyWith((message) => updates(message as SupplierItem))
          as SupplierItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SupplierItem() / SupplierItem.new instead')
  static SupplierItem create() => SupplierItem._();
  static $pb.GeneratedMessage $_createMessage() => SupplierItem._();
  @$core.override
  SupplierItem createEmptyInstance() => SupplierItem._();
  @$core.pragma('dart2js:noInline')
  static SupplierItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplierItem>(
          SupplierItem.$_createMessage);
  static SupplierItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get inventoryItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set inventoryItemId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInventoryItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInventoryItemId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get supplierSku => $_getSZ(3);
  @$pb.TagNumber(4)
  set supplierSku($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSupplierSku() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierSku() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($1.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get minOrderQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set minOrderQuantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinOrderQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinOrderQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => $_clearField(8);

  @$pb.TagNumber(9)
  SupplierItemStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SupplierItemStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  SupplyKind get supplyKind => $_getN(9);
  @$pb.TagNumber(10)
  set supplyKind(SupplyKind value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSupplyKind() => $_has(9);
  @$pb.TagNumber(10)
  void clearSupplyKind() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get productVariantId => $_getSZ(10);
  @$pb.TagNumber(11)
  set productVariantId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProductVariantId() => $_has(10);
  @$pb.TagNumber(11)
  void clearProductVariantId() => $_clearField(11);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(11);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(11);
}

class PurchaseOrder extends $pb.GeneratedMessage {
  factory PurchaseOrder({
    $core.String? id,
    $core.String? propertyId,
    $core.String? supplierId,
    $core.String? orderNumber,
    PurchaseOrderStatus? status,
    $0.Timestamp? expectedDeliveryDate,
    $0.Timestamp? submittedAt,
    $core.String? submittedBy,
    $1.Money? totalAmount,
    $core.String? notes,
    $core.String? planId,
    $core.Iterable<PurchaseOrderLine>? lines,
    $0.Timestamp? createdAt,
  }) {
    final result = PurchaseOrder._();
    if (id != null) result.id = id;
    if (propertyId != null) result.propertyId = propertyId;
    if (supplierId != null) result.supplierId = supplierId;
    if (orderNumber != null) result.orderNumber = orderNumber;
    if (status != null) result.status = status;
    if (expectedDeliveryDate != null)
      result.expectedDeliveryDate = expectedDeliveryDate;
    if (submittedAt != null) result.submittedAt = submittedAt;
    if (submittedBy != null) result.submittedBy = submittedBy;
    if (totalAmount != null) result.totalAmount = totalAmount;
    if (notes != null) result.notes = notes;
    if (planId != null) result.planId = planId;
    if (lines != null) result.lines.addAll(lines);
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  PurchaseOrder._();

  factory PurchaseOrder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrder()..mergeFromBuffer(data, registry);
  factory PurchaseOrder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrder()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrder.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierId')
    ..aOS(4, _omitFieldNames ? '' : 'orderNumber')
    ..aE<PurchaseOrderStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: PurchaseOrderStatus.values)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'expectedDeliveryDate',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'submittedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<$1.Money>(9, _omitFieldNames ? '' : 'totalAmount',
        subBuilder: $1.Money.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOS(11, _omitFieldNames ? '' : 'planId')
    ..pPM<PurchaseOrderLine>(12, _omitFieldNames ? '' : 'lines',
        subBuilder: PurchaseOrderLine.$_createMessage)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrder copyWith(void Function(PurchaseOrder) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrder))
          as PurchaseOrder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PurchaseOrder() / PurchaseOrder.new instead')
  static PurchaseOrder create() => PurchaseOrder._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrder._();
  @$core.override
  PurchaseOrder createEmptyInstance() => PurchaseOrder._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrder getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrder>(
          PurchaseOrder.$_createMessage);
  static PurchaseOrder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupplierId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orderNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set orderNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrderNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  PurchaseOrderStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(PurchaseOrderStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get expectedDeliveryDate => $_getN(5);
  @$pb.TagNumber(6)
  set expectedDeliveryDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedDeliveryDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedDeliveryDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureExpectedDeliveryDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get submittedAt => $_getN(6);
  @$pb.TagNumber(7)
  set submittedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasSubmittedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubmittedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureSubmittedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get submittedBy => $_getSZ(7);
  @$pb.TagNumber(8)
  set submittedBy($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSubmittedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubmittedBy() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Money get totalAmount => $_getN(8);
  @$pb.TagNumber(9)
  set totalAmount($1.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalAmount() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Money ensureTotalAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get planId => $_getSZ(10);
  @$pb.TagNumber(11)
  set planId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPlanId() => $_has(10);
  @$pb.TagNumber(11)
  void clearPlanId() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<PurchaseOrderLine> get lines => $_getList(11);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);
}

class PurchaseOrderLine extends $pb.GeneratedMessage {
  factory PurchaseOrderLine({
    $core.String? id,
    $core.String? purchaseOrderId,
    $core.String? supplierItemId,
    $core.String? inventoryItemId,
    $core.double? orderedQuantity,
    $core.double? receivedQuantity,
    $1.Money? unitPrice,
    $core.String? unit,
    PurchaseOrderLineStatus? status,
    SupplyKind? supplyKind,
    $core.String? productVariantId,
  }) {
    final result = PurchaseOrderLine._();
    if (id != null) result.id = id;
    if (purchaseOrderId != null) result.purchaseOrderId = purchaseOrderId;
    if (supplierItemId != null) result.supplierItemId = supplierItemId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (orderedQuantity != null) result.orderedQuantity = orderedQuantity;
    if (receivedQuantity != null) result.receivedQuantity = receivedQuantity;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (unit != null) result.unit = unit;
    if (status != null) result.status = status;
    if (supplyKind != null) result.supplyKind = supplyKind;
    if (productVariantId != null) result.productVariantId = productVariantId;
    return result;
  }

  PurchaseOrderLine._();

  factory PurchaseOrderLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderLine()..mergeFromBuffer(data, registry);
  factory PurchaseOrderLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierItemId')
    ..aOS(4, _omitFieldNames ? '' : 'inventoryItemId')
    ..aD(5, _omitFieldNames ? '' : 'orderedQuantity')
    ..aD(6, _omitFieldNames ? '' : 'receivedQuantity')
    ..aOM<$1.Money>(7, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $1.Money.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'unit')
    ..aE<PurchaseOrderLineStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: PurchaseOrderLineStatus.values)
    ..aE<SupplyKind>(10, _omitFieldNames ? '' : 'supplyKind',
        enumValues: SupplyKind.values)
    ..aOS(11, _omitFieldNames ? '' : 'productVariantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderLine copyWith(void Function(PurchaseOrderLine) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderLine))
          as PurchaseOrderLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PurchaseOrderLine() / PurchaseOrderLine.new instead')
  static PurchaseOrderLine create() => PurchaseOrderLine._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrderLine._();
  @$core.override
  PurchaseOrderLine createEmptyInstance() => PurchaseOrderLine._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PurchaseOrderLine>(
          PurchaseOrderLine.$_createMessage);
  static PurchaseOrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierItemId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupplierItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierItemId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inventoryItemId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inventoryItemId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInventoryItemId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInventoryItemId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get orderedQuantity => $_getN(4);
  @$pb.TagNumber(5)
  set orderedQuantity($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrderedQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrderedQuantity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get receivedQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set receivedQuantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReceivedQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Money get unitPrice => $_getN(6);
  @$pb.TagNumber(7)
  set unitPrice($1.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUnitPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnitPrice() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Money ensureUnitPrice() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get unit => $_getSZ(7);
  @$pb.TagNumber(8)
  set unit($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnit() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnit() => $_clearField(8);

  @$pb.TagNumber(9)
  PurchaseOrderLineStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(PurchaseOrderLineStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  SupplyKind get supplyKind => $_getN(9);
  @$pb.TagNumber(10)
  set supplyKind(SupplyKind value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSupplyKind() => $_has(9);
  @$pb.TagNumber(10)
  void clearSupplyKind() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get productVariantId => $_getSZ(10);
  @$pb.TagNumber(11)
  set productVariantId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProductVariantId() => $_has(10);
  @$pb.TagNumber(11)
  void clearProductVariantId() => $_clearField(11);
}

class GoodsReceipt extends $pb.GeneratedMessage {
  factory GoodsReceipt({
    $core.String? id,
    $core.String? purchaseOrderId,
    $core.String? propertyId,
    $core.String? receivedBy,
    $0.Timestamp? receivedAt,
    GoodsReceiptStatus? status,
    $core.String? notes,
    $core.Iterable<GoodsReceiptLine>? lines,
    $core.String? stockLocationId,
    $0.Timestamp? createdAt,
  }) {
    final result = GoodsReceipt._();
    if (id != null) result.id = id;
    if (purchaseOrderId != null) result.purchaseOrderId = purchaseOrderId;
    if (propertyId != null) result.propertyId = propertyId;
    if (receivedBy != null) result.receivedBy = receivedBy;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (status != null) result.status = status;
    if (notes != null) result.notes = notes;
    if (lines != null) result.lines.addAll(lines);
    if (stockLocationId != null) result.stockLocationId = stockLocationId;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  GoodsReceipt._();

  factory GoodsReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceipt()..mergeFromBuffer(data, registry);
  factory GoodsReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceipt()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceipt.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'propertyId')
    ..aOS(4, _omitFieldNames ? '' : 'receivedBy')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'receivedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<GoodsReceiptStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: GoodsReceiptStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..pPM<GoodsReceiptLine>(8, _omitFieldNames ? '' : 'lines',
        subBuilder: GoodsReceiptLine.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'stockLocationId')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceipt copyWith(void Function(GoodsReceipt) updates) =>
      super.copyWith((message) => updates(message as GoodsReceipt))
          as GoodsReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoodsReceipt() / GoodsReceipt.new instead')
  static GoodsReceipt create() => GoodsReceipt._();
  static $pb.GeneratedMessage $_createMessage() => GoodsReceipt._();
  @$core.override
  GoodsReceipt createEmptyInstance() => GoodsReceipt._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceipt getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceipt>(
          GoodsReceipt.$_createMessage);
  static GoodsReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get propertyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set propertyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPropertyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPropertyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get receivedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set receivedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReceivedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearReceivedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get receivedAt => $_getN(4);
  @$pb.TagNumber(5)
  set receivedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasReceivedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureReceivedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  GoodsReceiptStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(GoodsReceiptStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<GoodsReceiptLine> get lines => $_getList(7);

  /// Manufacturing stock location raw materials are received into.
  @$pb.TagNumber(9)
  $core.String get stockLocationId => $_getSZ(8);
  @$pb.TagNumber(9)
  set stockLocationId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStockLocationId() => $_has(8);
  @$pb.TagNumber(9)
  void clearStockLocationId() => $_clearField(9);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);
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
    $0.Timestamp? expiryDate,
    $core.String? unit,
    SupplyKind? supplyKind,
    $core.String? productVariantId,
    StockDeliveryStatus? deliveryStatus,
    $core.String? deliveryNote,
    $core.String? resolvedBy,
    $0.Timestamp? resolvedAt,
    $core.String? resolutionNote,
    $core.String? locationId,
  }) {
    final result = GoodsReceiptLine._();
    if (id != null) result.id = id;
    if (goodsReceiptId != null) result.goodsReceiptId = goodsReceiptId;
    if (purchaseOrderLineId != null)
      result.purchaseOrderLineId = purchaseOrderLineId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (receivedQuantity != null) result.receivedQuantity = receivedQuantity;
    if (acceptedQuantity != null) result.acceptedQuantity = acceptedQuantity;
    if (rejectedQuantity != null) result.rejectedQuantity = rejectedQuantity;
    if (rejectionReason != null) result.rejectionReason = rejectionReason;
    if (lotNumber != null) result.lotNumber = lotNumber;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (unit != null) result.unit = unit;
    if (supplyKind != null) result.supplyKind = supplyKind;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (deliveryStatus != null) result.deliveryStatus = deliveryStatus;
    if (deliveryNote != null) result.deliveryNote = deliveryNote;
    if (resolvedBy != null) result.resolvedBy = resolvedBy;
    if (resolvedAt != null) result.resolvedAt = resolvedAt;
    if (resolutionNote != null) result.resolutionNote = resolutionNote;
    if (locationId != null) result.locationId = locationId;
    return result;
  }

  GoodsReceiptLine._();

  factory GoodsReceiptLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLine()..mergeFromBuffer(data, registry);
  factory GoodsReceiptLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'goodsReceiptId')
    ..aOS(3, _omitFieldNames ? '' : 'purchaseOrderLineId')
    ..aOS(4, _omitFieldNames ? '' : 'inventoryItemId')
    ..aD(5, _omitFieldNames ? '' : 'receivedQuantity')
    ..aD(6, _omitFieldNames ? '' : 'acceptedQuantity')
    ..aD(7, _omitFieldNames ? '' : 'rejectedQuantity')
    ..aOS(8, _omitFieldNames ? '' : 'rejectionReason')
    ..aOS(9, _omitFieldNames ? '' : 'lotNumber')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'unit')
    ..aE<SupplyKind>(12, _omitFieldNames ? '' : 'supplyKind',
        enumValues: SupplyKind.values)
    ..aOS(13, _omitFieldNames ? '' : 'productVariantId')
    ..aE<StockDeliveryStatus>(14, _omitFieldNames ? '' : 'deliveryStatus',
        enumValues: StockDeliveryStatus.values)
    ..aOS(15, _omitFieldNames ? '' : 'deliveryNote')
    ..aOS(16, _omitFieldNames ? '' : 'resolvedBy')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'resolvedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(18, _omitFieldNames ? '' : 'resolutionNote')
    ..aOS(19, _omitFieldNames ? '' : 'locationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLine copyWith(void Function(GoodsReceiptLine) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptLine))
          as GoodsReceiptLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoodsReceiptLine() / GoodsReceiptLine.new instead')
  static GoodsReceiptLine create() => GoodsReceiptLine._();
  static $pb.GeneratedMessage $_createMessage() => GoodsReceiptLine._();
  @$core.override
  GoodsReceiptLine createEmptyInstance() => GoodsReceiptLine._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLine>(
          GoodsReceiptLine.$_createMessage);
  static GoodsReceiptLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goodsReceiptId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goodsReceiptId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoodsReceiptId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoodsReceiptId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get purchaseOrderLineId => $_getSZ(2);
  @$pb.TagNumber(3)
  set purchaseOrderLineId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPurchaseOrderLineId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPurchaseOrderLineId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inventoryItemId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inventoryItemId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInventoryItemId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInventoryItemId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get receivedQuantity => $_getN(4);
  @$pb.TagNumber(5)
  set receivedQuantity($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReceivedQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedQuantity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get acceptedQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set acceptedQuantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAcceptedQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearAcceptedQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get rejectedQuantity => $_getN(6);
  @$pb.TagNumber(7)
  set rejectedQuantity($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRejectedQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearRejectedQuantity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get rejectionReason => $_getSZ(7);
  @$pb.TagNumber(8)
  set rejectionReason($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRejectionReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearRejectionReason() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get lotNumber => $_getSZ(8);
  @$pb.TagNumber(9)
  set lotNumber($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLotNumber() => $_has(8);
  @$pb.TagNumber(9)
  void clearLotNumber() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get expiryDate => $_getN(9);
  @$pb.TagNumber(10)
  set expiryDate($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasExpiryDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpiryDate() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureExpiryDate() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get unit => $_getSZ(10);
  @$pb.TagNumber(11)
  set unit($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUnit() => $_has(10);
  @$pb.TagNumber(11)
  void clearUnit() => $_clearField(11);

  @$pb.TagNumber(12)
  SupplyKind get supplyKind => $_getN(11);
  @$pb.TagNumber(12)
  set supplyKind(SupplyKind value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSupplyKind() => $_has(11);
  @$pb.TagNumber(12)
  void clearSupplyKind() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get productVariantId => $_getSZ(12);
  @$pb.TagNumber(13)
  set productVariantId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasProductVariantId() => $_has(12);
  @$pb.TagNumber(13)
  void clearProductVariantId() => $_clearField(13);

  @$pb.TagNumber(14)
  StockDeliveryStatus get deliveryStatus => $_getN(13);
  @$pb.TagNumber(14)
  set deliveryStatus(StockDeliveryStatus value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasDeliveryStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearDeliveryStatus() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get deliveryNote => $_getSZ(14);
  @$pb.TagNumber(15)
  set deliveryNote($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDeliveryNote() => $_has(14);
  @$pb.TagNumber(15)
  void clearDeliveryNote() => $_clearField(15);

  /// Who marked the line resolved, when, and their note.
  @$pb.TagNumber(16)
  $core.String get resolvedBy => $_getSZ(15);
  @$pb.TagNumber(16)
  set resolvedBy($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasResolvedBy() => $_has(15);
  @$pb.TagNumber(16)
  void clearResolvedBy() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get resolvedAt => $_getN(16);
  @$pb.TagNumber(17)
  set resolvedAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasResolvedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearResolvedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureResolvedAt() => $_ensure(16);

  @$pb.TagNumber(18)
  $core.String get resolutionNote => $_getSZ(17);
  @$pb.TagNumber(18)
  set resolutionNote($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasResolutionNote() => $_has(17);
  @$pb.TagNumber(18)
  void clearResolutionNote() => $_clearField(18);

  /// Where a raw material is put away in manufacturing inventory.
  @$pb.TagNumber(19)
  $core.String get locationId => $_getSZ(18);
  @$pb.TagNumber(19)
  set locationId($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasLocationId() => $_has(18);
  @$pb.TagNumber(19)
  void clearLocationId() => $_clearField(19);
}

class PurchaseOrderSuggestion extends $pb.GeneratedMessage {
  factory PurchaseOrderSuggestion({
    $core.String? supplierId,
    $core.String? supplierName,
    $core.Iterable<PurchaseOrderSuggestionLine>? lines,
    $1.Money? estimatedTotal,
  }) {
    final result = PurchaseOrderSuggestion._();
    if (supplierId != null) result.supplierId = supplierId;
    if (supplierName != null) result.supplierName = supplierName;
    if (lines != null) result.lines.addAll(lines);
    if (estimatedTotal != null) result.estimatedTotal = estimatedTotal;
    return result;
  }

  PurchaseOrderSuggestion._();

  factory PurchaseOrderSuggestion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSuggestion()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSuggestion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSuggestion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSuggestion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSuggestion.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'supplierId')
    ..aOS(2, _omitFieldNames ? '' : 'supplierName')
    ..pPM<PurchaseOrderSuggestionLine>(3, _omitFieldNames ? '' : 'lines',
        subBuilder: PurchaseOrderSuggestionLine.$_createMessage)
    ..aOM<$1.Money>(4, _omitFieldNames ? '' : 'estimatedTotal',
        subBuilder: $1.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSuggestion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSuggestion copyWith(
          void Function(PurchaseOrderSuggestion) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderSuggestion))
          as PurchaseOrderSuggestion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSuggestion() / PurchaseOrderSuggestion.new instead')
  static PurchaseOrderSuggestion create() => PurchaseOrderSuggestion._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrderSuggestion._();
  @$core.override
  PurchaseOrderSuggestion createEmptyInstance() => PurchaseOrderSuggestion._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSuggestion>(
          PurchaseOrderSuggestion.$_createMessage);
  static PurchaseOrderSuggestion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplierId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierName => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSupplierName() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<PurchaseOrderSuggestionLine> get lines => $_getList(2);

  @$pb.TagNumber(4)
  $1.Money get estimatedTotal => $_getN(3);
  @$pb.TagNumber(4)
  set estimatedTotal($1.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimatedTotal() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimatedTotal() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Money ensureEstimatedTotal() => $_ensure(3);
}

class PurchaseOrderSuggestionLine extends $pb.GeneratedMessage {
  factory PurchaseOrderSuggestionLine({
    $core.String? inventoryItemId,
    $core.String? itemName,
    $core.double? shortageQuantity,
    $core.String? unit,
    $core.String? supplierItemId,
    $1.Money? unitPrice,
  }) {
    final result = PurchaseOrderSuggestionLine._();
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (itemName != null) result.itemName = itemName;
    if (shortageQuantity != null) result.shortageQuantity = shortageQuantity;
    if (unit != null) result.unit = unit;
    if (supplierItemId != null) result.supplierItemId = supplierItemId;
    if (unitPrice != null) result.unitPrice = unitPrice;
    return result;
  }

  PurchaseOrderSuggestionLine._();

  factory PurchaseOrderSuggestionLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSuggestionLine()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSuggestionLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSuggestionLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSuggestionLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSuggestionLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(2, _omitFieldNames ? '' : 'itemName')
    ..aD(3, _omitFieldNames ? '' : 'shortageQuantity')
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..aOS(5, _omitFieldNames ? '' : 'supplierItemId')
    ..aOM<$1.Money>(6, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $1.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSuggestionLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSuggestionLine copyWith(
          void Function(PurchaseOrderSuggestionLine) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderSuggestionLine))
          as PurchaseOrderSuggestionLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSuggestionLine() / PurchaseOrderSuggestionLine.new instead')
  static PurchaseOrderSuggestionLine create() =>
      PurchaseOrderSuggestionLine._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderSuggestionLine._();
  @$core.override
  PurchaseOrderSuggestionLine createEmptyInstance() =>
      PurchaseOrderSuggestionLine._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSuggestionLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSuggestionLine>(
          PurchaseOrderSuggestionLine.$_createMessage);
  static PurchaseOrderSuggestionLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inventoryItemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set inventoryItemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInventoryItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInventoryItemId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get itemName => $_getSZ(1);
  @$pb.TagNumber(2)
  set itemName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasItemName() => $_has(1);
  @$pb.TagNumber(2)
  void clearItemName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get shortageQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set shortageQuantity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasShortageQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearShortageQuantity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get supplierItemId => $_getSZ(4);
  @$pb.TagNumber(5)
  set supplierItemId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSupplierItemId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSupplierItemId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Money get unitPrice => $_getN(5);
  @$pb.TagNumber(6)
  set unitPrice($1.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUnitPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnitPrice() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Money ensureUnitPrice() => $_ensure(5);
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
    final result = SupplierSaveRequest._();
    if (id != null) result.id = id;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (supplierType != null) result.supplierType = supplierType;
    if (status != null) result.status = status;
    if (paymentTermsDays != null) result.paymentTermsDays = paymentTermsDays;
    if (currency != null) result.currency = currency;
    if (leadTimeDays != null) result.leadTimeDays = leadTimeDays;
    if (rating != null) result.rating = rating;
    if (notes != null) result.notes = notes;
    return result;
  }

  SupplierSaveRequest._();

  factory SupplierSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSaveRequest()..mergeFromBuffer(data, registry);
  factory SupplierSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<SupplierType>(4, _omitFieldNames ? '' : 'supplierType',
        enumValues: SupplierType.values)
    ..aE<SupplierStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: SupplierStatus.values)
    ..aI(6, _omitFieldNames ? '' : 'paymentTermsDays')
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..aI(8, _omitFieldNames ? '' : 'leadTimeDays')
    ..aE<SupplierRating>(9, _omitFieldNames ? '' : 'rating',
        enumValues: SupplierRating.values)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSaveRequest copyWith(void Function(SupplierSaveRequest) updates) =>
      super.copyWith((message) => updates(message as SupplierSaveRequest))
          as SupplierSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SupplierSaveRequest() / SupplierSaveRequest.new instead')
  static SupplierSaveRequest create() => SupplierSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => SupplierSaveRequest._();
  @$core.override
  SupplierSaveRequest createEmptyInstance() => SupplierSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static SupplierSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierSaveRequest>(
          SupplierSaveRequest.$_createMessage);
  static SupplierSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  SupplierType get supplierType => $_getN(3);
  @$pb.TagNumber(4)
  set supplierType(SupplierType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSupplierType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierType() => $_clearField(4);

  @$pb.TagNumber(5)
  SupplierStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SupplierStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get paymentTermsDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set paymentTermsDays($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentTermsDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaymentTermsDays() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => $_clearField(8);

  @$pb.TagNumber(9)
  SupplierRating get rating => $_getN(8);
  @$pb.TagNumber(9)
  set rating(SupplierRating value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasRating() => $_has(8);
  @$pb.TagNumber(9)
  void clearRating() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

class SupplierSaveResponse extends $pb.GeneratedMessage {
  factory SupplierSaveResponse({
    Supplier? supplier,
  }) {
    final result = SupplierSaveResponse._();
    if (supplier != null) result.supplier = supplier;
    return result;
  }

  SupplierSaveResponse._();

  factory SupplierSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSaveResponse()..mergeFromBuffer(data, registry);
  factory SupplierSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierSaveResponse.$_createMessage)
    ..aOM<Supplier>(1, _omitFieldNames ? '' : 'supplier',
        subBuilder: Supplier.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSaveResponse copyWith(void Function(SupplierSaveResponse) updates) =>
      super.copyWith((message) => updates(message as SupplierSaveResponse))
          as SupplierSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierSaveResponse() / SupplierSaveResponse.new instead')
  static SupplierSaveResponse create() => SupplierSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => SupplierSaveResponse._();
  @$core.override
  SupplierSaveResponse createEmptyInstance() => SupplierSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static SupplierSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierSaveResponse>(
          SupplierSaveResponse.$_createMessage);
  static SupplierSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Supplier get supplier => $_getN(0);
  @$pb.TagNumber(1)
  set supplier(Supplier value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplier() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplier() => $_clearField(1);
  @$pb.TagNumber(1)
  Supplier ensureSupplier() => $_ensure(0);
}

class SupplierGetRequest extends $pb.GeneratedMessage {
  factory SupplierGetRequest({
    $core.String? id,
  }) {
    final result = SupplierGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  SupplierGetRequest._();

  factory SupplierGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierGetRequest()..mergeFromBuffer(data, registry);
  factory SupplierGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierGetRequest copyWith(void Function(SupplierGetRequest) updates) =>
      super.copyWith((message) => updates(message as SupplierGetRequest))
          as SupplierGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SupplierGetRequest() / SupplierGetRequest.new instead')
  static SupplierGetRequest create() => SupplierGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SupplierGetRequest._();
  @$core.override
  SupplierGetRequest createEmptyInstance() => SupplierGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SupplierGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierGetRequest>(
          SupplierGetRequest.$_createMessage);
  static SupplierGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SupplierGetResponse extends $pb.GeneratedMessage {
  factory SupplierGetResponse({
    Supplier? supplier,
  }) {
    final result = SupplierGetResponse._();
    if (supplier != null) result.supplier = supplier;
    return result;
  }

  SupplierGetResponse._();

  factory SupplierGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierGetResponse()..mergeFromBuffer(data, registry);
  factory SupplierGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierGetResponse.$_createMessage)
    ..aOM<Supplier>(1, _omitFieldNames ? '' : 'supplier',
        subBuilder: Supplier.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierGetResponse copyWith(void Function(SupplierGetResponse) updates) =>
      super.copyWith((message) => updates(message as SupplierGetResponse))
          as SupplierGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SupplierGetResponse() / SupplierGetResponse.new instead')
  static SupplierGetResponse create() => SupplierGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => SupplierGetResponse._();
  @$core.override
  SupplierGetResponse createEmptyInstance() => SupplierGetResponse._();
  @$core.pragma('dart2js:noInline')
  static SupplierGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierGetResponse>(
          SupplierGetResponse.$_createMessage);
  static SupplierGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Supplier get supplier => $_getN(0);
  @$pb.TagNumber(1)
  set supplier(Supplier value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplier() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplier() => $_clearField(1);
  @$pb.TagNumber(1)
  Supplier ensureSupplier() => $_ensure(0);
}

class SupplierSearchRequest extends $pb.GeneratedMessage {
  factory SupplierSearchRequest({
    $2.SearchRequest? search,
    SupplierType? supplierType,
    SupplierStatus? status,
  }) {
    final result = SupplierSearchRequest._();
    if (search != null) result.search = search;
    if (supplierType != null) result.supplierType = supplierType;
    if (status != null) result.status = status;
    return result;
  }

  SupplierSearchRequest._();

  factory SupplierSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSearchRequest()..mergeFromBuffer(data, registry);
  factory SupplierSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierSearchRequest.$_createMessage)
    ..aOM<$2.SearchRequest>(1, _omitFieldNames ? '' : 'search',
        subBuilder: $2.SearchRequest.$_createMessage)
    ..aE<SupplierType>(2, _omitFieldNames ? '' : 'supplierType',
        enumValues: SupplierType.values)
    ..aE<SupplierStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: SupplierStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSearchRequest copyWith(
          void Function(SupplierSearchRequest) updates) =>
      super.copyWith((message) => updates(message as SupplierSearchRequest))
          as SupplierSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierSearchRequest() / SupplierSearchRequest.new instead')
  static SupplierSearchRequest create() => SupplierSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => SupplierSearchRequest._();
  @$core.override
  SupplierSearchRequest createEmptyInstance() => SupplierSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static SupplierSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierSearchRequest>(
          SupplierSearchRequest.$_createMessage);
  static SupplierSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.SearchRequest get search => $_getN(0);
  @$pb.TagNumber(1)
  set search($2.SearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSearch() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearch() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.SearchRequest ensureSearch() => $_ensure(0);

  @$pb.TagNumber(2)
  SupplierType get supplierType => $_getN(1);
  @$pb.TagNumber(2)
  set supplierType(SupplierType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSupplierType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierType() => $_clearField(2);

  @$pb.TagNumber(3)
  SupplierStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(SupplierStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);
}

class SupplierSearchResponse extends $pb.GeneratedMessage {
  factory SupplierSearchResponse({
    $core.Iterable<Supplier>? suppliers,
    $core.String? nextPage,
  }) {
    final result = SupplierSearchResponse._();
    if (suppliers != null) result.suppliers.addAll(suppliers);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  SupplierSearchResponse._();

  factory SupplierSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSearchResponse()..mergeFromBuffer(data, registry);
  factory SupplierSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierSearchResponse.$_createMessage)
    ..pPM<Supplier>(1, _omitFieldNames ? '' : 'suppliers',
        subBuilder: Supplier.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierSearchResponse copyWith(
          void Function(SupplierSearchResponse) updates) =>
      super.copyWith((message) => updates(message as SupplierSearchResponse))
          as SupplierSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierSearchResponse() / SupplierSearchResponse.new instead')
  static SupplierSearchResponse create() => SupplierSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => SupplierSearchResponse._();
  @$core.override
  SupplierSearchResponse createEmptyInstance() => SupplierSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static SupplierSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierSearchResponse>(
          SupplierSearchResponse.$_createMessage);
  static SupplierSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Supplier> get suppliers => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class SupplierItemSaveRequest extends $pb.GeneratedMessage {
  factory SupplierItemSaveRequest({
    $core.String? id,
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $core.String? supplierSku,
    $1.Money? unitPrice,
    $core.double? minOrderQuantity,
    $core.String? unit,
    $core.int? leadTimeDays,
    SupplierItemStatus? status,
    SupplyKind? supplyKind,
    $core.String? productVariantId,
  }) {
    final result = SupplierItemSaveRequest._();
    if (id != null) result.id = id;
    if (supplierId != null) result.supplierId = supplierId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (supplierSku != null) result.supplierSku = supplierSku;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (minOrderQuantity != null) result.minOrderQuantity = minOrderQuantity;
    if (unit != null) result.unit = unit;
    if (leadTimeDays != null) result.leadTimeDays = leadTimeDays;
    if (status != null) result.status = status;
    if (supplyKind != null) result.supplyKind = supplyKind;
    if (productVariantId != null) result.productVariantId = productVariantId;
    return result;
  }

  SupplierItemSaveRequest._();

  factory SupplierItemSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSaveRequest()..mergeFromBuffer(data, registry);
  factory SupplierItemSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierItemSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierItemSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..aOS(3, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOS(4, _omitFieldNames ? '' : 'supplierSku')
    ..aOM<$1.Money>(5, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $1.Money.$_createMessage)
    ..aD(6, _omitFieldNames ? '' : 'minOrderQuantity')
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..aI(8, _omitFieldNames ? '' : 'leadTimeDays')
    ..aE<SupplierItemStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: SupplierItemStatus.values)
    ..aE<SupplyKind>(10, _omitFieldNames ? '' : 'supplyKind',
        enumValues: SupplyKind.values)
    ..aOS(11, _omitFieldNames ? '' : 'productVariantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSaveRequest copyWith(
          void Function(SupplierItemSaveRequest) updates) =>
      super.copyWith((message) => updates(message as SupplierItemSaveRequest))
          as SupplierItemSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierItemSaveRequest() / SupplierItemSaveRequest.new instead')
  static SupplierItemSaveRequest create() => SupplierItemSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => SupplierItemSaveRequest._();
  @$core.override
  SupplierItemSaveRequest createEmptyInstance() => SupplierItemSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierItemSaveRequest>(
          SupplierItemSaveRequest.$_createMessage);
  static SupplierItemSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get inventoryItemId => $_getSZ(2);
  @$pb.TagNumber(3)
  set inventoryItemId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInventoryItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInventoryItemId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get supplierSku => $_getSZ(3);
  @$pb.TagNumber(4)
  set supplierSku($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSupplierSku() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupplierSku() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($1.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get minOrderQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set minOrderQuantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinOrderQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinOrderQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadTimeDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadTimeDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeadTimeDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadTimeDays() => $_clearField(8);

  @$pb.TagNumber(9)
  SupplierItemStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SupplierItemStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  /// Fixed when the item is created. Unspecified with an inventory_item_id
  /// means SUPPLY_KIND_MATERIAL.
  @$pb.TagNumber(10)
  SupplyKind get supplyKind => $_getN(9);
  @$pb.TagNumber(10)
  set supplyKind(SupplyKind value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSupplyKind() => $_has(9);
  @$pb.TagNumber(10)
  void clearSupplyKind() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get productVariantId => $_getSZ(10);
  @$pb.TagNumber(11)
  set productVariantId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProductVariantId() => $_has(10);
  @$pb.TagNumber(11)
  void clearProductVariantId() => $_clearField(11);
}

class SupplierItemSaveResponse extends $pb.GeneratedMessage {
  factory SupplierItemSaveResponse({
    SupplierItem? supplierItem,
  }) {
    final result = SupplierItemSaveResponse._();
    if (supplierItem != null) result.supplierItem = supplierItem;
    return result;
  }

  SupplierItemSaveResponse._();

  factory SupplierItemSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSaveResponse()..mergeFromBuffer(data, registry);
  factory SupplierItemSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierItemSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierItemSaveResponse.$_createMessage)
    ..aOM<SupplierItem>(1, _omitFieldNames ? '' : 'supplierItem',
        subBuilder: SupplierItem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSaveResponse copyWith(
          void Function(SupplierItemSaveResponse) updates) =>
      super.copyWith((message) => updates(message as SupplierItemSaveResponse))
          as SupplierItemSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierItemSaveResponse() / SupplierItemSaveResponse.new instead')
  static SupplierItemSaveResponse create() => SupplierItemSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => SupplierItemSaveResponse._();
  @$core.override
  SupplierItemSaveResponse createEmptyInstance() =>
      SupplierItemSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierItemSaveResponse>(
          SupplierItemSaveResponse.$_createMessage);
  static SupplierItemSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SupplierItem get supplierItem => $_getN(0);
  @$pb.TagNumber(1)
  set supplierItem(SupplierItem value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplierItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierItem() => $_clearField(1);
  @$pb.TagNumber(1)
  SupplierItem ensureSupplierItem() => $_ensure(0);
}

class SupplierItemSearchRequest extends $pb.GeneratedMessage {
  factory SupplierItemSearchRequest({
    $core.String? supplierId,
    $core.String? inventoryItemId,
    $2.SearchRequest? search,
  }) {
    final result = SupplierItemSearchRequest._();
    if (supplierId != null) result.supplierId = supplierId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (search != null) result.search = search;
    return result;
  }

  SupplierItemSearchRequest._();

  factory SupplierItemSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSearchRequest()..mergeFromBuffer(data, registry);
  factory SupplierItemSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierItemSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierItemSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'supplierId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..aOM<$2.SearchRequest>(3, _omitFieldNames ? '' : 'search',
        subBuilder: $2.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSearchRequest copyWith(
          void Function(SupplierItemSearchRequest) updates) =>
      super.copyWith((message) => updates(message as SupplierItemSearchRequest))
          as SupplierItemSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierItemSearchRequest() / SupplierItemSearchRequest.new instead')
  static SupplierItemSearchRequest create() => SupplierItemSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SupplierItemSearchRequest._();
  @$core.override
  SupplierItemSearchRequest createEmptyInstance() =>
      SupplierItemSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierItemSearchRequest>(
          SupplierItemSearchRequest.$_createMessage);
  static SupplierItemSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplierId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($2.SearchRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.SearchRequest ensureSearch() => $_ensure(2);
}

class SupplierItemSearchResponse extends $pb.GeneratedMessage {
  factory SupplierItemSearchResponse({
    $core.Iterable<SupplierItem>? supplierItems,
    $core.String? nextPage,
  }) {
    final result = SupplierItemSearchResponse._();
    if (supplierItems != null) result.supplierItems.addAll(supplierItems);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  SupplierItemSearchResponse._();

  factory SupplierItemSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSearchResponse()..mergeFromBuffer(data, registry);
  factory SupplierItemSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SupplierItemSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplierItemSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SupplierItemSearchResponse.$_createMessage)
    ..pPM<SupplierItem>(1, _omitFieldNames ? '' : 'supplierItems',
        subBuilder: SupplierItem.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplierItemSearchResponse copyWith(
          void Function(SupplierItemSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SupplierItemSearchResponse))
          as SupplierItemSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SupplierItemSearchResponse() / SupplierItemSearchResponse.new instead')
  static SupplierItemSearchResponse create() => SupplierItemSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SupplierItemSearchResponse._();
  @$core.override
  SupplierItemSearchResponse createEmptyInstance() =>
      SupplierItemSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static SupplierItemSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplierItemSearchResponse>(
          SupplierItemSearchResponse.$_createMessage);
  static SupplierItemSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SupplierItem> get supplierItems => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class PurchaseOrderCreateRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderCreateRequest({
    $core.String? idempotencyKey,
    $core.String? propertyId,
    $core.String? supplierId,
    $0.Timestamp? expectedDeliveryDate,
    $core.String? notes,
    $core.String? planId,
    $core.Iterable<PurchaseOrderLineInput>? lines,
  }) {
    final result = PurchaseOrderCreateRequest._();
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (propertyId != null) result.propertyId = propertyId;
    if (supplierId != null) result.supplierId = supplierId;
    if (expectedDeliveryDate != null)
      result.expectedDeliveryDate = expectedDeliveryDate;
    if (notes != null) result.notes = notes;
    if (planId != null) result.planId = planId;
    if (lines != null) result.lines.addAll(lines);
    return result;
  }

  PurchaseOrderCreateRequest._();

  factory PurchaseOrderCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCreateRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..aOS(3, _omitFieldNames ? '' : 'supplierId')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'expectedDeliveryDate',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..aOS(6, _omitFieldNames ? '' : 'planId')
    ..pPM<PurchaseOrderLineInput>(7, _omitFieldNames ? '' : 'lines',
        subBuilder: PurchaseOrderLineInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCreateRequest copyWith(
          void Function(PurchaseOrderCreateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderCreateRequest))
          as PurchaseOrderCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCreateRequest() / PurchaseOrderCreateRequest.new instead')
  static PurchaseOrderCreateRequest create() => PurchaseOrderCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCreateRequest._();
  @$core.override
  PurchaseOrderCreateRequest createEmptyInstance() =>
      PurchaseOrderCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCreateRequest>(
          PurchaseOrderCreateRequest.$_createMessage);
  static PurchaseOrderCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get idempotencyKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set idempotencyKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdempotencyKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdempotencyKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get supplierId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supplierId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupplierId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupplierId() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get expectedDeliveryDate => $_getN(3);
  @$pb.TagNumber(4)
  set expectedDeliveryDate($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedDeliveryDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedDeliveryDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureExpectedDeliveryDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get planId => $_getSZ(5);
  @$pb.TagNumber(6)
  set planId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPlanId() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlanId() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<PurchaseOrderLineInput> get lines => $_getList(6);
}

class PurchaseOrderLineInput extends $pb.GeneratedMessage {
  factory PurchaseOrderLineInput({
    $core.String? supplierItemId,
    $core.String? inventoryItemId,
    $core.double? orderedQuantity,
    $core.String? unit,
  }) {
    final result = PurchaseOrderLineInput._();
    if (supplierItemId != null) result.supplierItemId = supplierItemId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (orderedQuantity != null) result.orderedQuantity = orderedQuantity;
    if (unit != null) result.unit = unit;
    return result;
  }

  PurchaseOrderLineInput._();

  factory PurchaseOrderLineInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderLineInput()..mergeFromBuffer(data, registry);
  factory PurchaseOrderLineInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderLineInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderLineInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderLineInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'supplierItemId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..aD(3, _omitFieldNames ? '' : 'orderedQuantity')
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderLineInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderLineInput copyWith(
          void Function(PurchaseOrderLineInput) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderLineInput))
          as PurchaseOrderLineInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderLineInput() / PurchaseOrderLineInput.new instead')
  static PurchaseOrderLineInput create() => PurchaseOrderLineInput._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrderLineInput._();
  @$core.override
  PurchaseOrderLineInput createEmptyInstance() => PurchaseOrderLineInput._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderLineInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderLineInput>(
          PurchaseOrderLineInput.$_createMessage);
  static PurchaseOrderLineInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get supplierItemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supplierItemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupplierItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupplierItemId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get orderedQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set orderedQuantity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderedQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderedQuantity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => $_clearField(4);
}

class PurchaseOrderCreateResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderCreateResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final result = PurchaseOrderCreateResponse._();
    if (purchaseOrder != null) result.purchaseOrder = purchaseOrder;
    return result;
  }

  PurchaseOrderCreateResponse._();

  factory PurchaseOrderCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCreateResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCreateResponse.$_createMessage)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder',
        subBuilder: PurchaseOrder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCreateResponse copyWith(
          void Function(PurchaseOrderCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderCreateResponse))
          as PurchaseOrderCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCreateResponse() / PurchaseOrderCreateResponse.new instead')
  static PurchaseOrderCreateResponse create() =>
      PurchaseOrderCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCreateResponse._();
  @$core.override
  PurchaseOrderCreateResponse createEmptyInstance() =>
      PurchaseOrderCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCreateResponse>(
          PurchaseOrderCreateResponse.$_createMessage);
  static PurchaseOrderCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderGetRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderGetRequest({
    $core.String? id,
  }) {
    final result = PurchaseOrderGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PurchaseOrderGetRequest._();

  factory PurchaseOrderGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderGetRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderGetRequest copyWith(
          void Function(PurchaseOrderGetRequest) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderGetRequest))
          as PurchaseOrderGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderGetRequest() / PurchaseOrderGetRequest.new instead')
  static PurchaseOrderGetRequest create() => PurchaseOrderGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrderGetRequest._();
  @$core.override
  PurchaseOrderGetRequest createEmptyInstance() => PurchaseOrderGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderGetRequest>(
          PurchaseOrderGetRequest.$_createMessage);
  static PurchaseOrderGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PurchaseOrderGetResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderGetResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final result = PurchaseOrderGetResponse._();
    if (purchaseOrder != null) result.purchaseOrder = purchaseOrder;
    return result;
  }

  PurchaseOrderGetResponse._();

  factory PurchaseOrderGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderGetResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderGetResponse.$_createMessage)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder',
        subBuilder: PurchaseOrder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderGetResponse copyWith(
          void Function(PurchaseOrderGetResponse) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderGetResponse))
          as PurchaseOrderGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderGetResponse() / PurchaseOrderGetResponse.new instead')
  static PurchaseOrderGetResponse create() => PurchaseOrderGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => PurchaseOrderGetResponse._();
  @$core.override
  PurchaseOrderGetResponse createEmptyInstance() =>
      PurchaseOrderGetResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderGetResponse>(
          PurchaseOrderGetResponse.$_createMessage);
  static PurchaseOrderGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderSearchRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderSearchRequest({
    $core.String? propertyId,
    $core.String? supplierId,
    PurchaseOrderStatus? status,
    $2.SearchRequest? search,
  }) {
    final result = PurchaseOrderSearchRequest._();
    if (propertyId != null) result.propertyId = propertyId;
    if (supplierId != null) result.supplierId = supplierId;
    if (status != null) result.status = status;
    if (search != null) result.search = search;
    return result;
  }

  PurchaseOrderSearchRequest._();

  factory PurchaseOrderSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSearchRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'propertyId')
    ..aOS(2, _omitFieldNames ? '' : 'supplierId')
    ..aE<PurchaseOrderStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: PurchaseOrderStatus.values)
    ..aOM<$2.SearchRequest>(4, _omitFieldNames ? '' : 'search',
        subBuilder: $2.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSearchRequest copyWith(
          void Function(PurchaseOrderSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderSearchRequest))
          as PurchaseOrderSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSearchRequest() / PurchaseOrderSearchRequest.new instead')
  static PurchaseOrderSearchRequest create() => PurchaseOrderSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderSearchRequest._();
  @$core.override
  PurchaseOrderSearchRequest createEmptyInstance() =>
      PurchaseOrderSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSearchRequest>(
          PurchaseOrderSearchRequest.$_createMessage);
  static PurchaseOrderSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get propertyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set propertyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPropertyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPropertyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get supplierId => $_getSZ(1);
  @$pb.TagNumber(2)
  set supplierId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSupplierId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupplierId() => $_clearField(2);

  @$pb.TagNumber(3)
  PurchaseOrderStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(PurchaseOrderStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.SearchRequest get search => $_getN(3);
  @$pb.TagNumber(4)
  set search($2.SearchRequest value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSearch() => $_has(3);
  @$pb.TagNumber(4)
  void clearSearch() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.SearchRequest ensureSearch() => $_ensure(3);
}

class PurchaseOrderSearchResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderSearchResponse({
    $core.Iterable<PurchaseOrder>? purchaseOrders,
    $core.String? nextPage,
  }) {
    final result = PurchaseOrderSearchResponse._();
    if (purchaseOrders != null) result.purchaseOrders.addAll(purchaseOrders);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  PurchaseOrderSearchResponse._();

  factory PurchaseOrderSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSearchResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSearchResponse.$_createMessage)
    ..pPM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrders',
        subBuilder: PurchaseOrder.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSearchResponse copyWith(
          void Function(PurchaseOrderSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderSearchResponse))
          as PurchaseOrderSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSearchResponse() / PurchaseOrderSearchResponse.new instead')
  static PurchaseOrderSearchResponse create() =>
      PurchaseOrderSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderSearchResponse._();
  @$core.override
  PurchaseOrderSearchResponse createEmptyInstance() =>
      PurchaseOrderSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSearchResponse>(
          PurchaseOrderSearchResponse.$_createMessage);
  static PurchaseOrderSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PurchaseOrder> get purchaseOrders => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class PurchaseOrderSubmitRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderSubmitRequest({
    $core.String? id,
  }) {
    final result = PurchaseOrderSubmitRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PurchaseOrderSubmitRequest._();

  factory PurchaseOrderSubmitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSubmitRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSubmitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSubmitRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSubmitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSubmitRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSubmitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSubmitRequest copyWith(
          void Function(PurchaseOrderSubmitRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderSubmitRequest))
          as PurchaseOrderSubmitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSubmitRequest() / PurchaseOrderSubmitRequest.new instead')
  static PurchaseOrderSubmitRequest create() => PurchaseOrderSubmitRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderSubmitRequest._();
  @$core.override
  PurchaseOrderSubmitRequest createEmptyInstance() =>
      PurchaseOrderSubmitRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSubmitRequest>(
          PurchaseOrderSubmitRequest.$_createMessage);
  static PurchaseOrderSubmitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PurchaseOrderSubmitResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderSubmitResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final result = PurchaseOrderSubmitResponse._();
    if (purchaseOrder != null) result.purchaseOrder = purchaseOrder;
    return result;
  }

  PurchaseOrderSubmitResponse._();

  factory PurchaseOrderSubmitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSubmitResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderSubmitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderSubmitResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderSubmitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderSubmitResponse.$_createMessage)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder',
        subBuilder: PurchaseOrder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSubmitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderSubmitResponse copyWith(
          void Function(PurchaseOrderSubmitResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderSubmitResponse))
          as PurchaseOrderSubmitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderSubmitResponse() / PurchaseOrderSubmitResponse.new instead')
  static PurchaseOrderSubmitResponse create() =>
      PurchaseOrderSubmitResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderSubmitResponse._();
  @$core.override
  PurchaseOrderSubmitResponse createEmptyInstance() =>
      PurchaseOrderSubmitResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderSubmitResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderSubmitResponse>(
          PurchaseOrderSubmitResponse.$_createMessage);
  static PurchaseOrderSubmitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderCancelRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = PurchaseOrderCancelRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  PurchaseOrderCancelRequest._();

  factory PurchaseOrderCancelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCancelRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCancelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCancelRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCancelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCancelRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCancelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCancelRequest copyWith(
          void Function(PurchaseOrderCancelRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderCancelRequest))
          as PurchaseOrderCancelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCancelRequest() / PurchaseOrderCancelRequest.new instead')
  static PurchaseOrderCancelRequest create() => PurchaseOrderCancelRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCancelRequest._();
  @$core.override
  PurchaseOrderCancelRequest createEmptyInstance() =>
      PurchaseOrderCancelRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCancelRequest>(
          PurchaseOrderCancelRequest.$_createMessage);
  static PurchaseOrderCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class PurchaseOrderCancelResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderCancelResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final result = PurchaseOrderCancelResponse._();
    if (purchaseOrder != null) result.purchaseOrder = purchaseOrder;
    return result;
  }

  PurchaseOrderCancelResponse._();

  factory PurchaseOrderCancelResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCancelResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCancelResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCancelResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCancelResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCancelResponse.$_createMessage)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder',
        subBuilder: PurchaseOrder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCancelResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCancelResponse copyWith(
          void Function(PurchaseOrderCancelResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderCancelResponse))
          as PurchaseOrderCancelResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCancelResponse() / PurchaseOrderCancelResponse.new instead')
  static PurchaseOrderCancelResponse create() =>
      PurchaseOrderCancelResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCancelResponse._();
  @$core.override
  PurchaseOrderCancelResponse createEmptyInstance() =>
      PurchaseOrderCancelResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCancelResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCancelResponse>(
          PurchaseOrderCancelResponse.$_createMessage);
  static PurchaseOrderCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  PurchaseOrder ensurePurchaseOrder() => $_ensure(0);
}

class PurchaseOrderCloseRequest extends $pb.GeneratedMessage {
  factory PurchaseOrderCloseRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = PurchaseOrderCloseRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  PurchaseOrderCloseRequest._();

  factory PurchaseOrderCloseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCloseRequest()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCloseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCloseRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCloseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCloseRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCloseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCloseRequest copyWith(
          void Function(PurchaseOrderCloseRequest) updates) =>
      super.copyWith((message) => updates(message as PurchaseOrderCloseRequest))
          as PurchaseOrderCloseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCloseRequest() / PurchaseOrderCloseRequest.new instead')
  static PurchaseOrderCloseRequest create() => PurchaseOrderCloseRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCloseRequest._();
  @$core.override
  PurchaseOrderCloseRequest createEmptyInstance() =>
      PurchaseOrderCloseRequest._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCloseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCloseRequest>(
          PurchaseOrderCloseRequest.$_createMessage);
  static PurchaseOrderCloseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class PurchaseOrderCloseResponse extends $pb.GeneratedMessage {
  factory PurchaseOrderCloseResponse({
    PurchaseOrder? purchaseOrder,
  }) {
    final result = PurchaseOrderCloseResponse._();
    if (purchaseOrder != null) result.purchaseOrder = purchaseOrder;
    return result;
  }

  PurchaseOrderCloseResponse._();

  factory PurchaseOrderCloseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCloseResponse()..mergeFromBuffer(data, registry);
  factory PurchaseOrderCloseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PurchaseOrderCloseResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurchaseOrderCloseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: PurchaseOrderCloseResponse.$_createMessage)
    ..aOM<PurchaseOrder>(1, _omitFieldNames ? '' : 'purchaseOrder',
        subBuilder: PurchaseOrder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCloseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurchaseOrderCloseResponse copyWith(
          void Function(PurchaseOrderCloseResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PurchaseOrderCloseResponse))
          as PurchaseOrderCloseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PurchaseOrderCloseResponse() / PurchaseOrderCloseResponse.new instead')
  static PurchaseOrderCloseResponse create() => PurchaseOrderCloseResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PurchaseOrderCloseResponse._();
  @$core.override
  PurchaseOrderCloseResponse createEmptyInstance() =>
      PurchaseOrderCloseResponse._();
  @$core.pragma('dart2js:noInline')
  static PurchaseOrderCloseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurchaseOrderCloseResponse>(
          PurchaseOrderCloseResponse.$_createMessage);
  static PurchaseOrderCloseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PurchaseOrder get purchaseOrder => $_getN(0);
  @$pb.TagNumber(1)
  set purchaseOrder(PurchaseOrder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrder() => $_clearField(1);
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
    $core.String? stockLocationId,
  }) {
    final result = GoodsReceiptCreateRequest._();
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (purchaseOrderId != null) result.purchaseOrderId = purchaseOrderId;
    if (propertyId != null) result.propertyId = propertyId;
    if (notes != null) result.notes = notes;
    if (lines != null) result.lines.addAll(lines);
    if (stockLocationId != null) result.stockLocationId = stockLocationId;
    return result;
  }

  GoodsReceiptCreateRequest._();

  factory GoodsReceiptCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptCreateRequest()..mergeFromBuffer(data, registry);
  factory GoodsReceiptCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(2, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(3, _omitFieldNames ? '' : 'propertyId')
    ..aOS(4, _omitFieldNames ? '' : 'notes')
    ..pPM<GoodsReceiptLineInput>(5, _omitFieldNames ? '' : 'lines',
        subBuilder: GoodsReceiptLineInput.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'stockLocationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptCreateRequest copyWith(
          void Function(GoodsReceiptCreateRequest) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptCreateRequest))
          as GoodsReceiptCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptCreateRequest() / GoodsReceiptCreateRequest.new instead')
  static GoodsReceiptCreateRequest create() => GoodsReceiptCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptCreateRequest._();
  @$core.override
  GoodsReceiptCreateRequest createEmptyInstance() =>
      GoodsReceiptCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptCreateRequest>(
          GoodsReceiptCreateRequest.$_createMessage);
  static GoodsReceiptCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get idempotencyKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set idempotencyKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdempotencyKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdempotencyKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get purchaseOrderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set purchaseOrderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPurchaseOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseOrderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get propertyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set propertyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPropertyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPropertyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get notes => $_getSZ(3);
  @$pb.TagNumber(4)
  set notes($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotes() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotes() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<GoodsReceiptLineInput> get lines => $_getList(4);

  /// Manufacturing stock location raw materials are put away in. With one,
  /// raw material lines are booked into manufacturing inventory
  /// automatically; without, they wait (STOCK_DELIVERY_STATUS_PENDING_TRANSFER)
  /// until staff choose a location or book them by hand.
  @$pb.TagNumber(6)
  $core.String get stockLocationId => $_getSZ(5);
  @$pb.TagNumber(6)
  set stockLocationId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStockLocationId() => $_has(5);
  @$pb.TagNumber(6)
  void clearStockLocationId() => $_clearField(6);
}

class GoodsReceiptLineInput extends $pb.GeneratedMessage {
  factory GoodsReceiptLineInput({
    $core.String? purchaseOrderLineId,
    $core.String? inventoryItemId,
    $core.double? receivedQuantity,
    $core.String? lotNumber,
    $0.Timestamp? expiryDate,
    $core.String? unit,
  }) {
    final result = GoodsReceiptLineInput._();
    if (purchaseOrderLineId != null)
      result.purchaseOrderLineId = purchaseOrderLineId;
    if (inventoryItemId != null) result.inventoryItemId = inventoryItemId;
    if (receivedQuantity != null) result.receivedQuantity = receivedQuantity;
    if (lotNumber != null) result.lotNumber = lotNumber;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (unit != null) result.unit = unit;
    return result;
  }

  GoodsReceiptLineInput._();

  factory GoodsReceiptLineInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineInput()..mergeFromBuffer(data, registry);
  factory GoodsReceiptLineInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptLineInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptLineInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'purchaseOrderLineId')
    ..aOS(2, _omitFieldNames ? '' : 'inventoryItemId')
    ..aD(3, _omitFieldNames ? '' : 'receivedQuantity')
    ..aOS(4, _omitFieldNames ? '' : 'lotNumber')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineInput copyWith(
          void Function(GoodsReceiptLineInput) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptLineInput))
          as GoodsReceiptLineInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptLineInput() / GoodsReceiptLineInput.new instead')
  static GoodsReceiptLineInput create() => GoodsReceiptLineInput._();
  static $pb.GeneratedMessage $_createMessage() => GoodsReceiptLineInput._();
  @$core.override
  GoodsReceiptLineInput createEmptyInstance() => GoodsReceiptLineInput._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLineInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLineInput>(
          GoodsReceiptLineInput.$_createMessage);
  static GoodsReceiptLineInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get purchaseOrderLineId => $_getSZ(0);
  @$pb.TagNumber(1)
  set purchaseOrderLineId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrderLineId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrderLineId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inventoryItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inventoryItemId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInventoryItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInventoryItemId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get receivedQuantity => $_getN(2);
  @$pb.TagNumber(3)
  set receivedQuantity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReceivedQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedQuantity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lotNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set lotNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLotNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearLotNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get expiryDate => $_getN(4);
  @$pb.TagNumber(5)
  set expiryDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiryDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiryDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureExpiryDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get unit => $_getSZ(5);
  @$pb.TagNumber(6)
  set unit($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUnit() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnit() => $_clearField(6);
}

class GoodsReceiptCreateResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptCreateResponse({
    GoodsReceipt? goodsReceipt,
  }) {
    final result = GoodsReceiptCreateResponse._();
    if (goodsReceipt != null) result.goodsReceipt = goodsReceipt;
    return result;
  }

  GoodsReceiptCreateResponse._();

  factory GoodsReceiptCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptCreateResponse()..mergeFromBuffer(data, registry);
  factory GoodsReceiptCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptCreateResponse.$_createMessage)
    ..aOM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipt',
        subBuilder: GoodsReceipt.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptCreateResponse copyWith(
          void Function(GoodsReceiptCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptCreateResponse))
          as GoodsReceiptCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptCreateResponse() / GoodsReceiptCreateResponse.new instead')
  static GoodsReceiptCreateResponse create() => GoodsReceiptCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptCreateResponse._();
  @$core.override
  GoodsReceiptCreateResponse createEmptyInstance() =>
      GoodsReceiptCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptCreateResponse>(
          GoodsReceiptCreateResponse.$_createMessage);
  static GoodsReceiptCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GoodsReceipt get goodsReceipt => $_getN(0);
  @$pb.TagNumber(1)
  set goodsReceipt(GoodsReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  GoodsReceipt ensureGoodsReceipt() => $_ensure(0);
}

class GoodsReceiptGetRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptGetRequest({
    $core.String? id,
  }) {
    final result = GoodsReceiptGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GoodsReceiptGetRequest._();

  factory GoodsReceiptGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptGetRequest()..mergeFromBuffer(data, registry);
  factory GoodsReceiptGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptGetRequest copyWith(
          void Function(GoodsReceiptGetRequest) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptGetRequest))
          as GoodsReceiptGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptGetRequest() / GoodsReceiptGetRequest.new instead')
  static GoodsReceiptGetRequest create() => GoodsReceiptGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoodsReceiptGetRequest._();
  @$core.override
  GoodsReceiptGetRequest createEmptyInstance() => GoodsReceiptGetRequest._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptGetRequest>(
          GoodsReceiptGetRequest.$_createMessage);
  static GoodsReceiptGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GoodsReceiptGetResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptGetResponse({
    GoodsReceipt? goodsReceipt,
  }) {
    final result = GoodsReceiptGetResponse._();
    if (goodsReceipt != null) result.goodsReceipt = goodsReceipt;
    return result;
  }

  GoodsReceiptGetResponse._();

  factory GoodsReceiptGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptGetResponse()..mergeFromBuffer(data, registry);
  factory GoodsReceiptGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptGetResponse.$_createMessage)
    ..aOM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipt',
        subBuilder: GoodsReceipt.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptGetResponse copyWith(
          void Function(GoodsReceiptGetResponse) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptGetResponse))
          as GoodsReceiptGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptGetResponse() / GoodsReceiptGetResponse.new instead')
  static GoodsReceiptGetResponse create() => GoodsReceiptGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => GoodsReceiptGetResponse._();
  @$core.override
  GoodsReceiptGetResponse createEmptyInstance() => GoodsReceiptGetResponse._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptGetResponse>(
          GoodsReceiptGetResponse.$_createMessage);
  static GoodsReceiptGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GoodsReceipt get goodsReceipt => $_getN(0);
  @$pb.TagNumber(1)
  set goodsReceipt(GoodsReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  GoodsReceipt ensureGoodsReceipt() => $_ensure(0);
}

class GoodsReceiptSearchRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptSearchRequest({
    $core.String? purchaseOrderId,
    $core.String? propertyId,
    GoodsReceiptStatus? status,
    $2.SearchRequest? search,
  }) {
    final result = GoodsReceiptSearchRequest._();
    if (purchaseOrderId != null) result.purchaseOrderId = purchaseOrderId;
    if (propertyId != null) result.propertyId = propertyId;
    if (status != null) result.status = status;
    if (search != null) result.search = search;
    return result;
  }

  GoodsReceiptSearchRequest._();

  factory GoodsReceiptSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptSearchRequest()..mergeFromBuffer(data, registry);
  factory GoodsReceiptSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'purchaseOrderId')
    ..aOS(2, _omitFieldNames ? '' : 'propertyId')
    ..aE<GoodsReceiptStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: GoodsReceiptStatus.values)
    ..aOM<$2.SearchRequest>(4, _omitFieldNames ? '' : 'search',
        subBuilder: $2.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptSearchRequest copyWith(
          void Function(GoodsReceiptSearchRequest) updates) =>
      super.copyWith((message) => updates(message as GoodsReceiptSearchRequest))
          as GoodsReceiptSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptSearchRequest() / GoodsReceiptSearchRequest.new instead')
  static GoodsReceiptSearchRequest create() => GoodsReceiptSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptSearchRequest._();
  @$core.override
  GoodsReceiptSearchRequest createEmptyInstance() =>
      GoodsReceiptSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptSearchRequest>(
          GoodsReceiptSearchRequest.$_createMessage);
  static GoodsReceiptSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get purchaseOrderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set purchaseOrderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPurchaseOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPurchaseOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get propertyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set propertyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPropertyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPropertyId() => $_clearField(2);

  @$pb.TagNumber(3)
  GoodsReceiptStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(GoodsReceiptStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.SearchRequest get search => $_getN(3);
  @$pb.TagNumber(4)
  set search($2.SearchRequest value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSearch() => $_has(3);
  @$pb.TagNumber(4)
  void clearSearch() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.SearchRequest ensureSearch() => $_ensure(3);
}

class GoodsReceiptSearchResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptSearchResponse({
    $core.Iterable<GoodsReceipt>? goodsReceipts,
    $core.String? nextPage,
  }) {
    final result = GoodsReceiptSearchResponse._();
    if (goodsReceipts != null) result.goodsReceipts.addAll(goodsReceipts);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  GoodsReceiptSearchResponse._();

  factory GoodsReceiptSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptSearchResponse()..mergeFromBuffer(data, registry);
  factory GoodsReceiptSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptSearchResponse.$_createMessage)
    ..pPM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipts',
        subBuilder: GoodsReceipt.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptSearchResponse copyWith(
          void Function(GoodsReceiptSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptSearchResponse))
          as GoodsReceiptSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptSearchResponse() / GoodsReceiptSearchResponse.new instead')
  static GoodsReceiptSearchResponse create() => GoodsReceiptSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptSearchResponse._();
  @$core.override
  GoodsReceiptSearchResponse createEmptyInstance() =>
      GoodsReceiptSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptSearchResponse>(
          GoodsReceiptSearchResponse.$_createMessage);
  static GoodsReceiptSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GoodsReceipt> get goodsReceipts => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class SuggestPurchaseOrdersRequest extends $pb.GeneratedMessage {
  factory SuggestPurchaseOrdersRequest({
    $core.String? propertyId,
    $core.String? planId,
    $core.String? currencyCode,
  }) {
    final result = SuggestPurchaseOrdersRequest._();
    if (propertyId != null) result.propertyId = propertyId;
    if (planId != null) result.planId = planId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    return result;
  }

  SuggestPurchaseOrdersRequest._();

  factory SuggestPurchaseOrdersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SuggestPurchaseOrdersRequest()..mergeFromBuffer(data, registry);
  factory SuggestPurchaseOrdersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SuggestPurchaseOrdersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SuggestPurchaseOrdersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SuggestPurchaseOrdersRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'propertyId')
    ..aOS(2, _omitFieldNames ? '' : 'planId')
    ..aOS(3, _omitFieldNames ? '' : 'currencyCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SuggestPurchaseOrdersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SuggestPurchaseOrdersRequest copyWith(
          void Function(SuggestPurchaseOrdersRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SuggestPurchaseOrdersRequest))
          as SuggestPurchaseOrdersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SuggestPurchaseOrdersRequest() / SuggestPurchaseOrdersRequest.new instead')
  static SuggestPurchaseOrdersRequest create() =>
      SuggestPurchaseOrdersRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SuggestPurchaseOrdersRequest._();
  @$core.override
  SuggestPurchaseOrdersRequest createEmptyInstance() =>
      SuggestPurchaseOrdersRequest._();
  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SuggestPurchaseOrdersRequest>(
          SuggestPurchaseOrdersRequest.$_createMessage);
  static SuggestPurchaseOrdersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get propertyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set propertyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPropertyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPropertyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get planId => $_getSZ(1);
  @$pb.TagNumber(2)
  set planId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlanId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlanId() => $_clearField(2);

  /// Only supplier items priced in this currency are considered. When empty,
  /// a material offered in more than one currency is left unsourced rather
  /// than compared across currencies.
  @$pb.TagNumber(3)
  $core.String get currencyCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set currencyCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrencyCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrencyCode() => $_clearField(3);
}

class SuggestPurchaseOrdersResponse extends $pb.GeneratedMessage {
  factory SuggestPurchaseOrdersResponse({
    $core.Iterable<PurchaseOrderSuggestion>? suggestions,
  }) {
    final result = SuggestPurchaseOrdersResponse._();
    if (suggestions != null) result.suggestions.addAll(suggestions);
    return result;
  }

  SuggestPurchaseOrdersResponse._();

  factory SuggestPurchaseOrdersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SuggestPurchaseOrdersResponse()..mergeFromBuffer(data, registry);
  factory SuggestPurchaseOrdersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SuggestPurchaseOrdersResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SuggestPurchaseOrdersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: SuggestPurchaseOrdersResponse.$_createMessage)
    ..pPM<PurchaseOrderSuggestion>(1, _omitFieldNames ? '' : 'suggestions',
        subBuilder: PurchaseOrderSuggestion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SuggestPurchaseOrdersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SuggestPurchaseOrdersResponse copyWith(
          void Function(SuggestPurchaseOrdersResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SuggestPurchaseOrdersResponse))
          as SuggestPurchaseOrdersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SuggestPurchaseOrdersResponse() / SuggestPurchaseOrdersResponse.new instead')
  static SuggestPurchaseOrdersResponse create() =>
      SuggestPurchaseOrdersResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SuggestPurchaseOrdersResponse._();
  @$core.override
  SuggestPurchaseOrdersResponse createEmptyInstance() =>
      SuggestPurchaseOrdersResponse._();
  @$core.pragma('dart2js:noInline')
  static SuggestPurchaseOrdersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SuggestPurchaseOrdersResponse>(
          SuggestPurchaseOrdersResponse.$_createMessage);
  static SuggestPurchaseOrdersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PurchaseOrderSuggestion> get suggestions => $_getList(0);
}

class GoodsReceiptDeliverRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptDeliverRequest({
    $core.int? limit,
  }) {
    final result = GoodsReceiptDeliverRequest._();
    if (limit != null) result.limit = limit;
    return result;
  }

  GoodsReceiptDeliverRequest._();

  factory GoodsReceiptDeliverRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptDeliverRequest()..mergeFromBuffer(data, registry);
  factory GoodsReceiptDeliverRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptDeliverRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptDeliverRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptDeliverRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptDeliverRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptDeliverRequest copyWith(
          void Function(GoodsReceiptDeliverRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptDeliverRequest))
          as GoodsReceiptDeliverRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptDeliverRequest() / GoodsReceiptDeliverRequest.new instead')
  static GoodsReceiptDeliverRequest create() => GoodsReceiptDeliverRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptDeliverRequest._();
  @$core.override
  GoodsReceiptDeliverRequest createEmptyInstance() =>
      GoodsReceiptDeliverRequest._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptDeliverRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptDeliverRequest>(
          GoodsReceiptDeliverRequest.$_createMessage);
  static GoodsReceiptDeliverRequest? _defaultInstance;

  /// Most lines to push in this call; 0 means 100, at most 500.
  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);
}

class GoodsReceiptDeliverResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptDeliverResponse({
    $core.int? delivered,
    $core.int? pending,
    $core.int? failed,
  }) {
    final result = GoodsReceiptDeliverResponse._();
    if (delivered != null) result.delivered = delivered;
    if (pending != null) result.pending = pending;
    if (failed != null) result.failed = failed;
    return result;
  }

  GoodsReceiptDeliverResponse._();

  factory GoodsReceiptDeliverResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptDeliverResponse()..mergeFromBuffer(data, registry);
  factory GoodsReceiptDeliverResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptDeliverResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptDeliverResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptDeliverResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'delivered')
    ..aI(2, _omitFieldNames ? '' : 'pending')
    ..aI(3, _omitFieldNames ? '' : 'failed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptDeliverResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptDeliverResponse copyWith(
          void Function(GoodsReceiptDeliverResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptDeliverResponse))
          as GoodsReceiptDeliverResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptDeliverResponse() / GoodsReceiptDeliverResponse.new instead')
  static GoodsReceiptDeliverResponse create() =>
      GoodsReceiptDeliverResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptDeliverResponse._();
  @$core.override
  GoodsReceiptDeliverResponse createEmptyInstance() =>
      GoodsReceiptDeliverResponse._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptDeliverResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptDeliverResponse>(
          GoodsReceiptDeliverResponse.$_createMessage);
  static GoodsReceiptDeliverResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get delivered => $_getIZ(0);
  @$pb.TagNumber(1)
  set delivered($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDelivered() => $_has(0);
  @$pb.TagNumber(1)
  void clearDelivered() => $_clearField(1);

  /// Still pending after this call (transient failures), to retry later.
  @$pb.TagNumber(2)
  $core.int get pending => $_getIZ(1);
  @$pb.TagNumber(2)
  set pending($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPending() => $_has(1);
  @$pb.TagNumber(2)
  void clearPending() => $_clearField(2);

  /// Refused for good and marked STOCK_DELIVERY_STATUS_FAILED.
  @$pb.TagNumber(3)
  $core.int get failed => $_getIZ(2);
  @$pb.TagNumber(3)
  set failed($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFailed() => $_has(2);
  @$pb.TagNumber(3)
  void clearFailed() => $_clearField(3);
}

class GoodsReceiptLineResolveRequest extends $pb.GeneratedMessage {
  factory GoodsReceiptLineResolveRequest({
    $core.String? goodsReceiptId,
    $core.String? lineId,
    GoodsReceiptLineResolution? resolution,
    $core.String? note,
    $core.String? locationId,
  }) {
    final result = GoodsReceiptLineResolveRequest._();
    if (goodsReceiptId != null) result.goodsReceiptId = goodsReceiptId;
    if (lineId != null) result.lineId = lineId;
    if (resolution != null) result.resolution = resolution;
    if (note != null) result.note = note;
    if (locationId != null) result.locationId = locationId;
    return result;
  }

  GoodsReceiptLineResolveRequest._();

  factory GoodsReceiptLineResolveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineResolveRequest()..mergeFromBuffer(data, registry);
  factory GoodsReceiptLineResolveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineResolveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptLineResolveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptLineResolveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'goodsReceiptId')
    ..aOS(2, _omitFieldNames ? '' : 'lineId')
    ..aE<GoodsReceiptLineResolution>(3, _omitFieldNames ? '' : 'resolution',
        enumValues: GoodsReceiptLineResolution.values)
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..aOS(5, _omitFieldNames ? '' : 'locationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineResolveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineResolveRequest copyWith(
          void Function(GoodsReceiptLineResolveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptLineResolveRequest))
          as GoodsReceiptLineResolveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptLineResolveRequest() / GoodsReceiptLineResolveRequest.new instead')
  static GoodsReceiptLineResolveRequest create() =>
      GoodsReceiptLineResolveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptLineResolveRequest._();
  @$core.override
  GoodsReceiptLineResolveRequest createEmptyInstance() =>
      GoodsReceiptLineResolveRequest._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLineResolveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLineResolveRequest>(
          GoodsReceiptLineResolveRequest.$_createMessage);
  static GoodsReceiptLineResolveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get goodsReceiptId => $_getSZ(0);
  @$pb.TagNumber(1)
  set goodsReceiptId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceiptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceiptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lineId => $_getSZ(1);
  @$pb.TagNumber(2)
  set lineId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLineId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLineId() => $_clearField(2);

  @$pb.TagNumber(3)
  GoodsReceiptLineResolution get resolution => $_getN(2);
  @$pb.TagNumber(3)
  set resolution(GoodsReceiptLineResolution value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResolution() => $_has(2);
  @$pb.TagNumber(3)
  void clearResolution() => $_clearField(3);

  /// Why, or where the stock was booked; at most 1000 characters.
  @$pb.TagNumber(4)
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);

  /// RETRY of a raw material: the manufacturing stock location to book it
  /// into; required unless the line already has one.
  @$pb.TagNumber(5)
  $core.String get locationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set locationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLocationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocationId() => $_clearField(5);
}

class GoodsReceiptLineResolveResponse extends $pb.GeneratedMessage {
  factory GoodsReceiptLineResolveResponse({
    GoodsReceipt? goodsReceipt,
  }) {
    final result = GoodsReceiptLineResolveResponse._();
    if (goodsReceipt != null) result.goodsReceipt = goodsReceipt;
    return result;
  }

  GoodsReceiptLineResolveResponse._();

  factory GoodsReceiptLineResolveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineResolveResponse()..mergeFromBuffer(data, registry);
  factory GoodsReceiptLineResolveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoodsReceiptLineResolveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoodsReceiptLineResolveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'procurement.v1'),
      createEmptyInstance: GoodsReceiptLineResolveResponse.$_createMessage)
    ..aOM<GoodsReceipt>(1, _omitFieldNames ? '' : 'goodsReceipt',
        subBuilder: GoodsReceipt.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineResolveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoodsReceiptLineResolveResponse copyWith(
          void Function(GoodsReceiptLineResolveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GoodsReceiptLineResolveResponse))
          as GoodsReceiptLineResolveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GoodsReceiptLineResolveResponse() / GoodsReceiptLineResolveResponse.new instead')
  static GoodsReceiptLineResolveResponse create() =>
      GoodsReceiptLineResolveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GoodsReceiptLineResolveResponse._();
  @$core.override
  GoodsReceiptLineResolveResponse createEmptyInstance() =>
      GoodsReceiptLineResolveResponse._();
  @$core.pragma('dart2js:noInline')
  static GoodsReceiptLineResolveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoodsReceiptLineResolveResponse>(
          GoodsReceiptLineResolveResponse.$_createMessage);
  static GoodsReceiptLineResolveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GoodsReceipt get goodsReceipt => $_getN(0);
  @$pb.TagNumber(1)
  set goodsReceipt(GoodsReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGoodsReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoodsReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  GoodsReceipt ensureGoodsReceipt() => $_ensure(0);
}

class ProcurementServiceApi {
  final $pb.RpcClient _client;

  ProcurementServiceApi(this._client);

  /// ---- Suppliers ----
  $async.Future<SupplierSaveResponse> supplierSave(
          $pb.ClientContext? ctx, SupplierSaveRequest request) =>
      _client.invoke<SupplierSaveResponse>(ctx, 'ProcurementService',
          'SupplierSave', request, SupplierSaveResponse());
  $async.Future<SupplierGetResponse> supplierGet(
          $pb.ClientContext? ctx, SupplierGetRequest request) =>
      _client.invoke<SupplierGetResponse>(ctx, 'ProcurementService',
          'SupplierGet', request, SupplierGetResponse());
  $async.Future<SupplierSearchResponse> supplierSearch(
          $pb.ClientContext? ctx, SupplierSearchRequest request) =>
      _client.invoke<SupplierSearchResponse>(ctx, 'ProcurementService',
          'SupplierSearch', request, SupplierSearchResponse());

  /// ---- Supplier Items ----
  $async.Future<SupplierItemSaveResponse> supplierItemSave(
          $pb.ClientContext? ctx, SupplierItemSaveRequest request) =>
      _client.invoke<SupplierItemSaveResponse>(ctx, 'ProcurementService',
          'SupplierItemSave', request, SupplierItemSaveResponse());
  $async.Future<SupplierItemSearchResponse> supplierItemSearch(
          $pb.ClientContext? ctx, SupplierItemSearchRequest request) =>
      _client.invoke<SupplierItemSearchResponse>(ctx, 'ProcurementService',
          'SupplierItemSearch', request, SupplierItemSearchResponse());

  /// ---- Purchase Orders ----
  $async.Future<PurchaseOrderCreateResponse> purchaseOrderCreate(
          $pb.ClientContext? ctx, PurchaseOrderCreateRequest request) =>
      _client.invoke<PurchaseOrderCreateResponse>(ctx, 'ProcurementService',
          'PurchaseOrderCreate', request, PurchaseOrderCreateResponse());
  $async.Future<PurchaseOrderGetResponse> purchaseOrderGet(
          $pb.ClientContext? ctx, PurchaseOrderGetRequest request) =>
      _client.invoke<PurchaseOrderGetResponse>(ctx, 'ProcurementService',
          'PurchaseOrderGet', request, PurchaseOrderGetResponse());
  $async.Future<PurchaseOrderSearchResponse> purchaseOrderSearch(
          $pb.ClientContext? ctx, PurchaseOrderSearchRequest request) =>
      _client.invoke<PurchaseOrderSearchResponse>(ctx, 'ProcurementService',
          'PurchaseOrderSearch', request, PurchaseOrderSearchResponse());
  $async.Future<PurchaseOrderSubmitResponse> purchaseOrderSubmit(
          $pb.ClientContext? ctx, PurchaseOrderSubmitRequest request) =>
      _client.invoke<PurchaseOrderSubmitResponse>(ctx, 'ProcurementService',
          'PurchaseOrderSubmit', request, PurchaseOrderSubmitResponse());
  $async.Future<PurchaseOrderCancelResponse> purchaseOrderCancel(
          $pb.ClientContext? ctx, PurchaseOrderCancelRequest request) =>
      _client.invoke<PurchaseOrderCancelResponse>(ctx, 'ProcurementService',
          'PurchaseOrderCancel', request, PurchaseOrderCancelResponse());

  /// Closes a partially received order short: what was received stands, the
  /// remainder of every open line is cancelled and no further receipt is
  /// accepted.
  $async.Future<PurchaseOrderCloseResponse> purchaseOrderClose(
          $pb.ClientContext? ctx, PurchaseOrderCloseRequest request) =>
      _client.invoke<PurchaseOrderCloseResponse>(ctx, 'ProcurementService',
          'PurchaseOrderClose', request, PurchaseOrderCloseResponse());

  /// ---- Goods Receipts ----
  $async.Future<GoodsReceiptCreateResponse> goodsReceiptCreate(
          $pb.ClientContext? ctx, GoodsReceiptCreateRequest request) =>
      _client.invoke<GoodsReceiptCreateResponse>(ctx, 'ProcurementService',
          'GoodsReceiptCreate', request, GoodsReceiptCreateResponse());
  $async.Future<GoodsReceiptGetResponse> goodsReceiptGet(
          $pb.ClientContext? ctx, GoodsReceiptGetRequest request) =>
      _client.invoke<GoodsReceiptGetResponse>(ctx, 'ProcurementService',
          'GoodsReceiptGet', request, GoodsReceiptGetResponse());
  $async.Future<GoodsReceiptSearchResponse> goodsReceiptSearch(
          $pb.ClientContext? ctx, GoodsReceiptSearchRequest request) =>
      _client.invoke<GoodsReceiptSearchResponse>(ctx, 'ProcurementService',
          'GoodsReceiptSearch', request, GoodsReceiptSearchResponse());

  /// Pushes received stock that has not reached its destination yet (commerce
  /// product variants), oldest and least-tried first, at most limit lines.
  /// Each line lands once whatever the number of calls. Scheduled.
  $async.Future<GoodsReceiptDeliverResponse> goodsReceiptDeliver(
          $pb.ClientContext? ctx, GoodsReceiptDeliverRequest request) =>
      _client.invoke<GoodsReceiptDeliverResponse>(ctx, 'ProcurementService',
          'GoodsReceiptDeliver', request, GoodsReceiptDeliverResponse());

  /// Settles a receipt line that needs a person: stock booked by hand
  /// (BOOKED_MANUALLY) is marked resolved with who, when and why; a FAILED
  /// product variant line is put back to PENDING and pushed once (RETRY).
  /// Authorised on the receipt's property (goods_receipt_manage).
  $async.Future<GoodsReceiptLineResolveResponse> goodsReceiptLineResolve(
          $pb.ClientContext? ctx, GoodsReceiptLineResolveRequest request) =>
      _client.invoke<GoodsReceiptLineResolveResponse>(
          ctx,
          'ProcurementService',
          'GoodsReceiptLineResolve',
          request,
          GoodsReceiptLineResolveResponse());

  /// ---- Suggestions ----
  $async.Future<SuggestPurchaseOrdersResponse> suggestPurchaseOrders(
          $pb.ClientContext? ctx, SuggestPurchaseOrdersRequest request) =>
      _client.invoke<SuggestPurchaseOrdersResponse>(ctx, 'ProcurementService',
          'SuggestPurchaseOrders', request, SuggestPurchaseOrdersResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
