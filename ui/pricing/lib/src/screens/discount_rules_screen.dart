import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_core/permissions/permission_guard.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../widgets/discount_rule_card.dart';
import '../widgets/pricing_section_nav.dart';
import 'discount_rule_form.dart';

/// Screen listing discount rules for a shop, with approval of rules that
/// require it.
class DiscountRulesScreen extends ConsumerStatefulWidget {
  const DiscountRulesScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<DiscountRulesScreen> createState() =>
      _DiscountRulesScreenState();
}

class _DiscountRulesScreenState extends ConsumerState<DiscountRulesScreen> {
  final Set<String> _approving = {};

  String get shopId => widget.shopId;

  Future<void> _approve(DiscountRule rule) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Approve Discount',
      message:
          'Approve "${rule.name.isNotEmpty ? rule.name : rule.id}"? '
          'Once approved it is applied automatically when its conditions '
          'match.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _approving.add(rule.id));
    try {
      await ref.read(pricingNotifierProvider.notifier).approveDiscount(rule.id);
      ref.invalidate(discountRuleListProvider(shopId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Discount approved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${friendlyError(e)}')));
      }
    } finally {
      if (mounted) setState(() => _approving.remove(rule.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncRules = ref.watch(discountRuleListProvider(shopId));
    final canManage = ref.watch(hasPermissionProvider('discount_manage'));
    final canApprove = ref.watch(hasPermissionProvider('discount_approve'));

    return Scaffold(
      floatingActionButton: PermissionGuard(
        permissions: const {'discount_manage'},
        child: FloatingActionButton.extended(
          onPressed: () =>
              showDiscountRuleForm(context: context, ref: ref, shopId: shopId),
          icon: const Icon(Icons.add),
          label: const Text('New Discount'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: PricingSectionNav(current: PricingSection.discounts),
          ),
          Expanded(
            child: asyncRules.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load discount rules',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      friendlyError(error),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              data: (rules) {
                if (rules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(
                            120,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No discount rules yet',
                          style: theme.textTheme.bodyLarge,
                        ),
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
                          Icon(
                            Icons.discount_outlined,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Discount Rules',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${rules.length} rules',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...rules.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DiscountRuleCard(
                            rule: r,
                            approving: _approving.contains(r.id),
                            onApprove: canApprove ? () => _approve(r) : null,
                            onTap: !canManage
                                ? null
                                : () => showDiscountRuleForm(
                                    context: context,
                                    ref: ref,
                                    shopId: shopId,
                                    existing: r,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
