import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/customer_providers.dart';

/// Detail screen for a single customer.
///
/// Shows a profile header with tabs: Orders (the customer's history in the
/// shop, newest first; open an order to record a payment) | Locations.
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.shopId,
  });

  final String customerId;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCustomer = ref.watch(customerByIdProvider(customerId));

    return asyncCustomer.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load customer', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              friendlyError(error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(customerByIdProvider(customerId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (profile) => _CustomerDetailContent(
        profile: profile,
        customerId: customerId,
        shopId: shopId,
      ),
    );
  }
}

class _CustomerDetailContent extends ConsumerStatefulWidget {
  const _CustomerDetailContent({
    required this.profile,
    required this.customerId,
    required this.shopId,
  });

  final ProfileObject profile;
  final String customerId;
  final String shopId;

  @override
  ConsumerState<_CustomerDetailContent> createState() =>
      _CustomerDetailContentState();
}

class _CustomerDetailContentState extends ConsumerState<_CustomerDetailContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.profile;
    final name = profileName(profile);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Customers',
                  onPressed: () => context.go('/customers'),
                ),
                const SizedBox(width: 8),
                ProfileAvatar(profileId: profile.id, name: name, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ProfileTypeBadge(type: profile.type),
                          SelectableText(
                            'ID: ${profile.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Orders'),
              Tab(text: 'Locations'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrdersTab(
                  customerId: widget.customerId,
                  shopId: widget.shopId,
                ),
                _LocationsTab(profile: profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Orders Tab --

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({required this.customerId, required this.shopId});
  final String customerId;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = (shopId: shopId, customerId: customerId);
    final asyncOrders = ref.watch(customerOrdersProvider(query));

    return asyncOrders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load orders', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              friendlyError(error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(customerOrdersProvider(query)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (history) {
        final orders = history.orders;
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Open an order to record a payment against it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final order in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomerOrderTile(
                  order: order,
                  onTap: () => context.go('/orders/${order.id}'),
                ),
              ),
            if (history.loadMoreError != null)
              Text(
                friendlyError(history.loadMoreError!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (history.hasMore)
              Center(
                child: OutlinedButton(
                  key: const ValueKey('customer-orders-load-more'),
                  onPressed: history.loadingMore
                      ? null
                      : () => ref
                            .read(customerOrdersProvider(query).notifier)
                            .loadMore(),
                  child: Text(history.loadingMore ? 'Loading…' : 'Load more'),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One of a customer's orders: number, where it stands, and what is still
/// owed.
class CustomerOrderTile extends StatelessWidget {
  const CustomerOrderTile({super.key, required this.order, this.onTap});

  final Order order;
  final VoidCallback? onTap;

  static String statusLabel(Order order) {
    switch (order.paymentStatus) {
      case PaymentStatus.PAYMENT_STATUS_REFUND_PENDING:
        return 'Cancelled, refund pending';
      case PaymentStatus.PAYMENT_STATUS_REFUNDED:
        return 'Refunded';
      default:
    }
    switch (order.status) {
      case OrderStatus.ORDER_STATUS_PENDING_PAYMENT:
        return order.paymentStatus ==
                PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID
            ? 'Part paid'
            : 'Awaiting payment';
      case OrderStatus.ORDER_STATUS_CONFIRMED:
        return 'Confirmed';
      case OrderStatus.ORDER_STATUS_CANCELLED:
        return 'Cancelled';
      case OrderStatus.ORDER_STATUS_FULFILLED:
        return 'Fulfilled';
      default:
        return 'Pending';
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owes =
        order.status != OrderStatus.ORDER_STATUS_CANCELLED &&
        order.hasBalance() &&
        (order.balance.units > 0 || order.balance.nanos > 0);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.orderNumber.isNotEmpty
                                ? '#${order.orderNumber}'
                                : order.id,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AmountDisplay(amount: order.total),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        statusLabel(order),
                        if (order.hasCreatedAt())
                          _formatDate(order.createdAt.toDateTime()),
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (owes)
                      Row(
                        children: [
                          Text(
                            'Owes ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          AmountDisplay(amount: order.balance),
                        ],
                      ),
                  ],
                ),
              ),
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

// -- Locations Tab --

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({required this.profile});
  final ProfileObject profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addresses = profile.addresses;

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses on file',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: addresses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return AddressTile(address: address);
      },
    );
  }
}
