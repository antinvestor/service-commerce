import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'paged_list.dart';
import 'procurement_api.dart';
import 'procurement_transport_provider.dart';

/// Server-side filters for the supplier lists. A null field means "any".
typedef SupplierFilter = ({SupplierType? type, SupplierStatus? status});

/// The unfiltered supplier search.
const SupplierFilter allSuppliers = (type: null, status: null);

SupplierSearchRequest _supplierSearch(SupplierFilter filter, SearchRequest s) {
  final request = SupplierSearchRequest(search: s);
  if (filter.type != null) request.supplierType = filter.type!;
  if (filter.status != null) request.status = filter.status!;
  return request;
}

/// Every supplier matching [SupplierFilter], up to [collectMaxPages] pages:
/// for pickers and counts.
final supplierListProvider =
    FutureProvider.family<List<Supplier>, SupplierFilter>((ref, filter) {
      final api = ref.watch(procurementApiProvider);
      return collectPages((s) async {
        final r = await api.supplierSearch(_supplierSearch(filter, s));
        return (r.suppliers.toList(), r.nextPage);
      });
    });

/// Suppliers matching a filter, a page at a time.
class SupplierPages extends PagedController<Supplier> {
  SupplierPages(this.filter);

  final SupplierFilter filter;

  @override
  Future<(List<Supplier>, String)> fetchPage(
    ProcurementApi api,
    String page,
  ) async {
    final r = await api.supplierSearch(
      _supplierSearch(filter, pageSearch(page)),
    );
    return (r.suppliers.toList(), r.nextPage);
  }
}

final supplierPagesProvider =
    AsyncNotifierProvider.family<
      SupplierPages,
      PagedList<Supplier>,
      SupplierFilter
    >(SupplierPages.new);

/// Get a single supplier by ID.
final supplierByIdProvider = FutureProvider.family<Supplier, String>((
  ref,
  supplierId,
) async {
  final client = ref.watch(procurementServiceClientProvider);
  final request = SupplierGetRequest()..id = supplierId;
  final response = await client.supplierGet(request);
  return response.supplier;
});

/// Every item a supplier offers, up to [collectMaxPages] pages: for the
/// purchase order wizard's item picker.
final supplierItemListProvider =
    FutureProvider.family<List<SupplierItem>, String>((ref, supplierId) {
      final api = ref.watch(procurementApiProvider);
      return collectPages((s) async {
        final r = await api.supplierItemSearch(
          SupplierItemSearchRequest(supplierId: supplierId, search: s),
        );
        return (r.supplierItems.toList(), r.nextPage);
      });
    });

/// A supplier's items, a page at a time.
class SupplierItemPages extends PagedController<SupplierItem> {
  SupplierItemPages(this.supplierId);

  final String supplierId;

  @override
  Future<(List<SupplierItem>, String)> fetchPage(
    ProcurementApi api,
    String page,
  ) async {
    final r = await api.supplierItemSearch(
      SupplierItemSearchRequest(
        supplierId: supplierId,
        search: pageSearch(page),
      ),
    );
    return (r.supplierItems.toList(), r.nextPage);
  }
}

final supplierItemPagesProvider =
    AsyncNotifierProvider.family<
      SupplierItemPages,
      PagedList<SupplierItem>,
      String
    >(SupplierItemPages.new);

/// Every purchase order of a property, up to [collectMaxPages] pages: for
/// counts on the home screen and the dashboard.
final purchaseOrderListProvider =
    FutureProvider.family<List<PurchaseOrder>, String>((ref, propertyId) {
      final api = ref.watch(procurementApiProvider);
      return collectPages((s) async {
        final r = await api.purchaseOrderSearch(
          PurchaseOrderSearchRequest(propertyId: propertyId, search: s),
        );
        return (r.purchaseOrders.toList(), r.nextPage);
      });
    });

/// A property's purchase orders, optionally in one status.
typedef PurchaseOrderQuery = ({String propertyId, PurchaseOrderStatus? status});

/// Purchase orders matching a [PurchaseOrderQuery], a page at a time; the
/// status is filtered by the server.
class PurchaseOrderPages extends PagedController<PurchaseOrder> {
  PurchaseOrderPages(this.query);

  final PurchaseOrderQuery query;

  @override
  Future<(List<PurchaseOrder>, String)> fetchPage(
    ProcurementApi api,
    String page,
  ) async {
    final request = PurchaseOrderSearchRequest(
      propertyId: query.propertyId,
      search: pageSearch(page),
    );
    if (query.status != null) request.status = query.status!;
    final r = await api.purchaseOrderSearch(request);
    return (r.purchaseOrders.toList(), r.nextPage);
  }
}

final purchaseOrderPagesProvider =
    AsyncNotifierProvider.family<
      PurchaseOrderPages,
      PagedList<PurchaseOrder>,
      PurchaseOrderQuery
    >(PurchaseOrderPages.new);

/// Get a single purchase order by ID.
final purchaseOrderByIdProvider = FutureProvider.family<PurchaseOrder, String>((
  ref,
  poId,
) async {
  final client = ref.watch(procurementServiceClientProvider);
  final request = PurchaseOrderGetRequest()..id = poId;
  final response = await client.purchaseOrderGet(request);
  return response.purchaseOrder;
});

/// The goods receipts recorded against one purchase order, a page at a time.
class GoodsReceiptPages extends PagedController<GoodsReceipt> {
  GoodsReceiptPages(this.purchaseOrderId);

  final String purchaseOrderId;

  @override
  Future<(List<GoodsReceipt>, String)> fetchPage(
    ProcurementApi api,
    String page,
  ) async {
    final r = await api.goodsReceiptSearch(
      GoodsReceiptSearchRequest(
        purchaseOrderId: purchaseOrderId,
        search: pageSearch(page),
      ),
    );
    return (r.goodsReceipts.toList(), r.nextPage);
  }
}

final goodsReceiptPagesProvider =
    AsyncNotifierProvider.family<
      GoodsReceiptPages,
      PagedList<GoodsReceipt>,
      String
    >(GoodsReceiptPages.new);

/// Get a single goods receipt by ID.
final goodsReceiptByIdProvider = FutureProvider.family<GoodsReceipt, String>((
  ref,
  receiptId,
) async {
  final client = ref.watch(procurementServiceClientProvider);
  final request = GoodsReceiptGetRequest()..id = receiptId;
  final response = await client.goodsReceiptGet(request);
  return response.goodsReceipt;
});

/// Which plan to propose purchase orders for, and the currency supplier
/// prices are compared in (empty: materials offered in more than one
/// currency are left unsourced).
typedef SuggestionQuery = ({
  String propertyId,
  String planId,
  String currencyCode,
});

/// Purchase orders that would cover a production plan's material shortages.
/// A suggestion with no supplier lists shortages nobody supplies yet.
final purchaseOrderSuggestionsProvider = FutureProvider.autoDispose
    .family<List<PurchaseOrderSuggestion>, SuggestionQuery>((ref, query) async {
      final client = ref.watch(procurementServiceClientProvider);
      final response = await client.suggestPurchaseOrders(
        SuggestPurchaseOrdersRequest()
          ..propertyId = query.propertyId
          ..planId = query.planId
          ..currencyCode = query.currencyCode,
      );
      return response.suggestions;
    });

/// Notifier for procurement mutations.
class ProcurementNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  ProcurementServiceClient get _client =>
      ref.read(procurementServiceClientProvider);

  Future<Supplier> saveSupplier(SupplierSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.supplierSave(request);
      state = const AsyncValue.data(null);
      return response.supplier;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<SupplierItem> saveSupplierItem(SupplierItemSaveRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.supplierItemSave(request);
      state = const AsyncValue.data(null);
      return response.supplierItem;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<PurchaseOrder> createPO(PurchaseOrderCreateRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.purchaseOrderCreate(request);
      state = const AsyncValue.data(null);
      return response.purchaseOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<PurchaseOrder> submitPO(PurchaseOrderSubmitRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.purchaseOrderSubmit(request);
      state = const AsyncValue.data(null);
      return response.purchaseOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<PurchaseOrder> cancelPO(PurchaseOrderCancelRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.purchaseOrderCancel(request);
      state = const AsyncValue.data(null);
      return response.purchaseOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Closes a partially received order short: nothing more is received.
  Future<PurchaseOrder> closePO(PurchaseOrderCloseRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.purchaseOrderClose(request);
      state = const AsyncValue.data(null);
      return response.purchaseOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<GoodsReceipt> createGoodsReceipt(
    GoodsReceiptCreateRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.goodsReceiptCreate(request);
      state = const AsyncValue.data(null);
      return response.goodsReceipt;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Settles a receipt line that needs a person (booked by hand, or a
  /// refused product variant retried). Returns the receipt as it stands.
  Future<GoodsReceipt> resolveGoodsReceiptLine(
    GoodsReceiptLineResolveRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.goodsReceiptLineResolve(request);
      state = const AsyncValue.data(null);
      return response.goodsReceipt;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final procurementNotifierProvider =
    NotifierProvider<ProcurementNotifier, AsyncValue<void>>(
      ProcurementNotifier.new,
    );
