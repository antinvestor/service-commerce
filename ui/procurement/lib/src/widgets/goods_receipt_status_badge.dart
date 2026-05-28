import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [GoodsReceiptStatus].
class GoodsReceiptStatusBadge extends StatelessWidget {
  const GoodsReceiptStatusBadge({super.key, required this.status});

  final GoodsReceiptStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        GoodsReceiptStatus.GOODS_RECEIPT_STATUS_PENDING_INSPECTION =>
          ('Pending', Colors.orange, null),
        GoodsReceiptStatus.GOODS_RECEIPT_STATUS_ACCEPTED =>
          ('Accepted', Colors.green, null),
        GoodsReceiptStatus.GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED =>
          ('Partial', Colors.blue, null),
        GoodsReceiptStatus.GOODS_RECEIPT_STATUS_REJECTED =>
          ('Rejected', Colors.red, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
