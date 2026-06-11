import 'package:antinvestor_api_audit/antinvestor_api_audit.dart'
    show AuditEntryObject, ListAuditEntriesRequest, ListAuditEntriesResponse;
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
import 'package:antinvestor_ui_core/api/stream_helpers.dart'
    show collectStream;
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart'
    show batchListProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/tenant_context_provider.dart';
import '../../../core/services/audit_client_provider.dart';

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

/// How many audit entries the dashboard feed shows.
const _recentActivityCount = 8;

/// Recent-activity feed backed by the audit service.
///
/// Every service writes its actions to the tamper-proof audit trail, so
/// one query covers orders, POs, batches, and stock adjustments alike.
/// The bearer token scopes results to the operator's tenant server-side.
/// Failures degrade to an empty list (rendered as a quiet empty state)
/// in line with the KPI providers — a transient audit outage must not
/// break the dashboard.
final recentActivityProvider =
    FutureProvider<List<RecentActivityEntry>>((ref) async {
  final scope = ref.watch(tenantScopeProvider);
  if (!scope.isReady) {
    return const [];
  }

  try {
    final client = ref.watch(auditServiceClientProvider);
    final stream = client.listAuditEntries(
      ListAuditEntriesRequest(count: _recentActivityCount),
    );
    final entries = await collectStream<ListAuditEntriesResponse,
        AuditEntryObject>(
      stream,
      extract: (r) => r.data,
      maxPages: 1,
    );
    entries.sort((a, b) => _entryTime(b).compareTo(_entryTime(a)));
    return entries
        .take(_recentActivityCount)
        .map(_toActivityEntry)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
});

RecentActivityEntry _toActivityEntry(AuditEntryObject entry) {
  return RecentActivityEntry(
    title: _activityTitle(entry),
    subtitle: _activitySubtitle(entry),
    timestamp: _entryTime(entry),
  );
}

DateTime _entryTime(AuditEntryObject entry) {
  if (!entry.hasCreatedAt()) return DateTime.fromMillisecondsSinceEpoch(0);
  final ts = entry.createdAt;
  return DateTime.fromMillisecondsSinceEpoch(
    ts.seconds.toInt() * 1000 + (ts.nanos ~/ 1000000),
    isUtc: true,
  ).toLocal();
}

/// "purchase_order" + "create" → "Purchase order created".
String _activityTitle(AuditEntryObject entry) {
  final resource = _humanize(entry.resourceType);
  final action = _pastTense(entry.action);
  if (resource.isEmpty) return action.isEmpty ? 'Activity' : action;
  return action.isEmpty ? resource : '$resource ${action.toLowerCase()}';
}

String _activitySubtitle(AuditEntryObject entry) {
  final parts = <String>[
    if (entry.service.isNotEmpty) _humanize(entry.service),
    if (entry.resourceId.isNotEmpty) entry.resourceId,
  ];
  return parts.isEmpty ? '—' : parts.join(' · ');
}

/// "service_commerce" / "purchase_order" → "Service commerce" /
/// "Purchase order".
String _humanize(String raw) {
  final words = raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  if (words.isEmpty) return '';
  return words[0].toUpperCase() + words.substring(1).toLowerCase();
}

/// Best-effort verb for the feed title: "create" → "Created". Unknown
/// verbs pass through humanized rather than mangled.
String _pastTense(String action) {
  final a = action.trim().toLowerCase();
  if (a.isEmpty) return '';
  const irregular = {
    'create': 'Created',
    'update': 'Updated',
    'delete': 'Deleted',
    'login': 'Logged in',
    'logout': 'Logged out',
    'grant_permission': 'Permission granted',
    'revoke_permission': 'Permission revoked',
  };
  final known = irregular[a];
  if (known != null) return known;
  if (a.endsWith('e')) return _humanize('${a}d');
  if (a.endsWith('ed')) return _humanize(a);
  return _humanize(a);
}
