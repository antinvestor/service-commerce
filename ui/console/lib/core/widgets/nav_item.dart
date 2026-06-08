import 'package:flutter/material.dart';

/// A single sidebar destination in the console.
///
/// Items can be standalone leaves (e.g. Dashboard, Settings) or
/// expandable groups whose children point at the route modules
/// composed by the router.
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.children = const [],
    this.isGroup = false,
    this.group,
  });

  final String label;
  final IconData icon;
  final String route;

  /// Optional nested items rendered when the group is expanded.
  final List<NavItem> children;

  /// Whether this item is an expandable group header.
  final bool isGroup;

  /// Human-readable group label used for visual separation in the
  /// drawer / overflow menu.
  final String? group;

  bool get hasChildren => children.isNotEmpty;
}

/// Top-level nav items always visible in the sidebar.
const List<NavItem> primaryNavItems = [
  NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/'),
  NavItem(
    label: 'Sales',
    icon: Icons.point_of_sale_outlined,
    route: '/orders',
  ),
  NavItem(
    label: 'Production',
    icon: Icons.precision_manufacturing_outlined,
    route: '/production',
  ),
  NavItem(
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    route: '/inventory',
  ),
  NavItem(
    label: 'Customers',
    icon: Icons.people_outline,
    route: '/customers',
  ),
];

/// Secondary destinations surfaced via the "More" overflow drawer,
/// grouped by domain.
const List<NavItem> secondaryNavItems = [
  // Commerce
  NavItem(
    label: 'Catalog',
    icon: Icons.category_outlined,
    route: '/catalog',
    group: 'Commerce',
  ),
  NavItem(
    label: 'Pricing',
    icon: Icons.sell_outlined,
    route: '/pricing',
    group: 'Commerce',
  ),
  NavItem(
    label: 'Procurement',
    icon: Icons.local_shipping_outlined,
    route: '/procurement',
    group: 'Commerce',
  ),

  // Manufacturing
  NavItem(
    label: 'Recipes',
    icon: Icons.menu_book_outlined,
    route: '/recipes',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Equipment',
    icon: Icons.build_outlined,
    route: '/equipment',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Quality',
    icon: Icons.verified_outlined,
    route: '/quality',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Cold chain',
    icon: Icons.ac_unit_outlined,
    route: '/coldchain',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Waste',
    icon: Icons.delete_outline,
    route: '/waste',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Costing',
    icon: Icons.calculate_outlined,
    route: '/costing',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Demand',
    icon: Icons.insights_outlined,
    route: '/demand',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Traceability',
    icon: Icons.timeline_outlined,
    route: '/traceability',
    group: 'Manufacturing',
  ),
  NavItem(
    label: 'Shelf life',
    icon: Icons.schedule_outlined,
    route: '/shelflife',
    group: 'Manufacturing',
  ),

  // Platform
  NavItem(
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    route: '/notifications',
    group: 'Platform',
  ),
  NavItem(
    label: 'Payments',
    icon: Icons.payments_outlined,
    route: '/payments',
    group: 'Platform',
  ),
  NavItem(
    label: 'Identity',
    icon: Icons.badge_outlined,
    route: '/identity',
    group: 'Platform',
  ),
  NavItem(
    label: 'Profiles',
    icon: Icons.person_outline,
    route: '/profiles',
    group: 'Platform',
  ),
];

/// Items pinned to the bottom of the sidebar.
const List<NavItem> bottomNavItems = [
  NavItem(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  NavItem(label: 'Logout', icon: Icons.logout, route: '/logout'),
];
