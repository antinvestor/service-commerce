import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../widgets/goods_receipt_card.dart';
import '../widgets/load_more_footer.dart';
import '../widgets/po_actions.dart';
import '../widgets/po_line_tile.dart';
import '../widgets/po_status_badge.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Detail screen for a single purchase order: header, lines with ordered
/// and received quantities, lifecycle actions, and the goods receipts
/// recorded against it.
class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({super.key, required this.poId});

  final String poId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncPO = ref.watch(purchaseOrderByIdProvider(poId));

    return Scaffold(
      body: asyncPO.when(
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
                'Failed to load purchase order',
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
                    ref.invalidate(purchaseOrderByIdProvider(poId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (po) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(po: po),
              const SizedBox(height: 16),
              _Actions(po: po),
              const SizedBox(height: 24),
              _Summary(po: po),
              const SizedBox(height: 24),
              Text(
                'Lines (${po.lines.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (po.lines.isEmpty)
                Text(
                  'No lines',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final line in po.lines) _LineRow(line: line),
              const SizedBox(height: 24),
              _ReceiptsSection(po: po),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Purchase orders',
          onPressed: () => context.go(ProcurementPaths.orders),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.assignment_outlined,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poLabel(po),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                po.id,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        POStatusBadge(status: po.status),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(procurementNotifierProvider).isLoading;
    final actions = <Widget>[
      if (canSubmitPO(po))
        PermissionGuard(
          permissions: const {'purchase_order_submit'},
          child: FilledButton.icon(
            onPressed: busy
                ? null
                : () => submitPurchaseOrder(context, ref, po),
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Submit'),
          ),
        ),
      if (canReceivePO(po))
        PermissionGuard(
          permissions: const {'goods_receipt_create'},
          child: FilledButton.icon(
            onPressed: busy
                ? null
                : () => context.go(ProcurementPaths.receiveOrder(po.id)),
            icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
            label: const Text('Receive goods'),
          ),
        ),
      if (canClosePO(po))
        PermissionGuard(
          permissions: const {'purchase_order_cancel'},
          child: OutlinedButton.icon(
            key: const Key('po_close_short'),
            onPressed: busy
                ? null
                : () => closePurchaseOrderShort(context, ref, po),
            icon: const Icon(Icons.block_outlined, size: 18),
            label: const Text('Close short'),
          ),
        ),
      if (canCancelPO(po))
        PermissionGuard(
          permissions: const {'purchase_order_cancel'},
          child: OutlinedButton.icon(
            onPressed: busy
                ? null
                : () => cancelPurchaseOrder(context, ref, po),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel'),
          ),
        ),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: actions),
        if (canClosePO(po)) ...[
          const SizedBox(height: 8),
          Text(
            'Part of this order has arrived. Receive the rest, or close it '
            'short if no more is coming.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supplierName = po.supplierId.isEmpty
        ? ''
        : ref
                  .watch(supplierByIdProvider(po.supplierId))
                  .whenOrNull(data: (s) => s.name) ??
              '';

    return Column(
      children: [
        _DetailRow(
          label: 'Supplier',
          child: po.supplierId.isEmpty
              ? const Text('-')
              : InkWell(
                  onTap: () =>
                      context.go(ProcurementPaths.supplier(po.supplierId)),
                  child: Text(
                    supplierName.isNotEmpty ? supplierName : po.supplierId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
        ),
        if (po.hasTotalAmount())
          _DetailRow(
            label: 'Total',
            child: AmountDisplay(amount: po.totalAmount),
          ),
        if (po.hasExpectedDeliveryDate())
          _DetailRow(
            label: 'Expected',
            text: _formatDate(po.expectedDeliveryDate.toDateTime()),
          ),
        if (po.hasSubmittedAt())
          _DetailRow(
            label: 'Submitted',
            text: _formatDate(po.submittedAt.toDateTime()),
          ),
        if (po.hasCreatedAt())
          _DetailRow(
            label: 'Created',
            text: _formatDate(po.createdAt.toDateTime()),
          ),
        if (po.notes.isNotEmpty) _DetailRow(label: 'Notes', text: po.notes),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final PurchaseOrderLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: POLineTile(line: line)),
        const SizedBox(width: 8),
        StatusBadge.fromEnum(
          value: line.status,
          mapper: (s) => switch (s) {
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_PENDING => (
              'Pending',
              Colors.grey,
              null,
            ),
            PurchaseOrderLineStatus
                .PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED =>
              ('Partial', Colors.orange, null),
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_RECEIVED => (
              'Received',
              Colors.green,
              null,
            ),
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CANCELLED => (
              'Cancelled',
              Colors.red,
              null,
            ),
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CLOSED => (
              'Closed',
              Colors.blueGrey,
              null,
            ),
            _ => ('Unknown', Colors.grey, null),
          },
        ),
      ],
    );
  }
}

class _ReceiptsSection extends ConsumerWidget {
  const _ReceiptsSection({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncReceipts = ref.watch(goodsReceiptPagesProvider(po.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.move_to_inbox_outlined,
              size: 22,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Goods receipts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        asyncReceipts.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Row(
            children: [
              Expanded(
                child: Text(
                  friendlyError(error),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(goodsReceiptPagesProvider(po.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (list) {
            if (list.items.isEmpty) {
              return Text(
                'No goods received yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              children: [
                for (final r in list.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GoodsReceiptCard(
                      receipt: r,
                      onTap: () => context.go(ProcurementPaths.receipt(r.id)),
                    ),
                  ),
                LoadMoreFooter(
                  list: list,
                  onLoadMore: () => ref
                      .read(goodsReceiptPagesProvider(po.id).notifier)
                      .loadMore(),
                ),
              ],
            );
          },
        ),
      ],
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
