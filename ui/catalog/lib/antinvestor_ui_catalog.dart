/// Product catalog UI library for Antinvestor.
///
/// Provides embeddable screens and widgets for browsing products,
/// selecting variants, and managing catalog entries.
library;

// Routing
export 'src/routing/catalog_route_module.dart';

// Screens
export 'src/screens/catalog_browse_screen.dart';
export 'src/screens/product_detail_screen.dart';
export 'src/screens/product_create_screen.dart';
export 'src/screens/variant_create_screen.dart';

// Widgets
export 'src/widgets/product_card.dart';
export 'src/widgets/product_grid.dart';
export 'src/widgets/variant_card.dart';
export 'src/widgets/variant_selector.dart';
export 'src/widgets/product_status_badge.dart';
export 'src/widgets/variant_status_badge.dart';
export 'src/widgets/product_search_select.dart';
export 'src/widgets/variant_price_tile.dart';
export 'src/widgets/fulfilment_type_badge.dart';

// Providers
export 'src/providers/catalog_transport_provider.dart';
export 'src/providers/catalog_providers.dart';
