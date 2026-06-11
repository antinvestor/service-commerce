import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show CommerceServiceClient;
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

/// Connect transport pointed at the commerce service.
///
/// Mirrors the per-package transport pattern used by the commerce UI
/// packages (see `catalog_transport_provider.dart`): it reuses the
/// shared [createTransport] helper and the host-overridden
/// [authTokenProviderProvider] so every request carries a bearer token.
final commerceTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(
    tokenProvider,
    baseUrl: ApiConfig.commerceBaseUrl,
  );
});

/// Commerce service client used by console-owned features (e.g. the
/// shop settings surface) that call commerce RPCs directly rather than
/// through a domain UI package.
final commerceServiceClientProvider = Provider<CommerceServiceClient>((ref) {
  return CommerceServiceClient(ref.watch(commerceTransportProvider));
});
