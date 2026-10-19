import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../widgets/order_event_timeline.dart';

/// Shop-wide feed of order payment and lifecycle events (ListOrderEvents by
/// shop), oldest first with cursor paging, including each event's webhook
/// delivery state.
class OrderEventsScreen extends ConsumerWidget {
  const OrderEventsScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = shopEventsControllerProvider(shopId);
    final asyncEvents = ref.watch(provider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/orders'),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.notifications_active_outlined,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Order events',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(provider),
                ),
              ],
            ),
            const SizedBox(height: 20),
            asyncEvents.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed to load events',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friendlyError(error),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(provider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrderEventTimeline(
                    events: state.events,
                    showOrder: true,
                    onOrderTap: (e) => context.go('/orders/${e.orderId}'),
                  ),
                  if (state.loadMoreError != null)
                    Text(
                      friendlyError(state.loadMoreError!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  if (state.hasMore)
                    Center(
                      child: OutlinedButton(
                        onPressed: state.loadingMore
                            ? null
                            : () => ref.read(provider.notifier).loadMore(),
                        child: Text(
                          state.loadingMore ? 'Loading…' : 'Load more',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
