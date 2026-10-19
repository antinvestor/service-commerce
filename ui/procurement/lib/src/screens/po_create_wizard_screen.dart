import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../util/idempotency.dart';
import '../widgets/supplier_card.dart';

/// Multi-step wizard for creating a purchase order.
///
/// Steps:
/// 1. Select supplier
/// 2. Add order lines
/// 3. Set delivery date
/// 4. Confirm
class POCreateWizardScreen extends ConsumerStatefulWidget {
  const POCreateWizardScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  ConsumerState<POCreateWizardScreen> createState() =>
      _POCreateWizardScreenState();
}

class _POCreateWizardScreenState extends ConsumerState<POCreateWizardScreen> {
  int _step = 0;
  Supplier? _selectedSupplier;
  final List<_POLineItem> _lines = [];
  DateTime _expectedDelivery = DateTime.now().add(const Duration(days: 7));
  String _notes = '';
  bool _submitting = false;

  /// One key per wizard session, so resubmitting after a lost response
  /// cannot create a duplicate purchase order.
  final String _idempotencyKey = newIdempotencyKey();

  static const _stepLabels = ['Supplier', 'Lines', 'Delivery', 'Confirm'];

  bool get _canAdvance => switch (_step) {
    0 => _selectedSupplier != null,
    1 => _lines.isNotEmpty,
    2 => true,
    _ => false,
  };

  Future<void> _createPO() async {
    if (_selectedSupplier == null || _lines.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final request = PurchaseOrderCreateRequest()
        ..idempotencyKey = _idempotencyKey
        ..propertyId = widget.propertyId
        ..supplierId = _selectedSupplier!.id
        ..expectedDeliveryDate = Timestamp.fromDateTime(
          DateTime.utc(
            _expectedDelivery.year,
            _expectedDelivery.month,
            _expectedDelivery.day,
          ),
        )
        ..notes = _notes;

      for (final line in _lines) {
        request.lines.add(
          PurchaseOrderLineInput()
            ..supplierItemId = line.supplierItemId
            ..inventoryItemId = line.inventoryItemId
            ..orderedQuantity = line.quantity
            ..unit = line.unit,
        );
      }

      final notifier = ref.read(procurementNotifierProvider.notifier);
      final created = await notifier.createPO(request);
      ref.invalidate(purchaseOrderListProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchase order created')));
        context.go(
          created.id.isNotEmpty
              ? ProcurementPaths.order(created.id)
              : ProcurementPaths.orders,
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

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
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
                Text(
                  'New Purchase Order',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stepper indicators
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
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: switch (_step) {
                0 => _StepSupplier(
                  selected: _selectedSupplier,
                  onSelected: (s) => setState(() {
                    // Lines reference the previous supplier's catalogue.
                    if (s.id != _selectedSupplier?.id) _lines.clear();
                    _selectedSupplier = s;
                  }),
                ),
                1 => _StepLines(
                  supplierId: _selectedSupplier!.id,
                  lines: _lines,
                  onAdd: (l) => setState(() => _lines.add(l)),
                  onRemove: (i) => setState(() => _lines.removeAt(i)),
                ),
                2 => _StepDelivery(
                  date: _expectedDelivery,
                  notes: _notes,
                  onDateChanged: (d) => setState(() => _expectedDelivery = d),
                  onNotesChanged: (n) => setState(() => _notes = n),
                ),
                3 => _StepConfirm(
                  supplier: _selectedSupplier,
                  lines: _lines,
                  expectedDelivery: _expectedDelivery,
                  notes: _notes,
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
                if (_step < 3)
                  FilledButton(
                    onPressed: _canAdvance
                        ? () => setState(() => _step++)
                        : null,
                    child: const Text('Next'),
                  ),
                if (_step == 3)
                  FilledButton.icon(
                    onPressed: _submitting ? null : _createPO,
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
                    label: const Text('Create PO'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Step Widgets -----

class _StepSupplier extends ConsumerWidget {
  const _StepSupplier({this.selected, required this.onSelected});

  final Supplier? selected;
  final ValueChanged<Supplier> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncSuppliers = ref.watch(
      supplierListProvider((
        type: null,
        status: SupplierStatus.SUPPLIER_STATUS_ACTIVE,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Supplier',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: asyncSuppliers.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (suppliers) => ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final s = suppliers[index];
                final isSelected = s.id == selected?.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          )
                        : null,
                    child: SupplierCard(
                      supplier: s,
                      onTap: () => onSelected(s),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StepLines extends ConsumerStatefulWidget {
  const _StepLines({
    required this.supplierId,
    required this.lines,
    required this.onAdd,
    required this.onRemove,
  });

  final String supplierId;
  final List<_POLineItem> lines;
  final ValueChanged<_POLineItem> onAdd;
  final ValueChanged<int> onRemove;

  @override
  ConsumerState<_StepLines> createState() => _StepLinesState();
}

class _StepLinesState extends ConsumerState<_StepLines> {
  SupplierItem? _item;
  final _qtyController = TextEditingController(text: '1');
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _selectItem(SupplierItem? item) {
    setState(() {
      _item = item;
      _unitController.text = item?.unit ?? '';
      if (item != null && item.minOrderQuantity > 0) {
        _qtyController.text = _formatQty(item.minOrderQuantity);
      }
    });
  }

  void _addLine() {
    final item = _item;
    final qty = double.tryParse(_qtyController.text.trim()) ?? 0;
    if (item == null || qty <= 0) return;
    final unit = _unitController.text.trim();
    widget.onAdd(
      _POLineItem(
        supplierItemId: item.id,
        inventoryItemId: item.inventoryItemId,
        label: item.supplierSku.isNotEmpty
            ? item.supplierSku
            : item.inventoryItemId,
        quantity: qty,
        unit: unit.isNotEmpty ? unit : item.unit,
      ),
    );
    _selectItem(null);
    _qtyController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncItems = ref.watch(supplierItemListProvider(widget.supplierId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Order Lines',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        asyncItems.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Failed to load supplier items: $e',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          data: (all) {
            final items = all
                .where(
                  (i) =>
                      i.status !=
                      SupplierItemStatus.SUPPLIER_ITEM_STATUS_DISCONTINUED,
                )
                .toList();
            if (items.isEmpty) {
              return Text(
                'This supplier has no active items. Add items on the '
                'supplier page first.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<SupplierItem>(
                    key: ValueKey(_item?.id),
                    initialValue: _item,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Supplier item',
                      isDense: true,
                    ),
                    items: [
                      for (final i in items)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            i.supplierSku.isNotEmpty
                                ? '${i.supplierSku} (${i.inventoryItemId})'
                                : i.inventoryItemId,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _selectItem,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Add line',
                  onPressed: _item == null ? null : _addLine,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: widget.lines.isEmpty
              ? Center(
                  child: Text(
                    'No lines added',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.lines.length,
                  itemBuilder: (context, index) {
                    final line = widget.lines[index];
                    return ListTile(
                      dense: true,
                      title: Text(line.label),
                      subtitle: Text(
                        '${_formatQty(line.quantity)} ${line.unit}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => widget.onRemove(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

String _formatQty(double qty) =>
    qty == qty.roundToDouble() ? qty.toStringAsFixed(0) : qty.toString();

class _StepDelivery extends StatelessWidget {
  const _StepDelivery({
    required this.date,
    required this.notes,
    required this.onDateChanged,
    required this.onNotesChanged,
  });

  final DateTime date;
  final String notes;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Details',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          ),
          subtitle: const Text('Expected delivery date'),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onDateChanged(picked);
          },
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

class _StepConfirm extends StatelessWidget {
  const _StepConfirm({
    this.supplier,
    required this.lines,
    required this.expectedDelivery,
    required this.notes,
  });

  final Supplier? supplier;
  final List<_POLineItem> lines;
  final DateTime expectedDelivery;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Purchase Order',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _Row(label: 'Supplier', value: supplier?.name ?? 'None'),
        _Row(label: 'Lines', value: '${lines.length} items'),
        _Row(
          label: 'Delivery',
          value:
              '${expectedDelivery.year}-${expectedDelivery.month.toString().padLeft(2, '0')}-${expectedDelivery.day.toString().padLeft(2, '0')}',
        ),
        if (notes.isNotEmpty) _Row(label: 'Notes', value: notes),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              for (final line in lines)
                ListTile(
                  dense: true,
                  title: Text(line.label),
                  trailing: Text('${_formatQty(line.quantity)} ${line.unit}'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
            child: Text(
              value,
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

class _POLineItem {
  const _POLineItem({
    required this.supplierItemId,
    required this.inventoryItemId,
    required this.label,
    required this.quantity,
    required this.unit,
  });

  final String supplierItemId;
  final String inventoryItemId;
  final String label;
  final double quantity;
  final String unit;
}
