import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot of the KPIs surfaced on the dashboard.
///
/// Backed by placeholder data today. A production version will wire
/// each field to the relevant service's reporting RPC.
class DashboardKpis {
  const DashboardKpis({
    required this.todaysSales,
    required this.openPurchaseOrders,
    required this.activeBatches,
    required this.lowStockItems,
  });

  final String todaysSales;
  final int openPurchaseOrders;
  final int activeBatches;
  final int lowStockItems;
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

/// Placeholder KPI feed. Returns deterministic sample data so the
/// shell renders something meaningful before live wiring lands.
final dashboardKpisProvider = Provider<DashboardKpis>((ref) {
  return const DashboardKpis(
    todaysSales: r'KSh 248,300',
    openPurchaseOrders: 7,
    activeBatches: 3,
    lowStockItems: 12,
  );
});

/// Placeholder recent-activity feed used by the dashboard list.
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
