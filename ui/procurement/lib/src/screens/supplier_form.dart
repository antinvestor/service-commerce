import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/procurement_providers.dart';

const _typeLabels = <String, SupplierType>{
  'Raw Material': SupplierType.SUPPLIER_TYPE_RAW_MATERIAL,
  'Packaging': SupplierType.SUPPLIER_TYPE_PACKAGING,
  'Service': SupplierType.SUPPLIER_TYPE_SERVICE,
  'Equipment': SupplierType.SUPPLIER_TYPE_EQUIPMENT,
};

const _statusLabels = <String, SupplierStatus>{
  'Active': SupplierStatus.SUPPLIER_STATUS_ACTIVE,
  'Suspended': SupplierStatus.SUPPLIER_STATUS_SUSPENDED,
  'Inactive': SupplierStatus.SUPPLIER_STATUS_INACTIVE,
};

const _ratingLabels = <String, SupplierRating>{
  'Unrated': SupplierRating.SUPPLIER_RATING_UNRATED,
  'Approved': SupplierRating.SUPPLIER_RATING_APPROVED,
  'Preferred': SupplierRating.SUPPLIER_RATING_PREFERRED,
  'Probation': SupplierRating.SUPPLIER_RATING_PROBATION,
};

String _labelFor<T>(Map<String, T> labels, T value, String fallback) {
  for (final entry in labels.entries) {
    if (entry.value == value) return entry.key;
  }
  return fallback;
}

/// Shows the supplier create/edit dialog and persists it via
/// [ProcurementNotifier.saveSupplier]. Pass [existing] to edit (its id is
/// carried into the request). Returns true on success.
Future<bool> showSupplierForm({
  required BuildContext context,
  required WidgetRef ref,
  Supplier? existing,
}) async {
  final isEdit = existing != null;
  final values = await showEditDialog(
    context: context,
    title: isEdit ? 'Edit Supplier' : 'New Supplier',
    saveLabel: isEdit ? 'Save' : 'Create',
    fields: [
      DialogField(
        key: 'name',
        label: 'Name',
        required: true,
        initialValue: existing?.name ?? '',
      ),
      DialogField(
        key: 'type',
        label: 'Type',
        type: DialogFieldType.dropdown,
        options: _typeLabels.keys.toList(),
        initialValue: isEdit
            ? _labelFor(_typeLabels, existing.supplierType, '')
            : '',
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: _statusLabels.keys.toList(),
        initialValue: isEdit
            ? _labelFor(_statusLabels, existing.status, 'Active')
            : 'Active',
      ),
      DialogField(
        key: 'rating',
        label: 'Rating',
        type: DialogFieldType.dropdown,
        options: _ratingLabels.keys.toList(),
        initialValue: isEdit
            ? _labelFor(_ratingLabels, existing.rating, 'Unrated')
            : 'Unrated',
      ),
      DialogField(
        key: 'currency',
        label: 'Currency',
        hint: 'e.g. KES',
        initialValue: existing?.currency ?? '',
      ),
      DialogField(
        key: 'paymentTermsDays',
        label: 'Payment Terms (days)',
        initialValue: isEdit ? '${existing.paymentTermsDays}' : '0',
      ),
      DialogField(
        key: 'leadTimeDays',
        label: 'Lead Time (days)',
        initialValue: isEdit ? '${existing.leadTimeDays}' : '0',
      ),
      DialogField(
        key: 'notes',
        label: 'Notes',
        type: DialogFieldType.textarea,
        initialValue: existing?.notes ?? '',
      ),
    ],
  );
  if (values == null || !context.mounted) return false;

  final name = (values['name'] ?? '').trim();
  if (name.isEmpty) {
    _showError(context, 'Name is required');
    return false;
  }

  final request = SupplierSaveRequest()
    ..name = name
    ..currency = (values['currency'] ?? '').trim()
    ..paymentTermsDays =
        int.tryParse((values['paymentTermsDays'] ?? '0').trim()) ?? 0
    ..leadTimeDays =
        int.tryParse((values['leadTimeDays'] ?? '0').trim()) ?? 0
    ..notes = (values['notes'] ?? '').trim();

  final type = _typeLabels[values['type']];
  if (type != null) request.supplierType = type;
  final status = _statusLabels[values['status']];
  if (status != null) request.status = status;
  final rating = _ratingLabels[values['rating']];
  if (rating != null) request.rating = rating;
  if (isEdit) {
    request.id = existing.id;
    if (existing.profileId.isNotEmpty) request.profileId = existing.profileId;
  }

  try {
    final notifier = ref.read(procurementNotifierProvider.notifier);
    final saved = await notifier.saveSupplier(request);
    ref.invalidate(supplierListProvider(null));
    if (isEdit) ref.invalidate(supplierByIdProvider(saved.id));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Supplier updated' : 'Supplier created')),
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
