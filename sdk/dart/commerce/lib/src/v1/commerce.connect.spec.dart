//
//  Generated code. Do not modify.
//  source: v1/commerce.proto
//

import "package:connectrpc/connect.dart" as connect;
import "commerce.pb.dart" as v1commerce;

abstract final class CommerceService {
  /// Fully-qualified name of the CommerceService service.
  static const name = 'commerce.v1.CommerceService';

  /// Creates a new shop. The authenticated user becomes the admin.
  static const createShop = connect.Spec(
    '/$name/CreateShop',
    connect.StreamType.unary,
    v1commerce.CreateShopRequest.new,
    v1commerce.CreateShopResponse.new,
  );

  /// Retrieves shop details by ID.
  static const getShop = connect.Spec(
    '/$name/GetShop',
    connect.StreamType.unary,
    v1commerce.GetShopRequest.new,
    v1commerce.GetShopResponse.new,
  );

  /// Updates shop details.
  static const updateShop = connect.Spec(
    '/$name/UpdateShop',
    connect.StreamType.unary,
    v1commerce.UpdateShopRequest.new,
    v1commerce.UpdateShopResponse.new,
  );

  /// Lists the shops in the caller's partition.
  static const listShops = connect.Spec(
    '/$name/ListShops',
    connect.StreamType.unary,
    v1commerce.ListShopsRequest.new,
    v1commerce.ListShopsResponse.new,
  );

  /// Creates a new product in the catalog.
  static const createProduct = connect.Spec(
    '/$name/CreateProduct',
    connect.StreamType.unary,
    v1commerce.CreateProductRequest.new,
    v1commerce.CreateProductResponse.new,
  );

  /// Retrieves a product by its ID.
  static const getProduct = connect.Spec(
    '/$name/GetProduct',
    connect.StreamType.unary,
    v1commerce.GetProductRequest.new,
    v1commerce.GetProductResponse.new,
  );

  /// Lists products belonging to a shop, with optional search and filtering.
  static const listProducts = connect.Spec(
    '/$name/ListProducts',
    connect.StreamType.unary,
    v1commerce.ListProductsRequest.new,
    v1commerce.ListProductsResponse.new,
  );

  /// Creates a new variant for a product.
  static const createProductVariant = connect.Spec(
    '/$name/CreateProductVariant',
    connect.StreamType.unary,
    v1commerce.CreateProductVariantRequest.new,
    v1commerce.CreateProductVariantResponse.new,
  );

  /// Updates an existing product variant.
  static const updateProductVariant = connect.Spec(
    '/$name/UpdateProductVariant',
    connect.StreamType.unary,
    v1commerce.UpdateProductVariantRequest.new,
    v1commerce.UpdateProductVariantResponse.new,
  );

  /// Lists the variants of a product.
  static const listProductVariants = connect.Spec(
    '/$name/ListProductVariants',
    connect.StreamType.unary,
    v1commerce.ListProductVariantsRequest.new,
    v1commerce.ListProductVariantsResponse.new,
  );

  static const createCart = connect.Spec(
    '/$name/CreateCart',
    connect.StreamType.unary,
    v1commerce.CreateCartRequest.new,
    v1commerce.CreateCartResponse.new,
  );

  static const getCart = connect.Spec(
    '/$name/GetCart',
    connect.StreamType.unary,
    v1commerce.GetCartRequest.new,
    v1commerce.GetCartResponse.new,
  );

  static const addCartLine = connect.Spec(
    '/$name/AddCartLine',
    connect.StreamType.unary,
    v1commerce.AddCartLineRequest.new,
    v1commerce.AddCartLineResponse.new,
  );

  static const removeCartLine = connect.Spec(
    '/$name/RemoveCartLine',
    connect.StreamType.unary,
    v1commerce.RemoveCartLineRequest.new,
    v1commerce.RemoveCartLineResponse.new,
  );

  static const createOrderFromCart = connect.Spec(
    '/$name/CreateOrderFromCart',
    connect.StreamType.unary,
    v1commerce.CreateOrderFromCartRequest.new,
    v1commerce.CreateOrderFromCartResponse.new,
  );

  /// Creates an order and reserves stock atomically.
  /// The server MUST:
  /// - validate all variants belong to the shop
  /// - validate sufficient stock
  /// - decrement stock
  /// - snapshot price and name
  /// - compute totals
  /// The order is created in CONFIRMED state
  /// (since this API does not handle payments).
  static const createOrder = connect.Spec(
    '/$name/CreateOrder',
    connect.StreamType.unary,
    v1commerce.CreateOrderRequest.new,
    v1commerce.CreateOrderResponse.new,
  );

  /// Retrieves an order by ID.
  static const getOrder = connect.Spec(
    '/$name/GetOrder',
    connect.StreamType.unary,
    v1commerce.GetOrderRequest.new,
    v1commerce.GetOrderResponse.new,
  );

  /// Lists orders for a shop, with optional search and filtering.
  static const listOrders = connect.Spec(
    '/$name/ListOrders',
    connect.StreamType.unary,
    v1commerce.ListOrdersRequest.new,
    v1commerce.ListOrdersResponse.new,
  );

  /// Starts payment for an order: creates a hosted checkout session and
  /// returns the page the buyer should be sent to. Idempotent per order.
  static const checkoutOrder = connect.Spec(
    '/$name/CheckoutOrder',
    connect.StreamType.unary,
    v1commerce.CheckoutOrderRequest.new,
    v1commerce.CheckoutOrderResponse.new,
  );

  /// Marks an order paid after verifying the checkout session with the
  /// payment service. Safe to call repeatedly; used by staff and by the
  /// scheduled reconciler.
  static const confirmOrderPayment = connect.Spec(
    '/$name/ConfirmOrderPayment',
    connect.StreamType.unary,
    v1commerce.ConfirmOrderPaymentRequest.new,
    v1commerce.ConfirmOrderPaymentResponse.new,
  );

  /// Cancels an unfulfilled order and returns its stock. Buyers may cancel
  /// their own unpaid orders; staff may cancel any unfulfilled order.
  static const cancelOrder = connect.Spec(
    '/$name/CancelOrder',
    connect.StreamType.unary,
    v1commerce.CancelOrderRequest.new,
    v1commerce.CancelOrderResponse.new,
  );

  /// Reconciles orders awaiting payment against the payment service and
  /// expires reservations whose payment window has lapsed. Scheduled.
  static const reconcilePayments = connect.Spec(
    '/$name/ReconcilePayments',
    connect.StreamType.unary,
    v1commerce.ReconcilePaymentsRequest.new,
    v1commerce.ReconcilePaymentsResponse.new,
  );

  /// Posts one balanced ledger transaction per shop for a trading day,
  /// merging that day's paid and refunded orders. Scheduled end of day.
  static const runEndOfDayLedger = connect.Spec(
    '/$name/RunEndOfDayLedger',
    connect.StreamType.unary,
    v1commerce.RunEndOfDayLedgerRequest.new,
    v1commerce.RunEndOfDayLedgerResponse.new,
  );

  /// Creates a fulfilment for an order.
  /// A fulfilment may contain a subset of order lines.
  /// Quantity per line MUST NOT exceed remaining unfulfilled quantity.
  static const createFulfilment = connect.Spec(
    '/$name/CreateFulfilment',
    connect.StreamType.unary,
    v1commerce.CreateFulfilmentRequest.new,
    v1commerce.CreateFulfilmentResponse.new,
  );

  /// Updates a fulfilment (e.g. adding tracking number, marking as shipped).
  static const updateFulfilment = connect.Spec(
    '/$name/UpdateFulfilment',
    connect.StreamType.unary,
    v1commerce.UpdateFulfilmentRequest.new,
    v1commerce.UpdateFulfilmentResponse.new,
  );

  /// Retrieves a fulfilment by ID.
  static const getFulfilment = connect.Spec(
    '/$name/GetFulfilment',
    connect.StreamType.unary,
    v1commerce.GetFulfilmentRequest.new,
    v1commerce.GetFulfilmentResponse.new,
  );

  /// Creates or updates a price list.
  static const priceListSave = connect.Spec(
    '/$name/PriceListSave',
    connect.StreamType.unary,
    v1commerce.PriceListSaveRequest.new,
    v1commerce.PriceListSaveResponse.new,
  );

  /// Retrieves a price list by ID.
  static const priceListGet = connect.Spec(
    '/$name/PriceListGet',
    connect.StreamType.unary,
    v1commerce.PriceListGetRequest.new,
    v1commerce.PriceListGetResponse.new,
  );

  /// Searches price lists for a shop.
  static const priceListSearch = connect.Spec(
    '/$name/PriceListSearch',
    connect.StreamType.unary,
    v1commerce.PriceListSearchRequest.new,
    v1commerce.PriceListSearchResponse.new,
  );

  /// Replaces all entries for the given variants in a price list.
  static const priceListEntryBatchSave = connect.Spec(
    '/$name/PriceListEntryBatchSave',
    connect.StreamType.unary,
    v1commerce.PriceListEntryBatchSaveRequest.new,
    v1commerce.PriceListEntryBatchSaveResponse.new,
  );

  /// Creates or updates a customer-to-price-list assignment.
  static const customerPriceListAssignmentSave = connect.Spec(
    '/$name/CustomerPriceListAssignmentSave',
    connect.StreamType.unary,
    v1commerce.CustomerPriceListAssignmentSaveRequest.new,
    v1commerce.CustomerPriceListAssignmentSaveResponse.new,
  );

  /// Searches customer price list assignments.
  static const customerPriceListAssignmentSearch = connect.Spec(
    '/$name/CustomerPriceListAssignmentSearch',
    connect.StreamType.unary,
    v1commerce.CustomerPriceListAssignmentSearchRequest.new,
    v1commerce.CustomerPriceListAssignmentSearchResponse.new,
  );

  /// Creates or updates a customer price override for a specific variant.
  static const customerPriceOverrideSave = connect.Spec(
    '/$name/CustomerPriceOverrideSave',
    connect.StreamType.unary,
    v1commerce.CustomerPriceOverrideSaveRequest.new,
    v1commerce.CustomerPriceOverrideSaveResponse.new,
  );

  /// Searches customer price overrides.
  static const customerPriceOverrideSearch = connect.Spec(
    '/$name/CustomerPriceOverrideSearch',
    connect.StreamType.unary,
    v1commerce.CustomerPriceOverrideSearchRequest.new,
    v1commerce.CustomerPriceOverrideSearchResponse.new,
  );

  /// Creates or updates a discount rule.
  static const discountRuleSave = connect.Spec(
    '/$name/DiscountRuleSave',
    connect.StreamType.unary,
    v1commerce.DiscountRuleSaveRequest.new,
    v1commerce.DiscountRuleSaveResponse.new,
  );

  /// Searches discount rules for a shop.
  static const discountRuleSearch = connect.Spec(
    '/$name/DiscountRuleSearch',
    connect.StreamType.unary,
    v1commerce.DiscountRuleSearchRequest.new,
    v1commerce.DiscountRuleSearchResponse.new,
  );

  /// Resolves the effective price for a variant given customer and quantity context.
  static const resolvePrice = connect.Spec(
    '/$name/ResolvePrice',
    connect.StreamType.unary,
    v1commerce.ResolvePriceRequest.new,
    v1commerce.ResolvePriceResponse.new,
  );
}
