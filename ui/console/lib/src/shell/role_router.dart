import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coarse user role buckets used to seed which primary destination the
/// shell should land on after sign-in.
///
/// Production code will replace this with a richer mapping driven by
/// the platform's role taxonomy and per-tenant configuration. The
/// router is intentionally placed alongside the shell so the rest of
/// the app can stay role-agnostic.
enum ConsoleRole { operations, production, finance, admin, unknown }

ConsoleRole _classify(List<String> roles) {
  if (roles.any((r) => r.contains('admin'))) return ConsoleRole.admin;
  if (roles.any((r) => r.contains('production') || r.contains('factory'))) {
    return ConsoleRole.production;
  }
  if (roles.any((r) => r.contains('finance') || r.contains('account'))) {
    return ConsoleRole.finance;
  }
  if (roles.any((r) => r.contains('ops') || r.contains('sales'))) {
    return ConsoleRole.operations;
  }
  return ConsoleRole.unknown;
}

/// Best-effort role for the current user.
final consoleRoleProvider = Provider<ConsoleRole>((ref) {
  final rolesAsync = ref.watch(rolesProvider);
  return rolesAsync.maybeWhen(
    data: _classify,
    orElse: () => ConsoleRole.unknown,
  );
});

/// Initial deep-link target for a given role. Used by the shell to
/// pick a sensible default surface after sign-in.
String initialRouteForRole(ConsoleRole role) {
  switch (role) {
    case ConsoleRole.production:
      return '/production';
    case ConsoleRole.finance:
      return '/payments';
    case ConsoleRole.operations:
      return '/orders';
    case ConsoleRole.admin:
    case ConsoleRole.unknown:
      return '/';
  }
}
