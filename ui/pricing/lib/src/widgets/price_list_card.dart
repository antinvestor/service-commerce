import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// A card widget for displaying a [PriceList] in list views.
///
/// Shows name, currency, priority, status, and valid date range.
class PriceListCard extends StatelessWidget {
  const PriceListCard({
    super.key,
    required this.priceList,
    this.onTap,
  });

  final PriceList priceList;
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
                  Icons.price_change_outlined,
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
                      priceList.name.isNotEmpty ? priceList.name : priceList.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _PriceListStatusBadge(status: priceList.status),
                        const SizedBox(width: 8),
                        Text(
                          '${priceList.currency} | P${priceList.priority}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (priceList.hasValidFrom() || priceList.hasValidUntil()) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (priceList.hasValidFrom())
                      Text(
                        _formatDate(priceList.validFrom.toDateTime()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (priceList.hasValidUntil())
                      Text(
                        _formatDate(priceList.validUntil.toDateTime()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
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

class _PriceListStatusBadge extends StatelessWidget {
  const _PriceListStatusBadge({required this.status});

  final PriceListStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: status,
      mapper: (s) => switch (s) {
        PriceListStatus.PRICE_LIST_STATUS_ACTIVE =>
          ('Active', Colors.green, null),
        PriceListStatus.PRICE_LIST_STATUS_DRAFT =>
          ('Draft', Colors.orange, null),
        PriceListStatus.PRICE_LIST_STATUS_EXPIRED =>
          ('Expired', Colors.grey, null),
        _ => ('Unknown', Colors.grey, null),
      },
    );
  }
}

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
