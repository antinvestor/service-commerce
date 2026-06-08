import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../widgets/supplier_rating_badge.dart';

/// Detail screen for a single supplier.
class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncSupplier = ref.watch(supplierByIdProvider(supplierId));

    return Scaffold(
      body: asyncSupplier.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load supplier',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        data: (supplier) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        context.go('/procurement/suppliers'),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.business_outlined,
                      size: 28, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name.isNotEmpty
                              ? supplier.name
                              : 'Supplier',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(supplier.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 8,
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
                  SupplierRatingBadge(rating: supplier.rating),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(label: 'Currency', value: supplier.currency),
              _DetailRow(
                  label: 'Payment Terms',
                  value: '${supplier.paymentTermsDays} days'),
              _DetailRow(
                  label: 'Lead Time',
                  value: '${supplier.leadTimeDays} days'),
              if (supplier.notes.isNotEmpty)
                _DetailRow(label: 'Notes', value: supplier.notes),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
