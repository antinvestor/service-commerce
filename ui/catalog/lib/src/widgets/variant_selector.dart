import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:flutter/material.dart';

import 'variant_status_badge.dart';

/// Horizontal chip list of [ProductVariant]s with bottom sheet detail on tap.
class VariantSelector extends StatelessWidget {
  const VariantSelector({
    super.key,
    required this.variants,
    this.selectedId,
    this.onSelected,
  });

  final List<ProductVariant> variants;
  final String? selectedId;
  final ValueChanged<ProductVariant>? onSelected;

  void _showDetail(BuildContext context, ProductVariant variant) {
    final theme = Theme.of(context);
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
            Text(
              variant.name.isNotEmpty ? variant.name : variant.sku,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (variant.sku.isNotEmpty)
              _DetailRow(label: 'SKU', value: variant.sku),
            _DetailRow(
              label: 'Price',
              child: AmountDisplay(amount: variant.price),
            ),
            _DetailRow(
              label: 'Stock',
              value: '${variant.stockQuantity.toInt()}',
            ),
            _DetailRow(
              label: 'Status',
              child: VariantStatusBadge(status: variant.status),
            ),
            if (variant.attributes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Attributes',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              for (final entry in variant.attributes.entries)
                _DetailRow(label: entry.key, value: entry.value),
            ],
            const SizedBox(height: 16),
            if (onSelected != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    onSelected!(variant);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Select Variant'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (variants.isEmpty) {
      return Text('No variants available',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final variant = variants[index];
          final isSelected = variant.id == selectedId;
          return ChoiceChip(
            label: Text(
              variant.name.isNotEmpty ? variant.name : variant.sku,
            ),
            selected: isSelected,
            onSelected: (_) => _showDetail(context, variant),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: child ??
                Text(value ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
