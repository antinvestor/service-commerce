//
//  Generated code. Do not modify.
//  source: v1/commerce.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../common/v1/common.pb.dart' as $7;
import '../common/v1/money.pb.dart' as $8;
import '../google/protobuf/field_mask.pb.dart' as $1;
import '../google/protobuf/struct.pb.dart' as $6;
import '../google/protobuf/timestamp.pb.dart' as $2;
import 'commerce.pbenum.dart';

export 'commerce.pbenum.dart';

class Shop extends $pb.GeneratedMessage {
  factory Shop({
    $core.String? id,
    $core.String? name,
    $core.String? slug,
    $core.String? description,
    ShopStatus? status,
    $core.Iterable<$core.String>? mediaIds,
    $core.String? currency,
    $core.String? contactId,
    $core.String? checkoutReturnUrl,
    $2.Timestamp? createdAt,
    $6.Struct? extra,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (slug != null) {
      $result.slug = slug;
    }
    if (description != null) {
      $result.description = description;
    }
    if (status != null) {
      $result.status = status;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (checkoutReturnUrl != null) {
      $result.checkoutReturnUrl = checkoutReturnUrl;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (extra != null) {
      $result.extra = extra;
    }
    return $result;
  }
  Shop._() : super();
  factory Shop.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Shop.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Shop', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'slug')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..e<ShopStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ShopStatus.SHOP_STATUS_UNSPECIFIED, valueOf: ShopStatus.valueOf, enumValues: ShopStatus.values)
    ..pPS(6, _omitFieldNames ? '' : 'mediaIds')
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..aOS(8, _omitFieldNames ? '' : 'contactId')
    ..aOS(9, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOM<$6.Struct>(15, _omitFieldNames ? '' : 'extra', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Shop clone() => Shop()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Shop copyWith(void Function(Shop) updates) => super.copyWith((message) => updates(message as Shop)) as Shop;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Shop create() => Shop._();
  Shop createEmptyInstance() => create();
  static $pb.PbList<Shop> createRepeated() => $pb.PbList<Shop>();
  @$core.pragma('dart2js:noInline')
  static Shop getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Shop>(create);
  static Shop? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get slug => $_getSZ(2);
  @$pb.TagNumber(3)
  set slug($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSlug() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlug() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  ShopStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ShopStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  ///
  /// Media assets associated with the shop (logo, banner, etc.).
  /// References files in the Files Service.
  @$pb.TagNumber(6)
  $core.List<$core.String> get mediaIds => $_getList(5);

  /// ISO 4217 currency every product in the shop is priced in.
  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => clearField(7);

  /// Contact that receives seller-side notifications (new orders, payments).
  @$pb.TagNumber(8)
  $core.String get contactId => $_getSZ(7);
  @$pb.TagNumber(8)
  set contactId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasContactId() => $_has(7);
  @$pb.TagNumber(8)
  void clearContactId() => clearField(8);

  /// Where the hosted checkout page sends the buyer after paying. Empty uses
  /// the service default.
  @$pb.TagNumber(9)
  $core.String get checkoutReturnUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set checkoutReturnUrl($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCheckoutReturnUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearCheckoutReturnUrl() => clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(15)
  $6.Struct get extra => $_getN(10);
  @$pb.TagNumber(15)
  set extra($6.Struct v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasExtra() => $_has(10);
  @$pb.TagNumber(15)
  void clearExtra() => clearField(15);
  @$pb.TagNumber(15)
  $6.Struct ensureExtra() => $_ensure(10);
}

class CreateShopRequest extends $pb.GeneratedMessage {
  factory CreateShopRequest({
    $core.String? name,
    $core.String? slug,
    $core.String? description,
    $core.String? currency,
    $core.String? contactId,
    $core.Iterable<$core.String>? mediaIds,
    $core.String? checkoutReturnUrl,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (slug != null) {
      $result.slug = slug;
    }
    if (description != null) {
      $result.description = description;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    if (checkoutReturnUrl != null) {
      $result.checkoutReturnUrl = checkoutReturnUrl;
    }
    return $result;
  }
  CreateShopRequest._() : super();
  factory CreateShopRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateShopRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateShopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'slug')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..pPS(6, _omitFieldNames ? '' : 'mediaIds')
    ..aOS(7, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateShopRequest clone() => CreateShopRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateShopRequest copyWith(void Function(CreateShopRequest) updates) => super.copyWith((message) => updates(message as CreateShopRequest)) as CreateShopRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateShopRequest create() => CreateShopRequest._();
  CreateShopRequest createEmptyInstance() => create();
  static $pb.PbList<CreateShopRequest> createRepeated() => $pb.PbList<CreateShopRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateShopRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateShopRequest>(create);
  static CreateShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get slug => $_getSZ(1);
  @$pb.TagNumber(2)
  set slug($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSlug() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlug() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.String> get mediaIds => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get checkoutReturnUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set checkoutReturnUrl($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCheckoutReturnUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearCheckoutReturnUrl() => clearField(7);
}

class CreateShopResponse extends $pb.GeneratedMessage {
  factory CreateShopResponse({
    Shop? shop,
  }) {
    final $result = create();
    if (shop != null) {
      $result.shop = shop;
    }
    return $result;
  }
  CreateShopResponse._() : super();
  factory CreateShopResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateShopResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateShopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop', subBuilder: Shop.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateShopResponse clone() => CreateShopResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateShopResponse copyWith(void Function(CreateShopResponse) updates) => super.copyWith((message) => updates(message as CreateShopResponse)) as CreateShopResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateShopResponse create() => CreateShopResponse._();
  CreateShopResponse createEmptyInstance() => create();
  static $pb.PbList<CreateShopResponse> createRepeated() => $pb.PbList<CreateShopResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateShopResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateShopResponse>(create);
  static CreateShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class UpdateShopRequest extends $pb.GeneratedMessage {
  factory UpdateShopRequest({
    $core.String? id,
    $1.FieldMask? updateMask,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.String>? mediaIds,
    ShopStatus? status,
    $6.Struct? extra,
    $core.String? currency,
    $core.String? contactId,
    $core.String? checkoutReturnUrl,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (updateMask != null) {
      $result.updateMask = updateMask;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    if (status != null) {
      $result.status = status;
    }
    if (extra != null) {
      $result.extra = extra;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (checkoutReturnUrl != null) {
      $result.checkoutReturnUrl = checkoutReturnUrl;
    }
    return $result;
  }
  UpdateShopRequest._() : super();
  factory UpdateShopRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateShopRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateShopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.FieldMask>(2, _omitFieldNames ? '' : 'updateMask', subBuilder: $1.FieldMask.create)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..pPS(5, _omitFieldNames ? '' : 'mediaIds')
    ..e<ShopStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ShopStatus.SHOP_STATUS_UNSPECIFIED, valueOf: ShopStatus.valueOf, enumValues: ShopStatus.values)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'extra', subBuilder: $6.Struct.create)
    ..aOS(8, _omitFieldNames ? '' : 'currency')
    ..aOS(9, _omitFieldNames ? '' : 'contactId')
    ..aOS(10, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateShopRequest clone() => UpdateShopRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateShopRequest copyWith(void Function(UpdateShopRequest) updates) => super.copyWith((message) => updates(message as UpdateShopRequest)) as UpdateShopRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateShopRequest create() => UpdateShopRequest._();
  UpdateShopRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateShopRequest> createRepeated() => $pb.PbList<UpdateShopRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateShopRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateShopRequest>(create);
  static UpdateShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $1.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($1.FieldMask v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => clearField(2);
  @$pb.TagNumber(2)
  $1.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get mediaIds => $_getList(4);

  @$pb.TagNumber(6)
  ShopStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(ShopStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get extra => $_getN(6);
  @$pb.TagNumber(7)
  set extra($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasExtra() => $_has(6);
  @$pb.TagNumber(7)
  void clearExtra() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureExtra() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get currency => $_getSZ(7);
  @$pb.TagNumber(8)
  set currency($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCurrency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrency() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get contactId => $_getSZ(8);
  @$pb.TagNumber(9)
  set contactId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasContactId() => $_has(8);
  @$pb.TagNumber(9)
  void clearContactId() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get checkoutReturnUrl => $_getSZ(9);
  @$pb.TagNumber(10)
  set checkoutReturnUrl($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasCheckoutReturnUrl() => $_has(9);
  @$pb.TagNumber(10)
  void clearCheckoutReturnUrl() => clearField(10);
}

class UpdateShopResponse extends $pb.GeneratedMessage {
  factory UpdateShopResponse({
    Shop? shop,
  }) {
    final $result = create();
    if (shop != null) {
      $result.shop = shop;
    }
    return $result;
  }
  UpdateShopResponse._() : super();
  factory UpdateShopResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateShopResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateShopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop', subBuilder: Shop.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateShopResponse clone() => UpdateShopResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateShopResponse copyWith(void Function(UpdateShopResponse) updates) => super.copyWith((message) => updates(message as UpdateShopResponse)) as UpdateShopResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateShopResponse create() => UpdateShopResponse._();
  UpdateShopResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateShopResponse> createRepeated() => $pb.PbList<UpdateShopResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateShopResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateShopResponse>(create);
  static UpdateShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class GetShopRequest extends $pb.GeneratedMessage {
  factory GetShopRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetShopRequest._() : super();
  factory GetShopRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetShopRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetShopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetShopRequest clone() => GetShopRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetShopRequest copyWith(void Function(GetShopRequest) updates) => super.copyWith((message) => updates(message as GetShopRequest)) as GetShopRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetShopRequest create() => GetShopRequest._();
  GetShopRequest createEmptyInstance() => create();
  static $pb.PbList<GetShopRequest> createRepeated() => $pb.PbList<GetShopRequest>();
  @$core.pragma('dart2js:noInline')
  static GetShopRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShopRequest>(create);
  static GetShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ListShopsRequest extends $pb.GeneratedMessage {
  factory ListShopsRequest({
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  ListShopsRequest._() : super();
  factory ListShopsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListShopsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListShopsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<$7.SearchRequest>(1, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListShopsRequest clone() => ListShopsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListShopsRequest copyWith(void Function(ListShopsRequest) updates) => super.copyWith((message) => updates(message as ListShopsRequest)) as ListShopsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListShopsRequest create() => ListShopsRequest._();
  ListShopsRequest createEmptyInstance() => create();
  static $pb.PbList<ListShopsRequest> createRepeated() => $pb.PbList<ListShopsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListShopsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListShopsRequest>(create);
  static ListShopsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $7.SearchRequest get search => $_getN(0);
  @$pb.TagNumber(1)
  set search($7.SearchRequest v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSearch() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearch() => clearField(1);
  @$pb.TagNumber(1)
  $7.SearchRequest ensureSearch() => $_ensure(0);
}

class ListShopsResponse extends $pb.GeneratedMessage {
  factory ListShopsResponse({
    $core.Iterable<Shop>? shops,
    $core.String? nextPage,
  }) {
    final $result = create();
    if (shops != null) {
      $result.shops.addAll(shops);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    return $result;
  }
  ListShopsResponse._() : super();
  factory ListShopsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListShopsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListShopsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<Shop>(1, _omitFieldNames ? '' : 'shops', $pb.PbFieldType.PM, subBuilder: Shop.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListShopsResponse clone() => ListShopsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListShopsResponse copyWith(void Function(ListShopsResponse) updates) => super.copyWith((message) => updates(message as ListShopsResponse)) as ListShopsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListShopsResponse create() => ListShopsResponse._();
  ListShopsResponse createEmptyInstance() => create();
  static $pb.PbList<ListShopsResponse> createRepeated() => $pb.PbList<ListShopsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListShopsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListShopsResponse>(create);
  static ListShopsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Shop> get shops => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);
}

class GetShopResponse extends $pb.GeneratedMessage {
  factory GetShopResponse({
    Shop? shop,
  }) {
    final $result = create();
    if (shop != null) {
      $result.shop = shop;
    }
    return $result;
  }
  GetShopResponse._() : super();
  factory GetShopResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetShopResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetShopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop', subBuilder: Shop.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetShopResponse clone() => GetShopResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetShopResponse copyWith(void Function(GetShopResponse) updates) => super.copyWith((message) => updates(message as GetShopResponse)) as GetShopResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetShopResponse create() => GetShopResponse._();
  GetShopResponse createEmptyInstance() => create();
  static $pb.PbList<GetShopResponse> createRepeated() => $pb.PbList<GetShopResponse>();
  @$core.pragma('dart2js:noInline')
  static GetShopResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShopResponse>(create);
  static GetShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class Product extends $pb.GeneratedMessage {
  factory Product({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? description,
    $core.Map<$core.String, $core.String>? attributes,
    FulfilmentType? fulfilmentType,
    ProductStatus? status,
    $core.Iterable<$core.String>? mediaIds,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (fulfilmentType != null) {
      $result.fulfilmentType = fulfilmentType;
    }
    if (status != null) {
      $result.status = status;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  Product._() : super();
  factory Product.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Product.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Product', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes', entryClassName: 'Product.AttributesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commerce.v1'))
    ..e<FulfilmentType>(10, _omitFieldNames ? '' : 'fulfilmentType', $pb.PbFieldType.OE, defaultOrMaker: FulfilmentType.FULFILMENT_TYPE_UNSPECIFIED, valueOf: FulfilmentType.valueOf, enumValues: FulfilmentType.values)
    ..e<ProductStatus>(15, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ProductStatus.PRODUCT_STATUS_UNSPECIFIED, valueOf: ProductStatus.valueOf, enumValues: ProductStatus.values)
    ..pPS(16, _omitFieldNames ? '' : 'mediaIds')
    ..aOM<$2.Timestamp>(17, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Product clone() => Product()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Product copyWith(void Function(Product) updates) => super.copyWith((message) => updates(message as Product)) as Product;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Product create() => Product._();
  Product createEmptyInstance() => create();
  static $pb.PbList<Product> createRepeated() => $pb.PbList<Product>();
  @$core.pragma('dart2js:noInline')
  static Product getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Product>(create);
  static Product? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(10)
  FulfilmentType get fulfilmentType => $_getN(5);
  @$pb.TagNumber(10)
  set fulfilmentType(FulfilmentType v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasFulfilmentType() => $_has(5);
  @$pb.TagNumber(10)
  void clearFulfilmentType() => clearField(10);

  @$pb.TagNumber(15)
  ProductStatus get status => $_getN(6);
  @$pb.TagNumber(15)
  set status(ProductStatus v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(15)
  void clearStatus() => clearField(15);

  ///
  /// Media assets (images, videos) for the product.
  /// References files in the Files Service.
  @$pb.TagNumber(16)
  $core.List<$core.String> get mediaIds => $_getList(7);

  @$pb.TagNumber(17)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(17)
  set createdAt($2.Timestamp v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(17)
  void clearCreatedAt() => clearField(17);
  @$pb.TagNumber(17)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);
}

class ProductVariant extends $pb.GeneratedMessage {
  factory ProductVariant({
    $core.String? id,
    $core.String? productId,
    $core.String? sku,
    $core.String? name,
    $8.Money? price,
    $core.Map<$core.String, $core.String>? attributes,
    $fixnum.Int64? stockQuantity,
    ProductVariantStatus? status,
    $2.Timestamp? createdAt,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (sku != null) {
      $result.sku = sku;
    }
    if (name != null) {
      $result.name = name;
    }
    if (price != null) {
      $result.price = price;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (stockQuantity != null) {
      $result.stockQuantity = stockQuantity;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    return $result;
  }
  ProductVariant._() : super();
  factory ProductVariant.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProductVariant.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProductVariant', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'sku')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOM<$8.Money>(5, _omitFieldNames ? '' : 'price', subBuilder: $8.Money.create)
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'attributes', entryClassName: 'ProductVariant.AttributesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(7, _omitFieldNames ? '' : 'stockQuantity')
    ..e<ProductVariantStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ProductVariantStatus.PRODUCT_VARIANT_STATUS_UNSPECIFIED, valueOf: ProductVariantStatus.valueOf, enumValues: ProductVariantStatus.values)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..pPS(10, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProductVariant clone() => ProductVariant()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProductVariant copyWith(void Function(ProductVariant) updates) => super.copyWith((message) => updates(message as ProductVariant)) as ProductVariant;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductVariant create() => ProductVariant._();
  ProductVariant createEmptyInstance() => create();
  static $pb.PbList<ProductVariant> createRepeated() => $pb.PbList<ProductVariant>();
  @$core.pragma('dart2js:noInline')
  static ProductVariant getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProductVariant>(create);
  static ProductVariant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get sku => $_getSZ(2);
  @$pb.TagNumber(3)
  set sku($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSku() => $_has(2);
  @$pb.TagNumber(3)
  void clearSku() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => clearField(4);

  ///
  /// Price in minor units (for example cents).
  @$pb.TagNumber(5)
  $8.Money get price => $_getN(4);
  @$pb.TagNumber(5)
  set price($8.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrice() => clearField(5);
  @$pb.TagNumber(5)
  $8.Money ensurePrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get stockQuantity => $_getI64(6);
  @$pb.TagNumber(7)
  set stockQuantity($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStockQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearStockQuantity() => clearField(7);

  @$pb.TagNumber(8)
  ProductVariantStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(ProductVariantStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(9)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($2.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.List<$core.String> get mediaIds => $_getList(9);
}

class CreateProductRequest extends $pb.GeneratedMessage {
  factory CreateProductRequest({
    $core.String? shopId,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.String>? mediaIds,
    $core.Map<$core.String, $core.String>? attributes,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    return $result;
  }
  CreateProductRequest._() : super();
  factory CreateProductRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProductRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProductRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..pPS(4, _omitFieldNames ? '' : 'mediaIds')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes', entryClassName: 'CreateProductRequest.AttributesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commerce.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProductRequest clone() => CreateProductRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProductRequest copyWith(void Function(CreateProductRequest) updates) => super.copyWith((message) => updates(message as CreateProductRequest)) as CreateProductRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProductRequest create() => CreateProductRequest._();
  CreateProductRequest createEmptyInstance() => create();
  static $pb.PbList<CreateProductRequest> createRepeated() => $pb.PbList<CreateProductRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateProductRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProductRequest>(create);
  static CreateProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get mediaIds => $_getList(3);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(4);
}

class CreateProductResponse extends $pb.GeneratedMessage {
  factory CreateProductResponse({
    Product? product,
  }) {
    final $result = create();
    if (product != null) {
      $result.product = product;
    }
    return $result;
  }
  CreateProductResponse._() : super();
  factory CreateProductResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProductResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProductResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Product>(1, _omitFieldNames ? '' : 'product', subBuilder: Product.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProductResponse clone() => CreateProductResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProductResponse copyWith(void Function(CreateProductResponse) updates) => super.copyWith((message) => updates(message as CreateProductResponse)) as CreateProductResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProductResponse create() => CreateProductResponse._();
  CreateProductResponse createEmptyInstance() => create();
  static $pb.PbList<CreateProductResponse> createRepeated() => $pb.PbList<CreateProductResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateProductResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProductResponse>(create);
  static CreateProductResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(Product v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => clearField(1);
  @$pb.TagNumber(1)
  Product ensureProduct() => $_ensure(0);
}

class GetProductRequest extends $pb.GeneratedMessage {
  factory GetProductRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetProductRequest._() : super();
  factory GetProductRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProductRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProductRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProductRequest clone() => GetProductRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProductRequest copyWith(void Function(GetProductRequest) updates) => super.copyWith((message) => updates(message as GetProductRequest)) as GetProductRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProductRequest create() => GetProductRequest._();
  GetProductRequest createEmptyInstance() => create();
  static $pb.PbList<GetProductRequest> createRepeated() => $pb.PbList<GetProductRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProductRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProductRequest>(create);
  static GetProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetProductResponse extends $pb.GeneratedMessage {
  factory GetProductResponse({
    Product? product,
  }) {
    final $result = create();
    if (product != null) {
      $result.product = product;
    }
    return $result;
  }
  GetProductResponse._() : super();
  factory GetProductResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProductResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProductResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Product>(1, _omitFieldNames ? '' : 'product', subBuilder: Product.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProductResponse clone() => GetProductResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProductResponse copyWith(void Function(GetProductResponse) updates) => super.copyWith((message) => updates(message as GetProductResponse)) as GetProductResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProductResponse create() => GetProductResponse._();
  GetProductResponse createEmptyInstance() => create();
  static $pb.PbList<GetProductResponse> createRepeated() => $pb.PbList<GetProductResponse>();
  @$core.pragma('dart2js:noInline')
  static GetProductResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProductResponse>(create);
  static GetProductResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(Product v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => clearField(1);
  @$pb.TagNumber(1)
  Product ensureProduct() => $_ensure(0);
}

class ListProductsRequest extends $pb.GeneratedMessage {
  factory ListProductsRequest({
    $core.String? shopId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  ListProductsRequest._() : super();
  factory ListProductsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProductsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProductsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$7.SearchRequest>(2, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProductsRequest clone() => ListProductsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProductsRequest copyWith(void Function(ListProductsRequest) updates) => super.copyWith((message) => updates(message as ListProductsRequest)) as ListProductsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProductsRequest create() => ListProductsRequest._();
  ListProductsRequest createEmptyInstance() => create();
  static $pb.PbList<ListProductsRequest> createRepeated() => $pb.PbList<ListProductsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListProductsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProductsRequest>(create);
  static ListProductsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  /// Optional search parameters (query, cursor, etc.)
  @$pb.TagNumber(2)
  $7.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($7.SearchRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => clearField(2);
  @$pb.TagNumber(2)
  $7.SearchRequest ensureSearch() => $_ensure(1);
}

class ListProductsResponse extends $pb.GeneratedMessage {
  factory ListProductsResponse({
    $core.Iterable<Product>? products,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (products != null) {
      $result.products.addAll(products);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  ListProductsResponse._() : super();
  factory ListProductsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProductsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProductsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<Product>(1, _omitFieldNames ? '' : 'products', $pb.PbFieldType.PM, subBuilder: Product.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProductsResponse clone() => ListProductsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProductsResponse copyWith(void Function(ListProductsResponse) updates) => super.copyWith((message) => updates(message as ListProductsResponse)) as ListProductsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProductsResponse create() => ListProductsResponse._();
  ListProductsResponse createEmptyInstance() => create();
  static $pb.PbList<ListProductsResponse> createRepeated() => $pb.PbList<ListProductsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListProductsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProductsResponse>(create);
  static ListProductsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Product> get products => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class CreateProductVariantRequest extends $pb.GeneratedMessage {
  factory CreateProductVariantRequest({
    $core.String? productId,
    $core.String? sku,
    $core.String? name,
    $8.Money? price,
    $core.Map<$core.String, $core.String>? attributes,
    $fixnum.Int64? stockQuantity,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final $result = create();
    if (productId != null) {
      $result.productId = productId;
    }
    if (sku != null) {
      $result.sku = sku;
    }
    if (name != null) {
      $result.name = name;
    }
    if (price != null) {
      $result.price = price;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (stockQuantity != null) {
      $result.stockQuantity = stockQuantity;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    return $result;
  }
  CreateProductVariantRequest._() : super();
  factory CreateProductVariantRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProductVariantRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProductVariantRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'productId')
    ..aOS(2, _omitFieldNames ? '' : 'sku')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$8.Money>(4, _omitFieldNames ? '' : 'price', subBuilder: $8.Money.create)
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes', entryClassName: 'CreateProductVariantRequest.AttributesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(6, _omitFieldNames ? '' : 'stockQuantity')
    ..pPS(7, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProductVariantRequest clone() => CreateProductVariantRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProductVariantRequest copyWith(void Function(CreateProductVariantRequest) updates) => super.copyWith((message) => updates(message as CreateProductVariantRequest)) as CreateProductVariantRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProductVariantRequest create() => CreateProductVariantRequest._();
  CreateProductVariantRequest createEmptyInstance() => create();
  static $pb.PbList<CreateProductVariantRequest> createRepeated() => $pb.PbList<CreateProductVariantRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateProductVariantRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProductVariantRequest>(create);
  static CreateProductVariantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get productId => $_getSZ(0);
  @$pb.TagNumber(1)
  set productId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProductId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sku => $_getSZ(1);
  @$pb.TagNumber(2)
  set sku($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSku() => $_has(1);
  @$pb.TagNumber(2)
  void clearSku() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $8.Money get price => $_getN(3);
  @$pb.TagNumber(4)
  set price($8.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrice() => clearField(4);
  @$pb.TagNumber(4)
  $8.Money ensurePrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get stockQuantity => $_getI64(5);
  @$pb.TagNumber(6)
  set stockQuantity($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStockQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearStockQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.String> get mediaIds => $_getList(6);
}

class CreateProductVariantResponse extends $pb.GeneratedMessage {
  factory CreateProductVariantResponse({
    ProductVariant? productVariant,
  }) {
    final $result = create();
    if (productVariant != null) {
      $result.productVariant = productVariant;
    }
    return $result;
  }
  CreateProductVariantResponse._() : super();
  factory CreateProductVariantResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProductVariantResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProductVariantResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<ProductVariant>(1, _omitFieldNames ? '' : 'productVariant', subBuilder: ProductVariant.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProductVariantResponse clone() => CreateProductVariantResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProductVariantResponse copyWith(void Function(CreateProductVariantResponse) updates) => super.copyWith((message) => updates(message as CreateProductVariantResponse)) as CreateProductVariantResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProductVariantResponse create() => CreateProductVariantResponse._();
  CreateProductVariantResponse createEmptyInstance() => create();
  static $pb.PbList<CreateProductVariantResponse> createRepeated() => $pb.PbList<CreateProductVariantResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateProductVariantResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProductVariantResponse>(create);
  static CreateProductVariantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProductVariant get productVariant => $_getN(0);
  @$pb.TagNumber(1)
  set productVariant(ProductVariant v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProductVariant() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductVariant() => clearField(1);
  @$pb.TagNumber(1)
  ProductVariant ensureProductVariant() => $_ensure(0);
}

class UpdateProductVariantRequest extends $pb.GeneratedMessage {
  factory UpdateProductVariantRequest({
    $core.String? variantId,
    $1.FieldMask? updateMask,
    $core.String? sku,
    $core.String? name,
    $8.Money? price,
    $core.Map<$core.String, $core.String>? attributes,
    $fixnum.Int64? stockQuantity,
    ProductVariantStatus? status,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final $result = create();
    if (variantId != null) {
      $result.variantId = variantId;
    }
    if (updateMask != null) {
      $result.updateMask = updateMask;
    }
    if (sku != null) {
      $result.sku = sku;
    }
    if (name != null) {
      $result.name = name;
    }
    if (price != null) {
      $result.price = price;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (stockQuantity != null) {
      $result.stockQuantity = stockQuantity;
    }
    if (status != null) {
      $result.status = status;
    }
    if (mediaIds != null) {
      $result.mediaIds.addAll(mediaIds);
    }
    return $result;
  }
  UpdateProductVariantRequest._() : super();
  factory UpdateProductVariantRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProductVariantRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProductVariantRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aOM<$1.FieldMask>(2, _omitFieldNames ? '' : 'updateMask', subBuilder: $1.FieldMask.create)
    ..aOS(3, _omitFieldNames ? '' : 'sku')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOM<$8.Money>(5, _omitFieldNames ? '' : 'price', subBuilder: $8.Money.create)
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'attributes', entryClassName: 'UpdateProductVariantRequest.AttributesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(7, _omitFieldNames ? '' : 'stockQuantity')
    ..e<ProductVariantStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ProductVariantStatus.PRODUCT_VARIANT_STATUS_UNSPECIFIED, valueOf: ProductVariantStatus.valueOf, enumValues: ProductVariantStatus.values)
    ..pPS(9, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProductVariantRequest clone() => UpdateProductVariantRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProductVariantRequest copyWith(void Function(UpdateProductVariantRequest) updates) => super.copyWith((message) => updates(message as UpdateProductVariantRequest)) as UpdateProductVariantRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantRequest create() => UpdateProductVariantRequest._();
  UpdateProductVariantRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateProductVariantRequest> createRepeated() => $pb.PbList<UpdateProductVariantRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProductVariantRequest>(create);
  static UpdateProductVariantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => clearField(1);

  @$pb.TagNumber(2)
  $1.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($1.FieldMask v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => clearField(2);
  @$pb.TagNumber(2)
  $1.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get sku => $_getSZ(2);
  @$pb.TagNumber(3)
  set sku($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSku() => $_has(2);
  @$pb.TagNumber(3)
  void clearSku() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => clearField(4);

  @$pb.TagNumber(5)
  $8.Money get price => $_getN(4);
  @$pb.TagNumber(5)
  set price($8.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrice() => clearField(5);
  @$pb.TagNumber(5)
  $8.Money ensurePrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get stockQuantity => $_getI64(6);
  @$pb.TagNumber(7)
  set stockQuantity($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStockQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearStockQuantity() => clearField(7);

  @$pb.TagNumber(8)
  ProductVariantStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(ProductVariantStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.String> get mediaIds => $_getList(8);
}

class ListProductVariantsRequest extends $pb.GeneratedMessage {
  factory ListProductVariantsRequest({
    $core.String? productId,
  }) {
    final $result = create();
    if (productId != null) {
      $result.productId = productId;
    }
    return $result;
  }
  ListProductVariantsRequest._() : super();
  factory ListProductVariantsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProductVariantsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProductVariantsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'productId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProductVariantsRequest clone() => ListProductVariantsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProductVariantsRequest copyWith(void Function(ListProductVariantsRequest) updates) => super.copyWith((message) => updates(message as ListProductVariantsRequest)) as ListProductVariantsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProductVariantsRequest create() => ListProductVariantsRequest._();
  ListProductVariantsRequest createEmptyInstance() => create();
  static $pb.PbList<ListProductVariantsRequest> createRepeated() => $pb.PbList<ListProductVariantsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListProductVariantsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProductVariantsRequest>(create);
  static ListProductVariantsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get productId => $_getSZ(0);
  @$pb.TagNumber(1)
  set productId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProductId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductId() => clearField(1);
}

class ListProductVariantsResponse extends $pb.GeneratedMessage {
  factory ListProductVariantsResponse({
    $core.Iterable<ProductVariant>? productVariants,
  }) {
    final $result = create();
    if (productVariants != null) {
      $result.productVariants.addAll(productVariants);
    }
    return $result;
  }
  ListProductVariantsResponse._() : super();
  factory ListProductVariantsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProductVariantsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProductVariantsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<ProductVariant>(1, _omitFieldNames ? '' : 'productVariants', $pb.PbFieldType.PM, subBuilder: ProductVariant.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProductVariantsResponse clone() => ListProductVariantsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProductVariantsResponse copyWith(void Function(ListProductVariantsResponse) updates) => super.copyWith((message) => updates(message as ListProductVariantsResponse)) as ListProductVariantsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProductVariantsResponse create() => ListProductVariantsResponse._();
  ListProductVariantsResponse createEmptyInstance() => create();
  static $pb.PbList<ListProductVariantsResponse> createRepeated() => $pb.PbList<ListProductVariantsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListProductVariantsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProductVariantsResponse>(create);
  static ListProductVariantsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProductVariant> get productVariants => $_getList(0);
}

class UpdateProductVariantResponse extends $pb.GeneratedMessage {
  factory UpdateProductVariantResponse({
    ProductVariant? productVariant,
  }) {
    final $result = create();
    if (productVariant != null) {
      $result.productVariant = productVariant;
    }
    return $result;
  }
  UpdateProductVariantResponse._() : super();
  factory UpdateProductVariantResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProductVariantResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProductVariantResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<ProductVariant>(1, _omitFieldNames ? '' : 'productVariant', subBuilder: ProductVariant.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProductVariantResponse clone() => UpdateProductVariantResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProductVariantResponse copyWith(void Function(UpdateProductVariantResponse) updates) => super.copyWith((message) => updates(message as UpdateProductVariantResponse)) as UpdateProductVariantResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantResponse create() => UpdateProductVariantResponse._();
  UpdateProductVariantResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateProductVariantResponse> createRepeated() => $pb.PbList<UpdateProductVariantResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProductVariantResponse>(create);
  static UpdateProductVariantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProductVariant get productVariant => $_getN(0);
  @$pb.TagNumber(1)
  set productVariant(ProductVariant v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProductVariant() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductVariant() => clearField(1);
  @$pb.TagNumber(1)
  ProductVariant ensureProductVariant() => $_ensure(0);
}

class Cart extends $pb.GeneratedMessage {
  factory Cart({
    $core.String? id,
    $core.String? shopId,
    CartStatus? status,
    $core.String? profileId,
    $core.String? contactId,
    $core.Iterable<CartLine>? lines,
    $2.Timestamp? expiresAt,
    $2.Timestamp? createdAt,
    $2.Timestamp? updatedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Cart._() : super();
  factory Cart.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Cart.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Cart', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..e<CartStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CartStatus.CART_STATUS_UNSPECIFIED, valueOf: CartStatus.valueOf, enumValues: CartStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'profileId')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..pc<CartLine>(10, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: CartLine.create)
    ..aOM<$2.Timestamp>(16, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(17, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(18, _omitFieldNames ? '' : 'updatedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Cart clone() => Cart()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Cart copyWith(void Function(Cart) updates) => super.copyWith((message) => updates(message as Cart)) as Cart;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cart create() => Cart._();
  Cart createEmptyInstance() => create();
  static $pb.PbList<Cart> createRepeated() => $pb.PbList<Cart>();
  @$core.pragma('dart2js:noInline')
  static Cart getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cart>(create);
  static Cart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  CartStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(CartStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get profileId => $_getSZ(3);
  @$pb.TagNumber(4)
  set profileId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProfileId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProfileId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => clearField(5);

  @$pb.TagNumber(10)
  $core.List<CartLine> get lines => $_getList(5);

  @$pb.TagNumber(16)
  $2.Timestamp get expiresAt => $_getN(6);
  @$pb.TagNumber(16)
  set expiresAt($2.Timestamp v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasExpiresAt() => $_has(6);
  @$pb.TagNumber(16)
  void clearExpiresAt() => clearField(16);
  @$pb.TagNumber(16)
  $2.Timestamp ensureExpiresAt() => $_ensure(6);

  @$pb.TagNumber(17)
  $2.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(17)
  set createdAt($2.Timestamp v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(17)
  void clearCreatedAt() => clearField(17);
  @$pb.TagNumber(17)
  $2.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(18)
  $2.Timestamp get updatedAt => $_getN(8);
  @$pb.TagNumber(18)
  set updatedAt($2.Timestamp v) { setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(18)
  void clearUpdatedAt() => clearField(18);
  @$pb.TagNumber(18)
  $2.Timestamp ensureUpdatedAt() => $_ensure(8);
}

class CartLine extends $pb.GeneratedMessage {
  factory CartLine({
    $core.String? id,
    $core.String? productVariantId,
    $fixnum.Int64? quantity,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    return $result;
  }
  CartLine._() : super();
  factory CartLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CartLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CartLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aInt64(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CartLine clone() => CartLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CartLine copyWith(void Function(CartLine) updates) => super.copyWith((message) => updates(message as CartLine)) as CartLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CartLine create() => CartLine._();
  CartLine createEmptyInstance() => create();
  static $pb.PbList<CartLine> createRepeated() => $pb.PbList<CartLine>();
  @$core.pragma('dart2js:noInline')
  static CartLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CartLine>(create);
  static CartLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get quantity => $_getI64(2);
  @$pb.TagNumber(3)
  set quantity($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => clearField(3);
}

class CreateCartRequest extends $pb.GeneratedMessage {
  factory CreateCartRequest({
    $core.String? shopId,
    $core.String? profileId,
    $core.String? contactId,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    return $result;
  }
  CreateCartRequest._() : super();
  factory CreateCartRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateCartRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateCartRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'contactId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateCartRequest clone() => CreateCartRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateCartRequest copyWith(void Function(CreateCartRequest) updates) => super.copyWith((message) => updates(message as CreateCartRequest)) as CreateCartRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCartRequest create() => CreateCartRequest._();
  CreateCartRequest createEmptyInstance() => create();
  static $pb.PbList<CreateCartRequest> createRepeated() => $pb.PbList<CreateCartRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateCartRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCartRequest>(create);
  static CreateCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  /// Optional – used for abandoned cart reminders
  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get contactId => $_getSZ(2);
  @$pb.TagNumber(3)
  set contactId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContactId() => $_has(2);
  @$pb.TagNumber(3)
  void clearContactId() => clearField(3);
}

class CreateCartResponse extends $pb.GeneratedMessage {
  factory CreateCartResponse({
    Cart? cart,
  }) {
    final $result = create();
    if (cart != null) {
      $result.cart = cart;
    }
    return $result;
  }
  CreateCartResponse._() : super();
  factory CreateCartResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateCartResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateCartResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart', subBuilder: Cart.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateCartResponse clone() => CreateCartResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateCartResponse copyWith(void Function(CreateCartResponse) updates) => super.copyWith((message) => updates(message as CreateCartResponse)) as CreateCartResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCartResponse create() => CreateCartResponse._();
  CreateCartResponse createEmptyInstance() => create();
  static $pb.PbList<CreateCartResponse> createRepeated() => $pb.PbList<CreateCartResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateCartResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCartResponse>(create);
  static CreateCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class GetCartRequest extends $pb.GeneratedMessage {
  factory GetCartRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetCartRequest._() : super();
  factory GetCartRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCartRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCartRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCartRequest clone() => GetCartRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCartRequest copyWith(void Function(GetCartRequest) updates) => super.copyWith((message) => updates(message as GetCartRequest)) as GetCartRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCartRequest create() => GetCartRequest._();
  GetCartRequest createEmptyInstance() => create();
  static $pb.PbList<GetCartRequest> createRepeated() => $pb.PbList<GetCartRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCartRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartRequest>(create);
  static GetCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetCartResponse extends $pb.GeneratedMessage {
  factory GetCartResponse({
    Cart? cart,
  }) {
    final $result = create();
    if (cart != null) {
      $result.cart = cart;
    }
    return $result;
  }
  GetCartResponse._() : super();
  factory GetCartResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCartResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCartResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart', subBuilder: Cart.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCartResponse clone() => GetCartResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCartResponse copyWith(void Function(GetCartResponse) updates) => super.copyWith((message) => updates(message as GetCartResponse)) as GetCartResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCartResponse create() => GetCartResponse._();
  GetCartResponse createEmptyInstance() => create();
  static $pb.PbList<GetCartResponse> createRepeated() => $pb.PbList<GetCartResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCartResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartResponse>(create);
  static GetCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class AddCartLineRequest extends $pb.GeneratedMessage {
  factory AddCartLineRequest({
    $core.String? cartId,
    $core.String? productVariantId,
    $fixnum.Int64? quantity,
  }) {
    final $result = create();
    if (cartId != null) {
      $result.cartId = cartId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    return $result;
  }
  AddCartLineRequest._() : super();
  factory AddCartLineRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddCartLineRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddCartLineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aInt64(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddCartLineRequest clone() => AddCartLineRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddCartLineRequest copyWith(void Function(AddCartLineRequest) updates) => super.copyWith((message) => updates(message as AddCartLineRequest)) as AddCartLineRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddCartLineRequest create() => AddCartLineRequest._();
  AddCartLineRequest createEmptyInstance() => create();
  static $pb.PbList<AddCartLineRequest> createRepeated() => $pb.PbList<AddCartLineRequest>();
  @$core.pragma('dart2js:noInline')
  static AddCartLineRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddCartLineRequest>(create);
  static AddCartLineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get quantity => $_getI64(2);
  @$pb.TagNumber(3)
  set quantity($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => clearField(3);
}

class AddCartLineResponse extends $pb.GeneratedMessage {
  factory AddCartLineResponse({
    Cart? cart,
  }) {
    final $result = create();
    if (cart != null) {
      $result.cart = cart;
    }
    return $result;
  }
  AddCartLineResponse._() : super();
  factory AddCartLineResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddCartLineResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddCartLineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart', subBuilder: Cart.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddCartLineResponse clone() => AddCartLineResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddCartLineResponse copyWith(void Function(AddCartLineResponse) updates) => super.copyWith((message) => updates(message as AddCartLineResponse)) as AddCartLineResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddCartLineResponse create() => AddCartLineResponse._();
  AddCartLineResponse createEmptyInstance() => create();
  static $pb.PbList<AddCartLineResponse> createRepeated() => $pb.PbList<AddCartLineResponse>();
  @$core.pragma('dart2js:noInline')
  static AddCartLineResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddCartLineResponse>(create);
  static AddCartLineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class RemoveCartLineRequest extends $pb.GeneratedMessage {
  factory RemoveCartLineRequest({
    $core.String? cartId,
    $core.String? cartLineId,
  }) {
    final $result = create();
    if (cartId != null) {
      $result.cartId = cartId;
    }
    if (cartLineId != null) {
      $result.cartLineId = cartLineId;
    }
    return $result;
  }
  RemoveCartLineRequest._() : super();
  factory RemoveCartLineRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveCartLineRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveCartLineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(2, _omitFieldNames ? '' : 'cartLineId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveCartLineRequest clone() => RemoveCartLineRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveCartLineRequest copyWith(void Function(RemoveCartLineRequest) updates) => super.copyWith((message) => updates(message as RemoveCartLineRequest)) as RemoveCartLineRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveCartLineRequest create() => RemoveCartLineRequest._();
  RemoveCartLineRequest createEmptyInstance() => create();
  static $pb.PbList<RemoveCartLineRequest> createRepeated() => $pb.PbList<RemoveCartLineRequest>();
  @$core.pragma('dart2js:noInline')
  static RemoveCartLineRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveCartLineRequest>(create);
  static RemoveCartLineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get cartLineId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cartLineId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCartLineId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCartLineId() => clearField(2);
}

class RemoveCartLineResponse extends $pb.GeneratedMessage {
  factory RemoveCartLineResponse({
    Cart? cart,
  }) {
    final $result = create();
    if (cart != null) {
      $result.cart = cart;
    }
    return $result;
  }
  RemoveCartLineResponse._() : super();
  factory RemoveCartLineResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveCartLineResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveCartLineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart', subBuilder: Cart.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveCartLineResponse clone() => RemoveCartLineResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveCartLineResponse copyWith(void Function(RemoveCartLineResponse) updates) => super.copyWith((message) => updates(message as RemoveCartLineResponse)) as RemoveCartLineResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveCartLineResponse create() => RemoveCartLineResponse._();
  RemoveCartLineResponse createEmptyInstance() => create();
  static $pb.PbList<RemoveCartLineResponse> createRepeated() => $pb.PbList<RemoveCartLineResponse>();
  @$core.pragma('dart2js:noInline')
  static RemoveCartLineResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveCartLineResponse>(create);
  static RemoveCartLineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class CreateOrderFromCartRequest extends $pb.GeneratedMessage {
  factory CreateOrderFromCartRequest({
    $core.String? cartId,
    $core.String? profileId,
    $core.String? contactId,
    $core.String? addressId,
  }) {
    final $result = create();
    if (cartId != null) {
      $result.cartId = cartId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (addressId != null) {
      $result.addressId = addressId;
    }
    return $result;
  }
  CreateOrderFromCartRequest._() : super();
  factory CreateOrderFromCartRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateOrderFromCartRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateOrderFromCartRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateOrderFromCartRequest clone() => CreateOrderFromCartRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateOrderFromCartRequest copyWith(void Function(CreateOrderFromCartRequest) updates) => super.copyWith((message) => updates(message as CreateOrderFromCartRequest)) as CreateOrderFromCartRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartRequest create() => CreateOrderFromCartRequest._();
  CreateOrderFromCartRequest createEmptyInstance() => create();
  static $pb.PbList<CreateOrderFromCartRequest> createRepeated() => $pb.PbList<CreateOrderFromCartRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderFromCartRequest>(create);
  static CreateOrderFromCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => clearField(1);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(5)
  set profileId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(5)
  void clearProfileId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(2);
  @$pb.TagNumber(6)
  set contactId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(2);
  @$pb.TagNumber(6)
  void clearContactId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(3);
  @$pb.TagNumber(7)
  set addressId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(3);
  @$pb.TagNumber(7)
  void clearAddressId() => clearField(7);
}

class CreateOrderFromCartResponse extends $pb.GeneratedMessage {
  factory CreateOrderFromCartResponse({
    Order? order,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  CreateOrderFromCartResponse._() : super();
  factory CreateOrderFromCartResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateOrderFromCartResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateOrderFromCartResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateOrderFromCartResponse clone() => CreateOrderFromCartResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateOrderFromCartResponse copyWith(void Function(CreateOrderFromCartResponse) updates) => super.copyWith((message) => updates(message as CreateOrderFromCartResponse)) as CreateOrderFromCartResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartResponse create() => CreateOrderFromCartResponse._();
  CreateOrderFromCartResponse createEmptyInstance() => create();
  static $pb.PbList<CreateOrderFromCartResponse> createRepeated() => $pb.PbList<CreateOrderFromCartResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderFromCartResponse>(create);
  static CreateOrderFromCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class Order extends $pb.GeneratedMessage {
  factory Order({
    $core.String? id,
    $core.String? shopId,
    $core.String? orderNumber,
    OrderStatus? status,
    $core.String? profileId,
    $core.String? contactId,
    $core.String? addressId,
    $8.Money? subtotal,
    $8.Money? total,
    $core.Iterable<OrderLine>? lines,
    $2.Timestamp? createdAt,
    $core.String? paymentSessionRef,
    $core.String? checkoutUrl,
    $core.String? paymentId,
    PaymentStatus? paymentStatus,
    FulfilmentStatus? fulfilmentStatus,
    $2.Timestamp? paidAt,
    $2.Timestamp? cancelledAt,
    $core.String? cancelReason,
    $core.String? ledgerTransactionId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (orderNumber != null) {
      $result.orderNumber = orderNumber;
    }
    if (status != null) {
      $result.status = status;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (addressId != null) {
      $result.addressId = addressId;
    }
    if (subtotal != null) {
      $result.subtotal = subtotal;
    }
    if (total != null) {
      $result.total = total;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (paymentSessionRef != null) {
      $result.paymentSessionRef = paymentSessionRef;
    }
    if (checkoutUrl != null) {
      $result.checkoutUrl = checkoutUrl;
    }
    if (paymentId != null) {
      $result.paymentId = paymentId;
    }
    if (paymentStatus != null) {
      $result.paymentStatus = paymentStatus;
    }
    if (fulfilmentStatus != null) {
      $result.fulfilmentStatus = fulfilmentStatus;
    }
    if (paidAt != null) {
      $result.paidAt = paidAt;
    }
    if (cancelledAt != null) {
      $result.cancelledAt = cancelledAt;
    }
    if (cancelReason != null) {
      $result.cancelReason = cancelReason;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    return $result;
  }
  Order._() : super();
  factory Order.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Order.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Order', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'orderNumber')
    ..e<OrderStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: OrderStatus.ORDER_STATUS_UNSPECIFIED, valueOf: OrderStatus.valueOf, enumValues: OrderStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..aOM<$8.Money>(8, _omitFieldNames ? '' : 'subtotal', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(9, _omitFieldNames ? '' : 'total', subBuilder: $8.Money.create)
    ..pc<OrderLine>(10, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: OrderLine.create)
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOS(12, _omitFieldNames ? '' : 'paymentSessionRef')
    ..aOS(13, _omitFieldNames ? '' : 'checkoutUrl')
    ..aOS(14, _omitFieldNames ? '' : 'paymentId')
    ..e<PaymentStatus>(15, _omitFieldNames ? '' : 'paymentStatus', $pb.PbFieldType.OE, defaultOrMaker: PaymentStatus.PAYMENT_STATUS_UNSPECIFIED, valueOf: PaymentStatus.valueOf, enumValues: PaymentStatus.values)
    ..e<FulfilmentStatus>(16, _omitFieldNames ? '' : 'fulfilmentStatus', $pb.PbFieldType.OE, defaultOrMaker: FulfilmentStatus.FULFILMENT_STATUS_UNSPECIFIED, valueOf: FulfilmentStatus.valueOf, enumValues: FulfilmentStatus.values)
    ..aOM<$2.Timestamp>(17, _omitFieldNames ? '' : 'paidAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(18, _omitFieldNames ? '' : 'cancelledAt', subBuilder: $2.Timestamp.create)
    ..aOS(19, _omitFieldNames ? '' : 'cancelReason')
    ..aOS(20, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Order clone() => Order()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Order copyWith(void Function(Order) updates) => super.copyWith((message) => updates(message as Order)) as Order;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Order create() => Order._();
  Order createEmptyInstance() => create();
  static $pb.PbList<Order> createRepeated() => $pb.PbList<Order>();
  @$core.pragma('dart2js:noInline')
  static Order getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Order>(create);
  static Order? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get orderNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set orderNumber($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrderNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderNumber() => clearField(3);

  @$pb.TagNumber(4)
  OrderStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(OrderStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(4);
  @$pb.TagNumber(5)
  set profileId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProfileId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(5);
  @$pb.TagNumber(6)
  set contactId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(5);
  @$pb.TagNumber(6)
  void clearContactId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(6);
  @$pb.TagNumber(7)
  set addressId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(6);
  @$pb.TagNumber(7)
  void clearAddressId() => clearField(7);

  @$pb.TagNumber(8)
  $8.Money get subtotal => $_getN(7);
  @$pb.TagNumber(8)
  set subtotal($8.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasSubtotal() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubtotal() => clearField(8);
  @$pb.TagNumber(8)
  $8.Money ensureSubtotal() => $_ensure(7);

  @$pb.TagNumber(9)
  $8.Money get total => $_getN(8);
  @$pb.TagNumber(9)
  set total($8.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasTotal() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotal() => clearField(9);
  @$pb.TagNumber(9)
  $8.Money ensureTotal() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.List<OrderLine> get lines => $_getList(9);

  @$pb.TagNumber(11)
  $2.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($2.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureCreatedAt() => $_ensure(10);

  /// Hosted checkout session for this order, set by CheckoutOrder.
  @$pb.TagNumber(12)
  $core.String get paymentSessionRef => $_getSZ(11);
  @$pb.TagNumber(12)
  set paymentSessionRef($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPaymentSessionRef() => $_has(11);
  @$pb.TagNumber(12)
  void clearPaymentSessionRef() => clearField(12);

  /// Page the buyer completes payment on.
  @$pb.TagNumber(13)
  $core.String get checkoutUrl => $_getSZ(12);
  @$pb.TagNumber(13)
  set checkoutUrl($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasCheckoutUrl() => $_has(12);
  @$pb.TagNumber(13)
  void clearCheckoutUrl() => clearField(13);

  /// Payment service reference once the session completes.
  @$pb.TagNumber(14)
  $core.String get paymentId => $_getSZ(13);
  @$pb.TagNumber(14)
  set paymentId($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasPaymentId() => $_has(13);
  @$pb.TagNumber(14)
  void clearPaymentId() => clearField(14);

  @$pb.TagNumber(15)
  PaymentStatus get paymentStatus => $_getN(14);
  @$pb.TagNumber(15)
  set paymentStatus(PaymentStatus v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasPaymentStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearPaymentStatus() => clearField(15);

  @$pb.TagNumber(16)
  FulfilmentStatus get fulfilmentStatus => $_getN(15);
  @$pb.TagNumber(16)
  set fulfilmentStatus(FulfilmentStatus v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasFulfilmentStatus() => $_has(15);
  @$pb.TagNumber(16)
  void clearFulfilmentStatus() => clearField(16);

  @$pb.TagNumber(17)
  $2.Timestamp get paidAt => $_getN(16);
  @$pb.TagNumber(17)
  set paidAt($2.Timestamp v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasPaidAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearPaidAt() => clearField(17);
  @$pb.TagNumber(17)
  $2.Timestamp ensurePaidAt() => $_ensure(16);

  @$pb.TagNumber(18)
  $2.Timestamp get cancelledAt => $_getN(17);
  @$pb.TagNumber(18)
  set cancelledAt($2.Timestamp v) { setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasCancelledAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearCancelledAt() => clearField(18);
  @$pb.TagNumber(18)
  $2.Timestamp ensureCancelledAt() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get cancelReason => $_getSZ(18);
  @$pb.TagNumber(19)
  set cancelReason($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasCancelReason() => $_has(18);
  @$pb.TagNumber(19)
  void clearCancelReason() => clearField(19);

  /// Ledger transaction this order was merged into at end of day.
  @$pb.TagNumber(20)
  $core.String get ledgerTransactionId => $_getSZ(19);
  @$pb.TagNumber(20)
  set ledgerTransactionId($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasLedgerTransactionId() => $_has(19);
  @$pb.TagNumber(20)
  void clearLedgerTransactionId() => clearField(20);
}

class OrderLine extends $pb.GeneratedMessage {
  factory OrderLine({
    $core.String? id,
    $core.String? productVariantId,
    $core.String? skuSnapshot,
    $core.String? nameSnapshot,
    $8.Money? unitPrice,
    $fixnum.Int64? quantity,
    $8.Money? totalPrice,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (skuSnapshot != null) {
      $result.skuSnapshot = skuSnapshot;
    }
    if (nameSnapshot != null) {
      $result.nameSnapshot = nameSnapshot;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    if (totalPrice != null) {
      $result.totalPrice = totalPrice;
    }
    return $result;
  }
  OrderLine._() : super();
  factory OrderLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrderLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrderLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aOS(3, _omitFieldNames ? '' : 'skuSnapshot')
    ..aOS(4, _omitFieldNames ? '' : 'nameSnapshot')
    ..aOM<$8.Money>(5, _omitFieldNames ? '' : 'unitPrice', subBuilder: $8.Money.create)
    ..aInt64(6, _omitFieldNames ? '' : 'quantity')
    ..aOM<$8.Money>(7, _omitFieldNames ? '' : 'totalPrice', subBuilder: $8.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrderLine clone() => OrderLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrderLine copyWith(void Function(OrderLine) updates) => super.copyWith((message) => updates(message as OrderLine)) as OrderLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrderLine create() => OrderLine._();
  OrderLine createEmptyInstance() => create();
  static $pb.PbList<OrderLine> createRepeated() => $pb.PbList<OrderLine>();
  @$core.pragma('dart2js:noInline')
  static OrderLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrderLine>(create);
  static OrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => clearField(2);

  /// Snapshot fields
  @$pb.TagNumber(3)
  $core.String get skuSnapshot => $_getSZ(2);
  @$pb.TagNumber(3)
  set skuSnapshot($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSkuSnapshot() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkuSnapshot() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get nameSnapshot => $_getSZ(3);
  @$pb.TagNumber(4)
  set nameSnapshot($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNameSnapshot() => $_has(3);
  @$pb.TagNumber(4)
  void clearNameSnapshot() => clearField(4);

  @$pb.TagNumber(5)
  $8.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($8.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => clearField(5);
  @$pb.TagNumber(5)
  $8.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get quantity => $_getI64(5);
  @$pb.TagNumber(6)
  set quantity($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuantity() => clearField(6);

  @$pb.TagNumber(7)
  $8.Money get totalPrice => $_getN(6);
  @$pb.TagNumber(7)
  set totalPrice($8.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalPrice() => clearField(7);
  @$pb.TagNumber(7)
  $8.Money ensureTotalPrice() => $_ensure(6);
}

class CreateOrderRequest extends $pb.GeneratedMessage {
  factory CreateOrderRequest({
    $core.String? shopId,
    $core.String? idempotencyKey,
    $core.String? profileId,
    $core.String? contactId,
    $core.String? addressId,
    $core.Iterable<CreateOrderLine>? lines,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (addressId != null) {
      $result.addressId = addressId;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    return $result;
  }
  CreateOrderRequest._() : super();
  factory CreateOrderRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateOrderRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateOrderRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..pc<CreateOrderLine>(10, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: CreateOrderLine.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateOrderRequest clone() => CreateOrderRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateOrderRequest copyWith(void Function(CreateOrderRequest) updates) => super.copyWith((message) => updates(message as CreateOrderRequest)) as CreateOrderRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateOrderRequest create() => CreateOrderRequest._();
  CreateOrderRequest createEmptyInstance() => create();
  static $pb.PbList<CreateOrderRequest> createRepeated() => $pb.PbList<CreateOrderRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateOrderRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderRequest>(create);
  static CreateOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => clearField(2);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(5)
  set profileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(5)
  void clearProfileId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(3);
  @$pb.TagNumber(6)
  set contactId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(3);
  @$pb.TagNumber(6)
  void clearContactId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(4);
  @$pb.TagNumber(7)
  set addressId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(4);
  @$pb.TagNumber(7)
  void clearAddressId() => clearField(7);

  @$pb.TagNumber(10)
  $core.List<CreateOrderLine> get lines => $_getList(5);
}

class CreateOrderResponse extends $pb.GeneratedMessage {
  factory CreateOrderResponse({
    Order? order,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  CreateOrderResponse._() : super();
  factory CreateOrderResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateOrderResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateOrderResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateOrderResponse clone() => CreateOrderResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateOrderResponse copyWith(void Function(CreateOrderResponse) updates) => super.copyWith((message) => updates(message as CreateOrderResponse)) as CreateOrderResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateOrderResponse create() => CreateOrderResponse._();
  CreateOrderResponse createEmptyInstance() => create();
  static $pb.PbList<CreateOrderResponse> createRepeated() => $pb.PbList<CreateOrderResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateOrderResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderResponse>(create);
  static CreateOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class CreateOrderLine extends $pb.GeneratedMessage {
  factory CreateOrderLine({
    $core.String? variantId,
    $fixnum.Int64? quantity,
  }) {
    final $result = create();
    if (variantId != null) {
      $result.variantId = variantId;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    return $result;
  }
  CreateOrderLine._() : super();
  factory CreateOrderLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateOrderLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateOrderLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aInt64(2, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateOrderLine clone() => CreateOrderLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateOrderLine copyWith(void Function(CreateOrderLine) updates) => super.copyWith((message) => updates(message as CreateOrderLine)) as CreateOrderLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateOrderLine create() => CreateOrderLine._();
  CreateOrderLine createEmptyInstance() => create();
  static $pb.PbList<CreateOrderLine> createRepeated() => $pb.PbList<CreateOrderLine>();
  @$core.pragma('dart2js:noInline')
  static CreateOrderLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderLine>(create);
  static CreateOrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quantity => $_getI64(1);
  @$pb.TagNumber(2)
  set quantity($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => clearField(2);
}

class GetOrderRequest extends $pb.GeneratedMessage {
  factory GetOrderRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetOrderRequest._() : super();
  factory GetOrderRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetOrderRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOrderRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetOrderRequest clone() => GetOrderRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetOrderRequest copyWith(void Function(GetOrderRequest) updates) => super.copyWith((message) => updates(message as GetOrderRequest)) as GetOrderRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOrderRequest create() => GetOrderRequest._();
  GetOrderRequest createEmptyInstance() => create();
  static $pb.PbList<GetOrderRequest> createRepeated() => $pb.PbList<GetOrderRequest>();
  @$core.pragma('dart2js:noInline')
  static GetOrderRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOrderRequest>(create);
  static GetOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetOrderResponse extends $pb.GeneratedMessage {
  factory GetOrderResponse({
    Order? order,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  GetOrderResponse._() : super();
  factory GetOrderResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetOrderResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOrderResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetOrderResponse clone() => GetOrderResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetOrderResponse copyWith(void Function(GetOrderResponse) updates) => super.copyWith((message) => updates(message as GetOrderResponse)) as GetOrderResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOrderResponse create() => GetOrderResponse._();
  GetOrderResponse createEmptyInstance() => create();
  static $pb.PbList<GetOrderResponse> createRepeated() => $pb.PbList<GetOrderResponse>();
  @$core.pragma('dart2js:noInline')
  static GetOrderResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOrderResponse>(create);
  static GetOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class ListOrdersRequest extends $pb.GeneratedMessage {
  factory ListOrdersRequest({
    $core.String? shopId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  ListOrdersRequest._() : super();
  factory ListOrdersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListOrdersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListOrdersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$7.SearchRequest>(2, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListOrdersRequest clone() => ListOrdersRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListOrdersRequest copyWith(void Function(ListOrdersRequest) updates) => super.copyWith((message) => updates(message as ListOrdersRequest)) as ListOrdersRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrdersRequest create() => ListOrdersRequest._();
  ListOrdersRequest createEmptyInstance() => create();
  static $pb.PbList<ListOrdersRequest> createRepeated() => $pb.PbList<ListOrdersRequest>();
  @$core.pragma('dart2js:noInline')
  static ListOrdersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListOrdersRequest>(create);
  static ListOrdersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  /// Optional search parameters (query, cursor, etc.)
  @$pb.TagNumber(2)
  $7.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($7.SearchRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => clearField(2);
  @$pb.TagNumber(2)
  $7.SearchRequest ensureSearch() => $_ensure(1);
}

class ListOrdersResponse extends $pb.GeneratedMessage {
  factory ListOrdersResponse({
    $core.Iterable<Order>? orders,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (orders != null) {
      $result.orders.addAll(orders);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  ListOrdersResponse._() : super();
  factory ListOrdersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListOrdersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListOrdersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<Order>(1, _omitFieldNames ? '' : 'orders', $pb.PbFieldType.PM, subBuilder: Order.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListOrdersResponse clone() => ListOrdersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListOrdersResponse copyWith(void Function(ListOrdersResponse) updates) => super.copyWith((message) => updates(message as ListOrdersResponse)) as ListOrdersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrdersResponse create() => ListOrdersResponse._();
  ListOrdersResponse createEmptyInstance() => create();
  static $pb.PbList<ListOrdersResponse> createRepeated() => $pb.PbList<ListOrdersResponse>();
  @$core.pragma('dart2js:noInline')
  static ListOrdersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListOrdersResponse>(create);
  static ListOrdersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Order> get orders => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class CheckoutOrderRequest extends $pb.GeneratedMessage {
  factory CheckoutOrderRequest({
    $core.String? orderId,
    $core.String? returnUrl,
    $core.Iterable<$core.String>? methods,
  }) {
    final $result = create();
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (returnUrl != null) {
      $result.returnUrl = returnUrl;
    }
    if (methods != null) {
      $result.methods.addAll(methods);
    }
    return $result;
  }
  CheckoutOrderRequest._() : super();
  factory CheckoutOrderRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckoutOrderRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckoutOrderRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOS(2, _omitFieldNames ? '' : 'returnUrl')
    ..pPS(3, _omitFieldNames ? '' : 'methods')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckoutOrderRequest clone() => CheckoutOrderRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckoutOrderRequest copyWith(void Function(CheckoutOrderRequest) updates) => super.copyWith((message) => updates(message as CheckoutOrderRequest)) as CheckoutOrderRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckoutOrderRequest create() => CheckoutOrderRequest._();
  CheckoutOrderRequest createEmptyInstance() => create();
  static $pb.PbList<CheckoutOrderRequest> createRepeated() => $pb.PbList<CheckoutOrderRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckoutOrderRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckoutOrderRequest>(create);
  static CheckoutOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => clearField(1);

  /// Overrides the shop's return URL for this session.
  @$pb.TagNumber(2)
  $core.String get returnUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set returnUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReturnUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearReturnUrl() => clearField(2);

  /// Optional restriction to specific payment methods.
  @$pb.TagNumber(3)
  $core.List<$core.String> get methods => $_getList(2);
}

class CheckoutOrderResponse extends $pb.GeneratedMessage {
  factory CheckoutOrderResponse({
    Order? order,
    $core.String? checkoutUrl,
    $core.String? sessionRef,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    if (checkoutUrl != null) {
      $result.checkoutUrl = checkoutUrl;
    }
    if (sessionRef != null) {
      $result.sessionRef = sessionRef;
    }
    return $result;
  }
  CheckoutOrderResponse._() : super();
  factory CheckoutOrderResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckoutOrderResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckoutOrderResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..aOS(2, _omitFieldNames ? '' : 'checkoutUrl')
    ..aOS(3, _omitFieldNames ? '' : 'sessionRef')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckoutOrderResponse clone() => CheckoutOrderResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckoutOrderResponse copyWith(void Function(CheckoutOrderResponse) updates) => super.copyWith((message) => updates(message as CheckoutOrderResponse)) as CheckoutOrderResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckoutOrderResponse create() => CheckoutOrderResponse._();
  CheckoutOrderResponse createEmptyInstance() => create();
  static $pb.PbList<CheckoutOrderResponse> createRepeated() => $pb.PbList<CheckoutOrderResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckoutOrderResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckoutOrderResponse>(create);
  static CheckoutOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get checkoutUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set checkoutUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCheckoutUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheckoutUrl() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionRef => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionRef($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSessionRef() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionRef() => clearField(3);
}

class ConfirmOrderPaymentRequest extends $pb.GeneratedMessage {
  factory ConfirmOrderPaymentRequest({
    $core.String? orderId,
  }) {
    final $result = create();
    if (orderId != null) {
      $result.orderId = orderId;
    }
    return $result;
  }
  ConfirmOrderPaymentRequest._() : super();
  factory ConfirmOrderPaymentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConfirmOrderPaymentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmOrderPaymentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConfirmOrderPaymentRequest clone() => ConfirmOrderPaymentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConfirmOrderPaymentRequest copyWith(void Function(ConfirmOrderPaymentRequest) updates) => super.copyWith((message) => updates(message as ConfirmOrderPaymentRequest)) as ConfirmOrderPaymentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentRequest create() => ConfirmOrderPaymentRequest._();
  ConfirmOrderPaymentRequest createEmptyInstance() => create();
  static $pb.PbList<ConfirmOrderPaymentRequest> createRepeated() => $pb.PbList<ConfirmOrderPaymentRequest>();
  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmOrderPaymentRequest>(create);
  static ConfirmOrderPaymentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => clearField(1);
}

class ConfirmOrderPaymentResponse extends $pb.GeneratedMessage {
  factory ConfirmOrderPaymentResponse({
    Order? order,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  ConfirmOrderPaymentResponse._() : super();
  factory ConfirmOrderPaymentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConfirmOrderPaymentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmOrderPaymentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConfirmOrderPaymentResponse clone() => ConfirmOrderPaymentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConfirmOrderPaymentResponse copyWith(void Function(ConfirmOrderPaymentResponse) updates) => super.copyWith((message) => updates(message as ConfirmOrderPaymentResponse)) as ConfirmOrderPaymentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentResponse create() => ConfirmOrderPaymentResponse._();
  ConfirmOrderPaymentResponse createEmptyInstance() => create();
  static $pb.PbList<ConfirmOrderPaymentResponse> createRepeated() => $pb.PbList<ConfirmOrderPaymentResponse>();
  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmOrderPaymentResponse>(create);
  static ConfirmOrderPaymentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class CancelOrderRequest extends $pb.GeneratedMessage {
  factory CancelOrderRequest({
    $core.String? orderId,
    $core.String? reason,
  }) {
    final $result = create();
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  CancelOrderRequest._() : super();
  factory CancelOrderRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CancelOrderRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelOrderRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CancelOrderRequest clone() => CancelOrderRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CancelOrderRequest copyWith(void Function(CancelOrderRequest) updates) => super.copyWith((message) => updates(message as CancelOrderRequest)) as CancelOrderRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelOrderRequest create() => CancelOrderRequest._();
  CancelOrderRequest createEmptyInstance() => create();
  static $pb.PbList<CancelOrderRequest> createRepeated() => $pb.PbList<CancelOrderRequest>();
  @$core.pragma('dart2js:noInline')
  static CancelOrderRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelOrderRequest>(create);
  static CancelOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class CancelOrderResponse extends $pb.GeneratedMessage {
  factory CancelOrderResponse({
    Order? order,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    return $result;
  }
  CancelOrderResponse._() : super();
  factory CancelOrderResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CancelOrderResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelOrderResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CancelOrderResponse clone() => CancelOrderResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CancelOrderResponse copyWith(void Function(CancelOrderResponse) updates) => super.copyWith((message) => updates(message as CancelOrderResponse)) as CancelOrderResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelOrderResponse create() => CancelOrderResponse._();
  CancelOrderResponse createEmptyInstance() => create();
  static $pb.PbList<CancelOrderResponse> createRepeated() => $pb.PbList<CancelOrderResponse>();
  @$core.pragma('dart2js:noInline')
  static CancelOrderResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelOrderResponse>(create);
  static CancelOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class ReconcilePaymentsRequest extends $pb.GeneratedMessage {
  factory ReconcilePaymentsRequest({
    $core.String? shopId,
    $core.int? limit,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ReconcilePaymentsRequest._() : super();
  factory ReconcilePaymentsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconcilePaymentsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconcilePaymentsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconcilePaymentsRequest clone() => ReconcilePaymentsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconcilePaymentsRequest copyWith(void Function(ReconcilePaymentsRequest) updates) => super.copyWith((message) => updates(message as ReconcilePaymentsRequest)) as ReconcilePaymentsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsRequest create() => ReconcilePaymentsRequest._();
  ReconcilePaymentsRequest createEmptyInstance() => create();
  static $pb.PbList<ReconcilePaymentsRequest> createRepeated() => $pb.PbList<ReconcilePaymentsRequest>();
  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconcilePaymentsRequest>(create);
  static ReconcilePaymentsRequest? _defaultInstance;

  /// Limit to one shop; empty reconciles every shop in the partition.
  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  /// Maximum orders to examine in this run.
  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);
}

class ReconcilePaymentsResponse extends $pb.GeneratedMessage {
  factory ReconcilePaymentsResponse({
    $core.int? examined,
    $core.int? paid,
    $core.int? expired,
    $core.int? failed,
  }) {
    final $result = create();
    if (examined != null) {
      $result.examined = examined;
    }
    if (paid != null) {
      $result.paid = paid;
    }
    if (expired != null) {
      $result.expired = expired;
    }
    if (failed != null) {
      $result.failed = failed;
    }
    return $result;
  }
  ReconcilePaymentsResponse._() : super();
  factory ReconcilePaymentsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconcilePaymentsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconcilePaymentsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'examined', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'paid', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'expired', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'failed', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconcilePaymentsResponse clone() => ReconcilePaymentsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconcilePaymentsResponse copyWith(void Function(ReconcilePaymentsResponse) updates) => super.copyWith((message) => updates(message as ReconcilePaymentsResponse)) as ReconcilePaymentsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsResponse create() => ReconcilePaymentsResponse._();
  ReconcilePaymentsResponse createEmptyInstance() => create();
  static $pb.PbList<ReconcilePaymentsResponse> createRepeated() => $pb.PbList<ReconcilePaymentsResponse>();
  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconcilePaymentsResponse>(create);
  static ReconcilePaymentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get examined => $_getIZ(0);
  @$pb.TagNumber(1)
  set examined($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExamined() => $_has(0);
  @$pb.TagNumber(1)
  void clearExamined() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get paid => $_getIZ(1);
  @$pb.TagNumber(2)
  set paid($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPaid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaid() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get expired => $_getIZ(2);
  @$pb.TagNumber(3)
  set expired($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExpired() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpired() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get failed => $_getIZ(3);
  @$pb.TagNumber(4)
  set failed($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFailed() => $_has(3);
  @$pb.TagNumber(4)
  void clearFailed() => clearField(4);
}

class RunEndOfDayLedgerRequest extends $pb.GeneratedMessage {
  factory RunEndOfDayLedgerRequest({
    $core.String? shopId,
    $core.String? date,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (date != null) {
      $result.date = date;
    }
    return $result;
  }
  RunEndOfDayLedgerRequest._() : super();
  factory RunEndOfDayLedgerRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RunEndOfDayLedgerRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RunEndOfDayLedgerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RunEndOfDayLedgerRequest clone() => RunEndOfDayLedgerRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RunEndOfDayLedgerRequest copyWith(void Function(RunEndOfDayLedgerRequest) updates) => super.copyWith((message) => updates(message as RunEndOfDayLedgerRequest)) as RunEndOfDayLedgerRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerRequest create() => RunEndOfDayLedgerRequest._();
  RunEndOfDayLedgerRequest createEmptyInstance() => create();
  static $pb.PbList<RunEndOfDayLedgerRequest> createRepeated() => $pb.PbList<RunEndOfDayLedgerRequest>();
  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RunEndOfDayLedgerRequest>(create);
  static RunEndOfDayLedgerRequest? _defaultInstance;

  /// Limit to one shop; empty runs every shop in the partition.
  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  /// Trading day in YYYY-MM-DD, interpreted in the shop's timezone. Empty
  /// means the previous calendar day.
  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => clearField(2);
}

class LedgerPosting extends $pb.GeneratedMessage {
  factory LedgerPosting({
    $core.String? shopId,
    $core.String? date,
    $core.String? transactionId,
    $8.Money? sales,
    $8.Money? refunds,
    $core.int? orders,
    $core.bool? skipped,
    $core.String? error,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (date != null) {
      $result.date = date;
    }
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    if (sales != null) {
      $result.sales = sales;
    }
    if (refunds != null) {
      $result.refunds = refunds;
    }
    if (orders != null) {
      $result.orders = orders;
    }
    if (skipped != null) {
      $result.skipped = skipped;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  LedgerPosting._() : super();
  factory LedgerPosting.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LedgerPosting.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LedgerPosting', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..aOS(3, _omitFieldNames ? '' : 'transactionId')
    ..aOM<$8.Money>(4, _omitFieldNames ? '' : 'sales', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(5, _omitFieldNames ? '' : 'refunds', subBuilder: $8.Money.create)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'orders', $pb.PbFieldType.O3)
    ..aOB(7, _omitFieldNames ? '' : 'skipped')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LedgerPosting clone() => LedgerPosting()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LedgerPosting copyWith(void Function(LedgerPosting) updates) => super.copyWith((message) => updates(message as LedgerPosting)) as LedgerPosting;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerPosting create() => LedgerPosting._();
  LedgerPosting createEmptyInstance() => create();
  static $pb.PbList<LedgerPosting> createRepeated() => $pb.PbList<LedgerPosting>();
  @$core.pragma('dart2js:noInline')
  static LedgerPosting getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerPosting>(create);
  static LedgerPosting? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get transactionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set transactionId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTransactionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransactionId() => clearField(3);

  @$pb.TagNumber(4)
  $8.Money get sales => $_getN(3);
  @$pb.TagNumber(4)
  set sales($8.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSales() => $_has(3);
  @$pb.TagNumber(4)
  void clearSales() => clearField(4);
  @$pb.TagNumber(4)
  $8.Money ensureSales() => $_ensure(3);

  @$pb.TagNumber(5)
  $8.Money get refunds => $_getN(4);
  @$pb.TagNumber(5)
  set refunds($8.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRefunds() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefunds() => clearField(5);
  @$pb.TagNumber(5)
  $8.Money ensureRefunds() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get orders => $_getIZ(5);
  @$pb.TagNumber(6)
  set orders($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOrders() => $_has(5);
  @$pb.TagNumber(6)
  void clearOrders() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get skipped => $_getBF(6);
  @$pb.TagNumber(7)
  set skipped($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSkipped() => $_has(6);
  @$pb.TagNumber(7)
  void clearSkipped() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => clearField(8);
}

class RunEndOfDayLedgerResponse extends $pb.GeneratedMessage {
  factory RunEndOfDayLedgerResponse({
    $core.Iterable<LedgerPosting>? postings,
  }) {
    final $result = create();
    if (postings != null) {
      $result.postings.addAll(postings);
    }
    return $result;
  }
  RunEndOfDayLedgerResponse._() : super();
  factory RunEndOfDayLedgerResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RunEndOfDayLedgerResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RunEndOfDayLedgerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<LedgerPosting>(1, _omitFieldNames ? '' : 'postings', $pb.PbFieldType.PM, subBuilder: LedgerPosting.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RunEndOfDayLedgerResponse clone() => RunEndOfDayLedgerResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RunEndOfDayLedgerResponse copyWith(void Function(RunEndOfDayLedgerResponse) updates) => super.copyWith((message) => updates(message as RunEndOfDayLedgerResponse)) as RunEndOfDayLedgerResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerResponse create() => RunEndOfDayLedgerResponse._();
  RunEndOfDayLedgerResponse createEmptyInstance() => create();
  static $pb.PbList<RunEndOfDayLedgerResponse> createRepeated() => $pb.PbList<RunEndOfDayLedgerResponse>();
  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RunEndOfDayLedgerResponse>(create);
  static RunEndOfDayLedgerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LedgerPosting> get postings => $_getList(0);
}

class Fulfilment extends $pb.GeneratedMessage {
  factory Fulfilment({
    $core.String? id,
    $core.String? orderId,
    FulfilmentStatus? status,
    $core.String? carrier,
    $core.String? trackingNumber,
    $core.Iterable<FulfilmentLine>? lines,
    $2.Timestamp? createdAt,
    $2.Timestamp? shippedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (carrier != null) {
      $result.carrier = carrier;
    }
    if (trackingNumber != null) {
      $result.trackingNumber = trackingNumber;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (shippedAt != null) {
      $result.shippedAt = shippedAt;
    }
    return $result;
  }
  Fulfilment._() : super();
  factory Fulfilment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Fulfilment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Fulfilment', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'orderId')
    ..e<FulfilmentStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FulfilmentStatus.FULFILMENT_STATUS_UNSPECIFIED, valueOf: FulfilmentStatus.valueOf, enumValues: FulfilmentStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'carrier')
    ..aOS(5, _omitFieldNames ? '' : 'trackingNumber')
    ..pc<FulfilmentLine>(6, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: FulfilmentLine.create)
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'shippedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Fulfilment clone() => Fulfilment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Fulfilment copyWith(void Function(Fulfilment) updates) => super.copyWith((message) => updates(message as Fulfilment)) as Fulfilment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Fulfilment create() => Fulfilment._();
  Fulfilment createEmptyInstance() => create();
  static $pb.PbList<Fulfilment> createRepeated() => $pb.PbList<Fulfilment>();
  @$core.pragma('dart2js:noInline')
  static Fulfilment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Fulfilment>(create);
  static Fulfilment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get orderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set orderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderId() => clearField(2);

  @$pb.TagNumber(3)
  FulfilmentStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FulfilmentStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get carrier => $_getSZ(3);
  @$pb.TagNumber(4)
  set carrier($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCarrier() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarrier() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get trackingNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set trackingNumber($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTrackingNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrackingNumber() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<FulfilmentLine> get lines => $_getList(5);

  @$pb.TagNumber(7)
  $2.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($2.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $2.Timestamp get shippedAt => $_getN(7);
  @$pb.TagNumber(8)
  set shippedAt($2.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasShippedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearShippedAt() => clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureShippedAt() => $_ensure(7);
}

class FulfilmentLine extends $pb.GeneratedMessage {
  factory FulfilmentLine({
    $core.String? orderLineId,
    $fixnum.Int64? quantity,
  }) {
    final $result = create();
    if (orderLineId != null) {
      $result.orderLineId = orderLineId;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    return $result;
  }
  FulfilmentLine._() : super();
  factory FulfilmentLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FulfilmentLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FulfilmentLine', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orderLineId')
    ..aInt64(2, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FulfilmentLine clone() => FulfilmentLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FulfilmentLine copyWith(void Function(FulfilmentLine) updates) => super.copyWith((message) => updates(message as FulfilmentLine)) as FulfilmentLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FulfilmentLine create() => FulfilmentLine._();
  FulfilmentLine createEmptyInstance() => create();
  static $pb.PbList<FulfilmentLine> createRepeated() => $pb.PbList<FulfilmentLine>();
  @$core.pragma('dart2js:noInline')
  static FulfilmentLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FulfilmentLine>(create);
  static FulfilmentLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderLineId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderLineId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrderLineId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderLineId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quantity => $_getI64(1);
  @$pb.TagNumber(2)
  set quantity($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => clearField(2);
}

class CreateFulfilmentRequest extends $pb.GeneratedMessage {
  factory CreateFulfilmentRequest({
    $core.String? orderId,
    $core.Iterable<FulfilmentLine>? lines,
  }) {
    final $result = create();
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (lines != null) {
      $result.lines.addAll(lines);
    }
    return $result;
  }
  CreateFulfilmentRequest._() : super();
  factory CreateFulfilmentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateFulfilmentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateFulfilmentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..pc<FulfilmentLine>(2, _omitFieldNames ? '' : 'lines', $pb.PbFieldType.PM, subBuilder: FulfilmentLine.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateFulfilmentRequest clone() => CreateFulfilmentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateFulfilmentRequest copyWith(void Function(CreateFulfilmentRequest) updates) => super.copyWith((message) => updates(message as CreateFulfilmentRequest)) as CreateFulfilmentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentRequest create() => CreateFulfilmentRequest._();
  CreateFulfilmentRequest createEmptyInstance() => create();
  static $pb.PbList<CreateFulfilmentRequest> createRepeated() => $pb.PbList<CreateFulfilmentRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateFulfilmentRequest>(create);
  static CreateFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<FulfilmentLine> get lines => $_getList(1);
}

class CreateFulfilmentResponse extends $pb.GeneratedMessage {
  factory CreateFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final $result = create();
    if (fulfilment != null) {
      $result.fulfilment = fulfilment;
    }
    return $result;
  }
  CreateFulfilmentResponse._() : super();
  factory CreateFulfilmentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateFulfilmentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateFulfilmentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment', subBuilder: Fulfilment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateFulfilmentResponse clone() => CreateFulfilmentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateFulfilmentResponse copyWith(void Function(CreateFulfilmentResponse) updates) => super.copyWith((message) => updates(message as CreateFulfilmentResponse)) as CreateFulfilmentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentResponse create() => CreateFulfilmentResponse._();
  CreateFulfilmentResponse createEmptyInstance() => create();
  static $pb.PbList<CreateFulfilmentResponse> createRepeated() => $pb.PbList<CreateFulfilmentResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateFulfilmentResponse>(create);
  static CreateFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

class UpdateFulfilmentRequest extends $pb.GeneratedMessage {
  factory UpdateFulfilmentRequest({
    $core.String? id,
    $1.FieldMask? updateMask,
    FulfilmentStatus? status,
    $core.String? carrier,
    $core.String? trackingNumber,
    $2.Timestamp? shippedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (updateMask != null) {
      $result.updateMask = updateMask;
    }
    if (status != null) {
      $result.status = status;
    }
    if (carrier != null) {
      $result.carrier = carrier;
    }
    if (trackingNumber != null) {
      $result.trackingNumber = trackingNumber;
    }
    if (shippedAt != null) {
      $result.shippedAt = shippedAt;
    }
    return $result;
  }
  UpdateFulfilmentRequest._() : super();
  factory UpdateFulfilmentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateFulfilmentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateFulfilmentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.FieldMask>(2, _omitFieldNames ? '' : 'updateMask', subBuilder: $1.FieldMask.create)
    ..e<FulfilmentStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FulfilmentStatus.FULFILMENT_STATUS_UNSPECIFIED, valueOf: FulfilmentStatus.valueOf, enumValues: FulfilmentStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'carrier')
    ..aOS(5, _omitFieldNames ? '' : 'trackingNumber')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'shippedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateFulfilmentRequest clone() => UpdateFulfilmentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateFulfilmentRequest copyWith(void Function(UpdateFulfilmentRequest) updates) => super.copyWith((message) => updates(message as UpdateFulfilmentRequest)) as UpdateFulfilmentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentRequest create() => UpdateFulfilmentRequest._();
  UpdateFulfilmentRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateFulfilmentRequest> createRepeated() => $pb.PbList<UpdateFulfilmentRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateFulfilmentRequest>(create);
  static UpdateFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $1.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($1.FieldMask v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => clearField(2);
  @$pb.TagNumber(2)
  $1.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  FulfilmentStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FulfilmentStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get carrier => $_getSZ(3);
  @$pb.TagNumber(4)
  set carrier($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCarrier() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarrier() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get trackingNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set trackingNumber($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTrackingNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrackingNumber() => clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get shippedAt => $_getN(5);
  @$pb.TagNumber(6)
  set shippedAt($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasShippedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearShippedAt() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureShippedAt() => $_ensure(5);
}

class UpdateFulfilmentResponse extends $pb.GeneratedMessage {
  factory UpdateFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final $result = create();
    if (fulfilment != null) {
      $result.fulfilment = fulfilment;
    }
    return $result;
  }
  UpdateFulfilmentResponse._() : super();
  factory UpdateFulfilmentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateFulfilmentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateFulfilmentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment', subBuilder: Fulfilment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateFulfilmentResponse clone() => UpdateFulfilmentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateFulfilmentResponse copyWith(void Function(UpdateFulfilmentResponse) updates) => super.copyWith((message) => updates(message as UpdateFulfilmentResponse)) as UpdateFulfilmentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentResponse create() => UpdateFulfilmentResponse._();
  UpdateFulfilmentResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateFulfilmentResponse> createRepeated() => $pb.PbList<UpdateFulfilmentResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateFulfilmentResponse>(create);
  static UpdateFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

class GetFulfilmentRequest extends $pb.GeneratedMessage {
  factory GetFulfilmentRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetFulfilmentRequest._() : super();
  factory GetFulfilmentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFulfilmentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFulfilmentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFulfilmentRequest clone() => GetFulfilmentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFulfilmentRequest copyWith(void Function(GetFulfilmentRequest) updates) => super.copyWith((message) => updates(message as GetFulfilmentRequest)) as GetFulfilmentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFulfilmentRequest create() => GetFulfilmentRequest._();
  GetFulfilmentRequest createEmptyInstance() => create();
  static $pb.PbList<GetFulfilmentRequest> createRepeated() => $pb.PbList<GetFulfilmentRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFulfilmentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFulfilmentRequest>(create);
  static GetFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetFulfilmentResponse extends $pb.GeneratedMessage {
  factory GetFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final $result = create();
    if (fulfilment != null) {
      $result.fulfilment = fulfilment;
    }
    return $result;
  }
  GetFulfilmentResponse._() : super();
  factory GetFulfilmentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFulfilmentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFulfilmentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment', subBuilder: Fulfilment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFulfilmentResponse clone() => GetFulfilmentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFulfilmentResponse copyWith(void Function(GetFulfilmentResponse) updates) => super.copyWith((message) => updates(message as GetFulfilmentResponse)) as GetFulfilmentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFulfilmentResponse create() => GetFulfilmentResponse._();
  GetFulfilmentResponse createEmptyInstance() => create();
  static $pb.PbList<GetFulfilmentResponse> createRepeated() => $pb.PbList<GetFulfilmentResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFulfilmentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFulfilmentResponse>(create);
  static GetFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

/// A named collection of prices for product variants, scoped to a shop and currency.
class PriceList extends $pb.GeneratedMessage {
  factory PriceList({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? currency,
    $core.int? priority,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    PriceListStatus? status,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  PriceList._() : super();
  factory PriceList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceList', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.O3)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..e<PriceListStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PriceListStatus.PRICE_LIST_STATUS_UNSPECIFIED, valueOf: PriceListStatus.valueOf, enumValues: PriceListStatus.values)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceList clone() => PriceList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceList copyWith(void Function(PriceList) updates) => super.copyWith((message) => updates(message as PriceList)) as PriceList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceList create() => PriceList._();
  PriceList createEmptyInstance() => create();
  static $pb.PbList<PriceList> createRepeated() => $pb.PbList<PriceList>();
  @$core.pragma('dart2js:noInline')
  static PriceList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceList>(create);
  static PriceList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get priority => $_getIZ(4);
  @$pb.TagNumber(5)
  set priority($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get validFrom => $_getN(5);
  @$pb.TagNumber(6)
  set validFrom($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasValidFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidFrom() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureValidFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.Timestamp get validUntil => $_getN(6);
  @$pb.TagNumber(7)
  set validUntil($2.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasValidUntil() => $_has(6);
  @$pb.TagNumber(7)
  void clearValidUntil() => clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureValidUntil() => $_ensure(6);

  @$pb.TagNumber(8)
  PriceListStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(PriceListStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);
}

/// A single price entry within a price list, optionally quantity-tiered.
class PriceListEntry extends $pb.GeneratedMessage {
  factory PriceListEntry({
    $core.String? id,
    $core.String? priceListId,
    $core.String? productVariantId,
    $8.Money? unitPrice,
    $core.int? minQuantity,
    $core.int? maxQuantity,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (minQuantity != null) {
      $result.minQuantity = minQuantity;
    }
    if (maxQuantity != null) {
      $result.maxQuantity = maxQuantity;
    }
    return $result;
  }
  PriceListEntry._() : super();
  factory PriceListEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'priceListId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$8.Money>(4, _omitFieldNames ? '' : 'unitPrice', subBuilder: $8.Money.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'minQuantity', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'maxQuantity', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListEntry clone() => PriceListEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListEntry copyWith(void Function(PriceListEntry) updates) => super.copyWith((message) => updates(message as PriceListEntry)) as PriceListEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListEntry create() => PriceListEntry._();
  PriceListEntry createEmptyInstance() => create();
  static $pb.PbList<PriceListEntry> createRepeated() => $pb.PbList<PriceListEntry>();
  @$core.pragma('dart2js:noInline')
  static PriceListEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListEntry>(create);
  static PriceListEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get priceListId => $_getSZ(1);
  @$pb.TagNumber(2)
  set priceListId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPriceListId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPriceListId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => clearField(3);

  @$pb.TagNumber(4)
  $8.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($8.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => clearField(4);
  @$pb.TagNumber(4)
  $8.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get minQuantity => $_getIZ(4);
  @$pb.TagNumber(5)
  set minQuantity($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMinQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinQuantity() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxQuantity => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxQuantity($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxQuantity() => clearField(6);
}

/// Links a customer to a price list.
class CustomerPriceListAssignment extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignment({
    $core.String? id,
    $core.String? customerId,
    $core.String? priceListId,
    $core.String? assignedBy,
    CustomerPriceListAssignmentStatus? status,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (assignedBy != null) {
      $result.assignedBy = assignedBy;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  CustomerPriceListAssignment._() : super();
  factory CustomerPriceListAssignment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceListAssignment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceListAssignment', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'priceListId')
    ..aOS(4, _omitFieldNames ? '' : 'assignedBy')
    ..e<CustomerPriceListAssignmentStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CustomerPriceListAssignmentStatus.CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED, valueOf: CustomerPriceListAssignmentStatus.valueOf, enumValues: CustomerPriceListAssignmentStatus.values)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignment clone() => CustomerPriceListAssignment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignment copyWith(void Function(CustomerPriceListAssignment) updates) => super.copyWith((message) => updates(message as CustomerPriceListAssignment)) as CustomerPriceListAssignment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignment create() => CustomerPriceListAssignment._();
  CustomerPriceListAssignment createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceListAssignment> createRepeated() => $pb.PbList<CustomerPriceListAssignment>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignment>(create);
  static CustomerPriceListAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get priceListId => $_getSZ(2);
  @$pb.TagNumber(3)
  set priceListId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPriceListId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceListId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get assignedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAssignedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedBy() => clearField(4);

  @$pb.TagNumber(5)
  CustomerPriceListAssignmentStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(CustomerPriceListAssignmentStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(5);
}

/// A per-customer, per-variant price override that takes precedence over price lists.
class CustomerPriceOverride extends $pb.GeneratedMessage {
  factory CustomerPriceOverride({
    $core.String? id,
    $core.String? customerId,
    $core.String? productVariantId,
    $8.Money? unitPrice,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    $core.String? approvedBy,
    CustomerPriceOverrideStatus? status,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (approvedBy != null) {
      $result.approvedBy = approvedBy;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  CustomerPriceOverride._() : super();
  factory CustomerPriceOverride.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceOverride.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceOverride', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$8.Money>(4, _omitFieldNames ? '' : 'unitPrice', subBuilder: $8.Money.create)
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..aOS(7, _omitFieldNames ? '' : 'approvedBy')
    ..e<CustomerPriceOverrideStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED, valueOf: CustomerPriceOverrideStatus.valueOf, enumValues: CustomerPriceOverrideStatus.values)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceOverride clone() => CustomerPriceOverride()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceOverride copyWith(void Function(CustomerPriceOverride) updates) => super.copyWith((message) => updates(message as CustomerPriceOverride)) as CustomerPriceOverride;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverride create() => CustomerPriceOverride._();
  CustomerPriceOverride createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceOverride> createRepeated() => $pb.PbList<CustomerPriceOverride>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverride getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverride>(create);
  static CustomerPriceOverride? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => clearField(3);

  @$pb.TagNumber(4)
  $8.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($8.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => clearField(4);
  @$pb.TagNumber(4)
  $8.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $2.Timestamp get validFrom => $_getN(4);
  @$pb.TagNumber(5)
  set validFrom($2.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasValidFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidFrom() => clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureValidFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get validUntil => $_getN(5);
  @$pb.TagNumber(6)
  set validUntil($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasValidUntil() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidUntil() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureValidUntil() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get approvedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set approvedBy($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasApprovedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearApprovedBy() => clearField(7);

  @$pb.TagNumber(8)
  CustomerPriceOverrideStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(CustomerPriceOverrideStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);
}

/// A rule that applies discounts to orders or line items based on conditions.
class DiscountRule extends $pb.GeneratedMessage {
  factory DiscountRule({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    DiscountType? discountType,
    $core.double? value,
    DiscountAppliesTo? appliesTo,
    $6.Struct? conditions,
    $core.bool? requiresApproval,
    $core.double? maxDiscountPercent,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    DiscountRuleStatus? status,
    $2.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (discountType != null) {
      $result.discountType = discountType;
    }
    if (value != null) {
      $result.value = value;
    }
    if (appliesTo != null) {
      $result.appliesTo = appliesTo;
    }
    if (conditions != null) {
      $result.conditions = conditions;
    }
    if (requiresApproval != null) {
      $result.requiresApproval = requiresApproval;
    }
    if (maxDiscountPercent != null) {
      $result.maxDiscountPercent = maxDiscountPercent;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  DiscountRule._() : super();
  factory DiscountRule.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscountRule.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiscountRule', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<DiscountType>(4, _omitFieldNames ? '' : 'discountType', $pb.PbFieldType.OE, defaultOrMaker: DiscountType.DISCOUNT_TYPE_UNSPECIFIED, valueOf: DiscountType.valueOf, enumValues: DiscountType.values)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..e<DiscountAppliesTo>(6, _omitFieldNames ? '' : 'appliesTo', $pb.PbFieldType.OE, defaultOrMaker: DiscountAppliesTo.DISCOUNT_APPLIES_TO_UNSPECIFIED, valueOf: DiscountAppliesTo.valueOf, enumValues: DiscountAppliesTo.values)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'conditions', subBuilder: $6.Struct.create)
    ..aOB(8, _omitFieldNames ? '' : 'requiresApproval')
    ..a<$core.double>(9, _omitFieldNames ? '' : 'maxDiscountPercent', $pb.PbFieldType.OD)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..e<DiscountRuleStatus>(12, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DiscountRuleStatus.DISCOUNT_RULE_STATUS_UNSPECIFIED, valueOf: DiscountRuleStatus.valueOf, enumValues: DiscountRuleStatus.values)
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiscountRule clone() => DiscountRule()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiscountRule copyWith(void Function(DiscountRule) updates) => super.copyWith((message) => updates(message as DiscountRule)) as DiscountRule;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscountRule create() => DiscountRule._();
  DiscountRule createEmptyInstance() => create();
  static $pb.PbList<DiscountRule> createRepeated() => $pb.PbList<DiscountRule>();
  @$core.pragma('dart2js:noInline')
  static DiscountRule getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRule>(create);
  static DiscountRule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  DiscountType get discountType => $_getN(3);
  @$pb.TagNumber(4)
  set discountType(DiscountType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDiscountType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscountType() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get value => $_getN(4);
  @$pb.TagNumber(5)
  set value($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => clearField(5);

  @$pb.TagNumber(6)
  DiscountAppliesTo get appliesTo => $_getN(5);
  @$pb.TagNumber(6)
  set appliesTo(DiscountAppliesTo v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAppliesTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppliesTo() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get conditions => $_getN(6);
  @$pb.TagNumber(7)
  set conditions($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasConditions() => $_has(6);
  @$pb.TagNumber(7)
  void clearConditions() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureConditions() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get requiresApproval => $_getBF(7);
  @$pb.TagNumber(8)
  set requiresApproval($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRequiresApproval() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequiresApproval() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxDiscountPercent => $_getN(8);
  @$pb.TagNumber(9)
  set maxDiscountPercent($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMaxDiscountPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxDiscountPercent() => clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get validFrom => $_getN(9);
  @$pb.TagNumber(10)
  set validFrom($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasValidFrom() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidFrom() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureValidFrom() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.Timestamp get validUntil => $_getN(10);
  @$pb.TagNumber(11)
  set validUntil($2.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasValidUntil() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidUntil() => clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureValidUntil() => $_ensure(10);

  @$pb.TagNumber(12)
  DiscountRuleStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(DiscountRuleStatus v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => clearField(12);

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

/// The fully resolved price for a variant, showing which source and discounts apply.
class ResolvedPrice extends $pb.GeneratedMessage {
  factory ResolvedPrice({
    $core.String? variantId,
    $8.Money? unitPrice,
    PriceSource? priceSource,
    $core.String? priceListId,
    $core.String? overrideId,
    $8.Money? discountAmount,
    $core.String? discountRuleId,
    $8.Money? preDiscountPrice,
  }) {
    final $result = create();
    if (variantId != null) {
      $result.variantId = variantId;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (priceSource != null) {
      $result.priceSource = priceSource;
    }
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (overrideId != null) {
      $result.overrideId = overrideId;
    }
    if (discountAmount != null) {
      $result.discountAmount = discountAmount;
    }
    if (discountRuleId != null) {
      $result.discountRuleId = discountRuleId;
    }
    if (preDiscountPrice != null) {
      $result.preDiscountPrice = preDiscountPrice;
    }
    return $result;
  }
  ResolvedPrice._() : super();
  factory ResolvedPrice.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResolvedPrice.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResolvedPrice', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aOM<$8.Money>(2, _omitFieldNames ? '' : 'unitPrice', subBuilder: $8.Money.create)
    ..e<PriceSource>(3, _omitFieldNames ? '' : 'priceSource', $pb.PbFieldType.OE, defaultOrMaker: PriceSource.PRICE_SOURCE_UNSPECIFIED, valueOf: PriceSource.valueOf, enumValues: PriceSource.values)
    ..aOS(4, _omitFieldNames ? '' : 'priceListId')
    ..aOS(5, _omitFieldNames ? '' : 'overrideId')
    ..aOM<$8.Money>(6, _omitFieldNames ? '' : 'discountAmount', subBuilder: $8.Money.create)
    ..aOS(7, _omitFieldNames ? '' : 'discountRuleId')
    ..aOM<$8.Money>(8, _omitFieldNames ? '' : 'preDiscountPrice', subBuilder: $8.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResolvedPrice clone() => ResolvedPrice()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResolvedPrice copyWith(void Function(ResolvedPrice) updates) => super.copyWith((message) => updates(message as ResolvedPrice)) as ResolvedPrice;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolvedPrice create() => ResolvedPrice._();
  ResolvedPrice createEmptyInstance() => create();
  static $pb.PbList<ResolvedPrice> createRepeated() => $pb.PbList<ResolvedPrice>();
  @$core.pragma('dart2js:noInline')
  static ResolvedPrice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResolvedPrice>(create);
  static ResolvedPrice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => clearField(1);

  @$pb.TagNumber(2)
  $8.Money get unitPrice => $_getN(1);
  @$pb.TagNumber(2)
  set unitPrice($8.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnitPrice() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnitPrice() => clearField(2);
  @$pb.TagNumber(2)
  $8.Money ensureUnitPrice() => $_ensure(1);

  @$pb.TagNumber(3)
  PriceSource get priceSource => $_getN(2);
  @$pb.TagNumber(3)
  set priceSource(PriceSource v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPriceSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceSource() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get priceListId => $_getSZ(3);
  @$pb.TagNumber(4)
  set priceListId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPriceListId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPriceListId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get overrideId => $_getSZ(4);
  @$pb.TagNumber(5)
  set overrideId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOverrideId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverrideId() => clearField(5);

  @$pb.TagNumber(6)
  $8.Money get discountAmount => $_getN(5);
  @$pb.TagNumber(6)
  set discountAmount($8.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDiscountAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscountAmount() => clearField(6);
  @$pb.TagNumber(6)
  $8.Money ensureDiscountAmount() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get discountRuleId => $_getSZ(6);
  @$pb.TagNumber(7)
  set discountRuleId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDiscountRuleId() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscountRuleId() => clearField(7);

  @$pb.TagNumber(8)
  $8.Money get preDiscountPrice => $_getN(7);
  @$pb.TagNumber(8)
  set preDiscountPrice($8.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasPreDiscountPrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearPreDiscountPrice() => clearField(8);
  @$pb.TagNumber(8)
  $8.Money ensurePreDiscountPrice() => $_ensure(7);
}

class PriceListSaveRequest extends $pb.GeneratedMessage {
  factory PriceListSaveRequest({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? currency,
    $core.int? priority,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    PriceListStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  PriceListSaveRequest._() : super();
  factory PriceListSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.O3)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..e<PriceListStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PriceListStatus.PRICE_LIST_STATUS_UNSPECIFIED, valueOf: PriceListStatus.valueOf, enumValues: PriceListStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListSaveRequest clone() => PriceListSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListSaveRequest copyWith(void Function(PriceListSaveRequest) updates) => super.copyWith((message) => updates(message as PriceListSaveRequest)) as PriceListSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListSaveRequest create() => PriceListSaveRequest._();
  PriceListSaveRequest createEmptyInstance() => create();
  static $pb.PbList<PriceListSaveRequest> createRepeated() => $pb.PbList<PriceListSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PriceListSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListSaveRequest>(create);
  static PriceListSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get priority => $_getIZ(4);
  @$pb.TagNumber(5)
  set priority($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get validFrom => $_getN(5);
  @$pb.TagNumber(6)
  set validFrom($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasValidFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidFrom() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureValidFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.Timestamp get validUntil => $_getN(6);
  @$pb.TagNumber(7)
  set validUntil($2.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasValidUntil() => $_has(6);
  @$pb.TagNumber(7)
  void clearValidUntil() => clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureValidUntil() => $_ensure(6);

  @$pb.TagNumber(8)
  PriceListStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(PriceListStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);
}

class PriceListSaveResponse extends $pb.GeneratedMessage {
  factory PriceListSaveResponse({
    PriceList? priceList,
  }) {
    final $result = create();
    if (priceList != null) {
      $result.priceList = priceList;
    }
    return $result;
  }
  PriceListSaveResponse._() : super();
  factory PriceListSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<PriceList>(1, _omitFieldNames ? '' : 'priceList', subBuilder: PriceList.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListSaveResponse clone() => PriceListSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListSaveResponse copyWith(void Function(PriceListSaveResponse) updates) => super.copyWith((message) => updates(message as PriceListSaveResponse)) as PriceListSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListSaveResponse create() => PriceListSaveResponse._();
  PriceListSaveResponse createEmptyInstance() => create();
  static $pb.PbList<PriceListSaveResponse> createRepeated() => $pb.PbList<PriceListSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PriceListSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListSaveResponse>(create);
  static PriceListSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceList get priceList => $_getN(0);
  @$pb.TagNumber(1)
  set priceList(PriceList v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPriceList() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceList() => clearField(1);
  @$pb.TagNumber(1)
  PriceList ensurePriceList() => $_ensure(0);
}

class PriceListGetRequest extends $pb.GeneratedMessage {
  factory PriceListGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PriceListGetRequest._() : super();
  factory PriceListGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListGetRequest clone() => PriceListGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListGetRequest copyWith(void Function(PriceListGetRequest) updates) => super.copyWith((message) => updates(message as PriceListGetRequest)) as PriceListGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListGetRequest create() => PriceListGetRequest._();
  PriceListGetRequest createEmptyInstance() => create();
  static $pb.PbList<PriceListGetRequest> createRepeated() => $pb.PbList<PriceListGetRequest>();
  @$core.pragma('dart2js:noInline')
  static PriceListGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListGetRequest>(create);
  static PriceListGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PriceListGetResponse extends $pb.GeneratedMessage {
  factory PriceListGetResponse({
    PriceList? priceList,
  }) {
    final $result = create();
    if (priceList != null) {
      $result.priceList = priceList;
    }
    return $result;
  }
  PriceListGetResponse._() : super();
  factory PriceListGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<PriceList>(1, _omitFieldNames ? '' : 'priceList', subBuilder: PriceList.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListGetResponse clone() => PriceListGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListGetResponse copyWith(void Function(PriceListGetResponse) updates) => super.copyWith((message) => updates(message as PriceListGetResponse)) as PriceListGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListGetResponse create() => PriceListGetResponse._();
  PriceListGetResponse createEmptyInstance() => create();
  static $pb.PbList<PriceListGetResponse> createRepeated() => $pb.PbList<PriceListGetResponse>();
  @$core.pragma('dart2js:noInline')
  static PriceListGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListGetResponse>(create);
  static PriceListGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceList get priceList => $_getN(0);
  @$pb.TagNumber(1)
  set priceList(PriceList v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPriceList() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceList() => clearField(1);
  @$pb.TagNumber(1)
  PriceList ensurePriceList() => $_ensure(0);
}

class PriceListSearchRequest extends $pb.GeneratedMessage {
  factory PriceListSearchRequest({
    $core.String? shopId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  PriceListSearchRequest._() : super();
  factory PriceListSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$7.SearchRequest>(2, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListSearchRequest clone() => PriceListSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListSearchRequest copyWith(void Function(PriceListSearchRequest) updates) => super.copyWith((message) => updates(message as PriceListSearchRequest)) as PriceListSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListSearchRequest create() => PriceListSearchRequest._();
  PriceListSearchRequest createEmptyInstance() => create();
  static $pb.PbList<PriceListSearchRequest> createRepeated() => $pb.PbList<PriceListSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PriceListSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListSearchRequest>(create);
  static PriceListSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  @$pb.TagNumber(2)
  $7.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($7.SearchRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => clearField(2);
  @$pb.TagNumber(2)
  $7.SearchRequest ensureSearch() => $_ensure(1);
}

class PriceListSearchResponse extends $pb.GeneratedMessage {
  factory PriceListSearchResponse({
    $core.Iterable<PriceList>? priceLists,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (priceLists != null) {
      $result.priceLists.addAll(priceLists);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  PriceListSearchResponse._() : super();
  factory PriceListSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<PriceList>(1, _omitFieldNames ? '' : 'priceLists', $pb.PbFieldType.PM, subBuilder: PriceList.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListSearchResponse clone() => PriceListSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListSearchResponse copyWith(void Function(PriceListSearchResponse) updates) => super.copyWith((message) => updates(message as PriceListSearchResponse)) as PriceListSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListSearchResponse create() => PriceListSearchResponse._();
  PriceListSearchResponse createEmptyInstance() => create();
  static $pb.PbList<PriceListSearchResponse> createRepeated() => $pb.PbList<PriceListSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PriceListSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListSearchResponse>(create);
  static PriceListSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PriceList> get priceLists => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class PriceListEntryBatchSaveRequest extends $pb.GeneratedMessage {
  factory PriceListEntryBatchSaveRequest({
    $core.String? priceListId,
    $core.Iterable<PriceListEntry>? entries,
  }) {
    final $result = create();
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    return $result;
  }
  PriceListEntryBatchSaveRequest._() : super();
  factory PriceListEntryBatchSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListEntryBatchSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListEntryBatchSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'priceListId')
    ..pc<PriceListEntry>(2, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: PriceListEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListEntryBatchSaveRequest clone() => PriceListEntryBatchSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListEntryBatchSaveRequest copyWith(void Function(PriceListEntryBatchSaveRequest) updates) => super.copyWith((message) => updates(message as PriceListEntryBatchSaveRequest)) as PriceListEntryBatchSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveRequest create() => PriceListEntryBatchSaveRequest._();
  PriceListEntryBatchSaveRequest createEmptyInstance() => create();
  static $pb.PbList<PriceListEntryBatchSaveRequest> createRepeated() => $pb.PbList<PriceListEntryBatchSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListEntryBatchSaveRequest>(create);
  static PriceListEntryBatchSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priceListId => $_getSZ(0);
  @$pb.TagNumber(1)
  set priceListId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPriceListId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceListId() => clearField(1);

  /// Entries to save. For each product_variant_id present, all existing entries
  /// in this price list for that variant are replaced.
  @$pb.TagNumber(2)
  $core.List<PriceListEntry> get entries => $_getList(1);
}

class PriceListEntryBatchSaveResponse extends $pb.GeneratedMessage {
  factory PriceListEntryBatchSaveResponse({
    $core.Iterable<PriceListEntry>? entries,
  }) {
    final $result = create();
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    return $result;
  }
  PriceListEntryBatchSaveResponse._() : super();
  factory PriceListEntryBatchSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PriceListEntryBatchSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PriceListEntryBatchSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<PriceListEntry>(1, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: PriceListEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PriceListEntryBatchSaveResponse clone() => PriceListEntryBatchSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PriceListEntryBatchSaveResponse copyWith(void Function(PriceListEntryBatchSaveResponse) updates) => super.copyWith((message) => updates(message as PriceListEntryBatchSaveResponse)) as PriceListEntryBatchSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveResponse create() => PriceListEntryBatchSaveResponse._();
  PriceListEntryBatchSaveResponse createEmptyInstance() => create();
  static $pb.PbList<PriceListEntryBatchSaveResponse> createRepeated() => $pb.PbList<PriceListEntryBatchSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListEntryBatchSaveResponse>(create);
  static PriceListEntryBatchSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PriceListEntry> get entries => $_getList(0);
}

class CustomerPriceListAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSaveRequest({
    $core.String? id,
    $core.String? customerId,
    $core.String? priceListId,
    $core.String? assignedBy,
    CustomerPriceListAssignmentStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (assignedBy != null) {
      $result.assignedBy = assignedBy;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  CustomerPriceListAssignmentSaveRequest._() : super();
  factory CustomerPriceListAssignmentSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceListAssignmentSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceListAssignmentSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'priceListId')
    ..aOS(4, _omitFieldNames ? '' : 'assignedBy')
    ..e<CustomerPriceListAssignmentStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CustomerPriceListAssignmentStatus.CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED, valueOf: CustomerPriceListAssignmentStatus.valueOf, enumValues: CustomerPriceListAssignmentStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSaveRequest clone() => CustomerPriceListAssignmentSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSaveRequest copyWith(void Function(CustomerPriceListAssignmentSaveRequest) updates) => super.copyWith((message) => updates(message as CustomerPriceListAssignmentSaveRequest)) as CustomerPriceListAssignmentSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveRequest create() => CustomerPriceListAssignmentSaveRequest._();
  CustomerPriceListAssignmentSaveRequest createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceListAssignmentSaveRequest> createRepeated() => $pb.PbList<CustomerPriceListAssignmentSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignmentSaveRequest>(create);
  static CustomerPriceListAssignmentSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get priceListId => $_getSZ(2);
  @$pb.TagNumber(3)
  set priceListId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPriceListId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceListId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get assignedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAssignedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedBy() => clearField(4);

  @$pb.TagNumber(5)
  CustomerPriceListAssignmentStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(CustomerPriceListAssignmentStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);
}

class CustomerPriceListAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSaveResponse({
    CustomerPriceListAssignment? assignment,
  }) {
    final $result = create();
    if (assignment != null) {
      $result.assignment = assignment;
    }
    return $result;
  }
  CustomerPriceListAssignmentSaveResponse._() : super();
  factory CustomerPriceListAssignmentSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceListAssignmentSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceListAssignmentSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<CustomerPriceListAssignment>(1, _omitFieldNames ? '' : 'assignment', subBuilder: CustomerPriceListAssignment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSaveResponse clone() => CustomerPriceListAssignmentSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSaveResponse copyWith(void Function(CustomerPriceListAssignmentSaveResponse) updates) => super.copyWith((message) => updates(message as CustomerPriceListAssignmentSaveResponse)) as CustomerPriceListAssignmentSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveResponse create() => CustomerPriceListAssignmentSaveResponse._();
  CustomerPriceListAssignmentSaveResponse createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceListAssignmentSaveResponse> createRepeated() => $pb.PbList<CustomerPriceListAssignmentSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignmentSaveResponse>(create);
  static CustomerPriceListAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CustomerPriceListAssignment get assignment => $_getN(0);
  @$pb.TagNumber(1)
  set assignment(CustomerPriceListAssignment v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAssignment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssignment() => clearField(1);
  @$pb.TagNumber(1)
  CustomerPriceListAssignment ensureAssignment() => $_ensure(0);
}

class CustomerPriceListAssignmentSearchRequest extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSearchRequest({
    $core.String? customerId,
    $core.String? priceListId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (priceListId != null) {
      $result.priceListId = priceListId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  CustomerPriceListAssignmentSearchRequest._() : super();
  factory CustomerPriceListAssignmentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceListAssignmentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceListAssignmentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'priceListId')
    ..aOM<$7.SearchRequest>(3, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSearchRequest clone() => CustomerPriceListAssignmentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSearchRequest copyWith(void Function(CustomerPriceListAssignmentSearchRequest) updates) => super.copyWith((message) => updates(message as CustomerPriceListAssignmentSearchRequest)) as CustomerPriceListAssignmentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchRequest create() => CustomerPriceListAssignmentSearchRequest._();
  CustomerPriceListAssignmentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceListAssignmentSearchRequest> createRepeated() => $pb.PbList<CustomerPriceListAssignmentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignmentSearchRequest>(create);
  static CustomerPriceListAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get priceListId => $_getSZ(1);
  @$pb.TagNumber(2)
  set priceListId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPriceListId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPriceListId() => clearField(2);

  @$pb.TagNumber(3)
  $7.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($7.SearchRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => clearField(3);
  @$pb.TagNumber(3)
  $7.SearchRequest ensureSearch() => $_ensure(2);
}

class CustomerPriceListAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSearchResponse({
    $core.Iterable<CustomerPriceListAssignment>? assignments,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (assignments != null) {
      $result.assignments.addAll(assignments);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  CustomerPriceListAssignmentSearchResponse._() : super();
  factory CustomerPriceListAssignmentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceListAssignmentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceListAssignmentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<CustomerPriceListAssignment>(1, _omitFieldNames ? '' : 'assignments', $pb.PbFieldType.PM, subBuilder: CustomerPriceListAssignment.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSearchResponse clone() => CustomerPriceListAssignmentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceListAssignmentSearchResponse copyWith(void Function(CustomerPriceListAssignmentSearchResponse) updates) => super.copyWith((message) => updates(message as CustomerPriceListAssignmentSearchResponse)) as CustomerPriceListAssignmentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchResponse create() => CustomerPriceListAssignmentSearchResponse._();
  CustomerPriceListAssignmentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceListAssignmentSearchResponse> createRepeated() => $pb.PbList<CustomerPriceListAssignmentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignmentSearchResponse>(create);
  static CustomerPriceListAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CustomerPriceListAssignment> get assignments => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class CustomerPriceOverrideSaveRequest extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSaveRequest({
    $core.String? id,
    $core.String? customerId,
    $core.String? productVariantId,
    $8.Money? unitPrice,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    $core.String? approvedBy,
    CustomerPriceOverrideStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (unitPrice != null) {
      $result.unitPrice = unitPrice;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (approvedBy != null) {
      $result.approvedBy = approvedBy;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  CustomerPriceOverrideSaveRequest._() : super();
  factory CustomerPriceOverrideSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceOverrideSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceOverrideSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$8.Money>(4, _omitFieldNames ? '' : 'unitPrice', subBuilder: $8.Money.create)
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..aOS(7, _omitFieldNames ? '' : 'approvedBy')
    ..e<CustomerPriceOverrideStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED, valueOf: CustomerPriceOverrideStatus.valueOf, enumValues: CustomerPriceOverrideStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSaveRequest clone() => CustomerPriceOverrideSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSaveRequest copyWith(void Function(CustomerPriceOverrideSaveRequest) updates) => super.copyWith((message) => updates(message as CustomerPriceOverrideSaveRequest)) as CustomerPriceOverrideSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveRequest create() => CustomerPriceOverrideSaveRequest._();
  CustomerPriceOverrideSaveRequest createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceOverrideSaveRequest> createRepeated() => $pb.PbList<CustomerPriceOverrideSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSaveRequest>(create);
  static CustomerPriceOverrideSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => clearField(3);

  @$pb.TagNumber(4)
  $8.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($8.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => clearField(4);
  @$pb.TagNumber(4)
  $8.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $2.Timestamp get validFrom => $_getN(4);
  @$pb.TagNumber(5)
  set validFrom($2.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasValidFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidFrom() => clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureValidFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get validUntil => $_getN(5);
  @$pb.TagNumber(6)
  set validUntil($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasValidUntil() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidUntil() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureValidUntil() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get approvedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set approvedBy($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasApprovedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearApprovedBy() => clearField(7);

  @$pb.TagNumber(8)
  CustomerPriceOverrideStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(CustomerPriceOverrideStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);
}

class CustomerPriceOverrideSaveResponse extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSaveResponse({
    CustomerPriceOverride? override,
  }) {
    final $result = create();
    if (override != null) {
      $result.override = override;
    }
    return $result;
  }
  CustomerPriceOverrideSaveResponse._() : super();
  factory CustomerPriceOverrideSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceOverrideSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceOverrideSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<CustomerPriceOverride>(1, _omitFieldNames ? '' : 'override', subBuilder: CustomerPriceOverride.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSaveResponse clone() => CustomerPriceOverrideSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSaveResponse copyWith(void Function(CustomerPriceOverrideSaveResponse) updates) => super.copyWith((message) => updates(message as CustomerPriceOverrideSaveResponse)) as CustomerPriceOverrideSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveResponse create() => CustomerPriceOverrideSaveResponse._();
  CustomerPriceOverrideSaveResponse createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceOverrideSaveResponse> createRepeated() => $pb.PbList<CustomerPriceOverrideSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSaveResponse>(create);
  static CustomerPriceOverrideSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CustomerPriceOverride get override => $_getN(0);
  @$pb.TagNumber(1)
  set override(CustomerPriceOverride v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOverride() => $_has(0);
  @$pb.TagNumber(1)
  void clearOverride() => clearField(1);
  @$pb.TagNumber(1)
  CustomerPriceOverride ensureOverride() => $_ensure(0);
}

class CustomerPriceOverrideSearchRequest extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSearchRequest({
    $core.String? customerId,
    $core.String? productVariantId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  CustomerPriceOverrideSearchRequest._() : super();
  factory CustomerPriceOverrideSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceOverrideSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceOverrideSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$7.SearchRequest>(3, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSearchRequest clone() => CustomerPriceOverrideSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSearchRequest copyWith(void Function(CustomerPriceOverrideSearchRequest) updates) => super.copyWith((message) => updates(message as CustomerPriceOverrideSearchRequest)) as CustomerPriceOverrideSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchRequest create() => CustomerPriceOverrideSearchRequest._();
  CustomerPriceOverrideSearchRequest createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceOverrideSearchRequest> createRepeated() => $pb.PbList<CustomerPriceOverrideSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSearchRequest>(create);
  static CustomerPriceOverrideSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => clearField(2);

  @$pb.TagNumber(3)
  $7.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($7.SearchRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => clearField(3);
  @$pb.TagNumber(3)
  $7.SearchRequest ensureSearch() => $_ensure(2);
}

class CustomerPriceOverrideSearchResponse extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSearchResponse({
    $core.Iterable<CustomerPriceOverride>? overrides,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (overrides != null) {
      $result.overrides.addAll(overrides);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  CustomerPriceOverrideSearchResponse._() : super();
  factory CustomerPriceOverrideSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomerPriceOverrideSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomerPriceOverrideSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<CustomerPriceOverride>(1, _omitFieldNames ? '' : 'overrides', $pb.PbFieldType.PM, subBuilder: CustomerPriceOverride.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSearchResponse clone() => CustomerPriceOverrideSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomerPriceOverrideSearchResponse copyWith(void Function(CustomerPriceOverrideSearchResponse) updates) => super.copyWith((message) => updates(message as CustomerPriceOverrideSearchResponse)) as CustomerPriceOverrideSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchResponse create() => CustomerPriceOverrideSearchResponse._();
  CustomerPriceOverrideSearchResponse createEmptyInstance() => create();
  static $pb.PbList<CustomerPriceOverrideSearchResponse> createRepeated() => $pb.PbList<CustomerPriceOverrideSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSearchResponse>(create);
  static CustomerPriceOverrideSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CustomerPriceOverride> get overrides => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class DiscountRuleSaveRequest extends $pb.GeneratedMessage {
  factory DiscountRuleSaveRequest({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    DiscountType? discountType,
    $core.double? value,
    DiscountAppliesTo? appliesTo,
    $6.Struct? conditions,
    $core.bool? requiresApproval,
    $core.double? maxDiscountPercent,
    $2.Timestamp? validFrom,
    $2.Timestamp? validUntil,
    DiscountRuleStatus? status,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (discountType != null) {
      $result.discountType = discountType;
    }
    if (value != null) {
      $result.value = value;
    }
    if (appliesTo != null) {
      $result.appliesTo = appliesTo;
    }
    if (conditions != null) {
      $result.conditions = conditions;
    }
    if (requiresApproval != null) {
      $result.requiresApproval = requiresApproval;
    }
    if (maxDiscountPercent != null) {
      $result.maxDiscountPercent = maxDiscountPercent;
    }
    if (validFrom != null) {
      $result.validFrom = validFrom;
    }
    if (validUntil != null) {
      $result.validUntil = validUntil;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  DiscountRuleSaveRequest._() : super();
  factory DiscountRuleSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscountRuleSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiscountRuleSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<DiscountType>(4, _omitFieldNames ? '' : 'discountType', $pb.PbFieldType.OE, defaultOrMaker: DiscountType.DISCOUNT_TYPE_UNSPECIFIED, valueOf: DiscountType.valueOf, enumValues: DiscountType.values)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..e<DiscountAppliesTo>(6, _omitFieldNames ? '' : 'appliesTo', $pb.PbFieldType.OE, defaultOrMaker: DiscountAppliesTo.DISCOUNT_APPLIES_TO_UNSPECIFIED, valueOf: DiscountAppliesTo.valueOf, enumValues: DiscountAppliesTo.values)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'conditions', subBuilder: $6.Struct.create)
    ..aOB(8, _omitFieldNames ? '' : 'requiresApproval')
    ..a<$core.double>(9, _omitFieldNames ? '' : 'maxDiscountPercent', $pb.PbFieldType.OD)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'validFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'validUntil', subBuilder: $2.Timestamp.create)
    ..e<DiscountRuleStatus>(12, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DiscountRuleStatus.DISCOUNT_RULE_STATUS_UNSPECIFIED, valueOf: DiscountRuleStatus.valueOf, enumValues: DiscountRuleStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiscountRuleSaveRequest clone() => DiscountRuleSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiscountRuleSaveRequest copyWith(void Function(DiscountRuleSaveRequest) updates) => super.copyWith((message) => updates(message as DiscountRuleSaveRequest)) as DiscountRuleSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveRequest create() => DiscountRuleSaveRequest._();
  DiscountRuleSaveRequest createEmptyInstance() => create();
  static $pb.PbList<DiscountRuleSaveRequest> createRepeated() => $pb.PbList<DiscountRuleSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRuleSaveRequest>(create);
  static DiscountRuleSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  DiscountType get discountType => $_getN(3);
  @$pb.TagNumber(4)
  set discountType(DiscountType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDiscountType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscountType() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get value => $_getN(4);
  @$pb.TagNumber(5)
  set value($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => clearField(5);

  @$pb.TagNumber(6)
  DiscountAppliesTo get appliesTo => $_getN(5);
  @$pb.TagNumber(6)
  set appliesTo(DiscountAppliesTo v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAppliesTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppliesTo() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get conditions => $_getN(6);
  @$pb.TagNumber(7)
  set conditions($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasConditions() => $_has(6);
  @$pb.TagNumber(7)
  void clearConditions() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureConditions() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get requiresApproval => $_getBF(7);
  @$pb.TagNumber(8)
  set requiresApproval($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRequiresApproval() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequiresApproval() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxDiscountPercent => $_getN(8);
  @$pb.TagNumber(9)
  set maxDiscountPercent($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMaxDiscountPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxDiscountPercent() => clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get validFrom => $_getN(9);
  @$pb.TagNumber(10)
  set validFrom($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasValidFrom() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidFrom() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureValidFrom() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.Timestamp get validUntil => $_getN(10);
  @$pb.TagNumber(11)
  set validUntil($2.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasValidUntil() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidUntil() => clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureValidUntil() => $_ensure(10);

  @$pb.TagNumber(12)
  DiscountRuleStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(DiscountRuleStatus v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => clearField(12);
}

class DiscountRuleSaveResponse extends $pb.GeneratedMessage {
  factory DiscountRuleSaveResponse({
    DiscountRule? discountRule,
  }) {
    final $result = create();
    if (discountRule != null) {
      $result.discountRule = discountRule;
    }
    return $result;
  }
  DiscountRuleSaveResponse._() : super();
  factory DiscountRuleSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscountRuleSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiscountRuleSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<DiscountRule>(1, _omitFieldNames ? '' : 'discountRule', subBuilder: DiscountRule.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiscountRuleSaveResponse clone() => DiscountRuleSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiscountRuleSaveResponse copyWith(void Function(DiscountRuleSaveResponse) updates) => super.copyWith((message) => updates(message as DiscountRuleSaveResponse)) as DiscountRuleSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveResponse create() => DiscountRuleSaveResponse._();
  DiscountRuleSaveResponse createEmptyInstance() => create();
  static $pb.PbList<DiscountRuleSaveResponse> createRepeated() => $pb.PbList<DiscountRuleSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRuleSaveResponse>(create);
  static DiscountRuleSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiscountRule get discountRule => $_getN(0);
  @$pb.TagNumber(1)
  set discountRule(DiscountRule v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDiscountRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscountRule() => clearField(1);
  @$pb.TagNumber(1)
  DiscountRule ensureDiscountRule() => $_ensure(0);
}

class DiscountRuleSearchRequest extends $pb.GeneratedMessage {
  factory DiscountRuleSearchRequest({
    $core.String? shopId,
    $7.SearchRequest? search,
  }) {
    final $result = create();
    if (shopId != null) {
      $result.shopId = shopId;
    }
    if (search != null) {
      $result.search = search;
    }
    return $result;
  }
  DiscountRuleSearchRequest._() : super();
  factory DiscountRuleSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscountRuleSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiscountRuleSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$7.SearchRequest>(2, _omitFieldNames ? '' : 'search', subBuilder: $7.SearchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiscountRuleSearchRequest clone() => DiscountRuleSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiscountRuleSearchRequest copyWith(void Function(DiscountRuleSearchRequest) updates) => super.copyWith((message) => updates(message as DiscountRuleSearchRequest)) as DiscountRuleSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchRequest create() => DiscountRuleSearchRequest._();
  DiscountRuleSearchRequest createEmptyInstance() => create();
  static $pb.PbList<DiscountRuleSearchRequest> createRepeated() => $pb.PbList<DiscountRuleSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRuleSearchRequest>(create);
  static DiscountRuleSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => clearField(1);

  @$pb.TagNumber(2)
  $7.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($7.SearchRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => clearField(2);
  @$pb.TagNumber(2)
  $7.SearchRequest ensureSearch() => $_ensure(1);
}

class DiscountRuleSearchResponse extends $pb.GeneratedMessage {
  factory DiscountRuleSearchResponse({
    $core.Iterable<DiscountRule>? discountRules,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final $result = create();
    if (discountRules != null) {
      $result.discountRules.addAll(discountRules);
    }
    if (nextPage != null) {
      $result.nextPage = nextPage;
    }
    if (prevCursor != null) {
      $result.prevCursor = prevCursor;
    }
    return $result;
  }
  DiscountRuleSearchResponse._() : super();
  factory DiscountRuleSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscountRuleSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiscountRuleSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..pc<DiscountRule>(1, _omitFieldNames ? '' : 'discountRules', $pb.PbFieldType.PM, subBuilder: DiscountRule.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiscountRuleSearchResponse clone() => DiscountRuleSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiscountRuleSearchResponse copyWith(void Function(DiscountRuleSearchResponse) updates) => super.copyWith((message) => updates(message as DiscountRuleSearchResponse)) as DiscountRuleSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchResponse create() => DiscountRuleSearchResponse._();
  DiscountRuleSearchResponse createEmptyInstance() => create();
  static $pb.PbList<DiscountRuleSearchResponse> createRepeated() => $pb.PbList<DiscountRuleSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRuleSearchResponse>(create);
  static DiscountRuleSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DiscountRule> get discountRules => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => clearField(3);
}

class ResolvePriceRequest extends $pb.GeneratedMessage {
  factory ResolvePriceRequest({
    $core.String? customerId,
    $core.String? productVariantId,
    $core.int? quantity,
  }) {
    final $result = create();
    if (customerId != null) {
      $result.customerId = customerId;
    }
    if (productVariantId != null) {
      $result.productVariantId = productVariantId;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    return $result;
  }
  ResolvePriceRequest._() : super();
  factory ResolvePriceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResolvePriceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResolvePriceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'quantity', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResolvePriceRequest clone() => ResolvePriceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResolvePriceRequest copyWith(void Function(ResolvePriceRequest) updates) => super.copyWith((message) => updates(message as ResolvePriceRequest)) as ResolvePriceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolvePriceRequest create() => ResolvePriceRequest._();
  ResolvePriceRequest createEmptyInstance() => create();
  static $pb.PbList<ResolvePriceRequest> createRepeated() => $pb.PbList<ResolvePriceRequest>();
  @$core.pragma('dart2js:noInline')
  static ResolvePriceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResolvePriceRequest>(create);
  static ResolvePriceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get quantity => $_getIZ(2);
  @$pb.TagNumber(3)
  set quantity($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => clearField(3);
}

class ResolvePriceResponse extends $pb.GeneratedMessage {
  factory ResolvePriceResponse({
    ResolvedPrice? resolvedPrice,
  }) {
    final $result = create();
    if (resolvedPrice != null) {
      $result.resolvedPrice = resolvedPrice;
    }
    return $result;
  }
  ResolvePriceResponse._() : super();
  factory ResolvePriceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResolvePriceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResolvePriceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'), createEmptyInstance: create)
    ..aOM<ResolvedPrice>(1, _omitFieldNames ? '' : 'resolvedPrice', subBuilder: ResolvedPrice.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResolvePriceResponse clone() => ResolvePriceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResolvePriceResponse copyWith(void Function(ResolvePriceResponse) updates) => super.copyWith((message) => updates(message as ResolvePriceResponse)) as ResolvePriceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolvePriceResponse create() => ResolvePriceResponse._();
  ResolvePriceResponse createEmptyInstance() => create();
  static $pb.PbList<ResolvePriceResponse> createRepeated() => $pb.PbList<ResolvePriceResponse>();
  @$core.pragma('dart2js:noInline')
  static ResolvePriceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResolvePriceResponse>(create);
  static ResolvePriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResolvedPrice get resolvedPrice => $_getN(0);
  @$pb.TagNumber(1)
  set resolvedPrice(ResolvedPrice v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResolvedPrice() => $_has(0);
  @$pb.TagNumber(1)
  void clearResolvedPrice() => clearField(1);
  @$pb.TagNumber(1)
  ResolvedPrice ensureResolvedPrice() => $_ensure(0);
}

class CommerceServiceApi {
  $pb.RpcClient _client;
  CommerceServiceApi(this._client);

  $async.Future<CreateShopResponse> createShop($pb.ClientContext? ctx, CreateShopRequest request) =>
    _client.invoke<CreateShopResponse>(ctx, 'CommerceService', 'CreateShop', request, CreateShopResponse())
  ;
  $async.Future<GetShopResponse> getShop($pb.ClientContext? ctx, GetShopRequest request) =>
    _client.invoke<GetShopResponse>(ctx, 'CommerceService', 'GetShop', request, GetShopResponse())
  ;
  $async.Future<UpdateShopResponse> updateShop($pb.ClientContext? ctx, UpdateShopRequest request) =>
    _client.invoke<UpdateShopResponse>(ctx, 'CommerceService', 'UpdateShop', request, UpdateShopResponse())
  ;
  $async.Future<ListShopsResponse> listShops($pb.ClientContext? ctx, ListShopsRequest request) =>
    _client.invoke<ListShopsResponse>(ctx, 'CommerceService', 'ListShops', request, ListShopsResponse())
  ;
  $async.Future<CreateProductResponse> createProduct($pb.ClientContext? ctx, CreateProductRequest request) =>
    _client.invoke<CreateProductResponse>(ctx, 'CommerceService', 'CreateProduct', request, CreateProductResponse())
  ;
  $async.Future<GetProductResponse> getProduct($pb.ClientContext? ctx, GetProductRequest request) =>
    _client.invoke<GetProductResponse>(ctx, 'CommerceService', 'GetProduct', request, GetProductResponse())
  ;
  $async.Future<ListProductsResponse> listProducts($pb.ClientContext? ctx, ListProductsRequest request) =>
    _client.invoke<ListProductsResponse>(ctx, 'CommerceService', 'ListProducts', request, ListProductsResponse())
  ;
  $async.Future<CreateProductVariantResponse> createProductVariant($pb.ClientContext? ctx, CreateProductVariantRequest request) =>
    _client.invoke<CreateProductVariantResponse>(ctx, 'CommerceService', 'CreateProductVariant', request, CreateProductVariantResponse())
  ;
  $async.Future<UpdateProductVariantResponse> updateProductVariant($pb.ClientContext? ctx, UpdateProductVariantRequest request) =>
    _client.invoke<UpdateProductVariantResponse>(ctx, 'CommerceService', 'UpdateProductVariant', request, UpdateProductVariantResponse())
  ;
  $async.Future<ListProductVariantsResponse> listProductVariants($pb.ClientContext? ctx, ListProductVariantsRequest request) =>
    _client.invoke<ListProductVariantsResponse>(ctx, 'CommerceService', 'ListProductVariants', request, ListProductVariantsResponse())
  ;
  $async.Future<CreateCartResponse> createCart($pb.ClientContext? ctx, CreateCartRequest request) =>
    _client.invoke<CreateCartResponse>(ctx, 'CommerceService', 'CreateCart', request, CreateCartResponse())
  ;
  $async.Future<GetCartResponse> getCart($pb.ClientContext? ctx, GetCartRequest request) =>
    _client.invoke<GetCartResponse>(ctx, 'CommerceService', 'GetCart', request, GetCartResponse())
  ;
  $async.Future<AddCartLineResponse> addCartLine($pb.ClientContext? ctx, AddCartLineRequest request) =>
    _client.invoke<AddCartLineResponse>(ctx, 'CommerceService', 'AddCartLine', request, AddCartLineResponse())
  ;
  $async.Future<RemoveCartLineResponse> removeCartLine($pb.ClientContext? ctx, RemoveCartLineRequest request) =>
    _client.invoke<RemoveCartLineResponse>(ctx, 'CommerceService', 'RemoveCartLine', request, RemoveCartLineResponse())
  ;
  $async.Future<CreateOrderFromCartResponse> createOrderFromCart($pb.ClientContext? ctx, CreateOrderFromCartRequest request) =>
    _client.invoke<CreateOrderFromCartResponse>(ctx, 'CommerceService', 'CreateOrderFromCart', request, CreateOrderFromCartResponse())
  ;
  $async.Future<CreateOrderResponse> createOrder($pb.ClientContext? ctx, CreateOrderRequest request) =>
    _client.invoke<CreateOrderResponse>(ctx, 'CommerceService', 'CreateOrder', request, CreateOrderResponse())
  ;
  $async.Future<GetOrderResponse> getOrder($pb.ClientContext? ctx, GetOrderRequest request) =>
    _client.invoke<GetOrderResponse>(ctx, 'CommerceService', 'GetOrder', request, GetOrderResponse())
  ;
  $async.Future<ListOrdersResponse> listOrders($pb.ClientContext? ctx, ListOrdersRequest request) =>
    _client.invoke<ListOrdersResponse>(ctx, 'CommerceService', 'ListOrders', request, ListOrdersResponse())
  ;
  $async.Future<CheckoutOrderResponse> checkoutOrder($pb.ClientContext? ctx, CheckoutOrderRequest request) =>
    _client.invoke<CheckoutOrderResponse>(ctx, 'CommerceService', 'CheckoutOrder', request, CheckoutOrderResponse())
  ;
  $async.Future<ConfirmOrderPaymentResponse> confirmOrderPayment($pb.ClientContext? ctx, ConfirmOrderPaymentRequest request) =>
    _client.invoke<ConfirmOrderPaymentResponse>(ctx, 'CommerceService', 'ConfirmOrderPayment', request, ConfirmOrderPaymentResponse())
  ;
  $async.Future<CancelOrderResponse> cancelOrder($pb.ClientContext? ctx, CancelOrderRequest request) =>
    _client.invoke<CancelOrderResponse>(ctx, 'CommerceService', 'CancelOrder', request, CancelOrderResponse())
  ;
  $async.Future<ReconcilePaymentsResponse> reconcilePayments($pb.ClientContext? ctx, ReconcilePaymentsRequest request) =>
    _client.invoke<ReconcilePaymentsResponse>(ctx, 'CommerceService', 'ReconcilePayments', request, ReconcilePaymentsResponse())
  ;
  $async.Future<RunEndOfDayLedgerResponse> runEndOfDayLedger($pb.ClientContext? ctx, RunEndOfDayLedgerRequest request) =>
    _client.invoke<RunEndOfDayLedgerResponse>(ctx, 'CommerceService', 'RunEndOfDayLedger', request, RunEndOfDayLedgerResponse())
  ;
  $async.Future<CreateFulfilmentResponse> createFulfilment($pb.ClientContext? ctx, CreateFulfilmentRequest request) =>
    _client.invoke<CreateFulfilmentResponse>(ctx, 'CommerceService', 'CreateFulfilment', request, CreateFulfilmentResponse())
  ;
  $async.Future<UpdateFulfilmentResponse> updateFulfilment($pb.ClientContext? ctx, UpdateFulfilmentRequest request) =>
    _client.invoke<UpdateFulfilmentResponse>(ctx, 'CommerceService', 'UpdateFulfilment', request, UpdateFulfilmentResponse())
  ;
  $async.Future<GetFulfilmentResponse> getFulfilment($pb.ClientContext? ctx, GetFulfilmentRequest request) =>
    _client.invoke<GetFulfilmentResponse>(ctx, 'CommerceService', 'GetFulfilment', request, GetFulfilmentResponse())
  ;
  $async.Future<PriceListSaveResponse> priceListSave($pb.ClientContext? ctx, PriceListSaveRequest request) =>
    _client.invoke<PriceListSaveResponse>(ctx, 'CommerceService', 'PriceListSave', request, PriceListSaveResponse())
  ;
  $async.Future<PriceListGetResponse> priceListGet($pb.ClientContext? ctx, PriceListGetRequest request) =>
    _client.invoke<PriceListGetResponse>(ctx, 'CommerceService', 'PriceListGet', request, PriceListGetResponse())
  ;
  $async.Future<PriceListSearchResponse> priceListSearch($pb.ClientContext? ctx, PriceListSearchRequest request) =>
    _client.invoke<PriceListSearchResponse>(ctx, 'CommerceService', 'PriceListSearch', request, PriceListSearchResponse())
  ;
  $async.Future<PriceListEntryBatchSaveResponse> priceListEntryBatchSave($pb.ClientContext? ctx, PriceListEntryBatchSaveRequest request) =>
    _client.invoke<PriceListEntryBatchSaveResponse>(ctx, 'CommerceService', 'PriceListEntryBatchSave', request, PriceListEntryBatchSaveResponse())
  ;
  $async.Future<CustomerPriceListAssignmentSaveResponse> customerPriceListAssignmentSave($pb.ClientContext? ctx, CustomerPriceListAssignmentSaveRequest request) =>
    _client.invoke<CustomerPriceListAssignmentSaveResponse>(ctx, 'CommerceService', 'CustomerPriceListAssignmentSave', request, CustomerPriceListAssignmentSaveResponse())
  ;
  $async.Future<CustomerPriceListAssignmentSearchResponse> customerPriceListAssignmentSearch($pb.ClientContext? ctx, CustomerPriceListAssignmentSearchRequest request) =>
    _client.invoke<CustomerPriceListAssignmentSearchResponse>(ctx, 'CommerceService', 'CustomerPriceListAssignmentSearch', request, CustomerPriceListAssignmentSearchResponse())
  ;
  $async.Future<CustomerPriceOverrideSaveResponse> customerPriceOverrideSave($pb.ClientContext? ctx, CustomerPriceOverrideSaveRequest request) =>
    _client.invoke<CustomerPriceOverrideSaveResponse>(ctx, 'CommerceService', 'CustomerPriceOverrideSave', request, CustomerPriceOverrideSaveResponse())
  ;
  $async.Future<CustomerPriceOverrideSearchResponse> customerPriceOverrideSearch($pb.ClientContext? ctx, CustomerPriceOverrideSearchRequest request) =>
    _client.invoke<CustomerPriceOverrideSearchResponse>(ctx, 'CommerceService', 'CustomerPriceOverrideSearch', request, CustomerPriceOverrideSearchResponse())
  ;
  $async.Future<DiscountRuleSaveResponse> discountRuleSave($pb.ClientContext? ctx, DiscountRuleSaveRequest request) =>
    _client.invoke<DiscountRuleSaveResponse>(ctx, 'CommerceService', 'DiscountRuleSave', request, DiscountRuleSaveResponse())
  ;
  $async.Future<DiscountRuleSearchResponse> discountRuleSearch($pb.ClientContext? ctx, DiscountRuleSearchRequest request) =>
    _client.invoke<DiscountRuleSearchResponse>(ctx, 'CommerceService', 'DiscountRuleSearch', request, DiscountRuleSearchResponse())
  ;
  $async.Future<ResolvePriceResponse> resolvePrice($pb.ClientContext? ctx, ResolvePriceRequest request) =>
    _client.invoke<ResolvePriceResponse>(ctx, 'CommerceService', 'ResolvePrice', request, ResolvePriceResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
