import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../widgets/price_resolver_preview.dart';

/// Screen for resolving the effective price for a customer + variant combination.
class PriceCheckerScreen extends ConsumerStatefulWidget {
  const PriceCheckerScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<PriceCheckerScreen> createState() =>
      _PriceCheckerScreenState();
}

class _PriceCheckerScreenState extends ConsumerState<PriceCheckerScreen> {
  ProfileObject? _selectedCustomer;
  ProductVariant? _selectedVariant;
  int _quantity = 1;
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  bool get _canResolve =>
      _selectedCustomer != null && _selectedVariant != null && _quantity > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.price_check,
                    size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Price Checker',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 24),

            // Customer selector
            Text('Customer',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomerSearchSelect(
              onSelected: (p) => setState(() => _selectedCustomer = p),
            ),
            if (_selectedCustomer != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(profileName(_selectedCustomer!)),
                avatar: const Icon(Icons.person, size: 18),
                onDeleted: () =>
                    setState(() => _selectedCustomer = null),
              ),
            ],
            const SizedBox(height: 20),

            // Product/variant selector
            Text('Product Variant',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ProductSearchSelect(
              shopId: widget.shopId,
              onSelected: (product) {
                // Selecting a product — show variant picker if available
                _showVariantPicker(context, product);
              },
            ),
            if (_selectedVariant != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(_selectedVariant!.name.isNotEmpty
                    ? _selectedVariant!.name
                    : _selectedVariant!.sku),
                avatar: const Icon(Icons.sell, size: 18),
                onDeleted: () =>
                    setState(() => _selectedVariant = null),
              ),
            ],
            const SizedBox(height: 20),

            // Quantity
            SizedBox(
              width: 120,
              child: TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  isDense: true,
                ),
                onChanged: (v) =>
                    setState(() => _quantity = int.tryParse(v) ?? 1),
              ),
            ),
            const SizedBox(height: 24),

            // Resolve button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canResolve ? () => setState(() {}) : null,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Resolve Price'),
              ),
            ),
            const SizedBox(height: 24),

            // Result
            if (_canResolve) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final asyncResolved = ref.watch(resolvePriceProvider((
      customerId: _selectedCustomer!.id,
      variantId: _selectedVariant!.id,
      quantity: _quantity,
    )));

    return asyncResolved.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        'Error: ${friendlyError(error)}',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (resolved) => PriceResolverPreview(resolved: resolved),
    );
  }

  void _showVariantPicker(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            VariantSelector(
              variants: const [],
              onSelected: (variant) {
                setState(() => _selectedVariant = variant);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            Text('Select a variant to check its price.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
