import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/pricing_providers.dart';

const _statusOptions = ['Active', 'Inactive'];

/// Screen for assigning customers to a price list and listing assignments.
class PriceListAssignmentsScreen extends ConsumerWidget {
  const PriceListAssignmentsScreen({super.key, required this.priceListId});

  final String priceListId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final params = (priceListId: priceListId, customerId: null);
    final asyncAssignments =
        ref.watch(priceListAssignmentListProvider(params));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _assign(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Assign Customer'),
      ),
      body: asyncAssignments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load assignments',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(priceListAssignmentListProvider(params)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (assignments) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/pricing/$priceListId'),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.people_outline,
                      size: 28, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Assignments',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${assignments.length} assignments',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (assignments.isEmpty)
                Text('No customers assigned yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant))
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: assignments
                        .map((a) => _AssignmentTile(
                              assignment: a,
                              onEdit: () =>
                                  _assign(context, ref, existing: a),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref, {
    CustomerPriceListAssignment? existing,
  }) async {
    final isEdit = existing != null;
    final values = await showEditDialog(
      context: context,
      title: isEdit ? 'Edit Assignment' : 'Assign Customer',
      saveLabel: isEdit ? 'Save' : 'Assign',
      fields: [
        DialogField(
          key: 'customer',
          label: 'Customer ID',
          required: true,
          initialValue: existing?.customerId ?? '',
        ),
        DialogField(
          key: 'status',
          label: 'Status',
          type: DialogFieldType.dropdown,
          options: _statusOptions,
          initialValue: isEdit
              ? (existing.status ==
                      CustomerPriceListAssignmentStatus
                          .CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE
                  ? 'Inactive'
                  : 'Active')
              : 'Active',
        ),
      ],
    );
    if (values == null || !context.mounted) return;

    final customerId = (values['customer'] ?? '').trim();
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ID is required')),
      );
      return;
    }

    final request = CustomerPriceListAssignmentSaveRequest()
      ..priceListId = priceListId
      ..customerId = customerId
      ..status = (values['status'] ?? 'Active') == 'Inactive'
          ? CustomerPriceListAssignmentStatus
              .CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE
          : CustomerPriceListAssignmentStatus
              .CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE;
    if (isEdit) request.id = existing.id;

    try {
      await ref.read(pricingNotifierProvider.notifier).saveAssignment(request);
      ref.invalidate(priceListAssignmentListProvider(
          (priceListId: priceListId, customerId: null)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Assignment updated' : 'Customer assigned'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.assignment, this.onEdit});

  final CustomerPriceListAssignment assignment;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_outline,
                size: 18, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              assignment.customerId,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StatusBadge.fromEnum(
            value: assignment.status,
            mapper: (s) => switch (s) {
              CustomerPriceListAssignmentStatus
                    .CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_ACTIVE =>
                ('Active', Colors.green, null),
              CustomerPriceListAssignmentStatus
                    .CUSTOMER_PRICE_LIST_ASSIGNMENT_STATUS_INACTIVE =>
                ('Inactive', Colors.grey, null),
              _ => ('Unknown', Colors.grey, null),
            },
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
