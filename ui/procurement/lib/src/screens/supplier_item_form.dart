import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';
import '../providers/supply_pickers.dart';
import '../util/supply.dart';

const _statusLabels = <String, SupplierItemStatus>{
  'Active': SupplierItemStatus.SUPPLIER_ITEM_STATUS_ACTIVE,
  'Discontinued': SupplierItemStatus.SUPPLIER_ITEM_STATUS_DISCONTINUED,
};

final _idPattern = RegExp(r'^[0-9a-z_-]{3,40}$');
final _amountPattern = RegExp(r'^\d+(\.\d{1,9})?$');

/// Shows the supplier-item create/edit dialog and persists it via
/// [ProcurementNotifier.saveSupplierItem]. Pass [existing] to edit. The
/// [supplierId] scopes the item and the list refreshed on save. Returns true
/// on success.
Future<bool> showSupplierItemForm({
  required BuildContext context,
  required WidgetRef ref,
  required String supplierId,
  String currency = '',
  SupplierItem? existing,
}) async {
  final request = await showDialog<SupplierItemSaveRequest>(
    context: context,
    builder: (_) => SupplierItemFormDialog(
      supplierId: supplierId,
      currency: currency,
      existing: existing,
    ),
  );
  if (request == null || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(procurementNotifierProvider.notifier)
        .saveSupplierItem(request);
    ref.invalidate(supplierItemPagesProvider(supplierId));
    ref.invalidate(supplierItemListProvider(supplierId));
    messenger.showSnackBar(
      SnackBar(content: Text(existing != null ? 'Item updated' : 'Item added')),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not save the item: ${friendlyError(e)}')),
    );
    return false;
  }
}

/// Form for what a supplier offers: a manufacturing material or a product
/// variant bought for resale, its price and ordering terms.
///
/// What an item supplies is fixed once created, so editing shows it but
/// does not let it change. Pops with the request to save, or null.
class SupplierItemFormDialog extends ConsumerStatefulWidget {
  const SupplierItemFormDialog({
    super.key,
    required this.supplierId,
    this.currency = '',
    this.existing,
  });

  final String supplierId;
  final String currency;
  final SupplierItem? existing;

  @override
  ConsumerState<SupplierItemFormDialog> createState() =>
      _SupplierItemFormDialogState();
}

class _SupplierItemFormDialogState
    extends ConsumerState<SupplierItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late SupplyKind _kind;
  late final TextEditingController _target;
  late final TextEditingController _sku;
  late final TextEditingController _price;
  late final TextEditingController _currency;
  late final TextEditingController _unit;
  late final TextEditingController _moq;
  late final TextEditingController _leadTime;
  late SupplierItemStatus _status;
  String _pickedLabel = '';

  SupplierItem? get _existing => widget.existing;
  bool get _isEdit => _existing != null;

  @override
  void initState() {
    super.initState();
    final e = _existing;
    _kind = e == null || e.supplyKind == SupplyKind.SUPPLY_KIND_UNSPECIFIED
        ? SupplyKind.SUPPLY_KIND_MATERIAL
        : e.supplyKind;
    _target = TextEditingController(
      text: e == null
          ? ''
          : suppliedId(
              _kind,
              inventoryItemId: e.inventoryItemId,
              productVariantId: e.productVariantId,
            ),
    );
    _sku = TextEditingController(text: e?.supplierSku ?? '');
    _price = TextEditingController(
      text: e != null && e.hasUnitPrice()
          ? moneyToAmountString(e.unitPrice)
          : '',
    );
    _currency = TextEditingController(
      text: e != null && e.unitPrice.currencyCode.isNotEmpty
          ? e.unitPrice.currencyCode
          : widget.currency,
    );
    _unit = TextEditingController(text: e?.unit ?? '');
    _moq = TextEditingController(
      text: e != null && e.minOrderQuantity > 0
          ? _formatQty(e.minOrderQuantity)
          : '',
    );
    _leadTime = TextEditingController(
      text: e != null && e.leadTimeDays > 0 ? '${e.leadTimeDays}' : '',
    );
    _status = e?.status ?? SupplierItemStatus.SUPPLIER_ITEM_STATUS_ACTIVE;
    if (_status == SupplierItemStatus.SUPPLIER_ITEM_STATUS_UNSPECIFIED) {
      _status = SupplierItemStatus.SUPPLIER_ITEM_STATUS_ACTIVE;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _target,
      _sku,
      _price,
      _currency,
      _unit,
      _moq,
      _leadTime,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _targetLabel =>
      isResale(_kind) ? 'Product variant ID' : 'Inventory item ID';

  String? _validateTarget(String? v) {
    final id = (v ?? '').trim();
    if (id.isEmpty) {
      return isResale(_kind)
          ? 'Pick the product variant'
          : 'Pick the inventory item';
    }
    if (!_idPattern.hasMatch(id)) return 'Not a valid ID';
    return null;
  }

  String? _validatePrice(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Price is required';
    if (!_amountPattern.hasMatch(text)) return 'Enter an amount, e.g. 1500.00';
    return null;
  }

  String? _validateMoq(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null;
    final q = double.tryParse(text);
    if (q == null || q < 0) return 'Enter a quantity';
    if (needsWholeUnits(_kind) && q != q.roundToDouble()) {
      return 'Products are bought in whole units';
    }
    return null;
  }

  String? _validateLeadTime(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null;
    final d = int.tryParse(text);
    if (d == null || d < 0) return 'Enter whole days';
    return null;
  }

  void _setKind(SupplyKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      _target.clear();
      _pickedLabel = '';
    });
  }

  void _picked(SupplyChoice choice) {
    setState(() {
      _target.text = choice.id;
      _pickedLabel = choice.label;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id = _target.text.trim();
    final request = SupplierItemSaveRequest()
      ..supplierId = widget.supplierId
      ..supplierSku = _sku.text.trim()
      ..unit = _unit.text.trim()
      ..minOrderQuantity = double.tryParse(_moq.text.trim()) ?? 0
      ..leadTimeDays = int.tryParse(_leadTime.text.trim()) ?? 0
      ..status = _status;
    setMoneyFields(
      request.ensureUnitPrice(),
      _price.text.trim(),
      _currency.text.trim().toUpperCase(),
    );
    final existing = _existing;
    if (existing != null) {
      request.id = existing.id;
    } else {
      request.supplyKind = _kind;
      if (isResale(_kind)) {
        request.productVariantId = id;
      } else {
        request.inventoryItemId = id;
      }
    }
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = _isEdit
        ? null
        : ref.watch(supplyPickersProvider).forKind(_kind);

    return AlertDialog(
      title: Text(_isEdit ? 'Edit item' : 'Add item'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<SupplyKind>(
                    key: const Key('supply_kind'),
                    segments: const [
                      ButtonSegment(
                        value: SupplyKind.SUPPLY_KIND_MATERIAL,
                        icon: Icon(Icons.inventory_2_outlined),
                        label: Text('Material'),
                      ),
                      ButtonSegment(
                        value: SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT,
                        icon: Icon(Icons.sell_outlined),
                        label: Text('Product for resale'),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: _isEdit
                        ? null
                        : (s) => _setKind(s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEdit
                        ? '${supplyDestination(_kind)} What an item '
                              'supplies cannot change once it is created.'
                        : supplyDestination(_kind),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (picker != null) ...[
                    KeyedSubtree(
                      key: ValueKey('picker_$_kind'),
                      child: picker(context, _picked),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    key: const Key('supplier_item_target'),
                    controller: _target,
                    readOnly: _isEdit,
                    decoration: InputDecoration(
                      labelText: _targetLabel,
                      helperText: _pickedLabel.isNotEmpty
                          ? 'Selected: $_pickedLabel'
                          : _isEdit
                          ? null
                          : picker != null
                          ? 'Pick above, or paste the ID'
                          : 'Paste the ID',
                    ),
                    validator: _validateTarget,
                    onChanged: (_) {
                      if (_pickedLabel.isNotEmpty) {
                        setState(() => _pickedLabel = '');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('supplier_item_sku'),
                    controller: _sku,
                    decoration: const InputDecoration(
                      labelText: 'Supplier SKU (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: const Key('supplier_item_price'),
                          controller: _price,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Unit price',
                            hintText: 'e.g. 1500.00',
                          ),
                          validator: _validatePrice,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          key: const Key('supplier_item_currency'),
                          controller: _currency,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                          ),
                          validator: (v) =>
                              validateCurrency(v?.trim().toUpperCase()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('supplier_item_unit'),
                          controller: _unit,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            hintText: isResale(_kind)
                                ? 'e.g. piece'
                                : 'e.g. kg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          key: const Key('supplier_item_moq'),
                          controller: _moq,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Min order',
                          ),
                          validator: _validateMoq,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('supplier_item_lead_time'),
                    controller: _leadTime,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Lead time (days)',
                    ),
                    validator: _validateLeadTime,
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SupplierItemStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final e in _statusLabels.entries)
                          DropdownMenuItem(value: e.value, child: Text(e.key)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('supplier_item_save'),
          onPressed: _submit,
          child: Text(_isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

String _formatQty(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toString();
