import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

import '../utils/discount_conditions.dart';
import '../utils/pricing_validators.dart';
import 'discount_approval_status.dart';

/// A card widget for displaying a [DiscountRule].
///
/// Shows name, discount type, value, conditions, validity, status and the
/// approval state. Pass [onApprove] to offer approval of a pending rule.
class DiscountRuleCard extends StatelessWidget {
  const DiscountRuleCard({
    super.key,
    required this.rule,
    this.onTap,
    this.onApprove,
    this.approving = false,
  });

  final DiscountRule rule;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final bool approving;

  String? _conditionsSummary() {
    final c = DiscountConditions.fromStruct(
      rule.hasConditions() ? rule.conditions : null,
    );
    final min = c.minQuantity;
    final parts = [
      if (c.variantIds.isNotEmpty) '${c.variantIds.length} variant(s)',
      if (c.productIds.isNotEmpty) '${c.productIds.length} product(s)',
      if (min != null && min > 0)
        'min qty ${min == min.roundToDouble() ? min.toInt() : min}',
      if (c.unsupportedKeys.isNotEmpty)
        'unsupported: ${c.unsupportedKeys.join(', ')}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String? _validitySummary() {
    final from = timestampToDate(rule.hasValidFrom(), rule.validFrom);
    final until = timestampToDate(rule.hasValidUntil(), rule.validUntil);
    if (from == null && until == null) return null;
    return '${from != null ? formatDate(from) : 'now'} → '
        '${until != null ? formatDate(until) : 'open-ended'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = switch (rule.discountType) {
      DiscountType.DISCOUNT_TYPE_PERCENTAGE => 'Percentage',
      DiscountType.DISCOUNT_TYPE_FIXED_AMOUNT => 'Fixed Amount',
      _ => 'Unknown',
    };
    final valueLabel =
        rule.discountType == DiscountType.DISCOUNT_TYPE_PERCENTAGE
        ? '${rule.value}%'
        : rule.value.toStringAsFixed(2);
    final details = [?_conditionsSummary(), ?_validitySummary()];

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
                            DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE => (
                              'Active',
                              Colors.green,
                              null,
                            ),
                            DiscountRuleStatus.DISCOUNT_RULE_STATUS_INACTIVE =>
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
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details.join('  |  '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (rule.requiresApproval) ...[
                      const SizedBox(height: 6),
                      DiscountApprovalStatus(
                        rule: rule,
                        onApprove: onApprove,
                        approving: approving,
                      ),
                    ],
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
