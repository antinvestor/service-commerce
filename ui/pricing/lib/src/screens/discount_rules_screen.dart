import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../widgets/discount_rule_card.dart';
import 'discount_rule_form.dart';

/// Screen listing discount rules for a shop.
class DiscountRulesScreen extends ConsumerWidget {
  const DiscountRulesScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncRules = ref.watch(discountRuleListProvider(shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDiscountRuleForm(
          context: context,
          ref: ref,
          shopId: shopId,
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Discount'),
      ),
      body: asyncRules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load discount rules',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.discount_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha(120)),
                  const SizedBox(height: 12),
                  Text('No discount rules yet',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.discount_outlined,
                        size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discount Rules',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${rules.length} rules',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme
                                      .colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...rules.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DiscountRuleCard(
                        rule: r,
                        onTap: () => showDiscountRuleForm(
                          context: context,
                          ref: ref,
                          shopId: shopId,
                          existing: r,
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
