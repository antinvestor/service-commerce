import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';
import '../util/supply.dart';

/// The most a resolution note may hold; the server refuses more.
const maxResolutionNoteLength = 1000;

/// What staff chose in [ResolveReceiptLineDialog].
typedef LineResolution = ({GoodsReceiptLineResolution resolution, String note});

/// Asks how [line] was settled and records it on [receipt]. Refreshes the
/// receipt and its order's receipts and reports the outcome with a
/// snackbar. Returns true when the line was resolved or retried.
Future<bool> resolveReceiptLine(
  BuildContext context,
  WidgetRef ref,
  GoodsReceipt receipt,
  GoodsReceiptLine line,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final choice = await showDialog<LineResolution>(
    context: context,
    builder: (_) => ResolveReceiptLineDialog(line: line),
  );
  if (choice == null) return false;
  try {
    final updated = await ref
        .read(procurementNotifierProvider.notifier)
        .resolveGoodsReceiptLine(
          GoodsReceiptLineResolveRequest()
            ..goodsReceiptId = receipt.id
            ..lineId = line.id
            ..resolution = choice.resolution
            ..note = choice.note,
        );
    ref.invalidate(goodsReceiptByIdProvider(receipt.id));
    if (receipt.purchaseOrderId.isNotEmpty) {
      ref.invalidate(goodsReceiptPagesProvider(receipt.purchaseOrderId));
    }
    messenger.showSnackBar(
      SnackBar(content: Text(_outcome(choice.resolution, updated, line.id))),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Failed: ${friendlyError(e)}')),
    );
    return false;
  }
}

String _outcome(
  GoodsReceiptLineResolution resolution,
  GoodsReceipt updated,
  String lineId,
) {
  if (resolution ==
      GoodsReceiptLineResolution
          .GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY) {
    return 'Line marked booked by hand';
  }
  final status = updated.lines
      .where((l) => l.id == lineId)
      .map((l) => l.deliveryStatus)
      .firstOrNull;
  return switch (status) {
    StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED =>
      'Delivered to the shop',
    StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED =>
      'The shop refused it again; check the product variant',
    _ => 'Retry queued; it is retried automatically',
  };
}

/// Lets staff settle a receipt line that needs a person: mark it booked by
/// hand (with an optional note), or retry a refused product variant. Pops
/// with the choice, or null when dismissed.
class ResolveReceiptLineDialog extends StatefulWidget {
  const ResolveReceiptLineDialog({super.key, required this.line});

  final GoodsReceiptLine line;

  @override
  State<ResolveReceiptLineDialog> createState() =>
      _ResolveReceiptLineDialogState();
}

class _ResolveReceiptLineDialogState extends State<ResolveReceiptLineDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pop(GoodsReceiptLineResolution resolution) => Navigator.of(
    context,
  ).pop((resolution: resolution, note: _controller.text.trim()));

  @override
  Widget build(BuildContext context) {
    final retryable = deliveryRetryable(widget.line);
    final material = !isResale(widget.line.supplyKind);
    return AlertDialog(
      title: const Text('Resolve receipt line'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material
                    ? 'Once this stock is recorded in manufacturing '
                          'inventory, mark it booked here.'
                    : 'If you added this stock to the product variant '
                          'yourself, mark it booked. Otherwise fix the '
                          'variant and retry.',
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('resolve_line_note'),
                controller: _controller,
                autofocus: true,
                maxLines: 2,
                maxLength: maxResolutionNoteLength,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. booked into the main store, GRN 42',
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
          child: const Text('Not now'),
        ),
        if (retryable)
          OutlinedButton(
            key: const Key('resolve_line_retry'),
            onPressed: () => _pop(
              GoodsReceiptLineResolution.GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
            ),
            child: const Text('Retry now'),
          ),
        FilledButton(
          key: const Key('resolve_line_booked'),
          onPressed: () => _pop(
            GoodsReceiptLineResolution
                .GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY,
          ),
          child: const Text('Mark booked'),
        ),
      ],
    );
  }
}
