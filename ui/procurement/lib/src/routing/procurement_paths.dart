/// Every location the procurement module registers, in one place.
///
/// Screens navigate exclusively through these helpers so links cannot drift
/// from the route table in `ProcurementRouteModule`.
abstract final class ProcurementPaths {
  /// Procurement landing page; the host sidebar links here.
  static const String root = '/procurement';

  static const String suppliers = '$root/suppliers';
  static const String orders = '$root/orders';
  static const String newOrder = '$orders/new';
  static const String receipts = '$root/receipts';
  static const String suggestions = '$root/suggestions';

  static String supplier(String supplierId) =>
      '$suppliers/${Uri.encodeComponent(supplierId)}';

  static String order(String poId) => '$orders/${Uri.encodeComponent(poId)}';

  static String receiveOrder(String poId) => '${order(poId)}/receive';

  static String receipt(String receiptId) =>
      '$receipts/${Uri.encodeComponent(receiptId)}';
}
