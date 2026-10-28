import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

import '../util/supply.dart';

/// A tile showing a single [PurchaseOrderLine].
class POLineTile extends StatelessWidget {
  const POLineTile({super.key, required this.line, this.itemName = ''});

  final PurchaseOrderLine line;
  final String itemName;

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
              color: theme.colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_outlined,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName.isNotEmpty
                      ? itemName
                      : suppliedId(
                          line.supplyKind,
                          inventoryItemId: line.inventoryItemId,
                          productVariantId: line.productVariantId,
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${supplyKindLabel(line.supplyKind)} | '
                  'Ordered: ${line.orderedQuantity} ${line.unit} | Received: ${line.receivedQuantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (line.hasUnitPrice()) AmountDisplay(amount: line.unitPrice),
        ],
      ),
    );
  }
}
