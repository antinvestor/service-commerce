import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';

/// Error text for a payment call. Policy and state rejections carry the
/// backend's own explanation (e.g. "deposit must be at least 30%"), which is
/// shown as is; other failures get the generic friendly message.
String paymentErrorMessage(Object error) {
  if (error is ConnectException &&
      error.message.isNotEmpty &&
      const {
        Code.invalidArgument,
        Code.failedPrecondition,
        Code.alreadyExists,
        Code.outOfRange,
      }.contains(error.code)) {
    return error.message;
  }
  return friendlyError(error);
}

/// Asks how much of [order]'s balance to pay now, validated against the
/// order's payment policy ([InstalmentRules]).
///
/// Returns the amount in minor units, or null when dismissed.
Future<int?> showInstalmentAmountDialog(BuildContext context, Order order) {
  return showDialog<int>(
    context: context,
    builder: (_) =>
        InstalmentAmountDialog(rules: InstalmentRules.fromOrder(order)),
  );
}

class InstalmentAmountDialog extends StatefulWidget {
  const InstalmentAmountDialog({super.key, required this.rules});

  final InstalmentRules rules;

  @override
  State<InstalmentAmountDialog> createState() => _InstalmentAmountDialogState();
}

class _InstalmentAmountDialogState extends State<InstalmentAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;

  InstalmentRules get rules => widget.rules;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: minorToInput(rules.minimumMinor));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(parseMinor(_amount.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = rules.currencyCode;
    return AlertDialog(
      title: Text(rules.nothingPaid ? 'Pay a deposit' : 'Pay an instalment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance: ${formatMinor(rules.balanceMinor, currency)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (rules.requiredPercent > 0)
              Text(
                '${rules.nothingPaid ? 'Deposit' : 'Instalment'} of at least '
                '${rules.requiredPercent}% '
                '(${formatMinor(rules.minimumMinor, currency)}), '
                'or the whole balance.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('instalment-amount'),
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount to pay now',
                suffixText: currency,
              ),
              validator: rules.validateInput,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Minimum'),
                  onPressed: () =>
                      _amount.text = minorToInput(rules.minimumMinor),
                ),
                ActionChip(
                  label: const Text('Whole balance'),
                  onPressed: () =>
                      _amount.text = minorToInput(rules.balanceMinor),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}

/// Records a payment the shop took offline (cash, transfer, card terminal)
/// against [order] via RecordOrderPayment.
///
/// [initialMinor] pre-fills the amount; it defaults to the balance. Returns
/// the updated order, or null when dismissed.
Future<Order?> showRecordPaymentDialog(
  BuildContext context,
  Order order, {
  int? initialMinor,
}) {
  return showDialog<Order>(
    context: context,
    builder: (_) =>
        RecordPaymentDialog(order: order, initialMinor: initialMinor),
  );
}

class RecordPaymentDialog extends ConsumerStatefulWidget {
  const RecordPaymentDialog({
    super.key,
    required this.order,
    this.initialMinor,
  });

  final Order order;
  final int? initialMinor;

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  final _reference = TextEditingController();
  final _note = TextEditingController();
  bool _submitting = false;
  String? _error;

  late final InstalmentRules _rules = InstalmentRules.fromOrder(widget.order);

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMinor ?? _rules.balanceMinor;
    _amount = TextEditingController(
      text: initial > 0 ? minorToInput(initial) : '',
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final minor = parseMinor(value);
    if (minor == null) return 'Enter an amount such as 1250.00';
    if (minor <= 0) return 'Enter an amount greater than zero';
    if (_rules.balanceMinor > 0 && minor > _rules.balanceMinor) {
      return 'Cannot exceed the balance of '
          '${formatMinor(_rules.balanceMinor, _rules.currencyCode)}';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(orderNotifierProvider.notifier)
          .recordPayment(
            widget.order.id,
            amount: minorToMoney(
              parseMinor(_amount.text)!,
              _rules.currencyCode,
            ),
            reference: _reference.text.trim(),
            note: _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(order);
    } catch (e) {
      if (mounted) setState(() => _error = paymentErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Record payment'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance: ${formatMinor(_rules.balanceMinor, _rules.currencyCode)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('record-amount'),
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  suffixText: _rules.currencyCode,
                ),
                validator: _validateAmount,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('record-reference'),
                controller: _reference,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  helperText: 'Receipt or transaction number, unique per order',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Reference is required'
                    : null,
              ),
              TextFormField(
                key: const ValueKey('record-note'),
                controller: _note,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    key: const ValueKey('record-error'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Record payment'),
        ),
      ],
    );
  }
}
