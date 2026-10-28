import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';
import '../providers/supply_pickers.dart';
import '../util/supply.dart';

/// The most a resolution note may hold; the server refuses more.
const maxResolutionNoteLength = 1000;

/// What staff chose in [ResolveReceiptLineDialog]: [locationId] is the
/// stock location a raw material is sent to, empty to keep the line's.
typedef LineResolution = ({
  GoodsReceiptLineResolution resolution,
  String note,
  String locationId,
});

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
            ..note = choice.note
            ..locationId = choice.locationId,
        );
    ref.invalidate(goodsReceiptByIdProvider(receipt.id));
    if (receipt.purchaseOrderId.isNotEmpty) {
      ref.invalidate(goodsReceiptPagesProvider(receipt.purchaseOrderId));
    }
    messenger.showSnackBar(
      SnackBar(content: Text(_outcome(choice.resolution, updated, line))),
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
  GoodsReceiptLine line,
) {
  if (resolution ==
      GoodsReceiptLineResolution
          .GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY) {
    return 'Line marked booked by hand';
  }
  final material = !isResale(line.supplyKind);
  final status = updated.lines
      .where((l) => l.id == line.id)
      .map((l) => l.deliveryStatus)
      .firstOrNull;
  return switch (status) {
    StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED =>
      material
          ? 'Booked into manufacturing inventory'
          : 'Delivered to the shop',
    StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED =>
      material
          ? 'Manufacturing refused it again; check the item and location'
          : 'The shop refused it again; check the product variant',
    _ => 'Retry queued; it is retried automatically',
  };
}

/// Lets staff settle a receipt line that needs a person: send it again (a
/// raw material to the stock location they choose), or mark it booked by
/// hand, with an optional note. Pops with the choice, or null when
/// dismissed.
class ResolveReceiptLineDialog extends ConsumerStatefulWidget {
  const ResolveReceiptLineDialog({super.key, required this.line});

  final GoodsReceiptLine line;

  @override
  ConsumerState<ResolveReceiptLineDialog> createState() =>
      _ResolveReceiptLineDialogState();
}

class _ResolveReceiptLineDialogState
    extends ConsumerState<ResolveReceiptLineDialog> {
  final _controller = TextEditingController();
  SupplyChoice? _location;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pop(GoodsReceiptLineResolution resolution) =>
      Navigator.of(context).pop((
        resolution: resolution,
        note: _controller.text.trim(),
        locationId: _location?.id ?? '',
      ));

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final material = !isResale(line.supplyKind);
    final pickLocation = needsLocation(line)
        ? ref.watch(supplyPickersProvider).stockLocation
        : null;
    // A raw material that needs a location can be sent only once one is
    // picked, and only where the app offers a picker.
    final canSend =
        deliveryRetryable(line) &&
        (!needsLocation(line) || pickLocation != null);
    return AlertDialog(
      title: const Text('Resolve receipt line'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material
                      ? 'Choose where this stock is put away to book it into '
                            'manufacturing inventory, or, if you recorded it '
                            'there yourself, mark it booked.'
                      : 'If you added this stock to the product variant '
                            'yourself, mark it booked. Otherwise fix the '
                            'variant and retry.',
                ),
                if (pickLocation != null) ...[
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: const Key('resolve_line_location'),
                    child: pickLocation(
                      context,
                      (choice) => setState(() => _location = choice),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  key: const Key('resolve_line_note'),
                  controller: _controller,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        if (canSend)
          OutlinedButton(
            key: const Key('resolve_line_retry'),
            onPressed: needsLocation(line) && _location == null
                ? null
                : () => _pop(
                    GoodsReceiptLineResolution
                        .GOODS_RECEIPT_LINE_RESOLUTION_RETRY,
                  ),
            child: Text(material ? 'Book into inventory' : 'Retry now'),
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
