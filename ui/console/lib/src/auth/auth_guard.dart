import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adapts [authStateProvider] into a [Listenable] that GoRouter can hook
/// into via `refreshListenable`, plus a synchronous `isLoggedIn` flag
/// that the `redirect` callback can read without awaiting the stream.
///
/// The router re-evaluates redirects whenever the runtime state
/// transitions (signed in, signed out, refresh failure, …).
class ConsoleAuthListenable extends ChangeNotifier {
  ConsoleAuthListenable(Ref ref) {
    // Seed synchronously from whatever the stream has emitted so far.
    final seed = ref.read(authStateProvider);
    _isLoggedIn = seed.value == AuthState.authenticated;

    ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
      final logged = next.maybeWhen(
        data: (s) => s == AuthState.authenticated,
        // Preserve last-known value during transient refresh states so
        // the user isn't bounced to /login mid-refresh.
        orElse: () => _isLoggedIn,
      );
      if (logged != _isLoggedIn) {
        _isLoggedIn = logged;
        notifyListeners();
      } else {
        // Still notify on other transitions so the router re-evaluates
        // when (e.g.) sign-in succeeds and we want to leave /login.
        notifyListeners();
      }
    });
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
}

final consoleAuthListenableProvider = Provider<ConsoleAuthListenable>(
  ConsoleAuthListenable.new,
);
