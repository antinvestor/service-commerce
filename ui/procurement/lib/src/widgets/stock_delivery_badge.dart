import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Label, colour and what it means for staff, per [StockDeliveryStatus].
(String, Color, String) stockDeliveryStyle(StockDeliveryStatus status) =>
    switch (status) {
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING => (
        'Pending',
        Colors.orange,
        'On its way to the shop\'s stock; retried automatically.',
      ),
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_DELIVERED => (
        'In stock',
        Colors.green,
        'Added to stock.',
      ),
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING_TRANSFER => (
        'Needs location',
        Colors.blue,
        'Choose a stock location to book it into manufacturing inventory.',
      ),
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED => (
        'Failed',
        Colors.red,
        'The shop refused this stock; check the product variant.',
      ),
      StockDeliveryStatus.STOCK_DELIVERY_STATUS_RESOLVED => (
        'Booked by hand',
        Colors.teal,
        'Booked at its destination by hand.',
      ),
      _ => ('Unknown', Colors.grey, ''),
    };

/// Coloured pill for where a receipt line's stock is.
class StockDeliveryBadge extends StatelessWidget {
  const StockDeliveryBadge({super.key, required this.status});

  final StockDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) {
        final (label, color, _) = stockDeliveryStyle(s);
        return (label, color, null);
      },
    );
  }
}
