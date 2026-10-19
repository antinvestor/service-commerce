import 'package:console/core/router/console_modules.dart';
import 'package:console/core/widgets/app_sidebar.dart';
import 'package:console/core/widgets/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _page(BuildContext _, GoRouterState _) => const SizedBox();

void main() {
  test('collectRoutePaths joins nested relative paths', () {
    final paths = collectRoutePaths([
      GoRoute(
        path: '/pricing',
        builder: _page,
        routes: [
          GoRoute(path: 'overrides', builder: _page),
          GoRoute(
            path: ':id',
            builder: _page,
            routes: [GoRoute(path: 'assignments', builder: _page)],
          ),
        ],
      ),
      ShellRoute(
        builder: (_, _, child) => child,
        routes: [GoRoute(path: '/procurement/', builder: _page)],
      ),
    ]);
    expect(
      paths,
      containsAll([
        '/pricing',
        '/pricing/overrides',
        '/pricing/:id',
        '/pricing/:id/assignments',
        '/procurement',
      ]),
    );
  });

  test('visibleNavItems hides unregistered items and children', () {
    const items = [
      NavItem(
        label: 'Pricing',
        icon: Icons.sell,
        route: '/pricing',
        children: [
          NavItem(label: 'Overrides', icon: Icons.sell, route: '/pricing/x'),
          NavItem(label: 'Gone', icon: Icons.sell, route: '/pricing/gone'),
        ],
      ),
      NavItem(label: 'Missing', icon: Icons.sell, route: '/missing'),
    ];
    final visible = visibleNavItems(items, {'/pricing', '/pricing/x'});
    expect(visible.map((i) => i.label), ['Pricing']);
    expect(visible.single.children.map((c) => c.route), ['/pricing/x']);
  });

  test('pricing sub-pages are registered by the composed router', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final registered = container.read(registeredRoutePathsProvider);
    for (final route in [
      '/pricing/overrides',
      '/pricing/discounts',
      '/pricing/checker',
    ]) {
      expect(isRouteRegistered(registered, route), isTrue, reason: route);
    }
  });

  // Reports sidebar entries that point at modules the console does not
  // register. They are hidden at runtime; this prints them so they are
  // visible in test output without failing on other teams' modules.
  test('report sidebar routes missing from the router', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final registered = container.read(registeredRoutePathsProvider);
    final all = [
      ...primaryNavItems,
      ...secondaryNavItems,
      ...bottomNavItems,
      for (final item in secondaryNavItems) ...item.children,
    ];
    final missing = [
      for (final item in all)
        if (!isRouteRegistered(registered, item.route)) item.route,
    ];
    // ignore: avoid_print
    print('Sidebar routes not registered in the console router: $missing');
    expect(isRouteRegistered(registered, '/settings'), isTrue);
  });
}
