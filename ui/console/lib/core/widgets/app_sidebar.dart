import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'nav_item.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.collapsed = false,
    this.onToggleCollapse,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final bool collapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group secondary items by their `group` label so the drawer/sidebar
    // renders matching sections.
    final groups = <String, List<NavItem>>{};
    for (final item in secondaryNavItems) {
      groups.putIfAbsent(item.group ?? 'Other', () => []).add(item);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: collapsed ? 72 : 272,
      decoration: const BoxDecoration(color: AppColors.sidebarBg),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final item in primaryNavItems)
                  _NavTile(
                    item: item,
                    isActive: _isActive(item.route),
                    collapsed: collapsed,
                    onTap: () => onNavigate(item.route),
                  ),
                const SizedBox(height: 16),
                for (final entry in groups.entries) ...[
                  if (!collapsed)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: AppColors.sidebarText
                                  .withValues(alpha: 0.5),
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                  for (final item in entry.value)
                    _NavTile(
                      item: item,
                      isActive: _isActive(item.route),
                      collapsed: collapsed,
                      onTap: () => onNavigate(item.route),
                      compact: true,
                    ),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.sidebarActiveBg, height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: bottomNavItems
                  .map(
                    (item) => _NavTile(
                      item: item,
                      isActive: _isActive(item.route),
                      collapsed: collapsed,
                      onTap: () => onNavigate(item.route),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 12 : 20,
        vertical: 24,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: collapsed ? onToggleCollapse : null,
            child: Tooltip(
              message: collapsed ? 'Expand sidebar' : '',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Antinvestor',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Console',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors.sidebarText
                              .withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (onToggleCollapse != null)
              IconButton(
                onPressed: onToggleCollapse,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.sidebarText,
                  size: 20,
                ),
                splashRadius: 16,
              ),
          ],
        ],
      ),
    );
  }

  bool _isActive(String route) {
    if (route == '/') return currentRoute == '/';
    return currentRoute == route || currentRoute.startsWith('$route/');
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
    this.compact = false,
  });

  final NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? AppColors.sidebarActiveBg
        : _hovered
            ? AppColors.sidebarHoverBg.withValues(alpha: 0.5)
            : Colors.transparent;

    final fg = widget.isActive
        ? AppColors.sidebarActiveText
        : AppColors.sidebarText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 0 : 12,
                vertical: widget.compact ? 8 : 10,
              ),
              child: widget.collapsed
                  ? Center(
                      child: Tooltip(
                        message: widget.item.label,
                        child: Icon(
                          widget.item.icon,
                          color: fg,
                          size: 22,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          widget.item.icon,
                          color: fg,
                          size: widget.compact ? 18 : 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.item.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: fg,
                                  fontSize: widget.compact ? 13 : null,
                                  fontWeight: widget.isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
