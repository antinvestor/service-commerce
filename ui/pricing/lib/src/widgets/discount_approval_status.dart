import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

import '../utils/pricing_validators.dart';

/// Approval state of a [DiscountRule].
enum DiscountApprovalState {
  /// The rule applies without approval.
  notRequired,

  /// The rule requires approval and has none; it is never applied.
  pending,

  /// The rule requires approval and has been approved.
  approved;

  static DiscountApprovalState of(DiscountRule rule) {
    if (!rule.requiresApproval) return notRequired;
    return rule.approvedBy.isNotEmpty || rule.hasApprovedAt()
        ? approved
        : pending;
  }
}

/// Shows whether a rule is waiting for approval (with an Approve action when
/// [onApprove] is given) or who approved it and when. Renders nothing for
/// rules that do not require approval.
class DiscountApprovalStatus extends StatelessWidget {
  const DiscountApprovalStatus({
    super.key,
    required this.rule,
    this.onApprove,
    this.approving = false,
  });

  final DiscountRule rule;

  /// Called when the Approve button is pressed; the button is hidden when null.
  final VoidCallback? onApprove;
  final bool approving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (DiscountApprovalState.of(rule)) {
      case DiscountApprovalState.notRequired:
        return const SizedBox.shrink();
      case DiscountApprovalState.pending:
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const StatusBadge(
              label: 'Pending approval',
              color: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
            if (onApprove != null)
              FilledButton.tonalIcon(
                onPressed: approving ? null : onApprove,
                icon: approving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Approve'),
              ),
          ],
        );
      case DiscountApprovalState.approved:
        final at = rule.hasApprovedAt()
            ? formatDateTime(rule.approvedAt.toDateTime())
            : null;
        final by = rule.approvedBy.isNotEmpty ? rule.approvedBy : null;
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const StatusBadge(
              label: 'Approved',
              color: Colors.green,
              icon: Icons.verified_outlined,
            ),
            Text(
              [if (by != null) 'by $by', if (at != null) 'on $at'].join(' '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
    }
  }
}
