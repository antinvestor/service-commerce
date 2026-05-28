import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

import 'supplier_rating_badge.dart';

/// A card widget for displaying a [Supplier] in list views.
class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
  });

  final Supplier supplier;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business_outlined,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name.isNotEmpty ? supplier.name : supplier.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge.fromEnum(
                          value: supplier.status,
                          mapper: (s) => switch (s) {
                            SupplierStatus.SUPPLIER_STATUS_ACTIVE =>
                              ('Active', Colors.green, null),
                            SupplierStatus.SUPPLIER_STATUS_SUSPENDED =>
                              ('Suspended', Colors.orange, null),
                            SupplierStatus.SUPPLIER_STATUS_INACTIVE =>
                              ('Inactive', Colors.grey, null),
                            _ => ('Unknown', Colors.grey, null),
                          },
                        ),
                        const SizedBox(width: 8),
                        SupplierRatingBadge(rating: supplier.rating),
                      ],
                    ),
                  ],
                ),
              ),
              if (supplier.currency.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  supplier.currency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
