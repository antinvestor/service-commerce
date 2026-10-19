import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/procurement_providers.dart';
import '../routing/procurement_paths.dart';
import '../util/idempotency.dart';

/// Builds the draft purchase order for one supplier's suggestion. Each line
/// orders the suggested quantity of the chosen supplier item, and the order
/// is linked to the plan it covers.
PurchaseOrderCreateRequest suggestionToRequest(
  PurchaseOrderSuggestion suggestion, {
  required String propertyId,
  required String planId,
  required String idempotencyKey,
}) {
  final request = PurchaseOrderCreateRequest()
    ..idempotencyKey = idempotencyKey
    ..propertyId = propertyId
    ..supplierId = suggestion.supplierId
    ..planId = planId;
  for (final line in suggestion.lines) {
    request.lines.add(
      PurchaseOrderLineInput()
        ..supplierItemId = line.supplierItemId
        ..inventoryItemId = line.inventoryItemId
        ..orderedQuantity = line.shortageQuantity
        ..unit = line.unit,
    );
  }
  return request;
}

/// Proposes purchase orders that cover a production plan's material
/// shortages: one per supplier, using each item's cheapest active supplier,
/// plus the shortages no supplier carries yet.
class PurchaseOrderSuggestionsScreen extends ConsumerStatefulWidget {
  const PurchaseOrderSuggestionsScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  ConsumerState<PurchaseOrderSuggestionsScreen> createState() =>
      _PurchaseOrderSuggestionsScreenState();
}

class _PurchaseOrderSuggestionsScreenState
    extends ConsumerState<PurchaseOrderSuggestionsScreen> {
  final _planController = TextEditingController();
  String? _planId;

  /// One key per supplier per plan, so a double tap or retry never creates a
  /// second order.
  final Map<String, String> _keys = {};
  final Set<String> _creating = {};

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  void _suggest() {
    final planId = _planController.text.trim();
    if (planId.isEmpty) return;
    setState(() {
      _planId = planId;
      _keys.clear();
    });
  }

  Future<void> _create(PurchaseOrderSuggestion suggestion) async {
    final planId = _planId!;
    final key = _keys.putIfAbsent(suggestion.supplierId, newIdempotencyKey);
    setState(() => _creating.add(suggestion.supplierId));
    try {
      final created = await ref
          .read(procurementNotifierProvider.notifier)
          .createPO(
            suggestionToRequest(
              suggestion,
              propertyId: widget.propertyId,
              planId: planId,
              idempotencyKey: key,
            ),
          );
      ref.invalidate(purchaseOrderListProvider);
      if (mounted) context.go(ProcurementPaths.order(created.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create the order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating.remove(suggestion.supplierId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planId = _planId;
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase order suggestions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Enter a production plan to see what to buy. Each item comes '
            'from its cheapest active supplier, raised to the supplier\'s '
            'minimum order.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('suggestion_plan_id'),
                  controller: _planController,
                  decoration: const InputDecoration(
                    labelText: 'Production plan ID',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _suggest(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                key: const Key('suggestion_submit'),
                onPressed: _suggest,
                child: const Text('Suggest'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (planId != null)
            ref
                .watch(
                  purchaseOrderSuggestionsProvider((
                    propertyId: widget.propertyId,
                    planId: planId,
                  )),
                )
                .when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text(
                    'Could not load suggestions: $e',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  data: (suggestions) => suggestions.isEmpty
                      ? const Text('This plan has no shortages to cover.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final s in suggestions)
                              _SuggestionCard(
                                suggestion: s,
                                creating: _creating.contains(s.supplierId),
                                onCreate: s.supplierId.isEmpty
                                    ? null
                                    : () => _create(s),
                              ),
                          ],
                        ),
                ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.creating,
    required this.onCreate,
  });

  final PurchaseOrderSuggestion suggestion;
  final bool creating;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unsourced = suggestion.supplierId.isEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    unsourced
                        ? 'No supplier yet'
                        : (suggestion.supplierName.isEmpty
                              ? suggestion.supplierId
                              : suggestion.supplierName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (suggestion.hasEstimatedTotal())
                  Text(
                    formatMoney(suggestion.estimatedTotal),
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
            if (unsourced)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Add a supplier item for these to include them in an order.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            for (final line in suggestion.lines)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  line.itemName.isEmpty ? line.inventoryItemId : line.itemName,
                ),
                subtitle: Text(
                  '${_quantity(line.shortageQuantity)} ${line.unit}',
                ),
                trailing: line.hasUnitPrice()
                    ? Text('${formatMoney(line.unitPrice)} each')
                    : null,
              ),
            if (!unsourced)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: Key('suggestion_create_${suggestion.supplierId}'),
                  onPressed: creating ? null : onCreate,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text(creating ? 'Creating…' : 'Create draft order'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _quantity(double q) =>
      q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);
}
