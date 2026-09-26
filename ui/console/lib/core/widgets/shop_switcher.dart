import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Shop, ShopStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/active_shop_provider.dart';
import '../theme/app_colors.dart';

/// Shows the active shop and, when the operator can see more than one,
/// lets them switch between shops.
///
/// - no shops yet: a "No shop yet" hint that opens [onCreateShop];
/// - one shop: its name;
/// - several shops: a menu listing every shop, the active one ticked.
class ShopSwitcher extends ConsumerWidget {
  const ShopSwitcher({super.key, this.onCreateShop});

  /// Called when the operator has no shop and taps the hint.
  final VoidCallback? onCreateShop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      color: AppColors.onSurfaceMuted,
    );
    final shopsAsync = ref.watch(shopListProvider);
    final shops = shopsAsync.value ?? const <Shop>[];
    final active = ref.watch(activeShopProvider);

    if (shops.isEmpty) {
      if (shopsAsync.isLoading) {
        return Text('Loading shops…', style: labelStyle);
      }
      if (shopsAsync.hasError) {
        return Text('Shops unavailable', style: labelStyle);
      }
      return TextButton.icon(
        onPressed: onCreateShop,
        icon: const Icon(Icons.add_business_outlined, size: 18),
        label: const Text('No shop yet — create one'),
      );
    }

    if (shops.length == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined,
              size: 18, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _label(shops.first),
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      key: const ValueKey('shop-switcher'),
      tooltip: 'Switch shop',
      initialValue: active?.id,
      onSelected: (id) =>
          ref.read(selectedShopIdProvider.notifier).select(id),
      itemBuilder: (context) => [
        for (final shop in shops)
          CheckedPopupMenuItem<String>(
            value: shop.id,
            checked: shop.id == active?.id,
            child: Text(
              shop.status == ShopStatus.SHOP_STATUS_ACTIVE
                  ? _label(shop)
                  : '${_label(shop)} (disabled)',
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined,
              size: 18, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              active == null ? 'Select a shop' : _label(active),
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceMuted),
        ],
      ),
    );
  }

  static String _label(Shop shop) => shop.name.isNotEmpty ? shop.name : shop.id;
}
