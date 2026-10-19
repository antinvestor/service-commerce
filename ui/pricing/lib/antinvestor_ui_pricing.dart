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
export 'src/screens/price_list_assignments_screen.dart';
export 'src/screens/price_overrides_screen.dart';
export 'src/screens/discount_rules_screen.dart';
export 'src/screens/price_checker_screen.dart';

// Forms
export 'src/screens/price_list_form.dart';
export 'src/screens/price_list_entry_form.dart';
export 'src/screens/discount_rule_form.dart';
export 'src/screens/customer_price_override_form.dart';

// Widgets
export 'src/widgets/price_list_card.dart';
export 'src/widgets/price_list_entry_tile.dart';
export 'src/widgets/customer_override_tile.dart';
export 'src/widgets/discount_rule_card.dart';
export 'src/widgets/price_resolver_preview.dart';
export 'src/widgets/pricing_section_nav.dart';
export 'src/widgets/discount_approval_status.dart';
export 'src/widgets/discount_conditions_editor.dart';
export 'src/widgets/pricing_id_fields.dart';
export 'src/widgets/validity_date_field.dart';

// Utilities
export 'src/utils/discount_conditions.dart'
    show DiscountConditions, supportedConditionKeys;

// Providers
export 'src/providers/pricing_transport_provider.dart';
export 'src/providers/pricing_providers.dart';
