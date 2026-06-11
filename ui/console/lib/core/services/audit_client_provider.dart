import 'package:antinvestor_api_audit/antinvestor_api_audit.dart'
    show AuditServiceClient;
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

/// Connect transport pointed at the audit service.
///
/// Mirrors [commerceTransportProvider]: the shared [createTransport]
/// helper plus the host-overridden [authTokenProviderProvider], so audit
/// queries carry the operator's bearer token and the service scopes
/// results to the caller's tenant.
final auditTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(
    tokenProvider,
    baseUrl: ApiConfig.auditBaseUrl,
  );
});

/// Audit service client used by the dashboard's recent-activity feed.
final auditServiceClientProvider = Provider<AuditServiceClient>((ref) {
  return AuditServiceClient(ref.watch(auditTransportProvider));
});
