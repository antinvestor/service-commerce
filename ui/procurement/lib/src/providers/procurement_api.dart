import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'procurement_transport_provider.dart';

/// The procurement searches the list screens page through.
///
/// The generated [ProcurementServiceClient] is an extension type over a
/// transport and cannot be subclassed; this interface is the seam tests
/// replace with a fake.
abstract interface class ProcurementApi {
  Future<SupplierSearchResponse> supplierSearch(SupplierSearchRequest request);

  Future<SupplierItemSearchResponse> supplierItemSearch(
    SupplierItemSearchRequest request,
  );

  Future<PurchaseOrderSearchResponse> purchaseOrderSearch(
    PurchaseOrderSearchRequest request,
  );

  Future<GoodsReceiptSearchResponse> goodsReceiptSearch(
    GoodsReceiptSearchRequest request,
  );
}

/// [ProcurementApi] backed by the generated Connect client.
class ConnectProcurementApi implements ProcurementApi {
  ConnectProcurementApi(this._client);

  final ProcurementServiceClient _client;

  @override
  Future<SupplierSearchResponse> supplierSearch(
    SupplierSearchRequest request,
  ) => _client.supplierSearch(request);

  @override
  Future<SupplierItemSearchResponse> supplierItemSearch(
    SupplierItemSearchRequest request,
  ) => _client.supplierItemSearch(request);

  @override
  Future<PurchaseOrderSearchResponse> purchaseOrderSearch(
    PurchaseOrderSearchRequest request,
  ) => _client.purchaseOrderSearch(request);

  @override
  Future<GoodsReceiptSearchResponse> goodsReceiptSearch(
    GoodsReceiptSearchRequest request,
  ) => _client.goodsReceiptSearch(request);
}

/// Override in tests with a fake [ProcurementApi].
final procurementApiProvider = Provider<ProcurementApi>(
  (ref) => ConnectProcurementApi(ref.watch(procurementServiceClientProvider)),
);
