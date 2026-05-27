import 'dart:math';

import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Screen for creating a new product variant using a Stepper:
/// 1. SKU (auto-generated)
/// 2. Name & Price
/// 3. Confirm
class VariantCreateScreen extends ConsumerStatefulWidget {
  const VariantCreateScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<VariantCreateScreen> createState() =>
      _VariantCreateScreenState();
}

class _VariantCreateScreenState extends ConsumerState<VariantCreateScreen> {
  int _currentStep = 0;
  late final TextEditingController _skuController;
  final _nameController = TextEditingController();
  final _priceUnitsController = TextEditingController();
  final _currencyController = TextEditingController(text: 'KES');
  final _stockController = TextEditingController(text: '0');
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController(text: _generateSku());
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _priceUnitsController.dispose();
    _currencyController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String _generateSku() {
    final rand = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final suffix =
        List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'SKU-$suffix';
  }

  Future<void> _create() async {
    if (_skuController.text.trim().isEmpty) {
      setState(() => _error = 'SKU is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final priceUnits = int.tryParse(_priceUnitsController.text.trim()) ?? 0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final currency = _currencyController.text.trim();

      final request = CreateProductVariantRequest()
        ..productId = widget.productId
        ..sku = _skuController.text.trim()
        ..name = _nameController.text.trim()
        ..stockQuantity = Int64(stock);

      request.ensurePrice()
        ..currencyCode = currency.isNotEmpty ? currency : 'KES'
        ..units = Int64(priceUnits);

      await ref.read(variantNotifierProvider.notifier).create(request);

      if (mounted) {
        context.go('/catalog/${widget.productId}');
      }
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Variant')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _create();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.go('/catalog/${widget.productId}');
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep == 2)
                  GradientButton(
                    onPressed: _isLoading ? null : _create,
                    label: 'Create Variant',
                    icon: Icons.check,
                    isLoading: _isLoading,
                  )
                else
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continue'),
                  ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('SKU'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0
                ? StepState.complete
                : StepState.indexed,
            content: Column(
              children: [
                FormFieldCard(
                  label: 'SKU',
                  description: 'Auto-generated. Edit if needed.',
                  isRequired: true,
                  child: TextFormField(
                    controller: _skuController,
                    decoration: InputDecoration(
                      hintText: 'e.g. SKU-ABC12345',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: 'Regenerate',
                        onPressed: () => setState(
                            () => _skuController.text = _generateSku()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Name & Price'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1
                ? StepState.complete
                : StepState.indexed,
            content: Column(
              children: [
                FormFieldCard(
                  label: 'Variant Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Large, Red, 500ml...',
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Price (whole units)',
                  description:
                      'Enter the price in whole currency units (e.g. 100 for 100 KES).',
                  child: TextFormField(
                    controller: _priceUnitsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Currency Code',
                  child: TextFormField(
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      hintText: 'KES',
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Initial Stock',
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Confirm'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review your variant:',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 12),
                _ConfirmRow('SKU', _skuController.text.trim()),
                _ConfirmRow(
                    'Name',
                    _nameController.text.trim().isEmpty
                        ? '(none)'
                        : _nameController.text.trim()),
                _ConfirmRow(
                    'Price',
                    '${_priceUnitsController.text.trim().isEmpty ? '0' : _priceUnitsController.text.trim()}'
                    ' ${_currencyController.text.trim()}'),
                _ConfirmRow('Stock', _stockController.text.trim()),
                _ConfirmRow('Product', widget.productId),
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
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
