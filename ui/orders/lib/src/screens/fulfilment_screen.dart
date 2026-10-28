import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise update mask.
// ignore: implementation_imports
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../widgets/fulfilment_panel.dart';
import '../widgets/fulfilment_status_badge.dart';
import '../widgets/order_line_tile.dart';

/// Screen for creating and managing fulfilments against an order: lists the
/// order's fulfilments (with status/carrier/tracking updates) and creates a
/// new one from selected line quantities.
class FulfilmentScreen extends ConsumerStatefulWidget {
  const FulfilmentScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<FulfilmentScreen> createState() => _FulfilmentScreenState();
}

class _FulfilmentScreenState extends ConsumerState<FulfilmentScreen> {
  final Map<String, int> _quantities = {};
  final _carrier = TextEditingController();
  final _tracking = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _carrier.dispose();
    _tracking.dispose();
    super.dispose();
  }

  Future<void> _createFulfilment(Order order) async {
    final lines = <FulfilmentLine>[];
    for (final entry in _quantities.entries) {
      if (entry.value > 0) {
        lines.add(
          FulfilmentLine()
            ..orderLineId = entry.key
            ..quantity = Int64(entry.value),
        );
      }
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one line to fulfil')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final request = CreateFulfilmentRequest()
        ..orderId = widget.orderId
        ..lines.addAll(lines);

      final notifier = ref.read(fulfilmentNotifierProvider.notifier);
      final created = await notifier.create(request);
      ref.invalidate(orderByIdProvider(widget.orderId));

      // CreateFulfilment takes only lines; carrier and tracking are set
      // with a follow-up update.
      final carrier = _carrier.text.trim();
      final tracking = _tracking.text.trim();
      var message = 'Fulfilment created';
      if (carrier.isNotEmpty || tracking.isNotEmpty) {
        final update = UpdateFulfilmentRequest(id: created.id);
        final paths = <String>[];
        if (carrier.isNotEmpty) {
          update.carrier = carrier;
          paths.add('carrier');
        }
        if (tracking.isNotEmpty) {
          update.trackingNumber = tracking;
          paths.add('tracking_number');
        }
        update.updateMask = FieldMask(paths: paths);
        try {
          await notifier.update(update);
        } catch (e) {
          message =
              'Fulfilment created, but carrier/tracking were not '
              'saved: ${friendlyError(e)}';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        context.go('/orders/${widget.orderId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${friendlyError(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrder = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      body: asyncOrder.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Failed to load order', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                friendlyError(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/orders/${widget.orderId}'),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fulfilment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FulfilmentStatusBadge(status: order.fulfilmentStatus),
                ],
              ),
              const SizedBox(height: 24),

              // Existing fulfilments
              OrderFulfilmentsPanel(orderId: widget.orderId),
              const SizedBox(height: 24),

              Text(
                'Create Fulfilment',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Carrier / tracking
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _carrier,
                      decoration: const InputDecoration(
                        labelText: 'Carrier',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tracking,
                      decoration: const InputDecoration(
                        labelText: 'Tracking Number',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order lines with quantity pickers
              Text(
                'Select Lines to Fulfil',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: order.lines.map((line) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: OrderLineTile(line: line)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Qty',
                                hintText: '${line.quantity.toInt()}',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final qty = int.tryParse(v) ?? 0;
                                setState(() => _quantities[line.id] = qty);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => _createFulfilment(order),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: const Text('Create Fulfilment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
