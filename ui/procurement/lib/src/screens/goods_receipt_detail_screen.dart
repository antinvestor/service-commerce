import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../widgets/goods_receipt_status_badge.dart';
import '../widgets/receipt_line_tile.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Detail screen for a single goods receipt.
class GoodsReceiptDetailScreen extends ConsumerWidget {
  const GoodsReceiptDetailScreen({super.key, required this.receiptId});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncReceipt = ref.watch(goodsReceiptByIdProvider(receiptId));

    return Scaffold(
      body: asyncReceipt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load goods receipt',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                friendlyError(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(goodsReceiptByIdProvider(receiptId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (receipt) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Purchase order',
                    onPressed: () => context.go(
                      receipt.purchaseOrderId.isNotEmpty
                          ? ProcurementPaths.order(receipt.purchaseOrderId)
                          : ProcurementPaths.orders,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.move_to_inbox_outlined,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goods Receipt',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          receipt.id,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GoodsReceiptStatusBadge(status: receipt.status),
                ],
              ),
              const SizedBox(height: 24),
              if (receipt.purchaseOrderId.isNotEmpty)
                _DetailRow(
                  label: 'Purchase order',
                  child: InkWell(
                    onTap: () => context.go(
                      ProcurementPaths.order(receipt.purchaseOrderId),
                    ),
                    child: Text(
                      receipt.purchaseOrderId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (receipt.hasReceivedAt())
                _DetailRow(
                  label: 'Received',
                  text: _formatDate(receipt.receivedAt.toDateTime()),
                ),
              if (receipt.receivedBy.isNotEmpty)
                _DetailRow(label: 'Received by', text: receipt.receivedBy),
              if (receipt.notes.isNotEmpty)
                _DetailRow(label: 'Notes', text: receipt.notes),
              const SizedBox(height: 16),
              Text(
                'Lines (${receipt.lines.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final line in receipt.lines) ReceiptLineTile(line: line),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.text, this.child});

  final String label;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child:
                child ??
                Text(
                  text ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
