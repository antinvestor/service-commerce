import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [FulfilmentStatus].
class FulfilmentStatusBadge extends StatelessWidget {
  const FulfilmentStatusBadge({super.key, required this.status});

  final FulfilmentStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        FulfilmentStatus.FULFILMENT_STATUS_PENDING =>
          ('Pending', Colors.orange, null),
        FulfilmentStatus.FULFILMENT_STATUS_PREPARING =>
          ('Preparing', Colors.blue, null),
        FulfilmentStatus.FULFILMENT_STATUS_PACKED =>
          ('Packed', Colors.indigo, null),
        FulfilmentStatus.FULFILMENT_STATUS_SHIPPED =>
          ('Shipped', Colors.teal, null),
        FulfilmentStatus.FULFILMENT_STATUS_DELIVERED =>
          ('Delivered', Colors.green, null),
        FulfilmentStatus.FULFILMENT_STATUS_CANCELLED =>
          ('Cancelled', Colors.red, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
