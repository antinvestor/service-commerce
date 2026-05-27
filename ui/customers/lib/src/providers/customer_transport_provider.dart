import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _commerceUrl = String.fromEnvironment(
  'COMMERCE_URL',
  defaultValue: 'https://api.antinvestor.com/commerce',
);

final customerTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _commerceUrl);
});

final customerServiceClientProvider = Provider<CommerceServiceClient>((ref) {
  final transport = ref.watch(customerTransportProvider);
  return CommerceServiceClient(transport);
});
