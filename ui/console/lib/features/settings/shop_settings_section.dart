import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show PaymentPolicy, Shop;
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart'
    show PaymentPolicyEditor, validatePaymentPolicy;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/active_shop_provider.dart';
import '../../core/services/commerce_client_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/shop_switcher.dart';
import 'data/shop_providers.dart';
import 'webhook_settings.dart';

/// Settings panel body for the commerce shop the console operates on.
///
/// Shops are resolved via `ListShops` and offer:
/// - a shop selector when the operator can see several shops,
/// - an Edit action (`UpdateShop`) for the active shop,
/// - webhook URL and write-only secret settings,
/// - a read-only payment policy summary, and
/// - a Create action (`CreateShop`); the created shop becomes active.
class ShopSettingsSection extends ConsumerWidget {
  const ShopSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);
    final shopCount = ref.watch(shopListProvider).value?.length ?? 0;
    return shopAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ShopError(message: friendlyError(err)),
      data: (shop) => shop == null
          ? const _NoShop()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shopCount > 1) ...[
                  const ShopSwitcher(),
                  const SizedBox(height: 12),
                ],
                _ShopDetails(shop: shop),
              ],
            ),
    );
  }
}

class _ShopError extends StatelessWidget {
  const _ShopError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _NoShop extends ConsumerWidget {
  const _NoShop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(shopNotifierProvider).isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You don't have a shop yet. Create one to start selling.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        GradientButton(
          label: 'Create shop',
          icon: Icons.add_business_outlined,
          isLoading: saving,
          onPressed: saving ? null : () => _createShop(context, ref),
        ),
      ],
    );
  }
}

class _ShopDetails extends ConsumerWidget {
  const _ShopDetails({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(shopNotifierProvider).isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShopRow(label: 'Name', value: shop.name),
        _ShopRow(label: 'Slug', value: shop.slug),
        _ShopRow(
          label: 'Description',
          value: shop.description.isEmpty ? '—' : shop.description,
        ),
        _ShopRow(label: 'Status', value: shopStatusLabel(shop.status)),
        _ShopRow(label: 'Currency', value: shop.currency),
        _ShopRow(label: 'Seller contact', value: shop.contactId),
        _ShopRow(label: 'Return URL', value: shop.checkoutReturnUrl),
        _ShopRow(label: 'Shop ID', value: shop.id),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: saving ? null : () => _editShop(context, ref, shop),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit shop'),
            ),
            TextButton.icon(
              onPressed: saving ? null : () => _createShop(context, ref),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Create another shop'),
            ),
          ],
        ),
        const Divider(height: 32),
        _PaymentPolicySummary(shop: shop),
        const Divider(height: 32),
        WebhookSettingsSection(shop: shop),
      ],
    );
  }
}

/// Payment policy section: a summary of how buyers may pay, with an editor
/// for instalments, deposit and balance terms, and payment signals.
class _PaymentPolicySummary extends ConsumerWidget {
  const _PaymentPolicySummary({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saving = ref.watch(shopNotifierProvider).isLoading;
    return Column(
      key: const Key('payment-policy-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment policy',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final line in paymentPolicySummary(shop))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(line, style: theme.textTheme.bodyMedium),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('edit-payment-policy'),
          onPressed: saving ? null : () => _editPolicy(context, ref),
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Edit payment policy'),
        ),
      ],
    );
  }

  Future<void> _editPolicy(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_PolicyEdit>(
      context: context,
      builder: (_) => _PaymentPolicyDialog(
        initial: shop.hasPaymentPolicy() ? shop.paymentPolicy : null,
      ),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(shopNotifierProvider.notifier)
          .updatePaymentPolicy(id: shop.id, policy: result.policy);
      messenger.showSnackBar(
        const SnackBar(content: Text('Payment policy saved')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save the payment policy: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// The outcome of the policy dialog; a null [policy] means "pay in full".
class _PolicyEdit {
  const _PolicyEdit(this.policy);

  final PaymentPolicy? policy;
}

class _PaymentPolicyDialog extends StatefulWidget {
  const _PaymentPolicyDialog({required this.initial});

  final PaymentPolicy? initial;

  @override
  State<_PaymentPolicyDialog> createState() => _PaymentPolicyDialogState();
}

class _PaymentPolicyDialogState extends State<_PaymentPolicyDialog> {
  late PaymentPolicy? _policy = widget.initial;
  String? _error;

  void _save() {
    final error = validatePaymentPolicy(_policy);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final policy = _policy;
    Navigator.of(context).pop(
      _PolicyEdit(policy == null || !policy.allowInstalments ? null : policy),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment policy'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Applies to new orders. Products can override it, and '
                'orders already placed keep the policy they were placed with.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              PaymentPolicyEditor(
                initial: widget.initial,
                onChanged: (policy) => setState(() {
                  _policy = policy;
                  _error = null;
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-payment-policy'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the suggested default currency while showing a progress
/// dialog. Never throws; see [resolveDefaultCurrencySuggestion].
Future<DefaultCurrencySuggestion> _suggestCurrency(
  BuildContext context,
  WidgetRef ref,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  var dialogOpen = true;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  ).whenComplete(() => dialogOpen = false);
  final suggestion = await resolveDefaultCurrencySuggestion(
    ref.read(commerceServiceClientProvider),
  );
  if (dialogOpen) navigator.pop();
  return suggestion;
}

Future<void> _createShop(BuildContext context, WidgetRef ref) async {
  final suggestion = await _suggestCurrency(context, ref);
  if (!context.mounted) return;
  final values = await showEditDialog(
    context: context,
    title: 'Create shop',
    saveLabel: 'Create',
    fields: [
      const DialogField(
        key: 'name',
        label: 'Name',
        hint: 'e.g. Acacia Foods Storefront',
        required: true,
      ),
      const DialogField(
        key: 'slug',
        label: 'Slug',
        hint: 'e.g. acacia-foods',
        required: true,
      ),
      const DialogField(
        key: 'description',
        label: 'Description',
        type: DialogFieldType.textarea,
      ),
      DialogField(
        key: 'currency',
        label: 'Currency',
        hint: suggestion.hint,
        initialValue: suggestion.currency,
      ),
      const DialogField(
        key: 'contact_id',
        label: 'Seller contact',
        hint: 'Contact that receives order and payment alerts',
      ),
      const DialogField(
        key: 'checkout_return_url',
        label: 'Checkout return URL',
        hint: 'Where buyers land after paying; {order_id} is substituted',
      ),
    ],
  );
  if (values == null || !context.mounted) return;

  final name = (values['name'] ?? '').trim();
  final slug = (values['slug'] ?? '').trim();
  if (name.isEmpty || slug.isEmpty) {
    _showSnack(context, 'Name and slug are required.', isError: true);
    return;
  }
  // Empty lets the backend apply the same default ResolveDefaultCurrency
  // would have suggested.
  final currency = (values['currency'] ?? '').trim().toUpperCase();
  if (currency.isNotEmpty && currency.length != 3) {
    _showSnack(context, 'Currency must be a 3-letter code.', isError: true);
    return;
  }

  try {
    await ref
        .read(shopNotifierProvider.notifier)
        .create(
          name: name,
          slug: slug,
          description: (values['description'] ?? '').trim(),
          currency: currency,
          contactId: (values['contact_id'] ?? '').trim(),
          checkoutReturnUrl: (values['checkout_return_url'] ?? '').trim(),
        );
    if (context.mounted) _showSnack(context, 'Shop created.');
  } catch (e) {
    if (context.mounted) {
      _showSnack(context, friendlyError(e), isError: true);
    }
  }
}

Future<void> _editShop(BuildContext context, WidgetRef ref, Shop shop) async {
  final values = await showEditDialog(
    context: context,
    title: 'Edit shop',
    fields: [
      DialogField(
        key: 'name',
        label: 'Name',
        initialValue: shop.name,
        required: true,
      ),
      DialogField(
        key: 'description',
        label: 'Description',
        type: DialogFieldType.textarea,
        initialValue: shop.description,
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: shopStatusLabels,
        initialValue: shopStatusLabel(shop.status),
      ),
      DialogField(
        key: 'currency',
        label: 'Currency',
        hint: 'ISO 4217 code, e.g. KES',
        initialValue: shop.currency,
        required: true,
      ),
      DialogField(
        key: 'contact_id',
        label: 'Seller contact',
        hint: 'Contact that receives order and payment alerts',
        initialValue: shop.contactId,
      ),
      DialogField(
        key: 'checkout_return_url',
        label: 'Checkout return URL',
        hint: 'Where buyers land after paying; {order_id} is substituted',
        initialValue: shop.checkoutReturnUrl,
      ),
    ],
  );
  if (values == null || !context.mounted) return;

  final name = (values['name'] ?? '').trim();
  if (name.isEmpty) {
    _showSnack(context, 'Name is required.', isError: true);
    return;
  }
  final currency = (values['currency'] ?? '').trim().toUpperCase();
  if (currency.length != 3) {
    _showSnack(context, 'Currency must be a 3-letter code.', isError: true);
    return;
  }

  final statusLabel = values['status'] ?? '';
  final status = statusLabel.isEmpty
      ? shop.status
      : shopStatusFromLabel(statusLabel);

  try {
    await ref
        .read(shopNotifierProvider.notifier)
        .update(
          id: shop.id,
          name: name,
          description: (values['description'] ?? '').trim(),
          status: status,
          currency: currency,
          contactId: (values['contact_id'] ?? '').trim(),
          checkoutReturnUrl: (values['checkout_return_url'] ?? '').trim(),
        );
    if (context.mounted) _showSnack(context, 'Shop updated.');
  } catch (e) {
    if (context.mounted) {
      _showSnack(context, friendlyError(e), isError: true);
    }
  }
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ),
  );
}
