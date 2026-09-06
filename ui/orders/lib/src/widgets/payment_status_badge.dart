import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [PaymentStatus].
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        PaymentStatus.PAYMENT_STATUS_PENDING =>
          ('Pending', Colors.orange, null),
        PaymentStatus.PAYMENT_STATUS_PAID => ('Paid', Colors.green, null),
        PaymentStatus.PAYMENT_STATUS_FAILED =>
          ('Failed', Colors.red, null),
        PaymentStatus.PAYMENT_STATUS_REFUNDED =>
          ('Refunded', Colors.purple, null),
        PaymentStatus.PAYMENT_STATUS_EXPIRED =>
          ('Expired', Colors.grey, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
