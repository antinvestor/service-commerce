import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'nav_destinations.dart';

/// Top-level chrome wrapping every authenticated route.
///
/// Renders a [NavigationRail] on wide layouts (≥ 720px) and a
/// [NavigationBar] on narrow ones, with a "More" affordance that
/// opens an end-drawer listing every remaining module so users can
/// reach low-traffic surfaces without polluting the primary nav.
class ConsoleShell extends ConsumerWidget {
  const ConsoleShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isNarrow = MediaQuery.sizeOf(context).width < 720;

    final selectedIndex = _resolveSelectedIndex(location);

    return Scaffold(
      endDrawer: const _MoreDrawer(),
      appBar: isNarrow
          ? AppBar(
              title: const Text('Console'),
              actions: [
                Builder(
                  builder: (ctx) => IconButton(
                    tooltip: 'More modules',
                    icon: const Icon(Icons.apps),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
              ],
            )
          : null,
      body: isNarrow
          ? child
          : Row(
              children: [
                _ConsoleNavigationRail(
                  selectedIndex: selectedIndex,
                  onSelect: (i) => context.go(kPrimaryDestinations[i].route),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isNarrow
          ? NavigationBar(
              selectedIndex: selectedIndex.clamp(
                0,
                kPrimaryDestinations.length - 1,
              ),
              onDestinationSelected: (i) =>
                  context.go(kPrimaryDestinations[i].route),
              destinations: [
                for (final d in kPrimaryDestinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            )
          : null,
    );
  }

  /// Map the active GoRouter location back to the primary nav slot
  /// that should appear selected. Returns -1 if the user is on a
  /// secondary route — the bar/rail then renders nothing as active.
  int _resolveSelectedIndex(String location) {
    for (var i = 0; i < kPrimaryDestinations.length; i++) {
      final route = kPrimaryDestinations[i].route;
      // Dashboard ('/') matches only when location is exactly '/'.
      if (route == '/') {
        if (location == '/') return i;
        continue;
      }
      if (location == route || location.startsWith('$route/')) return i;
    }
    return -1;
  }
}

class _ConsoleNavigationRail extends StatelessWidget {
  const _ConsoleNavigationRail({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = selectedIndex < 0 ? 0 : selectedIndex;

    return NavigationRail(
      extended: MediaQuery.sizeOf(context).width >= 1100,
      selectedIndex: clamped,
      onDestinationSelected: onSelect,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Icon(
          Icons.dashboard_customize_outlined,
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  tooltip: 'More modules',
                  icon: const Icon(Icons.apps),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
              const SizedBox(height: 8),
              const _AccountButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      destinations: [
        for (final d in kPrimaryDestinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    );
  }
}

class _AccountButton extends ConsumerWidget {
  const _AccountButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(userClaimsProvider);
    final name = claimsAsync.value?['name'] as String?;
    return PopupMenuButton<String>(
      tooltip: name ?? 'Account',
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (v) async {
        if (v == 'signout') {
          await ref.read(authRuntimeProvider).logout();
        } else if (v == 'profile') {
          if (context.mounted) context.go('/profiles');
        }
      },
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'signout', child: Text('Sign out')),
      ],
    );
  }
}

class _MoreDrawer extends StatelessWidget {
  const _MoreDrawer();

  @override
  Widget build(BuildContext context) {
    // Group entries by the optional `group` label.
    final groups = <String, List<ConsoleDrawerEntry>>{};
    for (final entry in kSecondaryDestinations) {
      groups.putIfAbsent(entry.group ?? 'Other', () => []).add(entry);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final groupName in groups.keys) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  groupName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              for (final entry in groups[groupName]!)
                ListTile(
                  leading: Icon(entry.icon),
                  title: Text(entry.label),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(entry.route);
                  },
                ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}
