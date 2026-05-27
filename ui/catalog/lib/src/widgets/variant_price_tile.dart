import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

/// A [ListTile] showing variant name, SKU, and trailing price.
class VariantPriceTile extends StatelessWidget {
  const VariantPriceTile({
    super.key,
    required this.variant,
    this.onTap,
  });

  final ProductVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.style_outlined,
        size: 20,
        color: theme.colorScheme.secondary,
      ),
      title: Text(
        variant.name.isNotEmpty ? variant.name : 'Unnamed variant',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: variant.sku.isNotEmpty
          ? Text(
              'SKU: ${variant.sku}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            )
          : null,
      trailing: AmountDisplay(amount: variant.price),
    );
  }
}
