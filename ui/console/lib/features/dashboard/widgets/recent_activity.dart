import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/dashboard_providers.dart';

/// Compact list of recent operational events shown on the dashboard.
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({required this.entries, super.key});

  final List<RecentActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Recent activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No recent activity yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          for (var i = 0; i < entries.length; i++) ...[
            _ActivityTile(entry: entries[i]),
            if (i < entries.length - 1)
              const Divider(height: 1, indent: 16),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final RecentActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.tertiarySwatch[50],
        child: const Icon(
          Icons.bolt_outlined,
          color: AppColors.tertiary,
          size: 18,
        ),
      ),
      title: Text(entry.title),
      subtitle: Text(entry.subtitle),
      trailing: Text(
        _relative(entry.timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
