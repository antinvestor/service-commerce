import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../widgets/fulfilment_status_badge.dart';
import '../widgets/order_line_tile.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/payment_status_badge.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Detail screen for a single order, showing all lines and fulfilment actions.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncOrder = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      body: asyncOrder.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load order',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(orderByIdProvider(orderId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/orders'),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.receipt_long_outlined,
                      size: 28, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber.isNotEmpty
                              ? 'Order #${order.orderNumber}'
                              : 'Order',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(order.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        context.go('/orders/$orderId/fulfilment'),
                    icon: const Icon(Icons.local_shipping_outlined,
                        size: 18),
                    label: const Text('Fulfilment'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status row
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OrderStatusBadge(status: order.status),
                  PaymentStatusBadge(status: order.paymentStatus),
                  FulfilmentStatusBadge(status: order.fulfilmentStatus),
                ],
              ),
              const SizedBox(height: 20),

              // Details
              _DetailRow(label: 'Customer', value: order.profileId),
              if (order.hasCreatedAt())
                _DetailRow(
                  label: 'Created',
                  value: _formatDate(order.createdAt.toDateTime()),
                ),
              _DetailRow(
                label: 'Subtotal',
                child: AmountDisplay(amount: order.subtotal),
              ),
              _DetailRow(
                label: 'Total',
                child: AmountDisplay(amount: order.total),
              ),
              const SizedBox(height: 20),

              // Order lines
              Text('Order Lines',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: order.lines.isEmpty
                    ? Text('No lines',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant))
                    : Column(
                        children: order.lines
                            .map((line) => OrderLineTile(line: line))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

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
            child: child ??
                Text(value ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
