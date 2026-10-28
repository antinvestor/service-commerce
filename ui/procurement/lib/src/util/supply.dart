import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';

/// Whether a line or item is a commerce product variant bought for resale
/// rather than a manufacturing material.
bool isResale(SupplyKind kind) =>
    kind == SupplyKind.SUPPLY_KIND_PRODUCT_VARIANT;

/// Staff-facing name of a [SupplyKind].
String supplyKindLabel(SupplyKind kind) =>
    isResale(kind) ? 'Product for resale' : 'Material';

/// Where received stock lands, for a [SupplyKind].
String supplyDestination(SupplyKind kind) => isResale(kind)
    ? 'Raises the product variant\'s stock in the shop.'
    : 'Goes to manufacturing inventory.';

/// The id of what is supplied: the product variant for resale, else the
/// inventory item.
String suppliedId(
  SupplyKind kind, {
  required String inventoryItemId,
  required String productVariantId,
}) => isResale(kind) ? productVariantId : inventoryItemId;

/// Whether a quantity of [kind] must be whole: product variants are bought
/// and received in whole units.
bool needsWholeUnits(SupplyKind kind) => isResale(kind);

/// Whether a receipt line's stock still needs a person: refused by its
/// destination, or a raw material waiting for a stock location.
bool deliveryNeedsAction(GoodsReceiptLine line) =>
    line.deliveryStatus == StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED ||
    line.deliveryStatus ==
        StockDeliveryStatus.STOCK_DELIVERY_STATUS_PENDING_TRANSFER;

/// Whether staff can send a receipt line's stock again: anything its
/// destination refused, and a raw material still waiting for a stock
/// location (which then needs one).
bool deliveryRetryable(GoodsReceiptLine line) => deliveryNeedsAction(line);

/// Whether sending [line] again needs a stock location chosen first.
bool needsLocation(GoodsReceiptLine line) =>
    !isResale(line.supplyKind) &&
    (line.locationId.isEmpty ||
        line.deliveryStatus ==
            StockDeliveryStatus.STOCK_DELIVERY_STATUS_FAILED);
