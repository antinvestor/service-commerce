import 'dart:async';

import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart'
    as runtime;
import 'package:console/features/auth/data/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A runtime whose session was restored from storage before anyone
/// listened: it is authenticated, and its state stream never says so.
class _RestoredRuntime implements runtime.AuthRuntime {
  @override
  runtime.AuthState get state => runtime.AuthState.authenticated;

  @override
  Stream<runtime.AuthState> get authStateStream =>
      StreamController<runtime.AuthState>.broadcast().stream;

  @override
  Future<Map<String, dynamic>> getClaims() async => {
    'name': 'Wanjiku',
    'partition_id': 'partition-1',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'claims of a restored session are read without a fresh sign-in',
    () async {
      final container = ProviderContainer(
        overrides: [
          runtime.authRuntimeProvider.overrideWithValue(_RestoredRuntime()),
        ],
      );
      addTearDown(container.dispose);

      container.listen(consoleClaimsProvider, (_, _) {});
    await container.read(consoleAuthStateProvider.future);
    final claims = await container.read(consoleClaimsProvider.future);

      expect(claims['name'], 'Wanjiku');
      expect(claims['partition_id'], 'partition-1');
    },
  );
}
