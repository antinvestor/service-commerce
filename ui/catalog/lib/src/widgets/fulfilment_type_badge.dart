import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';

/// Icon + label badge for [FulfilmentType].
class FulfilmentTypeBadge extends StatelessWidget {
  const FulfilmentTypeBadge({super.key, required this.type});

  final FulfilmentType type;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (type) {
      FulfilmentType.FULFILMENT_TYPE_PHYSICAL => (
        'Physical',
        Icons.local_shipping_outlined,
        Colors.blue,
      ),
      FulfilmentType.FULFILMENT_TYPE_DIGITAL => (
        'Digital',
        Icons.cloud_download_outlined,
        Colors.purple,
      ),
      FulfilmentType.FULFILMENT_TYPE_NONE => (
        'None',
        Icons.block_outlined,
        Colors.grey,
      ),
      _ => (
        'Unknown',
        Icons.help_outline,
        Colors.grey,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
