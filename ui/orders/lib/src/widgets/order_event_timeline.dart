import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';

/// Label, icon and color for an [OrderEventType].
(String, IconData, Color) orderEventStyle(OrderEventType type) =>
    switch (type) {
      OrderEventType.ORDER_EVENT_TYPE_PAYMENT_RECEIVED => (
        'Payment received',
        Icons.payments_outlined,
        Colors.green,
      ),
      OrderEventType.ORDER_EVENT_TYPE_DEPOSIT_PAID => (
        'Deposit paid',
        Icons.savings_outlined,
        Colors.teal,
      ),
      OrderEventType.ORDER_EVENT_TYPE_THRESHOLD_CROSSED => (
        'Threshold reached',
        Icons.flag_outlined,
        Colors.blue,
      ),
      OrderEventType.ORDER_EVENT_TYPE_FULFILMENT_RELEASED => (
        'Fulfilment released',
        Icons.local_shipping_outlined,
        Colors.indigo,
      ),
      OrderEventType.ORDER_EVENT_TYPE_FULLY_PAID => (
        'Fully paid',
        Icons.check_circle_outline,
        Colors.green,
      ),
      OrderEventType.ORDER_EVENT_TYPE_BALANCE_OVERDUE => (
        'Balance overdue',
        Icons.schedule,
        Colors.orange,
      ),
      OrderEventType.ORDER_EVENT_TYPE_OVERPAID => (
        'Overpaid',
        Icons.warning_amber_outlined,
        Colors.deepOrange,
      ),
      OrderEventType.ORDER_EVENT_TYPE_CANCELLED => (
        'Cancelled',
        Icons.cancel_outlined,
        Colors.red,
      ),
      OrderEventType.ORDER_EVENT_TYPE_EXPIRED => (
        'Expired',
        Icons.timer_off_outlined,
        Colors.grey,
      ),
      _ => ('Event', Icons.circle_outlined, Colors.grey),
    };

/// Colored pill for an event's webhook [OrderEventDelivery] state.
class OrderEventDeliveryBadge extends StatelessWidget {
  const OrderEventDeliveryBadge({super.key, required this.delivery});

  final OrderEventDelivery delivery;

  @override
  Widget build(BuildContext context) {
    return StatusBadge.fromEnum(
      value: delivery,
      mapper: (d) => switch (d) {
        OrderEventDelivery.ORDER_EVENT_DELIVERY_NOT_REQUIRED => (
          'No webhook',
          Colors.grey,
          null,
        ),
        OrderEventDelivery.ORDER_EVENT_DELIVERY_PENDING => (
          'Webhook pending',
          Colors.orange,
          Icons.schedule,
        ),
        OrderEventDelivery.ORDER_EVENT_DELIVERY_DELIVERED => (
          'Webhook delivered',
          Colors.green,
          Icons.check,
        ),
        OrderEventDelivery.ORDER_EVENT_DELIVERY_FAILED => (
          'Webhook failed',
          Colors.red,
          Icons.error_outline,
        ),
        _ => ('Webhook unknown', Colors.grey, null),
      },
    );
  }
}

/// Renders order events in the order given (the API returns oldest first,
/// so the newest is last).
///
/// With [showOrder] each entry names its order and tapping it calls
/// [onOrderTap]; used by the shop-wide feed.
class OrderEventTimeline extends StatelessWidget {
  const OrderEventTimeline({
    super.key,
    required this.events,
    this.showOrder = false,
    this.onOrderTap,
  });

  final List<OrderEvent> events;
  final bool showOrder;
  final ValueChanged<OrderEvent>? onOrderTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (events.isEmpty) {
      return Text(
        'No events yet',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < events.length; i++)
          _OrderEventEntry(
            event: events[i],
            isLast: i == events.length - 1,
            showOrder: showOrder,
            onTap: onOrderTap == null ? null : () => onOrderTap!(events[i]),
          ),
      ],
    );
  }
}

class _OrderEventEntry extends StatelessWidget {
  const _OrderEventEntry({
    required this.event,
    required this.isLast,
    required this.showOrder,
    this.onTap,
  });

  final OrderEvent event;
  final bool isLast;
  final bool showOrder;
  final VoidCallback? onTap;

  String _money(Money m) => formatMinor(moneyToMinor(m), m.currencyCode);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = orderEventStyle(event.type);
    final facts = <String>[
      if (event.type == OrderEventType.ORDER_EVENT_TYPE_THRESHOLD_CROSSED &&
          event.thresholdPercent > 0)
        'Threshold ${event.thresholdPercent}%',
      '${event.paidPercent}% paid',
      if (event.hasPaymentAmount()) 'Instalment ${_money(event.paymentAmount)}',
      if (event.hasAmountPaid()) 'Paid ${_money(event.amountPaid)}',
      if (event.hasBalance()) 'Balance ${_money(event.balance)}',
    ];
    final orderLabel = event.orderNumber.isNotEmpty
        ? 'Order #${event.orderNumber}'
        : event.orderId;

    final content = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withAlpha(30),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showOrder)
                        Text(
                          orderLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      OrderEventDeliveryBadge(delivery: event.delivery),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(facts.join(' · '), style: theme.textTheme.bodySmall),
                  if (event.hasCreatedAt())
                    Text(
                      formatDateTime(event.createdAt.toDateTime()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// The event timeline for one order, loaded with ListOrderEvents.
class OrderEventsSection extends ConsumerWidget {
  const OrderEventsSection({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncEvents = ref.watch(orderEventsProvider(orderId));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Events',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh events',
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => ref.invalidate(orderEventsProvider(orderId)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          asyncEvents.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'Could not load events: ${friendlyError(e)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            data: (events) => OrderEventTimeline(events: events),
          ),
        ],
      ),
    );
  }
}
