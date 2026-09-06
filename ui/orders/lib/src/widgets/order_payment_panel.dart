import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/order_providers.dart';

/// Payment and lifecycle actions for one order: start hosted checkout, open
/// or copy the payment page, confirm a completed payment, and cancel.
///
/// What is offered follows the order's state:
/// - awaiting payment: Pay now (creates or reuses the checkout session),
///   Confirm payment (after the buyer paid), Cancel;
/// - confirmed and unshipped: Cancel (records a refund for a paid order);
/// - anything else: read-only summary.
class OrderPaymentPanel extends ConsumerWidget {
  const OrderPaymentPanel({super.key, required this.order});

  final Order order;

  bool get _awaitingPayment =>
      order.status == OrderStatus.ORDER_STATUS_PENDING_PAYMENT;

  bool get _cancellable =>
      order.status == OrderStatus.ORDER_STATUS_PENDING_PAYMENT ||
      (order.status == OrderStatus.ORDER_STATUS_CONFIRMED &&
          order.fulfilmentStatus.value <
              FulfilmentStatus.FULFILMENT_STATUS_SHIPPED.value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final busy = ref.watch(orderNotifierProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (order.paymentId.isNotEmpty)
            _row(theme, 'Payment reference', order.paymentId),
          if (order.hasPaidAt())
            _row(theme, 'Paid at', order.paidAt.toDateTime().toLocal().toString()),
          if (order.paymentSessionRef.isNotEmpty)
            _row(theme, 'Checkout session', order.paymentSessionRef),
          if (order.checkoutUrl.isNotEmpty && _awaitingPayment)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(order.checkoutUrl,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontFamily: 'monospace')),
                  ),
                  IconButton(
                    tooltip: 'Copy payment link',
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copy(context, order.checkoutUrl),
                  ),
                ],
              ),
            ),
          if (order.cancelReason.isNotEmpty)
            _row(theme, 'Cancelled', order.cancelReason),
          if (order.ledgerTransactionId.isNotEmpty)
            _row(theme, 'Ledger transaction', order.ledgerTransactionId),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_awaitingPayment)
                FilledButton.icon(
                  onPressed: busy ? null : () => _pay(context, ref),
                  icon: const Icon(Icons.payment, size: 18),
                  label: Text(order.checkoutUrl.isEmpty
                      ? 'Pay now'
                      : 'Open payment page'),
                ),
              if (_awaitingPayment && order.paymentSessionRef.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _confirm(context, ref),
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text('Confirm payment'),
                ),
              if (_cancellable)
                TextButton.icon(
                  onPressed: busy ? null : () => _cancel(context, ref),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(order.paymentStatus ==
                          PaymentStatus.PAYMENT_STATUS_PAID
                      ? 'Cancel and refund'
                      : 'Cancel order'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
            Expanded(
              child: SelectableText(value,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    try {
      final response =
          await ref.read(orderNotifierProvider.notifier).checkout(order.id);
      final url = response.checkoutUrl;
      if (url.isEmpty) {
        if (context.mounted) _toast(context, 'Payment page is not available yet.');
        return;
      }
      final opened = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        await _copy(context, url);
      }
    } catch (e) {
      if (context.mounted) _toast(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    try {
      final updated =
          await ref.read(orderNotifierProvider.notifier).confirmPayment(order.id);
      if (context.mounted) {
        _toast(
            context,
            updated.paymentStatus == PaymentStatus.PAYMENT_STATUS_PAID
                ? 'Payment confirmed.'
                : 'Payment is still pending.');
      }
    } catch (e) {
      if (context.mounted) _toast(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cancel order'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Reason'),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Keep order')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                child: const Text('Cancel order')),
          ],
        );
      },
    );
    if (reason == null) return;
    try {
      await ref
          .read(orderNotifierProvider.notifier)
          .cancel(order.id, reason: reason);
      if (context.mounted) _toast(context, 'Order cancelled.');
    } catch (e) {
      if (context.mounted) _toast(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) _toast(context, 'Payment link copied.');
  }

  void _toast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? Theme.of(context).colorScheme.error : null,
    ));
  }
}
