/// Procurement UI library for Antinvestor.
///
/// Embeddable screens and widgets for managing suppliers, purchase orders,
/// and goods receipts.
library;

// Routing
export 'src/routing/procurement_route_module.dart';

// Screens
export 'src/screens/supplier_list_screen.dart';
export 'src/screens/supplier_detail_screen.dart';
export 'src/screens/supplier_form.dart';
export 'src/screens/supplier_item_form.dart';
export 'src/screens/purchase_order_list_screen.dart';
export 'src/screens/po_create_wizard_screen.dart';
export 'src/screens/goods_receipt_wizard_screen.dart';

// Widgets
export 'src/widgets/supplier_card.dart';
export 'src/widgets/supplier_rating_badge.dart';
export 'src/widgets/purchase_order_card.dart';
export 'src/widgets/po_status_badge.dart';
export 'src/widgets/po_line_tile.dart';
export 'src/widgets/goods_receipt_card.dart';
export 'src/widgets/goods_receipt_status_badge.dart';
export 'src/widgets/receipt_line_tile.dart';

// Providers
export 'src/providers/procurement_transport_provider.dart';
export 'src/providers/procurement_providers.dart';
