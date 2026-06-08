import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Shows a resolved price with its source badge.
class PriceResolverPreview extends StatelessWidget {
  const PriceResolverPreview({
    super.key,
    required this.resolved,
  });

  final ResolvedPrice resolved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.price_check,
                    size: 24, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Resolved Price',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                _PriceSourceBadge(source: resolved.priceSource),
              ],
            ),
            const SizedBox(height: 16),
            _Row(label: 'Unit Price', child: AmountDisplay(amount: resolved.unitPrice)),
            if (resolved.hasPreDiscountPrice())
              _Row(
                  label: 'Pre-discount',
                  child: AmountDisplay(amount: resolved.preDiscountPrice)),
            if (resolved.hasDiscountAmount())
              _Row(
                  label: 'Discount',
                  child: AmountDisplay(amount: resolved.discountAmount)),
            if (resolved.priceListId.isNotEmpty)
              _Row(label: 'Price List', value: resolved.priceListId),
            if (resolved.overrideId.isNotEmpty)
              _Row(label: 'Override', value: resolved.overrideId),
            if (resolved.discountRuleId.isNotEmpty)
              _Row(label: 'Discount Rule', value: resolved.discountRuleId),
          ],
        ),
      ),
    );
  }
}

class _PriceSourceBadge extends StatelessWidget {
  const _PriceSourceBadge({required this.source});

  final PriceSource source;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: source,
      mapper: (s) => switch (s) {
        PriceSource.PRICE_SOURCE_CATALOG =>
          ('Catalog', Colors.blue, null),
        PriceSource.PRICE_SOURCE_PRICE_LIST =>
          ('Price List', Colors.teal, null),
        PriceSource.PRICE_SOURCE_CUSTOMER_OVERRIDE =>
          ('Override', Colors.purple, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, this.value, this.child});

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
            width: 110,
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
