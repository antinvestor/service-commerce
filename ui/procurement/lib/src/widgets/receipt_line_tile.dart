import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter/material.dart';

import '../util/supply.dart';
import 'stock_delivery_badge.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// A tile showing a single [GoodsReceiptLine]: quantities, lot, and where
/// its stock is, with what staff need to do about it.
class ReceiptLineTile extends StatelessWidget {
  const ReceiptLineTile({super.key, required this.line, this.itemName = ''});

  final GoodsReceiptLine line;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final id = suppliedId(
      line.supplyKind,
      inventoryItemId: line.inventoryItemId,
      productVariantId: line.productVariantId,
    );
    final hasDelivery =
        line.deliveryStatus !=
        StockDeliveryStatus.STOCK_DELIVERY_STATUS_UNSPECIFIED;
    final (_, color, meaning) = stockDeliveryStyle(line.deliveryStatus);
    final needsAction = deliveryNeedsAction(line);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isResale(line.supplyKind)
                  ? Icons.sell_outlined
                  : Icons.check_box_outlined,
              size: 18,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      itemName.isNotEmpty ? itemName : id,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasDelivery)
                      StockDeliveryBadge(status: line.deliveryStatus),
                  ],
                ),
                Text(supplyKindLabel(line.supplyKind), style: muted),
                Text(
                  'Received: ${line.receivedQuantity} | Accepted: ${line.acceptedQuantity} | Rejected: ${line.rejectedQuantity}',
                  style: muted,
                ),
                if (line.lotNumber.isNotEmpty || line.hasExpiryDate())
                  Text(
                    [
                      if (line.lotNumber.isNotEmpty) 'Lot: ${line.lotNumber}',
                      if (line.hasExpiryDate())
                        'Expires: ${_formatDate(line.expiryDate.toDateTime())}',
                    ].join(' | '),
                    style: muted,
                  ),
                if (hasDelivery && meaning.isNotEmpty)
                  Text(
                    meaning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: needsAction ? color : muted?.color,
                      fontWeight: needsAction ? FontWeight.w600 : null,
                    ),
                  ),
                if (line.deliveryNote.isNotEmpty)
                  Text(
                    line.deliveryNote,
                    style: muted?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
