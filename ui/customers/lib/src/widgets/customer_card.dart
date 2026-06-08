import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';

import 'customer_credit_badge.dart';

/// A card widget for displaying a customer in list views.
///
/// Wraps [ProfileCard] from ui_profile, adding a trailing balance amount
/// and a [CustomerCreditBadge].
class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.profile,
    this.onTap,
    this.balanceAmount,
    this.currencyCode = '',
    this.creditStatus = CreditStatus.paidUp,
  });

  final ProfileObject profile;
  final VoidCallback? onTap;

  /// Outstanding balance amount. Null means unknown / not loaded.
  final double? balanceAmount;

  /// ISO 4217 currency code (e.g. 'KES', 'USD').
  final String currencyCode;

  /// Credit status to display as a badge.
  final CreditStatus creditStatus;

  String _formatBalance() {
    if (balanceAmount == null) return '';
    final prefix = currencyCode.isNotEmpty ? '$currencyCode ' : '';
    return '$prefix${balanceAmount!.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profileName(profile);

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
              // Reuse ProfileCard's avatar and name layout inline.
              ProfileAvatar(
                profileId: profile.id,
                name: name,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ProfileTypeBadge(type: profile.type),
                        const SizedBox(width: 8),
                        CustomerCreditBadge(status: creditStatus),
                      ],
                    ),
                  ],
                ),
              ),
              if (balanceAmount != null) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatBalance(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: creditStatus == CreditStatus.overdue
                            ? Colors.red.shade700
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'balance',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 4),
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
