import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../utils/pricing_validators.dart';
import '../widgets/pricing_id_fields.dart';
import '../widgets/validity_date_field.dart';

/// Shows the customer price override create/edit dialog and persists it via
/// [PricingNotifier.saveOverride]. The currency defaults to the shop's
/// currency. Pass [existing] to edit. Returns the saved override, or null if
/// cancelled / failed.
Future<CustomerPriceOverride?> showCustomerPriceOverrideForm({
  required BuildContext context,
  required WidgetRef ref,
  required String shopId,
  CustomerPriceOverride? existing,
}) async {
  final shopCurrency = await readShopCurrency(ref, shopId);
  if (!context.mounted) return null;

  final request = await showDialog<CustomerPriceOverrideSaveRequest>(
    context: context,
    builder: (_) => CustomerPriceOverrideDialog(
      shopId: shopId,
      defaultCurrency: shopCurrency,
      existing: existing,
    ),
  );
  if (request == null || !context.mounted) return null;

  final isEdit = existing != null;
  try {
    final saved = await ref
        .read(pricingNotifierProvider.notifier)
        .saveOverride(request);
    ref.invalidate(customerOverrideListProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Override updated' : 'Override created'),
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

const _statusLabels = {
  CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE: 'Active',
  CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED: 'Expired',
};

/// Form dialog that pops a [CustomerPriceOverrideSaveRequest] on save.
class CustomerPriceOverrideDialog extends StatefulWidget {
  const CustomerPriceOverrideDialog({
    super.key,
    required this.shopId,
    required this.defaultCurrency,
    this.existing,
  });

  final String shopId;
  final String defaultCurrency;
  final CustomerPriceOverride? existing;

  @override
  State<CustomerPriceOverrideDialog> createState() =>
      _CustomerPriceOverrideDialogState();
}

class _CustomerPriceOverrideDialogState
    extends State<CustomerPriceOverrideDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customer;
  late final TextEditingController _variant;
  late final TextEditingController _price;
  late final TextEditingController _currency;
  DateTime? _validFrom;
  DateTime? _validUntil;
  late CustomerPriceOverrideStatus _status;
  String? _rangeError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _customer = TextEditingController(text: e?.customerId ?? '');
    _variant = TextEditingController(text: e?.productVariantId ?? '');
    _price = TextEditingController(
      text: e != null && e.hasUnitPrice()
          ? moneyToAmountString(e.unitPrice)
          : '',
    );
    _currency = TextEditingController(
      text: e != null && e.hasUnitPrice() && e.unitPrice.currencyCode.isNotEmpty
          ? e.unitPrice.currencyCode
          : widget.defaultCurrency,
    );
    _validFrom = e != null
        ? timestampToDate(e.hasValidFrom(), e.validFrom)
        : null;
    _validUntil = e != null
        ? timestampToDate(e.hasValidUntil(), e.validUntil)
        : null;
    _status = e != null && _statusLabels.containsKey(e.status)
        ? e.status
        : CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE;
  }

  @override
  void dispose() {
    _customer.dispose();
    _variant.dispose();
    _price.dispose();
    _currency.dispose();
    super.dispose();
  }

  void _submit() {
    final rangeError = validateValidityRange(_validFrom, _validUntil);
    setState(() => _rangeError = rangeError);
    if (!_formKey.currentState!.validate() || rangeError != null) return;

    final request = CustomerPriceOverrideSaveRequest()
      ..customerId = _customer.text.trim()
      ..productVariantId = _variant.text.trim()
      ..status = _status;
    setMoneyFields(
      request.ensureUnitPrice(),
      _price.text.trim().replaceAll(',', ''),
      _currency.text.trim().toUpperCase(),
    );
    if (_validFrom != null) request.validFrom = dateToTimestamp(_validFrom!);
    if (_validUntil != null) request.validUntil = dateToTimestamp(_validUntil!);
    if (widget.existing != null) request.id = widget.existing!.id;
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Customer Price' : 'New Customer Price'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomerIdField(controller: _customer),
                const SizedBox(height: 16),
                VariantIdField(shopId: widget.shopId, controller: _variant),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: const ValueKey('override-price'),
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                          hintText: 'e.g. 1500.00',
                        ),
                        validator: validateAmount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currency,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          helperText: 'Shop currency',
                        ),
                        validator: (v) =>
                            validateCurrency(v?.trim().toUpperCase()),
                      ),
                    ),
                  ],
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
                DropdownButtonFormField<CustomerPriceOverrideStatus>(
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
