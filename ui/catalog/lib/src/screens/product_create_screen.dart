import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

/// Screen for creating a new product using a 3-step Stepper:
/// 1. Name/Description
/// 2. Attributes
/// 3. Confirm
class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attrKeyController = TextEditingController();
  final _attrValueController = TextEditingController();
  final Map<String, String> _attributes = {};
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _attrKeyController.dispose();
    _attrValueController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    final key = _attrKeyController.text.trim();
    final value = _attrValueController.text.trim();
    if (key.isNotEmpty && value.isNotEmpty) {
      setState(() {
        _attributes[key] = value;
        _attrKeyController.clear();
        _attrValueController.clear();
      });
    }
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = CreateProductRequest()
        ..shopId = widget.shopId
        ..name = _nameController.text.trim()
        ..description = _descriptionController.text.trim();

      if (_attributes.isNotEmpty) {
        request.attributes.addAll(_attributes);
      }

      final created =
          await ref.read(productNotifierProvider.notifier).create(request);

      if (mounted) {
        context.go('/catalog/${created.id}');
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
      appBar: AppBar(title: const Text('New Product')),
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
            context.go('/catalog');
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
                    label: 'Create Product',
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
            title: const Text('Name & Description'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0
                ? StepState.complete
                : StepState.indexed,
            content: Column(
              children: [
                FormFieldCard(
                  label: 'Product Name',
                  isRequired: true,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter product name...',
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Description',
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Optional description...',
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Attributes'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1
                ? StepState.complete
                : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _attrKeyController,
                        decoration: const InputDecoration(
                          hintText: 'Key (e.g. color)',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _attrValueController,
                        decoration: const InputDecoration(
                          hintText: 'Value (e.g. red)',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _addAttribute,
                      tooltip: 'Add attribute',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_attributes.isEmpty)
                  Text('No attributes added yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attributes.entries
                        .map((e) => Chip(
                              label: Text('${e.key}: ${e.value}'),
                              onDeleted: () => setState(
                                  () => _attributes.remove(e.key)),
                            ))
                        .toList(),
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
                Text('Review your product:',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 12),
                _ConfirmRow('Name', _nameController.text.trim().isEmpty
                    ? '(not set)'
                    : _nameController.text.trim()),
                _ConfirmRow(
                    'Description',
                    _descriptionController.text.trim().isEmpty
                        ? '(none)'
                        : _descriptionController.text.trim()),
                _ConfirmRow('Attributes',
                    _attributes.isEmpty
                        ? '(none)'
                        : _attributes.entries
                            .map((e) => '${e.key}=${e.value}')
                            .join(', ')),
                _ConfirmRow('Shop', widget.shopId),
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
