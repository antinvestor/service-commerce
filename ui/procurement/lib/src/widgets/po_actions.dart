import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';

/// Only draft orders can be submitted to the supplier.
bool canSubmitPO(PurchaseOrder order) =>
    order.status == PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT;

/// Orders can be cancelled until goods arrive against them; after that the
/// rest is closed short instead ([canClosePO]).
bool canCancelPO(PurchaseOrder order) => switch (order.status) {
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT ||
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED ||
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CONFIRMED => true,
  _ => false,
};

/// A partially received order can be closed short: what arrived stays,
/// nothing more is expected.
bool canClosePO(PurchaseOrder order) =>
    order.status ==
    PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED;

/// Goods can be received once the order has left draft and until it is
/// fully received.
bool canReceivePO(PurchaseOrder order) => switch (order.status) {
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED ||
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CONFIRMED ||
  PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED => true,
  _ => false,
};

/// Human label for a purchase order: its number when assigned, else its ID.
String poLabel(PurchaseOrder order) =>
    order.orderNumber.isNotEmpty ? 'PO #${order.orderNumber}' : order.id;

/// Submits [order], refreshing cached order data and reporting the outcome
/// with a snackbar. Returns true on success.
Future<bool> submitPurchaseOrder(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrder order,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(procurementNotifierProvider.notifier)
        .submitPO(PurchaseOrderSubmitRequest()..id = order.id);
    _refreshOrder(ref, order.id);
    messenger.showSnackBar(
      const SnackBar(content: Text('Purchase order submitted')),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Failed: ${friendlyError(e)}')),
    );
    return false;
  }
}

/// Asks for a cancellation reason and cancels [order] with it. Returns true
/// when the order was cancelled; false if the user backed out or it failed.
Future<bool> cancelPurchaseOrder(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrder order,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => CancelPODialog(order: order),
  );
  if (reason == null) return false;
  try {
    await ref
        .read(procurementNotifierProvider.notifier)
        .cancelPO(
          PurchaseOrderCancelRequest()
            ..id = order.id
            ..reason = reason,
        );
    _refreshOrder(ref, order.id);
    messenger.showSnackBar(
      const SnackBar(content: Text('Purchase order cancelled')),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Failed: ${friendlyError(e)}')),
    );
    return false;
  }
}

/// Asks for confirmation (and an optional reason) and closes [order] short.
/// Returns true when the order was closed.
Future<bool> closePurchaseOrderShort(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrder order,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => ClosePODialog(order: order),
  );
  if (reason == null) return false;
  try {
    await ref
        .read(procurementNotifierProvider.notifier)
        .closePO(
          PurchaseOrderCloseRequest()
            ..id = order.id
            ..reason = reason,
        );
    _refreshOrder(ref, order.id);
    messenger.showSnackBar(
      const SnackBar(content: Text('Purchase order closed short')),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Failed: ${friendlyError(e)}')),
    );
    return false;
  }
}

void _refreshOrder(WidgetRef ref, String poId) {
  ref.invalidate(purchaseOrderListProvider);
  ref.invalidate(purchaseOrderPagesProvider);
  ref.invalidate(purchaseOrderByIdProvider(poId));
}

/// What is still outstanding on [order], e.g. "6 bag of FLOUR".
List<String> outstandingLines(PurchaseOrder order) => [
  for (final line in order.lines)
    if (line.orderedQuantity > line.receivedQuantity &&
        line.status !=
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CANCELLED &&
        line.status !=
            PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CLOSED)
      '${_qty(line.orderedQuantity - line.receivedQuantity)} ${line.unit}'
          .trim(),
];

String _qty(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);

/// Confirms closing a partially received order short. Pops with the trimmed
/// reason (possibly empty), or null when dismissed.
class ClosePODialog extends StatefulWidget {
  const ClosePODialog({super.key, required this.order});

  final PurchaseOrder order;

  @override
  State<ClosePODialog> createState() => _ClosePODialogState();
}

class _ClosePODialogState extends State<ClosePODialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outstanding = outstandingLines(widget.order);
    return AlertDialog(
      title: const Text('Close short'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Close ${poLabel(widget.order)}? What has arrived stays '
                'received; nothing more will be received against it.',
              ),
              if (outstanding.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('No longer expected: ${outstanding.join(', ')}.'),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('close_po_reason'),
                controller: _controller,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'e.g. supplier cannot deliver the rest',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep open'),
        ),
        FilledButton(
          key: const Key('close_po_confirm'),
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Close short'),
        ),
      ],
    );
  }
}

/// Confirmation dialog that requires a cancellation reason. Pops with the
/// trimmed reason, or null when dismissed.
class CancelPODialog extends StatefulWidget {
  const CancelPODialog({super.key, required this.order});

  final PurchaseOrder order;

  @override
  State<CancelPODialog> createState() => _CancelPODialogState();
}

class _CancelPODialogState extends State<CancelPODialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = _controller.text.trim();
    return AlertDialog(
      title: const Text('Cancel Purchase Order'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cancel ${poLabel(widget.order)}? This cannot be undone.'),
              const SizedBox(height: 16),
              TextField(
                key: const Key('cancel_po_reason'),
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Why is this order being cancelled?',
                  alignLabelWithHint: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep order'),
        ),
        ElevatedButton(
          onPressed: reason.isEmpty
              ? null
              : () => Navigator.of(context).pop(reason),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Cancel PO'),
        ),
      ],
    );
  }
}
