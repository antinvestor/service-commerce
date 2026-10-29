import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Product;
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart'
    show ProductSearchSelect, productVariantsProvider;
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart'
    show InventoryItemPicker, StockLocationDropdown, stockLocationListProvider;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show SupplyChoice, SupplyPickers, supplyPickersProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'tenant_context_provider.dart';

/// Supplier items pick what they supply: an inventory item at the active
/// site, or a product variant in the active shop. Received raw materials are
/// put away in one of the site's stock locations.
final Override consoleSupplyPickersOverride = supplyPickersProvider
    .overrideWith((ref) {
      final scope = ref.watch(tenantScopeProvider);
      return SupplyPickers(
        material: scope.propertyId.isEmpty
            ? null
            : (context, onPicked) => InventoryItemPicker(
                propertyId: scope.propertyId,
                onSelected: (item) => onPicked(
                  SupplyChoice(
                    id: item.id,
                    label: item.sku.isEmpty
                        ? item.name
                        : '${item.name} (${item.sku})',
                  ),
                ),
              ),
        productVariant: scope.shopId.isEmpty
            ? null
            : (context, onPicked) =>
                  VariantPicker(shopId: scope.shopId, onPicked: onPicked),
        stockLocation: scope.propertyId.isEmpty
            ? null
            : (context, onPicked) => StockLocationPicker(
                propertyId: scope.propertyId,
                onPicked: onPicked,
              ),
      );
    });

/// Search the shop's products, then pick one of the product's variants.
class VariantPicker extends ConsumerStatefulWidget {
  const VariantPicker({
    super.key,
    required this.shopId,
    required this.onPicked,
  });

  final String shopId;
  final ValueChanged<SupplyChoice> onPicked;

  @override
  ConsumerState<VariantPicker> createState() => _VariantPickerState();
}

class _VariantPickerState extends ConsumerState<VariantPicker> {
  Product? _product;
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProductSearchSelect(
          shopId: widget.shopId,
          label: 'Search the shop\'s products',
          onSelected: (p) => setState(() {
            _product = p;
            _picked = null;
          }),
        ),
        if (product != null) ...[
          const SizedBox(height: 8),
          ref
              .watch(productVariantsProvider(product.id))
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(
                  'Could not load variants: ${friendlyError(e)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (variants) => variants.isEmpty
                    ? Text(
                        '${product.name} has no variants',
                        style: theme.textTheme.bodySmall,
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final v in variants)
                            ChoiceChip(
                              label: Text(v.name.isNotEmpty ? v.name : v.sku),
                              selected: _picked == v.id,
                              onSelected: (_) {
                                setState(() => _picked = v.id);
                                widget.onPicked(
                                  SupplyChoice(
                                    id: v.id,
                                    label:
                                        '${product.name} · '
                                        '${v.name.isNotEmpty ? v.name : v.sku}',
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),
        ],
      ],
    );
  }
}

/// Pick one of the site's manufacturing stock locations.
class StockLocationPicker extends ConsumerStatefulWidget {
  const StockLocationPicker({
    super.key,
    required this.propertyId,
    required this.onPicked,
  });

  final String propertyId;
  final ValueChanged<SupplyChoice> onPicked;

  @override
  ConsumerState<StockLocationPicker> createState() =>
      _StockLocationPickerState();
}

class _StockLocationPickerState extends ConsumerState<StockLocationPicker> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ref
        .watch(stockLocationListProvider(widget.propertyId))
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Could not load stock locations: ${friendlyError(e)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          data: (paged) => paged.items.isEmpty
              ? Text(
                  'This site has no stock locations yet; add one under '
                  'Inventory, Stock Locations.',
                  style: theme.textTheme.bodySmall,
                )
              : StockLocationDropdown(
                  locations: paged.items,
                  value: _picked,
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() => _picked = id);
                    final loc = paged.items.firstWhere((l) => l.id == id);
                    widget.onPicked(
                      SupplyChoice(
                        id: id,
                        label: loc.name.isNotEmpty ? loc.name : id,
                      ),
                    );
                  },
                ),
        );
  }
}
