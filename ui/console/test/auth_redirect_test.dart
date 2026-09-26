import 'package:console/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

String? redirect(String location, {bool loading = false, bool authed = false}) =>
    resolveAuthRedirect(
      uri: Uri.parse(location),
      isLoading: loading,
      isAuthenticated: authed,
    );

void main() {
  group('resolveAuthRedirect', () {
    test('fresh load of a deep link waits on splash and remembers it', () {
      expect(
        redirect('/orders/ord-1', loading: true),
        '/splash?from=%2Forders%2Ford-1',
      );
    });

    test('returns to the deep link once auth resolves', () {
      expect(
        redirect('/splash?from=%2Forders%2Ford-1', authed: true),
        '/orders/ord-1',
      );
    });

    test('keeps query parameters of the requested location', () {
      final splash = redirect('/catalog?q=tea', loading: true)!;
      expect(redirect(splash, authed: true), '/catalog?q=tea');
    });

    test('carries the deep link through login when signed out', () {
      final splash = redirect('/orders/ord-1', loading: true)!;
      final login = redirect(splash)!;
      expect(Uri.parse(login).path, '/login');
      expect(redirect(login), isNull);
      expect(redirect(login, authed: true), '/orders/ord-1');
    });

    test('protected route while signed out goes to login with from', () {
      expect(redirect('/settings'), '/login?from=%2Fsettings');
    });

    test('dashboard needs no from parameter', () {
      expect(redirect('/', loading: true), '/splash');
      expect(redirect('/'), '/login');
      expect(redirect('/splash', authed: true), '/');
      expect(redirect('/login', authed: true), '/');
    });

    test('lets the OAuth callback complete', () {
      expect(redirect('/auth/callback?code=x', loading: true), isNull);
      expect(redirect('/auth/callback?code=x'), isNull);
      expect(redirect('/auth/callback?code=x', authed: true), '/');
    });

    test('no redirect for an authenticated user on an app route', () {
      expect(redirect('/orders/ord-1', authed: true), isNull);
    });

    test('ignores unsafe or looping return targets', () {
      expect(redirect('/splash?from=https://evil.example', authed: true), '/');
      expect(redirect('/splash?from=//evil.example/x', authed: true), '/');
      expect(redirect('/splash?from=%2Flogin', authed: true), '/');
      expect(redirect('/login?from=orders', authed: true), '/');
    });
  });

  group('sanitizeReturnTo', () {
    test('accepts in-app paths', () {
      expect(sanitizeReturnTo('/orders/1?tab=pay'), '/orders/1?tab=pay');
    });

    test('rejects external, auth and root locations', () {
      expect(sanitizeReturnTo(null), isNull);
      expect(sanitizeReturnTo(''), isNull);
      expect(sanitizeReturnTo('/'), isNull);
      expect(sanitizeReturnTo('/splash'), isNull);
      expect(sanitizeReturnTo('/logout'), isNull);
      expect(sanitizeReturnTo('//evil.example'), isNull);
      expect(sanitizeReturnTo('https://evil.example/x'), isNull);
    });
  });
}
