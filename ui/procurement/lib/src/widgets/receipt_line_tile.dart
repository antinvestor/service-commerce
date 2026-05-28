import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter/material.dart';

/// A tile showing a single [GoodsReceiptLine].
class ReceiptLineTile extends StatelessWidget {
  const ReceiptLineTile({super.key, required this.line, this.itemName = ''});

  final GoodsReceiptLine line;
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
              color: theme.colorScheme.tertiaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_box_outlined,
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
                  itemName.isNotEmpty
                      ? itemName
                      : line.inventoryItemId,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Received: ${line.receivedQuantity} | Accepted: ${line.acceptedQuantity} | Rejected: ${line.rejectedQuantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (line.lotNumber.isNotEmpty)
                  Text(
                    'Lot: ${line.lotNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
