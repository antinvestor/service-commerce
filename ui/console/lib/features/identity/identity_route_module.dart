import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart'
    show
        AccessRolesScreen,
        OrganizationsScreen,
        TeamsScreen,
        WorkforceMembersScreen;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Identity screens the console needs to run a shop: staff and the roles
/// that grant them access. Staff roles live in the identity service, not in
/// commerce, and shops inherit them from the partition.
///
/// The identity package ships screens but no route module, so the console
/// composes one here.
///
/// | Path                     | Screen                 |
/// |--------------------------|------------------------|
/// | /identity                | WorkforceMembersScreen |
/// | /identity/roles          | AccessRolesScreen      |
/// | /identity/teams          | TeamsScreen            |
/// | /identity/organizations  | OrganizationsScreen    |
class IdentityRouteModule extends RouteModule {
  static const String root = '/identity';
  static const String roles = '$root/roles';
  static const String teams = '$root/teams';
  static const String organizations = '$root/organizations';

  @override
  String get moduleId => 'identity';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: root,
      builder: (context, state) => const WorkforceMembersScreen(),
      routes: [
        GoRoute(
          path: 'roles',
          builder: (context, state) => const AccessRolesScreen(),
        ),
        GoRoute(
          path: 'teams',
          builder: (context, state) => const TeamsScreen(),
        ),
        GoRoute(
          path: 'organizations',
          builder: (context, state) => const OrganizationsScreen(),
        ),
      ],
    ),
  ];

  @override
  List<NavItem> buildNavItems() => const [
    NavItem(
      id: 'identity_staff',
      label: 'Staff',
      icon: Icons.badge_outlined,
      route: root,
    ),
    NavItem(
      id: 'identity_roles',
      label: 'Roles',
      icon: Icons.admin_panel_settings_outlined,
      route: roles,
    ),
    NavItem(
      id: 'identity_teams',
      label: 'Teams',
      icon: Icons.groups_outlined,
      route: teams,
    ),
    NavItem(
      id: 'identity_organizations',
      label: 'Organizations',
      icon: Icons.apartment_outlined,
      route: organizations,
    ),
  ];

  /// Access is enforced by the identity service per RPC.
  @override
  Map<String, Set<String>> get routePermissions => const {};
}
