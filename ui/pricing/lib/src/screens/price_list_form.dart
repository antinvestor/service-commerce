import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';

const _statusOptions = ['Active', 'Draft', 'Expired'];

PriceListStatus _statusFromLabel(String label) => switch (label) {
      'Active' => PriceListStatus.PRICE_LIST_STATUS_ACTIVE,
      'Draft' => PriceListStatus.PRICE_LIST_STATUS_DRAFT,
      'Expired' => PriceListStatus.PRICE_LIST_STATUS_EXPIRED,
      _ => PriceListStatus.PRICE_LIST_STATUS_UNSPECIFIED,
    };

String _labelFromStatus(PriceListStatus status) => switch (status) {
      PriceListStatus.PRICE_LIST_STATUS_ACTIVE => 'Active',
      PriceListStatus.PRICE_LIST_STATUS_DRAFT => 'Draft',
      PriceListStatus.PRICE_LIST_STATUS_EXPIRED => 'Expired',
      _ => 'Draft',
    };

/// Shows the price-list create/edit dialog and persists it via
/// [PricingNotifier.savePriceList]. Pass [existing] to edit. Returns the saved
/// price list, or null if cancelled / failed.
Future<PriceList?> showPriceListForm({
  required BuildContext context,
  required WidgetRef ref,
  required String shopId,
  PriceList? existing,
}) async {
  final isEdit = existing != null;
  final values = await showEditDialog(
    context: context,
    title: isEdit ? 'Edit Price List' : 'New Price List',
    saveLabel: isEdit ? 'Save' : 'Create',
    fields: [
      DialogField(
        key: 'name',
        label: 'Name',
        required: true,
        initialValue: existing?.name ?? '',
      ),
      DialogField(
        key: 'currency',
        label: 'Currency',
        hint: '3-letter code, e.g. KES',
        required: true,
        initialValue: existing?.currency ?? '',
      ),
      DialogField(
        key: 'priority',
        label: 'Priority',
        hint: 'Higher wins on conflicts',
        initialValue: isEdit ? '${existing.priority}' : '0',
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: _statusOptions,
        initialValue: isEdit ? _labelFromStatus(existing.status) : 'Draft',
      ),
    ],
  );
  if (values == null || !context.mounted) return null;

  final name = (values['name'] ?? '').trim();
  final currency = (values['currency'] ?? '').trim().toUpperCase();
  if (name.isEmpty || currency.isEmpty) {
    _showError(context, 'Name and currency are required');
    return null;
  }

  final request = PriceListSaveRequest()
    ..shopId = shopId
    ..name = name
    ..currency = currency
    ..priority = int.tryParse((values['priority'] ?? '0').trim()) ?? 0
    ..status = _statusFromLabel(values['status'] ?? 'Draft');
  if (isEdit) request.id = existing.id;

  try {
    final saved = await ref.read(pricingNotifierProvider.notifier).savePriceList(request);
    ref.invalidate(priceListProvider(shopId));
    if (isEdit) ref.invalidate(priceListByIdProvider(existing.id));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Price list updated' : 'Price list created')),
      );
    }
    return saved;
  } catch (e) {
    if (context.mounted) _showError(context, 'Error: $e');
    return null;
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
