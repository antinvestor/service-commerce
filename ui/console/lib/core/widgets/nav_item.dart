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

/// Top-level nav items shown in the sidebar.
///
/// The sidebar hides any item whose route is not served by the composed
/// router (see `registeredRoutePathsProvider`), so an entry for a module
/// that is not registered never leads to a "page not found".
const List<NavItem> primaryNavItems = [
  NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/'),
  NavItem(
    label: 'Sales',
    icon: Icons.point_of_sale_outlined,
    route: '/orders',
    children: [
      NavItem(
        label: 'Orders',
        icon: Icons.receipt_long_outlined,
        route: '/orders',
      ),
      NavItem(
        label: 'New order',
        icon: Icons.add_shopping_cart_outlined,
        route: '/orders/checkout',
      ),
      NavItem(
        label: 'Payment signals',
        icon: Icons.notifications_active_outlined,
        route: '/orders/events',
      ),
    ],
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
  NavItem(label: 'Customers', icon: Icons.people_outline, route: '/customers'),
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
    children: [
      NavItem(
        label: 'Price lists',
        icon: Icons.list_alt_outlined,
        route: '/pricing',
      ),
      NavItem(
        label: 'Customer overrides',
        icon: Icons.person_pin_outlined,
        route: '/pricing/overrides',
      ),
      NavItem(
        label: 'Discounts',
        icon: Icons.local_offer_outlined,
        route: '/pricing/discounts',
      ),
      NavItem(
        label: 'Price checker',
        icon: Icons.price_check_outlined,
        route: '/pricing/checker',
      ),
    ],
  ),
  NavItem(
    label: 'Procurement',
    icon: Icons.local_shipping_outlined,
    route: '/procurement',
    group: 'Commerce',
    children: [
      NavItem(
        label: 'Overview',
        icon: Icons.dashboard_outlined,
        route: '/procurement',
      ),
      NavItem(
        label: 'Suppliers',
        icon: Icons.business_outlined,
        route: '/procurement/suppliers',
      ),
      NavItem(
        label: 'Purchase orders',
        icon: Icons.assignment_outlined,
        route: '/procurement/orders',
      ),
      NavItem(
        label: 'Suggestions',
        icon: Icons.auto_awesome_outlined,
        route: '/procurement/suggestions',
      ),
    ],
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
    children: [
      NavItem(label: 'Staff', icon: Icons.badge_outlined, route: '/identity'),
      NavItem(
        label: 'Roles',
        icon: Icons.admin_panel_settings_outlined,
        route: '/identity/roles',
      ),
      NavItem(
        label: 'Teams',
        icon: Icons.groups_outlined,
        route: '/identity/teams',
      ),
      NavItem(
        label: 'Organizations',
        icon: Icons.apartment_outlined,
        route: '/identity/organizations',
      ),
    ],
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
