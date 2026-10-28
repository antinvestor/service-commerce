import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../util/idempotency.dart';
import '../util/supply.dart';
import '../widgets/po_line_tile.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Multi-step wizard for creating a goods receipt against a PO.
///
/// Steps:
/// 1. Select PO lines and enter received quantities
/// 2. Enter lot numbers and expiry dates (optional)
/// 3. Confirm
class GoodsReceiptWizardScreen extends ConsumerStatefulWidget {
  const GoodsReceiptWizardScreen({
    super.key,
    required this.poId,
    this.propertyId = '',
  });

  final String poId;

  /// Fallback receiving property, used when the purchase order does not
  /// carry one.
  final String propertyId;

  @override
  ConsumerState<GoodsReceiptWizardScreen> createState() =>
      _GoodsReceiptWizardScreenState();
}

class _GoodsReceiptWizardScreenState
    extends ConsumerState<GoodsReceiptWizardScreen> {
  int _step = 0;
  final Map<String, _ReceiptLineInput> _receiptLines = {};
  String _notes = '';
  bool _submitting = false;

  /// One key per wizard session, so resubmitting after a lost response
  /// cannot record the same delivery twice.
  final String _idempotencyKey = newIdempotencyKey();

  static const _stepLabels = ['Quantities', 'Lots & Expiry', 'Confirm'];

  bool get _canAdvance => switch (_step) {
    0 =>
      _receiptLines.values.any((l) => l.quantity > 0) &&
          _receiptLines.values.every((l) => l.quantityError == null),
    1 => true,
    _ => false,
  };

  Future<void> _createReceipt(PurchaseOrder po) async {
    setState(() => _submitting = true);
    try {
      final propertyId = po.propertyId.isNotEmpty
          ? po.propertyId
          : widget.propertyId;
      final request = GoodsReceiptCreateRequest()
        ..idempotencyKey = _idempotencyKey
        ..purchaseOrderId = widget.poId
        ..notes = _notes;
      if (propertyId.isNotEmpty) request.propertyId = propertyId;

      for (final entry in _receiptLines.entries) {
        if (entry.value.quantity > 0) {
          final lineInput = GoodsReceiptLineInput()
            ..purchaseOrderLineId = entry.key
            ..inventoryItemId = entry.value.inventoryItemId
            ..receivedQuantity = entry.value.quantity
            ..unit = entry.value.unit;
          if (entry.value.lotNumber.isNotEmpty) {
            lineInput.lotNumber = entry.value.lotNumber;
          }
          final expiry = entry.value.expiryDate;
          if (expiry != null) {
            lineInput.expiryDate = Timestamp.fromDateTime(
              DateTime.utc(expiry.year, expiry.month, expiry.day),
            );
          }
          request.lines.add(lineInput);
        }
      }

      final notifier = ref.read(procurementNotifierProvider.notifier);
      final receipt = await notifier.createGoodsReceipt(request);
      ref.invalidate(purchaseOrderByIdProvider(widget.poId));
      ref.invalidate(purchaseOrderListProvider);
      ref.invalidate(purchaseOrderPagesProvider);
      ref.invalidate(goodsReceiptPagesProvider(widget.poId));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Goods receipt created')));
        // The receipt shows where each line's stock went and what, if
        // anything, still needs doing.
        context.go(
          receipt.id.isNotEmpty
              ? ProcurementPaths.receipt(receipt.id)
              : ProcurementPaths.order(widget.poId),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncPO = ref.watch(purchaseOrderByIdProvider(widget.poId));

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
              Text('Failed to load PO', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error)),
            ],
          ),
        ),
        data: (po) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Purchase order',
                    onPressed: () =>
                        context.go(ProcurementPaths.order(widget.poId)),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.move_to_inbox_outlined,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Receive Goods',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_stepLabels.length, (i) {
                  final isActive = i == _step;
                  final isDone = i < _step;
                  return Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isDone
                              ? theme.colorScheme.primary
                              : isActive
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: theme.textTheme.labelSmall,
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(_stepLabels[i], style: theme.textTheme.labelSmall),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: switch (_step) {
                  0 => _StepQuantities(
                    po: po,
                    receiptLines: _receiptLines,
                    onChanged: (lineId, input) =>
                        setState(() => _receiptLines[lineId] = input),
                  ),
                  1 => _StepLotNumbers(
                    receiptLines: _receiptLines,
                    onLotChanged: (lineId, lot) => setState(() {
                      final existing = _receiptLines[lineId];
                      if (existing != null) {
                        _receiptLines[lineId] = existing.copyWith(
                          lotNumber: lot,
                        );
                      }
                    }),
                    onExpiryChanged: (lineId, expiry) => setState(() {
                      final existing = _receiptLines[lineId];
                      if (existing != null) {
                        _receiptLines[lineId] = existing.copyWith(
                          expiryDate: expiry,
                        );
                      }
                    }),
                  ),
                  2 => _StepGRConfirm(
                    receiptLines: _receiptLines,
                    onNotesChanged: (n) => setState(() => _notes = n),
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),

            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_step < 2)
                    FilledButton(
                      onPressed: _canAdvance
                          ? () => setState(() => _step++)
                          : null,
                      child: const Text('Next'),
                    ),
                  if (_step == 2)
                    FilledButton.icon(
                      onPressed: _submitting ? null : () => _createReceipt(po),
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Create Receipt'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepQuantities extends StatelessWidget {
  const _StepQuantities({
    required this.po,
    required this.receiptLines,
    required this.onChanged,
  });

  final PurchaseOrder po;
  final Map<String, _ReceiptLineInput> receiptLines;
  final void Function(String lineId, _ReceiptLineInput input) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = po.lines
        .where(
          (l) =>
              l.status !=
                  PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_RECEIVED &&
              l.status !=
                  PurchaseOrderLineStatus
                      .PURCHASE_ORDER_LINE_STATUS_CANCELLED &&
              l.status !=
                  PurchaseOrderLineStatus.PURCHASE_ORDER_LINE_STATUS_CLOSED,
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Received Quantities',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: lines.isEmpty
              ? Center(
                  child: Text(
                    'Every line on this order is already received',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    final remaining =
                        line.orderedQuantity - line.receivedQuantity;
                    final existing = receiptLines[line.id];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: POLineTile(line: line)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 96,
                            child: TextFormField(
                              key: Key('receive_qty_${line.id}'),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (_) =>
                                  receiptLines[line.id]?.quantityError,
                              initialValue:
                                  existing != null && existing.quantity > 0
                                  ? '${existing.quantity}'
                                  : null,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Qty',
                                hintText: '${remaining > 0 ? remaining : 0}',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final qty = double.tryParse(v) ?? 0;
                                onChanged(
                                  line.id,
                                  (existing ??
                                          _ReceiptLineInput(
                                            inventoryItemId:
                                                line.inventoryItemId,
                                            label: suppliedId(
                                              line.supplyKind,
                                              inventoryItemId:
                                                  line.inventoryItemId,
                                              productVariantId:
                                                  line.productVariantId,
                                            ),
                                            wholeUnits: needsWholeUnits(
                                              line.supplyKind,
                                            ),
                                            quantity: 0,
                                            unit: line.unit,
                                          ))
                                      .copyWith(quantity: qty),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StepLotNumbers extends StatelessWidget {
  const _StepLotNumbers({
    required this.receiptLines,
    required this.onLotChanged,
    required this.onExpiryChanged,
  });

  final Map<String, _ReceiptLineInput> receiptLines;
  final void Function(String lineId, String lot) onLotChanged;
  final void Function(String lineId, DateTime? expiry) onExpiryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLines = receiptLines.entries
        .where((e) => e.value.quantity > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lot Numbers & Expiry (Optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: activeLines.isEmpty
              ? Center(
                  child: Text(
                    'No lines to receive',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  itemCount: activeLines.length,
                  itemBuilder: (context, index) {
                    final entry = activeLines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.value.label,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: entry.value.lotNumber,
                              decoration: const InputDecoration(
                                labelText: 'Lot Number',
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  onLotChanged(entry.key, v.trim()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _ExpiryField(
                              value: entry.value.expiryDate,
                              onChanged: (d) => onExpiryChanged(entry.key, d),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StepGRConfirm extends StatelessWidget {
  const _StepGRConfirm({
    required this.receiptLines,
    required this.onNotesChanged,
  });

  final Map<String, _ReceiptLineInput> receiptLines;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLines = receiptLines.entries
        .where((e) => e.value.quantity > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Goods Receipt',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${activeLines.length} lines to receive',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onNotesChanged,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes', isDense: true),
        ),
      ],
    );
  }
}

/// Tappable expiry-date picker with a clear button.
class _ExpiryField extends StatelessWidget {
  const _ExpiryField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 10)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Expiry',
          isDense: true,
          suffixIcon: value == null
              ? const Icon(Icons.event, size: 18)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: 'Clear expiry',
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(value == null ? '' : _formatDate(value!)),
      ),
    );
  }
}

class _ReceiptLineInput {
  const _ReceiptLineInput({
    required this.inventoryItemId,
    required this.quantity,
    required this.unit,
    this.label = '',
    this.wholeUnits = false,
    this.lotNumber = '',
    this.expiryDate,
  });

  final String inventoryItemId;

  /// What the line supplies, for display.
  final String label;

  /// Product variants are received in whole units.
  final bool wholeUnits;
  final double quantity;
  final String unit;
  final String lotNumber;
  final DateTime? expiryDate;

  static const Object _keep = Object();

  /// Why [quantity] cannot be received, or null when it can.
  String? get quantityError {
    if (quantity < 0) return 'Not negative';
    if (wholeUnits && quantity != quantity.roundToDouble()) {
      return 'Whole units';
    }
    return null;
  }

  _ReceiptLineInput copyWith({
    double? quantity,
    String? lotNumber,
    Object? expiryDate = _keep,
  }) => _ReceiptLineInput(
    inventoryItemId: inventoryItemId,
    label: label,
    wholeUnits: wholeUnits,
    quantity: quantity ?? this.quantity,
    unit: unit,
    lotNumber: lotNumber ?? this.lotNumber,
    expiryDate: identical(expiryDate, _keep)
        ? this.expiryDate
        : expiryDate as DateTime?,
  );
}
