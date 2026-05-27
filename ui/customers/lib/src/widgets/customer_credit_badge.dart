import 'package:flutter/material.dart';

/// Credit status for a customer.
enum CreditStatus {
  /// Fully paid up, no outstanding balance.
  paidUp,

  /// Has an outstanding balance that is not yet overdue.
  hasBalance,

  /// Has an overdue balance.
  overdue,
}

/// A badge indicating a customer's credit status.
///
/// Green = paid up, Yellow = has balance, Red = overdue.
class CustomerCreditBadge extends StatelessWidget {
  const CustomerCreditBadge({
    super.key,
    required this.status,
  });

  final CreditStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      CreditStatus.paidUp => (
          Colors.green.shade50,
          Colors.green.shade700,
          'Paid Up',
        ),
      CreditStatus.hasBalance => (
          Colors.orange.shade50,
          Colors.orange.shade700,
          'Balance Due',
        ),
      CreditStatus.overdue => (
          Colors.red.shade50,
          Colors.red.shade700,
          'Overdue',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
