import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';
import 'order_payment_dialogs.dart';

/// The most a resolution note may hold; the server refuses more.
const maxRefundNoteLength = 500;

/// A refund the payment service could not pay, and, for staff who manage
/// orders, the two ways to settle it: send it again, or record that the
/// shop paid the buyer back itself.
class FailedRefundCard extends ConsumerWidget {
  const FailedRefundCard({
    super.key,
    required this.order,
    required this.refund,
    required this.canManage,
  });

  final Order order;
  final OrderRefund refund;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final busy = ref.watch(orderNotifierProvider).isLoading;
    final amount = formatMinor(
      moneyToMinor(refund.amount),
      refund.amount.currencyCode,
    );
    final why = refund.lastError.isNotEmpty ? ' (${refund.lastError})' : '';
    return Container(
      key: ValueKey('refund-failed-${refund.id}'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The payment service could not pay back $amount$why. '
                  'Send it again, or pay the buyer back yourself and record '
                  'it here.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (canManage) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('refund-retry-${refund.id}'),
                  onPressed: busy
                      ? null
                      : () => _resolve(
                          context,
                          ref,
                          OrderRefundResolution.ORDER_REFUND_RESOLUTION_RETRY,
                        ),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Send again'),
                ),
                FilledButton.icon(
                  key: ValueKey('refund-paid-back-${refund.id}'),
                  onPressed: busy
                      ? null
                      : () => _resolve(
                          context,
                          ref,
                          OrderRefundResolution
                              .ORDER_REFUND_RESOLUTION_PAID_BACK,
                        ),
                  icon: const Icon(Icons.price_check, size: 18),
                  label: const Text('Paid back by hand'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    OrderRefundResolution resolution,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final note = await showDialog<String>(
      context: context,
      builder: (_) => ResolveRefundDialog(resolution: resolution),
    );
    if (note == null) return;
    try {
      await ref
          .read(orderNotifierProvider.notifier)
          .resolveRefund(order.id, refund.id, resolution, note: note);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            resolution == OrderRefundResolution.ORDER_REFUND_RESOLUTION_RETRY
                ? 'Refund sent again'
                : 'Refund recorded as paid back',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed: ${paymentErrorMessage(e)}')),
      );
    }
  }
}

/// Confirms how a failed refund is settled and takes an optional note. Pops
/// with the trimmed note, or null when dismissed.
class ResolveRefundDialog extends StatefulWidget {
  const ResolveRefundDialog({super.key, required this.resolution});

  final OrderRefundResolution resolution;

  @override
  State<ResolveRefundDialog> createState() => _ResolveRefundDialogState();
}

class _ResolveRefundDialogState extends State<ResolveRefundDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retry =
        widget.resolution ==
        OrderRefundResolution.ORDER_REFUND_RESOLUTION_RETRY;
    return AlertDialog(
      title: Text(retry ? 'Send the refund again' : 'Record paid back'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                retry
                    ? 'The refund is sent to the buyer again as a new '
                          'payment.'
                    : 'Only if the shop has already paid the buyer back '
                          'itself. The order then shows Refunded.',
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('refund_resolve_note'),
                controller: _controller,
                maxLines: 2,
                maxLength: maxRefundNoteLength,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: retry
                      ? 'e.g. buyer fixed their wallet'
                      : 'e.g. cash at the till, receipt 42',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          key: const Key('refund_resolve_confirm'),
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(retry ? 'Send again' : 'Record paid back'),
        ),
      ],
    );
  }
}
