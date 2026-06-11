import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Shop;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/tenant_context_provider.dart';
import '../../core/theme/app_colors.dart';
import 'data/shop_providers.dart';

/// Settings panel body for the commerce shop bound to the active tenant
/// scope.
///
/// Resolves the shop via `GetShop` and offers:
/// - an Edit action (`UpdateShop`) when a shop exists, and
/// - a Create action (`CreateShop`) when none exists yet.
class ShopSettingsSection extends ConsumerWidget {
  const ShopSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(tenantScopeProvider);
    if (scope.shopId.isEmpty) {
      return Text(
        'Select an organization to manage its shop.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final shopAsync = ref.watch(currentShopProvider);
    return shopAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ShopError(message: friendlyError(err)),
      data: (shop) =>
          shop == null ? const _NoShop() : _ShopDetails(shop: shop),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
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
          'No shop is provisioned for this scope yet.',
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
        _ShopRow(label: 'Shop ID', value: shop.id),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: saving ? null : () => _editShop(context, ref, shop),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit shop'),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
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

Future<void> _createShop(BuildContext context, WidgetRef ref) async {
  final values = await showEditDialog(
    context: context,
    title: 'Create shop',
    saveLabel: 'Create',
    fields: const [
      DialogField(
        key: 'name',
        label: 'Name',
        hint: 'e.g. Acacia Foods Storefront',
        required: true,
      ),
      DialogField(
        key: 'slug',
        label: 'Slug',
        hint: 'e.g. acacia-foods',
        required: true,
      ),
      DialogField(
        key: 'description',
        label: 'Description',
        type: DialogFieldType.textarea,
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

  try {
    await ref.read(shopNotifierProvider.notifier).create(
          name: name,
          slug: slug,
          description: (values['description'] ?? '').trim(),
        );
    if (context.mounted) _showSnack(context, 'Shop created.');
  } catch (e) {
    if (context.mounted) {
      _showSnack(context, friendlyError(e), isError: true);
    }
  }
}

Future<void> _editShop(
  BuildContext context,
  WidgetRef ref,
  Shop shop,
) async {
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
    ],
  );
  if (values == null || !context.mounted) return;

  final name = (values['name'] ?? '').trim();
  if (name.isEmpty) {
    _showSnack(context, 'Name is required.', isError: true);
    return;
  }

  final statusLabel = values['status'] ?? '';
  final status = statusLabel.isEmpty
      ? shop.status
      : shopStatusFromLabel(statusLabel);

  try {
    await ref.read(shopNotifierProvider.notifier).update(
          id: shop.id,
          name: name,
          description: (values['description'] ?? '').trim(),
          status: status,
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
