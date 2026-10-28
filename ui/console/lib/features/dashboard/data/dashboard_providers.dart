import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show
        ListOrdersRequest,
        Order,
        OrderStatus,
        PageCursor,
        PaymentStatus,
        SearchRequest;
import 'package:antinvestor_api_manufacturing/antinvestor_api_manufacturing.dart'
    show Batch, BatchStatus;
import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart'
    show PurchaseOrder, PurchaseOrderStatus;
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart'
    show orderServiceClientProvider;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show purchaseOrderListProvider;
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart'
    show batchListProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/active_shop_provider.dart';
import 'sales_math.dart';
import '../../../core/auth/tenant_context_provider.dart';

class RecentActivityEntry {
  const RecentActivityEntry({
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
}

// Each KPI loads on its own so a slow or unreachable service only blanks
// its own card. A null count means the figure could not be loaded; it is
// shown as a dash rather than a zero that would read as "nothing to do".

/// Orders read for the dashboard figures: at most [dashboardOrderPages]
/// pages of [dashboardOrderPageSize], newest first. ListOrders has no
/// aggregate, so the figures are computed over this window and say so when
/// the shop has more orders than it holds.
const int dashboardOrderPages = 5;
const int dashboardOrderPageSize = 100;

/// The newest orders of a shop, and whether older ones were left out.
class RecentOrders {
  const RecentOrders(this.orders, {required this.truncated});

  final List<Order> orders;
  final bool truncated;
}

/// The active shop's newest orders, read page by page up to the bound.
final dashboardOrdersProvider = FutureProvider<RecentOrders?>((ref) async {
  final shopId = ref.watch(tenantScopeProvider.select((s) => s.shopId));
  if (shopId.isEmpty) return null;
  final client = ref.watch(orderServiceClientProvider);
  final orders = <Order>[];
  var page = '';
  for (var i = 0; i < dashboardOrderPages; i++) {
    final cursor = PageCursor(limit: dashboardOrderPageSize);
    if (page.isNotEmpty) cursor.page = page;
    final response = await client.listOrders(
      ListOrdersRequest(
        shopId: shopId,
        search: SearchRequest(cursor: cursor),
      ),
    );
    orders.addAll(response.orders);
    page = response.nextPage;
    if (page.isEmpty) return RecentOrders(orders, truncated: false);
  }
  return RecentOrders(orders, truncated: true);
});

/// A KPI value and an optional note on how it was worked out.
typedef Kpi = ({String value, String? note});

/// Money received today, in the active shop's currency.
final todaysSalesProvider = FutureProvider<Kpi>((ref) async {
  final currency = ref.watch(activeShopProvider.select((s) => s?.currency));
  try {
    final recent = await ref.watch(dashboardOrdersProvider.future);
    if (recent == null) return (value: '—', note: null);
    final code = (currency ?? '').trim().toUpperCase();
    final now = DateTime.now();
    final minor = paidMinorSince(
      recent.orders,
      DateTime(now.year, now.month, now.day),
      code,
    );
    return (
      value: formatMinorMoney(minor, code),
      note: recent.truncated
          ? 'Payments today on the latest ${recent.orders.length} orders'
          : 'Payments received today',
    );
  } catch (_) {
    return (value: '—', note: null);
  }
});

/// Open orders with money still owed: unpaid or part-paid.
final awaitingPaymentProvider = FutureProvider<Kpi>((ref) async {
  try {
    final recent = await ref.watch(dashboardOrdersProvider.future);
    if (recent == null) return (value: '—', note: null);
    final count = recent.orders.where(_owesMoney).length;
    return (
      value: '$count',
      note: recent.truncated
          ? 'Of the latest ${recent.orders.length} orders'
          : null,
    );
  } catch (_) {
    return (value: '—', note: null);
  }
});

/// Purchase orders submitted but not yet fully received.
final openPurchaseOrdersProvider = FutureProvider<int?>((ref) async {
  return _openPurchaseOrders(ref, ref.watch(tenantScopeProvider).propertyId);
});

/// Production batches in flight.
final activeBatchesProvider = FutureProvider<int?>((ref) async {
  return _activeBatches(ref, ref.watch(tenantScopeProvider).propertyId);
});

/// Formats [amount] in the shop's [currency] (ISO 4217), e.g. `KES 1,250.00`.
/// Without a currency the bare amount is shown rather than guessing one.
String formatShopMoney(double amount, String currency) {
  final code = currency.trim().toUpperCase();
  if (code.isEmpty) return NumberFormat('#,##0.00').format(amount);
  return NumberFormat.currency(name: code, symbol: '$code ').format(amount);
}

DateTime? _orderCreatedAt(Order order) {
  if (!order.hasCreatedAt()) return null;
  final ts = order.createdAt;
  return DateTime.fromMillisecondsSinceEpoch(
    ts.seconds.toInt() * 1000 + (ts.nanos ~/ 1000000),
    isUtc: true,
  ).toLocal();
}

bool _owesMoney(Order order) {
  if (order.status == OrderStatus.ORDER_STATUS_CANCELLED) return false;
  switch (order.paymentStatus) {
    case PaymentStatus.PAYMENT_STATUS_PENDING:
    case PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID:
      return true;
    default:
      return false;
  }
}

/// Count of purchase orders that are submitted but not yet fully received.
Future<int?> _openPurchaseOrders(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return null;
  try {
    final pos = await ref.read(purchaseOrderListProvider(propertyId).future);
    return pos.where(_isOpenPurchaseOrder).length;
  } catch (_) {
    return null;
  }
}

bool _isOpenPurchaseOrder(PurchaseOrder po) {
  switch (po.status) {
    case PurchaseOrderStatus.PURCHASE_ORDER_STATUS_SUBMITTED:
    case PurchaseOrderStatus.PURCHASE_ORDER_STATUS_CONFIRMED:
    case PurchaseOrderStatus.PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED:
      return true;
    default:
      return false;
  }
}

/// Count of batches currently in flight (created through completing).
Future<int?> _activeBatches(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return null;
  try {
    final batches = await ref.read(batchListProvider(propertyId).future);
    return batches.items.where(_isActiveBatch).length;
  } catch (_) {
    return null;
  }
}

bool _isActiveBatch(Batch batch) {
  switch (batch.status) {
    case BatchStatus.BATCH_STATUS_CREATED:
    case BatchStatus.BATCH_STATUS_STARTED:
    case BatchStatus.BATCH_STATUS_PAUSED:
    case BatchStatus.BATCH_STATUS_COMPLETING:
      return true;
    default:
      return false;
  }
}

/// The shop's most recent orders, newest first, as the activity feed.
final recentActivityProvider = FutureProvider<List<RecentActivityEntry>>((
  ref,
) async {
  final recent = await ref.watch(dashboardOrdersProvider.future);
  if (recent == null) return const [];
  final dated = [
    for (final order in recent.orders)
      if (_orderCreatedAt(order) case final created?) (order, created),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [
    for (final (order, created) in dated.take(_recentActivityLimit))
      RecentActivityEntry(
        title: 'Order ${order.orderNumber} · ${_paymentLabel(order)}',
        subtitle:
            '${_orderTotalText(order)}'
            ' · ${order.lines.length} line${order.lines.length == 1 ? '' : 's'}',
        timestamp: created,
      ),
  ];
});

const _recentActivityLimit = 6;

String _orderTotalText(Order order) {
  if (!order.hasTotal()) return '—';
  final code = order.total.currencyCode.toUpperCase();
  return formatMinorMoney(
    toMinor(order.total.units.toInt(), order.total.nanos, currencyDigits(code)),
    code,
  );
}

String _paymentLabel(Order order) {
  return switch (order.paymentStatus) {
    PaymentStatus.PAYMENT_STATUS_REFUND_PENDING => 'refund pending',
    PaymentStatus.PAYMENT_STATUS_REFUNDED => 'refunded',
    _ when order.status == OrderStatus.ORDER_STATUS_CANCELLED => 'cancelled',
    PaymentStatus.PAYMENT_STATUS_PAID => 'paid',
    PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID => 'part-paid',
    _ => 'awaiting payment',
  };
}
