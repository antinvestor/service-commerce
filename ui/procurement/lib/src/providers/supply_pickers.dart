import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a supply picker hands back: the picked id and how to name it.
class SupplyChoice {
  const SupplyChoice({required this.id, this.label = ''});

  final String id;
  final String label;
}

/// Builds a picker that calls [onPicked] with the chosen item.
typedef SupplyPickerBuilder =
    Widget Function(BuildContext context, ValueChanged<SupplyChoice> onPicked);

/// Pickers for what a supplier item supplies. The host app provides them:
/// materials come from manufacturing inventory, product variants from the
/// shop's catalogue, and this package depends on neither.
///
/// Without one, the supplier item form takes a pasted, validated ID.
class SupplyPickers {
  const SupplyPickers({this.material, this.productVariant});

  /// Picks a manufacturing inventory item.
  final SupplyPickerBuilder? material;

  /// Picks a commerce product variant.
  final SupplyPickerBuilder? productVariant;

  SupplyPickerBuilder? forKind(SupplyKind kind) =>
      kind == SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT
      ? productVariant
      : material;
}

/// Override in the host app with real pickers.
final supplyPickersProvider = Provider<SupplyPickers>(
  (ref) => const SupplyPickers(),
);
