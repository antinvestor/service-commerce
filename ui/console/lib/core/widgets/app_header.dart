import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/tenant_context_provider.dart';
import '../theme/app_colors.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onMenuTap,
    this.showMenuButton = false,
  });

  final VoidCallback? onMenuTap;
  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 800;
    final scope = ref.watch(tenantScopeProvider);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showMenuButton) ...[
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
            ),
            const SizedBox(width: 8),
          ],
          if (!isCompact) ...[
            Text(
              _scopeLabel(scope),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
            ),
          ],
          const Spacer(),
          if (!isCompact) ...[
            IconButton(
              onPressed: () => context.go('/notifications'),
              tooltip: 'Notifications',
              icon: const Icon(
                Icons.notifications_outlined,
                size: 22,
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: _UserAvatar(ref: ref, compact: isCompact)),
        ],
      ),
    );
  }

  String _scopeLabel(TenantScope scope) {
    if (scope.shopId.isEmpty) return 'No shop selected';
    if (scope.propertyId.isEmpty) return scope.shopId;
    return '${scope.shopId} · ${scope.propertyId}';
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.ref, this.compact = false});

  final WidgetRef ref;
  final bool compact;

  static String _resolveName(Map<String, dynamic>? info) {
    if (info == null) return 'Operator';
    final name = info['name'] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final given = info['given_name'] as String? ?? '';
    final family = info['family_name'] as String? ?? '';
    final fullName = '$given $family'.trim();
    if (fullName.isNotEmpty) return fullName;
    final preferred = info['preferred_username'] as String?;
    if (preferred != null && preferred.trim().isNotEmpty) {
      return preferred.trim();
    }
    final email = info['email'] as String?;
    if (email != null && email.trim().isNotEmpty) return email.trim();
    return 'Operator';
  }

  static String _resolveSubtitle(Map<String, dynamic>? info) {
    if (info == null) return 'Console';
    final email = info['email'] as String?;
    if (email != null && email.trim().isNotEmpty) return email.trim();
    final preferred = info['preferred_username'] as String?;
    if (preferred != null && preferred.trim().isNotEmpty) {
      return preferred.trim();
    }
    return 'Console';
  }

  @override
  Widget build(BuildContext context) {
    final claimsAsync = ref.watch(userClaimsProvider);
    final claims = claimsAsync.whenOrNull(data: (info) => info);
    final name = _resolveName(claims);
    final subtitle = _resolveSubtitle(claims);

    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        if (!compact) const SizedBox(width: 10),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.tertiary,
          child: Text(
            initials.isNotEmpty ? initials : 'O',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
