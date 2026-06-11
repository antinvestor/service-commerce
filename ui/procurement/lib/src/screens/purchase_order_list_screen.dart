import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
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
  PurchaseOrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders =
        ref.watch(purchaseOrderListProvider(widget.propertyId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.go('/procurement/orders/new'),
        icon: const Icon(Icons.add),
        label: const Text('New PO'),
      ),
      body: asyncOrders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load purchase orders',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        data: (orders) {
          final filtered = _selectedStatus != null
              ? orders
                  .where((o) => o.status == _selectedStatus)
                  .toList()
              : orders;
          return _buildContent(context, theme, filtered);
        },
      ),
    );
  }

  Future<void> _submitOrder(PurchaseOrder order) async {
    try {
      final notifier = ref.read(procurementNotifierProvider.notifier);
      await notifier.submitPO(PurchaseOrderSubmitRequest()..id = order.id);
      ref.invalidate(purchaseOrderListProvider(widget.propertyId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _cancelOrder(PurchaseOrder order) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Cancel Purchase Order',
      message: order.orderNumber.isNotEmpty
          ? 'Cancel PO #${order.orderNumber}? This cannot be undone.'
          : 'Cancel this purchase order? This cannot be undone.',
      confirmLabel: 'Cancel PO',
    );
    if (!confirmed || !mounted) return;
    try {
      final notifier = ref.read(procurementNotifierProvider.notifier);
      await notifier.cancelPO(PurchaseOrderCancelRequest()..id = order.id);
      ref.invalidate(purchaseOrderListProvider(widget.propertyId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${friendlyError(e)}')),
        );
      }
    }
  }

  Widget _buildContent(BuildContext context, ThemeData theme,
      List<PurchaseOrder> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Orders',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text('${orders.length} orders',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    context.go('/procurement/orders/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New PO'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) =>
                    setState(() => _selectedStatus = null),
              ),
              FilterChip(
                label: const Text('Draft'),
                selected: _selectedStatus ==
                    PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT,
                onSelected: (_) => setState(() => _selectedStatus =
                    PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT),
              ),
              FilterChip(
                label: const Text('Submitted'),
                selected: _selectedStatus ==
                    PurchaseOrderStatus
                        .PURCHASE_ORDER_STATUS_SUBMITTED,
                onSelected: (_) => setState(() => _selectedStatus =
                    PurchaseOrderStatus
                        .PURCHASE_ORDER_STATUS_SUBMITTED),
              ),
              FilterChip(
                label: const Text('Received'),
                selected: _selectedStatus ==
                    PurchaseOrderStatus
                        .PURCHASE_ORDER_STATUS_RECEIVED,
                onSelected: (_) => setState(() => _selectedStatus =
                    PurchaseOrderStatus
                        .PURCHASE_ORDER_STATUS_RECEIVED),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha(120)),
                  const SizedBox(height: 12),
                  Text('No purchase orders',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          else
            ...orders.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: PurchaseOrderCard(
                          order: o,
                          onTap: () => context
                              .go('/procurement/orders/${o.id}'),
                        ),
                      ),
                      _POActionsMenu(
                        order: o,
                        onSubmit: () => _submitOrder(o),
                        onCancel: () => _cancelOrder(o),
                      ),
                    ],
                  ),
                )),
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
    final canSubmit =
        order.status == PurchaseOrderStatus.PURCHASE_ORDER_STATUS_DRAFT;
    final canCancel = order.status !=
            PurchaseOrderStatus.PURCHASE_ORDER_STATUS_RECEIVED &&
        order.status != PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CANCELLED;

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
