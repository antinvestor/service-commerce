import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The top-level pricing areas reachable from [PricingSectionNav].
enum PricingSection {
  priceLists('/pricing', 'Price Lists', Icons.price_change_outlined),
  overrides('/pricing/overrides', 'Customer Overrides', Icons.person_outline),
  discounts('/pricing/discounts', 'Discounts', Icons.discount_outlined),
  checker('/pricing/checker', 'Price Checker', Icons.price_check);

  const PricingSection(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

/// Segmented navigation between the pricing areas, shown at the top of each
/// pricing screen so every sub-page is reachable from the price-list screen.
class PricingSectionNav extends StatelessWidget {
  const PricingSectionNav({super.key, required this.current});

  final PricingSection current;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<PricingSection>(
        showSelectedIcon: false,
        segments: [
          for (final section in PricingSection.values)
            ButtonSegment(
              value: section,
              icon: Icon(section.icon, size: 18),
              label: Text(section.label),
            ),
        ],
        selected: {current},
        onSelectionChanged: (selection) {
          final target = selection.first;
          if (target != current) context.go(target.route);
        },
      ),
    );
  }
}
