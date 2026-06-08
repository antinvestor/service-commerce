import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _procurementUrl = String.fromEnvironment(
  'PROCUREMENT_URL',
  defaultValue: 'https://api.antinvestor.com/procurement',
);

final procurementTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _procurementUrl);
});

final procurementServiceClientProvider =
    Provider<ProcurementServiceClient>((ref) {
  final transport = ref.watch(procurementTransportProvider);
  return ProcurementServiceClient(transport);
});
