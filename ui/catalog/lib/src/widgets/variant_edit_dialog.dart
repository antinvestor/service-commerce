import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import '../utils/price_input.dart';
import 'attribute_list_editor.dart';

const _statusActive = 'Active';
const _statusDisabled = 'Disabled';

/// Builds the `UpdateProductVariant` request for the values edited in
/// [showVariantEditDialog].
///
/// The update mask always names `name`, `price`, `stock_quantity` (which the
/// backend only writes when it is explicitly masked) and `status`; `sku` and
/// `attributes` are masked only when they changed. Throws a
/// [FormatException] with a user-facing message when a value is invalid.
UpdateProductVariantRequest buildVariantUpdateRequest(
  ProductVariant variant, {
  required String name,
  required String price,
  required String currency,
  required String stock,
  required String status,
  String? sku,
  Map<String, String>? attributes,
}) {
  final amount = parsePriceAmount(price);
  final currencyCode = currency.trim().toUpperCase();
  if (validateCurrency(currencyCode) != null) {
    throw const FormatException('Currency must be a 3-letter code.');
  }
  final stockQuantity = int.tryParse(stock.trim());
  if (stockQuantity == null || stockQuantity < 0) {
    throw const FormatException('Stock must be a whole number of 0 or more.');
  }

  final paths = ['name', 'price', 'stock_quantity', 'status'];
  final request = UpdateProductVariantRequest(
    variantId: variant.id,
    name: name.trim(),
    stockQuantity: Int64(stockQuantity),
    status: status == _statusDisabled
        ? ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED
        : ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE,
  );
  request.ensurePrice()
    ..currencyCode = currencyCode
    ..units = amount.units
    ..nanos = amount.nanos;

  if (sku != null && sku.trim() != variant.sku) {
    if (sku.trim().isEmpty) {
      throw const FormatException('SKU is required.');
    }
    request.sku = sku.trim();
    paths.add('sku');
  }
  if (attributes != null &&
      !mapEquals(attributes, Map.of(variant.attributes))) {
    request.attributes.addAll(attributes);
    paths.add('attributes');
  }

  request.updateMask = FieldMask(paths: paths);
  return request;
}

/// Opens the edit dialog for [variant] (SKU, name, price, currency, stock,
/// status and attributes) and saves the changes via `UpdateProductVariant`.
///
/// When the variant has no price currency yet, the currency defaults to the
/// currency of [shopId]'s shop.
///
/// Returns the updated variant, or `null` when the dialog was dismissed or
/// the update failed (failures are reported with a snackbar).
Future<ProductVariant?> showVariantEditDialog(
  BuildContext context,
  WidgetRef ref,
  ProductVariant variant, {
  String? shopId,
}) async {
  var defaultCurrency = moneyCurrency(variant.price);
  if (defaultCurrency.isEmpty && shopId != null && shopId.isNotEmpty) {
    try {
      defaultCurrency = await ref.read(shopCurrencyProvider(shopId).future);
    } catch (_) {
      // Leave the currency for the user to enter.
    }
    if (!context.mounted) return null;
  }

  final request = await showDialog<UpdateProductVariantRequest>(
    context: context,
    builder: (_) =>
        _VariantEditDialog(variant: variant, defaultCurrency: defaultCurrency),
  );
  if (request == null || !context.mounted) return null;

  try {
    final updated = await ref
        .read(variantNotifierProvider.notifier)
        .update(request);
    if (context.mounted) _snack(context, 'Variant updated.');
    return updated;
  } catch (e) {
    if (context.mounted) _snack(context, friendlyError(e), isError: true);
    return null;
  }
}

class _VariantEditDialog extends StatefulWidget {
  const _VariantEditDialog({
    required this.variant,
    required this.defaultCurrency,
  });

  final ProductVariant variant;
  final String defaultCurrency;

  @override
  State<_VariantEditDialog> createState() => _VariantEditDialogState();
}

class _VariantEditDialogState extends State<_VariantEditDialog> {
  late final _sku = TextEditingController(text: widget.variant.sku);
  late final _name = TextEditingController(text: widget.variant.name);
  late final _price = TextEditingController(
    text: widget.variant.hasPrice()
        ? formatPriceAmount(
            widget.variant.price.units,
            widget.variant.price.nanos,
          )
        : '',
  );
  late final _currency = TextEditingController(text: widget.defaultCurrency);
  late final _stock = TextEditingController(
    text: widget.variant.stockQuantity.toString(),
  );
  late String _status =
      widget.variant.status ==
          ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED
      ? _statusDisabled
      : _statusActive;
  late Map<String, String> _attributes = Map.of(widget.variant.attributes);
  String? _error;

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _price.dispose();
    _currency.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _save() {
    try {
      final request = buildVariantUpdateRequest(
        widget.variant,
        sku: _sku.text,
        name: _name.text,
        price: _price.text,
        currency: _currency.text,
        stock: _stock.text,
        status: _status,
        attributes: _attributes,
      );
      Navigator.of(context).pop(request);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Edit variant ${widget.variant.sku}'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('variant-edit-sku'),
                controller: _sku,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('variant-edit-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Variant name'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      key: const ValueKey('variant-edit-price'),
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'e.g. 150 or 149.50',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('variant-edit-currency'),
                      controller: _currency,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        hintText: 'ISO 4217 code',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('variant-edit-stock'),
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock on hand'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const ValueKey('variant-edit-status'),
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(
                    value: _statusActive,
                    child: Text(_statusActive),
                  ),
                  DropdownMenuItem(
                    value: _statusDisabled,
                    child: Text(_statusDisabled),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: 20),
              Text('Attributes', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              AttributeListEditor(
                initial: _attributes,
                onChanged: (v) => _attributes = v,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

void _snack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}
