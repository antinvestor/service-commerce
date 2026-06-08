import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [OrderStatus].
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        OrderStatus.ORDER_STATUS_CONFIRMED =>
          ('Confirmed', Colors.blue, null),
        OrderStatus.ORDER_STATUS_FULFILLED =>
          ('Fulfilled', Colors.green, null),
        OrderStatus.ORDER_STATUS_CANCELLED =>
          ('Cancelled', Colors.red, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
