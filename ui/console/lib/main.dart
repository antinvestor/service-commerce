import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart'
    show AuthRuntime, authRuntimeProvider;
import 'package:antinvestor_ui_core/api/api_base.dart'
    show authTokenProviderProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth/auth_bridge.dart';
import 'core/auth/migration.dart';
import 'core/auth/runtime_provider.dart';
import 'core/config/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  // One-time migration: wipe legacy auth-stack tokens from secure storage
  // so the runtime prompts for a fresh sign-in on the first launch after
  // upgrading to the runtime-based stack. Subsequent launches no-op via
  // a flag persisted in SharedPreferences.
  await migrateLegacyAuthIfNeeded();

  // Construct the auth runtime once at app start so every ProviderScope
  // consumer shares the same instance.
  final AuthRuntime authRuntime = buildConsoleRuntime();

  runApp(
    ProviderScope(
      overrides: [
        // Share the single runtime instance with every consumer of
        // `authRuntimeProvider`.
        authRuntimeProvider.overrideWithValue(authRuntime),

        // Bridge the runtime onto ui_core's AuthTokenProvider contract
        // so the route-module transport providers (catalog, orders,
        // inventory, …) can participate in the console's auth
        // lifecycle. The bridge currently no-ops on tokens — modules
        // ride the runtime's outbound `fetch` pipeline once it grows
        // a public token accessor — but `logout()` flows through.
        authTokenProviderProvider.overrideWith(
          (ref) => ConsoleAuthBridge(ref.watch(authRuntimeProvider)),
        ),
      ],
      child: const ConsoleApp(),
    ),
  );
}
