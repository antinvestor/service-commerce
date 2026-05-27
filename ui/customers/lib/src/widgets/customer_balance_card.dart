import 'package:flutter/material.dart';

import 'customer_credit_badge.dart';

/// A card showing a customer's balance summary: total owed, last payment date,
/// and payment terms.
class CustomerBalanceCard extends StatelessWidget {
  const CustomerBalanceCard({
    super.key,
    required this.totalOwed,
    this.currencyCode = '',
    this.lastPaymentDate,
    this.paymentTerms = '',
    this.creditStatus = CreditStatus.paidUp,
  });

  /// The total amount owed by this customer.
  final double totalOwed;

  /// ISO 4217 currency code (e.g. 'KES', 'USD').
  final String currencyCode;

  /// When the customer last made a payment, or null if never.
  final DateTime? lastPaymentDate;

  /// Payment terms description (e.g. 'Net 30', 'COD').
  final String paymentTerms;

  /// Current credit status.
  final CreditStatus creditStatus;

  String _formatAmount(double amount) {
    final prefix = currencyCode.isNotEmpty ? '$currencyCode ' : '';
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Balance Summary',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                CustomerCreditBadge(status: creditStatus),
              ],
            ),
            const SizedBox(height: 16),
            _BalanceRow(
              label: 'Total Owed',
              value: _formatAmount(totalOwed),
              valueStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: totalOwed > 0
                    ? Colors.red.shade700
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _BalanceRow(
              label: 'Last Payment',
              value: lastPaymentDate != null
                  ? _formatDate(lastPaymentDate!)
                  : 'No payments yet',
            ),
            if (paymentTerms.isNotEmpty) ...[
              const SizedBox(height: 8),
              _BalanceRow(label: 'Payment Terms', value: paymentTerms),
            ],
          ],
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
