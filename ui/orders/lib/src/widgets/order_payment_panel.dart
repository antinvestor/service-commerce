import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:connectrpc/connect.dart';
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
///   "I've paid — check status" (verifies the session), Cancel;
/// - confirmed and unshipped: Cancel (records a refund for a paid order);
/// - anything else: read-only summary.
///
/// While the order awaits payment the order is reloaded whenever the app
/// regains focus, so returning from the payment page shows the latest
/// state without a manual refresh.
class OrderPaymentPanel extends ConsumerStatefulWidget {
  const OrderPaymentPanel({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<OrderPaymentPanel> createState() => _OrderPaymentPanelState();
}

class _OrderPaymentPanelState extends ConsumerState<OrderPaymentPanel> {
  late final AppLifecycleListener _lifecycle;

  /// Set once the payment page has been opened from this panel.
  bool _checkoutOpened = false;

  /// Inline note shown after a status check that found no payment yet.
  String? _pendingNote;

  Order get order => widget.order;

  bool get _awaitingPayment =>
      order.status == OrderStatus.ORDER_STATUS_PENDING_PAYMENT;

  bool get _cancellable =>
      order.status == OrderStatus.ORDER_STATUS_PENDING_PAYMENT ||
      (order.status == OrderStatus.ORDER_STATUS_CONFIRMED &&
          order.fulfilmentStatus.value <
              FulfilmentStatus.FULFILMENT_STATUS_SHIPPED.value);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Reloads the order when the operator comes back (e.g. from the payment
  /// page in another tab or app) while it still awaits payment.
  void _onResume() {
    if (!mounted || !_awaitingPayment) return;
    ref.invalidate(orderByIdProvider(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = ref.watch(orderNotifierProvider).isLoading;
    final canCheckStatus = _awaitingPayment &&
        (order.paymentSessionRef.isNotEmpty || _checkoutOpened);

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
          if (canCheckStatus)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _pendingNote ??
                    'Once the buyer has completed payment on the payment '
                        'page, check the status to confirm the order.',
                key: const ValueKey('payment-status-note'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
              if (canCheckStatus)
                FilledButton.icon(
                  onPressed: busy ? null : _confirm,
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text("I've paid — check status"),
                ),
              if (_awaitingPayment)
                (canCheckStatus
                    ? OutlinedButton.icon(
                        onPressed: busy ? null : _pay,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open payment page'),
                      )
                    : FilledButton.icon(
                        onPressed: busy ? null : _pay,
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text(order.checkoutUrl.isEmpty
                            ? 'Pay now'
                            : 'Open payment page'),
                      )),
              if (_cancellable)
                TextButton.icon(
                  onPressed: busy ? null : _cancel,
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

  Future<void> _pay() async {
    try {
      final response =
          await ref.read(orderNotifierProvider.notifier).checkout(order.id);
      final url = response.checkoutUrl;
      if (url.isEmpty) {
        if (mounted) _toast(context, 'Payment page is not available yet.');
        return;
      }
      if (mounted) setState(() => _checkoutOpened = true);
      bool opened;
      try {
        opened = await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
      if (!opened && mounted) {
        await _copy(context, url);
      }
    } catch (e) {
      if (mounted) _toast(context, friendlyError(e), isError: true);
    }
  }

  /// Asks the backend to verify the checkout session. A session that has
  /// not completed yet is an expected outcome (FailedPrecondition), shown
  /// as guidance rather than as an error.
  Future<void> _confirm() async {
    try {
      final updated =
          await ref.read(orderNotifierProvider.notifier).confirmPayment(order.id);
      if (!mounted) return;
      final paid = updated.paymentStatus == PaymentStatus.PAYMENT_STATUS_PAID;
      setState(() => _pendingNote = paid ? null : kPaymentNotCompletedMessage);
      _toast(context,
          paid ? 'Payment confirmed.' : kPaymentNotCompletedMessage);
    } on ConnectException catch (e) {
      if (!mounted) return;
      if (e.code == Code.failedPrecondition) {
        setState(() => _pendingNote = kPaymentNotCompletedMessage);
        // The order may have moved on (e.g. paid via webhook): reload it.
        ref.invalidate(orderByIdProvider(order.id));
        _toast(context, kPaymentNotCompletedMessage);
      } else {
        _toast(context, friendlyError(e), isError: true);
      }
    } catch (e) {
      if (mounted) _toast(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _cancel() async {
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
    if (reason == null || !mounted) return;
    try {
      await ref
          .read(orderNotifierProvider.notifier)
          .cancel(order.id, reason: reason);
      if (mounted) _toast(context, 'Order cancelled.');
    } catch (e) {
      if (mounted) _toast(context, friendlyError(e), isError: true);
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

/// Shown when a payment status check finds the checkout not completed yet.
const String kPaymentNotCompletedMessage =
    "Payment hasn't completed yet. Finish paying on the payment page, "
    'then check again.';
