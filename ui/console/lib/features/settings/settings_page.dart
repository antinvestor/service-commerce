import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/tenant_context_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/widgets/page_header.dart';

/// Console settings surface.
///
/// Renders four panels stacked vertically:
/// 1. Appearance — light/dark/system theme switcher
/// 2. Profile & account — link to identity profile + email
/// 3. Tenant / organization scope — current shop + property
/// 4. Session — sign-out button + about/version info
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String _consoleVersion = String.fromEnvironment(
    'CONSOLE_VERSION',
    defaultValue: 'dev',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final claimsAsync = ref.watch(userClaimsProvider);
    final scope = ref.watch(tenantScopeProvider);
    final runtime = ref.watch(authRuntimeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Settings',
                subtitle:
                    'Adjust your console appearance, profile, and session.',
                breadcrumbs: ['Dashboard', 'Settings'],
              ),
              const SizedBox(height: 24),
              _Panel(
                title: 'Appearance',
                child: _ThemeSwitcher(
                  current: themeModeAsync.value ?? ThemeMode.system,
                  onChanged: (mode) =>
                      ref.read(themeModeProvider.notifier).set(mode),
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                title: 'Profile & account',
                child: claimsAsync.when(
                  data: (claims) => _ProfileSection(claims: claims),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, _) => const Text('Unable to load profile.'),
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                title: 'Tenant scope',
                child: _TenantScopeSection(scope: scope),
              ),
              const SizedBox(height: 16),
              _Panel(
                title: 'Session',
                child: _SessionSection(
                  onSignOut: () async {
                    await runtime.logout();
                  },
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                title: 'About',
                child: _AboutSection(version: _consoleVersion),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher({required this.current, required this.onChanged});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.claims});

  final Map<String, dynamic> claims;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = claims['name'] as String? ??
        claims['preferred_username'] as String? ??
        'Unknown operator';
    final email = claims['email'] as String? ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.tertiary,
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall),
                  Text(email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.go('/profiles'),
          icon: const Icon(Icons.person_outline),
          label: const Text('Open profile'),
        ),
      ],
    );
  }

  String _initials(String name) => name
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();
}

class _TenantScopeSection extends StatelessWidget {
  const _TenantScopeSection({required this.scope});

  final TenantScope scope;

  @override
  Widget build(BuildContext context) {
    if (!scope.isReady) {
      return Text(
        'No shop or property selected yet.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScopeRow(label: 'Shop', value: scope.shopId),
        _ScopeRow(label: 'Property', value: scope.propertyId),
        _ScopeRow(label: 'Partition', value: scope.partitionId),
      ],
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Antinvestor Console',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Version $version',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Auth runtime $authRuntimeVersion',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
