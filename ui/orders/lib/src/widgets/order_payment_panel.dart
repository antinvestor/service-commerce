import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';
import 'order_payment_dialogs.dart';

/// Payment state and actions for one order.
///
/// Shows the total, what has been paid, the balance and its deadline, the
/// payment policy snapshotted on the order, and every instalment applied.
///
/// What is offered follows the order's state:
/// - money owed: Pay now (hosted checkout; with an instalment policy the
///   amount is asked for and validated against the policy), "I've paid —
///   check status" (verifies the session), Record payment (staff, offline
///   payments), Cancel;
/// - confirmed and unshipped: Cancel (records a refund of what was paid);
/// - anything else: read-only summary.
///
/// While money is owed the order is reloaded whenever the app regains
/// focus, so returning from the payment page shows the latest state without
/// a manual refresh.
class OrderPaymentPanel extends ConsumerStatefulWidget {
  const OrderPaymentPanel({
    super.key,
    required this.order,
    this.canRecordPayments = true,
  });

  final Order order;

  /// Offer "Record payment" for offline payments (needs `order_manage`).
  final bool canRecordPayments;

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

  InstalmentRules get _rules => InstalmentRules.fromOrder(order);

  /// Whether money is still owed and can be paid. Orders from before
  /// instalments carry no balance; they fall back to their status.
  bool get _payable {
    if (order.status == OrderStatus.ORDER_STATUS_CANCELLED) return false;
    if (order.hasBalance()) return _rules.balanceMinor > 0;
    return order.status == OrderStatus.ORDER_STATUS_PENDING_PAYMENT;
  }

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
    if (!mounted || !_payable) return;
    ref.invalidate(orderByIdProvider(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = ref.watch(orderNotifierProvider).isLoading;
    final rules = _rules;
    final payable = _payable;
    final canCheckStatus =
        payable && (order.paymentSessionRef.isNotEmpty || _checkoutOpened);
    final currency = rules.currencyCode;
    final unpaid = rules.paidMinor <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (order.hasTotal()) ...[
            _row(theme, 'Total', formatMinor(rules.totalMinor, currency)),
            _row(
              theme,
              'Amount paid',
              formatMinor(rules.paidMinor, currency),
              key: const ValueKey('payment-amount-paid'),
            ),
            _row(
              theme,
              'Balance',
              formatMinor(rules.balanceMinor, currency),
              key: const ValueKey('payment-balance'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        key: const ValueKey('payment-progress'),
                        value: rules.paidFraction,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(rules.paidFraction * 100).floor()}% paid',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (order.hasBalanceDueAt() && rules.balanceMinor > 0)
            _dueRow(theme, 'Balance due by', order.balanceDueAt.toDateTime()),
          if (order.hasPaymentDueAt() && unpaid && payable)
            _dueRow(theme, 'Pay by', order.paymentDueAt.toDateTime()),
          if (order.hasPaymentPolicy())
            _row(
              theme,
              'Payment terms',
              paymentPolicySummary(order.paymentPolicy),
            ),
          if (order.paymentId.isNotEmpty)
            _row(theme, 'Payment reference', order.paymentId),
          if (order.hasPaidAt())
            _row(theme, 'Paid at', formatDateTime(order.paidAt.toDateTime())),
          if (order.paymentSessionRef.isNotEmpty)
            _row(theme, 'Checkout session', order.paymentSessionRef),
          if (order.checkoutUrl.isNotEmpty && payable)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      order.checkoutUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (order.cancelReason.isNotEmpty)
            _row(theme, 'Cancelled', order.cancelReason),
          if (order.ledgerTransactionId.isNotEmpty)
            _row(theme, 'Ledger transaction', order.ledgerTransactionId),
          if (order.payments.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Payments (${order.payments.length})',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...order.payments.map((p) => OrderPaymentTile(payment: p)),
            const SizedBox(height: 12),
          ],
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
              if (payable && rules.allowsPartial) ...[
                (canCheckStatus
                    ? OutlinedButton.icon(
                        onPressed: busy ? null : _payInstalment,
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(unpaid ? 'Pay deposit' : 'Pay instalment'),
                      )
                    : FilledButton.icon(
                        onPressed: busy ? null : _payInstalment,
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(unpaid ? 'Pay deposit' : 'Pay instalment'),
                      )),
                if (order.checkoutUrl.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _open(order.checkoutUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open payment page'),
                  ),
              ] else if (payable)
                (canCheckStatus
                    ? OutlinedButton.icon(
                        onPressed: busy ? null : () => _pay(),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open payment page'),
                      )
                    : FilledButton.icon(
                        onPressed: busy ? null : () => _pay(),
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text(
                          order.checkoutUrl.isEmpty
                              ? 'Pay now'
                              : 'Open payment page',
                        ),
                      )),
              if (payable && widget.canRecordPayments)
                OutlinedButton.icon(
                  onPressed: busy ? null : _recordPayment,
                  icon: const Icon(Icons.point_of_sale_outlined, size: 18),
                  label: const Text('Record payment'),
                ),
              if (_cancellable)
                TextButton.icon(
                  onPressed: busy ? null : _cancel,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(
                    rules.paidMinor > 0 ||
                            order.paymentStatus ==
                                PaymentStatus.PAYMENT_STATUS_PAID
                        ? 'Cancel and refund'
                        : 'Cancel order',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dueRow(ThemeData theme, String label, DateTime due) {
    final overdue = due.isBefore(DateTime.now());
    return _row(
      theme,
      label,
      overdue ? '${formatDateTime(due)} (overdue)' : formatDateTime(due),
      color: overdue ? theme.colorScheme.error : null,
    );
  }

  Widget _row(
    ThemeData theme,
    String label,
    String value, {
    Key? key,
    Color? color,
  }) => Padding(
    key: key,
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );

  /// Starts hosted checkout for [amount] (null pays the whole balance) and
  /// opens the payment page, copying the link when it cannot be opened.
  Future<void> _pay({Money? amount}) async {
    try {
      final response = await ref
          .read(orderNotifierProvider.notifier)
          .checkout(order.id, amount: amount);
      final url = response.checkoutUrl;
      if (url.isEmpty) {
        if (mounted) _toast(context, 'Payment page is not available yet.');
        return;
      }
      if (mounted) setState(() => _checkoutOpened = true);
      if (mounted && response.hasAmount()) {
        _toast(
          context,
          'Payment page for ${formatMinor(moneyToMinor(response.amount), response.amount.currencyCode)}.',
        );
      }
      await _open(url);
    } catch (e) {
      if (mounted) _toast(context, paymentErrorMessage(e), isError: true);
    }
  }

  Future<void> _open(String url) async {
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      await _copy(context, url);
    }
  }

  /// Asks for the instalment amount, validated against the order's policy.
  /// Paying the whole balance sends no amount, so a live full-balance
  /// session is reused.
  Future<void> _payInstalment() async {
    final minor = await showInstalmentAmountDialog(context, order);
    if (minor == null || !mounted) return;
    final rules = _rules;
    await _pay(
      amount: minor >= rules.balanceMinor
          ? null
          : minorToMoney(minor, rules.currencyCode),
    );
  }

  Future<void> _recordPayment() async {
    final updated = await showRecordPaymentDialog(context, order);
    if (updated != null && mounted) _toast(context, 'Payment recorded.');
  }

  /// Asks the backend to verify the checkout session. A session that has
  /// not completed yet is an expected outcome (FailedPrecondition), shown
  /// as guidance rather than as an error.
  Future<void> _confirm() async {
    try {
      final updated = await ref
          .read(orderNotifierProvider.notifier)
          .confirmPayment(order.id);
      if (!mounted) return;
      final paid =
          updated.paymentStatus == PaymentStatus.PAYMENT_STATUS_PAID ||
          updated.paymentStatus == PaymentStatus.PAYMENT_STATUS_PARTIALLY_PAID;
      setState(() => _pendingNote = paid ? null : kPaymentNotCompletedMessage);
      _toast(
        context,
        paid ? 'Payment confirmed.' : kPaymentNotCompletedMessage,
      );
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
              child: const Text('Keep order'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Cancel order'),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}

/// Shown when a payment status check finds the checkout not completed yet.
const String kPaymentNotCompletedMessage =
    "Payment hasn't completed yet. Finish paying on the payment page, "
    'then check again.';

/// One applied payment: amount, how it was taken, its reference and when.
class OrderPaymentTile extends StatelessWidget {
  const OrderPaymentTile({super.key, required this.payment});

  final OrderPayment payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recorded =
        payment.source == OrderPaymentSource.ORDER_PAYMENT_SOURCE_RECORDED;
    final details = <String>[
      if (payment.reference.isNotEmpty) 'Ref ${payment.reference}',
      if (payment.hasPaidAt()) formatDateTime(payment.paidAt.toDateTime()),
      if (payment.recordedBy.isNotEmpty) 'by ${payment.recordedBy}',
    ];
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        recorded ? Icons.point_of_sale_outlined : Icons.credit_card,
        color: theme.colorScheme.primary,
      ),
      title: Row(
        children: [
          Text(
            formatMinor(
              moneyToMinor(payment.amount),
              payment.amount.currencyCode,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            recorded ? 'Recorded' : 'Checkout',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.isNotEmpty)
            Text(details.join(' · '), style: theme.textTheme.bodySmall),
          if (payment.note.isNotEmpty)
            Text(
              payment.note,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
