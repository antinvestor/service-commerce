import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../utils/pricing_validators.dart';
import '../widgets/validity_date_field.dart';

const _statusLabels = {
  PriceListStatus.PRICE_LIST_STATUS_ACTIVE: 'Active',
  PriceListStatus.PRICE_LIST_STATUS_DRAFT: 'Draft',
  PriceListStatus.PRICE_LIST_STATUS_EXPIRED: 'Expired',
};

/// Shows the price-list create/edit dialog and persists it via
/// [PricingNotifier.savePriceList]. New price lists default to the shop's
/// currency. Pass [existing] to edit. Returns the saved price list, or null if
/// cancelled / failed.
Future<PriceList?> showPriceListForm({
  required BuildContext context,
  required WidgetRef ref,
  required String shopId,
  PriceList? existing,
}) async {
  final isEdit = existing != null;
  final shopCurrency = await readShopCurrency(ref, shopId);
  if (!context.mounted) return null;

  final request = await showDialog<PriceListSaveRequest>(
    context: context,
    builder: (_) => PriceListFormDialog(
      shopId: shopId,
      defaultCurrency: shopCurrency,
      existing: existing,
    ),
  );
  if (request == null || !context.mounted) return null;

  try {
    final saved = await ref
        .read(pricingNotifierProvider.notifier)
        .savePriceList(request);
    ref.invalidate(priceListProvider(shopId));
    if (isEdit) ref.invalidate(priceListByIdProvider(existing.id));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Price list updated' : 'Price list created'),
        ),
      );
    }
    return saved;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return null;
  }
}

/// Form dialog that pops a [PriceListSaveRequest] on save.
class PriceListFormDialog extends StatefulWidget {
  const PriceListFormDialog({
    super.key,
    required this.shopId,
    required this.defaultCurrency,
    this.existing,
  });

  final String shopId;

  /// The shop's currency, pre-filled for new price lists.
  final String defaultCurrency;
  final PriceList? existing;

  @override
  State<PriceListFormDialog> createState() => _PriceListFormDialogState();
}

class _PriceListFormDialogState extends State<PriceListFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _currency;
  late final TextEditingController _priority;
  late PriceListStatus _status;
  DateTime? _validFrom;
  DateTime? _validUntil;
  String? _rangeError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _currency = TextEditingController(
      text: e != null && e.currency.isNotEmpty
          ? e.currency
          : widget.defaultCurrency,
    );
    _priority = TextEditingController(text: e != null ? '${e.priority}' : '0');
    _status = e != null && _statusLabels.containsKey(e.status)
        ? e.status
        : PriceListStatus.PRICE_LIST_STATUS_DRAFT;
    _validFrom = e != null
        ? timestampToDate(e.hasValidFrom(), e.validFrom)
        : null;
    _validUntil = e != null
        ? timestampToDate(e.hasValidUntil(), e.validUntil)
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    _priority.dispose();
    super.dispose();
  }

  void _submit() {
    final rangeError = validateValidityRange(_validFrom, _validUntil);
    setState(() => _rangeError = rangeError);
    if (!_formKey.currentState!.validate() || rangeError != null) return;

    final request = PriceListSaveRequest()
      ..shopId = widget.shopId
      ..name = _name.text.trim()
      ..currency = _currency.text.trim().toUpperCase()
      ..priority = int.tryParse(_priority.text.trim()) ?? 0
      ..status = _status;
    if (_validFrom != null) request.validFrom = dateToTimestamp(_validFrom!);
    if (_validUntil != null) request.validUntil = dateToTimestamp(_validUntil!);
    if (widget.existing != null) request.id = widget.existing!.id;
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Price List' : 'New Price List'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('price-list-currency'),
                  controller: _currency,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    helperText: widget.defaultCurrency.isNotEmpty
                        ? 'Shop currency: ${widget.defaultCurrency}'
                        : '3-letter code, e.g. KES',
                  ),
                  validator: (v) => validateCurrency(v?.trim().toUpperCase()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priority,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    helperText: 'Higher wins on conflicts',
                  ),
                  validator: (v) => int.tryParse(v?.trim() ?? '') == null
                      ? 'Enter a whole number'
                      : null,
                ),
                const SizedBox(height: 16),
                ValidityDateField(
                  label: 'Valid From',
                  value: _validFrom,
                  emptyText: 'Immediately',
                  onChanged: (d) => setState(() => _validFrom = d),
                ),
                const SizedBox(height: 16),
                ValidityDateField(
                  label: 'Valid Until',
                  value: _validUntil,
                  endOfDay: true,
                  errorText: _rangeError,
                  onChanged: (d) => setState(() => _validUntil = d),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PriceListStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final entry in _statusLabels.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
