import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/payment_status_badge.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Admin-grade order list screen with DataTable, server-side search, status
/// filter, and cursor paging ("Load more").
class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  OrderStatus? _selectedStatus;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _runSearch(String query) => ref
      .read(orderListControllerProvider(widget.shopId).notifier)
      .search(query);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(orderListControllerProvider(widget.shopId));

    return Scaffold(
      floatingActionButton: PermissionGuard(
        permissions: const {'order_manage'},
        child: FloatingActionButton.extended(
          onPressed: () => context.go('/orders/checkout'),
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
        ),
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
                onPressed: () =>
                    ref.invalidate(orderListControllerProvider(widget.shopId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (state) {
          final filtered = _selectedStatus != null
              ? state.orders.where((o) => o.status == _selectedStatus).toList()
              : state.orders;
          return _buildContent(context, theme, filtered, state);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    List<Order> orders,
    OrderListState state,
  ) {
    final pageItems = orders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (orders.isNotEmpty)
                      Text(
                        '${orders.length} orders'
                        '${state.hasMore ? ' loaded' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/orders/events'),
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Events'),
              ),
              PermissionGuard(
                permissions: const {'order_manage'},
                child: FilledButton.icon(
                  onPressed: () => context.go('/orders/checkout'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Order'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Server-side search
          TextField(
            key: const ValueKey('order-search'),
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search orders by number or customer',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty && state.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        _runSearch('');
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: _runSearch,
          ),
          if (state.searching)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 12),

          // Status filter chips
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) => setState(() => _selectedStatus = null),
              ),
              FilterChip(
                label: const Text('Awaiting payment'),
                selected:
                    _selectedStatus == OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
                onSelected: (_) => setState(
                  () => _selectedStatus =
                      OrderStatus.ORDER_STATUS_PENDING_PAYMENT,
                ),
              ),
              FilterChip(
                label: const Text('Confirmed'),
                selected: _selectedStatus == OrderStatus.ORDER_STATUS_CONFIRMED,
                onSelected: (_) => setState(
                  () => _selectedStatus = OrderStatus.ORDER_STATUS_CONFIRMED,
                ),
              ),
              FilterChip(
                label: const Text('Fulfilled'),
                selected: _selectedStatus == OrderStatus.ORDER_STATUS_FULFILLED,
                onSelected: (_) => setState(
                  () => _selectedStatus = OrderStatus.ORDER_STATUS_FULFILLED,
                ),
              ),
              FilterChip(
                label: const Text('Cancelled'),
                selected: _selectedStatus == OrderStatus.ORDER_STATUS_CANCELLED,
                onSelected: (_) => setState(
                  () => _selectedStatus = OrderStatus.ORDER_STATUS_CANCELLED,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // A table where there is room for one; cards on a phone.
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 600
                ? Column(
                    children: [
                      for (final order in pageItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OrderCard(
                            order: order,
                            onTap: () => context.go('/orders/${order.id}'),
                          ),
                        ),
                    ],
                  )
                : _OrderTable(orders: pageItems),
          ),

          // Cursor paging
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  state.query.isEmpty
                      ? 'No orders yet'
                      : 'No orders match "${state.query}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          if (state.loadMoreError != null)
            Text(
              friendlyError(state.loadMoreError!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          if (state.hasMore)
            Center(
              child: OutlinedButton(
                key: const ValueKey('orders-load-more'),
                onPressed: state.loadingMore
                    ? null
                    : () => ref
                          .read(
                            orderListControllerProvider(widget.shopId).notifier,
                          )
                          .loadMore(),
                child: Text(state.loadingMore ? 'Loading…' : 'Load more'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderTable extends StatelessWidget {
  const _OrderTable({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('ORDER')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('PAYMENT')),
              DataColumn(label: Text('TOTAL')),
              DataColumn(label: Text('DATE')),
            ],
            rows: [
              for (final order in orders)
                DataRow(
                  onSelectChanged: (_) => context.go('/orders/${order.id}'),
                  cells: [
                    DataCell(
                      Text(
                        order.orderNumber.isNotEmpty
                            ? '#${order.orderNumber}'
                            : order.id,
                      ),
                    ),
                    DataCell(OrderStatusBadge(status: order.status)),
                    DataCell(PaymentStatusBadge(status: order.paymentStatus)),
                    DataCell(AmountDisplay(amount: order.total)),
                    DataCell(
                      Text(
                        order.hasCreatedAt()
                            ? _formatDate(order.createdAt.toDateTime())
                            : '',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
