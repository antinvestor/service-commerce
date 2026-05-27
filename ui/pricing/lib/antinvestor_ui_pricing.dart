/// Pricing UI library for Antinvestor.
///
/// Provides embeddable screens and widgets for price lists,
/// discounts, customer overrides, and price resolution.
library;

// Routing
export 'src/routing/pricing_route_module.dart';

// Screens
export 'src/screens/price_list_screen.dart';
export 'src/screens/price_list_detail_screen.dart';
export 'src/screens/price_overrides_screen.dart';
export 'src/screens/discount_rules_screen.dart';
export 'src/screens/price_checker_screen.dart';

// Widgets
export 'src/widgets/price_list_card.dart';
export 'src/widgets/price_list_entry_tile.dart';
export 'src/widgets/customer_override_tile.dart';
export 'src/widgets/discount_rule_card.dart';
export 'src/widgets/price_resolver_preview.dart';

// Providers
export 'src/providers/pricing_transport_provider.dart';
export 'src/providers/pricing_providers.dart';
