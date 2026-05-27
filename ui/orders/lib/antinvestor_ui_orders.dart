/// Order management UI library for Antinvestor.
///
/// Provides embeddable screens and widgets for cart, checkout,
/// orders, and fulfilment workflows.
library;

// Routing
export 'src/routing/order_route_module.dart';

// Screens
export 'src/screens/order_list_screen.dart';
export 'src/screens/order_detail_screen.dart';
export 'src/screens/checkout_flow_screen.dart';
export 'src/screens/fulfilment_screen.dart';

// Widgets
export 'src/widgets/order_card.dart';
export 'src/widgets/order_status_badge.dart';
export 'src/widgets/payment_status_badge.dart';
export 'src/widgets/fulfilment_status_badge.dart';
export 'src/widgets/order_line_tile.dart';
export 'src/widgets/cart_summary_card.dart';
export 'src/widgets/checkout_button.dart';

// Providers
export 'src/providers/order_transport_provider.dart';
export 'src/providers/order_providers.dart';
