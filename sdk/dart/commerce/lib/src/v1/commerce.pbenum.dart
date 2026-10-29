// This is a generated file - do not edit.
//
// Generated from v1/commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ShopStatus extends $pb.ProtobufEnum {
  static const ShopStatus SHOP_STATUS_UNSPECIFIED =
      ShopStatus._(0, _omitEnumNames ? '' : 'SHOP_STATUS_UNSPECIFIED');
  static const ShopStatus SHOP_STATUS_ACTIVE =
      ShopStatus._(1, _omitEnumNames ? '' : 'SHOP_STATUS_ACTIVE');
  static const ShopStatus SHOP_STATUS_DISABLED =
      ShopStatus._(2, _omitEnumNames ? '' : 'SHOP_STATUS_DISABLED');

  static const $core.List<ShopStatus> values = <ShopStatus>[
    SHOP_STATUS_UNSPECIFIED,
    SHOP_STATUS_ACTIVE,
    SHOP_STATUS_DISABLED,
  ];

  static final $core.List<ShopStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ShopStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ShopStatus._(super.value, super.name);
}

/// Where a resolved default currency came from.
class CurrencySource extends $pb.ProtobufEnum {
  static const CurrencySource CURRENCY_SOURCE_UNSPECIFIED =
      CurrencySource._(0, _omitEnumNames ? '' : 'CURRENCY_SOURCE_UNSPECIFIED');

  /// The caller's "currency" setting in the settings service.
  static const CurrencySource CURRENCY_SOURCE_PREFERENCE =
      CurrencySource._(1, _omitEnumNames ? '' : 'CURRENCY_SOURCE_PREFERENCE');

  /// The locale of the device the caller is signed in on.
  static const CurrencySource CURRENCY_SOURCE_DEVICE =
      CurrencySource._(2, _omitEnumNames ? '' : 'CURRENCY_SOURCE_DEVICE');

  /// The country of the caller's first profile address.
  static const CurrencySource CURRENCY_SOURCE_ADDRESS =
      CurrencySource._(3, _omitEnumNames ? '' : 'CURRENCY_SOURCE_ADDRESS');

  /// Nothing was known about the caller; the platform default applies.
  static const CurrencySource CURRENCY_SOURCE_PLATFORM_DEFAULT =
      CurrencySource._(
          4, _omitEnumNames ? '' : 'CURRENCY_SOURCE_PLATFORM_DEFAULT');

  static const $core.List<CurrencySource> values = <CurrencySource>[
    CURRENCY_SOURCE_UNSPECIFIED,
    CURRENCY_SOURCE_PREFERENCE,
    CURRENCY_SOURCE_DEVICE,
    CURRENCY_SOURCE_ADDRESS,
    CURRENCY_SOURCE_PLATFORM_DEFAULT,
  ];

  static final $core.List<CurrencySource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CurrencySource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CurrencySource._(super.value, super.name);
}

class ProductStatus extends $pb.ProtobufEnum {
  static const ProductStatus PRODUCT_STATUS_UNSPECIFIED =
      ProductStatus._(0, _omitEnumNames ? '' : 'PRODUCT_STATUS_UNSPECIFIED');
  static const ProductStatus PRODUCT_STATUS_ACTIVE =
      ProductStatus._(1, _omitEnumNames ? '' : 'PRODUCT_STATUS_ACTIVE');
  static const ProductStatus PRODUCT_STATUS_INACTIVE =
      ProductStatus._(2, _omitEnumNames ? '' : 'PRODUCT_STATUS_INACTIVE');
  static const ProductStatus PRODUCT_STATUS_ARCHIVED =
      ProductStatus._(3, _omitEnumNames ? '' : 'PRODUCT_STATUS_ARCHIVED');

  static const $core.List<ProductStatus> values = <ProductStatus>[
    PRODUCT_STATUS_UNSPECIFIED,
    PRODUCT_STATUS_ACTIVE,
    PRODUCT_STATUS_INACTIVE,
    PRODUCT_STATUS_ARCHIVED,
  ];

  static final $core.List<ProductStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ProductStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProductStatus._(super.value, super.name);
}

class FulfilmentType extends $pb.ProtobufEnum {
  static const FulfilmentType FULFILMENT_TYPE_UNSPECIFIED =
      FulfilmentType._(0, _omitEnumNames ? '' : 'FULFILMENT_TYPE_UNSPECIFIED');

  /// Requires shipping / physical handling
  static const FulfilmentType FULFILMENT_TYPE_PHYSICAL =
      FulfilmentType._(1, _omitEnumNames ? '' : 'FULFILMENT_TYPE_PHYSICAL');

  /// Delivered digitally (license, download, access, etc)
  static const FulfilmentType FULFILMENT_TYPE_DIGITAL =
      FulfilmentType._(2, _omitEnumNames ? '' : 'FULFILMENT_TYPE_DIGITAL');

  /// No fulfilment at all (donations, subscriptions started elsewhere, etc)
  static const FulfilmentType FULFILMENT_TYPE_NONE =
      FulfilmentType._(3, _omitEnumNames ? '' : 'FULFILMENT_TYPE_NONE');

  static const $core.List<FulfilmentType> values = <FulfilmentType>[
    FULFILMENT_TYPE_UNSPECIFIED,
    FULFILMENT_TYPE_PHYSICAL,
    FULFILMENT_TYPE_DIGITAL,
    FULFILMENT_TYPE_NONE,
  ];

  static final $core.List<FulfilmentType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static FulfilmentType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FulfilmentType._(super.value, super.name);
}

class ProductVariantStatus extends $pb.ProtobufEnum {
  static const ProductVariantStatus PRODUCT_VARIANT_STATUS_UNSPECIFIED =
      ProductVariantStatus._(
          0, _omitEnumNames ? '' : 'PRODUCT_VARIANT_STATUS_UNSPECIFIED');
  static const ProductVariantStatus PRODUCT_VARIANT_STATUS_ACTIVE =
      ProductVariantStatus._(
          1, _omitEnumNames ? '' : 'PRODUCT_VARIANT_STATUS_ACTIVE');
  static const ProductVariantStatus PRODUCT_VARIANT_STATUS_DISABLED =
      ProductVariantStatus._(
          2, _omitEnumNames ? '' : 'PRODUCT_VARIANT_STATUS_DISABLED');

  static const $core.List<ProductVariantStatus> values = <ProductVariantStatus>[
    PRODUCT_VARIANT_STATUS_UNSPECIFIED,
    PRODUCT_VARIANT_STATUS_ACTIVE,
    PRODUCT_VARIANT_STATUS_DISABLED,
  ];

  static final $core.List<ProductVariantStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ProductVariantStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProductVariantStatus._(super.value, super.name);
}

class CartStatus extends $pb.ProtobufEnum {
  static const CartStatus CART_STATUS_UNSPECIFIED =
      CartStatus._(0, _omitEnumNames ? '' : 'CART_STATUS_UNSPECIFIED');
  static const CartStatus CART_STATUS_ACTIVE =
      CartStatus._(1, _omitEnumNames ? '' : 'CART_STATUS_ACTIVE');
  static const CartStatus CART_STATUS_CONVERTED =
      CartStatus._(2, _omitEnumNames ? '' : 'CART_STATUS_CONVERTED');
  static const CartStatus CART_STATUS_ABANDONED =
      CartStatus._(3, _omitEnumNames ? '' : 'CART_STATUS_ABANDONED');
  static const CartStatus CART_STATUS_EXPIRED =
      CartStatus._(4, _omitEnumNames ? '' : 'CART_STATUS_EXPIRED');

  static const $core.List<CartStatus> values = <CartStatus>[
    CART_STATUS_UNSPECIFIED,
    CART_STATUS_ACTIVE,
    CART_STATUS_CONVERTED,
    CART_STATUS_ABANDONED,
    CART_STATUS_EXPIRED,
  ];

  static final $core.List<CartStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CartStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CartStatus._(super.value, super.name);
}

class OrderRefundStatus extends $pb.ProtobufEnum {
  static const OrderRefundStatus ORDER_REFUND_STATUS_UNSPECIFIED =
      OrderRefundStatus._(
          0, _omitEnumNames ? '' : 'ORDER_REFUND_STATUS_UNSPECIFIED');

  /// Raised; sent to the payment service on the next run.
  static const OrderRefundStatus ORDER_REFUND_STATUS_PENDING =
      OrderRefundStatus._(
          1, _omitEnumNames ? '' : 'ORDER_REFUND_STATUS_PENDING');

  /// The payment service holds it; confirmed once the money arrives.
  static const OrderRefundStatus ORDER_REFUND_STATUS_SENT =
      OrderRefundStatus._(2, _omitEnumNames ? '' : 'ORDER_REFUND_STATUS_SENT');

  /// The buyer has been paid back.
  static const OrderRefundStatus ORDER_REFUND_STATUS_CONFIRMED =
      OrderRefundStatus._(
          3, _omitEnumNames ? '' : 'ORDER_REFUND_STATUS_CONFIRMED');

  /// The payment service could not pay it; staff resolve it
  /// (ResolveOrderRefund).
  static const OrderRefundStatus ORDER_REFUND_STATUS_FAILED =
      OrderRefundStatus._(
          4, _omitEnumNames ? '' : 'ORDER_REFUND_STATUS_FAILED');

  static const $core.List<OrderRefundStatus> values = <OrderRefundStatus>[
    ORDER_REFUND_STATUS_UNSPECIFIED,
    ORDER_REFUND_STATUS_PENDING,
    ORDER_REFUND_STATUS_SENT,
    ORDER_REFUND_STATUS_CONFIRMED,
    ORDER_REFUND_STATUS_FAILED,
  ];

  static final $core.List<OrderRefundStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static OrderRefundStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderRefundStatus._(super.value, super.name);
}

/// How staff settle a refund the payment service failed.
class OrderRefundResolution extends $pb.ProtobufEnum {
  static const OrderRefundResolution ORDER_REFUND_RESOLUTION_UNSPECIFIED =
      OrderRefundResolution._(
          0, _omitEnumNames ? '' : 'ORDER_REFUND_RESOLUTION_UNSPECIFIED');

  /// Send it again, as a new payment; it goes back to PENDING and is sent
  /// straight away.
  static const OrderRefundResolution ORDER_REFUND_RESOLUTION_RETRY =
      OrderRefundResolution._(
          1, _omitEnumNames ? '' : 'ORDER_REFUND_RESOLUTION_RETRY');

  /// The shop paid the buyer back itself; the refund is confirmed.
  static const OrderRefundResolution ORDER_REFUND_RESOLUTION_PAID_BACK =
      OrderRefundResolution._(
          2, _omitEnumNames ? '' : 'ORDER_REFUND_RESOLUTION_PAID_BACK');

  static const $core.List<OrderRefundResolution> values =
      <OrderRefundResolution>[
    ORDER_REFUND_RESOLUTION_UNSPECIFIED,
    ORDER_REFUND_RESOLUTION_RETRY,
    ORDER_REFUND_RESOLUTION_PAID_BACK,
  ];

  static final $core.List<OrderRefundResolution?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static OrderRefundResolution? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderRefundResolution._(super.value, super.name);
}

class OrderPaymentSource extends $pb.ProtobufEnum {
  static const OrderPaymentSource ORDER_PAYMENT_SOURCE_UNSPECIFIED =
      OrderPaymentSource._(
          0, _omitEnumNames ? '' : 'ORDER_PAYMENT_SOURCE_UNSPECIFIED');

  /// Paid through hosted checkout.
  static const OrderPaymentSource ORDER_PAYMENT_SOURCE_CHECKOUT =
      OrderPaymentSource._(
          1, _omitEnumNames ? '' : 'ORDER_PAYMENT_SOURCE_CHECKOUT');

  /// Taken by the shop and recorded by staff.
  static const OrderPaymentSource ORDER_PAYMENT_SOURCE_RECORDED =
      OrderPaymentSource._(
          2, _omitEnumNames ? '' : 'ORDER_PAYMENT_SOURCE_RECORDED');

  static const $core.List<OrderPaymentSource> values = <OrderPaymentSource>[
    ORDER_PAYMENT_SOURCE_UNSPECIFIED,
    ORDER_PAYMENT_SOURCE_CHECKOUT,
    ORDER_PAYMENT_SOURCE_RECORDED,
  ];

  static final $core.List<OrderPaymentSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static OrderPaymentSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderPaymentSource._(super.value, super.name);
}

class OrderStatus extends $pb.ProtobufEnum {
  static const OrderStatus ORDER_STATUS_UNSPECIFIED =
      OrderStatus._(0, _omitEnumNames ? '' : 'ORDER_STATUS_UNSPECIFIED');

  /// Stock has been reserved and the order is ready for fulfilment.
  static const OrderStatus ORDER_STATUS_CONFIRMED =
      OrderStatus._(1, _omitEnumNames ? '' : 'ORDER_STATUS_CONFIRMED');
  static const OrderStatus ORDER_STATUS_CANCELLED =
      OrderStatus._(2, _omitEnumNames ? '' : 'ORDER_STATUS_CANCELLED');

  /// All quantities across all order lines have been fulfilled.
  static const OrderStatus ORDER_STATUS_FULFILLED =
      OrderStatus._(3, _omitEnumNames ? '' : 'ORDER_STATUS_FULFILLED');

  /// Stock is reserved and the buyer has a checkout session to complete.
  static const OrderStatus ORDER_STATUS_PENDING_PAYMENT =
      OrderStatus._(4, _omitEnumNames ? '' : 'ORDER_STATUS_PENDING_PAYMENT');

  static const $core.List<OrderStatus> values = <OrderStatus>[
    ORDER_STATUS_UNSPECIFIED,
    ORDER_STATUS_CONFIRMED,
    ORDER_STATUS_CANCELLED,
    ORDER_STATUS_FULFILLED,
    ORDER_STATUS_PENDING_PAYMENT,
  ];

  static final $core.List<OrderStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static OrderStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderStatus._(super.value, super.name);
}

class PaymentStatus extends $pb.ProtobufEnum {
  static const PaymentStatus PAYMENT_STATUS_UNSPECIFIED =
      PaymentStatus._(0, _omitEnumNames ? '' : 'PAYMENT_STATUS_UNSPECIFIED');
  static const PaymentStatus PAYMENT_STATUS_PENDING =
      PaymentStatus._(1, _omitEnumNames ? '' : 'PAYMENT_STATUS_PENDING');
  static const PaymentStatus PAYMENT_STATUS_PAID =
      PaymentStatus._(2, _omitEnumNames ? '' : 'PAYMENT_STATUS_PAID');
  static const PaymentStatus PAYMENT_STATUS_FAILED =
      PaymentStatus._(3, _omitEnumNames ? '' : 'PAYMENT_STATUS_FAILED');
  static const PaymentStatus PAYMENT_STATUS_REFUNDED =
      PaymentStatus._(4, _omitEnumNames ? '' : 'PAYMENT_STATUS_REFUNDED');

  /// Payment window lapsed without completion; stock was released.
  static const PaymentStatus PAYMENT_STATUS_EXPIRED =
      PaymentStatus._(5, _omitEnumNames ? '' : 'PAYMENT_STATUS_EXPIRED');

  /// At least one instalment is paid and a balance remains.
  static const PaymentStatus PAYMENT_STATUS_PARTIALLY_PAID =
      PaymentStatus._(6, _omitEnumNames ? '' : 'PAYMENT_STATUS_PARTIALLY_PAID');

  /// The order was cancelled after money arrived; the refund to the buyer
  /// has been raised with the payment service and is not yet confirmed.
  /// REFUNDED follows once every refund is confirmed.
  static const PaymentStatus PAYMENT_STATUS_REFUND_PENDING =
      PaymentStatus._(7, _omitEnumNames ? '' : 'PAYMENT_STATUS_REFUND_PENDING');

  static const $core.List<PaymentStatus> values = <PaymentStatus>[
    PAYMENT_STATUS_UNSPECIFIED,
    PAYMENT_STATUS_PENDING,
    PAYMENT_STATUS_PAID,
    PAYMENT_STATUS_FAILED,
    PAYMENT_STATUS_REFUNDED,
    PAYMENT_STATUS_EXPIRED,
    PAYMENT_STATUS_PARTIALLY_PAID,
    PAYMENT_STATUS_REFUND_PENDING,
  ];

  static final $core.List<PaymentStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static PaymentStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PaymentStatus._(super.value, super.name);
}

class OrderEventType extends $pb.ProtobufEnum {
  static const OrderEventType ORDER_EVENT_TYPE_UNSPECIFIED =
      OrderEventType._(0, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_UNSPECIFIED');

  /// An instalment was applied.
  static const OrderEventType ORDER_EVENT_TYPE_PAYMENT_RECEIVED =
      OrderEventType._(
          1, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_PAYMENT_RECEIVED');

  /// The first instalment was applied; stock is held until the balance
  /// deadline.
  static const OrderEventType ORDER_EVENT_TYPE_DEPOSIT_PAID = OrderEventType._(
      2, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_DEPOSIT_PAID');

  /// Payment crossed one of the policy's signal thresholds.
  static const OrderEventType ORDER_EVENT_TYPE_THRESHOLD_CROSSED =
      OrderEventType._(
          3, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_THRESHOLD_CROSSED');

  /// The paid share reached the policy's fulfilment mark.
  static const OrderEventType ORDER_EVENT_TYPE_FULFILMENT_RELEASED =
      OrderEventType._(
          4, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_FULFILMENT_RELEASED');

  /// The order is paid in full.
  static const OrderEventType ORDER_EVENT_TYPE_FULLY_PAID =
      OrderEventType._(5, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_FULLY_PAID');

  /// The balance deadline passed with money still owed.
  static const OrderEventType ORDER_EVENT_TYPE_BALANCE_OVERDUE =
      OrderEventType._(
          6, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_BALANCE_OVERDUE');

  /// More was paid than the order total; the excess needs refunding.
  static const OrderEventType ORDER_EVENT_TYPE_OVERPAID =
      OrderEventType._(7, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_OVERPAID');
  static const OrderEventType ORDER_EVENT_TYPE_CANCELLED =
      OrderEventType._(8, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_CANCELLED');

  /// The payment window lapsed before anything was paid.
  static const OrderEventType ORDER_EVENT_TYPE_EXPIRED =
      OrderEventType._(9, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_EXPIRED');

  /// A refund to the buyer was confirmed by the payment service.
  static const OrderEventType ORDER_EVENT_TYPE_REFUNDED =
      OrderEventType._(10, _omitEnumNames ? '' : 'ORDER_EVENT_TYPE_REFUNDED');

  static const $core.List<OrderEventType> values = <OrderEventType>[
    ORDER_EVENT_TYPE_UNSPECIFIED,
    ORDER_EVENT_TYPE_PAYMENT_RECEIVED,
    ORDER_EVENT_TYPE_DEPOSIT_PAID,
    ORDER_EVENT_TYPE_THRESHOLD_CROSSED,
    ORDER_EVENT_TYPE_FULFILMENT_RELEASED,
    ORDER_EVENT_TYPE_FULLY_PAID,
    ORDER_EVENT_TYPE_BALANCE_OVERDUE,
    ORDER_EVENT_TYPE_OVERPAID,
    ORDER_EVENT_TYPE_CANCELLED,
    ORDER_EVENT_TYPE_EXPIRED,
    ORDER_EVENT_TYPE_REFUNDED,
  ];

  static final $core.List<OrderEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static OrderEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderEventType._(super.value, super.name);
}

class OrderEventDelivery extends $pb.ProtobufEnum {
  static const OrderEventDelivery ORDER_EVENT_DELIVERY_UNSPECIFIED =
      OrderEventDelivery._(
          0, _omitEnumNames ? '' : 'ORDER_EVENT_DELIVERY_UNSPECIFIED');

  /// The shop has no webhook.
  static const OrderEventDelivery ORDER_EVENT_DELIVERY_NOT_REQUIRED =
      OrderEventDelivery._(
          1, _omitEnumNames ? '' : 'ORDER_EVENT_DELIVERY_NOT_REQUIRED');
  static const OrderEventDelivery ORDER_EVENT_DELIVERY_PENDING =
      OrderEventDelivery._(
          2, _omitEnumNames ? '' : 'ORDER_EVENT_DELIVERY_PENDING');
  static const OrderEventDelivery ORDER_EVENT_DELIVERY_DELIVERED =
      OrderEventDelivery._(
          3, _omitEnumNames ? '' : 'ORDER_EVENT_DELIVERY_DELIVERED');

  /// Retries are exhausted.
  static const OrderEventDelivery ORDER_EVENT_DELIVERY_FAILED =
      OrderEventDelivery._(
          4, _omitEnumNames ? '' : 'ORDER_EVENT_DELIVERY_FAILED');

  static const $core.List<OrderEventDelivery> values = <OrderEventDelivery>[
    ORDER_EVENT_DELIVERY_UNSPECIFIED,
    ORDER_EVENT_DELIVERY_NOT_REQUIRED,
    ORDER_EVENT_DELIVERY_PENDING,
    ORDER_EVENT_DELIVERY_DELIVERED,
    ORDER_EVENT_DELIVERY_FAILED,
  ];

  static final $core.List<OrderEventDelivery?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static OrderEventDelivery? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderEventDelivery._(super.value, super.name);
}

class FulfilmentStatus extends $pb.ProtobufEnum {
  static const FulfilmentStatus FULFILMENT_STATUS_UNSPECIFIED =
      FulfilmentStatus._(
          0, _omitEnumNames ? '' : 'FULFILMENT_STATUS_UNSPECIFIED');
  static const FulfilmentStatus FULFILMENT_STATUS_PENDING =
      FulfilmentStatus._(1, _omitEnumNames ? '' : 'FULFILMENT_STATUS_PENDING');
  static const FulfilmentStatus FULFILMENT_STATUS_PREPARING =
      FulfilmentStatus._(
          2, _omitEnumNames ? '' : 'FULFILMENT_STATUS_PREPARING');
  static const FulfilmentStatus FULFILMENT_STATUS_PACKED =
      FulfilmentStatus._(3, _omitEnumNames ? '' : 'FULFILMENT_STATUS_PACKED');
  static const FulfilmentStatus FULFILMENT_STATUS_SHIPPED =
      FulfilmentStatus._(4, _omitEnumNames ? '' : 'FULFILMENT_STATUS_SHIPPED');
  static const FulfilmentStatus FULFILMENT_STATUS_DELIVERED =
      FulfilmentStatus._(
          5, _omitEnumNames ? '' : 'FULFILMENT_STATUS_DELIVERED');
  static const FulfilmentStatus FULFILMENT_STATUS_CANCELLED =
      FulfilmentStatus._(
          6, _omitEnumNames ? '' : 'FULFILMENT_STATUS_CANCELLED');

  static const $core.List<FulfilmentStatus> values = <FulfilmentStatus>[
    FULFILMENT_STATUS_UNSPECIFIED,
    FULFILMENT_STATUS_PENDING,
    FULFILMENT_STATUS_PREPARING,
    FULFILMENT_STATUS_PACKED,
    FULFILMENT_STATUS_SHIPPED,
    FULFILMENT_STATUS_DELIVERED,
    FULFILMENT_STATUS_CANCELLED,
  ];

  static final $core.List<FulfilmentStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static FulfilmentStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FulfilmentStatus._(super.value, super.name);
}

class PriceListStatus extends $pb.ProtobufEnum {
  static const PriceListStatus PRICE_LIST_STATUS_UNSPECIFIED =
      PriceListStatus._(
          0, _omitEnumNames ? '' : 'PRICE_LIST_STATUS_UNSPECIFIED');
  static const PriceListStatus PRICE_LIST_STATUS_ACTIVE =
      PriceListStatus._(1, _omitEnumNames ? '' : 'PRICE_LIST_STATUS_ACTIVE');
  static const PriceListStatus PRICE_LIST_STATUS_DRAFT =
      PriceListStatus._(2, _omitEnumNames ? '' : 'PRICE_LIST_STATUS_DRAFT');
  static const PriceListStatus PRICE_LIST_STATUS_EXPIRED =
      PriceListStatus._(3, _omitEnumNames ? '' : 'PRICE_LIST_STATUS_EXPIRED');

  static const $core.List<PriceListStatus> values = <PriceListStatus>[
    PRICE_LIST_STATUS_UNSPECIFIED,
    PRICE_LIST_STATUS_ACTIVE,
    PRICE_LIST_STATUS_DRAFT,
    PRICE_LIST_STATUS_EXPIRED,
  ];

  static final $core.List<PriceListStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PriceListStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PriceListStatus._(super.value, super.name);
}

class PriceSource extends $pb.ProtobufEnum {
  static const PriceSource PRICE_SOURCE_UNSPECIFIED =
      PriceSource._(0, _omitEnumNames ? '' : 'PRICE_SOURCE_UNSPECIFIED');
  static const PriceSource PRICE_SOURCE_CATALOG =
      PriceSource._(1, _omitEnumNames ? '' : 'PRICE_SOURCE_CATALOG');
  static const PriceSource PRICE_SOURCE_PRICE_LIST =
      PriceSource._(2, _omitEnumNames ? '' : 'PRICE_SOURCE_PRICE_LIST');
  static const PriceSource PRICE_SOURCE_CUSTOMER_OVERRIDE =
      PriceSource._(3, _omitEnumNames ? '' : 'PRICE_SOURCE_CUSTOMER_OVERRIDE');

  static const $core.List<PriceSource> values = <PriceSource>[
    PRICE_SOURCE_UNSPECIFIED,
    PRICE_SOURCE_CATALOG,
    PRICE_SOURCE_PRICE_LIST,
    PRICE_SOURCE_CUSTOMER_OVERRIDE,
  ];

  static final $core.List<PriceSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PriceSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PriceSource._(super.value, super.name);
}

class DiscountType extends $pb.ProtobufEnum {
  static const DiscountType DISCOUNT_TYPE_UNSPECIFIED =
      DiscountType._(0, _omitEnumNames ? '' : 'DISCOUNT_TYPE_UNSPECIFIED');
  static const DiscountType DISCOUNT_TYPE_PERCENTAGE =
      DiscountType._(1, _omitEnumNames ? '' : 'DISCOUNT_TYPE_PERCENTAGE');
  static const DiscountType DISCOUNT_TYPE_FIXED_AMOUNT =
      DiscountType._(2, _omitEnumNames ? '' : 'DISCOUNT_TYPE_FIXED_AMOUNT');

  static const $core.List<DiscountType> values = <DiscountType>[
    DISCOUNT_TYPE_UNSPECIFIED,
    DISCOUNT_TYPE_PERCENTAGE,
    DISCOUNT_TYPE_FIXED_AMOUNT,
  ];

  static final $core.List<DiscountType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DiscountType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiscountType._(super.value, super.name);
}

class DiscountAppliesTo extends $pb.ProtobufEnum {
  static const DiscountAppliesTo DISCOUNT_APPLIES_TO_UNSPECIFIED =
      DiscountAppliesTo._(
          0, _omitEnumNames ? '' : 'DISCOUNT_APPLIES_TO_UNSPECIFIED');
  static const DiscountAppliesTo DISCOUNT_APPLIES_TO_ORDER =
      DiscountAppliesTo._(1, _omitEnumNames ? '' : 'DISCOUNT_APPLIES_TO_ORDER');
  static const DiscountAppliesTo DISCOUNT_APPLIES_TO_LINE_ITEM =
      DiscountAppliesTo._(
          2, _omitEnumNames ? '' : 'DISCOUNT_APPLIES_TO_LINE_ITEM');

  static const $core.List<DiscountAppliesTo> values = <DiscountAppliesTo>[
    DISCOUNT_APPLIES_TO_UNSPECIFIED,
    DISCOUNT_APPLIES_TO_ORDER,
    DISCOUNT_APPLIES_TO_LINE_ITEM,
  ];

  static final $core.List<DiscountAppliesTo?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DiscountAppliesTo? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiscountAppliesTo._(super.value, super.name);
}

class DiscountRuleStatus extends $pb.ProtobufEnum {
  static const DiscountRuleStatus DISCOUNT_RULE_STATUS_UNSPECIFIED =
      DiscountRuleStatus._(
          0, _omitEnumNames ? '' : 'DISCOUNT_RULE_STATUS_UNSPECIFIED');
  static const DiscountRuleStatus DISCOUNT_RULE_STATUS_ACTIVE =
      DiscountRuleStatus._(
          1, _omitEnumNames ? '' : 'DISCOUNT_RULE_STATUS_ACTIVE');
  static const DiscountRuleStatus DISCOUNT_RULE_STATUS_INACTIVE =
      DiscountRuleStatus._(
          2, _omitEnumNames ? '' : 'DISCOUNT_RULE_STATUS_INACTIVE');

  static const $core.List<DiscountRuleStatus> values = <DiscountRuleStatus>[
    DISCOUNT_RULE_STATUS_UNSPECIFIED,
    DISCOUNT_RULE_STATUS_ACTIVE,
    DISCOUNT_RULE_STATUS_INACTIVE,
  ];

  static final $core.List<DiscountRuleStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DiscountRuleStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiscountRuleStatus._(super.value, super.name);
}

class CustomerPriceOverrideStatus extends $pb.ProtobufEnum {
  static const CustomerPriceOverrideStatus
      CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED =
      CustomerPriceOverrideStatus._(0,
          _omitEnumNames ? '' : 'CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED');
  static const CustomerPriceOverrideStatus
      CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE = CustomerPriceOverrideStatus._(
          1, _omitEnumNames ? '' : 'CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE');
  static const CustomerPriceOverrideStatus
      CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED = CustomerPriceOverrideStatus._(
          2, _omitEnumNames ? '' : 'CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED');

  static const $core.List<CustomerPriceOverrideStatus> values =
      <CustomerPriceOverrideStatus>[
    CUSTOMER_PRICE_OVERRIDE_STATUS_UNSPECIFIED,
    CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE,
    CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED,
  ];

  static final $core.List<CustomerPriceOverrideStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CustomerPriceOverrideStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CustomerPriceOverrideStatus._(super.value, super.name);
}

class CustomerPriceListAssignmentStatus extends $pb.ProtobufEnum {
  static const CustomerPriceListAssignmentStatus
      CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED =
      CustomerPriceListAssignmentStatus._(
          0,
          _omitEnumNames
              ? ''
              : 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED');
  static const CustomerPriceListAssignmentStatus
      CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE =
      CustomerPriceListAssignmentStatus._(1,
          _omitEnumNames ? '' : 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE');
  static const CustomerPriceListAssignmentStatus
      CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE =
      CustomerPriceListAssignmentStatus._(
          2,
          _omitEnumNames
              ? ''
              : 'CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE');

  static const $core.List<CustomerPriceListAssignmentStatus> values =
      <CustomerPriceListAssignmentStatus>[
    CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_UNSPECIFIED,
    CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE,
    CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE,
  ];

  static final $core.List<CustomerPriceListAssignmentStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CustomerPriceListAssignmentStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CustomerPriceListAssignmentStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
