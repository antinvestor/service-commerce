import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';

const _statusLabels = <String, SupplierItemStatus>{
  'Active': SupplierItemStatus.SUPPLIER_ITEM_STATUS_ACTIVE,
  'Discontinued': SupplierItemStatus.SUPPLIER_ITEM_STATUS_DISCONTINUED,
};

String _statusLabelFor(SupplierItemStatus value) {
  for (final entry in _statusLabels.entries) {
    if (entry.value == value) return entry.key;
  }
  return 'Active';
}

/// Shows the supplier-item create/edit dialog and persists it via
/// [ProcurementNotifier.saveSupplierItem]. Pass [existing] to edit. The
/// [supplierId] scopes the item and the provider that is invalidated on save.
/// Returns true on success.
Future<bool> showSupplierItemForm({
  required BuildContext context,
  required WidgetRef ref,
  required String supplierId,
  String currency = '',
  SupplierItem? existing,
}) async {
  final isEdit = existing != null;
  final values = await showEditDialog(
    context: context,
    title: isEdit ? 'Edit Item' : 'Add Item',
    saveLabel: isEdit ? 'Save' : 'Add',
    fields: [
      DialogField(
        key: 'inventoryItemId',
        label: 'Inventory Item ID',
        required: true,
        initialValue: existing?.inventoryItemId ?? '',
      ),
      DialogField(
        key: 'supplierSku',
        label: 'Supplier SKU',
        initialValue: existing?.supplierSku ?? '',
      ),
      DialogField(
        key: 'unitPrice',
        label: 'Unit Price',
        hint: 'e.g. 1500.00',
        required: true,
        initialValue: isEdit ? moneyToAmountString(existing.unitPrice) : '',
      ),
      DialogField(
        key: 'unit',
        label: 'Unit',
        hint: 'e.g. kg',
        initialValue: existing?.unit ?? '',
      ),
      DialogField(
        key: 'minOrderQuantity',
        label: 'Min Order Quantity',
        initialValue: isEdit ? '${existing.minOrderQuantity}' : '0',
      ),
      DialogField(
        key: 'leadTimeDays',
        label: 'Lead Time (days)',
        initialValue: isEdit ? '${existing.leadTimeDays}' : '0',
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: _statusLabels.keys.toList(),
        initialValue: isEdit ? _statusLabelFor(existing.status) : 'Active',
      ),
    ],
  );
  if (values == null || !context.mounted) return false;

  final inventoryItemId = (values['inventoryItemId'] ?? '').trim();
  final priceStr = (values['unitPrice'] ?? '').trim();
  if (inventoryItemId.isEmpty || double.tryParse(priceStr) == null) {
    _showError(context, 'Inventory Item ID and a numeric price are required');
    return false;
  }

  final request = SupplierItemSaveRequest()
    ..supplierId = supplierId
    ..inventoryItemId = inventoryItemId
    ..supplierSku = (values['supplierSku'] ?? '').trim()
    ..unit = (values['unit'] ?? '').trim()
    ..minOrderQuantity =
        double.tryParse((values['minOrderQuantity'] ?? '0').trim()) ?? 0
    ..leadTimeDays =
        int.tryParse((values['leadTimeDays'] ?? '0').trim()) ?? 0;
  setMoneyFields(request.ensureUnitPrice(), priceStr,
      currency.isNotEmpty ? currency : existing?.unitPrice.currencyCode ?? '');
  final status = _statusLabels[values['status']];
  if (status != null) request.status = status;
  if (isEdit) request.id = existing.id;

  try {
    final notifier = ref.read(procurementNotifierProvider.notifier);
    await notifier.saveSupplierItem(request);
    ref.invalidate(supplierItemListProvider(supplierId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Item updated' : 'Item added')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) _showError(context, 'Error: $e');
    return false;
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
