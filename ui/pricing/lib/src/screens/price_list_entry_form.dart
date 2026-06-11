import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';

/// Shows the price-list entry create/edit dialog and persists it via
/// [PricingNotifier.batchSaveEntries]. Because the backend replaces all entries
/// for a given variant, saving sends the complete desired set of entries for
/// the affected variant. Pass [existing] to edit. Returns true on success.
Future<bool> showPriceListEntryForm({
  required BuildContext context,
  required WidgetRef ref,
  required String priceListId,
  required String currency,
  PriceListEntry? existing,
}) async {
  final isEdit = existing != null;
  final values = await showEditDialog(
    context: context,
    title: isEdit ? 'Edit Entry' : 'Add Entry',
    saveLabel: isEdit ? 'Save' : 'Add',
    fields: [
      DialogField(
        key: 'variant',
        label: 'Product Variant ID',
        required: true,
        initialValue: existing?.productVariantId ?? '',
      ),
      DialogField(
        key: 'price',
        label: 'Unit Price',
        hint: 'e.g. 1500.00',
        required: true,
        initialValue: isEdit ? moneyToAmountString(existing.unitPrice) : '',
      ),
      DialogField(
        key: 'minQuantity',
        label: 'Minimum Quantity',
        initialValue: isEdit ? '${existing.minQuantity}' : '0',
      ),
      DialogField(
        key: 'maxQuantity',
        label: 'Maximum Quantity',
        hint: '0 for unlimited',
        initialValue: isEdit ? '${existing.maxQuantity}' : '0',
      ),
    ],
  );
  if (values == null || !context.mounted) return false;

  final variantId = (values['variant'] ?? '').trim();
  final priceStr = (values['price'] ?? '').trim();
  if (variantId.isEmpty || double.tryParse(priceStr) == null) {
    _showError(context, 'Variant ID and a numeric price are required');
    return false;
  }

  final entry = PriceListEntry()
    ..priceListId = priceListId
    ..productVariantId = variantId
    ..minQuantity = int.tryParse((values['minQuantity'] ?? '0').trim()) ?? 0
    ..maxQuantity = int.tryParse((values['maxQuantity'] ?? '0').trim()) ?? 0;
  setMoneyFields(entry.unitPrice, priceStr, currency);
  if (isEdit) entry.id = existing.id;

  // The backend replaces all entries for the variant. Send the complete set of
  // entries that should exist for this variant: the new/updated one plus any
  // other tiers for the same variant already known in this session.
  final notifier = ref.read(pricingNotifierProvider.notifier);
  final existingForVariant = notifier
      .entriesFor(priceListId)
      .where((e) => e.productVariantId == variantId && e.id != entry.id)
      .toList();
  final desired = [...existingForVariant, entry];

  try {
    await notifier.batchSaveEntries(
      PriceListEntryBatchSaveRequest()
        ..priceListId = priceListId
        ..entries.addAll(desired),
    );
    ref.invalidate(priceListEntryListProvider(priceListId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Entry updated' : 'Entry added')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) _showError(context, 'Error: $e');
    return false;
  }
}

/// Deletes a single entry by re-saving the remaining entries for its variant.
Future<bool> deletePriceListEntry({
  required BuildContext context,
  required WidgetRef ref,
  required String priceListId,
  required PriceListEntry entry,
}) async {
  final confirmed = await showConfirmDialog(
    context: context,
    title: 'Delete Entry',
    message: 'Remove the price for ${entry.productVariantId}?',
  );
  if (!confirmed || !context.mounted) return false;

  final notifier = ref.read(pricingNotifierProvider.notifier);
  // Re-save the variant with all of its tiers except the one being removed.
  // The backend deletes every existing entry for a variant before recreating
  // the supplied ones, so resending the surviving tiers removes this entry.
  final remaining = notifier
      .entriesFor(priceListId)
      .where((e) =>
          e.productVariantId == entry.productVariantId && e.id != entry.id)
      .toList();

  try {
    await notifier.removeVariantEntries(
      priceListId: priceListId,
      variantId: entry.productVariantId,
      remaining: remaining,
    );
    ref.invalidate(priceListEntryListProvider(priceListId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted')),
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
