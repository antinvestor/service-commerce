import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:antinvestor_ui_core/auth/auth_token_provider.dart';

/// Bridges [AuthRuntime] onto ui_core's [AuthTokenProvider] interface so
/// every shared widget package (catalog, orders, inventory, …) can
/// participate in the console's auth lifecycle.
///
/// The runtime intentionally hides the raw access token from
/// application code — every authenticated call is supposed to go
/// through [AuthRuntime.fetch]. The widget packages, however, are wired
/// for the legacy Bearer-token model. Until they migrate, this bridge
/// returns a sentinel empty token so the Connect interceptor leaves the
/// `Authorization` header unset and the runtime's outbound `fetch`
/// pipeline can intercept the call at the transport layer (follow-up).
///
/// The [logout] call is routed straight through so any module-side
/// auth failure ("401 — please log out") propagates to the runtime.
class ConsoleAuthBridge implements AuthTokenProvider {
  ConsoleAuthBridge(this._runtime);

  final AuthRuntime _runtime;

  @override
  Future<String?> ensureValidAccessToken() async {
    if (!_runtime.isAuthenticated) {
      // Don't trigger an interactive sign-in from arbitrary RPCs — the
      // GoRouter redirect handles unauthenticated state explicitly.
      return null;
    }
    return null;
  }

  @override
  Future<String?> forceRefreshAccessToken() async {
    if (!_runtime.isAuthenticated) return null;
    return null;
  }

  @override
  Future<void> logout() => _runtime.logout();
}
