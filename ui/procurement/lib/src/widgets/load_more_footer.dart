import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';

import '../providers/paged_list.dart';

/// The end of a paged list: a "Load more" button while pages remain, a
/// spinner while one loads, and the error with a retry when one failed.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.list,
    required this.onLoadMore,
  });

  final PagedList<Object?> list;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (list.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = list.loadMoreError;
    if (!list.hasMore && error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error != null)
              Text(
                friendlyError(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            OutlinedButton.icon(
              key: const Key('load_more'),
              onPressed: onLoadMore,
              icon: Icon(error != null ? Icons.refresh : Icons.expand_more),
              label: Text(error != null ? 'Try again' : 'Load more'),
            ),
          ],
        ),
      ),
    );
  }
}
