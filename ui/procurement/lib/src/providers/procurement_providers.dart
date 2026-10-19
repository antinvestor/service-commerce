import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'procurement_transport_provider.dart';

/// Server-side filters for [supplierListProvider]. A null field means
/// "any".
typedef SupplierFilter = ({SupplierType? type, SupplierStatus? status});

/// The unfiltered supplier search.
const SupplierFilter allSuppliers = (type: null, status: null);

/// Search suppliers, optionally narrowed by type and status.
final supplierListProvider =
    FutureProvider.family<List<Supplier>, SupplierFilter>((ref, filter) async {
      final client = ref.watch(procurementServiceClientProvider);
      final request = SupplierSearchRequest();
      if (filter.type != null) request.supplierType = filter.type!;
      if (filter.status != null) request.status = filter.status!;
      final response = await client.supplierSearch(request);
      return response.suppliers;
    });

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

/// Search supplier items for a given supplier.
final supplierItemListProvider =
    FutureProvider.family<List<SupplierItem>, String>((ref, supplierId) async {
      final client = ref.watch(procurementServiceClientProvider);
      final request = SupplierItemSearchRequest()..supplierId = supplierId;
      final response = await client.supplierItemSearch(request);
      return response.supplierItems;
    });

/// Search purchase orders by property.
final purchaseOrderListProvider =
    FutureProvider.family<List<PurchaseOrder>, String>((ref, propertyId) async {
      final client = ref.watch(procurementServiceClientProvider);
      final request = PurchaseOrderSearchRequest()..propertyId = propertyId;
      final response = await client.purchaseOrderSearch(request);
      return response.purchaseOrders;
    });

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

/// Search goods receipts.
final goodsReceiptListProvider =
    FutureProvider.family<
      List<GoodsReceipt>,
      ({String? propertyId, String? purchaseOrderId})
    >((ref, params) async {
      final client = ref.watch(procurementServiceClientProvider);
      final request = GoodsReceiptSearchRequest();
      if (params.propertyId != null) request.propertyId = params.propertyId!;
      if (params.purchaseOrderId != null) {
        request.purchaseOrderId = params.purchaseOrderId!;
      }
      final response = await client.goodsReceiptSearch(request);
      return response.goodsReceipts;
    });

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

/// Notifier for procurement mutations.
/// Which plan to propose purchase orders for.
typedef SuggestionQuery = ({String propertyId, String planId});

/// Purchase orders that would cover a production plan's material shortages.
/// A suggestion with no supplier lists shortages nobody supplies yet.
final purchaseOrderSuggestionsProvider = FutureProvider.autoDispose
    .family<List<PurchaseOrderSuggestion>, SuggestionQuery>((ref, query) async {
      final client = ref.watch(procurementServiceClientProvider);
      final response = await client.suggestPurchaseOrders(
        SuggestPurchaseOrdersRequest()
          ..propertyId = query.propertyId
          ..planId = query.planId,
      );
      return response.suggestions;
    });

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
}

final procurementNotifierProvider =
    NotifierProvider<ProcurementNotifier, AsyncValue<void>>(
      ProcurementNotifier.new,
    );
