import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/payment_status_badge.dart';

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Admin-grade order list screen with DataTable, search, and status filter.
class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  OrderStatus? _selectedStatus;
  int _currentPage = 0;
  int _pageSize = 25;

  static const _pageSizeOptions = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(orderListProvider(widget.shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/orders/checkout'),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
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
              Text('Failed to load orders',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(orderListProvider(widget.shopId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
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
      BuildContext context, ThemeData theme, List<Order> orders) {
    final totalPages = (orders.length / _pageSize).ceil();
    final pageStart = _currentPage * _pageSize;
    final pageEnd = (pageStart + _pageSize).clamp(0, orders.length);
    final pageItems =
        orders.isNotEmpty ? orders.sublist(pageStart, pageEnd) : <Order>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Orders',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (orders.isNotEmpty)
                      Text('${orders.length} orders',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/orders/checkout'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Order'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status filter chips
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) => setState(() {
                  _selectedStatus = null;
                  _currentPage = 0;
                }),
              ),
              FilterChip(
                label: const Text('Confirmed'),
                selected:
                    _selectedStatus == OrderStatus.ORDER_STATUS_CONFIRMED,
                onSelected: (_) => setState(() {
                  _selectedStatus = OrderStatus.ORDER_STATUS_CONFIRMED;
                  _currentPage = 0;
                }),
              ),
              FilterChip(
                label: const Text('Fulfilled'),
                selected:
                    _selectedStatus == OrderStatus.ORDER_STATUS_FULFILLED,
                onSelected: (_) => setState(() {
                  _selectedStatus = OrderStatus.ORDER_STATUS_FULFILLED;
                  _currentPage = 0;
                }),
              ),
              FilterChip(
                label: const Text('Cancelled'),
                selected:
                    _selectedStatus == OrderStatus.ORDER_STATUS_CANCELLED,
                onSelected: (_) => setState(() {
                  _selectedStatus = OrderStatus.ORDER_STATUS_CANCELLED;
                  _currentPage = 0;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data table
          Container(
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
                  rows: List.generate(pageItems.length, (i) {
                    final order = pageItems[i];
                    return DataRow(
                      onSelectChanged: (_) =>
                          context.go('/orders/${order.id}'),
                      cells: [
                        DataCell(Text(
                          order.orderNumber.isNotEmpty
                              ? '#${order.orderNumber}'
                              : order.id,
                        )),
                        DataCell(OrderStatusBadge(status: order.status)),
                        DataCell(PaymentStatusBadge(
                            status: order.paymentStatus)),
                        DataCell(AmountDisplay(amount: order.total)),
                        DataCell(Text(
                          order.hasCreatedAt()
                              ? _formatDate(order.createdAt.toDateTime())
                              : '',
                        )),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          // Pagination
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Rows per page:', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _pageSize,
                    underline: const SizedBox(),
                    items: _pageSizeOptions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text('$s')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _pageSize = v;
                          _currentPage = 0;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    orders.isEmpty
                        ? '0 of 0'
                        : '${pageStart + 1}-$pageEnd of ${orders.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
