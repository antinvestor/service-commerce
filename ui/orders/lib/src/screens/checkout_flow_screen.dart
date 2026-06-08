import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../widgets/checkout_button.dart';

/// Multi-step checkout wizard.
///
/// Steps:
/// 1. Select customer ([CustomerSearchSelect])
/// 2. Add products ([ProductGrid] / [VariantSelector])
/// 3. Review cart
/// 4. Payment method
/// 5. Confirm
class CheckoutFlowScreen extends ConsumerStatefulWidget {
  const CheckoutFlowScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<CheckoutFlowScreen> createState() =>
      _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends ConsumerState<CheckoutFlowScreen> {
  int _step = 0;
  ProfileObject? _selectedCustomer;
  final List<_CartItem> _cartItems = [];
  String _paymentMethod = 'cash';
  bool _submitting = false;

  static const _stepLabels = [
    'Customer',
    'Products',
    'Review',
    'Payment',
    'Confirm',
  ];

  void _addToCart(ProductVariant variant) {
    setState(() {
      final existing =
          _cartItems.indexWhere((i) => i.variantId == variant.id);
      if (existing >= 0) {
        _cartItems[existing] = _cartItems[existing].incrementQuantity();
      } else {
        _cartItems.add(_CartItem(
          variantId: variant.id,
          name: variant.name.isNotEmpty ? variant.name : variant.sku,
          sku: variant.sku,
          quantity: 1,
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  Future<void> _placeOrder() async {
    if (_selectedCustomer == null || _cartItems.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final request = CreateOrderRequest()
        ..shopId = widget.shopId
        ..profileId = _selectedCustomer!.id
        ..contactId = _selectedCustomer!.id
        ..addressId = _selectedCustomer!.id;

      for (final item in _cartItems) {
        request.lines.add(CreateOrderLine()
          ..variantId = item.variantId
          ..quantity = Int64(item.quantity));
      }

      final notifier = ref.read(orderNotifierProvider.notifier);
      await notifier.createOrder(request);
      ref.invalidate(orderListProvider(widget.shopId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully')),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _canAdvance => switch (_step) {
        0 => _selectedCustomer != null,
        1 => _cartItems.isNotEmpty,
        2 => true,
        3 => true,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/orders'),
                ),
                const SizedBox(width: 8),
                Icon(Icons.shopping_cart_checkout,
                    size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Checkout',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stepper indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_stepLabels.length, (i) {
                final isActive = i == _step;
                final isDone = i < _step;
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isDone
                            ? theme.colorScheme.primary
                            : isActive
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        child: isDone
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text('${i + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme
                                          .colorScheme.onSurfaceVariant,
                                )),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: switch (_step) {
                0 => _StepCustomer(
                    selected: _selectedCustomer,
                    onSelected: (p) =>
                        setState(() => _selectedCustomer = p),
                  ),
                1 => _StepProducts(
                    shopId: widget.shopId,
                    cartItems: _cartItems,
                    onAddVariant: _addToCart,
                    onRemove: _removeFromCart,
                  ),
                2 => _StepReview(cartItems: _cartItems),
                3 => _StepPayment(
                    method: _paymentMethod,
                    onChanged: (m) =>
                        setState(() => _paymentMethod = m),
                  ),
                4 => _StepConfirm(
                    customer: _selectedCustomer,
                    cartItems: _cartItems,
                    paymentMethod: _paymentMethod,
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                if (_step < 4)
                  FilledButton(
                    onPressed:
                        _canAdvance ? () => setState(() => _step++) : null,
                    child: const Text('Next'),
                  ),
                if (_step == 4)
                  CheckoutButton(
                    onPressed: _placeOrder,
                    isLoading: _submitting,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Step Widgets -----

class _StepCustomer extends StatelessWidget {
  const _StepCustomer({this.selected, required this.onSelected});

  final ProfileObject? selected;
  final ValueChanged<ProfileObject> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Customer',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        CustomerSearchSelect(onSelected: onSelected),
        if (selected != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary),
            ),
            child: ListTile(
              leading: Icon(Icons.person,
                  color: theme.colorScheme.primary),
              title: Text(profileName(selected!)),
              subtitle: Text(selected!.id,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontFamily: 'monospace')),
              trailing: const Icon(Icons.check_circle,
                  color: Colors.green),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepProducts extends StatelessWidget {
  const _StepProducts({
    required this.shopId,
    required this.cartItems,
    required this.onAddVariant,
    required this.onRemove,
  });

  final String shopId;
  final List<_CartItem> cartItems;
  final ValueChanged<ProductVariant> onAddVariant;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product picker
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Products',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: ProductGrid(
                  shopId: shopId,
                  onProductTap: (product) {
                    _showVariantPicker(context, product);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Cart summary
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cart (${cartItems.length})',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Text('No items yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                            dense: true,
                            title: Text(item.name),
                            subtitle: Text('x${item.quantity}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              onPressed: () => onRemove(index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVariantPicker(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            VariantSelector(
              variants: const [], // Variants loaded from product detail
              onSelected: (variant) {
                onAddVariant(variant);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a product to select a variant to add.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepReview extends StatelessWidget {
  const _StepReview({required this.cartItems});

  final List<_CartItem> cartItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Order',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: cartItems.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ListTile(
                leading: Icon(Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary),
                title: Text(item.name),
                subtitle: item.sku.isNotEmpty ? Text('SKU: ${item.sku}') : null,
                trailing: Text('x${item.quantity}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StepPayment extends StatelessWidget {
  const _StepPayment({required this.method, required this.onChanged});

  final String method;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: method,
          onChanged: (v) => onChanged(v ?? method),
          child: Column(
            children: const [
              RadioListTile<String>(
                title: Text('Cash'),
                value: 'cash',
              ),
              RadioListTile<String>(
                title: Text('Mobile Money'),
                value: 'mobile_money',
              ),
              RadioListTile<String>(
                title: Text('Credit'),
                value: 'credit',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepConfirm extends StatelessWidget {
  const _StepConfirm({
    this.customer,
    required this.cartItems,
    required this.paymentMethod,
  });

  final ProfileObject? customer;
  final List<_CartItem> cartItems;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Order',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _ConfirmRow(label: 'Customer', value: customer != null ? profileName(customer!) : 'None'),
        _ConfirmRow(
            label: 'Items', value: '${cartItems.length} line items'),
        _ConfirmRow(
          label: 'Total qty',
          value:
              '${cartItems.fold<int>(0, (s, i) => s + i.quantity)}',
        ),
        _ConfirmRow(label: 'Payment', value: paymentMethod),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CartItem {
  const _CartItem({
    required this.variantId,
    required this.name,
    this.sku = '',
    required this.quantity,
  });

  final String variantId;
  final String name;
  final String sku;
  final int quantity;

  _CartItem incrementQuantity() =>
      _CartItem(variantId: variantId, name: name, sku: sku, quantity: quantity + 1);
}
