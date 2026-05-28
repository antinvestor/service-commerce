import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../widgets/po_line_tile.dart';

/// Multi-step wizard for creating a goods receipt against a PO.
///
/// Steps:
/// 1. Select PO lines and enter received quantities
/// 2. Enter lot numbers (optional)
/// 3. Confirm
class GoodsReceiptWizardScreen extends ConsumerStatefulWidget {
  const GoodsReceiptWizardScreen({super.key, required this.poId});

  final String poId;

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

  static const _stepLabels = ['Quantities', 'Lot Numbers', 'Confirm'];

  bool get _canAdvance => switch (_step) {
        0 => _receiptLines.values.any((l) => l.quantity > 0),
        1 => true,
        _ => false,
      };

  Future<void> _createReceipt() async {
    setState(() => _submitting = true);
    try {
      final request = GoodsReceiptCreateRequest()
        ..purchaseOrderId = widget.poId
        ..notes = _notes;

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
          request.lines.add(lineInput);
        }
      }

      final notifier = ref.read(procurementNotifierProvider.notifier);
      await notifier.createGoodsReceipt(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goods receipt created')),
        );
        context.go('/procurement/orders/${widget.poId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
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
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
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
                    onPressed: () => context
                        .go('/procurement/orders/${widget.poId}'),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.move_to_inbox_outlined,
                      size: 28, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Receive Goods',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
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
                                  : theme.colorScheme
                                      .surfaceContainerHighest,
                          child: isDone
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : Text('${i + 1}',
                                  style: theme.textTheme.labelSmall),
                        ),
                        const SizedBox(height: 4),
                        Text(_stepLabels[i],
                            style: theme.textTheme.labelSmall),
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
                      onChanged: (lineId, input) => setState(
                          () => _receiptLines[lineId] = input),
                    ),
                  1 => _StepLotNumbers(
                      receiptLines: _receiptLines,
                      onLotChanged: (lineId, lot) => setState(() {
                        final existing = _receiptLines[lineId];
                        if (existing != null) {
                          _receiptLines[lineId] = existing.withLot(lot);
                        }
                      }),
                    ),
                  2 => _StepGRConfirm(
                      receiptLines: _receiptLines,
                      onNotesChanged: (n) =>
                          setState(() => _notes = n),
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
                      onPressed: _submitting ? null : _createReceipt,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter Received Quantities',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: po.lines.length,
            itemBuilder: (context, index) {
              final line = po.lines[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: POLineTile(line: line)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Qty',
                          hintText:
                              '${line.orderedQuantity}',
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final qty = double.tryParse(v) ?? 0;
                          onChanged(
                            line.id,
                            _ReceiptLineInput(
                              inventoryItemId: line.inventoryItemId,
                              quantity: qty,
                              unit: line.unit,
                            ),
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
  });

  final Map<String, _ReceiptLineInput> receiptLines;
  final void Function(String lineId, String lot) onLotChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLines = receiptLines.entries
        .where((e) => e.value.quantity > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lot Numbers (Optional)',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Expanded(
          child: activeLines.isEmpty
              ? Center(
                  child: Text('No lines to receive',
                      style: theme.textTheme.bodySmall),
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
                              entry.value.inventoryItemId,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Lot Number',
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  onLotChanged(entry.key, v),
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
        Text('Confirm Goods Receipt',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text('${activeLines.length} lines to receive',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        TextField(
          onChanged: onNotesChanged,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _ReceiptLineInput {
  const _ReceiptLineInput({
    required this.inventoryItemId,
    required this.quantity,
    required this.unit,
    this.lotNumber = '',
  });

  final String inventoryItemId;
  final double quantity;
  final String unit;
  final String lotNumber;

  _ReceiptLineInput withLot(String lot) => _ReceiptLineInput(
        inventoryItemId: inventoryItemId,
        quantity: quantity,
        unit: unit,
        lotNumber: lot,
      );
}
