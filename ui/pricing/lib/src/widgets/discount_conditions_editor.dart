import 'package:flutter/material.dart';

import '../utils/discount_conditions.dart';
import '../utils/pricing_validators.dart';

/// Explains which condition keys the pricing engine evaluates.
const discountConditionsHelp =
    'Only variant IDs, product IDs and a minimum quantity are understood. '
    'A rule with any other condition is never applied automatically. '
    'All conditions set must match.';

/// Edits the condition keys the backend understands — `variant_ids`,
/// `product_ids` and `min_quantity` — and reports each change as a
/// [DiscountConditions]. Place inside a [Form] to get field validation.
class DiscountConditionsEditor extends StatefulWidget {
  const DiscountConditionsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final DiscountConditions initial;
  final ValueChanged<DiscountConditions> onChanged;

  @override
  State<DiscountConditionsEditor> createState() =>
      _DiscountConditionsEditorState();
}

class _DiscountConditionsEditorState extends State<DiscountConditionsEditor> {
  late final TextEditingController _variants;
  late final TextEditingController _products;
  late final TextEditingController _minQuantity;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _variants = TextEditingController(text: c.variantIds.join(', '));
    _products = TextEditingController(text: c.productIds.join(', '));
    final min = c.minQuantity;
    _minQuantity = TextEditingController(
      text: min == null || min <= 0
          ? ''
          : (min == min.roundToDouble() ? '${min.toInt()}' : '$min'),
    );
  }

  @override
  void dispose() {
    _variants.dispose();
    _products.dispose();
    _minQuantity.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      DiscountConditions(
        variantIds: parseIdList(_variants.text),
        productIds: parseIdList(_products.text),
        minQuantity: double.tryParse(_minQuantity.text.trim()),
        unsupportedKeys: widget.initial.unsupportedKeys,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Conditions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          discountConditionsHelp,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('condition-variant-ids'),
          controller: _variants,
          decoration: const InputDecoration(
            labelText: 'Variant IDs',
            helperText: 'Comma separated; leave empty for any variant',
          ),
          validator: (v) =>
              validateEntityIdList(parseIdList(v ?? ''), 'variant ID'),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('condition-product-ids'),
          controller: _products,
          decoration: const InputDecoration(
            labelText: 'Product IDs',
            helperText: 'Comma separated; leave empty for any product',
          ),
          validator: (v) =>
              validateEntityIdList(parseIdList(v ?? ''), 'product ID'),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('condition-min-quantity'),
          controller: _minQuantity,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minimum Quantity',
            helperText: 'Leave empty for no threshold',
          ),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return null;
            final n = double.tryParse(t);
            if (n == null || n < 0) return 'Enter a non-negative number';
            return null;
          },
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}
