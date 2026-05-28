import 'package:flutter/material.dart';

/// One slot in the console's primary navigation.
class ConsoleNavDestination {
  const ConsoleNavDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Route to navigate to when the destination is tapped. Matches the
  /// `path` exposed by each `RouteModule.buildRoutes()`.
  final String route;
}

/// One entry in the "More" overflow drawer.
class ConsoleDrawerEntry {
  const ConsoleDrawerEntry({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.group,
  });

  final String id;
  final String label;
  final IconData icon;
  final String route;

  /// Optional grouping label (e.g. 'Manufacturing', 'Operations',
  /// 'Platform'). Drawer renders entries grouped by this value.
  final String? group;
}

/// Top-level destinations promoted to the persistent nav (NavigationRail
/// on desktop, NavigationBar on mobile).
const List<ConsoleNavDestination> kPrimaryDestinations = [
  ConsoleNavDestination(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    route: '/',
  ),
  ConsoleNavDestination(
    id: 'sales',
    label: 'Sales',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
    route: '/orders',
  ),
  ConsoleNavDestination(
    id: 'production',
    label: 'Production',
    icon: Icons.precision_manufacturing_outlined,
    selectedIcon: Icons.precision_manufacturing,
    route: '/production',
  ),
  ConsoleNavDestination(
    id: 'inventory',
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    route: '/inventory',
  ),
  ConsoleNavDestination(
    id: 'customers',
    label: 'Customers',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    route: '/customers',
  ),
];

/// Every other module the console can reach. Surfaced via the "More"
/// drawer / overflow menu.
const List<ConsoleDrawerEntry> kSecondaryDestinations = [
  // Manufacturing
  ConsoleDrawerEntry(
    id: 'recipes',
    label: 'Recipes',
    icon: Icons.menu_book_outlined,
    route: '/recipes',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'equipment',
    label: 'Equipment',
    icon: Icons.build_outlined,
    route: '/equipment',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'coldchain',
    label: 'Cold chain',
    icon: Icons.ac_unit_outlined,
    route: '/coldchain',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'quality',
    label: 'Quality',
    icon: Icons.verified_outlined,
    route: '/quality',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'waste',
    label: 'Waste',
    icon: Icons.delete_outline,
    route: '/waste',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'costing',
    label: 'Costing',
    icon: Icons.calculate_outlined,
    route: '/costing',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'demand',
    label: 'Demand',
    icon: Icons.insights_outlined,
    route: '/demand',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'traceability',
    label: 'Traceability',
    icon: Icons.timeline_outlined,
    route: '/traceability',
    group: 'Manufacturing',
  ),
  ConsoleDrawerEntry(
    id: 'shelflife',
    label: 'Shelf life',
    icon: Icons.schedule_outlined,
    route: '/shelflife',
    group: 'Manufacturing',
  ),

  // Commerce / Operations
  ConsoleDrawerEntry(
    id: 'procurement',
    label: 'Procurement',
    icon: Icons.local_shipping_outlined,
    route: '/procurement',
    group: 'Commerce',
  ),
  ConsoleDrawerEntry(
    id: 'pricing',
    label: 'Pricing',
    icon: Icons.sell_outlined,
    route: '/pricing',
    group: 'Commerce',
  ),
  ConsoleDrawerEntry(
    id: 'catalog',
    label: 'Catalog',
    icon: Icons.category_outlined,
    route: '/catalog',
    group: 'Commerce',
  ),

  // Platform / cross-cutting
  ConsoleDrawerEntry(
    id: 'notifications',
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    route: '/notifications',
    group: 'Platform',
  ),
  ConsoleDrawerEntry(
    id: 'payments',
    label: 'Payments',
    icon: Icons.payments_outlined,
    route: '/payments',
    group: 'Platform',
  ),
  ConsoleDrawerEntry(
    id: 'identity',
    label: 'Identity',
    icon: Icons.badge_outlined,
    route: '/identity',
    group: 'Platform',
  ),
  ConsoleDrawerEntry(
    id: 'profile',
    label: 'Profiles',
    icon: Icons.person_outline,
    route: '/profiles',
    group: 'Platform',
  ),
];
