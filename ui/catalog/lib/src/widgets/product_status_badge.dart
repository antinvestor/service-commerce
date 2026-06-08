import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [ProductStatus].
///
/// Green = ACTIVE, Grey = INACTIVE, Red = ARCHIVED.
class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        ProductStatus.PRODUCT_STATUS_ACTIVE => ('Active', Colors.green, null),
        ProductStatus.PRODUCT_STATUS_INACTIVE =>
          ('Inactive', Colors.grey, null),
        ProductStatus.PRODUCT_STATUS_ARCHIVED =>
          ('Archived', Colors.red, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
