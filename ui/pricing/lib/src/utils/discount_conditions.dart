import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';

/// Condition key restricting a rule to specific product variants.
const conditionVariantIds = 'variant_ids';

/// Condition key restricting a rule to specific products.
const conditionProductIds = 'product_ids';

/// Condition key requiring a minimum line quantity.
const conditionMinQuantity = 'min_quantity';

/// The only condition keys the pricing engine evaluates. A rule carrying any
/// other key is never applied automatically.
const supportedConditionKeys = {
  conditionVariantIds,
  conditionProductIds,
  conditionMinQuantity,
};

/// Typed view of a [DiscountRule]'s `conditions` Struct, limited to the keys
/// the backend understands.
class DiscountConditions {
  const DiscountConditions({
    this.variantIds = const [],
    this.productIds = const [],
    this.minQuantity,
    this.unsupportedKeys = const [],
  });

  /// Reads the supported keys from [struct]. Keys the backend does not
  /// understand are reported in [unsupportedKeys] so the UI can warn about
  /// them rather than silently dropping them.
  factory DiscountConditions.fromStruct(Struct? struct) {
    if (struct == null) return const DiscountConditions();
    final fields = struct.fields;
    return DiscountConditions(
      variantIds: _readStringList(fields[conditionVariantIds]),
      productIds: _readStringList(fields[conditionProductIds]),
      minQuantity: fields[conditionMinQuantity]?.hasNumberValue() == true
          ? fields[conditionMinQuantity]!.numberValue
          : null,
      unsupportedKeys:
          fields.keys.where((k) => !supportedConditionKeys.contains(k)).toList()
            ..sort(),
    );
  }

  final List<String> variantIds;
  final List<String> productIds;

  /// Minimum quantity threshold; null or <= 0 means no threshold.
  final double? minQuantity;

  /// Keys present on the source Struct that the backend never evaluates.
  final List<String> unsupportedKeys;

  bool get isEmpty =>
      variantIds.isEmpty &&
      productIds.isEmpty &&
      (minQuantity == null || minQuantity! <= 0);

  /// Builds the `google.protobuf.Struct` sent on save. Lists are encoded as
  /// `ListValue`s of string values and the threshold as a `numberValue`;
  /// empty conditions are omitted entirely.
  Struct toStruct() {
    final fields = <String, Value>{};
    final variants = _clean(variantIds);
    if (variants.isNotEmpty) {
      fields[conditionVariantIds] = _stringListValue(variants);
    }
    final products = _clean(productIds);
    if (products.isNotEmpty) {
      fields[conditionProductIds] = _stringListValue(products);
    }
    if (minQuantity != null && minQuantity! > 0) {
      fields[conditionMinQuantity] = Value(numberValue: minQuantity);
    }
    return Struct(fields: fields.entries);
  }

  static Value _stringListValue(List<String> items) => Value(
    listValue: ListValue(values: items.map((s) => Value(stringValue: s))),
  );

  static List<String> _clean(List<String> items) {
    final seen = <String>{};
    return [
      for (final raw in items)
        if (raw.trim().isNotEmpty && seen.add(raw.trim())) raw.trim(),
    ];
  }

  static List<String> _readStringList(Value? value) {
    if (value == null || !value.hasListValue()) return const [];
    return value.listValue.values
        .where((v) => v.hasStringValue())
        .map((v) => v.stringValue)
        .toList();
  }
}

/// Splits comma, whitespace or newline separated IDs into a de-duplicated list.
List<String> parseIdList(String input) {
  final seen = <String>{};
  return [
    for (final part in input.split(RegExp(r'[\s,]+')))
      if (part.isNotEmpty && seen.add(part)) part,
  ];
}
