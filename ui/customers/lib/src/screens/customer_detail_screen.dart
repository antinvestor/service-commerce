import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_core/widgets/amount_display.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/customer_providers.dart';
import '../widgets/customer_balance_card.dart';
import '../widgets/customer_credit_badge.dart';
import '../widgets/customer_note_tile.dart';

/// Detail screen for a single customer.
///
/// Shows a profile header (reusing [ProfileCard]) with tabs:
/// Orders | Balance | Locations | Notes.
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.shopId,
  });

  final String customerId;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCustomer = ref.watch(customerByIdProvider(customerId));

    return asyncCustomer.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load customer',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(friendlyError(error),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(customerByIdProvider(customerId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (profile) => _CustomerDetailContent(
        profile: profile,
        customerId: customerId,
        shopId: shopId,
      ),
    );
  }
}

class _CustomerDetailContent extends ConsumerStatefulWidget {
  const _CustomerDetailContent({
    required this.profile,
    required this.customerId,
    required this.shopId,
  });

  final ProfileObject profile;
  final String customerId;
  final String shopId;

  @override
  ConsumerState<_CustomerDetailContent> createState() =>
      _CustomerDetailContentState();
}

class _CustomerDetailContentState
    extends ConsumerState<_CustomerDetailContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.profile;
    final name = profileName(profile);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ProfileAvatar(
                  profileId: profile.id,
                  name: name,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ProfileTypeBadge(type: profile.type),
                          const SizedBox(width: 8),
                          SelectableText(
                            'ID: ${profile.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/customers'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => context.go(
                      '/customers/${widget.customerId}/payment'),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Receive Payment'),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Orders'),
              Tab(text: 'Balance'),
              Tab(text: 'Locations'),
              Tab(text: 'Notes'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrdersTab(
                  customerId: widget.customerId,
                  shopId: widget.shopId,
                ),
                _BalanceTab(customerId: widget.customerId),
                _LocationsTab(profile: profile),
                _NotesTab(customerId: widget.customerId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Orders Tab --

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({required this.customerId, required this.shopId});
  final String customerId;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(
      customerOrdersProvider((shopId: shopId, customerId: customerId)),
    );

    return asyncOrders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load orders',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(friendlyError(error),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(customerOrdersProvider(
                  (shopId: shopId, customerId: customerId))),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48,
                    color:
                        theme.colorScheme.onSurfaceVariant.withAlpha(80)),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _CustomerOrderTile(order: orders[index]),
        );
      },
    );
  }
}

/// Compact summary tile for a customer's order.
class _CustomerOrderTile extends StatelessWidget {
  const _CustomerOrderTile({required this.order});

  final Order order;

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.ORDER_STATUS_CONFIRMED:
        return 'Confirmed';
      case OrderStatus.ORDER_STATUS_CANCELLED:
        return 'Cancelled';
      case OrderStatus.ORDER_STATUS_FULFILLED:
        return 'Fulfilled';
      default:
        return 'Pending';
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber.isNotEmpty
                        ? '#${order.orderNumber}'
                        : order.id,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(order.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountDisplay(amount: order.total),
                const SizedBox(height: 4),
                if (order.hasCreatedAt())
                  Text(
                    _formatDate(order.createdAt.toDateTime()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- Balance Tab --

class _BalanceTab extends StatelessWidget {
  const _BalanceTab({required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomerBalanceCard(
        totalOwed: 0,
        creditStatus: CreditStatus.paidUp,
        paymentTerms: 'COD',
      ),
    );
  }
}

// -- Locations Tab --

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({required this.profile});
  final ProfileObject profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addresses = profile.addresses;

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              'No addresses on file',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: addresses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return AddressTile(address: address);
      },
    );
  }
}

// -- Notes Tab --

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab({required this.customerId});
  final String customerId;

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = ref.watch(customerNoteNotifierProvider);

    return Column(
      children: [
        // Add note input
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Add a note...',
                    isDense: true,
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  final text = _noteController.text.trim();
                  if (text.isNotEmpty) {
                    ref
                        .read(customerNoteNotifierProvider.notifier)
                        .add(text: text);
                    _noteController.clear();
                  }
                },
                icon: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ),

        // Notes list
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text(
                    'No notes yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    // Show newest first.
                    final note = notes[notes.length - 1 - index];
                    return CustomerNoteTile(
                      note: note,
                      onDelete: () => ref
                          .read(customerNoteNotifierProvider.notifier)
                          .remove(note.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
