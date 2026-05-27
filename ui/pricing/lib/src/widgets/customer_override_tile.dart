import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// A tile showing a [CustomerPriceOverride].
class CustomerOverrideTile extends StatelessWidget {
  const CustomerOverrideTile({
    super.key,
    required this.override_,
    this.customerName = '',
    this.variantName = '',
  });

  final CustomerPriceOverride override_;
  final String customerName;
  final String variantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_outline,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName.isNotEmpty
                      ? customerName
                      : override_.customerId,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  variantName.isNotEmpty
                      ? variantName
                      : override_.productVariantId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge.fromEnum(
            value: override_.status,
            mapper: (s) => switch (s) {
              CustomerPriceOverrideStatus
                    .CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE =>
                ('Active', Colors.green, null),
              CustomerPriceOverrideStatus
                    .CUSTOMER_PRICE_OVERRIDE_STATUS_EXPIRED =>
                ('Expired', Colors.grey, null),
              _ => ('Unknown', Colors.grey, null),
            },
          ),
          const SizedBox(width: 8),
          AmountDisplay(amount: override_.unitPrice),
        ],
      ),
    );
  }
}
