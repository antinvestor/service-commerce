// This is a generated file - do not edit.
//
// Generated from v1/commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $2;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import '../common/v1/common.pb.dart' as $3;
import '../common/v1/money.pb.dart' as $4;
import 'commerce.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    $0.Timestamp? createdAt,
    $1.Struct? extra,
    PaymentPolicy? paymentPolicy,
    $core.String? webhookUrl,
    $core.bool? webhookSecretSet,
    $core.bool? publicStorefront,
    $core.String? storefrontUrl,
  }) {
    final result = Shop._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (currency != null) result.currency = currency;
    if (contactId != null) result.contactId = contactId;
    if (checkoutReturnUrl != null) result.checkoutReturnUrl = checkoutReturnUrl;
    if (createdAt != null) result.createdAt = createdAt;
    if (extra != null) result.extra = extra;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    if (webhookUrl != null) result.webhookUrl = webhookUrl;
    if (webhookSecretSet != null) result.webhookSecretSet = webhookSecretSet;
    if (publicStorefront != null) result.publicStorefront = publicStorefront;
    if (storefrontUrl != null) result.storefrontUrl = storefrontUrl;
    return result;
  }

  Shop._();

  factory Shop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Shop()..mergeFromBuffer(data, registry);
  factory Shop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Shop()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Shop',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: Shop.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'slug')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aE<ShopStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: ShopStatus.values)
    ..pPS(6, _omitFieldNames ? '' : 'mediaIds')
    ..aOS(7, _omitFieldNames ? '' : 'currency')
    ..aOS(8, _omitFieldNames ? '' : 'contactId')
    ..aOS(9, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$1.Struct>(15, _omitFieldNames ? '' : 'extra',
        subBuilder: $1.Struct.$_createMessage)
    ..aOM<PaymentPolicy>(16, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..aOS(17, _omitFieldNames ? '' : 'webhookUrl')
    ..aOB(18, _omitFieldNames ? '' : 'webhookSecretSet')
    ..aOB(19, _omitFieldNames ? '' : 'publicStorefront')
    ..aOS(20, _omitFieldNames ? '' : 'storefrontUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shop copyWith(void Function(Shop) updates) =>
      super.copyWith((message) => updates(message as Shop)) as Shop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Shop() / Shop.new instead')
  static Shop create() => Shop._();
  static $pb.GeneratedMessage $_createMessage() => Shop._();
  @$core.override
  Shop createEmptyInstance() => Shop._();
  @$core.pragma('dart2js:noInline')
  static Shop getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Shop>(Shop.$_createMessage);
  static Shop? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get slug => $_getSZ(2);
  @$pb.TagNumber(3)
  set slug($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlug() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlug() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  ShopStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ShopStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  ///
  /// Media assets associated with the shop (logo, banner, etc.).
  /// References files in the Files Service.
  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get mediaIds => $_getList(5);

  /// ISO 4217 currency every product in the shop is priced in.
  @$pb.TagNumber(7)
  $core.String get currency => $_getSZ(6);
  @$pb.TagNumber(7)
  set currency($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrency() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrency() => $_clearField(7);

  /// Contact that receives seller-side notifications (new orders, payments).
  @$pb.TagNumber(8)
  $core.String get contactId => $_getSZ(7);
  @$pb.TagNumber(8)
  set contactId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasContactId() => $_has(7);
  @$pb.TagNumber(8)
  void clearContactId() => $_clearField(8);

  /// Where the hosted checkout page sends the buyer after paying. Empty uses
  /// the service default.
  @$pb.TagNumber(9)
  $core.String get checkoutReturnUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set checkoutReturnUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCheckoutReturnUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearCheckoutReturnUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(15)
  $1.Struct get extra => $_getN(10);
  @$pb.TagNumber(15)
  set extra($1.Struct value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasExtra() => $_has(10);
  @$pb.TagNumber(15)
  void clearExtra() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.Struct ensureExtra() => $_ensure(10);

  /// How buyers may pay: in full, or in instalments with thresholds. Products
  /// may override it.
  @$pb.TagNumber(16)
  PaymentPolicy get paymentPolicy => $_getN(11);
  @$pb.TagNumber(16)
  set paymentPolicy(PaymentPolicy value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasPaymentPolicy() => $_has(11);
  @$pb.TagNumber(16)
  void clearPaymentPolicy() => $_clearField(16);
  @$pb.TagNumber(16)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(11);

  /// HTTPS endpoint order events are POSTed to, signed with the shop's
  /// webhook secret.
  @$pb.TagNumber(17)
  $core.String get webhookUrl => $_getSZ(12);
  @$pb.TagNumber(17)
  set webhookUrl($core.String value) => $_setString(12, value);
  @$pb.TagNumber(17)
  $core.bool hasWebhookUrl() => $_has(12);
  @$pb.TagNumber(17)
  void clearWebhookUrl() => $_clearField(17);

  /// Whether a webhook secret is set. The secret itself is never returned.
  @$pb.TagNumber(18)
  $core.bool get webhookSecretSet => $_getBF(13);
  @$pb.TagNumber(18)
  set webhookSecretSet($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(18)
  $core.bool hasWebhookSecretSet() => $_has(13);
  @$pb.TagNumber(18)
  void clearWebhookSecretSet() => $_clearField(18);

  /// Whether anyone may browse the shop and buy from its public page without
  /// signing in. Off by default.
  @$pb.TagNumber(19)
  $core.bool get publicStorefront => $_getBF(14);
  @$pb.TagNumber(19)
  set publicStorefront($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(19)
  $core.bool hasPublicStorefront() => $_has(14);
  @$pb.TagNumber(19)
  void clearPublicStorefront() => $_clearField(19);

  /// The public shop page; empty while public_storefront is off.
  @$pb.TagNumber(20)
  $core.String get storefrontUrl => $_getSZ(15);
  @$pb.TagNumber(20)
  set storefrontUrl($core.String value) => $_setString(15, value);
  @$pb.TagNumber(20)
  $core.bool hasStorefrontUrl() => $_has(15);
  @$pb.TagNumber(20)
  void clearStorefrontUrl() => $_clearField(20);
}

/// PaymentPolicy governs paying for an order in instalments and the signals
/// raised as payment progresses. Percentages are whole percent of the order
/// total.
class PaymentPolicy extends $pb.GeneratedMessage {
  factory PaymentPolicy({
    $core.bool? allowInstalments,
    $core.int? minDepositPercent,
    $core.int? minInstalmentPercent,
    $core.int? balanceDueDays,
    $core.int? fulfilAtPercent,
    $core.Iterable<$core.int>? signalThresholds,
    $core.bool? cancelWhenOverdue,
  }) {
    final result = PaymentPolicy._();
    if (allowInstalments != null) result.allowInstalments = allowInstalments;
    if (minDepositPercent != null) result.minDepositPercent = minDepositPercent;
    if (minInstalmentPercent != null)
      result.minInstalmentPercent = minInstalmentPercent;
    if (balanceDueDays != null) result.balanceDueDays = balanceDueDays;
    if (fulfilAtPercent != null) result.fulfilAtPercent = fulfilAtPercent;
    if (signalThresholds != null)
      result.signalThresholds.addAll(signalThresholds);
    if (cancelWhenOverdue != null) result.cancelWhenOverdue = cancelWhenOverdue;
    return result;
  }

  PaymentPolicy._();

  factory PaymentPolicy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentPolicy()..mergeFromBuffer(data, registry);
  factory PaymentPolicy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentPolicy()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PaymentPolicy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PaymentPolicy.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'allowInstalments')
    ..aI(2, _omitFieldNames ? '' : 'minDepositPercent')
    ..aI(3, _omitFieldNames ? '' : 'minInstalmentPercent')
    ..aI(4, _omitFieldNames ? '' : 'balanceDueDays')
    ..aI(5, _omitFieldNames ? '' : 'fulfilAtPercent')
    ..p<$core.int>(
        6, _omitFieldNames ? '' : 'signalThresholds', $pb.PbFieldType.K3)
    ..aOB(7, _omitFieldNames ? '' : 'cancelWhenOverdue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentPolicy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentPolicy copyWith(void Function(PaymentPolicy) updates) =>
      super.copyWith((message) => updates(message as PaymentPolicy))
          as PaymentPolicy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PaymentPolicy() / PaymentPolicy.new instead')
  static PaymentPolicy create() => PaymentPolicy._();
  static $pb.GeneratedMessage $_createMessage() => PaymentPolicy._();
  @$core.override
  PaymentPolicy createEmptyInstance() => PaymentPolicy._();
  @$core.pragma('dart2js:noInline')
  static PaymentPolicy getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentPolicy>(
          PaymentPolicy.$_createMessage);
  static PaymentPolicy? _defaultInstance;

  /// Buyers may pay in more than one instalment.
  @$pb.TagNumber(1)
  $core.bool get allowInstalments => $_getBF(0);
  @$pb.TagNumber(1)
  set allowInstalments($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAllowInstalments() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllowInstalments() => $_clearField(1);

  /// The first instalment must be at least this share of the total. Once it
  /// is paid, stock stays reserved past the payment window. 0 accepts any
  /// amount.
  @$pb.TagNumber(2)
  $core.int get minDepositPercent => $_getIZ(1);
  @$pb.TagNumber(2)
  set minDepositPercent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinDepositPercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinDepositPercent() => $_clearField(2);

  /// Every instalment but the last must be at least this share of the total.
  @$pb.TagNumber(3)
  $core.int get minInstalmentPercent => $_getIZ(2);
  @$pb.TagNumber(3)
  set minInstalmentPercent($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinInstalmentPercent() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinInstalmentPercent() => $_clearField(3);

  /// Days the buyer has to pay the balance after the first instalment. 0
  /// means no deadline.
  @$pb.TagNumber(4)
  $core.int get balanceDueDays => $_getIZ(3);
  @$pb.TagNumber(4)
  set balanceDueDays($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBalanceDueDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearBalanceDueDays() => $_clearField(4);

  /// Share that must be paid before the order may be fulfilled. 0 means the
  /// full amount.
  @$pb.TagNumber(5)
  $core.int get fulfilAtPercent => $_getIZ(4);
  @$pb.TagNumber(5)
  set fulfilAtPercent($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFulfilAtPercent() => $_has(4);
  @$pb.TagNumber(5)
  void clearFulfilAtPercent() => $_clearField(5);

  /// Paid-share marks that raise an ORDER_EVENT_TYPE_THRESHOLD_CROSSED signal
  /// when payment crosses them, e.g. [25, 50, 75].
  @$pb.TagNumber(6)
  $pb.PbList<$core.int> get signalThresholds => $_getList(5);

  /// Cancel the order, release its stock and record a refund of what was paid
  /// when the balance deadline passes.
  @$pb.TagNumber(7)
  $core.bool get cancelWhenOverdue => $_getBF(6);
  @$pb.TagNumber(7)
  set cancelWhenOverdue($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCancelWhenOverdue() => $_has(6);
  @$pb.TagNumber(7)
  void clearCancelWhenOverdue() => $_clearField(7);
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
    PaymentPolicy? paymentPolicy,
    $core.String? webhookUrl,
    $core.String? webhookSecret,
    $core.bool? publicStorefront,
  }) {
    final result = CreateShopRequest._();
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (description != null) result.description = description;
    if (currency != null) result.currency = currency;
    if (contactId != null) result.contactId = contactId;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (checkoutReturnUrl != null) result.checkoutReturnUrl = checkoutReturnUrl;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    if (webhookUrl != null) result.webhookUrl = webhookUrl;
    if (webhookSecret != null) result.webhookSecret = webhookSecret;
    if (publicStorefront != null) result.publicStorefront = publicStorefront;
    return result;
  }

  CreateShopRequest._();

  factory CreateShopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateShopRequest()..mergeFromBuffer(data, registry);
  factory CreateShopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateShopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateShopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateShopRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'slug')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..pPS(6, _omitFieldNames ? '' : 'mediaIds')
    ..aOS(7, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..aOM<PaymentPolicy>(8, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'webhookUrl')
    ..aOS(10, _omitFieldNames ? '' : 'webhookSecret')
    ..aOB(11, _omitFieldNames ? '' : 'publicStorefront')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShopRequest copyWith(void Function(CreateShopRequest) updates) =>
      super.copyWith((message) => updates(message as CreateShopRequest))
          as CreateShopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateShopRequest() / CreateShopRequest.new instead')
  static CreateShopRequest create() => CreateShopRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateShopRequest._();
  @$core.override
  CreateShopRequest createEmptyInstance() => CreateShopRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateShopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateShopRequest>(
          CreateShopRequest.$_createMessage);
  static CreateShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get slug => $_getSZ(1);
  @$pb.TagNumber(2)
  set slug($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlug() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlug() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// ISO 4217 code. Empty uses the caller's default (see ResolveDefaultCurrency).
  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get mediaIds => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get checkoutReturnUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set checkoutReturnUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCheckoutReturnUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearCheckoutReturnUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  PaymentPolicy get paymentPolicy => $_getN(7);
  @$pb.TagNumber(8)
  set paymentPolicy(PaymentPolicy value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPaymentPolicy() => $_has(7);
  @$pb.TagNumber(8)
  void clearPaymentPolicy() => $_clearField(8);
  @$pb.TagNumber(8)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get webhookUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set webhookUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWebhookUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearWebhookUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get webhookSecret => $_getSZ(9);
  @$pb.TagNumber(10)
  set webhookSecret($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWebhookSecret() => $_has(9);
  @$pb.TagNumber(10)
  void clearWebhookSecret() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get publicStorefront => $_getBF(10);
  @$pb.TagNumber(11)
  set publicStorefront($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPublicStorefront() => $_has(10);
  @$pb.TagNumber(11)
  void clearPublicStorefront() => $_clearField(11);
}

class CreateShopResponse extends $pb.GeneratedMessage {
  factory CreateShopResponse({
    Shop? shop,
  }) {
    final result = CreateShopResponse._();
    if (shop != null) result.shop = shop;
    return result;
  }

  CreateShopResponse._();

  factory CreateShopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateShopResponse()..mergeFromBuffer(data, registry);
  factory CreateShopResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateShopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateShopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateShopResponse.$_createMessage)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop',
        subBuilder: Shop.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShopResponse copyWith(void Function(CreateShopResponse) updates) =>
      super.copyWith((message) => updates(message as CreateShopResponse))
          as CreateShopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateShopResponse() / CreateShopResponse.new instead')
  static CreateShopResponse create() => CreateShopResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateShopResponse._();
  @$core.override
  CreateShopResponse createEmptyInstance() => CreateShopResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateShopResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateShopResponse>(
          CreateShopResponse.$_createMessage);
  static CreateShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => $_clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class UpdateShopRequest extends $pb.GeneratedMessage {
  factory UpdateShopRequest({
    $core.String? id,
    $2.FieldMask? updateMask,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.String>? mediaIds,
    ShopStatus? status,
    $1.Struct? extra,
    $core.String? currency,
    $core.String? contactId,
    $core.String? checkoutReturnUrl,
    PaymentPolicy? paymentPolicy,
    $core.String? webhookUrl,
    $core.String? webhookSecret,
    $core.bool? publicStorefront,
  }) {
    final result = UpdateShopRequest._();
    if (id != null) result.id = id;
    if (updateMask != null) result.updateMask = updateMask;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (status != null) result.status = status;
    if (extra != null) result.extra = extra;
    if (currency != null) result.currency = currency;
    if (contactId != null) result.contactId = contactId;
    if (checkoutReturnUrl != null) result.checkoutReturnUrl = checkoutReturnUrl;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    if (webhookUrl != null) result.webhookUrl = webhookUrl;
    if (webhookSecret != null) result.webhookSecret = webhookSecret;
    if (publicStorefront != null) result.publicStorefront = publicStorefront;
    return result;
  }

  UpdateShopRequest._();

  factory UpdateShopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateShopRequest()..mergeFromBuffer(data, registry);
  factory UpdateShopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateShopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateShopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateShopRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$2.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $2.FieldMask.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..pPS(5, _omitFieldNames ? '' : 'mediaIds')
    ..aE<ShopStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: ShopStatus.values)
    ..aOM<$1.Struct>(7, _omitFieldNames ? '' : 'extra',
        subBuilder: $1.Struct.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'currency')
    ..aOS(9, _omitFieldNames ? '' : 'contactId')
    ..aOS(10, _omitFieldNames ? '' : 'checkoutReturnUrl')
    ..aOM<PaymentPolicy>(11, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'webhookUrl')
    ..aOS(13, _omitFieldNames ? '' : 'webhookSecret')
    ..aOB(14, _omitFieldNames ? '' : 'publicStorefront')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateShopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateShopRequest copyWith(void Function(UpdateShopRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateShopRequest))
          as UpdateShopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateShopRequest() / UpdateShopRequest.new instead')
  static UpdateShopRequest create() => UpdateShopRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateShopRequest._();
  @$core.override
  UpdateShopRequest createEmptyInstance() => UpdateShopRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateShopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateShopRequest>(
          UpdateShopRequest.$_createMessage);
  static UpdateShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($2.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get mediaIds => $_getList(4);

  @$pb.TagNumber(6)
  ShopStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(ShopStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Struct get extra => $_getN(6);
  @$pb.TagNumber(7)
  set extra($1.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasExtra() => $_has(6);
  @$pb.TagNumber(7)
  void clearExtra() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Struct ensureExtra() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get currency => $_getSZ(7);
  @$pb.TagNumber(8)
  set currency($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrency() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get contactId => $_getSZ(8);
  @$pb.TagNumber(9)
  set contactId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasContactId() => $_has(8);
  @$pb.TagNumber(9)
  void clearContactId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get checkoutReturnUrl => $_getSZ(9);
  @$pb.TagNumber(10)
  set checkoutReturnUrl($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCheckoutReturnUrl() => $_has(9);
  @$pb.TagNumber(10)
  void clearCheckoutReturnUrl() => $_clearField(10);

  @$pb.TagNumber(11)
  PaymentPolicy get paymentPolicy => $_getN(10);
  @$pb.TagNumber(11)
  set paymentPolicy(PaymentPolicy value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPaymentPolicy() => $_has(10);
  @$pb.TagNumber(11)
  void clearPaymentPolicy() => $_clearField(11);
  @$pb.TagNumber(11)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get webhookUrl => $_getSZ(11);
  @$pb.TagNumber(12)
  set webhookUrl($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasWebhookUrl() => $_has(11);
  @$pb.TagNumber(12)
  void clearWebhookUrl() => $_clearField(12);

  /// Write-only. Empty with "webhook_secret" in the mask clears it.
  @$pb.TagNumber(13)
  $core.String get webhookSecret => $_getSZ(12);
  @$pb.TagNumber(13)
  set webhookSecret($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasWebhookSecret() => $_has(12);
  @$pb.TagNumber(13)
  void clearWebhookSecret() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get publicStorefront => $_getBF(13);
  @$pb.TagNumber(14)
  set publicStorefront($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPublicStorefront() => $_has(13);
  @$pb.TagNumber(14)
  void clearPublicStorefront() => $_clearField(14);
}

class UpdateShopResponse extends $pb.GeneratedMessage {
  factory UpdateShopResponse({
    Shop? shop,
  }) {
    final result = UpdateShopResponse._();
    if (shop != null) result.shop = shop;
    return result;
  }

  UpdateShopResponse._();

  factory UpdateShopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateShopResponse()..mergeFromBuffer(data, registry);
  factory UpdateShopResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateShopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateShopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateShopResponse.$_createMessage)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop',
        subBuilder: Shop.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateShopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateShopResponse copyWith(void Function(UpdateShopResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateShopResponse))
          as UpdateShopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateShopResponse() / UpdateShopResponse.new instead')
  static UpdateShopResponse create() => UpdateShopResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateShopResponse._();
  @$core.override
  UpdateShopResponse createEmptyInstance() => UpdateShopResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateShopResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateShopResponse>(
          UpdateShopResponse.$_createMessage);
  static UpdateShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => $_clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class GetShopRequest extends $pb.GeneratedMessage {
  factory GetShopRequest({
    $core.String? id,
  }) {
    final result = GetShopRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetShopRequest._();

  factory GetShopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetShopRequest()..mergeFromBuffer(data, registry);
  factory GetShopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetShopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetShopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetShopRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShopRequest copyWith(void Function(GetShopRequest) updates) =>
      super.copyWith((message) => updates(message as GetShopRequest))
          as GetShopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetShopRequest() / GetShopRequest.new instead')
  static GetShopRequest create() => GetShopRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetShopRequest._();
  @$core.override
  GetShopRequest createEmptyInstance() => GetShopRequest._();
  @$core.pragma('dart2js:noInline')
  static GetShopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShopRequest>(
          GetShopRequest.$_createMessage);
  static GetShopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ListShopsRequest extends $pb.GeneratedMessage {
  factory ListShopsRequest({
    $3.SearchRequest? search,
  }) {
    final result = ListShopsRequest._();
    if (search != null) result.search = search;
    return result;
  }

  ListShopsRequest._();

  factory ListShopsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListShopsRequest()..mergeFromBuffer(data, registry);
  factory ListShopsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListShopsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListShopsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListShopsRequest.$_createMessage)
    ..aOM<$3.SearchRequest>(1, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopsRequest copyWith(void Function(ListShopsRequest) updates) =>
      super.copyWith((message) => updates(message as ListShopsRequest))
          as ListShopsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListShopsRequest() / ListShopsRequest.new instead')
  static ListShopsRequest create() => ListShopsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListShopsRequest._();
  @$core.override
  ListShopsRequest createEmptyInstance() => ListShopsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListShopsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListShopsRequest>(
          ListShopsRequest.$_createMessage);
  static ListShopsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $3.SearchRequest get search => $_getN(0);
  @$pb.TagNumber(1)
  set search($3.SearchRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSearch() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearch() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.SearchRequest ensureSearch() => $_ensure(0);
}

class ListShopsResponse extends $pb.GeneratedMessage {
  factory ListShopsResponse({
    $core.Iterable<Shop>? shops,
    $core.String? nextPage,
  }) {
    final result = ListShopsResponse._();
    if (shops != null) result.shops.addAll(shops);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  ListShopsResponse._();

  factory ListShopsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListShopsResponse()..mergeFromBuffer(data, registry);
  factory ListShopsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListShopsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListShopsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListShopsResponse.$_createMessage)
    ..pPM<Shop>(1, _omitFieldNames ? '' : 'shops',
        subBuilder: Shop.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopsResponse copyWith(void Function(ListShopsResponse) updates) =>
      super.copyWith((message) => updates(message as ListShopsResponse))
          as ListShopsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListShopsResponse() / ListShopsResponse.new instead')
  static ListShopsResponse create() => ListShopsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListShopsResponse._();
  @$core.override
  ListShopsResponse createEmptyInstance() => ListShopsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListShopsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListShopsResponse>(
          ListShopsResponse.$_createMessage);
  static ListShopsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Shop> get shops => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class GetShopResponse extends $pb.GeneratedMessage {
  factory GetShopResponse({
    Shop? shop,
  }) {
    final result = GetShopResponse._();
    if (shop != null) result.shop = shop;
    return result;
  }

  GetShopResponse._();

  factory GetShopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetShopResponse()..mergeFromBuffer(data, registry);
  factory GetShopResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetShopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetShopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetShopResponse.$_createMessage)
    ..aOM<Shop>(1, _omitFieldNames ? '' : 'shop',
        subBuilder: Shop.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShopResponse copyWith(void Function(GetShopResponse) updates) =>
      super.copyWith((message) => updates(message as GetShopResponse))
          as GetShopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetShopResponse() / GetShopResponse.new instead')
  static GetShopResponse create() => GetShopResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetShopResponse._();
  @$core.override
  GetShopResponse createEmptyInstance() => GetShopResponse._();
  @$core.pragma('dart2js:noInline')
  static GetShopResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShopResponse>(
          GetShopResponse.$_createMessage);
  static GetShopResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Shop get shop => $_getN(0);
  @$pb.TagNumber(1)
  set shop(Shop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasShop() => $_has(0);
  @$pb.TagNumber(1)
  void clearShop() => $_clearField(1);
  @$pb.TagNumber(1)
  Shop ensureShop() => $_ensure(0);
}

class ResolveDefaultCurrencyRequest extends $pb.GeneratedMessage {
  factory ResolveDefaultCurrencyRequest() => ResolveDefaultCurrencyRequest._();

  ResolveDefaultCurrencyRequest._();

  factory ResolveDefaultCurrencyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveDefaultCurrencyRequest()..mergeFromBuffer(data, registry);
  factory ResolveDefaultCurrencyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveDefaultCurrencyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveDefaultCurrencyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolveDefaultCurrencyRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveDefaultCurrencyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveDefaultCurrencyRequest copyWith(
          void Function(ResolveDefaultCurrencyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveDefaultCurrencyRequest))
          as ResolveDefaultCurrencyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ResolveDefaultCurrencyRequest() / ResolveDefaultCurrencyRequest.new instead')
  static ResolveDefaultCurrencyRequest create() =>
      ResolveDefaultCurrencyRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ResolveDefaultCurrencyRequest._();
  @$core.override
  ResolveDefaultCurrencyRequest createEmptyInstance() =>
      ResolveDefaultCurrencyRequest._();
  @$core.pragma('dart2js:noInline')
  static ResolveDefaultCurrencyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveDefaultCurrencyRequest>(
          ResolveDefaultCurrencyRequest.$_createMessage);
  static ResolveDefaultCurrencyRequest? _defaultInstance;
}

class ResolveDefaultCurrencyResponse extends $pb.GeneratedMessage {
  factory ResolveDefaultCurrencyResponse({
    $core.String? currency,
    CurrencySource? source,
  }) {
    final result = ResolveDefaultCurrencyResponse._();
    if (currency != null) result.currency = currency;
    if (source != null) result.source = source;
    return result;
  }

  ResolveDefaultCurrencyResponse._();

  factory ResolveDefaultCurrencyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveDefaultCurrencyResponse()..mergeFromBuffer(data, registry);
  factory ResolveDefaultCurrencyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveDefaultCurrencyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveDefaultCurrencyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolveDefaultCurrencyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'currency')
    ..aE<CurrencySource>(2, _omitFieldNames ? '' : 'source',
        enumValues: CurrencySource.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveDefaultCurrencyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveDefaultCurrencyResponse copyWith(
          void Function(ResolveDefaultCurrencyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveDefaultCurrencyResponse))
          as ResolveDefaultCurrencyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ResolveDefaultCurrencyResponse() / ResolveDefaultCurrencyResponse.new instead')
  static ResolveDefaultCurrencyResponse create() =>
      ResolveDefaultCurrencyResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ResolveDefaultCurrencyResponse._();
  @$core.override
  ResolveDefaultCurrencyResponse createEmptyInstance() =>
      ResolveDefaultCurrencyResponse._();
  @$core.pragma('dart2js:noInline')
  static ResolveDefaultCurrencyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveDefaultCurrencyResponse>(
          ResolveDefaultCurrencyResponse.$_createMessage);
  static ResolveDefaultCurrencyResponse? _defaultInstance;

  /// ISO 4217 code.
  @$pb.TagNumber(1)
  $core.String get currency => $_getSZ(0);
  @$pb.TagNumber(1)
  set currency($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrency() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrency() => $_clearField(1);

  @$pb.TagNumber(2)
  CurrencySource get source => $_getN(1);
  @$pb.TagNumber(2)
  set source(CurrencySource value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearSource() => $_clearField(2);
}

class Product extends $pb.GeneratedMessage {
  factory Product({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    FulfilmentType? fulfilmentType,
    ProductStatus? status,
    $core.Iterable<$core.String>? mediaIds,
    $0.Timestamp? createdAt,
    PaymentPolicy? paymentPolicy,
  }) {
    final result = Product._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (attributes != null) result.attributes.addEntries(attributes);
    if (fulfilmentType != null) result.fulfilmentType = fulfilmentType;
    if (status != null) result.status = status;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (createdAt != null) result.createdAt = createdAt;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    return result;
  }

  Product._();

  factory Product.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Product()..mergeFromBuffer(data, registry);
  factory Product.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Product()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Product',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: Product.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'Product.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aE<FulfilmentType>(10, _omitFieldNames ? '' : 'fulfilmentType',
        enumValues: FulfilmentType.values)
    ..aE<ProductStatus>(15, _omitFieldNames ? '' : 'status',
        enumValues: ProductStatus.values)
    ..pPS(16, _omitFieldNames ? '' : 'mediaIds')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<PaymentPolicy>(18, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product copyWith(void Function(Product) updates) =>
      super.copyWith((message) => updates(message as Product)) as Product;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Product() / Product.new instead')
  static Product create() => Product._();
  static $pb.GeneratedMessage $_createMessage() => Product._();
  @$core.override
  Product createEmptyInstance() => Product._();
  @$core.pragma('dart2js:noInline')
  static Product getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Product>(Product.$_createMessage);
  static Product? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(10)
  FulfilmentType get fulfilmentType => $_getN(5);
  @$pb.TagNumber(10)
  set fulfilmentType(FulfilmentType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasFulfilmentType() => $_has(5);
  @$pb.TagNumber(10)
  void clearFulfilmentType() => $_clearField(10);

  @$pb.TagNumber(15)
  ProductStatus get status => $_getN(6);
  @$pb.TagNumber(15)
  set status(ProductStatus value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(15)
  void clearStatus() => $_clearField(15);

  ///
  /// Media assets (images, videos) for the product.
  /// References files in the Files Service.
  @$pb.TagNumber(16)
  $pb.PbList<$core.String> get mediaIds => $_getList(7);

  @$pb.TagNumber(17)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(17)
  set createdAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(17)
  void clearCreatedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);

  /// Overrides the shop's payment policy for orders containing this product.
  /// Unset uses the shop's.
  @$pb.TagNumber(18)
  PaymentPolicy get paymentPolicy => $_getN(9);
  @$pb.TagNumber(18)
  set paymentPolicy(PaymentPolicy value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasPaymentPolicy() => $_has(9);
  @$pb.TagNumber(18)
  void clearPaymentPolicy() => $_clearField(18);
  @$pb.TagNumber(18)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(9);
}

class ProductVariant extends $pb.GeneratedMessage {
  factory ProductVariant({
    $core.String? id,
    $core.String? productId,
    $core.String? sku,
    $core.String? name,
    $4.Money? price,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    $fixnum.Int64? stockQuantity,
    ProductVariantStatus? status,
    $0.Timestamp? createdAt,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final result = ProductVariant._();
    if (id != null) result.id = id;
    if (productId != null) result.productId = productId;
    if (sku != null) result.sku = sku;
    if (name != null) result.name = name;
    if (price != null) result.price = price;
    if (attributes != null) result.attributes.addEntries(attributes);
    if (stockQuantity != null) result.stockQuantity = stockQuantity;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    return result;
  }

  ProductVariant._();

  factory ProductVariant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductVariant()..mergeFromBuffer(data, registry);
  factory ProductVariant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductVariant()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductVariant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ProductVariant.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'sku')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOM<$4.Money>(5, _omitFieldNames ? '' : 'price',
        subBuilder: $4.Money.$_createMessage)
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'ProductVariant.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(7, _omitFieldNames ? '' : 'stockQuantity')
    ..aE<ProductVariantStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: ProductVariantStatus.values)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPS(10, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductVariant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductVariant copyWith(void Function(ProductVariant) updates) =>
      super.copyWith((message) => updates(message as ProductVariant))
          as ProductVariant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProductVariant() / ProductVariant.new instead')
  static ProductVariant create() => ProductVariant._();
  static $pb.GeneratedMessage $_createMessage() => ProductVariant._();
  @$core.override
  ProductVariant createEmptyInstance() => ProductVariant._();
  @$core.pragma('dart2js:noInline')
  static ProductVariant getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProductVariant>(
          ProductVariant.$_createMessage);
  static ProductVariant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sku => $_getSZ(2);
  @$pb.TagNumber(3)
  set sku($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSku() => $_has(2);
  @$pb.TagNumber(3)
  void clearSku() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  ///
  /// Price in minor units (for example cents).
  @$pb.TagNumber(5)
  $4.Money get price => $_getN(4);
  @$pb.TagNumber(5)
  set price($4.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrice() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Money ensurePrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get stockQuantity => $_getI64(6);
  @$pb.TagNumber(7)
  set stockQuantity($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStockQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearStockQuantity() => $_clearField(7);

  @$pb.TagNumber(8)
  ProductVariantStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(ProductVariantStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get mediaIds => $_getList(9);
}

class CreateProductRequest extends $pb.GeneratedMessage {
  factory CreateProductRequest({
    $core.String? shopId,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.String>? mediaIds,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    FulfilmentType? fulfilmentType,
    PaymentPolicy? paymentPolicy,
  }) {
    final result = CreateProductRequest._();
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (attributes != null) result.attributes.addEntries(attributes);
    if (fulfilmentType != null) result.fulfilmentType = fulfilmentType;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    return result;
  }

  CreateProductRequest._();

  factory CreateProductRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductRequest()..mergeFromBuffer(data, registry);
  factory CreateProductRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProductRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateProductRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..pPS(4, _omitFieldNames ? '' : 'mediaIds')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'CreateProductRequest.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aE<FulfilmentType>(6, _omitFieldNames ? '' : 'fulfilmentType',
        enumValues: FulfilmentType.values)
    ..aOM<PaymentPolicy>(7, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductRequest copyWith(void Function(CreateProductRequest) updates) =>
      super.copyWith((message) => updates(message as CreateProductRequest))
          as CreateProductRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateProductRequest() / CreateProductRequest.new instead')
  static CreateProductRequest create() => CreateProductRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateProductRequest._();
  @$core.override
  CreateProductRequest createEmptyInstance() => CreateProductRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateProductRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProductRequest>(
          CreateProductRequest.$_createMessage);
  static CreateProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get mediaIds => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(6)
  FulfilmentType get fulfilmentType => $_getN(5);
  @$pb.TagNumber(6)
  set fulfilmentType(FulfilmentType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFulfilmentType() => $_has(5);
  @$pb.TagNumber(6)
  void clearFulfilmentType() => $_clearField(6);

  @$pb.TagNumber(7)
  PaymentPolicy get paymentPolicy => $_getN(6);
  @$pb.TagNumber(7)
  set paymentPolicy(PaymentPolicy value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPaymentPolicy() => $_has(6);
  @$pb.TagNumber(7)
  void clearPaymentPolicy() => $_clearField(7);
  @$pb.TagNumber(7)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(6);
}

class CreateProductResponse extends $pb.GeneratedMessage {
  factory CreateProductResponse({
    Product? product,
  }) {
    final result = CreateProductResponse._();
    if (product != null) result.product = product;
    return result;
  }

  CreateProductResponse._();

  factory CreateProductResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductResponse()..mergeFromBuffer(data, registry);
  factory CreateProductResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProductResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateProductResponse.$_createMessage)
    ..aOM<Product>(1, _omitFieldNames ? '' : 'product',
        subBuilder: Product.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductResponse copyWith(
          void Function(CreateProductResponse) updates) =>
      super.copyWith((message) => updates(message as CreateProductResponse))
          as CreateProductResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateProductResponse() / CreateProductResponse.new instead')
  static CreateProductResponse create() => CreateProductResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateProductResponse._();
  @$core.override
  CreateProductResponse createEmptyInstance() => CreateProductResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateProductResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProductResponse>(
          CreateProductResponse.$_createMessage);
  static CreateProductResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(Product value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => $_clearField(1);
  @$pb.TagNumber(1)
  Product ensureProduct() => $_ensure(0);
}

class GetProductRequest extends $pb.GeneratedMessage {
  factory GetProductRequest({
    $core.String? id,
  }) {
    final result = GetProductRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetProductRequest._();

  factory GetProductRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProductRequest()..mergeFromBuffer(data, registry);
  factory GetProductRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProductRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProductRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetProductRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProductRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProductRequest copyWith(void Function(GetProductRequest) updates) =>
      super.copyWith((message) => updates(message as GetProductRequest))
          as GetProductRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetProductRequest() / GetProductRequest.new instead')
  static GetProductRequest create() => GetProductRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetProductRequest._();
  @$core.override
  GetProductRequest createEmptyInstance() => GetProductRequest._();
  @$core.pragma('dart2js:noInline')
  static GetProductRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProductRequest>(
          GetProductRequest.$_createMessage);
  static GetProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetProductResponse extends $pb.GeneratedMessage {
  factory GetProductResponse({
    Product? product,
  }) {
    final result = GetProductResponse._();
    if (product != null) result.product = product;
    return result;
  }

  GetProductResponse._();

  factory GetProductResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProductResponse()..mergeFromBuffer(data, registry);
  factory GetProductResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProductResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProductResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetProductResponse.$_createMessage)
    ..aOM<Product>(1, _omitFieldNames ? '' : 'product',
        subBuilder: Product.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProductResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProductResponse copyWith(void Function(GetProductResponse) updates) =>
      super.copyWith((message) => updates(message as GetProductResponse))
          as GetProductResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetProductResponse() / GetProductResponse.new instead')
  static GetProductResponse create() => GetProductResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetProductResponse._();
  @$core.override
  GetProductResponse createEmptyInstance() => GetProductResponse._();
  @$core.pragma('dart2js:noInline')
  static GetProductResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProductResponse>(
          GetProductResponse.$_createMessage);
  static GetProductResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(Product value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => $_clearField(1);
  @$pb.TagNumber(1)
  Product ensureProduct() => $_ensure(0);
}

class ListProductsRequest extends $pb.GeneratedMessage {
  factory ListProductsRequest({
    $core.String? shopId,
    $3.SearchRequest? search,
  }) {
    final result = ListProductsRequest._();
    if (shopId != null) result.shopId = shopId;
    if (search != null) result.search = search;
    return result;
  }

  ListProductsRequest._();

  factory ListProductsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductsRequest()..mergeFromBuffer(data, registry);
  factory ListProductsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProductsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListProductsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$3.SearchRequest>(2, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductsRequest copyWith(void Function(ListProductsRequest) updates) =>
      super.copyWith((message) => updates(message as ListProductsRequest))
          as ListProductsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ListProductsRequest() / ListProductsRequest.new instead')
  static ListProductsRequest create() => ListProductsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListProductsRequest._();
  @$core.override
  ListProductsRequest createEmptyInstance() => ListProductsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListProductsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProductsRequest>(
          ListProductsRequest.$_createMessage);
  static ListProductsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  /// Optional search parameters (query, cursor, etc.)
  @$pb.TagNumber(2)
  $3.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($3.SearchRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.SearchRequest ensureSearch() => $_ensure(1);
}

class ListProductsResponse extends $pb.GeneratedMessage {
  factory ListProductsResponse({
    $core.Iterable<Product>? products,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = ListProductsResponse._();
    if (products != null) result.products.addAll(products);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  ListProductsResponse._();

  factory ListProductsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductsResponse()..mergeFromBuffer(data, registry);
  factory ListProductsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProductsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListProductsResponse.$_createMessage)
    ..pPM<Product>(1, _omitFieldNames ? '' : 'products',
        subBuilder: Product.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductsResponse copyWith(void Function(ListProductsResponse) updates) =>
      super.copyWith((message) => updates(message as ListProductsResponse))
          as ListProductsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListProductsResponse() / ListProductsResponse.new instead')
  static ListProductsResponse create() => ListProductsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListProductsResponse._();
  @$core.override
  ListProductsResponse createEmptyInstance() => ListProductsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListProductsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProductsResponse>(
          ListProductsResponse.$_createMessage);
  static ListProductsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Product> get products => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class CreateProductVariantRequest extends $pb.GeneratedMessage {
  factory CreateProductVariantRequest({
    $core.String? productId,
    $core.String? sku,
    $core.String? name,
    $4.Money? price,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    $fixnum.Int64? stockQuantity,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final result = CreateProductVariantRequest._();
    if (productId != null) result.productId = productId;
    if (sku != null) result.sku = sku;
    if (name != null) result.name = name;
    if (price != null) result.price = price;
    if (attributes != null) result.attributes.addEntries(attributes);
    if (stockQuantity != null) result.stockQuantity = stockQuantity;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    return result;
  }

  CreateProductVariantRequest._();

  factory CreateProductVariantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductVariantRequest()..mergeFromBuffer(data, registry);
  factory CreateProductVariantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductVariantRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProductVariantRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateProductVariantRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'productId')
    ..aOS(2, _omitFieldNames ? '' : 'sku')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'price',
        subBuilder: $4.Money.$_createMessage)
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'CreateProductVariantRequest.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(6, _omitFieldNames ? '' : 'stockQuantity')
    ..pPS(7, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductVariantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductVariantRequest copyWith(
          void Function(CreateProductVariantRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateProductVariantRequest))
          as CreateProductVariantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateProductVariantRequest() / CreateProductVariantRequest.new instead')
  static CreateProductVariantRequest create() =>
      CreateProductVariantRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateProductVariantRequest._();
  @$core.override
  CreateProductVariantRequest createEmptyInstance() =>
      CreateProductVariantRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateProductVariantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProductVariantRequest>(
          CreateProductVariantRequest.$_createMessage);
  static CreateProductVariantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get productId => $_getSZ(0);
  @$pb.TagNumber(1)
  set productId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProductId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sku => $_getSZ(1);
  @$pb.TagNumber(2)
  set sku($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSku() => $_has(1);
  @$pb.TagNumber(2)
  void clearSku() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Money get price => $_getN(3);
  @$pb.TagNumber(4)
  set price($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrice() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensurePrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get stockQuantity => $_getI64(5);
  @$pb.TagNumber(6)
  set stockQuantity($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStockQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearStockQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get mediaIds => $_getList(6);
}

class CreateProductVariantResponse extends $pb.GeneratedMessage {
  factory CreateProductVariantResponse({
    ProductVariant? productVariant,
  }) {
    final result = CreateProductVariantResponse._();
    if (productVariant != null) result.productVariant = productVariant;
    return result;
  }

  CreateProductVariantResponse._();

  factory CreateProductVariantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductVariantResponse()..mergeFromBuffer(data, registry);
  factory CreateProductVariantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateProductVariantResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProductVariantResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateProductVariantResponse.$_createMessage)
    ..aOM<ProductVariant>(1, _omitFieldNames ? '' : 'productVariant',
        subBuilder: ProductVariant.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductVariantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProductVariantResponse copyWith(
          void Function(CreateProductVariantResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateProductVariantResponse))
          as CreateProductVariantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateProductVariantResponse() / CreateProductVariantResponse.new instead')
  static CreateProductVariantResponse create() =>
      CreateProductVariantResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateProductVariantResponse._();
  @$core.override
  CreateProductVariantResponse createEmptyInstance() =>
      CreateProductVariantResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateProductVariantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProductVariantResponse>(
          CreateProductVariantResponse.$_createMessage);
  static CreateProductVariantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProductVariant get productVariant => $_getN(0);
  @$pb.TagNumber(1)
  set productVariant(ProductVariant value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProductVariant() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductVariant() => $_clearField(1);
  @$pb.TagNumber(1)
  ProductVariant ensureProductVariant() => $_ensure(0);
}

class UpdateProductVariantRequest extends $pb.GeneratedMessage {
  factory UpdateProductVariantRequest({
    $core.String? variantId,
    $2.FieldMask? updateMask,
    $core.String? sku,
    $core.String? name,
    $4.Money? price,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    $fixnum.Int64? stockQuantity,
    ProductVariantStatus? status,
    $core.Iterable<$core.String>? mediaIds,
  }) {
    final result = UpdateProductVariantRequest._();
    if (variantId != null) result.variantId = variantId;
    if (updateMask != null) result.updateMask = updateMask;
    if (sku != null) result.sku = sku;
    if (name != null) result.name = name;
    if (price != null) result.price = price;
    if (attributes != null) result.attributes.addEntries(attributes);
    if (stockQuantity != null) result.stockQuantity = stockQuantity;
    if (status != null) result.status = status;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    return result;
  }

  UpdateProductVariantRequest._();

  factory UpdateProductVariantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductVariantRequest()..mergeFromBuffer(data, registry);
  factory UpdateProductVariantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductVariantRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProductVariantRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateProductVariantRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aOM<$2.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $2.FieldMask.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'sku')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOM<$4.Money>(5, _omitFieldNames ? '' : 'price',
        subBuilder: $4.Money.$_createMessage)
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'UpdateProductVariantRequest.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aInt64(7, _omitFieldNames ? '' : 'stockQuantity')
    ..aE<ProductVariantStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: ProductVariantStatus.values)
    ..pPS(9, _omitFieldNames ? '' : 'mediaIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductVariantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductVariantRequest copyWith(
          void Function(UpdateProductVariantRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateProductVariantRequest))
          as UpdateProductVariantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateProductVariantRequest() / UpdateProductVariantRequest.new instead')
  static UpdateProductVariantRequest create() =>
      UpdateProductVariantRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      UpdateProductVariantRequest._();
  @$core.override
  UpdateProductVariantRequest createEmptyInstance() =>
      UpdateProductVariantRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProductVariantRequest>(
          UpdateProductVariantRequest.$_createMessage);
  static UpdateProductVariantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($2.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get sku => $_getSZ(2);
  @$pb.TagNumber(3)
  set sku($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSku() => $_has(2);
  @$pb.TagNumber(3)
  void clearSku() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $4.Money get price => $_getN(4);
  @$pb.TagNumber(5)
  set price($4.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrice() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Money ensurePrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get stockQuantity => $_getI64(6);
  @$pb.TagNumber(7)
  set stockQuantity($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStockQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearStockQuantity() => $_clearField(7);

  @$pb.TagNumber(8)
  ProductVariantStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(ProductVariantStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get mediaIds => $_getList(8);
}

class UpdateProductRequest extends $pb.GeneratedMessage {
  factory UpdateProductRequest({
    $core.String? id,
    $2.FieldMask? updateMask,
    $core.String? name,
    $core.String? description,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
    FulfilmentType? fulfilmentType,
    ProductStatus? status,
    $core.Iterable<$core.String>? mediaIds,
    PaymentPolicy? paymentPolicy,
  }) {
    final result = UpdateProductRequest._();
    if (id != null) result.id = id;
    if (updateMask != null) result.updateMask = updateMask;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (attributes != null) result.attributes.addEntries(attributes);
    if (fulfilmentType != null) result.fulfilmentType = fulfilmentType;
    if (status != null) result.status = status;
    if (mediaIds != null) result.mediaIds.addAll(mediaIds);
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    return result;
  }

  UpdateProductRequest._();

  factory UpdateProductRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductRequest()..mergeFromBuffer(data, registry);
  factory UpdateProductRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProductRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateProductRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$2.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $2.FieldMask.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'UpdateProductRequest.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('commerce.v1'))
    ..aE<FulfilmentType>(6, _omitFieldNames ? '' : 'fulfilmentType',
        enumValues: FulfilmentType.values)
    ..aE<ProductStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: ProductStatus.values)
    ..pPS(8, _omitFieldNames ? '' : 'mediaIds')
    ..aOM<PaymentPolicy>(9, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductRequest copyWith(void Function(UpdateProductRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateProductRequest))
          as UpdateProductRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateProductRequest() / UpdateProductRequest.new instead')
  static UpdateProductRequest create() => UpdateProductRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateProductRequest._();
  @$core.override
  UpdateProductRequest createEmptyInstance() => UpdateProductRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateProductRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProductRequest>(
          UpdateProductRequest.$_createMessage);
  static UpdateProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Fields to apply. Without a mask only fields carrying a value are applied.
  @$pb.TagNumber(2)
  $2.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($2.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(4);

  @$pb.TagNumber(6)
  FulfilmentType get fulfilmentType => $_getN(5);
  @$pb.TagNumber(6)
  set fulfilmentType(FulfilmentType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFulfilmentType() => $_has(5);
  @$pb.TagNumber(6)
  void clearFulfilmentType() => $_clearField(6);

  @$pb.TagNumber(7)
  ProductStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(ProductStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get mediaIds => $_getList(7);

  /// With "payment_policy" in the mask and this unset, the override is
  /// removed and the shop's policy applies again.
  @$pb.TagNumber(9)
  PaymentPolicy get paymentPolicy => $_getN(8);
  @$pb.TagNumber(9)
  set paymentPolicy(PaymentPolicy value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPaymentPolicy() => $_has(8);
  @$pb.TagNumber(9)
  void clearPaymentPolicy() => $_clearField(9);
  @$pb.TagNumber(9)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(8);
}

class UpdateProductResponse extends $pb.GeneratedMessage {
  factory UpdateProductResponse({
    Product? product,
  }) {
    final result = UpdateProductResponse._();
    if (product != null) result.product = product;
    return result;
  }

  UpdateProductResponse._();

  factory UpdateProductResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductResponse()..mergeFromBuffer(data, registry);
  factory UpdateProductResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProductResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateProductResponse.$_createMessage)
    ..aOM<Product>(1, _omitFieldNames ? '' : 'product',
        subBuilder: Product.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductResponse copyWith(
          void Function(UpdateProductResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateProductResponse))
          as UpdateProductResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateProductResponse() / UpdateProductResponse.new instead')
  static UpdateProductResponse create() => UpdateProductResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateProductResponse._();
  @$core.override
  UpdateProductResponse createEmptyInstance() => UpdateProductResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateProductResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProductResponse>(
          UpdateProductResponse.$_createMessage);
  static UpdateProductResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(Product value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => $_clearField(1);
  @$pb.TagNumber(1)
  Product ensureProduct() => $_ensure(0);
}

class ListProductVariantsRequest extends $pb.GeneratedMessage {
  factory ListProductVariantsRequest({
    $core.String? productId,
  }) {
    final result = ListProductVariantsRequest._();
    if (productId != null) result.productId = productId;
    return result;
  }

  ListProductVariantsRequest._();

  factory ListProductVariantsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductVariantsRequest()..mergeFromBuffer(data, registry);
  factory ListProductVariantsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductVariantsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProductVariantsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListProductVariantsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'productId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductVariantsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductVariantsRequest copyWith(
          void Function(ListProductVariantsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListProductVariantsRequest))
          as ListProductVariantsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListProductVariantsRequest() / ListProductVariantsRequest.new instead')
  static ListProductVariantsRequest create() => ListProductVariantsRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ListProductVariantsRequest._();
  @$core.override
  ListProductVariantsRequest createEmptyInstance() =>
      ListProductVariantsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListProductVariantsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProductVariantsRequest>(
          ListProductVariantsRequest.$_createMessage);
  static ListProductVariantsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get productId => $_getSZ(0);
  @$pb.TagNumber(1)
  set productId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProductId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductId() => $_clearField(1);
}

class ListProductVariantsResponse extends $pb.GeneratedMessage {
  factory ListProductVariantsResponse({
    $core.Iterable<ProductVariant>? productVariants,
  }) {
    final result = ListProductVariantsResponse._();
    if (productVariants != null) result.productVariants.addAll(productVariants);
    return result;
  }

  ListProductVariantsResponse._();

  factory ListProductVariantsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductVariantsResponse()..mergeFromBuffer(data, registry);
  factory ListProductVariantsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListProductVariantsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProductVariantsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListProductVariantsResponse.$_createMessage)
    ..pPM<ProductVariant>(1, _omitFieldNames ? '' : 'productVariants',
        subBuilder: ProductVariant.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductVariantsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProductVariantsResponse copyWith(
          void Function(ListProductVariantsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListProductVariantsResponse))
          as ListProductVariantsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListProductVariantsResponse() / ListProductVariantsResponse.new instead')
  static ListProductVariantsResponse create() =>
      ListProductVariantsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ListProductVariantsResponse._();
  @$core.override
  ListProductVariantsResponse createEmptyInstance() =>
      ListProductVariantsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListProductVariantsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProductVariantsResponse>(
          ListProductVariantsResponse.$_createMessage);
  static ListProductVariantsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProductVariant> get productVariants => $_getList(0);
}

class ReceiveStockRequest extends $pb.GeneratedMessage {
  factory ReceiveStockRequest({
    $core.String? variantId,
    $fixnum.Int64? quantity,
    $core.String? reference,
    $core.String? tenantId,
  }) {
    final result = ReceiveStockRequest._();
    if (variantId != null) result.variantId = variantId;
    if (quantity != null) result.quantity = quantity;
    if (reference != null) result.reference = reference;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  ReceiveStockRequest._();

  factory ReceiveStockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveStockRequest()..mergeFromBuffer(data, registry);
  factory ReceiveStockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveStockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveStockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ReceiveStockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aInt64(2, _omitFieldNames ? '' : 'quantity')
    ..aOS(3, _omitFieldNames ? '' : 'reference')
    ..aOS(4, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveStockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveStockRequest copyWith(void Function(ReceiveStockRequest) updates) =>
      super.copyWith((message) => updates(message as ReceiveStockRequest))
          as ReceiveStockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ReceiveStockRequest() / ReceiveStockRequest.new instead')
  static ReceiveStockRequest create() => ReceiveStockRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReceiveStockRequest._();
  @$core.override
  ReceiveStockRequest createEmptyInstance() => ReceiveStockRequest._();
  @$core.pragma('dart2js:noInline')
  static ReceiveStockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveStockRequest>(
          ReceiveStockRequest.$_createMessage);
  static ReceiveStockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => $_clearField(1);

  /// Whole units received; must be positive.
  @$pb.TagNumber(2)
  $fixnum.Int64 get quantity => $_getI64(1);
  @$pb.TagNumber(2)
  set quantity($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => $_clearField(2);

  /// Unique per receipt line (e.g. "procurement:grl:<line id>"). A reference
  /// already received for the same variant and quantity adds nothing; for any
  /// other variant or quantity it is refused.
  @$pb.TagNumber(3)
  $core.String get reference => $_getSZ(2);
  @$pb.TagNumber(3)
  set reference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearReference() => $_clearField(3);

  /// The tenant the receipt was recorded in; the variant must belong to it.
  @$pb.TagNumber(4)
  $core.String get tenantId => $_getSZ(3);
  @$pb.TagNumber(4)
  set tenantId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTenantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTenantId() => $_clearField(4);
}

class ReceiveStockResponse extends $pb.GeneratedMessage {
  factory ReceiveStockResponse({
    $fixnum.Int64? stockQuantity,
    $core.bool? replayed,
  }) {
    final result = ReceiveStockResponse._();
    if (stockQuantity != null) result.stockQuantity = stockQuantity;
    if (replayed != null) result.replayed = replayed;
    return result;
  }

  ReceiveStockResponse._();

  factory ReceiveStockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveStockResponse()..mergeFromBuffer(data, registry);
  factory ReceiveStockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveStockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveStockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ReceiveStockResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'stockQuantity')
    ..aOB(2, _omitFieldNames ? '' : 'replayed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveStockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveStockResponse copyWith(void Function(ReceiveStockResponse) updates) =>
      super.copyWith((message) => updates(message as ReceiveStockResponse))
          as ReceiveStockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReceiveStockResponse() / ReceiveStockResponse.new instead')
  static ReceiveStockResponse create() => ReceiveStockResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReceiveStockResponse._();
  @$core.override
  ReceiveStockResponse createEmptyInstance() => ReceiveStockResponse._();
  @$core.pragma('dart2js:noInline')
  static ReceiveStockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveStockResponse>(
          ReceiveStockResponse.$_createMessage);
  static ReceiveStockResponse? _defaultInstance;

  /// The variant's stock after the receipt.
  @$pb.TagNumber(1)
  $fixnum.Int64 get stockQuantity => $_getI64(0);
  @$pb.TagNumber(1)
  set stockQuantity($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStockQuantity() => $_has(0);
  @$pb.TagNumber(1)
  void clearStockQuantity() => $_clearField(1);

  /// True when the reference had already been received.
  @$pb.TagNumber(2)
  $core.bool get replayed => $_getBF(1);
  @$pb.TagNumber(2)
  set replayed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReplayed() => $_has(1);
  @$pb.TagNumber(2)
  void clearReplayed() => $_clearField(2);
}

class UpdateProductVariantResponse extends $pb.GeneratedMessage {
  factory UpdateProductVariantResponse({
    ProductVariant? productVariant,
  }) {
    final result = UpdateProductVariantResponse._();
    if (productVariant != null) result.productVariant = productVariant;
    return result;
  }

  UpdateProductVariantResponse._();

  factory UpdateProductVariantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductVariantResponse()..mergeFromBuffer(data, registry);
  factory UpdateProductVariantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProductVariantResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProductVariantResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateProductVariantResponse.$_createMessage)
    ..aOM<ProductVariant>(1, _omitFieldNames ? '' : 'productVariant',
        subBuilder: ProductVariant.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductVariantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProductVariantResponse copyWith(
          void Function(UpdateProductVariantResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateProductVariantResponse))
          as UpdateProductVariantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateProductVariantResponse() / UpdateProductVariantResponse.new instead')
  static UpdateProductVariantResponse create() =>
      UpdateProductVariantResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      UpdateProductVariantResponse._();
  @$core.override
  UpdateProductVariantResponse createEmptyInstance() =>
      UpdateProductVariantResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateProductVariantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProductVariantResponse>(
          UpdateProductVariantResponse.$_createMessage);
  static UpdateProductVariantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProductVariant get productVariant => $_getN(0);
  @$pb.TagNumber(1)
  set productVariant(ProductVariant value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProductVariant() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductVariant() => $_clearField(1);
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
    $0.Timestamp? expiresAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = Cart._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (status != null) result.status = status;
    if (profileId != null) result.profileId = profileId;
    if (contactId != null) result.contactId = contactId;
    if (lines != null) result.lines.addAll(lines);
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Cart._();

  factory Cart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Cart()..mergeFromBuffer(data, registry);
  factory Cart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Cart()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Cart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: Cart.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aE<CartStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: CartStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'profileId')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..pPM<CartLine>(10, _omitFieldNames ? '' : 'lines',
        subBuilder: CartLine.$_createMessage)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cart copyWith(void Function(Cart) updates) =>
      super.copyWith((message) => updates(message as Cart)) as Cart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Cart() / Cart.new instead')
  static Cart create() => Cart._();
  static $pb.GeneratedMessage $_createMessage() => Cart._();
  @$core.override
  Cart createEmptyInstance() => Cart._();
  @$core.pragma('dart2js:noInline')
  static Cart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Cart>(Cart.$_createMessage);
  static Cart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  CartStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(CartStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get profileId => $_getSZ(3);
  @$pb.TagNumber(4)
  set profileId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProfileId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProfileId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => $_clearField(5);

  @$pb.TagNumber(10)
  $pb.PbList<CartLine> get lines => $_getList(5);

  @$pb.TagNumber(16)
  $0.Timestamp get expiresAt => $_getN(6);
  @$pb.TagNumber(16)
  set expiresAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasExpiresAt() => $_has(6);
  @$pb.TagNumber(16)
  void clearExpiresAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureExpiresAt() => $_ensure(6);

  @$pb.TagNumber(17)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(17)
  set createdAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(17)
  void clearCreatedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(18)
  $0.Timestamp get updatedAt => $_getN(8);
  @$pb.TagNumber(18)
  set updatedAt($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(18)
  void clearUpdatedAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureUpdatedAt() => $_ensure(8);
}

class CartLine extends $pb.GeneratedMessage {
  factory CartLine({
    $core.String? id,
    $core.String? productVariantId,
    $fixnum.Int64? quantity,
  }) {
    final result = CartLine._();
    if (id != null) result.id = id;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  CartLine._();

  factory CartLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CartLine()..mergeFromBuffer(data, registry);
  factory CartLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CartLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CartLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CartLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aInt64(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CartLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CartLine copyWith(void Function(CartLine) updates) =>
      super.copyWith((message) => updates(message as CartLine)) as CartLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CartLine() / CartLine.new instead')
  static CartLine create() => CartLine._();
  static $pb.GeneratedMessage $_createMessage() => CartLine._();
  @$core.override
  CartLine createEmptyInstance() => CartLine._();
  @$core.pragma('dart2js:noInline')
  static CartLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CartLine>(CartLine.$_createMessage);
  static CartLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get quantity => $_getI64(2);
  @$pb.TagNumber(3)
  set quantity($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);
}

class CreateCartRequest extends $pb.GeneratedMessage {
  factory CreateCartRequest({
    $core.String? shopId,
    $core.String? profileId,
    $core.String? contactId,
  }) {
    final result = CreateCartRequest._();
    if (shopId != null) result.shopId = shopId;
    if (profileId != null) result.profileId = profileId;
    if (contactId != null) result.contactId = contactId;
    return result;
  }

  CreateCartRequest._();

  factory CreateCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCartRequest()..mergeFromBuffer(data, registry);
  factory CreateCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateCartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'contactId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCartRequest copyWith(void Function(CreateCartRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCartRequest))
          as CreateCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateCartRequest() / CreateCartRequest.new instead')
  static CreateCartRequest create() => CreateCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateCartRequest._();
  @$core.override
  CreateCartRequest createEmptyInstance() => CreateCartRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateCartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCartRequest>(
          CreateCartRequest.$_createMessage);
  static CreateCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  /// Optional – used for abandoned cart reminders
  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get contactId => $_getSZ(2);
  @$pb.TagNumber(3)
  set contactId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContactId() => $_has(2);
  @$pb.TagNumber(3)
  void clearContactId() => $_clearField(3);
}

class CreateCartResponse extends $pb.GeneratedMessage {
  factory CreateCartResponse({
    Cart? cart,
  }) {
    final result = CreateCartResponse._();
    if (cart != null) result.cart = cart;
    return result;
  }

  CreateCartResponse._();

  factory CreateCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCartResponse()..mergeFromBuffer(data, registry);
  factory CreateCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCartResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateCartResponse.$_createMessage)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart',
        subBuilder: Cart.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCartResponse copyWith(void Function(CreateCartResponse) updates) =>
      super.copyWith((message) => updates(message as CreateCartResponse))
          as CreateCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateCartResponse() / CreateCartResponse.new instead')
  static CreateCartResponse create() => CreateCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateCartResponse._();
  @$core.override
  CreateCartResponse createEmptyInstance() => CreateCartResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCartResponse>(
          CreateCartResponse.$_createMessage);
  static CreateCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => $_clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class GetCartRequest extends $pb.GeneratedMessage {
  factory GetCartRequest({
    $core.String? id,
  }) {
    final result = GetCartRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetCartRequest._();

  factory GetCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartRequest()..mergeFromBuffer(data, registry);
  factory GetCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetCartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartRequest copyWith(void Function(GetCartRequest) updates) =>
      super.copyWith((message) => updates(message as GetCartRequest))
          as GetCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCartRequest() / GetCartRequest.new instead')
  static GetCartRequest create() => GetCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCartRequest._();
  @$core.override
  GetCartRequest createEmptyInstance() => GetCartRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartRequest>(
          GetCartRequest.$_createMessage);
  static GetCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetCartResponse extends $pb.GeneratedMessage {
  factory GetCartResponse({
    Cart? cart,
  }) {
    final result = GetCartResponse._();
    if (cart != null) result.cart = cart;
    return result;
  }

  GetCartResponse._();

  factory GetCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartResponse()..mergeFromBuffer(data, registry);
  factory GetCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCartResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetCartResponse.$_createMessage)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart',
        subBuilder: Cart.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartResponse copyWith(void Function(GetCartResponse) updates) =>
      super.copyWith((message) => updates(message as GetCartResponse))
          as GetCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCartResponse() / GetCartResponse.new instead')
  static GetCartResponse create() => GetCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCartResponse._();
  @$core.override
  GetCartResponse createEmptyInstance() => GetCartResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCartResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartResponse>(
          GetCartResponse.$_createMessage);
  static GetCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => $_clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class AddCartLineRequest extends $pb.GeneratedMessage {
  factory AddCartLineRequest({
    $core.String? cartId,
    $core.String? productVariantId,
    $fixnum.Int64? quantity,
  }) {
    final result = AddCartLineRequest._();
    if (cartId != null) result.cartId = cartId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  AddCartLineRequest._();

  factory AddCartLineRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddCartLineRequest()..mergeFromBuffer(data, registry);
  factory AddCartLineRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddCartLineRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddCartLineRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: AddCartLineRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aInt64(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddCartLineRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddCartLineRequest copyWith(void Function(AddCartLineRequest) updates) =>
      super.copyWith((message) => updates(message as AddCartLineRequest))
          as AddCartLineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddCartLineRequest() / AddCartLineRequest.new instead')
  static AddCartLineRequest create() => AddCartLineRequest._();
  static $pb.GeneratedMessage $_createMessage() => AddCartLineRequest._();
  @$core.override
  AddCartLineRequest createEmptyInstance() => AddCartLineRequest._();
  @$core.pragma('dart2js:noInline')
  static AddCartLineRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddCartLineRequest>(
          AddCartLineRequest.$_createMessage);
  static AddCartLineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get quantity => $_getI64(2);
  @$pb.TagNumber(3)
  set quantity($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);
}

class AddCartLineResponse extends $pb.GeneratedMessage {
  factory AddCartLineResponse({
    Cart? cart,
  }) {
    final result = AddCartLineResponse._();
    if (cart != null) result.cart = cart;
    return result;
  }

  AddCartLineResponse._();

  factory AddCartLineResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddCartLineResponse()..mergeFromBuffer(data, registry);
  factory AddCartLineResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddCartLineResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddCartLineResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: AddCartLineResponse.$_createMessage)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart',
        subBuilder: Cart.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddCartLineResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddCartLineResponse copyWith(void Function(AddCartLineResponse) updates) =>
      super.copyWith((message) => updates(message as AddCartLineResponse))
          as AddCartLineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use AddCartLineResponse() / AddCartLineResponse.new instead')
  static AddCartLineResponse create() => AddCartLineResponse._();
  static $pb.GeneratedMessage $_createMessage() => AddCartLineResponse._();
  @$core.override
  AddCartLineResponse createEmptyInstance() => AddCartLineResponse._();
  @$core.pragma('dart2js:noInline')
  static AddCartLineResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddCartLineResponse>(
          AddCartLineResponse.$_createMessage);
  static AddCartLineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => $_clearField(1);
  @$pb.TagNumber(1)
  Cart ensureCart() => $_ensure(0);
}

class RemoveCartLineRequest extends $pb.GeneratedMessage {
  factory RemoveCartLineRequest({
    $core.String? cartId,
    $core.String? cartLineId,
  }) {
    final result = RemoveCartLineRequest._();
    if (cartId != null) result.cartId = cartId;
    if (cartLineId != null) result.cartLineId = cartLineId;
    return result;
  }

  RemoveCartLineRequest._();

  factory RemoveCartLineRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveCartLineRequest()..mergeFromBuffer(data, registry);
  factory RemoveCartLineRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveCartLineRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveCartLineRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RemoveCartLineRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(2, _omitFieldNames ? '' : 'cartLineId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveCartLineRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveCartLineRequest copyWith(
          void Function(RemoveCartLineRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveCartLineRequest))
          as RemoveCartLineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RemoveCartLineRequest() / RemoveCartLineRequest.new instead')
  static RemoveCartLineRequest create() => RemoveCartLineRequest._();
  static $pb.GeneratedMessage $_createMessage() => RemoveCartLineRequest._();
  @$core.override
  RemoveCartLineRequest createEmptyInstance() => RemoveCartLineRequest._();
  @$core.pragma('dart2js:noInline')
  static RemoveCartLineRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveCartLineRequest>(
          RemoveCartLineRequest.$_createMessage);
  static RemoveCartLineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cartLineId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cartLineId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCartLineId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCartLineId() => $_clearField(2);
}

class RemoveCartLineResponse extends $pb.GeneratedMessage {
  factory RemoveCartLineResponse({
    Cart? cart,
  }) {
    final result = RemoveCartLineResponse._();
    if (cart != null) result.cart = cart;
    return result;
  }

  RemoveCartLineResponse._();

  factory RemoveCartLineResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveCartLineResponse()..mergeFromBuffer(data, registry);
  factory RemoveCartLineResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveCartLineResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveCartLineResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RemoveCartLineResponse.$_createMessage)
    ..aOM<Cart>(1, _omitFieldNames ? '' : 'cart',
        subBuilder: Cart.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveCartLineResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveCartLineResponse copyWith(
          void Function(RemoveCartLineResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveCartLineResponse))
          as RemoveCartLineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RemoveCartLineResponse() / RemoveCartLineResponse.new instead')
  static RemoveCartLineResponse create() => RemoveCartLineResponse._();
  static $pb.GeneratedMessage $_createMessage() => RemoveCartLineResponse._();
  @$core.override
  RemoveCartLineResponse createEmptyInstance() => RemoveCartLineResponse._();
  @$core.pragma('dart2js:noInline')
  static RemoveCartLineResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveCartLineResponse>(
          RemoveCartLineResponse.$_createMessage);
  static RemoveCartLineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cart get cart => $_getN(0);
  @$pb.TagNumber(1)
  set cart(Cart value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCart() => $_has(0);
  @$pb.TagNumber(1)
  void clearCart() => $_clearField(1);
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
    final result = CreateOrderFromCartRequest._();
    if (cartId != null) result.cartId = cartId;
    if (profileId != null) result.profileId = profileId;
    if (contactId != null) result.contactId = contactId;
    if (addressId != null) result.addressId = addressId;
    return result;
  }

  CreateOrderFromCartRequest._();

  factory CreateOrderFromCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderFromCartRequest()..mergeFromBuffer(data, registry);
  factory CreateOrderFromCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderFromCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateOrderFromCartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateOrderFromCartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cartId')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderFromCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderFromCartRequest copyWith(
          void Function(CreateOrderFromCartRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateOrderFromCartRequest))
          as CreateOrderFromCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateOrderFromCartRequest() / CreateOrderFromCartRequest.new instead')
  static CreateOrderFromCartRequest create() => CreateOrderFromCartRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateOrderFromCartRequest._();
  @$core.override
  CreateOrderFromCartRequest createEmptyInstance() =>
      CreateOrderFromCartRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateOrderFromCartRequest>(
          CreateOrderFromCartRequest.$_createMessage);
  static CreateOrderFromCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cartId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cartId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCartId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCartId() => $_clearField(1);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(5)
  set profileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(5)
  void clearProfileId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(2);
  @$pb.TagNumber(6)
  set contactId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(2);
  @$pb.TagNumber(6)
  void clearContactId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(3);
  @$pb.TagNumber(7)
  set addressId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(3);
  @$pb.TagNumber(7)
  void clearAddressId() => $_clearField(7);
}

class CreateOrderFromCartResponse extends $pb.GeneratedMessage {
  factory CreateOrderFromCartResponse({
    Order? order,
  }) {
    final result = CreateOrderFromCartResponse._();
    if (order != null) result.order = order;
    return result;
  }

  CreateOrderFromCartResponse._();

  factory CreateOrderFromCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderFromCartResponse()..mergeFromBuffer(data, registry);
  factory CreateOrderFromCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderFromCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateOrderFromCartResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateOrderFromCartResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderFromCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderFromCartResponse copyWith(
          void Function(CreateOrderFromCartResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateOrderFromCartResponse))
          as CreateOrderFromCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateOrderFromCartResponse() / CreateOrderFromCartResponse.new instead')
  static CreateOrderFromCartResponse create() =>
      CreateOrderFromCartResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateOrderFromCartResponse._();
  @$core.override
  CreateOrderFromCartResponse createEmptyInstance() =>
      CreateOrderFromCartResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateOrderFromCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateOrderFromCartResponse>(
          CreateOrderFromCartResponse.$_createMessage);
  static CreateOrderFromCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
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
    $4.Money? subtotal,
    $4.Money? total,
    $core.Iterable<OrderLine>? lines,
    $0.Timestamp? createdAt,
    $core.String? paymentSessionRef,
    $core.String? checkoutUrl,
    $core.String? paymentId,
    PaymentStatus? paymentStatus,
    FulfilmentStatus? fulfilmentStatus,
    $0.Timestamp? paidAt,
    $0.Timestamp? cancelledAt,
    $core.String? cancelReason,
    $core.String? ledgerTransactionId,
    $4.Money? amountPaid,
    $4.Money? balance,
    $0.Timestamp? balanceDueAt,
    PaymentPolicy? paymentPolicy,
    $core.Iterable<OrderPayment>? payments,
    $0.Timestamp? paymentDueAt,
    $4.Money? amountRefunded,
    $core.String? paymentReview,
    $core.Iterable<OrderRefund>? refunds,
  }) {
    final result = Order._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (orderNumber != null) result.orderNumber = orderNumber;
    if (status != null) result.status = status;
    if (profileId != null) result.profileId = profileId;
    if (contactId != null) result.contactId = contactId;
    if (addressId != null) result.addressId = addressId;
    if (subtotal != null) result.subtotal = subtotal;
    if (total != null) result.total = total;
    if (lines != null) result.lines.addAll(lines);
    if (createdAt != null) result.createdAt = createdAt;
    if (paymentSessionRef != null) result.paymentSessionRef = paymentSessionRef;
    if (checkoutUrl != null) result.checkoutUrl = checkoutUrl;
    if (paymentId != null) result.paymentId = paymentId;
    if (paymentStatus != null) result.paymentStatus = paymentStatus;
    if (fulfilmentStatus != null) result.fulfilmentStatus = fulfilmentStatus;
    if (paidAt != null) result.paidAt = paidAt;
    if (cancelledAt != null) result.cancelledAt = cancelledAt;
    if (cancelReason != null) result.cancelReason = cancelReason;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (amountPaid != null) result.amountPaid = amountPaid;
    if (balance != null) result.balance = balance;
    if (balanceDueAt != null) result.balanceDueAt = balanceDueAt;
    if (paymentPolicy != null) result.paymentPolicy = paymentPolicy;
    if (payments != null) result.payments.addAll(payments);
    if (paymentDueAt != null) result.paymentDueAt = paymentDueAt;
    if (amountRefunded != null) result.amountRefunded = amountRefunded;
    if (paymentReview != null) result.paymentReview = paymentReview;
    if (refunds != null) result.refunds.addAll(refunds);
    return result;
  }

  Order._();

  factory Order.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Order()..mergeFromBuffer(data, registry);
  factory Order.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Order()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Order',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: Order.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'orderNumber')
    ..aE<OrderStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: OrderStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..aOM<$4.Money>(8, _omitFieldNames ? '' : 'subtotal',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$4.Money>(9, _omitFieldNames ? '' : 'total',
        subBuilder: $4.Money.$_createMessage)
    ..pPM<OrderLine>(10, _omitFieldNames ? '' : 'lines',
        subBuilder: OrderLine.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'paymentSessionRef')
    ..aOS(13, _omitFieldNames ? '' : 'checkoutUrl')
    ..aOS(14, _omitFieldNames ? '' : 'paymentId')
    ..aE<PaymentStatus>(15, _omitFieldNames ? '' : 'paymentStatus',
        enumValues: PaymentStatus.values)
    ..aE<FulfilmentStatus>(16, _omitFieldNames ? '' : 'fulfilmentStatus',
        enumValues: FulfilmentStatus.values)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'paidAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'cancelledAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(19, _omitFieldNames ? '' : 'cancelReason')
    ..aOS(20, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOM<$4.Money>(21, _omitFieldNames ? '' : 'amountPaid',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$4.Money>(22, _omitFieldNames ? '' : 'balance',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'balanceDueAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<PaymentPolicy>(24, _omitFieldNames ? '' : 'paymentPolicy',
        subBuilder: PaymentPolicy.$_createMessage)
    ..pPM<OrderPayment>(25, _omitFieldNames ? '' : 'payments',
        subBuilder: OrderPayment.$_createMessage)
    ..aOM<$0.Timestamp>(26, _omitFieldNames ? '' : 'paymentDueAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$4.Money>(27, _omitFieldNames ? '' : 'amountRefunded',
        subBuilder: $4.Money.$_createMessage)
    ..aOS(28, _omitFieldNames ? '' : 'paymentReview')
    ..pPM<OrderRefund>(29, _omitFieldNames ? '' : 'refunds',
        subBuilder: OrderRefund.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order copyWith(void Function(Order) updates) =>
      super.copyWith((message) => updates(message as Order)) as Order;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Order() / Order.new instead')
  static Order create() => Order._();
  static $pb.GeneratedMessage $_createMessage() => Order._();
  @$core.override
  Order createEmptyInstance() => Order._();
  @$core.pragma('dart2js:noInline')
  static Order getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Order>(Order.$_createMessage);
  static Order? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orderNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set orderNumber($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderNumber() => $_clearField(3);

  @$pb.TagNumber(4)
  OrderStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(OrderStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(4);
  @$pb.TagNumber(5)
  set profileId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProfileId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(5);
  @$pb.TagNumber(6)
  set contactId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(5);
  @$pb.TagNumber(6)
  void clearContactId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(6);
  @$pb.TagNumber(7)
  set addressId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(6);
  @$pb.TagNumber(7)
  void clearAddressId() => $_clearField(7);

  @$pb.TagNumber(8)
  $4.Money get subtotal => $_getN(7);
  @$pb.TagNumber(8)
  set subtotal($4.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasSubtotal() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubtotal() => $_clearField(8);
  @$pb.TagNumber(8)
  $4.Money ensureSubtotal() => $_ensure(7);

  @$pb.TagNumber(9)
  $4.Money get total => $_getN(8);
  @$pb.TagNumber(9)
  set total($4.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTotal() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotal() => $_clearField(9);
  @$pb.TagNumber(9)
  $4.Money ensureTotal() => $_ensure(8);

  @$pb.TagNumber(10)
  $pb.PbList<OrderLine> get lines => $_getList(9);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);

  /// Hosted checkout session for this order, set by CheckoutOrder.
  @$pb.TagNumber(12)
  $core.String get paymentSessionRef => $_getSZ(11);
  @$pb.TagNumber(12)
  set paymentSessionRef($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPaymentSessionRef() => $_has(11);
  @$pb.TagNumber(12)
  void clearPaymentSessionRef() => $_clearField(12);

  /// Page the buyer completes payment on.
  @$pb.TagNumber(13)
  $core.String get checkoutUrl => $_getSZ(12);
  @$pb.TagNumber(13)
  set checkoutUrl($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCheckoutUrl() => $_has(12);
  @$pb.TagNumber(13)
  void clearCheckoutUrl() => $_clearField(13);

  /// Payment service reference once the session completes.
  @$pb.TagNumber(14)
  $core.String get paymentId => $_getSZ(13);
  @$pb.TagNumber(14)
  set paymentId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPaymentId() => $_has(13);
  @$pb.TagNumber(14)
  void clearPaymentId() => $_clearField(14);

  @$pb.TagNumber(15)
  PaymentStatus get paymentStatus => $_getN(14);
  @$pb.TagNumber(15)
  set paymentStatus(PaymentStatus value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasPaymentStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearPaymentStatus() => $_clearField(15);

  @$pb.TagNumber(16)
  FulfilmentStatus get fulfilmentStatus => $_getN(15);
  @$pb.TagNumber(16)
  set fulfilmentStatus(FulfilmentStatus value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasFulfilmentStatus() => $_has(15);
  @$pb.TagNumber(16)
  void clearFulfilmentStatus() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get paidAt => $_getN(16);
  @$pb.TagNumber(17)
  set paidAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasPaidAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearPaidAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensurePaidAt() => $_ensure(16);

  @$pb.TagNumber(18)
  $0.Timestamp get cancelledAt => $_getN(17);
  @$pb.TagNumber(18)
  set cancelledAt($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasCancelledAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearCancelledAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureCancelledAt() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get cancelReason => $_getSZ(18);
  @$pb.TagNumber(19)
  set cancelReason($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCancelReason() => $_has(18);
  @$pb.TagNumber(19)
  void clearCancelReason() => $_clearField(19);

  /// Ledger transaction this order was merged into at end of day.
  @$pb.TagNumber(20)
  $core.String get ledgerTransactionId => $_getSZ(19);
  @$pb.TagNumber(20)
  set ledgerTransactionId($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasLedgerTransactionId() => $_has(19);
  @$pb.TagNumber(20)
  void clearLedgerTransactionId() => $_clearField(20);

  /// What has been paid so far across every instalment.
  @$pb.TagNumber(21)
  $4.Money get amountPaid => $_getN(20);
  @$pb.TagNumber(21)
  set amountPaid($4.Money value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasAmountPaid() => $_has(20);
  @$pb.TagNumber(21)
  void clearAmountPaid() => $_clearField(21);
  @$pb.TagNumber(21)
  $4.Money ensureAmountPaid() => $_ensure(20);

  /// What remains to be paid.
  @$pb.TagNumber(22)
  $4.Money get balance => $_getN(21);
  @$pb.TagNumber(22)
  set balance($4.Money value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasBalance() => $_has(21);
  @$pb.TagNumber(22)
  void clearBalance() => $_clearField(22);
  @$pb.TagNumber(22)
  $4.Money ensureBalance() => $_ensure(21);

  /// Deadline for the balance once a first instalment has been paid.
  @$pb.TagNumber(23)
  $0.Timestamp get balanceDueAt => $_getN(22);
  @$pb.TagNumber(23)
  set balanceDueAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasBalanceDueAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearBalanceDueAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureBalanceDueAt() => $_ensure(22);

  /// The payment policy in force for this order, fixed when it was placed.
  @$pb.TagNumber(24)
  PaymentPolicy get paymentPolicy => $_getN(23);
  @$pb.TagNumber(24)
  set paymentPolicy(PaymentPolicy value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasPaymentPolicy() => $_has(23);
  @$pb.TagNumber(24)
  void clearPaymentPolicy() => $_clearField(24);
  @$pb.TagNumber(24)
  PaymentPolicy ensurePaymentPolicy() => $_ensure(23);

  /// Every payment applied to the order, oldest first.
  @$pb.TagNumber(25)
  $pb.PbList<OrderPayment> get payments => $_getList(24);

  /// Unpaid orders hold stock until this time.
  @$pb.TagNumber(26)
  $0.Timestamp get paymentDueAt => $_getN(25);
  @$pb.TagNumber(26)
  set paymentDueAt($0.Timestamp value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasPaymentDueAt() => $_has(25);
  @$pb.TagNumber(26)
  void clearPaymentDueAt() => $_clearField(26);
  @$pb.TagNumber(26)
  $0.Timestamp ensurePaymentDueAt() => $_ensure(25);

  /// What has been paid back to the buyer: refunds the payment service
  /// confirmed.
  @$pb.TagNumber(27)
  $4.Money get amountRefunded => $_getN(26);
  @$pb.TagNumber(27)
  set amountRefunded($4.Money value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasAmountRefunded() => $_has(26);
  @$pb.TagNumber(27)
  void clearAmountRefunded() => $_clearField(27);
  @$pb.TagNumber(27)
  $4.Money ensureAmountRefunded() => $_ensure(26);

  /// Set when a payment on this order needs staff attention, such as a
  /// checkout session that charged a different amount from the one issued;
  /// the reconciler stops retrying it.
  @$pb.TagNumber(28)
  $core.String get paymentReview => $_getSZ(27);
  @$pb.TagNumber(28)
  set paymentReview($core.String value) => $_setString(27, value);
  @$pb.TagNumber(28)
  $core.bool hasPaymentReview() => $_has(27);
  @$pb.TagNumber(28)
  void clearPaymentReview() => $_clearField(28);

  /// Money owed back to the buyer, oldest first, and where each payment back
  /// stands.
  @$pb.TagNumber(29)
  $pb.PbList<OrderRefund> get refunds => $_getList(28);
}

/// OrderRefund is money owed back to an order's buyer: an overpayment, a
/// payment on a cancelled order, or what was paid before cancelling.
class OrderRefund extends $pb.GeneratedMessage {
  factory OrderRefund({
    $core.String? id,
    $4.Money? amount,
    OrderRefundStatus? status,
    $core.String? lastError,
    $0.Timestamp? confirmedAt,
    $core.String? resolvedBy,
    $core.String? note,
  }) {
    final result = OrderRefund._();
    if (id != null) result.id = id;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (lastError != null) result.lastError = lastError;
    if (confirmedAt != null) result.confirmedAt = confirmedAt;
    if (resolvedBy != null) result.resolvedBy = resolvedBy;
    if (note != null) result.note = note;
    return result;
  }

  OrderRefund._();

  factory OrderRefund.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderRefund()..mergeFromBuffer(data, registry);
  factory OrderRefund.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderRefund()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrderRefund',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: OrderRefund.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$4.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $4.Money.$_createMessage)
    ..aE<OrderRefundStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: OrderRefundStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'lastError')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'confirmedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'resolvedBy')
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderRefund clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderRefund copyWith(void Function(OrderRefund) updates) =>
      super.copyWith((message) => updates(message as OrderRefund))
          as OrderRefund;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrderRefund() / OrderRefund.new instead')
  static OrderRefund create() => OrderRefund._();
  static $pb.GeneratedMessage $_createMessage() => OrderRefund._();
  @$core.override
  OrderRefund createEmptyInstance() => OrderRefund._();
  @$core.pragma('dart2js:noInline')
  static OrderRefund getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrderRefund>(
          OrderRefund.$_createMessage);
  static OrderRefund? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $4.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($4.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  OrderRefundStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(OrderRefundStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  /// Why the last attempt did not settle it.
  @$pb.TagNumber(4)
  $core.String get lastError => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastError($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastError() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastError() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get confirmedAt => $_getN(4);
  @$pb.TagNumber(5)
  set confirmedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureConfirmedAt() => $_ensure(4);

  /// Staff who recorded paying the buyer back themselves, and their note.
  @$pb.TagNumber(6)
  $core.String get resolvedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set resolvedBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasResolvedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearResolvedBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => $_clearField(7);
}

/// OrderPayment is one instalment applied to an order.
class OrderPayment extends $pb.GeneratedMessage {
  factory OrderPayment({
    $core.String? id,
    $4.Money? amount,
    OrderPaymentSource? source,
    $core.String? reference,
    $core.String? paymentId,
    $0.Timestamp? paidAt,
    $core.String? recordedBy,
    $core.String? note,
  }) {
    final result = OrderPayment._();
    if (id != null) result.id = id;
    if (amount != null) result.amount = amount;
    if (source != null) result.source = source;
    if (reference != null) result.reference = reference;
    if (paymentId != null) result.paymentId = paymentId;
    if (paidAt != null) result.paidAt = paidAt;
    if (recordedBy != null) result.recordedBy = recordedBy;
    if (note != null) result.note = note;
    return result;
  }

  OrderPayment._();

  factory OrderPayment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderPayment()..mergeFromBuffer(data, registry);
  factory OrderPayment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderPayment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrderPayment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: OrderPayment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$4.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $4.Money.$_createMessage)
    ..aE<OrderPaymentSource>(3, _omitFieldNames ? '' : 'source',
        enumValues: OrderPaymentSource.values)
    ..aOS(4, _omitFieldNames ? '' : 'reference')
    ..aOS(5, _omitFieldNames ? '' : 'paymentId')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'paidAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'recordedBy')
    ..aOS(8, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderPayment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderPayment copyWith(void Function(OrderPayment) updates) =>
      super.copyWith((message) => updates(message as OrderPayment))
          as OrderPayment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrderPayment() / OrderPayment.new instead')
  static OrderPayment create() => OrderPayment._();
  static $pb.GeneratedMessage $_createMessage() => OrderPayment._();
  @$core.override
  OrderPayment createEmptyInstance() => OrderPayment._();
  @$core.pragma('dart2js:noInline')
  static OrderPayment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrderPayment>(
          OrderPayment.$_createMessage);
  static OrderPayment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $4.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($4.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  OrderPaymentSource get source => $_getN(2);
  @$pb.TagNumber(3)
  set source(OrderPaymentSource value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearSource() => $_clearField(3);

  /// Checkout session ref for online payments; the shop's receipt reference
  /// for recorded ones.
  @$pb.TagNumber(4)
  $core.String get reference => $_getSZ(3);
  @$pb.TagNumber(4)
  set reference($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearReference() => $_clearField(4);

  /// Payment service reference, when there is one.
  @$pb.TagNumber(5)
  $core.String get paymentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set paymentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPaymentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPaymentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get paidAt => $_getN(5);
  @$pb.TagNumber(6)
  set paidAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPaidAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaidAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensurePaidAt() => $_ensure(5);

  /// Profile of the staff member who recorded an offline payment.
  @$pb.TagNumber(7)
  $core.String get recordedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set recordedBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRecordedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearRecordedBy() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get note => $_getSZ(7);
  @$pb.TagNumber(8)
  set note($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNote() => $_has(7);
  @$pb.TagNumber(8)
  void clearNote() => $_clearField(8);
}

class OrderLine extends $pb.GeneratedMessage {
  factory OrderLine({
    $core.String? id,
    $core.String? productVariantId,
    $core.String? skuSnapshot,
    $core.String? nameSnapshot,
    $4.Money? unitPrice,
    $fixnum.Int64? quantity,
    $4.Money? totalPrice,
  }) {
    final result = OrderLine._();
    if (id != null) result.id = id;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (skuSnapshot != null) result.skuSnapshot = skuSnapshot;
    if (nameSnapshot != null) result.nameSnapshot = nameSnapshot;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (quantity != null) result.quantity = quantity;
    if (totalPrice != null) result.totalPrice = totalPrice;
    return result;
  }

  OrderLine._();

  factory OrderLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderLine()..mergeFromBuffer(data, registry);
  factory OrderLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrderLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: OrderLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aOS(3, _omitFieldNames ? '' : 'skuSnapshot')
    ..aOS(4, _omitFieldNames ? '' : 'nameSnapshot')
    ..aOM<$4.Money>(5, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $4.Money.$_createMessage)
    ..aInt64(6, _omitFieldNames ? '' : 'quantity')
    ..aOM<$4.Money>(7, _omitFieldNames ? '' : 'totalPrice',
        subBuilder: $4.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderLine copyWith(void Function(OrderLine) updates) =>
      super.copyWith((message) => updates(message as OrderLine)) as OrderLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrderLine() / OrderLine.new instead')
  static OrderLine create() => OrderLine._();
  static $pb.GeneratedMessage $_createMessage() => OrderLine._();
  @$core.override
  OrderLine createEmptyInstance() => OrderLine._();
  @$core.pragma('dart2js:noInline')
  static OrderLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrderLine>(OrderLine.$_createMessage);
  static OrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => $_clearField(2);

  /// Snapshot fields
  @$pb.TagNumber(3)
  $core.String get skuSnapshot => $_getSZ(2);
  @$pb.TagNumber(3)
  set skuSnapshot($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSkuSnapshot() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkuSnapshot() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nameSnapshot => $_getSZ(3);
  @$pb.TagNumber(4)
  set nameSnapshot($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNameSnapshot() => $_has(3);
  @$pb.TagNumber(4)
  void clearNameSnapshot() => $_clearField(4);

  @$pb.TagNumber(5)
  $4.Money get unitPrice => $_getN(4);
  @$pb.TagNumber(5)
  set unitPrice($4.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUnitPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitPrice() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Money ensureUnitPrice() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get quantity => $_getI64(5);
  @$pb.TagNumber(6)
  set quantity($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $4.Money get totalPrice => $_getN(6);
  @$pb.TagNumber(7)
  set totalPrice($4.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalPrice() => $_clearField(7);
  @$pb.TagNumber(7)
  $4.Money ensureTotalPrice() => $_ensure(6);
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
    final result = CreateOrderRequest._();
    if (shopId != null) result.shopId = shopId;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (profileId != null) result.profileId = profileId;
    if (contactId != null) result.contactId = contactId;
    if (addressId != null) result.addressId = addressId;
    if (lines != null) result.lines.addAll(lines);
    return result;
  }

  CreateOrderRequest._();

  factory CreateOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderRequest()..mergeFromBuffer(data, registry);
  factory CreateOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateOrderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateOrderRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..aOS(7, _omitFieldNames ? '' : 'addressId')
    ..pPM<CreateOrderLine>(10, _omitFieldNames ? '' : 'lines',
        subBuilder: CreateOrderLine.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderRequest copyWith(void Function(CreateOrderRequest) updates) =>
      super.copyWith((message) => updates(message as CreateOrderRequest))
          as CreateOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateOrderRequest() / CreateOrderRequest.new instead')
  static CreateOrderRequest create() => CreateOrderRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateOrderRequest._();
  @$core.override
  CreateOrderRequest createEmptyInstance() => CreateOrderRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateOrderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateOrderRequest>(
          CreateOrderRequest.$_createMessage);
  static CreateOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => $_clearField(2);

  @$pb.TagNumber(5)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(5)
  set profileId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(5)
  void clearProfileId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(3);
  @$pb.TagNumber(6)
  set contactId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(3);
  @$pb.TagNumber(6)
  void clearContactId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get addressId => $_getSZ(4);
  @$pb.TagNumber(7)
  set addressId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(7)
  $core.bool hasAddressId() => $_has(4);
  @$pb.TagNumber(7)
  void clearAddressId() => $_clearField(7);

  @$pb.TagNumber(10)
  $pb.PbList<CreateOrderLine> get lines => $_getList(5);
}

class CreateOrderResponse extends $pb.GeneratedMessage {
  factory CreateOrderResponse({
    Order? order,
  }) {
    final result = CreateOrderResponse._();
    if (order != null) result.order = order;
    return result;
  }

  CreateOrderResponse._();

  factory CreateOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderResponse()..mergeFromBuffer(data, registry);
  factory CreateOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateOrderResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateOrderResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderResponse copyWith(void Function(CreateOrderResponse) updates) =>
      super.copyWith((message) => updates(message as CreateOrderResponse))
          as CreateOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CreateOrderResponse() / CreateOrderResponse.new instead')
  static CreateOrderResponse create() => CreateOrderResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateOrderResponse._();
  @$core.override
  CreateOrderResponse createEmptyInstance() => CreateOrderResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateOrderResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateOrderResponse>(
          CreateOrderResponse.$_createMessage);
  static CreateOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class CreateOrderLine extends $pb.GeneratedMessage {
  factory CreateOrderLine({
    $core.String? variantId,
    $fixnum.Int64? quantity,
  }) {
    final result = CreateOrderLine._();
    if (variantId != null) result.variantId = variantId;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  CreateOrderLine._();

  factory CreateOrderLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderLine()..mergeFromBuffer(data, registry);
  factory CreateOrderLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateOrderLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateOrderLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateOrderLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aInt64(2, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateOrderLine copyWith(void Function(CreateOrderLine) updates) =>
      super.copyWith((message) => updates(message as CreateOrderLine))
          as CreateOrderLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateOrderLine() / CreateOrderLine.new instead')
  static CreateOrderLine create() => CreateOrderLine._();
  static $pb.GeneratedMessage $_createMessage() => CreateOrderLine._();
  @$core.override
  CreateOrderLine createEmptyInstance() => CreateOrderLine._();
  @$core.pragma('dart2js:noInline')
  static CreateOrderLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateOrderLine>(
          CreateOrderLine.$_createMessage);
  static CreateOrderLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quantity => $_getI64(1);
  @$pb.TagNumber(2)
  set quantity($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => $_clearField(2);
}

class GetOrderRequest extends $pb.GeneratedMessage {
  factory GetOrderRequest({
    $core.String? id,
  }) {
    final result = GetOrderRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetOrderRequest._();

  factory GetOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOrderRequest()..mergeFromBuffer(data, registry);
  factory GetOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOrderRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOrderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetOrderRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderRequest copyWith(void Function(GetOrderRequest) updates) =>
      super.copyWith((message) => updates(message as GetOrderRequest))
          as GetOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetOrderRequest() / GetOrderRequest.new instead')
  static GetOrderRequest create() => GetOrderRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetOrderRequest._();
  @$core.override
  GetOrderRequest createEmptyInstance() => GetOrderRequest._();
  @$core.pragma('dart2js:noInline')
  static GetOrderRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOrderRequest>(
          GetOrderRequest.$_createMessage);
  static GetOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetOrderResponse extends $pb.GeneratedMessage {
  factory GetOrderResponse({
    Order? order,
  }) {
    final result = GetOrderResponse._();
    if (order != null) result.order = order;
    return result;
  }

  GetOrderResponse._();

  factory GetOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOrderResponse()..mergeFromBuffer(data, registry);
  factory GetOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOrderResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOrderResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetOrderResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderResponse copyWith(void Function(GetOrderResponse) updates) =>
      super.copyWith((message) => updates(message as GetOrderResponse))
          as GetOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetOrderResponse() / GetOrderResponse.new instead')
  static GetOrderResponse create() => GetOrderResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetOrderResponse._();
  @$core.override
  GetOrderResponse createEmptyInstance() => GetOrderResponse._();
  @$core.pragma('dart2js:noInline')
  static GetOrderResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOrderResponse>(
          GetOrderResponse.$_createMessage);
  static GetOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class ListOrdersRequest extends $pb.GeneratedMessage {
  factory ListOrdersRequest({
    $core.String? shopId,
    $3.SearchRequest? search,
    $core.String? profileId,
    $core.Iterable<OrderStatus>? statuses,
    $core.Iterable<PaymentStatus>? paymentStatuses,
  }) {
    final result = ListOrdersRequest._();
    if (shopId != null) result.shopId = shopId;
    if (search != null) result.search = search;
    if (profileId != null) result.profileId = profileId;
    if (statuses != null) result.statuses.addAll(statuses);
    if (paymentStatuses != null) result.paymentStatuses.addAll(paymentStatuses);
    return result;
  }

  ListOrdersRequest._();

  factory ListOrdersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrdersRequest()..mergeFromBuffer(data, registry);
  factory ListOrdersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrdersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrdersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListOrdersRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$3.SearchRequest>(2, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..pc<OrderStatus>(4, _omitFieldNames ? '' : 'statuses', $pb.PbFieldType.KE,
        valueOf: OrderStatus.valueOf,
        enumValues: OrderStatus.values,
        defaultEnumValue: OrderStatus.ORDER_STATUS_UNSPECIFIED)
    ..pc<PaymentStatus>(
        5, _omitFieldNames ? '' : 'paymentStatuses', $pb.PbFieldType.KE,
        valueOf: PaymentStatus.valueOf,
        enumValues: PaymentStatus.values,
        defaultEnumValue: PaymentStatus.PAYMENT_STATUS_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersRequest copyWith(void Function(ListOrdersRequest) updates) =>
      super.copyWith((message) => updates(message as ListOrdersRequest))
          as ListOrdersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListOrdersRequest() / ListOrdersRequest.new instead')
  static ListOrdersRequest create() => ListOrdersRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListOrdersRequest._();
  @$core.override
  ListOrdersRequest createEmptyInstance() => ListOrdersRequest._();
  @$core.pragma('dart2js:noInline')
  static ListOrdersRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListOrdersRequest>(
          ListOrdersRequest.$_createMessage);
  static ListOrdersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  /// Optional search parameters (query, cursor, etc.)
  @$pb.TagNumber(2)
  $3.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($3.SearchRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.SearchRequest ensureSearch() => $_ensure(1);

  /// Only this buyer's orders. Staff with orders_view on the shop may name
  /// any profile; anyone else lists their own orders and may name only
  /// themselves.
  @$pb.TagNumber(3)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => $_clearField(3);

  /// Only orders in any of these statuses; empty lists every status.
  @$pb.TagNumber(4)
  $pb.PbList<OrderStatus> get statuses => $_getList(3);

  /// Only orders whose payment is in any of these statuses; empty lists
  /// every payment status.
  @$pb.TagNumber(5)
  $pb.PbList<PaymentStatus> get paymentStatuses => $_getList(4);
}

class ListOrdersResponse extends $pb.GeneratedMessage {
  factory ListOrdersResponse({
    $core.Iterable<Order>? orders,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = ListOrdersResponse._();
    if (orders != null) result.orders.addAll(orders);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  ListOrdersResponse._();

  factory ListOrdersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrdersResponse()..mergeFromBuffer(data, registry);
  factory ListOrdersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrdersResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrdersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListOrdersResponse.$_createMessage)
    ..pPM<Order>(1, _omitFieldNames ? '' : 'orders',
        subBuilder: Order.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersResponse copyWith(void Function(ListOrdersResponse) updates) =>
      super.copyWith((message) => updates(message as ListOrdersResponse))
          as ListOrdersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListOrdersResponse() / ListOrdersResponse.new instead')
  static ListOrdersResponse create() => ListOrdersResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListOrdersResponse._();
  @$core.override
  ListOrdersResponse createEmptyInstance() => ListOrdersResponse._();
  @$core.pragma('dart2js:noInline')
  static ListOrdersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrdersResponse>(
          ListOrdersResponse.$_createMessage);
  static ListOrdersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Order> get orders => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class CheckoutOrderRequest extends $pb.GeneratedMessage {
  factory CheckoutOrderRequest({
    $core.String? orderId,
    $core.String? returnUrl,
    $core.Iterable<$core.String>? methods,
    $4.Money? amount,
  }) {
    final result = CheckoutOrderRequest._();
    if (orderId != null) result.orderId = orderId;
    if (returnUrl != null) result.returnUrl = returnUrl;
    if (methods != null) result.methods.addAll(methods);
    if (amount != null) result.amount = amount;
    return result;
  }

  CheckoutOrderRequest._();

  factory CheckoutOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckoutOrderRequest()..mergeFromBuffer(data, registry);
  factory CheckoutOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckoutOrderRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckoutOrderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CheckoutOrderRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOS(2, _omitFieldNames ? '' : 'returnUrl')
    ..pPS(3, _omitFieldNames ? '' : 'methods')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $4.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckoutOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckoutOrderRequest copyWith(void Function(CheckoutOrderRequest) updates) =>
      super.copyWith((message) => updates(message as CheckoutOrderRequest))
          as CheckoutOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CheckoutOrderRequest() / CheckoutOrderRequest.new instead')
  static CheckoutOrderRequest create() => CheckoutOrderRequest._();
  static $pb.GeneratedMessage $_createMessage() => CheckoutOrderRequest._();
  @$core.override
  CheckoutOrderRequest createEmptyInstance() => CheckoutOrderRequest._();
  @$core.pragma('dart2js:noInline')
  static CheckoutOrderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckoutOrderRequest>(
          CheckoutOrderRequest.$_createMessage);
  static CheckoutOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  /// Overrides the shop's return URL for this session.
  @$pb.TagNumber(2)
  $core.String get returnUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set returnUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReturnUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearReturnUrl() => $_clearField(2);

  /// Optional restriction to specific payment methods.
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get methods => $_getList(2);

  /// The instalment to pay now. Empty pays the whole balance. Anything less
  /// needs a policy that allows instalments and must meet its deposit and
  /// minimum instalment.
  @$pb.TagNumber(4)
  $4.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureAmount() => $_ensure(3);
}

class CheckoutOrderResponse extends $pb.GeneratedMessage {
  factory CheckoutOrderResponse({
    Order? order,
    $core.String? checkoutUrl,
    $core.String? sessionRef,
    $4.Money? amount,
  }) {
    final result = CheckoutOrderResponse._();
    if (order != null) result.order = order;
    if (checkoutUrl != null) result.checkoutUrl = checkoutUrl;
    if (sessionRef != null) result.sessionRef = sessionRef;
    if (amount != null) result.amount = amount;
    return result;
  }

  CheckoutOrderResponse._();

  factory CheckoutOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckoutOrderResponse()..mergeFromBuffer(data, registry);
  factory CheckoutOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckoutOrderResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckoutOrderResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CheckoutOrderResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'checkoutUrl')
    ..aOS(3, _omitFieldNames ? '' : 'sessionRef')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $4.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckoutOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckoutOrderResponse copyWith(
          void Function(CheckoutOrderResponse) updates) =>
      super.copyWith((message) => updates(message as CheckoutOrderResponse))
          as CheckoutOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CheckoutOrderResponse() / CheckoutOrderResponse.new instead')
  static CheckoutOrderResponse create() => CheckoutOrderResponse._();
  static $pb.GeneratedMessage $_createMessage() => CheckoutOrderResponse._();
  @$core.override
  CheckoutOrderResponse createEmptyInstance() => CheckoutOrderResponse._();
  @$core.pragma('dart2js:noInline')
  static CheckoutOrderResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckoutOrderResponse>(
          CheckoutOrderResponse.$_createMessage);
  static CheckoutOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get checkoutUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set checkoutUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCheckoutUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheckoutUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionRef => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionRef($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionRef() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionRef() => $_clearField(3);

  /// The amount this checkout session charges.
  @$pb.TagNumber(4)
  $4.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureAmount() => $_ensure(3);
}

class ConfirmOrderPaymentRequest extends $pb.GeneratedMessage {
  factory ConfirmOrderPaymentRequest({
    $core.String? orderId,
  }) {
    final result = ConfirmOrderPaymentRequest._();
    if (orderId != null) result.orderId = orderId;
    return result;
  }

  ConfirmOrderPaymentRequest._();

  factory ConfirmOrderPaymentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmOrderPaymentRequest()..mergeFromBuffer(data, registry);
  factory ConfirmOrderPaymentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmOrderPaymentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfirmOrderPaymentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ConfirmOrderPaymentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmOrderPaymentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmOrderPaymentRequest copyWith(
          void Function(ConfirmOrderPaymentRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ConfirmOrderPaymentRequest))
          as ConfirmOrderPaymentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ConfirmOrderPaymentRequest() / ConfirmOrderPaymentRequest.new instead')
  static ConfirmOrderPaymentRequest create() => ConfirmOrderPaymentRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ConfirmOrderPaymentRequest._();
  @$core.override
  ConfirmOrderPaymentRequest createEmptyInstance() =>
      ConfirmOrderPaymentRequest._();
  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfirmOrderPaymentRequest>(
          ConfirmOrderPaymentRequest.$_createMessage);
  static ConfirmOrderPaymentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);
}

class ConfirmOrderPaymentResponse extends $pb.GeneratedMessage {
  factory ConfirmOrderPaymentResponse({
    Order? order,
  }) {
    final result = ConfirmOrderPaymentResponse._();
    if (order != null) result.order = order;
    return result;
  }

  ConfirmOrderPaymentResponse._();

  factory ConfirmOrderPaymentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmOrderPaymentResponse()..mergeFromBuffer(data, registry);
  factory ConfirmOrderPaymentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmOrderPaymentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfirmOrderPaymentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ConfirmOrderPaymentResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmOrderPaymentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmOrderPaymentResponse copyWith(
          void Function(ConfirmOrderPaymentResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ConfirmOrderPaymentResponse))
          as ConfirmOrderPaymentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ConfirmOrderPaymentResponse() / ConfirmOrderPaymentResponse.new instead')
  static ConfirmOrderPaymentResponse create() =>
      ConfirmOrderPaymentResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ConfirmOrderPaymentResponse._();
  @$core.override
  ConfirmOrderPaymentResponse createEmptyInstance() =>
      ConfirmOrderPaymentResponse._();
  @$core.pragma('dart2js:noInline')
  static ConfirmOrderPaymentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfirmOrderPaymentResponse>(
          ConfirmOrderPaymentResponse.$_createMessage);
  static ConfirmOrderPaymentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class CancelOrderRequest extends $pb.GeneratedMessage {
  factory CancelOrderRequest({
    $core.String? orderId,
    $core.String? reason,
  }) {
    final result = CancelOrderRequest._();
    if (orderId != null) result.orderId = orderId;
    if (reason != null) result.reason = reason;
    return result;
  }

  CancelOrderRequest._();

  factory CancelOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelOrderRequest()..mergeFromBuffer(data, registry);
  factory CancelOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelOrderRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelOrderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CancelOrderRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelOrderRequest copyWith(void Function(CancelOrderRequest) updates) =>
      super.copyWith((message) => updates(message as CancelOrderRequest))
          as CancelOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelOrderRequest() / CancelOrderRequest.new instead')
  static CancelOrderRequest create() => CancelOrderRequest._();
  static $pb.GeneratedMessage $_createMessage() => CancelOrderRequest._();
  @$core.override
  CancelOrderRequest createEmptyInstance() => CancelOrderRequest._();
  @$core.pragma('dart2js:noInline')
  static CancelOrderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelOrderRequest>(
          CancelOrderRequest.$_createMessage);
  static CancelOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class CancelOrderResponse extends $pb.GeneratedMessage {
  factory CancelOrderResponse({
    Order? order,
  }) {
    final result = CancelOrderResponse._();
    if (order != null) result.order = order;
    return result;
  }

  CancelOrderResponse._();

  factory CancelOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelOrderResponse()..mergeFromBuffer(data, registry);
  factory CancelOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelOrderResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelOrderResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CancelOrderResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelOrderResponse copyWith(void Function(CancelOrderResponse) updates) =>
      super.copyWith((message) => updates(message as CancelOrderResponse))
          as CancelOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CancelOrderResponse() / CancelOrderResponse.new instead')
  static CancelOrderResponse create() => CancelOrderResponse._();
  static $pb.GeneratedMessage $_createMessage() => CancelOrderResponse._();
  @$core.override
  CancelOrderResponse createEmptyInstance() => CancelOrderResponse._();
  @$core.pragma('dart2js:noInline')
  static CancelOrderResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelOrderResponse>(
          CancelOrderResponse.$_createMessage);
  static CancelOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class RecordOrderPaymentRequest extends $pb.GeneratedMessage {
  factory RecordOrderPaymentRequest({
    $core.String? orderId,
    $4.Money? amount,
    $core.String? reference,
    $core.String? note,
  }) {
    final result = RecordOrderPaymentRequest._();
    if (orderId != null) result.orderId = orderId;
    if (amount != null) result.amount = amount;
    if (reference != null) result.reference = reference;
    if (note != null) result.note = note;
    return result;
  }

  RecordOrderPaymentRequest._();

  factory RecordOrderPaymentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecordOrderPaymentRequest()..mergeFromBuffer(data, registry);
  factory RecordOrderPaymentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecordOrderPaymentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordOrderPaymentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RecordOrderPaymentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOM<$4.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $4.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'reference')
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordOrderPaymentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordOrderPaymentRequest copyWith(
          void Function(RecordOrderPaymentRequest) updates) =>
      super.copyWith((message) => updates(message as RecordOrderPaymentRequest))
          as RecordOrderPaymentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecordOrderPaymentRequest() / RecordOrderPaymentRequest.new instead')
  static RecordOrderPaymentRequest create() => RecordOrderPaymentRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      RecordOrderPaymentRequest._();
  @$core.override
  RecordOrderPaymentRequest createEmptyInstance() =>
      RecordOrderPaymentRequest._();
  @$core.pragma('dart2js:noInline')
  static RecordOrderPaymentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordOrderPaymentRequest>(
          RecordOrderPaymentRequest.$_createMessage);
  static RecordOrderPaymentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $4.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($4.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.Money ensureAmount() => $_ensure(1);

  /// The shop's receipt or transaction reference; unique per order.
  @$pb.TagNumber(3)
  $core.String get reference => $_getSZ(2);
  @$pb.TagNumber(3)
  set reference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);
}

class RecordOrderPaymentResponse extends $pb.GeneratedMessage {
  factory RecordOrderPaymentResponse({
    Order? order,
  }) {
    final result = RecordOrderPaymentResponse._();
    if (order != null) result.order = order;
    return result;
  }

  RecordOrderPaymentResponse._();

  factory RecordOrderPaymentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecordOrderPaymentResponse()..mergeFromBuffer(data, registry);
  factory RecordOrderPaymentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecordOrderPaymentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordOrderPaymentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RecordOrderPaymentResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordOrderPaymentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordOrderPaymentResponse copyWith(
          void Function(RecordOrderPaymentResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RecordOrderPaymentResponse))
          as RecordOrderPaymentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecordOrderPaymentResponse() / RecordOrderPaymentResponse.new instead')
  static RecordOrderPaymentResponse create() => RecordOrderPaymentResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      RecordOrderPaymentResponse._();
  @$core.override
  RecordOrderPaymentResponse createEmptyInstance() =>
      RecordOrderPaymentResponse._();
  @$core.pragma('dart2js:noInline')
  static RecordOrderPaymentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordOrderPaymentResponse>(
          RecordOrderPaymentResponse.$_createMessage);
  static RecordOrderPaymentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class ResolveOrderRefundRequest extends $pb.GeneratedMessage {
  factory ResolveOrderRefundRequest({
    $core.String? orderId,
    $core.String? refundId,
    OrderRefundResolution? resolution,
    $core.String? note,
  }) {
    final result = ResolveOrderRefundRequest._();
    if (orderId != null) result.orderId = orderId;
    if (refundId != null) result.refundId = refundId;
    if (resolution != null) result.resolution = resolution;
    if (note != null) result.note = note;
    return result;
  }

  ResolveOrderRefundRequest._();

  factory ResolveOrderRefundRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveOrderRefundRequest()..mergeFromBuffer(data, registry);
  factory ResolveOrderRefundRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveOrderRefundRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveOrderRefundRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolveOrderRefundRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..aOS(2, _omitFieldNames ? '' : 'refundId')
    ..aE<OrderRefundResolution>(3, _omitFieldNames ? '' : 'resolution',
        enumValues: OrderRefundResolution.values)
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveOrderRefundRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveOrderRefundRequest copyWith(
          void Function(ResolveOrderRefundRequest) updates) =>
      super.copyWith((message) => updates(message as ResolveOrderRefundRequest))
          as ResolveOrderRefundRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ResolveOrderRefundRequest() / ResolveOrderRefundRequest.new instead')
  static ResolveOrderRefundRequest create() => ResolveOrderRefundRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ResolveOrderRefundRequest._();
  @$core.override
  ResolveOrderRefundRequest createEmptyInstance() =>
      ResolveOrderRefundRequest._();
  @$core.pragma('dart2js:noInline')
  static ResolveOrderRefundRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveOrderRefundRequest>(
          ResolveOrderRefundRequest.$_createMessage);
  static ResolveOrderRefundRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get refundId => $_getSZ(1);
  @$pb.TagNumber(2)
  set refundId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRefundId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRefundId() => $_clearField(2);

  @$pb.TagNumber(3)
  OrderRefundResolution get resolution => $_getN(2);
  @$pb.TagNumber(3)
  set resolution(OrderRefundResolution value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResolution() => $_has(2);
  @$pb.TagNumber(3)
  void clearResolution() => $_clearField(3);

  /// How the buyer was paid back, or why it is sent again.
  @$pb.TagNumber(4)
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);
}

class ResolveOrderRefundResponse extends $pb.GeneratedMessage {
  factory ResolveOrderRefundResponse({
    Order? order,
  }) {
    final result = ResolveOrderRefundResponse._();
    if (order != null) result.order = order;
    return result;
  }

  ResolveOrderRefundResponse._();

  factory ResolveOrderRefundResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveOrderRefundResponse()..mergeFromBuffer(data, registry);
  factory ResolveOrderRefundResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveOrderRefundResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveOrderRefundResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolveOrderRefundResponse.$_createMessage)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order',
        subBuilder: Order.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveOrderRefundResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveOrderRefundResponse copyWith(
          void Function(ResolveOrderRefundResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveOrderRefundResponse))
          as ResolveOrderRefundResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ResolveOrderRefundResponse() / ResolveOrderRefundResponse.new instead')
  static ResolveOrderRefundResponse create() => ResolveOrderRefundResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ResolveOrderRefundResponse._();
  @$core.override
  ResolveOrderRefundResponse createEmptyInstance() =>
      ResolveOrderRefundResponse._();
  @$core.pragma('dart2js:noInline')
  static ResolveOrderRefundResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveOrderRefundResponse>(
          ResolveOrderRefundResponse.$_createMessage);
  static ResolveOrderRefundResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

/// OrderEvent is a signal raised as an order's payment or lifecycle
/// progresses.
class OrderEvent extends $pb.GeneratedMessage {
  factory OrderEvent({
    $core.String? id,
    $core.String? shopId,
    $core.String? orderId,
    $core.String? orderNumber,
    OrderEventType? type,
    $core.int? thresholdPercent,
    $core.int? paidPercent,
    $4.Money? amountPaid,
    $4.Money? balance,
    $4.Money? paymentAmount,
    $0.Timestamp? createdAt,
    OrderEventDelivery? delivery,
  }) {
    final result = OrderEvent._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (orderId != null) result.orderId = orderId;
    if (orderNumber != null) result.orderNumber = orderNumber;
    if (type != null) result.type = type;
    if (thresholdPercent != null) result.thresholdPercent = thresholdPercent;
    if (paidPercent != null) result.paidPercent = paidPercent;
    if (amountPaid != null) result.amountPaid = amountPaid;
    if (balance != null) result.balance = balance;
    if (paymentAmount != null) result.paymentAmount = paymentAmount;
    if (createdAt != null) result.createdAt = createdAt;
    if (delivery != null) result.delivery = delivery;
    return result;
  }

  OrderEvent._();

  factory OrderEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderEvent()..mergeFromBuffer(data, registry);
  factory OrderEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrderEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrderEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: OrderEvent.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'orderId')
    ..aOS(4, _omitFieldNames ? '' : 'orderNumber')
    ..aE<OrderEventType>(5, _omitFieldNames ? '' : 'type',
        enumValues: OrderEventType.values)
    ..aI(6, _omitFieldNames ? '' : 'thresholdPercent')
    ..aI(7, _omitFieldNames ? '' : 'paidPercent')
    ..aOM<$4.Money>(8, _omitFieldNames ? '' : 'amountPaid',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$4.Money>(9, _omitFieldNames ? '' : 'balance',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$4.Money>(10, _omitFieldNames ? '' : 'paymentAmount',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<OrderEventDelivery>(12, _omitFieldNames ? '' : 'delivery',
        enumValues: OrderEventDelivery.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrderEvent copyWith(void Function(OrderEvent) updates) =>
      super.copyWith((message) => updates(message as OrderEvent)) as OrderEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrderEvent() / OrderEvent.new instead')
  static OrderEvent create() => OrderEvent._();
  static $pb.GeneratedMessage $_createMessage() => OrderEvent._();
  @$core.override
  OrderEvent createEmptyInstance() => OrderEvent._();
  @$core.pragma('dart2js:noInline')
  static OrderEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrderEvent>(OrderEvent.$_createMessage);
  static OrderEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orderId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orderId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orderNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set orderNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrderNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  OrderEventType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(OrderEventType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  /// For THRESHOLD_CROSSED, the policy mark that was crossed.
  @$pb.TagNumber(6)
  $core.int get thresholdPercent => $_getIZ(5);
  @$pb.TagNumber(6)
  set thresholdPercent($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasThresholdPercent() => $_has(5);
  @$pb.TagNumber(6)
  void clearThresholdPercent() => $_clearField(6);

  /// Share of the total paid when the event was raised.
  @$pb.TagNumber(7)
  $core.int get paidPercent => $_getIZ(6);
  @$pb.TagNumber(7)
  set paidPercent($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPaidPercent() => $_has(6);
  @$pb.TagNumber(7)
  void clearPaidPercent() => $_clearField(7);

  @$pb.TagNumber(8)
  $4.Money get amountPaid => $_getN(7);
  @$pb.TagNumber(8)
  set amountPaid($4.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAmountPaid() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmountPaid() => $_clearField(8);
  @$pb.TagNumber(8)
  $4.Money ensureAmountPaid() => $_ensure(7);

  @$pb.TagNumber(9)
  $4.Money get balance => $_getN(8);
  @$pb.TagNumber(9)
  set balance($4.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBalance() => $_has(8);
  @$pb.TagNumber(9)
  void clearBalance() => $_clearField(9);
  @$pb.TagNumber(9)
  $4.Money ensureBalance() => $_ensure(8);

  /// The instalment that caused the event, for payment events.
  @$pb.TagNumber(10)
  $4.Money get paymentAmount => $_getN(9);
  @$pb.TagNumber(10)
  set paymentAmount($4.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPaymentAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearPaymentAmount() => $_clearField(10);
  @$pb.TagNumber(10)
  $4.Money ensurePaymentAmount() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);

  /// Webhook delivery state for this event.
  @$pb.TagNumber(12)
  OrderEventDelivery get delivery => $_getN(11);
  @$pb.TagNumber(12)
  set delivery(OrderEventDelivery value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasDelivery() => $_has(11);
  @$pb.TagNumber(12)
  void clearDelivery() => $_clearField(12);
}

class ListOrderEventsRequest extends $pb.GeneratedMessage {
  factory ListOrderEventsRequest({
    $core.String? shopId,
    $core.String? orderId,
    $3.SearchRequest? search,
  }) {
    final result = ListOrderEventsRequest._();
    if (shopId != null) result.shopId = shopId;
    if (orderId != null) result.orderId = orderId;
    if (search != null) result.search = search;
    return result;
  }

  ListOrderEventsRequest._();

  factory ListOrderEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrderEventsRequest()..mergeFromBuffer(data, registry);
  factory ListOrderEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrderEventsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrderEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListOrderEventsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'orderId')
    ..aOM<$3.SearchRequest>(3, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrderEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrderEventsRequest copyWith(
          void Function(ListOrderEventsRequest) updates) =>
      super.copyWith((message) => updates(message as ListOrderEventsRequest))
          as ListOrderEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListOrderEventsRequest() / ListOrderEventsRequest.new instead')
  static ListOrderEventsRequest create() => ListOrderEventsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListOrderEventsRequest._();
  @$core.override
  ListOrderEventsRequest createEmptyInstance() => ListOrderEventsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListOrderEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrderEventsRequest>(
          ListOrderEventsRequest.$_createMessage);
  static ListOrderEventsRequest? _defaultInstance;

  /// One of shop_id or order_id is required.
  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get orderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set orderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderId() => $_clearField(2);

  /// Page size and cursor.
  @$pb.TagNumber(3)
  $3.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($3.SearchRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.SearchRequest ensureSearch() => $_ensure(2);
}

class ListOrderEventsResponse extends $pb.GeneratedMessage {
  factory ListOrderEventsResponse({
    $core.Iterable<OrderEvent>? events,
    $core.String? nextPage,
  }) {
    final result = ListOrderEventsResponse._();
    if (events != null) result.events.addAll(events);
    if (nextPage != null) result.nextPage = nextPage;
    return result;
  }

  ListOrderEventsResponse._();

  factory ListOrderEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrderEventsResponse()..mergeFromBuffer(data, registry);
  factory ListOrderEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOrderEventsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrderEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListOrderEventsResponse.$_createMessage)
    ..pPM<OrderEvent>(1, _omitFieldNames ? '' : 'events',
        subBuilder: OrderEvent.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrderEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrderEventsResponse copyWith(
          void Function(ListOrderEventsResponse) updates) =>
      super.copyWith((message) => updates(message as ListOrderEventsResponse))
          as ListOrderEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListOrderEventsResponse() / ListOrderEventsResponse.new instead')
  static ListOrderEventsResponse create() => ListOrderEventsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListOrderEventsResponse._();
  @$core.override
  ListOrderEventsResponse createEmptyInstance() => ListOrderEventsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListOrderEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrderEventsResponse>(
          ListOrderEventsResponse.$_createMessage);
  static ListOrderEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OrderEvent> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);
}

class ReconcilePaymentsRequest extends $pb.GeneratedMessage {
  factory ReconcilePaymentsRequest({
    $core.String? shopId,
    $core.int? limit,
  }) {
    final result = ReconcilePaymentsRequest._();
    if (shopId != null) result.shopId = shopId;
    if (limit != null) result.limit = limit;
    return result;
  }

  ReconcilePaymentsRequest._();

  factory ReconcilePaymentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconcilePaymentsRequest()..mergeFromBuffer(data, registry);
  factory ReconcilePaymentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconcilePaymentsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconcilePaymentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ReconcilePaymentsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconcilePaymentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconcilePaymentsRequest copyWith(
          void Function(ReconcilePaymentsRequest) updates) =>
      super.copyWith((message) => updates(message as ReconcilePaymentsRequest))
          as ReconcilePaymentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconcilePaymentsRequest() / ReconcilePaymentsRequest.new instead')
  static ReconcilePaymentsRequest create() => ReconcilePaymentsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReconcilePaymentsRequest._();
  @$core.override
  ReconcilePaymentsRequest createEmptyInstance() =>
      ReconcilePaymentsRequest._();
  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconcilePaymentsRequest>(
          ReconcilePaymentsRequest.$_createMessage);
  static ReconcilePaymentsRequest? _defaultInstance;

  /// Limit to one shop; empty reconciles every shop in the partition.
  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  /// Maximum orders to examine in this run.
  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class ReconcilePaymentsResponse extends $pb.GeneratedMessage {
  factory ReconcilePaymentsResponse({
    $core.int? examined,
    $core.int? paid,
    $core.int? expired,
    $core.int? failed,
    $core.int? overdue,
    $core.int? eventsDelivered,
    $core.int? refundsSent,
    $core.int? refundsConfirmed,
  }) {
    final result = ReconcilePaymentsResponse._();
    if (examined != null) result.examined = examined;
    if (paid != null) result.paid = paid;
    if (expired != null) result.expired = expired;
    if (failed != null) result.failed = failed;
    if (overdue != null) result.overdue = overdue;
    if (eventsDelivered != null) result.eventsDelivered = eventsDelivered;
    if (refundsSent != null) result.refundsSent = refundsSent;
    if (refundsConfirmed != null) result.refundsConfirmed = refundsConfirmed;
    return result;
  }

  ReconcilePaymentsResponse._();

  factory ReconcilePaymentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconcilePaymentsResponse()..mergeFromBuffer(data, registry);
  factory ReconcilePaymentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconcilePaymentsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconcilePaymentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ReconcilePaymentsResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'examined')
    ..aI(2, _omitFieldNames ? '' : 'paid')
    ..aI(3, _omitFieldNames ? '' : 'expired')
    ..aI(4, _omitFieldNames ? '' : 'failed')
    ..aI(5, _omitFieldNames ? '' : 'overdue')
    ..aI(6, _omitFieldNames ? '' : 'eventsDelivered')
    ..aI(7, _omitFieldNames ? '' : 'refundsSent')
    ..aI(8, _omitFieldNames ? '' : 'refundsConfirmed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconcilePaymentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconcilePaymentsResponse copyWith(
          void Function(ReconcilePaymentsResponse) updates) =>
      super.copyWith((message) => updates(message as ReconcilePaymentsResponse))
          as ReconcilePaymentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconcilePaymentsResponse() / ReconcilePaymentsResponse.new instead')
  static ReconcilePaymentsResponse create() => ReconcilePaymentsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReconcilePaymentsResponse._();
  @$core.override
  ReconcilePaymentsResponse createEmptyInstance() =>
      ReconcilePaymentsResponse._();
  @$core.pragma('dart2js:noInline')
  static ReconcilePaymentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconcilePaymentsResponse>(
          ReconcilePaymentsResponse.$_createMessage);
  static ReconcilePaymentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get examined => $_getIZ(0);
  @$pb.TagNumber(1)
  set examined($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExamined() => $_has(0);
  @$pb.TagNumber(1)
  void clearExamined() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get paid => $_getIZ(1);
  @$pb.TagNumber(2)
  set paid($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPaid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expired => $_getIZ(2);
  @$pb.TagNumber(3)
  set expired($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpired() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpired() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get failed => $_getIZ(3);
  @$pb.TagNumber(4)
  set failed($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFailed() => $_has(3);
  @$pb.TagNumber(4)
  void clearFailed() => $_clearField(4);

  /// Part-paid orders flagged past their balance deadline.
  @$pb.TagNumber(5)
  $core.int get overdue => $_getIZ(4);
  @$pb.TagNumber(5)
  set overdue($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOverdue() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverdue() => $_clearField(5);

  /// Webhook deliveries that succeeded on retry.
  @$pb.TagNumber(6)
  $core.int get eventsDelivered => $_getIZ(5);
  @$pb.TagNumber(6)
  set eventsDelivered($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEventsDelivered() => $_has(5);
  @$pb.TagNumber(6)
  void clearEventsDelivered() => $_clearField(6);

  /// Refunds handed to the payment service in this run.
  @$pb.TagNumber(7)
  $core.int get refundsSent => $_getIZ(6);
  @$pb.TagNumber(7)
  set refundsSent($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRefundsSent() => $_has(6);
  @$pb.TagNumber(7)
  void clearRefundsSent() => $_clearField(7);

  /// Refunds the payment service confirmed in this run.
  @$pb.TagNumber(8)
  $core.int get refundsConfirmed => $_getIZ(7);
  @$pb.TagNumber(8)
  set refundsConfirmed($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRefundsConfirmed() => $_has(7);
  @$pb.TagNumber(8)
  void clearRefundsConfirmed() => $_clearField(8);
}

class RunEndOfDayLedgerRequest extends $pb.GeneratedMessage {
  factory RunEndOfDayLedgerRequest({
    $core.String? shopId,
    $core.String? date,
  }) {
    final result = RunEndOfDayLedgerRequest._();
    if (shopId != null) result.shopId = shopId;
    if (date != null) result.date = date;
    return result;
  }

  RunEndOfDayLedgerRequest._();

  factory RunEndOfDayLedgerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunEndOfDayLedgerRequest()..mergeFromBuffer(data, registry);
  factory RunEndOfDayLedgerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunEndOfDayLedgerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RunEndOfDayLedgerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RunEndOfDayLedgerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunEndOfDayLedgerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunEndOfDayLedgerRequest copyWith(
          void Function(RunEndOfDayLedgerRequest) updates) =>
      super.copyWith((message) => updates(message as RunEndOfDayLedgerRequest))
          as RunEndOfDayLedgerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RunEndOfDayLedgerRequest() / RunEndOfDayLedgerRequest.new instead')
  static RunEndOfDayLedgerRequest create() => RunEndOfDayLedgerRequest._();
  static $pb.GeneratedMessage $_createMessage() => RunEndOfDayLedgerRequest._();
  @$core.override
  RunEndOfDayLedgerRequest createEmptyInstance() =>
      RunEndOfDayLedgerRequest._();
  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RunEndOfDayLedgerRequest>(
          RunEndOfDayLedgerRequest.$_createMessage);
  static RunEndOfDayLedgerRequest? _defaultInstance;

  /// Limit to one shop; empty runs every shop in the partition.
  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  /// Trading day in YYYY-MM-DD, interpreted in the shop's timezone. Empty
  /// means the previous calendar day.
  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);
}

class LedgerPosting extends $pb.GeneratedMessage {
  factory LedgerPosting({
    $core.String? shopId,
    $core.String? date,
    $core.String? transactionId,
    $4.Money? sales,
    $4.Money? refunds,
    $core.int? orders,
    $core.bool? skipped,
    $core.String? error,
  }) {
    final result = LedgerPosting._();
    if (shopId != null) result.shopId = shopId;
    if (date != null) result.date = date;
    if (transactionId != null) result.transactionId = transactionId;
    if (sales != null) result.sales = sales;
    if (refunds != null) result.refunds = refunds;
    if (orders != null) result.orders = orders;
    if (skipped != null) result.skipped = skipped;
    if (error != null) result.error = error;
    return result;
  }

  LedgerPosting._();

  factory LedgerPosting.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerPosting()..mergeFromBuffer(data, registry);
  factory LedgerPosting.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerPosting()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerPosting',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: LedgerPosting.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..aOS(3, _omitFieldNames ? '' : 'transactionId')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'sales',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$4.Money>(5, _omitFieldNames ? '' : 'refunds',
        subBuilder: $4.Money.$_createMessage)
    ..aI(6, _omitFieldNames ? '' : 'orders')
    ..aOB(7, _omitFieldNames ? '' : 'skipped')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerPosting clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerPosting copyWith(void Function(LedgerPosting) updates) =>
      super.copyWith((message) => updates(message as LedgerPosting))
          as LedgerPosting;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LedgerPosting() / LedgerPosting.new instead')
  static LedgerPosting create() => LedgerPosting._();
  static $pb.GeneratedMessage $_createMessage() => LedgerPosting._();
  @$core.override
  LedgerPosting createEmptyInstance() => LedgerPosting._();
  @$core.pragma('dart2js:noInline')
  static LedgerPosting getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerPosting>(
          LedgerPosting.$_createMessage);
  static LedgerPosting? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get transactionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set transactionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTransactionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransactionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Money get sales => $_getN(3);
  @$pb.TagNumber(4)
  set sales($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSales() => $_has(3);
  @$pb.TagNumber(4)
  void clearSales() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureSales() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.Money get refunds => $_getN(4);
  @$pb.TagNumber(5)
  set refunds($4.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRefunds() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefunds() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Money ensureRefunds() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get orders => $_getIZ(5);
  @$pb.TagNumber(6)
  set orders($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOrders() => $_has(5);
  @$pb.TagNumber(6)
  void clearOrders() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get skipped => $_getBF(6);
  @$pb.TagNumber(7)
  set skipped($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSkipped() => $_has(6);
  @$pb.TagNumber(7)
  void clearSkipped() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);
}

class RunEndOfDayLedgerResponse extends $pb.GeneratedMessage {
  factory RunEndOfDayLedgerResponse({
    $core.Iterable<LedgerPosting>? postings,
  }) {
    final result = RunEndOfDayLedgerResponse._();
    if (postings != null) result.postings.addAll(postings);
    return result;
  }

  RunEndOfDayLedgerResponse._();

  factory RunEndOfDayLedgerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunEndOfDayLedgerResponse()..mergeFromBuffer(data, registry);
  factory RunEndOfDayLedgerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunEndOfDayLedgerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RunEndOfDayLedgerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: RunEndOfDayLedgerResponse.$_createMessage)
    ..pPM<LedgerPosting>(1, _omitFieldNames ? '' : 'postings',
        subBuilder: LedgerPosting.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunEndOfDayLedgerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunEndOfDayLedgerResponse copyWith(
          void Function(RunEndOfDayLedgerResponse) updates) =>
      super.copyWith((message) => updates(message as RunEndOfDayLedgerResponse))
          as RunEndOfDayLedgerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RunEndOfDayLedgerResponse() / RunEndOfDayLedgerResponse.new instead')
  static RunEndOfDayLedgerResponse create() => RunEndOfDayLedgerResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      RunEndOfDayLedgerResponse._();
  @$core.override
  RunEndOfDayLedgerResponse createEmptyInstance() =>
      RunEndOfDayLedgerResponse._();
  @$core.pragma('dart2js:noInline')
  static RunEndOfDayLedgerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RunEndOfDayLedgerResponse>(
          RunEndOfDayLedgerResponse.$_createMessage);
  static RunEndOfDayLedgerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LedgerPosting> get postings => $_getList(0);
}

class Fulfilment extends $pb.GeneratedMessage {
  factory Fulfilment({
    $core.String? id,
    $core.String? orderId,
    FulfilmentStatus? status,
    $core.String? carrier,
    $core.String? trackingNumber,
    $core.Iterable<FulfilmentLine>? lines,
    $0.Timestamp? createdAt,
    $0.Timestamp? shippedAt,
  }) {
    final result = Fulfilment._();
    if (id != null) result.id = id;
    if (orderId != null) result.orderId = orderId;
    if (status != null) result.status = status;
    if (carrier != null) result.carrier = carrier;
    if (trackingNumber != null) result.trackingNumber = trackingNumber;
    if (lines != null) result.lines.addAll(lines);
    if (createdAt != null) result.createdAt = createdAt;
    if (shippedAt != null) result.shippedAt = shippedAt;
    return result;
  }

  Fulfilment._();

  factory Fulfilment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Fulfilment()..mergeFromBuffer(data, registry);
  factory Fulfilment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Fulfilment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Fulfilment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: Fulfilment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'orderId')
    ..aE<FulfilmentStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: FulfilmentStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'carrier')
    ..aOS(5, _omitFieldNames ? '' : 'trackingNumber')
    ..pPM<FulfilmentLine>(6, _omitFieldNames ? '' : 'lines',
        subBuilder: FulfilmentLine.$_createMessage)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'shippedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Fulfilment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Fulfilment copyWith(void Function(Fulfilment) updates) =>
      super.copyWith((message) => updates(message as Fulfilment)) as Fulfilment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Fulfilment() / Fulfilment.new instead')
  static Fulfilment create() => Fulfilment._();
  static $pb.GeneratedMessage $_createMessage() => Fulfilment._();
  @$core.override
  Fulfilment createEmptyInstance() => Fulfilment._();
  @$core.pragma('dart2js:noInline')
  static Fulfilment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Fulfilment>(Fulfilment.$_createMessage);
  static Fulfilment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get orderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set orderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderId() => $_clearField(2);

  @$pb.TagNumber(3)
  FulfilmentStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FulfilmentStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get carrier => $_getSZ(3);
  @$pb.TagNumber(4)
  set carrier($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCarrier() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarrier() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get trackingNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set trackingNumber($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTrackingNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrackingNumber() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<FulfilmentLine> get lines => $_getList(5);

  @$pb.TagNumber(7)
  $0.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get shippedAt => $_getN(7);
  @$pb.TagNumber(8)
  set shippedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasShippedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearShippedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureShippedAt() => $_ensure(7);
}

class FulfilmentLine extends $pb.GeneratedMessage {
  factory FulfilmentLine({
    $core.String? orderLineId,
    $fixnum.Int64? quantity,
  }) {
    final result = FulfilmentLine._();
    if (orderLineId != null) result.orderLineId = orderLineId;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  FulfilmentLine._();

  factory FulfilmentLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FulfilmentLine()..mergeFromBuffer(data, registry);
  factory FulfilmentLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FulfilmentLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FulfilmentLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: FulfilmentLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderLineId')
    ..aInt64(2, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FulfilmentLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FulfilmentLine copyWith(void Function(FulfilmentLine) updates) =>
      super.copyWith((message) => updates(message as FulfilmentLine))
          as FulfilmentLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FulfilmentLine() / FulfilmentLine.new instead')
  static FulfilmentLine create() => FulfilmentLine._();
  static $pb.GeneratedMessage $_createMessage() => FulfilmentLine._();
  @$core.override
  FulfilmentLine createEmptyInstance() => FulfilmentLine._();
  @$core.pragma('dart2js:noInline')
  static FulfilmentLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FulfilmentLine>(
          FulfilmentLine.$_createMessage);
  static FulfilmentLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderLineId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderLineId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderLineId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderLineId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quantity => $_getI64(1);
  @$pb.TagNumber(2)
  set quantity($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => $_clearField(2);
}

class CreateFulfilmentRequest extends $pb.GeneratedMessage {
  factory CreateFulfilmentRequest({
    $core.String? orderId,
    $core.Iterable<FulfilmentLine>? lines,
  }) {
    final result = CreateFulfilmentRequest._();
    if (orderId != null) result.orderId = orderId;
    if (lines != null) result.lines.addAll(lines);
    return result;
  }

  CreateFulfilmentRequest._();

  factory CreateFulfilmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateFulfilmentRequest()..mergeFromBuffer(data, registry);
  factory CreateFulfilmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateFulfilmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFulfilmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateFulfilmentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..pPM<FulfilmentLine>(2, _omitFieldNames ? '' : 'lines',
        subBuilder: FulfilmentLine.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFulfilmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFulfilmentRequest copyWith(
          void Function(CreateFulfilmentRequest) updates) =>
      super.copyWith((message) => updates(message as CreateFulfilmentRequest))
          as CreateFulfilmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateFulfilmentRequest() / CreateFulfilmentRequest.new instead')
  static CreateFulfilmentRequest create() => CreateFulfilmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateFulfilmentRequest._();
  @$core.override
  CreateFulfilmentRequest createEmptyInstance() => CreateFulfilmentRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFulfilmentRequest>(
          CreateFulfilmentRequest.$_createMessage);
  static CreateFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<FulfilmentLine> get lines => $_getList(1);
}

class CreateFulfilmentResponse extends $pb.GeneratedMessage {
  factory CreateFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final result = CreateFulfilmentResponse._();
    if (fulfilment != null) result.fulfilment = fulfilment;
    return result;
  }

  CreateFulfilmentResponse._();

  factory CreateFulfilmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateFulfilmentResponse()..mergeFromBuffer(data, registry);
  factory CreateFulfilmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateFulfilmentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFulfilmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CreateFulfilmentResponse.$_createMessage)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment',
        subBuilder: Fulfilment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFulfilmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFulfilmentResponse copyWith(
          void Function(CreateFulfilmentResponse) updates) =>
      super.copyWith((message) => updates(message as CreateFulfilmentResponse))
          as CreateFulfilmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateFulfilmentResponse() / CreateFulfilmentResponse.new instead')
  static CreateFulfilmentResponse create() => CreateFulfilmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateFulfilmentResponse._();
  @$core.override
  CreateFulfilmentResponse createEmptyInstance() =>
      CreateFulfilmentResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateFulfilmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFulfilmentResponse>(
          CreateFulfilmentResponse.$_createMessage);
  static CreateFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => $_clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

class UpdateFulfilmentRequest extends $pb.GeneratedMessage {
  factory UpdateFulfilmentRequest({
    $core.String? id,
    $2.FieldMask? updateMask,
    FulfilmentStatus? status,
    $core.String? carrier,
    $core.String? trackingNumber,
    $0.Timestamp? shippedAt,
  }) {
    final result = UpdateFulfilmentRequest._();
    if (id != null) result.id = id;
    if (updateMask != null) result.updateMask = updateMask;
    if (status != null) result.status = status;
    if (carrier != null) result.carrier = carrier;
    if (trackingNumber != null) result.trackingNumber = trackingNumber;
    if (shippedAt != null) result.shippedAt = shippedAt;
    return result;
  }

  UpdateFulfilmentRequest._();

  factory UpdateFulfilmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFulfilmentRequest()..mergeFromBuffer(data, registry);
  factory UpdateFulfilmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFulfilmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFulfilmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateFulfilmentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$2.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $2.FieldMask.$_createMessage)
    ..aE<FulfilmentStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: FulfilmentStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'carrier')
    ..aOS(5, _omitFieldNames ? '' : 'trackingNumber')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'shippedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFulfilmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFulfilmentRequest copyWith(
          void Function(UpdateFulfilmentRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateFulfilmentRequest))
          as UpdateFulfilmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateFulfilmentRequest() / UpdateFulfilmentRequest.new instead')
  static UpdateFulfilmentRequest create() => UpdateFulfilmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateFulfilmentRequest._();
  @$core.override
  UpdateFulfilmentRequest createEmptyInstance() => UpdateFulfilmentRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFulfilmentRequest>(
          UpdateFulfilmentRequest.$_createMessage);
  static UpdateFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($2.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  FulfilmentStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FulfilmentStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get carrier => $_getSZ(3);
  @$pb.TagNumber(4)
  set carrier($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCarrier() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarrier() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get trackingNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set trackingNumber($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTrackingNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrackingNumber() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get shippedAt => $_getN(5);
  @$pb.TagNumber(6)
  set shippedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasShippedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearShippedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureShippedAt() => $_ensure(5);
}

class UpdateFulfilmentResponse extends $pb.GeneratedMessage {
  factory UpdateFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final result = UpdateFulfilmentResponse._();
    if (fulfilment != null) result.fulfilment = fulfilment;
    return result;
  }

  UpdateFulfilmentResponse._();

  factory UpdateFulfilmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFulfilmentResponse()..mergeFromBuffer(data, registry);
  factory UpdateFulfilmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFulfilmentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFulfilmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: UpdateFulfilmentResponse.$_createMessage)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment',
        subBuilder: Fulfilment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFulfilmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFulfilmentResponse copyWith(
          void Function(UpdateFulfilmentResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateFulfilmentResponse))
          as UpdateFulfilmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateFulfilmentResponse() / UpdateFulfilmentResponse.new instead')
  static UpdateFulfilmentResponse create() => UpdateFulfilmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateFulfilmentResponse._();
  @$core.override
  UpdateFulfilmentResponse createEmptyInstance() =>
      UpdateFulfilmentResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateFulfilmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFulfilmentResponse>(
          UpdateFulfilmentResponse.$_createMessage);
  static UpdateFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => $_clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

class GetFulfilmentRequest extends $pb.GeneratedMessage {
  factory GetFulfilmentRequest({
    $core.String? id,
  }) {
    final result = GetFulfilmentRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetFulfilmentRequest._();

  factory GetFulfilmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFulfilmentRequest()..mergeFromBuffer(data, registry);
  factory GetFulfilmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFulfilmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFulfilmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetFulfilmentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFulfilmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFulfilmentRequest copyWith(void Function(GetFulfilmentRequest) updates) =>
      super.copyWith((message) => updates(message as GetFulfilmentRequest))
          as GetFulfilmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetFulfilmentRequest() / GetFulfilmentRequest.new instead')
  static GetFulfilmentRequest create() => GetFulfilmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetFulfilmentRequest._();
  @$core.override
  GetFulfilmentRequest createEmptyInstance() => GetFulfilmentRequest._();
  @$core.pragma('dart2js:noInline')
  static GetFulfilmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFulfilmentRequest>(
          GetFulfilmentRequest.$_createMessage);
  static GetFulfilmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFulfilmentResponse extends $pb.GeneratedMessage {
  factory GetFulfilmentResponse({
    Fulfilment? fulfilment,
  }) {
    final result = GetFulfilmentResponse._();
    if (fulfilment != null) result.fulfilment = fulfilment;
    return result;
  }

  GetFulfilmentResponse._();

  factory GetFulfilmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFulfilmentResponse()..mergeFromBuffer(data, registry);
  factory GetFulfilmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFulfilmentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFulfilmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: GetFulfilmentResponse.$_createMessage)
    ..aOM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilment',
        subBuilder: Fulfilment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFulfilmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFulfilmentResponse copyWith(
          void Function(GetFulfilmentResponse) updates) =>
      super.copyWith((message) => updates(message as GetFulfilmentResponse))
          as GetFulfilmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetFulfilmentResponse() / GetFulfilmentResponse.new instead')
  static GetFulfilmentResponse create() => GetFulfilmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetFulfilmentResponse._();
  @$core.override
  GetFulfilmentResponse createEmptyInstance() => GetFulfilmentResponse._();
  @$core.pragma('dart2js:noInline')
  static GetFulfilmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFulfilmentResponse>(
          GetFulfilmentResponse.$_createMessage);
  static GetFulfilmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Fulfilment get fulfilment => $_getN(0);
  @$pb.TagNumber(1)
  set fulfilment(Fulfilment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFulfilment() => $_has(0);
  @$pb.TagNumber(1)
  void clearFulfilment() => $_clearField(1);
  @$pb.TagNumber(1)
  Fulfilment ensureFulfilment() => $_ensure(0);
}

class ListFulfilmentsRequest extends $pb.GeneratedMessage {
  factory ListFulfilmentsRequest({
    $core.String? orderId,
  }) {
    final result = ListFulfilmentsRequest._();
    if (orderId != null) result.orderId = orderId;
    return result;
  }

  ListFulfilmentsRequest._();

  factory ListFulfilmentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFulfilmentsRequest()..mergeFromBuffer(data, registry);
  factory ListFulfilmentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFulfilmentsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFulfilmentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListFulfilmentsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'orderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFulfilmentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFulfilmentsRequest copyWith(
          void Function(ListFulfilmentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFulfilmentsRequest))
          as ListFulfilmentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListFulfilmentsRequest() / ListFulfilmentsRequest.new instead')
  static ListFulfilmentsRequest create() => ListFulfilmentsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListFulfilmentsRequest._();
  @$core.override
  ListFulfilmentsRequest createEmptyInstance() => ListFulfilmentsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListFulfilmentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFulfilmentsRequest>(
          ListFulfilmentsRequest.$_createMessage);
  static ListFulfilmentsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);
}

class ListFulfilmentsResponse extends $pb.GeneratedMessage {
  factory ListFulfilmentsResponse({
    $core.Iterable<Fulfilment>? fulfilments,
  }) {
    final result = ListFulfilmentsResponse._();
    if (fulfilments != null) result.fulfilments.addAll(fulfilments);
    return result;
  }

  ListFulfilmentsResponse._();

  factory ListFulfilmentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFulfilmentsResponse()..mergeFromBuffer(data, registry);
  factory ListFulfilmentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFulfilmentsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFulfilmentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ListFulfilmentsResponse.$_createMessage)
    ..pPM<Fulfilment>(1, _omitFieldNames ? '' : 'fulfilments',
        subBuilder: Fulfilment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFulfilmentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFulfilmentsResponse copyWith(
          void Function(ListFulfilmentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListFulfilmentsResponse))
          as ListFulfilmentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListFulfilmentsResponse() / ListFulfilmentsResponse.new instead')
  static ListFulfilmentsResponse create() => ListFulfilmentsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListFulfilmentsResponse._();
  @$core.override
  ListFulfilmentsResponse createEmptyInstance() => ListFulfilmentsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListFulfilmentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFulfilmentsResponse>(
          ListFulfilmentsResponse.$_createMessage);
  static ListFulfilmentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Fulfilment> get fulfilments => $_getList(0);
}

/// A named collection of prices for product variants, scoped to a shop and currency.
class PriceList extends $pb.GeneratedMessage {
  factory PriceList({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? currency,
    $core.int? priority,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    PriceListStatus? status,
    $0.Timestamp? createdAt,
  }) {
    final result = PriceList._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (currency != null) result.currency = currency;
    if (priority != null) result.priority = priority;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  PriceList._();

  factory PriceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceList()..mergeFromBuffer(data, registry);
  factory PriceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceList.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aI(5, _omitFieldNames ? '' : 'priority')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<PriceListStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: PriceListStatus.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceList copyWith(void Function(PriceList) updates) =>
      super.copyWith((message) => updates(message as PriceList)) as PriceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PriceList() / PriceList.new instead')
  static PriceList create() => PriceList._();
  static $pb.GeneratedMessage $_createMessage() => PriceList._();
  @$core.override
  PriceList createEmptyInstance() => PriceList._();
  @$core.pragma('dart2js:noInline')
  static PriceList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceList>(PriceList.$_createMessage);
  static PriceList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get priority => $_getIZ(4);
  @$pb.TagNumber(5)
  set priority($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get validFrom => $_getN(5);
  @$pb.TagNumber(6)
  set validFrom($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasValidFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidFrom() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureValidFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get validUntil => $_getN(6);
  @$pb.TagNumber(7)
  set validUntil($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasValidUntil() => $_has(6);
  @$pb.TagNumber(7)
  void clearValidUntil() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureValidUntil() => $_ensure(6);

  @$pb.TagNumber(8)
  PriceListStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(PriceListStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);
}

/// A single price entry within a price list, optionally quantity-tiered.
class PriceListEntry extends $pb.GeneratedMessage {
  factory PriceListEntry({
    $core.String? id,
    $core.String? priceListId,
    $core.String? productVariantId,
    $4.Money? unitPrice,
    $core.int? minQuantity,
    $core.int? maxQuantity,
  }) {
    final result = PriceListEntry._();
    if (id != null) result.id = id;
    if (priceListId != null) result.priceListId = priceListId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (minQuantity != null) result.minQuantity = minQuantity;
    if (maxQuantity != null) result.maxQuantity = maxQuantity;
    return result;
  }

  PriceListEntry._();

  factory PriceListEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntry()..mergeFromBuffer(data, registry);
  factory PriceListEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'priceListId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $4.Money.$_createMessage)
    ..aI(5, _omitFieldNames ? '' : 'minQuantity')
    ..aI(6, _omitFieldNames ? '' : 'maxQuantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntry copyWith(void Function(PriceListEntry) updates) =>
      super.copyWith((message) => updates(message as PriceListEntry))
          as PriceListEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PriceListEntry() / PriceListEntry.new instead')
  static PriceListEntry create() => PriceListEntry._();
  static $pb.GeneratedMessage $_createMessage() => PriceListEntry._();
  @$core.override
  PriceListEntry createEmptyInstance() => PriceListEntry._();
  @$core.pragma('dart2js:noInline')
  static PriceListEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PriceListEntry>(
          PriceListEntry.$_createMessage);
  static PriceListEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get priceListId => $_getSZ(1);
  @$pb.TagNumber(2)
  set priceListId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPriceListId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPriceListId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get minQuantity => $_getIZ(4);
  @$pb.TagNumber(5)
  set minQuantity($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinQuantity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxQuantity => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxQuantity($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxQuantity() => $_clearField(6);
}

/// Links a customer to a price list.
class CustomerPriceListAssignment extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignment({
    $core.String? id,
    $core.String? customerId,
    $core.String? priceListId,
    $core.String? assignedBy,
    CustomerPriceListAssignmentStatus? status,
    $0.Timestamp? createdAt,
  }) {
    final result = CustomerPriceListAssignment._();
    if (id != null) result.id = id;
    if (customerId != null) result.customerId = customerId;
    if (priceListId != null) result.priceListId = priceListId;
    if (assignedBy != null) result.assignedBy = assignedBy;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  CustomerPriceListAssignment._();

  factory CustomerPriceListAssignment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignment()..mergeFromBuffer(data, registry);
  factory CustomerPriceListAssignment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceListAssignment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceListAssignment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'priceListId')
    ..aOS(4, _omitFieldNames ? '' : 'assignedBy')
    ..aE<CustomerPriceListAssignmentStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: CustomerPriceListAssignmentStatus.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignment copyWith(
          void Function(CustomerPriceListAssignment) updates) =>
      super.copyWith(
              (message) => updates(message as CustomerPriceListAssignment))
          as CustomerPriceListAssignment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceListAssignment() / CustomerPriceListAssignment.new instead')
  static CustomerPriceListAssignment create() =>
      CustomerPriceListAssignment._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceListAssignment._();
  @$core.override
  CustomerPriceListAssignment createEmptyInstance() =>
      CustomerPriceListAssignment._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomerPriceListAssignment>(
          CustomerPriceListAssignment.$_createMessage);
  static CustomerPriceListAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get priceListId => $_getSZ(2);
  @$pb.TagNumber(3)
  set priceListId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriceListId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceListId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get assignedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssignedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  CustomerPriceListAssignmentStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(CustomerPriceListAssignmentStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(5);
}

/// A per-customer, per-variant price override that takes precedence over price lists.
class CustomerPriceOverride extends $pb.GeneratedMessage {
  factory CustomerPriceOverride({
    $core.String? id,
    $core.String? customerId,
    $core.String? productVariantId,
    $4.Money? unitPrice,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    $core.String? approvedBy,
    CustomerPriceOverrideStatus? status,
    $0.Timestamp? createdAt,
  }) {
    final result = CustomerPriceOverride._();
    if (id != null) result.id = id;
    if (customerId != null) result.customerId = customerId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (approvedBy != null) result.approvedBy = approvedBy;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  CustomerPriceOverride._();

  factory CustomerPriceOverride.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverride()..mergeFromBuffer(data, registry);
  factory CustomerPriceOverride.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverride()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceOverride',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceOverride.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'approvedBy')
    ..aE<CustomerPriceOverrideStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: CustomerPriceOverrideStatus.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverride clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverride copyWith(
          void Function(CustomerPriceOverride) updates) =>
      super.copyWith((message) => updates(message as CustomerPriceOverride))
          as CustomerPriceOverride;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceOverride() / CustomerPriceOverride.new instead')
  static CustomerPriceOverride create() => CustomerPriceOverride._();
  static $pb.GeneratedMessage $_createMessage() => CustomerPriceOverride._();
  @$core.override
  CustomerPriceOverride createEmptyInstance() => CustomerPriceOverride._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverride getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverride>(
          CustomerPriceOverride.$_createMessage);
  static CustomerPriceOverride? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get validFrom => $_getN(4);
  @$pb.TagNumber(5)
  set validFrom($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasValidFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidFrom() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureValidFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get validUntil => $_getN(5);
  @$pb.TagNumber(6)
  set validUntil($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasValidUntil() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidUntil() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureValidUntil() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get approvedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set approvedBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApprovedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearApprovedBy() => $_clearField(7);

  @$pb.TagNumber(8)
  CustomerPriceOverrideStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(CustomerPriceOverrideStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);
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
    $1.Struct? conditions,
    $core.bool? requiresApproval,
    $core.double? maxDiscountPercent,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    DiscountRuleStatus? status,
    $0.Timestamp? createdAt,
    $core.String? approvedBy,
    $0.Timestamp? approvedAt,
  }) {
    final result = DiscountRule._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (discountType != null) result.discountType = discountType;
    if (value != null) result.value = value;
    if (appliesTo != null) result.appliesTo = appliesTo;
    if (conditions != null) result.conditions = conditions;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    if (maxDiscountPercent != null)
      result.maxDiscountPercent = maxDiscountPercent;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (approvedBy != null) result.approvedBy = approvedBy;
    if (approvedAt != null) result.approvedAt = approvedAt;
    return result;
  }

  DiscountRule._();

  factory DiscountRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRule()..mergeFromBuffer(data, registry);
  factory DiscountRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRule()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRule.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<DiscountType>(4, _omitFieldNames ? '' : 'discountType',
        enumValues: DiscountType.values)
    ..aD(5, _omitFieldNames ? '' : 'value')
    ..aE<DiscountAppliesTo>(6, _omitFieldNames ? '' : 'appliesTo',
        enumValues: DiscountAppliesTo.values)
    ..aOM<$1.Struct>(7, _omitFieldNames ? '' : 'conditions',
        subBuilder: $1.Struct.$_createMessage)
    ..aOB(8, _omitFieldNames ? '' : 'requiresApproval')
    ..aD(9, _omitFieldNames ? '' : 'maxDiscountPercent')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<DiscountRuleStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: DiscountRuleStatus.values)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(16, _omitFieldNames ? '' : 'approvedBy')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'approvedAt',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRule copyWith(void Function(DiscountRule) updates) =>
      super.copyWith((message) => updates(message as DiscountRule))
          as DiscountRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DiscountRule() / DiscountRule.new instead')
  static DiscountRule create() => DiscountRule._();
  static $pb.GeneratedMessage $_createMessage() => DiscountRule._();
  @$core.override
  DiscountRule createEmptyInstance() => DiscountRule._();
  @$core.pragma('dart2js:noInline')
  static DiscountRule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscountRule>(
          DiscountRule.$_createMessage);
  static DiscountRule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  DiscountType get discountType => $_getN(3);
  @$pb.TagNumber(4)
  set discountType(DiscountType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscountType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscountType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get value => $_getN(4);
  @$pb.TagNumber(5)
  set value($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => $_clearField(5);

  @$pb.TagNumber(6)
  DiscountAppliesTo get appliesTo => $_getN(5);
  @$pb.TagNumber(6)
  set appliesTo(DiscountAppliesTo value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAppliesTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppliesTo() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Struct get conditions => $_getN(6);
  @$pb.TagNumber(7)
  set conditions($1.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasConditions() => $_has(6);
  @$pb.TagNumber(7)
  void clearConditions() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Struct ensureConditions() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get requiresApproval => $_getBF(7);
  @$pb.TagNumber(8)
  set requiresApproval($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequiresApproval() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequiresApproval() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxDiscountPercent => $_getN(8);
  @$pb.TagNumber(9)
  set maxDiscountPercent($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxDiscountPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxDiscountPercent() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get validFrom => $_getN(9);
  @$pb.TagNumber(10)
  set validFrom($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasValidFrom() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidFrom() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureValidFrom() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get validUntil => $_getN(10);
  @$pb.TagNumber(11)
  set validUntil($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasValidUntil() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidUntil() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureValidUntil() => $_ensure(10);

  @$pb.TagNumber(12)
  DiscountRuleStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(DiscountRuleStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

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

  /// Who approved a rule that requires approval; empty until approved.
  @$pb.TagNumber(16)
  $core.String get approvedBy => $_getSZ(13);
  @$pb.TagNumber(16)
  set approvedBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(16)
  $core.bool hasApprovedBy() => $_has(13);
  @$pb.TagNumber(16)
  void clearApprovedBy() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get approvedAt => $_getN(14);
  @$pb.TagNumber(17)
  set approvedAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasApprovedAt() => $_has(14);
  @$pb.TagNumber(17)
  void clearApprovedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureApprovedAt() => $_ensure(14);
}

/// The fully resolved price for a variant, showing which source and discounts apply.
class ResolvedPrice extends $pb.GeneratedMessage {
  factory ResolvedPrice({
    $core.String? variantId,
    $4.Money? unitPrice,
    PriceSource? priceSource,
    $core.String? priceListId,
    $core.String? overrideId,
    $4.Money? discountAmount,
    $core.String? discountRuleId,
    $4.Money? preDiscountPrice,
  }) {
    final result = ResolvedPrice._();
    if (variantId != null) result.variantId = variantId;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (priceSource != null) result.priceSource = priceSource;
    if (priceListId != null) result.priceListId = priceListId;
    if (overrideId != null) result.overrideId = overrideId;
    if (discountAmount != null) result.discountAmount = discountAmount;
    if (discountRuleId != null) result.discountRuleId = discountRuleId;
    if (preDiscountPrice != null) result.preDiscountPrice = preDiscountPrice;
    return result;
  }

  ResolvedPrice._();

  factory ResolvedPrice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvedPrice()..mergeFromBuffer(data, registry);
  factory ResolvedPrice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvedPrice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolvedPrice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolvedPrice.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'variantId')
    ..aOM<$4.Money>(2, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $4.Money.$_createMessage)
    ..aE<PriceSource>(3, _omitFieldNames ? '' : 'priceSource',
        enumValues: PriceSource.values)
    ..aOS(4, _omitFieldNames ? '' : 'priceListId')
    ..aOS(5, _omitFieldNames ? '' : 'overrideId')
    ..aOM<$4.Money>(6, _omitFieldNames ? '' : 'discountAmount',
        subBuilder: $4.Money.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'discountRuleId')
    ..aOM<$4.Money>(8, _omitFieldNames ? '' : 'preDiscountPrice',
        subBuilder: $4.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvedPrice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvedPrice copyWith(void Function(ResolvedPrice) updates) =>
      super.copyWith((message) => updates(message as ResolvedPrice))
          as ResolvedPrice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResolvedPrice() / ResolvedPrice.new instead')
  static ResolvedPrice create() => ResolvedPrice._();
  static $pb.GeneratedMessage $_createMessage() => ResolvedPrice._();
  @$core.override
  ResolvedPrice createEmptyInstance() => ResolvedPrice._();
  @$core.pragma('dart2js:noInline')
  static ResolvedPrice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResolvedPrice>(
          ResolvedPrice.$_createMessage);
  static ResolvedPrice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get variantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set variantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVariantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $4.Money get unitPrice => $_getN(1);
  @$pb.TagNumber(2)
  set unitPrice($4.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUnitPrice() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnitPrice() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.Money ensureUnitPrice() => $_ensure(1);

  @$pb.TagNumber(3)
  PriceSource get priceSource => $_getN(2);
  @$pb.TagNumber(3)
  set priceSource(PriceSource value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPriceSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceSource() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get priceListId => $_getSZ(3);
  @$pb.TagNumber(4)
  set priceListId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPriceListId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPriceListId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get overrideId => $_getSZ(4);
  @$pb.TagNumber(5)
  set overrideId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOverrideId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverrideId() => $_clearField(5);

  @$pb.TagNumber(6)
  $4.Money get discountAmount => $_getN(5);
  @$pb.TagNumber(6)
  set discountAmount($4.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDiscountAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscountAmount() => $_clearField(6);
  @$pb.TagNumber(6)
  $4.Money ensureDiscountAmount() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get discountRuleId => $_getSZ(6);
  @$pb.TagNumber(7)
  set discountRuleId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiscountRuleId() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscountRuleId() => $_clearField(7);

  @$pb.TagNumber(8)
  $4.Money get preDiscountPrice => $_getN(7);
  @$pb.TagNumber(8)
  set preDiscountPrice($4.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPreDiscountPrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearPreDiscountPrice() => $_clearField(8);
  @$pb.TagNumber(8)
  $4.Money ensurePreDiscountPrice() => $_ensure(7);
}

class PriceListSaveRequest extends $pb.GeneratedMessage {
  factory PriceListSaveRequest({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    $core.String? currency,
    $core.int? priority,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    PriceListStatus? status,
  }) {
    final result = PriceListSaveRequest._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (currency != null) result.currency = currency;
    if (priority != null) result.priority = priority;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (status != null) result.status = status;
    return result;
  }

  PriceListSaveRequest._();

  factory PriceListSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSaveRequest()..mergeFromBuffer(data, registry);
  factory PriceListSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aI(5, _omitFieldNames ? '' : 'priority')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<PriceListStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: PriceListStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSaveRequest copyWith(void Function(PriceListSaveRequest) updates) =>
      super.copyWith((message) => updates(message as PriceListSaveRequest))
          as PriceListSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListSaveRequest() / PriceListSaveRequest.new instead')
  static PriceListSaveRequest create() => PriceListSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => PriceListSaveRequest._();
  @$core.override
  PriceListSaveRequest createEmptyInstance() => PriceListSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PriceListSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListSaveRequest>(
          PriceListSaveRequest.$_createMessage);
  static PriceListSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get priority => $_getIZ(4);
  @$pb.TagNumber(5)
  set priority($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get validFrom => $_getN(5);
  @$pb.TagNumber(6)
  set validFrom($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasValidFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidFrom() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureValidFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get validUntil => $_getN(6);
  @$pb.TagNumber(7)
  set validUntil($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasValidUntil() => $_has(6);
  @$pb.TagNumber(7)
  void clearValidUntil() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureValidUntil() => $_ensure(6);

  @$pb.TagNumber(8)
  PriceListStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(PriceListStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);
}

class PriceListSaveResponse extends $pb.GeneratedMessage {
  factory PriceListSaveResponse({
    PriceList? priceList,
  }) {
    final result = PriceListSaveResponse._();
    if (priceList != null) result.priceList = priceList;
    return result;
  }

  PriceListSaveResponse._();

  factory PriceListSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSaveResponse()..mergeFromBuffer(data, registry);
  factory PriceListSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListSaveResponse.$_createMessage)
    ..aOM<PriceList>(1, _omitFieldNames ? '' : 'priceList',
        subBuilder: PriceList.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSaveResponse copyWith(
          void Function(PriceListSaveResponse) updates) =>
      super.copyWith((message) => updates(message as PriceListSaveResponse))
          as PriceListSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListSaveResponse() / PriceListSaveResponse.new instead')
  static PriceListSaveResponse create() => PriceListSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => PriceListSaveResponse._();
  @$core.override
  PriceListSaveResponse createEmptyInstance() => PriceListSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PriceListSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListSaveResponse>(
          PriceListSaveResponse.$_createMessage);
  static PriceListSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceList get priceList => $_getN(0);
  @$pb.TagNumber(1)
  set priceList(PriceList value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceList() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceList() => $_clearField(1);
  @$pb.TagNumber(1)
  PriceList ensurePriceList() => $_ensure(0);
}

class PriceListGetRequest extends $pb.GeneratedMessage {
  factory PriceListGetRequest({
    $core.String? id,
  }) {
    final result = PriceListGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PriceListGetRequest._();

  factory PriceListGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListGetRequest()..mergeFromBuffer(data, registry);
  factory PriceListGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListGetRequest copyWith(void Function(PriceListGetRequest) updates) =>
      super.copyWith((message) => updates(message as PriceListGetRequest))
          as PriceListGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PriceListGetRequest() / PriceListGetRequest.new instead')
  static PriceListGetRequest create() => PriceListGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PriceListGetRequest._();
  @$core.override
  PriceListGetRequest createEmptyInstance() => PriceListGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PriceListGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListGetRequest>(
          PriceListGetRequest.$_createMessage);
  static PriceListGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PriceListGetResponse extends $pb.GeneratedMessage {
  factory PriceListGetResponse({
    PriceList? priceList,
  }) {
    final result = PriceListGetResponse._();
    if (priceList != null) result.priceList = priceList;
    return result;
  }

  PriceListGetResponse._();

  factory PriceListGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListGetResponse()..mergeFromBuffer(data, registry);
  factory PriceListGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListGetResponse.$_createMessage)
    ..aOM<PriceList>(1, _omitFieldNames ? '' : 'priceList',
        subBuilder: PriceList.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListGetResponse copyWith(void Function(PriceListGetResponse) updates) =>
      super.copyWith((message) => updates(message as PriceListGetResponse))
          as PriceListGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListGetResponse() / PriceListGetResponse.new instead')
  static PriceListGetResponse create() => PriceListGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => PriceListGetResponse._();
  @$core.override
  PriceListGetResponse createEmptyInstance() => PriceListGetResponse._();
  @$core.pragma('dart2js:noInline')
  static PriceListGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListGetResponse>(
          PriceListGetResponse.$_createMessage);
  static PriceListGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceList get priceList => $_getN(0);
  @$pb.TagNumber(1)
  set priceList(PriceList value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceList() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceList() => $_clearField(1);
  @$pb.TagNumber(1)
  PriceList ensurePriceList() => $_ensure(0);
}

class PriceListSearchRequest extends $pb.GeneratedMessage {
  factory PriceListSearchRequest({
    $core.String? shopId,
    $3.SearchRequest? search,
  }) {
    final result = PriceListSearchRequest._();
    if (shopId != null) result.shopId = shopId;
    if (search != null) result.search = search;
    return result;
  }

  PriceListSearchRequest._();

  factory PriceListSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSearchRequest()..mergeFromBuffer(data, registry);
  factory PriceListSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$3.SearchRequest>(2, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSearchRequest copyWith(
          void Function(PriceListSearchRequest) updates) =>
      super.copyWith((message) => updates(message as PriceListSearchRequest))
          as PriceListSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListSearchRequest() / PriceListSearchRequest.new instead')
  static PriceListSearchRequest create() => PriceListSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => PriceListSearchRequest._();
  @$core.override
  PriceListSearchRequest createEmptyInstance() => PriceListSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PriceListSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListSearchRequest>(
          PriceListSearchRequest.$_createMessage);
  static PriceListSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($3.SearchRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.SearchRequest ensureSearch() => $_ensure(1);
}

class PriceListSearchResponse extends $pb.GeneratedMessage {
  factory PriceListSearchResponse({
    $core.Iterable<PriceList>? priceLists,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = PriceListSearchResponse._();
    if (priceLists != null) result.priceLists.addAll(priceLists);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  PriceListSearchResponse._();

  factory PriceListSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSearchResponse()..mergeFromBuffer(data, registry);
  factory PriceListSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListSearchResponse.$_createMessage)
    ..pPM<PriceList>(1, _omitFieldNames ? '' : 'priceLists',
        subBuilder: PriceList.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListSearchResponse copyWith(
          void Function(PriceListSearchResponse) updates) =>
      super.copyWith((message) => updates(message as PriceListSearchResponse))
          as PriceListSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListSearchResponse() / PriceListSearchResponse.new instead')
  static PriceListSearchResponse create() => PriceListSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => PriceListSearchResponse._();
  @$core.override
  PriceListSearchResponse createEmptyInstance() => PriceListSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PriceListSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListSearchResponse>(
          PriceListSearchResponse.$_createMessage);
  static PriceListSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PriceList> get priceLists => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class PriceListEntryBatchSaveRequest extends $pb.GeneratedMessage {
  factory PriceListEntryBatchSaveRequest({
    $core.String? priceListId,
    $core.Iterable<PriceListEntry>? entries,
  }) {
    final result = PriceListEntryBatchSaveRequest._();
    if (priceListId != null) result.priceListId = priceListId;
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  PriceListEntryBatchSaveRequest._();

  factory PriceListEntryBatchSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntryBatchSaveRequest()..mergeFromBuffer(data, registry);
  factory PriceListEntryBatchSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntryBatchSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListEntryBatchSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListEntryBatchSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'priceListId')
    ..pPM<PriceListEntry>(2, _omitFieldNames ? '' : 'entries',
        subBuilder: PriceListEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntryBatchSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntryBatchSaveRequest copyWith(
          void Function(PriceListEntryBatchSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PriceListEntryBatchSaveRequest))
          as PriceListEntryBatchSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListEntryBatchSaveRequest() / PriceListEntryBatchSaveRequest.new instead')
  static PriceListEntryBatchSaveRequest create() =>
      PriceListEntryBatchSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PriceListEntryBatchSaveRequest._();
  @$core.override
  PriceListEntryBatchSaveRequest createEmptyInstance() =>
      PriceListEntryBatchSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListEntryBatchSaveRequest>(
          PriceListEntryBatchSaveRequest.$_createMessage);
  static PriceListEntryBatchSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priceListId => $_getSZ(0);
  @$pb.TagNumber(1)
  set priceListId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceListId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceListId() => $_clearField(1);

  /// Entries to save. For each product_variant_id present, all existing entries
  /// in this price list for that variant are replaced.
  @$pb.TagNumber(2)
  $pb.PbList<PriceListEntry> get entries => $_getList(1);
}

class PriceListEntryBatchSaveResponse extends $pb.GeneratedMessage {
  factory PriceListEntryBatchSaveResponse({
    $core.Iterable<PriceListEntry>? entries,
  }) {
    final result = PriceListEntryBatchSaveResponse._();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  PriceListEntryBatchSaveResponse._();

  factory PriceListEntryBatchSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntryBatchSaveResponse()..mergeFromBuffer(data, registry);
  factory PriceListEntryBatchSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PriceListEntryBatchSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceListEntryBatchSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: PriceListEntryBatchSaveResponse.$_createMessage)
    ..pPM<PriceListEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: PriceListEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntryBatchSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceListEntryBatchSaveResponse copyWith(
          void Function(PriceListEntryBatchSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PriceListEntryBatchSaveResponse))
          as PriceListEntryBatchSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PriceListEntryBatchSaveResponse() / PriceListEntryBatchSaveResponse.new instead')
  static PriceListEntryBatchSaveResponse create() =>
      PriceListEntryBatchSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PriceListEntryBatchSaveResponse._();
  @$core.override
  PriceListEntryBatchSaveResponse createEmptyInstance() =>
      PriceListEntryBatchSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PriceListEntryBatchSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceListEntryBatchSaveResponse>(
          PriceListEntryBatchSaveResponse.$_createMessage);
  static PriceListEntryBatchSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PriceListEntry> get entries => $_getList(0);
}

class CustomerPriceListAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSaveRequest({
    $core.String? id,
    $core.String? customerId,
    $core.String? priceListId,
    $core.String? assignedBy,
    CustomerPriceListAssignmentStatus? status,
  }) {
    final result = CustomerPriceListAssignmentSaveRequest._();
    if (id != null) result.id = id;
    if (customerId != null) result.customerId = customerId;
    if (priceListId != null) result.priceListId = priceListId;
    if (assignedBy != null) result.assignedBy = assignedBy;
    if (status != null) result.status = status;
    return result;
  }

  CustomerPriceListAssignmentSaveRequest._();

  factory CustomerPriceListAssignmentSaveRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSaveRequest()..mergeFromBuffer(data, registry);
  factory CustomerPriceListAssignmentSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceListAssignmentSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance:
          CustomerPriceListAssignmentSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'priceListId')
    ..aOS(4, _omitFieldNames ? '' : 'assignedBy')
    ..aE<CustomerPriceListAssignmentStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: CustomerPriceListAssignmentStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSaveRequest copyWith(
          void Function(CustomerPriceListAssignmentSaveRequest) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceListAssignmentSaveRequest))
          as CustomerPriceListAssignmentSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceListAssignmentSaveRequest() / CustomerPriceListAssignmentSaveRequest.new instead')
  static CustomerPriceListAssignmentSaveRequest create() =>
      CustomerPriceListAssignmentSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceListAssignmentSaveRequest._();
  @$core.override
  CustomerPriceListAssignmentSaveRequest createEmptyInstance() =>
      CustomerPriceListAssignmentSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CustomerPriceListAssignmentSaveRequest>(
          CustomerPriceListAssignmentSaveRequest.$_createMessage);
  static CustomerPriceListAssignmentSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get priceListId => $_getSZ(2);
  @$pb.TagNumber(3)
  set priceListId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriceListId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceListId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get assignedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssignedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  CustomerPriceListAssignmentStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(CustomerPriceListAssignmentStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

class CustomerPriceListAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSaveResponse({
    CustomerPriceListAssignment? assignment,
  }) {
    final result = CustomerPriceListAssignmentSaveResponse._();
    if (assignment != null) result.assignment = assignment;
    return result;
  }

  CustomerPriceListAssignmentSaveResponse._();

  factory CustomerPriceListAssignmentSaveResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSaveResponse()
        ..mergeFromBuffer(data, registry);
  factory CustomerPriceListAssignmentSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceListAssignmentSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance:
          CustomerPriceListAssignmentSaveResponse.$_createMessage)
    ..aOM<CustomerPriceListAssignment>(1, _omitFieldNames ? '' : 'assignment',
        subBuilder: CustomerPriceListAssignment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSaveResponse copyWith(
          void Function(CustomerPriceListAssignmentSaveResponse) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceListAssignmentSaveResponse))
          as CustomerPriceListAssignmentSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceListAssignmentSaveResponse() / CustomerPriceListAssignmentSaveResponse.new instead')
  static CustomerPriceListAssignmentSaveResponse create() =>
      CustomerPriceListAssignmentSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceListAssignmentSaveResponse._();
  @$core.override
  CustomerPriceListAssignmentSaveResponse createEmptyInstance() =>
      CustomerPriceListAssignmentSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSaveResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CustomerPriceListAssignmentSaveResponse>(
          CustomerPriceListAssignmentSaveResponse.$_createMessage);
  static CustomerPriceListAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CustomerPriceListAssignment get assignment => $_getN(0);
  @$pb.TagNumber(1)
  set assignment(CustomerPriceListAssignment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAssignment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssignment() => $_clearField(1);
  @$pb.TagNumber(1)
  CustomerPriceListAssignment ensureAssignment() => $_ensure(0);
}

class CustomerPriceListAssignmentSearchRequest extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSearchRequest({
    $core.String? customerId,
    $core.String? priceListId,
    $3.SearchRequest? search,
  }) {
    final result = CustomerPriceListAssignmentSearchRequest._();
    if (customerId != null) result.customerId = customerId;
    if (priceListId != null) result.priceListId = priceListId;
    if (search != null) result.search = search;
    return result;
  }

  CustomerPriceListAssignmentSearchRequest._();

  factory CustomerPriceListAssignmentSearchRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSearchRequest()
        ..mergeFromBuffer(data, registry);
  factory CustomerPriceListAssignmentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceListAssignmentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance:
          CustomerPriceListAssignmentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'priceListId')
    ..aOM<$3.SearchRequest>(3, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSearchRequest copyWith(
          void Function(CustomerPriceListAssignmentSearchRequest) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceListAssignmentSearchRequest))
          as CustomerPriceListAssignmentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceListAssignmentSearchRequest() / CustomerPriceListAssignmentSearchRequest.new instead')
  static CustomerPriceListAssignmentSearchRequest create() =>
      CustomerPriceListAssignmentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceListAssignmentSearchRequest._();
  @$core.override
  CustomerPriceListAssignmentSearchRequest createEmptyInstance() =>
      CustomerPriceListAssignmentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CustomerPriceListAssignmentSearchRequest>(
          CustomerPriceListAssignmentSearchRequest.$_createMessage);
  static CustomerPriceListAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get priceListId => $_getSZ(1);
  @$pb.TagNumber(2)
  set priceListId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPriceListId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPriceListId() => $_clearField(2);

  @$pb.TagNumber(3)
  $3.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($3.SearchRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.SearchRequest ensureSearch() => $_ensure(2);
}

class CustomerPriceListAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory CustomerPriceListAssignmentSearchResponse({
    $core.Iterable<CustomerPriceListAssignment>? assignments,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = CustomerPriceListAssignmentSearchResponse._();
    if (assignments != null) result.assignments.addAll(assignments);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  CustomerPriceListAssignmentSearchResponse._();

  factory CustomerPriceListAssignmentSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSearchResponse()
        ..mergeFromBuffer(data, registry);
  factory CustomerPriceListAssignmentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceListAssignmentSearchResponse()
        ..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceListAssignmentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance:
          CustomerPriceListAssignmentSearchResponse.$_createMessage)
    ..pPM<CustomerPriceListAssignment>(1, _omitFieldNames ? '' : 'assignments',
        subBuilder: CustomerPriceListAssignment.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceListAssignmentSearchResponse copyWith(
          void Function(CustomerPriceListAssignmentSearchResponse) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceListAssignmentSearchResponse))
          as CustomerPriceListAssignmentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceListAssignmentSearchResponse() / CustomerPriceListAssignmentSearchResponse.new instead')
  static CustomerPriceListAssignmentSearchResponse create() =>
      CustomerPriceListAssignmentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceListAssignmentSearchResponse._();
  @$core.override
  CustomerPriceListAssignmentSearchResponse createEmptyInstance() =>
      CustomerPriceListAssignmentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceListAssignmentSearchResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CustomerPriceListAssignmentSearchResponse>(
          CustomerPriceListAssignmentSearchResponse.$_createMessage);
  static CustomerPriceListAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CustomerPriceListAssignment> get assignments => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class CustomerPriceOverrideSaveRequest extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSaveRequest({
    $core.String? id,
    $core.String? customerId,
    $core.String? productVariantId,
    $4.Money? unitPrice,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    $core.String? approvedBy,
    CustomerPriceOverrideStatus? status,
  }) {
    final result = CustomerPriceOverrideSaveRequest._();
    if (id != null) result.id = id;
    if (customerId != null) result.customerId = customerId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (unitPrice != null) result.unitPrice = unitPrice;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (approvedBy != null) result.approvedBy = approvedBy;
    if (status != null) result.status = status;
    return result;
  }

  CustomerPriceOverrideSaveRequest._();

  factory CustomerPriceOverrideSaveRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSaveRequest()..mergeFromBuffer(data, registry);
  factory CustomerPriceOverrideSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceOverrideSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceOverrideSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'customerId')
    ..aOS(3, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$4.Money>(4, _omitFieldNames ? '' : 'unitPrice',
        subBuilder: $4.Money.$_createMessage)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'approvedBy')
    ..aE<CustomerPriceOverrideStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: CustomerPriceOverrideStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSaveRequest copyWith(
          void Function(CustomerPriceOverrideSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CustomerPriceOverrideSaveRequest))
          as CustomerPriceOverrideSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceOverrideSaveRequest() / CustomerPriceOverrideSaveRequest.new instead')
  static CustomerPriceOverrideSaveRequest create() =>
      CustomerPriceOverrideSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceOverrideSaveRequest._();
  @$core.override
  CustomerPriceOverrideSaveRequest createEmptyInstance() =>
      CustomerPriceOverrideSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSaveRequest>(
          CustomerPriceOverrideSaveRequest.$_createMessage);
  static CustomerPriceOverrideSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get customerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set customerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productVariantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productVariantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductVariantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductVariantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Money get unitPrice => $_getN(3);
  @$pb.TagNumber(4)
  set unitPrice($4.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnitPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitPrice() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Money ensureUnitPrice() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get validFrom => $_getN(4);
  @$pb.TagNumber(5)
  set validFrom($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasValidFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidFrom() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureValidFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get validUntil => $_getN(5);
  @$pb.TagNumber(6)
  set validUntil($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasValidUntil() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidUntil() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureValidUntil() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get approvedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set approvedBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApprovedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearApprovedBy() => $_clearField(7);

  @$pb.TagNumber(8)
  CustomerPriceOverrideStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(CustomerPriceOverrideStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);
}

class CustomerPriceOverrideSaveResponse extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSaveResponse({
    CustomerPriceOverride? override,
  }) {
    final result = CustomerPriceOverrideSaveResponse._();
    if (override != null) result.override = override;
    return result;
  }

  CustomerPriceOverrideSaveResponse._();

  factory CustomerPriceOverrideSaveResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSaveResponse()..mergeFromBuffer(data, registry);
  factory CustomerPriceOverrideSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceOverrideSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceOverrideSaveResponse.$_createMessage)
    ..aOM<CustomerPriceOverride>(1, _omitFieldNames ? '' : 'override',
        subBuilder: CustomerPriceOverride.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSaveResponse copyWith(
          void Function(CustomerPriceOverrideSaveResponse) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceOverrideSaveResponse))
          as CustomerPriceOverrideSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceOverrideSaveResponse() / CustomerPriceOverrideSaveResponse.new instead')
  static CustomerPriceOverrideSaveResponse create() =>
      CustomerPriceOverrideSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceOverrideSaveResponse._();
  @$core.override
  CustomerPriceOverrideSaveResponse createEmptyInstance() =>
      CustomerPriceOverrideSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSaveResponse>(
          CustomerPriceOverrideSaveResponse.$_createMessage);
  static CustomerPriceOverrideSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CustomerPriceOverride get override => $_getN(0);
  @$pb.TagNumber(1)
  set override(CustomerPriceOverride value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOverride() => $_has(0);
  @$pb.TagNumber(1)
  void clearOverride() => $_clearField(1);
  @$pb.TagNumber(1)
  CustomerPriceOverride ensureOverride() => $_ensure(0);
}

class CustomerPriceOverrideSearchRequest extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSearchRequest({
    $core.String? customerId,
    $core.String? productVariantId,
    $3.SearchRequest? search,
  }) {
    final result = CustomerPriceOverrideSearchRequest._();
    if (customerId != null) result.customerId = customerId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (search != null) result.search = search;
    return result;
  }

  CustomerPriceOverrideSearchRequest._();

  factory CustomerPriceOverrideSearchRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSearchRequest()..mergeFromBuffer(data, registry);
  factory CustomerPriceOverrideSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceOverrideSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceOverrideSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aOM<$3.SearchRequest>(3, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSearchRequest copyWith(
          void Function(CustomerPriceOverrideSearchRequest) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceOverrideSearchRequest))
          as CustomerPriceOverrideSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceOverrideSearchRequest() / CustomerPriceOverrideSearchRequest.new instead')
  static CustomerPriceOverrideSearchRequest create() =>
      CustomerPriceOverrideSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceOverrideSearchRequest._();
  @$core.override
  CustomerPriceOverrideSearchRequest createEmptyInstance() =>
      CustomerPriceOverrideSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomerPriceOverrideSearchRequest>(
          CustomerPriceOverrideSearchRequest.$_createMessage);
  static CustomerPriceOverrideSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $3.SearchRequest get search => $_getN(2);
  @$pb.TagNumber(3)
  set search($3.SearchRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.SearchRequest ensureSearch() => $_ensure(2);
}

class CustomerPriceOverrideSearchResponse extends $pb.GeneratedMessage {
  factory CustomerPriceOverrideSearchResponse({
    $core.Iterable<CustomerPriceOverride>? overrides,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = CustomerPriceOverrideSearchResponse._();
    if (overrides != null) result.overrides.addAll(overrides);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  CustomerPriceOverrideSearchResponse._();

  factory CustomerPriceOverrideSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSearchResponse()..mergeFromBuffer(data, registry);
  factory CustomerPriceOverrideSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomerPriceOverrideSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomerPriceOverrideSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: CustomerPriceOverrideSearchResponse.$_createMessage)
    ..pPM<CustomerPriceOverride>(1, _omitFieldNames ? '' : 'overrides',
        subBuilder: CustomerPriceOverride.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomerPriceOverrideSearchResponse copyWith(
          void Function(CustomerPriceOverrideSearchResponse) updates) =>
      super.copyWith((message) =>
              updates(message as CustomerPriceOverrideSearchResponse))
          as CustomerPriceOverrideSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomerPriceOverrideSearchResponse() / CustomerPriceOverrideSearchResponse.new instead')
  static CustomerPriceOverrideSearchResponse create() =>
      CustomerPriceOverrideSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CustomerPriceOverrideSearchResponse._();
  @$core.override
  CustomerPriceOverrideSearchResponse createEmptyInstance() =>
      CustomerPriceOverrideSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static CustomerPriceOverrideSearchResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CustomerPriceOverrideSearchResponse>(
          CustomerPriceOverrideSearchResponse.$_createMessage);
  static CustomerPriceOverrideSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CustomerPriceOverride> get overrides => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class DiscountRuleSaveRequest extends $pb.GeneratedMessage {
  factory DiscountRuleSaveRequest({
    $core.String? id,
    $core.String? shopId,
    $core.String? name,
    DiscountType? discountType,
    $core.double? value,
    DiscountAppliesTo? appliesTo,
    $1.Struct? conditions,
    $core.bool? requiresApproval,
    $core.double? maxDiscountPercent,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    DiscountRuleStatus? status,
    $2.FieldMask? updateMask,
  }) {
    final result = DiscountRuleSaveRequest._();
    if (id != null) result.id = id;
    if (shopId != null) result.shopId = shopId;
    if (name != null) result.name = name;
    if (discountType != null) result.discountType = discountType;
    if (value != null) result.value = value;
    if (appliesTo != null) result.appliesTo = appliesTo;
    if (conditions != null) result.conditions = conditions;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    if (maxDiscountPercent != null)
      result.maxDiscountPercent = maxDiscountPercent;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (status != null) result.status = status;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  DiscountRuleSaveRequest._();

  factory DiscountRuleSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSaveRequest()..mergeFromBuffer(data, registry);
  factory DiscountRuleSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'shopId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<DiscountType>(4, _omitFieldNames ? '' : 'discountType',
        enumValues: DiscountType.values)
    ..aD(5, _omitFieldNames ? '' : 'value')
    ..aE<DiscountAppliesTo>(6, _omitFieldNames ? '' : 'appliesTo',
        enumValues: DiscountAppliesTo.values)
    ..aOM<$1.Struct>(7, _omitFieldNames ? '' : 'conditions',
        subBuilder: $1.Struct.$_createMessage)
    ..aOB(8, _omitFieldNames ? '' : 'requiresApproval')
    ..aD(9, _omitFieldNames ? '' : 'maxDiscountPercent')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aE<DiscountRuleStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: DiscountRuleStatus.values)
    ..aOM<$2.FieldMask>(13, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $2.FieldMask.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSaveRequest copyWith(
          void Function(DiscountRuleSaveRequest) updates) =>
      super.copyWith((message) => updates(message as DiscountRuleSaveRequest))
          as DiscountRuleSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleSaveRequest() / DiscountRuleSaveRequest.new instead')
  static DiscountRuleSaveRequest create() => DiscountRuleSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => DiscountRuleSaveRequest._();
  @$core.override
  DiscountRuleSaveRequest createEmptyInstance() => DiscountRuleSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleSaveRequest>(
          DiscountRuleSaveRequest.$_createMessage);
  static DiscountRuleSaveRequest? _defaultInstance;

  /// Empty for create; set for update.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shopId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shopId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShopId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShopId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  DiscountType get discountType => $_getN(3);
  @$pb.TagNumber(4)
  set discountType(DiscountType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscountType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscountType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get value => $_getN(4);
  @$pb.TagNumber(5)
  set value($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => $_clearField(5);

  @$pb.TagNumber(6)
  DiscountAppliesTo get appliesTo => $_getN(5);
  @$pb.TagNumber(6)
  set appliesTo(DiscountAppliesTo value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAppliesTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppliesTo() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Struct get conditions => $_getN(6);
  @$pb.TagNumber(7)
  set conditions($1.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasConditions() => $_has(6);
  @$pb.TagNumber(7)
  void clearConditions() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Struct ensureConditions() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get requiresApproval => $_getBF(7);
  @$pb.TagNumber(8)
  set requiresApproval($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequiresApproval() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequiresApproval() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxDiscountPercent => $_getN(8);
  @$pb.TagNumber(9)
  set maxDiscountPercent($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxDiscountPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxDiscountPercent() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get validFrom => $_getN(9);
  @$pb.TagNumber(10)
  set validFrom($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasValidFrom() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidFrom() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureValidFrom() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get validUntil => $_getN(10);
  @$pb.TagNumber(11)
  set validUntil($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasValidUntil() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidUntil() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureValidUntil() => $_ensure(10);

  @$pb.TagNumber(12)
  DiscountRuleStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(DiscountRuleStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  /// On update, the fields to apply. Without a mask only fields carrying a
  /// value are applied. Listing "requires_approval" with it false waives the
  /// approval requirement, which needs discount_approve on the shop.
  @$pb.TagNumber(13)
  $2.FieldMask get updateMask => $_getN(12);
  @$pb.TagNumber(13)
  set updateMask($2.FieldMask value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdateMask() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdateMask() => $_clearField(13);
  @$pb.TagNumber(13)
  $2.FieldMask ensureUpdateMask() => $_ensure(12);
}

class DiscountRuleSaveResponse extends $pb.GeneratedMessage {
  factory DiscountRuleSaveResponse({
    DiscountRule? discountRule,
  }) {
    final result = DiscountRuleSaveResponse._();
    if (discountRule != null) result.discountRule = discountRule;
    return result;
  }

  DiscountRuleSaveResponse._();

  factory DiscountRuleSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSaveResponse()..mergeFromBuffer(data, registry);
  factory DiscountRuleSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleSaveResponse.$_createMessage)
    ..aOM<DiscountRule>(1, _omitFieldNames ? '' : 'discountRule',
        subBuilder: DiscountRule.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSaveResponse copyWith(
          void Function(DiscountRuleSaveResponse) updates) =>
      super.copyWith((message) => updates(message as DiscountRuleSaveResponse))
          as DiscountRuleSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleSaveResponse() / DiscountRuleSaveResponse.new instead')
  static DiscountRuleSaveResponse create() => DiscountRuleSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => DiscountRuleSaveResponse._();
  @$core.override
  DiscountRuleSaveResponse createEmptyInstance() =>
      DiscountRuleSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleSaveResponse>(
          DiscountRuleSaveResponse.$_createMessage);
  static DiscountRuleSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiscountRule get discountRule => $_getN(0);
  @$pb.TagNumber(1)
  set discountRule(DiscountRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscountRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscountRule() => $_clearField(1);
  @$pb.TagNumber(1)
  DiscountRule ensureDiscountRule() => $_ensure(0);
}

class DiscountRuleSearchRequest extends $pb.GeneratedMessage {
  factory DiscountRuleSearchRequest({
    $core.String? shopId,
    $3.SearchRequest? search,
  }) {
    final result = DiscountRuleSearchRequest._();
    if (shopId != null) result.shopId = shopId;
    if (search != null) result.search = search;
    return result;
  }

  DiscountRuleSearchRequest._();

  factory DiscountRuleSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSearchRequest()..mergeFromBuffer(data, registry);
  factory DiscountRuleSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'shopId')
    ..aOM<$3.SearchRequest>(2, _omitFieldNames ? '' : 'search',
        subBuilder: $3.SearchRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSearchRequest copyWith(
          void Function(DiscountRuleSearchRequest) updates) =>
      super.copyWith((message) => updates(message as DiscountRuleSearchRequest))
          as DiscountRuleSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleSearchRequest() / DiscountRuleSearchRequest.new instead')
  static DiscountRuleSearchRequest create() => DiscountRuleSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DiscountRuleSearchRequest._();
  @$core.override
  DiscountRuleSearchRequest createEmptyInstance() =>
      DiscountRuleSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleSearchRequest>(
          DiscountRuleSearchRequest.$_createMessage);
  static DiscountRuleSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shopId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shopId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShopId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShopId() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.SearchRequest get search => $_getN(1);
  @$pb.TagNumber(2)
  set search($3.SearchRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.SearchRequest ensureSearch() => $_ensure(1);
}

class DiscountRuleSearchResponse extends $pb.GeneratedMessage {
  factory DiscountRuleSearchResponse({
    $core.Iterable<DiscountRule>? discountRules,
    $core.String? nextPage,
    $core.String? prevCursor,
  }) {
    final result = DiscountRuleSearchResponse._();
    if (discountRules != null) result.discountRules.addAll(discountRules);
    if (nextPage != null) result.nextPage = nextPage;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  DiscountRuleSearchResponse._();

  factory DiscountRuleSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSearchResponse()..mergeFromBuffer(data, registry);
  factory DiscountRuleSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleSearchResponse.$_createMessage)
    ..pPM<DiscountRule>(1, _omitFieldNames ? '' : 'discountRules',
        subBuilder: DiscountRule.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextPage')
    ..aOS(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleSearchResponse copyWith(
          void Function(DiscountRuleSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DiscountRuleSearchResponse))
          as DiscountRuleSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleSearchResponse() / DiscountRuleSearchResponse.new instead')
  static DiscountRuleSearchResponse create() => DiscountRuleSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      DiscountRuleSearchResponse._();
  @$core.override
  DiscountRuleSearchResponse createEmptyInstance() =>
      DiscountRuleSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleSearchResponse>(
          DiscountRuleSearchResponse.$_createMessage);
  static DiscountRuleSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DiscountRule> get discountRules => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPage => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevCursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevCursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class DiscountRuleApproveRequest extends $pb.GeneratedMessage {
  factory DiscountRuleApproveRequest({
    $core.String? id,
  }) {
    final result = DiscountRuleApproveRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DiscountRuleApproveRequest._();

  factory DiscountRuleApproveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleApproveRequest()..mergeFromBuffer(data, registry);
  factory DiscountRuleApproveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleApproveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleApproveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleApproveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleApproveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleApproveRequest copyWith(
          void Function(DiscountRuleApproveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DiscountRuleApproveRequest))
          as DiscountRuleApproveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleApproveRequest() / DiscountRuleApproveRequest.new instead')
  static DiscountRuleApproveRequest create() => DiscountRuleApproveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DiscountRuleApproveRequest._();
  @$core.override
  DiscountRuleApproveRequest createEmptyInstance() =>
      DiscountRuleApproveRequest._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleApproveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleApproveRequest>(
          DiscountRuleApproveRequest.$_createMessage);
  static DiscountRuleApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DiscountRuleApproveResponse extends $pb.GeneratedMessage {
  factory DiscountRuleApproveResponse({
    DiscountRule? discountRule,
  }) {
    final result = DiscountRuleApproveResponse._();
    if (discountRule != null) result.discountRule = discountRule;
    return result;
  }

  DiscountRuleApproveResponse._();

  factory DiscountRuleApproveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleApproveResponse()..mergeFromBuffer(data, registry);
  factory DiscountRuleApproveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiscountRuleApproveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscountRuleApproveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: DiscountRuleApproveResponse.$_createMessage)
    ..aOM<DiscountRule>(1, _omitFieldNames ? '' : 'discountRule',
        subBuilder: DiscountRule.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleApproveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscountRuleApproveResponse copyWith(
          void Function(DiscountRuleApproveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DiscountRuleApproveResponse))
          as DiscountRuleApproveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DiscountRuleApproveResponse() / DiscountRuleApproveResponse.new instead')
  static DiscountRuleApproveResponse create() =>
      DiscountRuleApproveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      DiscountRuleApproveResponse._();
  @$core.override
  DiscountRuleApproveResponse createEmptyInstance() =>
      DiscountRuleApproveResponse._();
  @$core.pragma('dart2js:noInline')
  static DiscountRuleApproveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscountRuleApproveResponse>(
          DiscountRuleApproveResponse.$_createMessage);
  static DiscountRuleApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiscountRule get discountRule => $_getN(0);
  @$pb.TagNumber(1)
  set discountRule(DiscountRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscountRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscountRule() => $_clearField(1);
  @$pb.TagNumber(1)
  DiscountRule ensureDiscountRule() => $_ensure(0);
}

class ResolvePriceRequest extends $pb.GeneratedMessage {
  factory ResolvePriceRequest({
    $core.String? customerId,
    $core.String? productVariantId,
    $core.int? quantity,
  }) {
    final result = ResolvePriceRequest._();
    if (customerId != null) result.customerId = customerId;
    if (productVariantId != null) result.productVariantId = productVariantId;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  ResolvePriceRequest._();

  factory ResolvePriceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvePriceRequest()..mergeFromBuffer(data, registry);
  factory ResolvePriceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvePriceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolvePriceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolvePriceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'customerId')
    ..aOS(2, _omitFieldNames ? '' : 'productVariantId')
    ..aI(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvePriceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvePriceRequest copyWith(void Function(ResolvePriceRequest) updates) =>
      super.copyWith((message) => updates(message as ResolvePriceRequest))
          as ResolvePriceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ResolvePriceRequest() / ResolvePriceRequest.new instead')
  static ResolvePriceRequest create() => ResolvePriceRequest._();
  static $pb.GeneratedMessage $_createMessage() => ResolvePriceRequest._();
  @$core.override
  ResolvePriceRequest createEmptyInstance() => ResolvePriceRequest._();
  @$core.pragma('dart2js:noInline')
  static ResolvePriceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolvePriceRequest>(
          ResolvePriceRequest.$_createMessage);
  static ResolvePriceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get customerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set customerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productVariantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productVariantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductVariantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quantity => $_getIZ(2);
  @$pb.TagNumber(3)
  set quantity($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);
}

class ResolvePriceResponse extends $pb.GeneratedMessage {
  factory ResolvePriceResponse({
    ResolvedPrice? resolvedPrice,
  }) {
    final result = ResolvePriceResponse._();
    if (resolvedPrice != null) result.resolvedPrice = resolvedPrice;
    return result;
  }

  ResolvePriceResponse._();

  factory ResolvePriceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvePriceResponse()..mergeFromBuffer(data, registry);
  factory ResolvePriceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolvePriceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolvePriceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'commerce.v1'),
      createEmptyInstance: ResolvePriceResponse.$_createMessage)
    ..aOM<ResolvedPrice>(1, _omitFieldNames ? '' : 'resolvedPrice',
        subBuilder: ResolvedPrice.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvePriceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolvePriceResponse copyWith(void Function(ResolvePriceResponse) updates) =>
      super.copyWith((message) => updates(message as ResolvePriceResponse))
          as ResolvePriceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ResolvePriceResponse() / ResolvePriceResponse.new instead')
  static ResolvePriceResponse create() => ResolvePriceResponse._();
  static $pb.GeneratedMessage $_createMessage() => ResolvePriceResponse._();
  @$core.override
  ResolvePriceResponse createEmptyInstance() => ResolvePriceResponse._();
  @$core.pragma('dart2js:noInline')
  static ResolvePriceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolvePriceResponse>(
          ResolvePriceResponse.$_createMessage);
  static ResolvePriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResolvedPrice get resolvedPrice => $_getN(0);
  @$pb.TagNumber(1)
  set resolvedPrice(ResolvedPrice value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasResolvedPrice() => $_has(0);
  @$pb.TagNumber(1)
  void clearResolvedPrice() => $_clearField(1);
  @$pb.TagNumber(1)
  ResolvedPrice ensureResolvedPrice() => $_ensure(0);
}

class CommerceServiceApi {
  final $pb.RpcClient _client;

  CommerceServiceApi(this._client);

  /// Creates a new shop. The authenticated user becomes the admin.
  $async.Future<CreateShopResponse> createShop(
          $pb.ClientContext? ctx, CreateShopRequest request) =>
      _client.invoke<CreateShopResponse>(
          ctx, 'CommerceService', 'CreateShop', request, CreateShopResponse());

  /// Retrieves shop details by ID.
  $async.Future<GetShopResponse> getShop(
          $pb.ClientContext? ctx, GetShopRequest request) =>
      _client.invoke<GetShopResponse>(
          ctx, 'CommerceService', 'GetShop', request, GetShopResponse());

  /// Updates shop details.
  $async.Future<UpdateShopResponse> updateShop(
          $pb.ClientContext? ctx, UpdateShopRequest request) =>
      _client.invoke<UpdateShopResponse>(
          ctx, 'CommerceService', 'UpdateShop', request, UpdateShopResponse());

  /// Lists the shops in the caller's partition.
  $async.Future<ListShopsResponse> listShops(
          $pb.ClientContext? ctx, ListShopsRequest request) =>
      _client.invoke<ListShopsResponse>(
          ctx, 'CommerceService', 'ListShops', request, ListShopsResponse());

  /// Resolves the currency the caller most likely trades in: their currency
  /// setting, else the locale of the device they are signed in on, else the
  /// country of their first profile address. CreateShop applies the same
  /// default when no currency is given.
  $async.Future<ResolveDefaultCurrencyResponse> resolveDefaultCurrency(
          $pb.ClientContext? ctx, ResolveDefaultCurrencyRequest request) =>
      _client.invoke<ResolveDefaultCurrencyResponse>(ctx, 'CommerceService',
          'ResolveDefaultCurrency', request, ResolveDefaultCurrencyResponse());

  /// Creates a new product in the catalog.
  $async.Future<CreateProductResponse> createProduct(
          $pb.ClientContext? ctx, CreateProductRequest request) =>
      _client.invoke<CreateProductResponse>(ctx, 'CommerceService',
          'CreateProduct', request, CreateProductResponse());

  /// Retrieves a product by its ID.
  $async.Future<GetProductResponse> getProduct(
          $pb.ClientContext? ctx, GetProductRequest request) =>
      _client.invoke<GetProductResponse>(
          ctx, 'CommerceService', 'GetProduct', request, GetProductResponse());

  /// Lists products belonging to a shop, with optional search and filtering.
  $async.Future<ListProductsResponse> listProducts(
          $pb.ClientContext? ctx, ListProductsRequest request) =>
      _client.invoke<ListProductsResponse>(ctx, 'CommerceService',
          'ListProducts', request, ListProductsResponse());

  /// Creates a new variant for a product.
  $async.Future<CreateProductVariantResponse> createProductVariant(
          $pb.ClientContext? ctx, CreateProductVariantRequest request) =>
      _client.invoke<CreateProductVariantResponse>(ctx, 'CommerceService',
          'CreateProductVariant', request, CreateProductVariantResponse());

  /// Updates an existing product variant.
  $async.Future<UpdateProductVariantResponse> updateProductVariant(
          $pb.ClientContext? ctx, UpdateProductVariantRequest request) =>
      _client.invoke<UpdateProductVariantResponse>(ctx, 'CommerceService',
          'UpdateProductVariant', request, UpdateProductVariantResponse());

  /// Updates a product: details, fulfilment type, status, and its payment
  /// policy override.
  $async.Future<UpdateProductResponse> updateProduct(
          $pb.ClientContext? ctx, UpdateProductRequest request) =>
      _client.invoke<UpdateProductResponse>(ctx, 'CommerceService',
          'UpdateProduct', request, UpdateProductResponse());

  /// Lists the variants of a product.
  $async.Future<ListProductVariantsResponse> listProductVariants(
          $pb.ClientContext? ctx, ListProductVariantsRequest request) =>
      _client.invoke<ListProductVariantsResponse>(ctx, 'CommerceService',
          'ListProductVariants', request, ListProductVariantsResponse());

  /// Adds goods received from a supplier to a variant's stock. Internal: the
  /// procurement service calls it once per goods receipt line, and a repeated
  /// reference adds nothing (it answers with the stock as it stands).
  $async.Future<ReceiveStockResponse> receiveStock(
          $pb.ClientContext? ctx, ReceiveStockRequest request) =>
      _client.invoke<ReceiveStockResponse>(ctx, 'CommerceService',
          'ReceiveStock', request, ReceiveStockResponse());
  $async.Future<CreateCartResponse> createCart(
          $pb.ClientContext? ctx, CreateCartRequest request) =>
      _client.invoke<CreateCartResponse>(
          ctx, 'CommerceService', 'CreateCart', request, CreateCartResponse());
  $async.Future<GetCartResponse> getCart(
          $pb.ClientContext? ctx, GetCartRequest request) =>
      _client.invoke<GetCartResponse>(
          ctx, 'CommerceService', 'GetCart', request, GetCartResponse());
  $async.Future<AddCartLineResponse> addCartLine(
          $pb.ClientContext? ctx, AddCartLineRequest request) =>
      _client.invoke<AddCartLineResponse>(ctx, 'CommerceService', 'AddCartLine',
          request, AddCartLineResponse());
  $async.Future<RemoveCartLineResponse> removeCartLine(
          $pb.ClientContext? ctx, RemoveCartLineRequest request) =>
      _client.invoke<RemoveCartLineResponse>(ctx, 'CommerceService',
          'RemoveCartLine', request, RemoveCartLineResponse());
  $async.Future<CreateOrderFromCartResponse> createOrderFromCart(
          $pb.ClientContext? ctx, CreateOrderFromCartRequest request) =>
      _client.invoke<CreateOrderFromCartResponse>(ctx, 'CommerceService',
          'CreateOrderFromCart', request, CreateOrderFromCartResponse());

  ///
  /// Creates an order and reserves stock atomically.
  ///
  /// The server MUST:
  /// - validate all variants belong to the shop
  /// - validate sufficient stock
  /// - decrement stock
  /// - snapshot price and name
  /// - compute totals
  ///
  /// The order is created in CONFIRMED state
  /// (since this API does not handle payments).
  $async.Future<CreateOrderResponse> createOrder(
          $pb.ClientContext? ctx, CreateOrderRequest request) =>
      _client.invoke<CreateOrderResponse>(ctx, 'CommerceService', 'CreateOrder',
          request, CreateOrderResponse());

  /// Retrieves an order by ID.
  $async.Future<GetOrderResponse> getOrder(
          $pb.ClientContext? ctx, GetOrderRequest request) =>
      _client.invoke<GetOrderResponse>(
          ctx, 'CommerceService', 'GetOrder', request, GetOrderResponse());

  /// Lists orders for a shop, with optional search and filtering.
  $async.Future<ListOrdersResponse> listOrders(
          $pb.ClientContext? ctx, ListOrdersRequest request) =>
      _client.invoke<ListOrdersResponse>(
          ctx, 'CommerceService', 'ListOrders', request, ListOrdersResponse());

  /// Starts payment for an order: creates a hosted checkout session and
  /// returns the page the buyer should be sent to. Idempotent per order.
  $async.Future<CheckoutOrderResponse> checkoutOrder(
          $pb.ClientContext? ctx, CheckoutOrderRequest request) =>
      _client.invoke<CheckoutOrderResponse>(ctx, 'CommerceService',
          'CheckoutOrder', request, CheckoutOrderResponse());

  /// Marks an order paid after verifying the checkout session with the
  /// payment service. Safe to call repeatedly; used by staff and by the
  /// scheduled reconciler.
  $async.Future<ConfirmOrderPaymentResponse> confirmOrderPayment(
          $pb.ClientContext? ctx, ConfirmOrderPaymentRequest request) =>
      _client.invoke<ConfirmOrderPaymentResponse>(ctx, 'CommerceService',
          'ConfirmOrderPayment', request, ConfirmOrderPaymentResponse());

  /// Cancels an unfulfilled order and returns its stock. Buyers may cancel
  /// their own unpaid orders; staff may cancel any unfulfilled order.
  $async.Future<CancelOrderResponse> cancelOrder(
          $pb.ClientContext? ctx, CancelOrderRequest request) =>
      _client.invoke<CancelOrderResponse>(ctx, 'CommerceService', 'CancelOrder',
          request, CancelOrderResponse());

  /// Records a payment the shop took itself (cash, bank transfer, a till) as
  /// an instalment against the order. Staff only. A reference already
  /// recorded on the order is returned as-is, so retries are safe.
  $async.Future<RecordOrderPaymentResponse> recordOrderPayment(
          $pb.ClientContext? ctx, RecordOrderPaymentRequest request) =>
      _client.invoke<RecordOrderPaymentResponse>(ctx, 'CommerceService',
          'RecordOrderPayment', request, RecordOrderPaymentResponse());

  /// Settles a refund the payment service failed: send it again, or record
  /// that the shop paid the buyer back itself. Staff only.
  $async.Future<ResolveOrderRefundResponse> resolveOrderRefund(
          $pb.ClientContext? ctx, ResolveOrderRefundRequest request) =>
      _client.invoke<ResolveOrderRefundResponse>(ctx, 'CommerceService',
          'ResolveOrderRefund', request, ResolveOrderRefundResponse());

  /// Lists payment and lifecycle signals for an order, or for every order in
  /// a shop, oldest first. The same events are pushed to the shop's webhook.
  $async.Future<ListOrderEventsResponse> listOrderEvents(
          $pb.ClientContext? ctx, ListOrderEventsRequest request) =>
      _client.invoke<ListOrderEventsResponse>(ctx, 'CommerceService',
          'ListOrderEvents', request, ListOrderEventsResponse());

  /// Reconciles orders awaiting payment against the payment service and
  /// expires reservations whose payment window has lapsed. Scheduled.
  $async.Future<ReconcilePaymentsResponse> reconcilePayments(
          $pb.ClientContext? ctx, ReconcilePaymentsRequest request) =>
      _client.invoke<ReconcilePaymentsResponse>(ctx, 'CommerceService',
          'ReconcilePayments', request, ReconcilePaymentsResponse());

  /// Posts one balanced ledger transaction per shop for a trading day,
  /// merging that day's paid and refunded orders. Scheduled end of day.
  $async.Future<RunEndOfDayLedgerResponse> runEndOfDayLedger(
          $pb.ClientContext? ctx, RunEndOfDayLedgerRequest request) =>
      _client.invoke<RunEndOfDayLedgerResponse>(ctx, 'CommerceService',
          'RunEndOfDayLedger', request, RunEndOfDayLedgerResponse());

  ///
  /// Creates a fulfilment for an order.
  ///
  /// A fulfilment may contain a subset of order lines.
  /// Quantity per line MUST NOT exceed remaining unfulfilled quantity.
  $async.Future<CreateFulfilmentResponse> createFulfilment(
          $pb.ClientContext? ctx, CreateFulfilmentRequest request) =>
      _client.invoke<CreateFulfilmentResponse>(ctx, 'CommerceService',
          'CreateFulfilment', request, CreateFulfilmentResponse());

  /// Updates a fulfilment (e.g. adding tracking number, marking as shipped).
  $async.Future<UpdateFulfilmentResponse> updateFulfilment(
          $pb.ClientContext? ctx, UpdateFulfilmentRequest request) =>
      _client.invoke<UpdateFulfilmentResponse>(ctx, 'CommerceService',
          'UpdateFulfilment', request, UpdateFulfilmentResponse());

  /// Retrieves a fulfilment by ID.
  $async.Future<GetFulfilmentResponse> getFulfilment(
          $pb.ClientContext? ctx, GetFulfilmentRequest request) =>
      _client.invoke<GetFulfilmentResponse>(ctx, 'CommerceService',
          'GetFulfilment', request, GetFulfilmentResponse());

  /// Lists an order's fulfilments, oldest first.
  $async.Future<ListFulfilmentsResponse> listFulfilments(
          $pb.ClientContext? ctx, ListFulfilmentsRequest request) =>
      _client.invoke<ListFulfilmentsResponse>(ctx, 'CommerceService',
          'ListFulfilments', request, ListFulfilmentsResponse());

  /// Creates or updates a price list.
  $async.Future<PriceListSaveResponse> priceListSave(
          $pb.ClientContext? ctx, PriceListSaveRequest request) =>
      _client.invoke<PriceListSaveResponse>(ctx, 'CommerceService',
          'PriceListSave', request, PriceListSaveResponse());

  /// Retrieves a price list by ID.
  $async.Future<PriceListGetResponse> priceListGet(
          $pb.ClientContext? ctx, PriceListGetRequest request) =>
      _client.invoke<PriceListGetResponse>(ctx, 'CommerceService',
          'PriceListGet', request, PriceListGetResponse());

  /// Searches price lists for a shop.
  $async.Future<PriceListSearchResponse> priceListSearch(
          $pb.ClientContext? ctx, PriceListSearchRequest request) =>
      _client.invoke<PriceListSearchResponse>(ctx, 'CommerceService',
          'PriceListSearch', request, PriceListSearchResponse());

  /// Replaces all entries for the given variants in a price list.
  $async.Future<PriceListEntryBatchSaveResponse> priceListEntryBatchSave(
          $pb.ClientContext? ctx, PriceListEntryBatchSaveRequest request) =>
      _client.invoke<PriceListEntryBatchSaveResponse>(
          ctx,
          'CommerceService',
          'PriceListEntryBatchSave',
          request,
          PriceListEntryBatchSaveResponse());

  /// Creates or updates a customer-to-price-list assignment.
  $async.Future<CustomerPriceListAssignmentSaveResponse>
      customerPriceListAssignmentSave($pb.ClientContext? ctx,
              CustomerPriceListAssignmentSaveRequest request) =>
          _client.invoke<CustomerPriceListAssignmentSaveResponse>(
              ctx,
              'CommerceService',
              'CustomerPriceListAssignmentSave',
              request,
              CustomerPriceListAssignmentSaveResponse());

  /// Searches customer price list assignments.
  $async.Future<CustomerPriceListAssignmentSearchResponse>
      customerPriceListAssignmentSearch($pb.ClientContext? ctx,
              CustomerPriceListAssignmentSearchRequest request) =>
          _client.invoke<CustomerPriceListAssignmentSearchResponse>(
              ctx,
              'CommerceService',
              'CustomerPriceListAssignmentSearch',
              request,
              CustomerPriceListAssignmentSearchResponse());

  /// Creates or updates a customer price override for a specific variant.
  $async.Future<CustomerPriceOverrideSaveResponse> customerPriceOverrideSave(
          $pb.ClientContext? ctx, CustomerPriceOverrideSaveRequest request) =>
      _client.invoke<CustomerPriceOverrideSaveResponse>(
          ctx,
          'CommerceService',
          'CustomerPriceOverrideSave',
          request,
          CustomerPriceOverrideSaveResponse());

  /// Searches customer price overrides.
  $async.Future<CustomerPriceOverrideSearchResponse>
      customerPriceOverrideSearch($pb.ClientContext? ctx,
              CustomerPriceOverrideSearchRequest request) =>
          _client.invoke<CustomerPriceOverrideSearchResponse>(
              ctx,
              'CommerceService',
              'CustomerPriceOverrideSearch',
              request,
              CustomerPriceOverrideSearchResponse());

  /// Creates or updates a discount rule.
  $async.Future<DiscountRuleSaveResponse> discountRuleSave(
          $pb.ClientContext? ctx, DiscountRuleSaveRequest request) =>
      _client.invoke<DiscountRuleSaveResponse>(ctx, 'CommerceService',
          'DiscountRuleSave', request, DiscountRuleSaveResponse());

  /// Searches discount rules for a shop.
  $async.Future<DiscountRuleSearchResponse> discountRuleSearch(
          $pb.ClientContext? ctx, DiscountRuleSearchRequest request) =>
      _client.invoke<DiscountRuleSearchResponse>(ctx, 'CommerceService',
          'DiscountRuleSearch', request, DiscountRuleSearchResponse());

  /// Approves a discount rule that requires approval, so pricing may apply
  /// it automatically.
  $async.Future<DiscountRuleApproveResponse> discountRuleApprove(
          $pb.ClientContext? ctx, DiscountRuleApproveRequest request) =>
      _client.invoke<DiscountRuleApproveResponse>(ctx, 'CommerceService',
          'DiscountRuleApprove', request, DiscountRuleApproveResponse());

  /// Resolves the effective price for a variant given customer and quantity context.
  $async.Future<ResolvePriceResponse> resolvePrice(
          $pb.ClientContext? ctx, ResolvePriceRequest request) =>
      _client.invoke<ResolvePriceResponse>(ctx, 'CommerceService',
          'ResolvePrice', request, ResolvePriceResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
