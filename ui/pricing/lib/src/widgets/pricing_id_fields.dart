import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/pricing_validators.dart';

/// Customer ID input: search customers by name, or type/paste an ID. The
/// validated ID lives in [controller].
class CustomerIdField extends StatefulWidget {
  const CustomerIdField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  State<CustomerIdField> createState() => _CustomerIdFieldState();
}

class _CustomerIdFieldState extends State<CustomerIdField> {
  String? _selectedName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enabled) ...[
          CustomerSearchSelect(
            onSelected: (profile) => setState(() {
              widget.controller.text = profile.id;
              _selectedName = profileName(profile);
            }),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: 'Customer ID',
            helperText: _selectedName != null
                ? 'Selected: $_selectedName'
                : 'Search above or enter the customer ID',
          ),
          validator: (v) => validateEntityId(v, 'Customer ID'),
          onChanged: (_) {
            if (_selectedName != null) setState(() => _selectedName = null);
          },
        ),
      ],
    );
  }
}

/// Product variant ID input: search a product and pick one of its variants,
/// or type/paste a variant ID. The validated ID lives in [controller].
class VariantIdField extends ConsumerStatefulWidget {
  const VariantIdField({
    super.key,
    required this.shopId,
    required this.controller,
    this.enabled = true,
  });

  final String shopId;
  final TextEditingController controller;
  final bool enabled;

  @override
  ConsumerState<VariantIdField> createState() => _VariantIdFieldState();
}

class _VariantIdFieldState extends ConsumerState<VariantIdField> {
  Product? _product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enabled) ...[
          ProductSearchSelect(
            shopId: widget.shopId,
            onSelected: (p) => setState(() => _product = p),
          ),
          if (_product != null) ...[
            const SizedBox(height: 8),
            ref
                .watch(productVariantsProvider(_product!.id))
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Could not load variants: ${friendlyError(e)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  data: (variants) => variants.isEmpty
                      ? Text(
                          '${_product!.name} has no variants',
                          style: theme.textTheme.bodySmall,
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final v in variants)
                              ChoiceChip(
                                label: Text(v.name.isNotEmpty ? v.name : v.sku),
                                selected: widget.controller.text == v.id,
                                onSelected: (_) => setState(
                                  () => widget.controller.text = v.id,
                                ),
                              ),
                          ],
                        ),
                ),
          ],
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: const InputDecoration(
            labelText: 'Product Variant ID',
            helperText: 'Search a product above or enter the variant ID',
          ),
          validator: (v) => validateEntityId(v, 'Variant ID'),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
