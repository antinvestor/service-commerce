/// Customer management UI library for Antinvestor.
///
/// Provides embeddable screens and widgets for browsing customers,
/// viewing balances, and receiving payments. Wraps profile widgets
/// from [antinvestor_ui_profile] with commerce-specific additions.
library;

// Routing
export 'src/routing/customer_route_module.dart';

// Screens
export 'src/screens/customer_list_screen.dart';
export 'src/screens/customer_detail_screen.dart';
export 'src/screens/receive_payment_screen.dart';

// Widgets
export 'src/widgets/customer_card.dart';
export 'src/widgets/customer_search_select.dart';
export 'src/widgets/customer_balance_card.dart';
export 'src/widgets/customer_credit_badge.dart';
export 'src/widgets/customer_location_tile.dart';
export 'src/widgets/customer_note_tile.dart';

// Providers
export 'src/providers/customer_transport_provider.dart';
export 'src/providers/customer_providers.dart';
