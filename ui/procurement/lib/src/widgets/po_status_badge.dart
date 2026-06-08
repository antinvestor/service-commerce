import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [PurchaseOrderStatus].
class POStatusBadge extends StatelessWidget {
  const POStatusBadge({super.key, required this.status});

  final PurchaseOrderStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT =>
          ('Draft', Colors.grey, null),
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED =>
          ('Submitted', Colors.blue, null),
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CONFIRMED =>
          ('Confirmed', Colors.indigo, null),
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED =>
          ('Partial', Colors.orange, null),
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_RECEIVED =>
          ('Received', Colors.green, null),
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CANCELLED =>
          ('Cancelled', Colors.red, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
