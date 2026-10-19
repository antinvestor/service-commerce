import 'dart:math';

import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';
import '../widgets/checkout_button.dart';
import '../widgets/order_payment_dialogs.dart';

/// How the back office takes payment for an order it places.
enum CheckoutPaymentMethod {
  /// Taken at the counter; recorded against the order as an offline payment.
  cash('Cash', 'Record the cash received against the order', false),

  /// Paid by the buyer on the hosted payment page.
  mobileMoney('Mobile Money', 'Send the buyer a payment link', true),

  /// Paid by card on the hosted payment page.
  card('Card', 'Open the hosted card payment page', true),

  /// Nothing is collected now; the order stays with its balance owed.
  payLater('Pay later', 'Leave the balance owed on the order', false);

  const CheckoutPaymentMethod(this.label, this.hint, this.online);

  final String label;
  final String hint;

  /// Paid through hosted checkout (CheckoutOrder).
  final bool online;
}

/// A fresh idempotency key for one order placement.
String _newIdempotencyKey() {
  final random = Random.secure();
  final suffix = List.generate(
    8,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  return 'bo-${DateTime.now().microsecondsSinceEpoch}-$suffix';
}

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
  ConsumerState<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends ConsumerState<CheckoutFlowScreen> {
  int _step = 0;
  ProfileObject? _selectedCustomer;
  String? _contactId;
  String? _addressId;
  final List<_CartItem> _cartItems = [];
  CheckoutPaymentMethod _paymentMethod = CheckoutPaymentMethod.cash;
  bool _submitting = false;

  /// Idempotency key for this wizard's order. It is kept across retries of
  /// the same order so a double submit cannot place two orders, and renewed
  /// when the customer or cart changes, which makes it a different order.
  String _idempotencyKey = _newIdempotencyKey();

  void _orderChanged() => _idempotencyKey = _newIdempotencyKey();

  void _selectCustomer(ProfileObject profile) {
    setState(() {
      _selectedCustomer = profile;
      _contactId = _defaultContactId(profile);
      _addressId = profile.addresses.isNotEmpty
          ? profile.addresses.first.id
          : null;
      _orderChanged();
    });
  }

  /// The customer's verified contact if any, else their first contact.
  static String? _defaultContactId(ProfileObject profile) {
    if (profile.contacts.isEmpty) return null;
    final verified = profile.contacts.where((c) => c.verified);
    return (verified.isNotEmpty ? verified.first : profile.contacts.first).id;
  }

  static const _stepLabels = [
    'Customer',
    'Products',
    'Review',
    'Payment',
    'Confirm',
  ];

  void _addToCart(ProductVariant variant) {
    setState(() {
      _orderChanged();
      final existing = _cartItems.indexWhere((i) => i.variantId == variant.id);
      if (existing >= 0) {
        _cartItems[existing] = _cartItems[existing].incrementQuantity();
      } else {
        _cartItems.add(
          _CartItem(
            variantId: variant.id,
            name: variant.name.isNotEmpty ? variant.name : variant.sku,
            sku: variant.sku,
            quantity: 1,
          ),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _orderChanged();
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedCustomer == null || _cartItems.isEmpty) return;

    setState(() => _submitting = true);
    Order order;
    try {
      final request = CreateOrderRequest()
        ..idempotencyKey = _idempotencyKey
        ..shopId = widget.shopId
        ..profileId = _selectedCustomer!.id;
      final contactId = _contactId;
      if (contactId != null && contactId.isNotEmpty) {
        request.contactId = contactId;
      }
      final addressId = _addressId;
      if (addressId != null && addressId.isNotEmpty) {
        request.addressId = addressId;
      }

      for (final item in _cartItems) {
        request.lines.add(
          CreateOrderLine()
            ..variantId = item.variantId
            ..quantity = Int64(item.quantity),
        );
      }

      final notifier = ref.read(orderNotifierProvider.notifier);
      order = await notifier.createOrder(request);
      ref.invalidate(orderListProvider(widget.shopId));
      ref.invalidate(orderListControllerProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${paymentErrorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully')));
    await _collectPayment(order);
    if (!mounted) return;
    setState(() => _submitting = false);
    context.go('/orders/${order.id}');
  }

  /// Applies the chosen payment method to the placed order: hosted checkout
  /// for the full balance (online), the Record payment dialog prefilled
  /// with the total (cash), or nothing (pay later). A failure here leaves
  /// the order placed; payment can be retried from the order.
  Future<void> _collectPayment(Order order) async {
    switch (_paymentMethod) {
      case CheckoutPaymentMethod.cash:
        final total = order.hasBalance() ? order.balance : order.total;
        await showRecordPaymentDialog(
          context,
          order,
          initialMinor: moneyToMinor(total),
        );
      case CheckoutPaymentMethod.mobileMoney:
      case CheckoutPaymentMethod.card:
        try {
          final response = await ref
              .read(orderNotifierProvider.notifier)
              .checkout(order.id);
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            builder: (_) => _CheckoutLinkDialog(response: response),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order placed, but the payment page could not '
                  'be created: ${paymentErrorMessage(e)}',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      case CheckoutPaymentMethod.payLater:
        break;
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
                Icon(
                  Icons.shopping_cart_checkout,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Checkout',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${i + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
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
                  onSelected: _selectCustomer,
                  contactId: _contactId,
                  addressId: _addressId,
                  onContactChanged: (id) => setState(() {
                    _contactId = id;
                    _orderChanged();
                  }),
                  onAddressChanged: (id) => setState(() {
                    _addressId = id;
                    _orderChanged();
                  }),
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
                  onChanged: (m) => setState(() => _paymentMethod = m),
                ),
                4 => _StepConfirm(
                  customer: _selectedCustomer,
                  cartItems: _cartItems,
                  paymentMethod: _paymentMethod.label,
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
                    onPressed: _canAdvance
                        ? () => setState(() => _step++)
                        : null,
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
  const _StepCustomer({
    this.selected,
    required this.onSelected,
    this.contactId,
    this.addressId,
    required this.onContactChanged,
    required this.onAddressChanged,
  });

  final ProfileObject? selected;
  final ValueChanged<ProfileObject> onSelected;
  final String? contactId;
  final String? addressId;
  final ValueChanged<String?> onContactChanged;
  final ValueChanged<String?> onAddressChanged;

  static String _addressLabel(AddressObject a) {
    final parts = [
      a.name,
      a.house,
      a.street,
      a.area,
      a.city,
      a.country,
    ].where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? a.id : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Customer',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
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
              leading: Icon(Icons.person, color: theme.colorScheme.primary),
              title: Text(profileName(selected!)),
              subtitle: Text(
                selected!.id,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          if (selected!.contacts.isEmpty)
            Text(
              'This customer has no contact on file; add one to their '
              'profile so the order can reach them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else
            DropdownButtonFormField<String>(
              key: ValueKey('checkout-contact-${selected!.id}'),
              initialValue: contactId,
              decoration: const InputDecoration(labelText: 'Contact'),
              items: selected!.contacts
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.detail.isNotEmpty ? c.detail : c.id),
                    ),
                  )
                  .toList(),
              onChanged: onContactChanged,
            ),
          const SizedBox(height: 12),
          if (selected!.addresses.isEmpty)
            Text(
              'This customer has no address on file; add one to their '
              'profile for delivery.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else
            DropdownButtonFormField<String>(
              key: ValueKey('checkout-address-${selected!.id}'),
              initialValue: addressId,
              decoration: const InputDecoration(labelText: 'Address'),
              items: selected!.addresses
                  .map(
                    (a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        _addressLabel(a),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onAddressChanged,
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
              Text(
                'Add Products',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
              Text(
                'Cart (${cartItems.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Text(
                          'No items yet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
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
            Text(product.name, style: Theme.of(context).textTheme.titleMedium),
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
        Text(
          'Review Order',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: cartItems.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ListTile(
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(item.name),
                subtitle: item.sku.isNotEmpty ? Text('SKU: ${item.sku}') : null,
                trailing: Text(
                  'x${item.quantity}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

  final CheckoutPaymentMethod method;
  final ValueChanged<CheckoutPaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RadioGroup<CheckoutPaymentMethod>(
          groupValue: method,
          onChanged: (v) => onChanged(v ?? method),
          child: Column(
            children: CheckoutPaymentMethod.values
                .map(
                  (m) => RadioListTile<CheckoutPaymentMethod>(
                    title: Text(m.label),
                    subtitle: Text(m.hint),
                    value: m,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Shows the hosted payment page created for a back-office order, to open
/// here or copy and send to the buyer.
class _CheckoutLinkDialog extends StatelessWidget {
  const _CheckoutLinkDialog({required this.response});

  final CheckoutOrderResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = response.checkoutUrl;
    return AlertDialog(
      title: const Text('Payment link'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (response.hasAmount())
              Text(
                'Amount: ${formatMinor(moneyToMinor(response.amount), response.amount.currencyCode)}',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            url.isEmpty
                ? const Text(
                    'The payment page is not available yet. '
                    'Retry from the order.',
                  )
                : SelectableText(
                    url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
          ],
        ),
      ),
      actions: [
        if (url.isNotEmpty)
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment link copied.')),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
        if (url.isNotEmpty)
          TextButton.icon(
            onPressed: () async {
              try {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
                }
              }
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open'),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
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
        Text(
          'Confirm Order',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _ConfirmRow(
          label: 'Customer',
          value: customer != null ? profileName(customer!) : 'None',
        ),
        _ConfirmRow(label: 'Items', value: '${cartItems.length} line items'),
        _ConfirmRow(
          label: 'Total qty',
          value: '${cartItems.fold<int>(0, (s, i) => s + i.quantity)}',
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
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
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

  _CartItem incrementQuantity() => _CartItem(
    variantId: variantId,
    name: name,
    sku: sku,
    quantity: quantity + 1,
  );
}
