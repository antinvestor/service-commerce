import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';

/// A location tile for customers that wraps [AddressTile] from ui_profile,
/// adding optional delivery instructions.
class CustomerLocationTile extends StatelessWidget {
  const CustomerLocationTile({
    super.key,
    required this.address,
    this.deliveryInstructions = '',
    this.onTap,
  });

  final AddressObject address;

  /// Optional delivery-specific instructions (e.g. gate code, landmarks).
  final String deliveryInstructions;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddressTile(
          address: address,
          onTap: onTap,
          trailing: deliveryInstructions.isNotEmpty
              ? Tooltip(
                  message: deliveryInstructions,
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ),
        if (deliveryInstructions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 68, top: 4, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    deliveryInstructions,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
