import 'package:flutter/material.dart';

/// A prominent checkout action button.
class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.onPressed,
    this.label = 'Place Order',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline, size: 20),
        label: Text(label),
      ),
    );
  }
}
