import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../widgets/po_actions.dart';
import '../widgets/purchase_order_card.dart';

/// Screen listing purchase orders for a property.
class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  static const _statusFilters = <String, PurchaseOrderStatus>{
    'Draft': PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT,
    'Submitted': PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED,
    'Confirmed': PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CONFIRMED,
    'Partially received':
        PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED,
    'Received': PurchaseOrderStatus.PURCHASE_ORDER_STATUS_RECEIVED,
    'Cancelled': PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CANCELLED,
  };

  PurchaseOrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(purchaseOrderListProvider(widget.propertyId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(ProcurementPaths.newOrder),
        icon: const Icon(Icons.add),
        label: const Text('New PO'),
      ),
      body: asyncOrders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load purchase orders',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                friendlyError(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        data: (orders) {
          final filtered = _selectedStatus != null
              ? orders.where((o) => o.status == _selectedStatus).toList()
              : orders;
          return _buildContent(context, theme, filtered);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    List<PurchaseOrder> orders,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Procurement',
                onPressed: () => context.go(ProcurementPaths.root),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.assignment_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase Orders',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${orders.length} orders',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go(ProcurementPaths.newOrder),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New PO'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) => setState(() => _selectedStatus = null),
              ),
              for (final entry in _statusFilters.entries)
                FilterChip(
                  label: Text(entry.key),
                  selected: _selectedStatus == entry.value,
                  onSelected: (_) =>
                      setState(() => _selectedStatus = entry.value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                  ),
                  const SizedBox(height: 12),
                  Text('No purchase orders', style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          else
            ...orders.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: PurchaseOrderCard(
                        order: o,
                        onTap: () => context.go(ProcurementPaths.order(o.id)),
                      ),
                    ),
                    _POActionsMenu(
                      order: o,
                      onSubmit: () => submitPurchaseOrder(context, ref, o),
                      onCancel: () => cancelPurchaseOrder(context, ref, o),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Overflow menu exposing the submit/cancel actions for a [PurchaseOrder].
///
/// Submit is offered only for draft orders; cancel is hidden once the order
/// has reached a terminal state (received or already cancelled).
class _POActionsMenu extends StatelessWidget {
  const _POActionsMenu({
    required this.order,
    required this.onSubmit,
    required this.onCancel,
  });

  final PurchaseOrder order;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final canSubmit = canSubmitPO(order);
    final canCancel = canCancelPO(order);

    if (!canSubmit && !canCancel) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Order actions',
      onSelected: (value) {
        switch (value) {
          case 'submit':
            onSubmit();
          case 'cancel':
            onCancel();
        }
      },
      itemBuilder: (context) => [
        if (canSubmit)
          const PopupMenuItem(
            value: 'submit',
            child: ListTile(
              leading: Icon(Icons.send_outlined),
              title: Text('Submit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (canCancel)
          const PopupMenuItem(
            value: 'cancel',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined),
              title: Text('Cancel'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
