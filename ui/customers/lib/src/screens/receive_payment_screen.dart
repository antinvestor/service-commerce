import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/customer_providers.dart';

/// Payment method options.
enum PaymentMethod { cash, mobileMoney, bankTransfer, cheque }

/// Screen to receive a payment from a customer.
///
/// Includes amount input, payment method selector, and confirmation.
class ReceivePaymentScreen extends ConsumerStatefulWidget {
  const ReceivePaymentScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<ReceivePaymentScreen> createState() =>
      _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends ConsumerState<ReceivePaymentScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String _methodLabel(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.bankTransfer => 'Bank Transfer',
      PaymentMethod.cheque => 'Cheque',
    };
  }

  IconData _methodIcon(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.mobileMoney => Icons.phone_android_outlined,
      PaymentMethod.bankTransfer => Icons.account_balance_outlined,
      PaymentMethod.cheque => Icons.description_outlined,
    };
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Placeholder: in production this would call a payment RPC.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Payment of ${amount.toStringAsFixed(2)} recorded'),
      ),
    );
    context.go('/customers/${widget.customerId}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncCustomer = ref.watch(customerByIdProvider(widget.customerId));

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.payment,
                    size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receive Payment',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/customers/${widget.customerId}'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer info
            asyncCustomer.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Customer: ${friendlyError(e)}'),
              data: (profile) {
                final name = profileName(profile);
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ProfileAvatar(
                          profileId: profile.id,
                          name: name,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                              Text(profile.id,
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Amount input
            Text('Amount',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 24),

            // Payment method selector
            Text('Payment Method',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((method) {
                final selected = _selectedMethod == method;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedMethod = method),
                  avatar: Icon(_methodIcon(method), size: 18),
                  label: Text(_methodLabel(method)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reference
            Text('Reference (optional)',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                hintText: 'Transaction reference or receipt number',
                isDense: true,
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                    _isSubmitting ? 'Recording...' : 'Record Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
