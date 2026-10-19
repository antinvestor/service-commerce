import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Largest `balance_due_days` the service accepts.
const maxBalanceDueDays = 3650;

/// Checks [policy] against the ranges the service enforces. Returns a
/// user-facing message for the first problem, or `null` when it is valid.
///
/// Callers that save a policy from [PaymentPolicyEditor] should run this
/// first and block the save on a non-null result.
String? validatePaymentPolicy(PaymentPolicy? policy) {
  if (policy == null || !policy.allowInstalments) return null;
  if (_percentError(policy.minDepositPercent) != null) {
    return 'Minimum deposit must be between 0 and 100%.';
  }
  if (_percentError(policy.minInstalmentPercent) != null) {
    return 'Minimum instalment must be between 0 and 100%.';
  }
  if (_daysError(policy.balanceDueDays) != null) {
    return 'Balance due days must be between 0 and $maxBalanceDueDays.';
  }
  if (_percentError(policy.fulfilAtPercent) != null) {
    return 'Fulfil at must be between 0 and 100%.';
  }
  for (final t in policy.signalThresholds) {
    if (t < 1 || t > 100) {
      return 'Signal thresholds must be between 1 and 100%.';
    }
  }
  return null;
}

/// One-line plain-language summary of [policy], e.g. for a detail page.
String describePaymentPolicy(PaymentPolicy policy) {
  if (!policy.allowInstalments) return 'Pay in full';
  final parts = <String>['Instalments allowed'];
  if (policy.minDepositPercent > 0) {
    parts.add('${policy.minDepositPercent}% deposit');
  }
  if (policy.minInstalmentPercent > 0) {
    parts.add('min ${policy.minInstalmentPercent}% per instalment');
  }
  parts.add(
    policy.balanceDueDays > 0
        ? 'balance due in ${policy.balanceDueDays} days'
        : 'no deadline',
  );
  parts.add(
    policy.fulfilAtPercent > 0 && policy.fulfilAtPercent < 100
        ? 'fulfil at ${policy.fulfilAtPercent}%'
        : 'fulfil when paid in full',
  );
  if (policy.signalThresholds.isNotEmpty) {
    parts.add(
      'signals at ${policy.signalThresholds.map((t) => '$t%').join(', ')}',
    );
  }
  if (policy.cancelWhenOverdue) parts.add('cancel when overdue');
  return parts.join(' · ');
}

String? _percentError(int value) =>
    value < 0 || value > 100 ? 'Enter 0 to 100' : null;

String? _daysError(int value) => value < 0 || value > maxBalanceDueDays
    ? 'Enter 0 to $maxBalanceDueDays'
    : null;

/// Edits a [PaymentPolicy]: whether buyers may pay in instalments and the
/// rules that apply when they do.
///
/// Every edit reports the resulting policy through [onChanged]; run
/// [validatePaymentPolicy] on it before saving. With [allowInherit] a switch
/// lets the policy be left unset (reported as `null`), meaning the shop's
/// policy applies.
///
/// [initial] is read once, like `TextFormField.initialValue`; give the
/// widget a new key to reset it to a different policy.
class PaymentPolicyEditor extends StatefulWidget {
  const PaymentPolicyEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.allowInherit = false,
    this.inheritLabel = 'Use the shop policy',
  });

  final PaymentPolicy? initial;
  final ValueChanged<PaymentPolicy?> onChanged;
  final bool allowInherit;
  final String inheritLabel;

  @override
  State<PaymentPolicyEditor> createState() => _PaymentPolicyEditorState();
}

class _PaymentPolicyEditorState extends State<PaymentPolicyEditor> {
  late bool _override;
  late bool _allowInstalments;
  late bool _cancelWhenOverdue;
  late List<int> _thresholds;
  late final TextEditingController _deposit;
  late final TextEditingController _instalment;
  late final TextEditingController _dueDays;
  late final TextEditingController _fulfilAt;
  final _thresholdInput = TextEditingController();
  String? _thresholdError;

  @override
  void initState() {
    super.initState();
    final p = widget.initial ?? PaymentPolicy();
    _override = !widget.allowInherit || widget.initial != null;
    _allowInstalments = p.allowInstalments;
    _cancelWhenOverdue = p.cancelWhenOverdue;
    _thresholds = _normalise(p.signalThresholds);
    _deposit = TextEditingController(text: '${p.minDepositPercent}');
    _instalment = TextEditingController(text: '${p.minInstalmentPercent}');
    _dueDays = TextEditingController(text: '${p.balanceDueDays}');
    _fulfilAt = TextEditingController(text: '${p.fulfilAtPercent}');
  }

  @override
  void dispose() {
    _deposit.dispose();
    _instalment.dispose();
    _dueDays.dispose();
    _fulfilAt.dispose();
    _thresholdInput.dispose();
    super.dispose();
  }

  static List<int> _normalise(Iterable<int> values) =>
      (values.where((v) => v >= 1 && v <= 100).toSet().toList()..sort());

  static int _read(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  PaymentPolicy? _current() {
    if (!_override) return null;
    if (!_allowInstalments) return PaymentPolicy(allowInstalments: false);
    return PaymentPolicy(
      allowInstalments: true,
      minDepositPercent: _read(_deposit),
      minInstalmentPercent: _read(_instalment),
      balanceDueDays: _read(_dueDays),
      fulfilAtPercent: _read(_fulfilAt),
      signalThresholds: _thresholds,
      cancelWhenOverdue: _cancelWhenOverdue,
    );
  }

  void _emit() => widget.onChanged(_current());

  void _update(VoidCallback change) {
    setState(change);
    _emit();
  }

  void _addThreshold() {
    final text = _thresholdInput.text.trim();
    if (text.isEmpty) return;
    final value = int.tryParse(text);
    if (value == null || value < 1 || value > 100) {
      setState(() => _thresholdError = 'Enter a whole number from 1 to 100');
      return;
    }
    _thresholdInput.clear();
    _update(() {
      _thresholdError = null;
      _thresholds = _normalise([..._thresholds, value]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helper = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.allowInherit)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Override the shop's payment policy"),
            subtitle: Text(
              _override
                  ? 'This product uses its own payment rules.'
                  : widget.inheritLabel,
            ),
            value: _override,
            onChanged: (v) => _update(() => _override = v),
          ),
        if (_override) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow instalments'),
            subtitle: const Text(
              'Buyers may pay in more than one payment instead of all at once.',
            ),
            value: _allowInstalments,
            onChanged: (v) => _update(() => _allowInstalments = v),
          ),
          if (_allowInstalments) ...[
            const SizedBox(height: 8),
            _NumberField(
              label: 'Minimum deposit (%)',
              helper:
                  'The first payment must be at least this share of the '
                  'order total. 0 accepts any amount.',
              controller: _deposit,
              error: _percentError(_read(_deposit)),
              onChanged: () => _update(() {}),
            ),
            _NumberField(
              label: 'Minimum instalment (%)',
              helper:
                  'Every later payment, except the one that clears the '
                  'balance, must be at least this share of the total.',
              controller: _instalment,
              error: _percentError(_read(_instalment)),
              onChanged: () => _update(() {}),
            ),
            _NumberField(
              label: 'Balance due (days)',
              helper:
                  'Days the buyer has to pay the rest after the first '
                  'payment. 0 means no deadline.',
              controller: _dueDays,
              error: _daysError(_read(_dueDays)),
              onChanged: () => _update(() {}),
            ),
            _NumberField(
              label: 'Fulfil at (%)',
              helper:
                  'Share that must be paid before the order can be '
                  'shipped or delivered. 0 means only when paid in full.',
              controller: _fulfilAt,
              error: _percentError(_read(_fulfilAt)),
              onChanged: () => _update(() {}),
            ),
            const SizedBox(height: 4),
            Text('Signal thresholds (%)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(
              'You get a signal (webhook, notification and order event) '
              'when the paid share crosses each of these marks.',
              style: helper,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final t in _thresholds)
                  InputChip(
                    label: Text('$t%'),
                    onDeleted: () => _update(() => _thresholds.remove(t)),
                    deleteButtonTooltipMessage: 'Remove $t%',
                  ),
                SizedBox(
                  width: 170,
                  child: TextField(
                    key: const ValueKey('payment-policy-threshold-input'),
                    controller: _thresholdInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'e.g. 50',
                      errorText: _thresholdError,
                      errorMaxLines: 2,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'Add threshold',
                        onPressed: _addThreshold,
                      ),
                    ),
                    onSubmitted: (_) => _addThreshold(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cancel when overdue'),
              subtitle: const Text(
                'When the balance deadline passes, cancel the order, put '
                'the stock back and record a refund of what was paid.',
              ),
              value: _cancelWhenOverdue,
              onChanged: (v) => _update(() => _cancelWhenOverdue = v),
            ),
          ] else
            Text('Buyers pay the full amount in one payment.', style: helper),
        ],
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.helper,
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  final String label;
  final String helper;
  final TextEditingController controller;
  final String? error;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          errorText: error,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
