import 'dart:async';

import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart'
    as runtime;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tri-state console auth flag mirrored from [runtime.AuthRuntime].
///
/// The runtime exposes five states (initializing, authenticated,
/// unauthenticated, refreshing, error). This collapses them into the
/// three states the router and UI actually care about so existing call
/// sites stay simple.
enum AuthState { authenticated, unauthenticated, loading }

AuthState _map(runtime.AuthState s) {
  switch (s) {
    case runtime.AuthState.authenticated:
      return AuthState.authenticated;
    case runtime.AuthState.unauthenticated:
      return AuthState.unauthenticated;
    case runtime.AuthState.initializing:
    case runtime.AuthState.refreshing:
      return AuthState.loading;
    case runtime.AuthState.error:
      return AuthState.unauthenticated;
  }
}

/// Console-level auth state notifier. Delegates to the runtime but
/// keeps the `login()` / `logout()` surface expected by the router
/// redirect and the login page.
class AuthStateNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription<runtime.AuthState>? _sub;

  @override
  Future<AuthState> build() async {
    final rt = ref.watch(runtime.authRuntimeProvider);

    _sub?.cancel();
    _sub = rt.authStateStream.listen((rs) {
      if (!ref.mounted) return;
      state = AsyncValue.data(_map(rs));
    });
    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;
    });

    return _map(rt.state);
  }

  /// Trigger login via the runtime.
  Future<void> login() async {
    state = const AsyncValue.loading();
    try {
      final rt = ref.read(runtime.authRuntimeProvider);
      await rt.ensureAuthenticated();
      if (!ref.mounted) return;
      state = AsyncValue.data(_map(rt.state));
    } catch (e, stack) {
      debugPrint('[Auth] Login failed: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  /// Trigger logout via the runtime.
  ///
  /// Forces the local state to `unauthenticated` even if the runtime's
  /// remote session revocation hangs. The user sees an immediate
  /// transition to the login page; the remote revocation completes in
  /// the background and any failure is logged but not surfaced.
  Future<void> logout() async {
    state = const AsyncValue.data(AuthState.unauthenticated);
    final rt = ref.read(runtime.authRuntimeProvider);
    unawaited(
      rt.logout().timeout(const Duration(seconds: 5)).catchError((Object e) {
        debugPrint('[Auth] Background logout failed: $e');
      }),
    );
  }
}

final consoleAuthStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthState>(
  AuthStateNotifier.new,
);
