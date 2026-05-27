import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// A card widget for displaying a [DiscountRule].
///
/// Shows name, discount type, value, conditions, and status.
class DiscountRuleCard extends StatelessWidget {
  const DiscountRuleCard({
    super.key,
    required this.rule,
    this.onTap,
  });

  final DiscountRule rule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = switch (rule.discountType) {
      DiscountType.DISCOUNT_TYPE_PERCENTAGE => 'Percentage',
      DiscountType.DISCOUNT_TYPE_FIXED_AMOUNT => 'Fixed Amount',
      _ => 'Unknown',
    };
    final valueLabel = rule.discountType ==
            DiscountType.DISCOUNT_TYPE_PERCENTAGE
        ? '${rule.value}%'
        : rule.value.toStringAsFixed(2);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.discount_outlined,
                  size: 22,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name.isNotEmpty ? rule.name : rule.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge.fromEnum(
                          value: rule.status,
                          mapper: (s) => switch (s) {
                            DiscountRuleStatus
                                  .DISCOUNT_RULE_STATUS_ACTIVE =>
                              ('Active', Colors.green, null),
                            DiscountRuleStatus
                                  .DISCOUNT_RULE_STATUS_INACTIVE =>
                              ('Inactive', Colors.grey, null),
                            _ => ('Unknown', Colors.grey, null),
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$typeLabel: $valueLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
