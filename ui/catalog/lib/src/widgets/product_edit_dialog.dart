import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/foundation.dart' show listEquals, mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import 'attribute_list_editor.dart';
import 'payment_policy_editor.dart';

/// Fulfilment types a product can be created or edited with, with labels.
const fulfilmentTypeOptions = <(FulfilmentType, String)>[
  (FulfilmentType.FULFILMENT_TYPE_PHYSICAL, 'Physical (shipped or collected)'),
  (FulfilmentType.FULFILMENT_TYPE_DIGITAL, 'Digital (delivered online)'),
  (FulfilmentType.FULFILMENT_TYPE_NONE, 'None (service, nothing to deliver)'),
];

/// Product statuses a product can be edited to, with labels.
const productStatusOptions = <(ProductStatus, String)>[
  (ProductStatus.PRODUCT_STATUS_ACTIVE, 'Active'),
  (ProductStatus.PRODUCT_STATUS_INACTIVE, 'Inactive'),
  (ProductStatus.PRODUCT_STATUS_ARCHIVED, 'Archived'),
];

/// Builds the `UpdateProduct` request for the edits made to [original].
///
/// Only fields whose value changed go into the update mask. A `null`
/// [paymentPolicy] on a product that had an override puts `payment_policy`
/// in the mask with the field unset, which removes the override. Returns
/// `null` when nothing changed. Throws a [FormatException] with a
/// user-facing message when a value is invalid.
UpdateProductRequest? buildProductUpdateRequest(
  Product original, {
  required String name,
  required String description,
  required Map<String, String> attributes,
  required FulfilmentType fulfilmentType,
  required ProductStatus status,
  required PaymentPolicy? paymentPolicy,
}) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    throw const FormatException('Name is required.');
  }
  final policyError = validatePaymentPolicy(paymentPolicy);
  if (policyError != null) throw FormatException(policyError);

  final request = UpdateProductRequest(id: original.id);
  final paths = <String>[];

  if (trimmedName != original.name) {
    request.name = trimmedName;
    paths.add('name');
  }
  final trimmedDescription = description.trim();
  if (trimmedDescription != original.description) {
    request.description = trimmedDescription;
    paths.add('description');
  }
  if (!mapEquals(attributes, Map.of(original.attributes))) {
    request.attributes.addAll(attributes);
    paths.add('attributes');
  }
  if (fulfilmentType != original.fulfilmentType) {
    request.fulfilmentType = fulfilmentType;
    paths.add('fulfilment_type');
  }
  if (status != original.status) {
    request.status = status;
    paths.add('status');
  }
  final originalPolicy = original.hasPaymentPolicy()
      ? original.paymentPolicy
      : null;
  if (!_samePolicy(paymentPolicy, originalPolicy)) {
    if (paymentPolicy != null) request.paymentPolicy = paymentPolicy;
    paths.add('payment_policy');
  }

  if (paths.isEmpty) return null;
  request.updateMask = FieldMask(paths: paths);
  return request;
}

// Compares by wire encoding so explicitly-set defaults match unset ones.
bool _samePolicy(PaymentPolicy? a, PaymentPolicy? b) {
  if (a == null || b == null) return a == null && b == null;
  return listEquals(a.writeToBuffer(), b.writeToBuffer());
}

/// Opens the product edit dialog (name, description, attributes,
/// fulfilment type, status and payment policy override) and saves the
/// changes via `UpdateProduct`.
///
/// Returns the updated product, or `null` when the dialog was dismissed,
/// nothing changed, or the update failed (failures are reported with a
/// snackbar).
Future<Product?> showProductEditDialog(BuildContext context, Product product) {
  return showDialog<Product>(
    context: context,
    builder: (_) => _ProductEditDialog(product: product),
  );
}

class _ProductEditDialog extends ConsumerStatefulWidget {
  const _ProductEditDialog({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends ConsumerState<_ProductEditDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.product.name,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.product.description,
  );
  late Map<String, String> _attributes = Map.of(widget.product.attributes);
  late FulfilmentType _fulfilmentType =
      widget.product.fulfilmentType ==
          FulfilmentType.FULFILMENT_TYPE_UNSPECIFIED
      ? FulfilmentType.FULFILMENT_TYPE_PHYSICAL
      : widget.product.fulfilmentType;
  late ProductStatus _status =
      widget.product.status == ProductStatus.PRODUCT_STATUS_UNSPECIFIED
      ? ProductStatus.PRODUCT_STATUS_ACTIVE
      : widget.product.status;
  late PaymentPolicy? _policy = widget.product.hasPaymentPolicy()
      ? widget.product.paymentPolicy
      : null;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final UpdateProductRequest? request;
    try {
      request = buildProductUpdateRequest(
        widget.product,
        name: _name.text,
        description: _description.text,
        attributes: _attributes,
        fulfilmentType: _fulfilmentType,
        status: _status,
        paymentPolicy: _policy,
      );
    } on FormatException catch (e) {
      setState(() => _error = e.message);
      return;
    }
    if (request == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(productNotifierProvider.notifier)
          .update(request);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product updated.')));
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Edit ${widget.product.name}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('product-edit-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('product-edit-description'),
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FulfilmentType>(
                key: const ValueKey('product-edit-fulfilment'),
                isExpanded: true,
                initialValue: _fulfilmentType,
                decoration: const InputDecoration(labelText: 'Fulfilment type'),
                items: [
                  for (final (type, label) in fulfilmentTypeOptions)
                    DropdownMenuItem(
                      value: type,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _fulfilmentType = v);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductStatus>(
                key: const ValueKey('product-edit-status'),
                isExpanded: true,
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  helperText:
                      'Inactive products are hidden from buyers; '
                      'archived ones are retired.',
                ),
                items: [
                  for (final (status, label) in productStatusOptions)
                    DropdownMenuItem(value: status, child: Text(label)),
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
              const SizedBox(height: 12),
              Text('Payment policy', style: theme.textTheme.titleSmall),
              PaymentPolicyEditor(
                initial: _policy,
                allowInherit: true,
                onChanged: (v) => _policy = v,
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
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
