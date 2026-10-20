import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Order, OrderStatus, PaymentStatus;
import 'package:antinvestor_api_manufacturing/antinvestor_api_manufacturing.dart'
    show Batch, BatchStatus;
import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart'
    show PurchaseOrder, PurchaseOrderStatus;
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart'
    show orderListProvider;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show purchaseOrderListProvider;
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart'
    show batchListProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/active_shop_provider.dart';
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

/// Sales booked today in the active shop's currency.
final todaysSalesProvider = FutureProvider<String>((ref) async {
  final scope = ref.watch(tenantScopeProvider);
  final currency = ref.watch(activeShopProvider.select((s) => s?.currency));
  return _todaysSales(ref, scope.shopId, currency ?? '');
});

/// Open orders with money still owed: unpaid or part-paid.
final awaitingPaymentProvider = FutureProvider<int?>((ref) async {
  return _awaitingPayment(ref, ref.watch(tenantScopeProvider).shopId);
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

/// Sum of order totals created since the start of the local day, in the
/// active shop's currency.
Future<String> _todaysSales(Ref ref, String shopId, String currency) async {
  if (shopId.isEmpty) return '—';
  try {
    final orders = await ref.read(orderListProvider(shopId).future);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final total = orders
        .where((o) => _orderCreatedAt(o)?.isAfter(startOfDay) ?? false)
        .fold<double>(0, (sum, o) => sum + _orderTotal(o));
    return formatShopMoney(total, currency);
  } catch (_) {
    return '—';
  }
}

DateTime? _orderCreatedAt(Order order) {
  if (!order.hasCreatedAt()) return null;
  final ts = order.createdAt;
  return DateTime.fromMillisecondsSinceEpoch(
    ts.seconds.toInt() * 1000 + (ts.nanos ~/ 1000000),
    isUtc: true,
  ).toLocal();
}

double _orderTotal(Order order) {
  if (!order.hasTotal()) return 0;
  final money = order.total;
  return money.units.toInt() + (money.nanos / 1e9);
}

/// Count of live orders that still owe money, including part-paid
/// instalment orders.
Future<int?> _awaitingPayment(Ref ref, String shopId) async {
  if (shopId.isEmpty) return null;
  try {
    final orders = await ref.read(orderListProvider(shopId).future);
    return orders.where(_owesMoney).length;
  } catch (_) {
    return null;
  }
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
  final shop = ref.watch(activeShopProvider);
  if (shop == null) return const [];
  final orders = await ref.watch(orderListProvider(shop.id).future);
  final dated = [
    for (final order in orders)
      if (_orderCreatedAt(order) case final created?) (order, created),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [
    for (final (order, created) in dated.take(_recentActivityLimit))
      RecentActivityEntry(
        title: 'Order ${order.orderNumber} · ${_paymentLabel(order)}',
        subtitle:
            '${formatShopMoney(_orderTotal(order), order.total.currencyCode)}'
            ' · ${order.lines.length} line${order.lines.length == 1 ? '' : 's'}',
        timestamp: created,
      ),
  ];
});

const _recentActivityLimit = 6;

String _paymentLabel(Order order) {
  if (order.status == OrderStatus.ORDER_STATUS_CANCELLED) return 'cancelled';
  return switch (order.paymentStatus) {
    PaymentStatus.PAYMENT_STATUS_PAID => 'paid',
    PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID => 'part-paid',
    PaymentStatus.PAYMENT_STATUS_REFUNDED => 'refunded',
    _ => 'awaiting payment',
  };
}
