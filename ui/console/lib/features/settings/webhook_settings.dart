import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Shop;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'data/shop_providers.dart';

/// Changes entered in [WebhookSettingsDialog].
class WebhookEdit {
  const WebhookEdit({required this.url, this.secret});

  /// The webhook URL; empty disables delivery.
  final String url;

  /// A new secret to store, or `null` to keep the current one.
  final String? secret;
}

/// Shows the shop's webhook settings and lets staff change the URL and
/// set, replace or clear the write-only signing secret.
class WebhookSettingsSection extends ConsumerWidget {
  const WebhookSettingsSection({required this.shop, super.key});

  final Shop shop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saving = ref.watch(shopNotifierProvider).isLoading;
    final secretSet = shop.webhookSecretSet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Order events are POSTed here, signed with HMAC-SHA256 of '
          '"<X-Commerce-Timestamp>.<body>" using the secret '
          '(X-Commerce-Signature). A secret is required.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 8),
        _Row(
          label: 'URL',
          value: shop.webhookUrl.isEmpty ? 'Not set' : shop.webhookUrl,
        ),
        _Row(
          label: 'Secret',
          value: secretSet ? 'Secret set' : 'No secret',
          icon: secretSet ? Icons.lock_outline : Icons.lock_open_outlined,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: saving ? null : () => _editWebhook(context, ref),
              icon: const Icon(Icons.webhook_outlined),
              label: Text(
                shop.webhookUrl.isEmpty && !secretSet
                    ? 'Set up webhook'
                    : 'Edit webhook',
              ),
            ),
            if (secretSet)
              TextButton.icon(
                onPressed: saving ? null : () => _clearSecret(context, ref),
                icon: const Icon(Icons.key_off_outlined),
                label: const Text('Clear secret'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _editWebhook(BuildContext context, WidgetRef ref) async {
    final edit = await showDialog<WebhookEdit>(
      context: context,
      builder: (_) => WebhookSettingsDialog(
        initialUrl: shop.webhookUrl,
        secretSet: shop.webhookSecretSet,
      ),
    );
    if (edit == null || !context.mounted) return;

    final urlChanged = edit.url != shop.webhookUrl;
    if (!urlChanged && edit.secret == null) {
      _snack(context, 'No changes to save.');
      return;
    }
    try {
      await ref
          .read(shopNotifierProvider.notifier)
          .updateWebhook(
            id: shop.id,
            url: urlChanged ? edit.url : null,
            secret: edit.secret,
          );
      if (context.mounted) _snack(context, 'Webhook updated.');
    } catch (e) {
      if (context.mounted) _snack(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _clearSecret(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear webhook secret?'),
        content: const Text(
          'Webhook deliveries will no longer be signed until a new secret '
          'is set.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear secret'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(shopNotifierProvider.notifier)
          .updateWebhook(id: shop.id, secret: '');
      if (context.mounted) _snack(context, 'Webhook secret cleared.');
    } catch (e) {
      if (context.mounted) _snack(context, friendlyError(e), isError: true);
    }
  }
}

/// Dialog for the webhook URL (https only) and an optional new secret.
///
/// Pops a [WebhookEdit] on save, or `null` on cancel. A blank secret field
/// keeps the stored secret.
class WebhookSettingsDialog extends StatefulWidget {
  const WebhookSettingsDialog({
    required this.initialUrl,
    required this.secretSet,
    super.key,
  });

  final String initialUrl;
  final bool secretSet;

  @override
  State<WebhookSettingsDialog> createState() => _WebhookSettingsDialogState();
}

class _WebhookSettingsDialogState extends State<WebhookSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url = TextEditingController(
    text: widget.initialUrl,
  );
  final _secret = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _url.dispose();
    _secret.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final secret = _secret.text.trim();
    Navigator.of(context).pop(
      WebhookEdit(
        url: _url.text.trim(),
        secret: secret.isEmpty ? null : secret,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Webhook'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('webhook-url'),
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL',
                  hintText: 'https://example.com/hooks/commerce',
                  helperText: 'https only. Leave empty to stop deliveries.',
                ),
                validator: (v) => validateWebhookUrl(v ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('webhook-secret'),
                controller: _secret,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: widget.secretSet
                      ? 'Replace secret'
                      : 'Signing secret',
                  helperText: widget.secretSet
                      ? 'A secret is set. Leave blank to keep it.'
                      : 'Leave blank to send unsigned deliveries.',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show' : 'Hide',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

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
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.onSurfaceMuted),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

void _snack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ),
  );
}
