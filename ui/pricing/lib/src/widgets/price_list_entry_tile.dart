import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

/// A tile showing a single [PriceListEntry] with variant, price, and quantity range.
class PriceListEntryTile extends StatelessWidget {
  const PriceListEntryTile({
    super.key,
    required this.entry,
    this.variantName = '',
  });

  final PriceListEntry entry;
  final String variantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.sell_outlined,
              size: 18,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variantName.isNotEmpty
                      ? variantName
                      : entry.productVariantId,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.minQuantity > 0 || entry.maxQuantity > 0)
                  Text(
                    'Qty: ${entry.minQuantity}–${entry.maxQuantity > 0 ? entry.maxQuantity : '*'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          AmountDisplay(amount: entry.unitPrice),
        ],
      ),
    );
  }
}
