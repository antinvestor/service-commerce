import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [ProductVariantStatus].
///
/// Green = ACTIVE, Grey = DISABLED.
class VariantStatusBadge extends StatelessWidget {
  const VariantStatusBadge({super.key, required this.status});

  final ProductVariantStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE =>
          ('Active', Colors.green, null),
        ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED =>
          ('Disabled', Colors.grey, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
