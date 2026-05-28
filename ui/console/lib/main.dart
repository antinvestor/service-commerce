import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

/// Console auth configuration.
///
/// The production deployment wires real client credentials via
/// `--dart-define`; the defaults here are placeholders so the shell
/// builds and runs locally for the dashboard demo.
const AuthConfig _kConsoleAuthConfig = AuthConfig(
  clientId: String.fromEnvironment(
    'CONSOLE_OAUTH_CLIENT_ID',
    defaultValue: 'console-dev',
  ),
  idpBaseUrl: String.fromEnvironment(
    'CONSOLE_OAUTH_ISSUER',
    defaultValue: 'https://auth.antinvestor.com',
  ),
  apiBaseUrl: String.fromEnvironment(
    'CONSOLE_API_BASE_URL',
    defaultValue: 'https://api.antinvestor.com',
  ),
  redirectScheme: 'com.antinvestor.console',
  redirectUri: 'com.antinvestor.console://sso/redirect',
  scopes: <String>['openid', 'profile', 'offline_access'],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRuntime authRuntime = createAuthRuntime(_kConsoleAuthConfig);

  runApp(
    ProviderScope(
      overrides: [
        authRuntimeProvider.overrideWithValue(authRuntime),
      ],
      child: const ConsoleApp(),
    ),
  );
}
