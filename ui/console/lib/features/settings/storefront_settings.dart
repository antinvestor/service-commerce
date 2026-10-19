import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Shop, ShopStatus;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'data/shop_providers.dart';

/// Opens or closes the shop's public storefront and shows its address.
///
/// The storefront is a page commerce serves itself: anyone with the link
/// can browse the shop's active products and pay through hosted checkout
/// without an account.
class StorefrontSettingsSection extends ConsumerWidget {
  const StorefrontSettingsSection({required this.shop, super.key});

  final Shop shop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saving = ref.watch(shopNotifierProvider).isLoading;
    final open = shop.publicStorefront;
    final active = shop.status == ShopStatus.SHOP_STATUS_ACTIVE;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('storefront-switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Public storefront',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Anyone with the link can see your active products and pay '
            'online without an account.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          value: open,
          onChanged: saving ? null : (value) => _toggle(context, ref, value),
        ),
        if (open && !active)
          Text(
            'The shop is not active, so the page shows as not found.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        if (open && shop.storefrontUrl.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  shop.storefrontUrl,
                  key: const Key('storefront-url'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                tooltip: 'Copy link',
                icon: const Icon(Icons.copy_outlined),
                onPressed: () => _copy(context),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool open) async {
    try {
      await ref
          .read(shopNotifierProvider.notifier)
          .updateStorefront(id: shop.id, enabled: open);
      if (context.mounted) {
        _snack(context, open ? 'Storefront is open.' : 'Storefront closed.');
      }
    } catch (e) {
      if (context.mounted) _snack(context, friendlyError(e), isError: true);
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: shop.storefrontUrl));
    if (context.mounted) _snack(context, 'Link copied.');
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
