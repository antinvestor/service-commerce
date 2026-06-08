import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Order;
import 'package:antinvestor_api_manufacturing/antinvestor_api_manufacturing.dart'
    show Batch, BatchStatus;
import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart'
    show PurchaseOrder, PurchaseOrderStatus;
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart'
    show inventoryItemListProvider;
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart'
    show orderListProvider;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show purchaseOrderListProvider;
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart'
    show batchListProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/tenant_context_provider.dart';

/// Snapshot of commerce + manufacturing KPIs surfaced on the dashboard.
class DashboardKpis {
  const DashboardKpis({
    required this.todaysSales,
    required this.openPurchaseOrders,
    required this.activeBatches,
    required this.lowStockItems,
    required this.expiringStockItems,
  });

  /// Placeholder used before the tenant scope resolves.
  factory DashboardKpis.empty() => const DashboardKpis(
        todaysSales: '—',
        openPurchaseOrders: 0,
        activeBatches: 0,
        lowStockItems: 0,
        expiringStockItems: 0,
      );

  final String todaysSales;
  final int openPurchaseOrders;
  final int activeBatches;
  final int lowStockItems;
  final int expiringStockItems;
}

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

/// Live KPI feed. Each field is computed from the corresponding domain
/// provider with a graceful fallback when the upstream call fails, so a
/// single transient backend issue cannot break the entire dashboard.
final dashboardKpisProvider = FutureProvider<DashboardKpis>((ref) async {
  final scope = ref.watch(tenantScopeProvider);
  if (!scope.isReady) {
    return DashboardKpis.empty();
  }

  final results = await Future.wait<Object>([
    _todaysSales(ref, scope.shopId),
    _openPurchaseOrders(ref, scope.propertyId),
    _activeBatches(ref, scope.propertyId),
    _lowStockItems(ref, scope.propertyId),
    _expiringStockItems(ref, scope.propertyId),
  ]);

  return DashboardKpis(
    todaysSales: results[0] as String,
    openPurchaseOrders: results[1] as int,
    activeBatches: results[2] as int,
    lowStockItems: results[3] as int,
    expiringStockItems: results[4] as int,
  );
});

final _currencyFormat = NumberFormat.currency(name: 'KES', symbol: 'KSh ');

/// Sum of order totals created since the start of the local day.
Future<String> _todaysSales(Ref ref, String shopId) async {
  if (shopId.isEmpty) return '—';
  try {
    final orders = await ref.read(orderListProvider(shopId).future);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final total = orders
        .where((o) => _orderCreatedAt(o)?.isAfter(startOfDay) ?? false)
        .fold<double>(0, (sum, o) => sum + _orderTotal(o));
    return _currencyFormat.format(total);
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

/// Count of purchase orders that are submitted but not yet fully received.
Future<int> _openPurchaseOrders(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return 0;
  try {
    final pos =
        await ref.read(purchaseOrderListProvider(propertyId).future);
    return pos.where(_isOpenPurchaseOrder).length;
  } catch (_) {
    return 0;
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
Future<int> _activeBatches(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return 0;
  try {
    final batches = await ref.read(batchListProvider(propertyId).future);
    return batches.where(_isActiveBatch).length;
  } catch (_) {
    return 0;
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

/// Count of inventory items below their reorder threshold.
///
/// The current `InventoryItem` protobuf does not expose a reorder level
/// nor a per-location stock balance in a single list call, so a true
/// low-stock aggregation needs a server-side endpoint (or N+1 balance
/// calls per item). Until that lands we surface zero — the dashboard
/// strip stays visually consistent without claiming false alerts.
Future<int> _lowStockItems(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return 0;
  try {
    // Touch the provider so the page still warms the inventory cache;
    // ignore the result until a dedicated low-stock RPC is available.
    await ref.read(inventoryItemListProvider(propertyId).future);
    return 0;
  } catch (_) {
    return 0;
  }
}

/// Count of stock lots expiring within the next 7 days.
///
/// Lot/expiry data lives on `StockMovement` / `LabelData` records and is
/// not exposed via a property-wide listing today. Returns zero until the
/// manufacturing service publishes an expiry aggregation endpoint.
Future<int> _expiringStockItems(Ref ref, String propertyId) async {
  if (propertyId.isEmpty) return 0;
  return 0;
}

/// Placeholder recent-activity feed.
///
/// A real feed requires an audit/events aggregation (orders, POs,
/// batches, stock adjustments) that no single service exposes today.
/// Keeping the sample data here lets the shell render meaningfully
/// until that cross-cutting feed is built.
final recentActivityProvider = Provider<List<RecentActivityEntry>>((ref) {
  final now = DateTime.now();
  return [
    RecentActivityEntry(
      title: 'Batch B-1042 completed',
      subtitle: 'Recipe: Honey & Oat — 480 units yielded',
      timestamp: now.subtract(const Duration(minutes: 12)),
    ),
    RecentActivityEntry(
      title: 'Purchase order PO-318 received',
      subtitle: 'Supplier: Acacia Foods',
      timestamp: now.subtract(const Duration(hours: 1)),
    ),
    RecentActivityEntry(
      title: 'Low stock alert — Vanilla Extract',
      subtitle: 'Below reorder level at warehouse W-1',
      timestamp: now.subtract(const Duration(hours: 3)),
    ),
    RecentActivityEntry(
      title: 'Order SO-9821 fulfilled',
      subtitle: 'Channel: storefront / 24 lines',
      timestamp: now.subtract(const Duration(hours: 5)),
    ),
  ];
});
