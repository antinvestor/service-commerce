import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../widgets/goods_receipt_status_badge.dart';
import '../widgets/receipt_line_actions.dart';
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
    final busy = ref.watch(procurementNotifierProvider).isLoading;

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
              _DeliverySummary(lines: receipt.lines),
              Text(
                'Lines (${receipt.lines.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final line in receipt.lines)
                ReceiptLineTile(
                  line: line,
                  action: PermissionGuard(
                    permissions: const {'goods_receipt_resolve'},
                    child: OutlinedButton(
                      key: Key('resolve_line_${line.id}'),
                      onPressed: busy
                          ? null
                          : () =>
                                resolveReceiptLine(context, ref, receipt, line),
                      child: const Text('Resolve'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What still needs a person on this receipt, in one line each, so staff
/// see it before reading the lines.
class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({required this.lines});

  final List<GoodsReceiptLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int count(StockDeliveryStatus s) =>
        lines.where((l) => l.deliveryStatus == s).length;
    final failed = count(StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED);
    final transfer = count(
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING_TRANSFER,
    );
    final pending = count(StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING);
    final messages = [
      if (failed > 0)
        '$failed ${_lines(failed)} refused by the shop: check the product '
            'variant and retry, or record the stock there and mark it '
            'booked.',
      if (transfer > 0)
        '$transfer ${_lines(transfer)} of raw material to book into '
            'manufacturing inventory by hand, then mark booked.',
      if (pending > 0)
        '$pending ${_lines(pending)} on the way to the shop\'s stock; '
            'retried automatically.',
    ];
    if (messages.isEmpty) return const SizedBox.shrink();
    final urgent = failed > 0 || transfer > 0;
    return Container(
      key: const Key('receipt_delivery_summary'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: urgent
            ? theme.colorScheme.errorContainer.withAlpha(90)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            urgent ? Icons.warning_amber_outlined : Icons.schedule,
            size: 20,
            color: urgent
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final m in messages)
                  Text(m, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _lines(int n) => n == 1 ? 'line' : 'lines';
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
