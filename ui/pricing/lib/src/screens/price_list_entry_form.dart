import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../widgets/pricing_id_fields.dart';

/// Shows the price-list entry create/edit dialog and persists it via
/// [PricingNotifier.batchSaveEntries]. Because the backend replaces all entries
/// for a given variant, saving sends the complete desired set of entries for
/// the affected variant. Pass [existing] to edit. Returns true on success.
Future<bool> showPriceListEntryForm({
  required BuildContext context,
  required WidgetRef ref,
  required String priceListId,
  required String currency,
  String shopId = '',
  PriceListEntry? existing,
}) async {
  final isEdit = existing != null;
  final values = await showDialog<PriceListEntryInput>(
    context: context,
    builder: (_) => PriceListEntryDialog(
      shopId: shopId,
      currency: currency,
      existing: existing,
    ),
  );
  if (values == null || !context.mounted) return false;

  final variantId = values.variantId;
  final priceStr = values.price;
  final entry = PriceListEntry()
    ..priceListId = priceListId
    ..productVariantId = variantId
    ..minQuantity = values.minQuantity
    ..maxQuantity = values.maxQuantity;
  setMoneyFields(entry.ensureUnitPrice(), priceStr, currency);
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
      .where(
        (e) => e.productVariantId == entry.productVariantId && e.id != entry.id,
      )
      .toList();

  try {
    await notifier.removeVariantEntries(
      priceListId: priceListId,
      variantId: entry.productVariantId,
      remaining: remaining,
    );
    ref.invalidate(priceListEntryListProvider(priceListId));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
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

/// What the entry dialog collected.
typedef PriceListEntryInput = ({
  String variantId,
  String price,
  int minQuantity,
  int maxQuantity,
});

/// Form for one price list entry: the variant (searched in the shop's
/// catalogue, or pasted), its unit price and the quantity band it applies
/// to. The variant of an existing entry is fixed. Pops with the input, or
/// null.
class PriceListEntryDialog extends StatefulWidget {
  const PriceListEntryDialog({
    super.key,
    required this.shopId,
    required this.currency,
    this.existing,
  });

  final String shopId;
  final String currency;
  final PriceListEntry? existing;

  @override
  State<PriceListEntryDialog> createState() => _PriceListEntryDialogState();
}

class _PriceListEntryDialogState extends State<PriceListEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _variant;
  late final TextEditingController _price;
  late final TextEditingController _min;
  late final TextEditingController _max;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _variant = TextEditingController(text: e?.productVariantId ?? '');
    _price = TextEditingController(
      text: e != null ? moneyToAmountString(e.unitPrice) : '',
    );
    _min = TextEditingController(text: e != null ? '${e.minQuantity}' : '0');
    _max = TextEditingController(text: e != null ? '${e.maxQuantity}' : '0');
  }

  @override
  void dispose() {
    for (final c in [_variant, _price, _min, _max]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validatePrice(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Price is required';
    if (!RegExp(r'^\d+(\.\d{1,9})?$').hasMatch(text)) {
      return 'Enter an amount, e.g. 1500.00';
    }
    return null;
  }

  String? _validateQuantity(String? v) {
    final q = int.tryParse((v ?? '').trim());
    if (q == null || q < 0) return 'Whole number, 0 or more';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final min = int.parse(_min.text.trim());
    final max = int.parse(_max.text.trim());
    if (max != 0 && max < min) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum must be 0 or at least the minimum'),
        ),
      );
      return;
    }
    Navigator.of(context).pop((
      variantId: _variant.text.trim(),
      price: _price.text.trim(),
      minQuantity: min,
      maxQuantity: max,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return AlertDialog(
      title: Text(isEdit ? 'Edit Entry' : 'Add Entry'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VariantIdField(
                    shopId: widget.shopId,
                    controller: _variant,
                    enabled: !isEdit,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('entry-price'),
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Unit price',
                      hintText: 'e.g. 1500.00',
                      suffixText: widget.currency,
                    ),
                    validator: _validatePrice,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('entry-min'),
                          controller: _min,
                          keyboardType: TextInputType.number,
                          inputFormatters: digits,
                          decoration: const InputDecoration(
                            labelText: 'From quantity',
                          ),
                          validator: _validateQuantity,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('entry-max'),
                          controller: _max,
                          keyboardType: TextInputType.number,
                          inputFormatters: digits,
                          decoration: const InputDecoration(
                            labelText: 'Up to (0: no limit)',
                          ),
                          validator: _validateQuantity,
                        ),
                      ),
                    ],
                  ),
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
          key: const ValueKey('entry-save'),
          onPressed: _submit,
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
