import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

const _statusActive = 'Active';
const _statusDisabled = 'Disabled';

final _amountPattern = RegExp(r'^\d+(\.\d{1,9})?$');

/// Builds the `UpdateProductVariant` request for the values edited in
/// [showVariantEditDialog].
///
/// The update mask names every edited field, including `stock_quantity`,
/// which the backend only writes when it is explicitly masked. Throws a
/// [FormatException] with a user-facing message when a value is invalid.
UpdateProductVariantRequest buildVariantUpdateRequest(
  ProductVariant variant, {
  required String name,
  required String price,
  required String currency,
  required String stock,
  required String status,
}) {
  final amount = price.trim().replaceAll(',', '');
  if (!_amountPattern.hasMatch(amount)) {
    throw const FormatException('Price must be a non-negative amount.');
  }
  final currencyCode = currency.trim().toUpperCase();
  if (validateCurrency(currencyCode) != null) {
    throw const FormatException('Currency must be a 3-letter code.');
  }
  final stockQuantity = int.tryParse(stock.trim());
  if (stockQuantity == null || stockQuantity < 0) {
    throw const FormatException('Stock must be a whole number of 0 or more.');
  }

  final request = UpdateProductVariantRequest(
    variantId: variant.id,
    name: name.trim(),
    stockQuantity: Int64(stockQuantity),
    status: status == _statusDisabled
        ? ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED
        : ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE,
    updateMask: FieldMask(
      paths: const ['name', 'price', 'stock_quantity', 'status'],
    ),
  );
  setMoneyFields(request.ensurePrice(), amount, currencyCode);
  return request;
}

/// Opens the edit dialog for [variant] (name, price, stock, status) and
/// saves the changes via `UpdateProductVariant`.
///
/// Returns the updated variant, or `null` when the dialog was dismissed or
/// the update failed (failures are reported with a snackbar).
Future<ProductVariant?> showVariantEditDialog(
  BuildContext context,
  WidgetRef ref,
  ProductVariant variant,
) async {
  final values = await showEditDialog(
    context: context,
    title: 'Edit variant ${variant.sku}',
    fields: [
      DialogField(
        key: 'name',
        label: 'Variant name',
        initialValue: variant.name,
      ),
      DialogField(
        key: 'price',
        label: 'Price',
        hint: 'e.g. 150 or 149.50',
        initialValue: moneyToAmountString(variant.price),
        required: true,
      ),
      DialogField(
        key: 'currency',
        label: 'Currency',
        hint: 'ISO 4217 code, e.g. KES',
        initialValue: moneyCurrency(variant.price, 'KES'),
        required: true,
      ),
      DialogField(
        key: 'stock',
        label: 'Stock on hand',
        initialValue: variant.stockQuantity.toString(),
        required: true,
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: const [_statusActive, _statusDisabled],
        initialValue:
            variant.status == ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED
                ? _statusDisabled
                : _statusActive,
      ),
    ],
  );
  if (values == null || !context.mounted) return null;

  final UpdateProductVariantRequest request;
  try {
    request = buildVariantUpdateRequest(
      variant,
      name: values['name'] ?? variant.name,
      price: values['price'] ?? '',
      currency: values['currency'] ?? '',
      stock: values['stock'] ?? '',
      status: values['status'] ?? _statusActive,
    );
  } on FormatException catch (e) {
    _snack(context, e.message, isError: true);
    return null;
  }

  try {
    final updated =
        await ref.read(variantNotifierProvider.notifier).update(request);
    if (context.mounted) _snack(context, 'Variant updated.');
    return updated;
  } catch (e) {
    if (context.mounted) _snack(context, friendlyError(e), isError: true);
    return null;
  }
}

void _snack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
  ));
}
