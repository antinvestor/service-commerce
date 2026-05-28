import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Colored pill badge for [SupplierRating].
class SupplierRatingBadge extends StatelessWidget {
  const SupplierRatingBadge({super.key, required this.rating});

  final SupplierRating rating;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: rating,
      mapper: (r) => switch (r) {
        SupplierRating.SUPPLIER_RATING_PREFERRED =>
          ('Preferred', Colors.green, null),
        SupplierRating.SUPPLIER_RATING_APPROVED =>
          ('Approved', Colors.blue, null),
        SupplierRating.SUPPLIER_RATING_PROBATION =>
          ('Probation', Colors.orange, null),
        SupplierRating.SUPPLIER_RATING_UNRATED =>
          ('Unrated', Colors.grey, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}
