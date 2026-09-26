import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:connectrpc/test.dart';
import 'package:console/core/auth/active_shop_provider.dart';
import 'package:console/core/auth/tenant_context_provider.dart';
import 'package:console/core/services/commerce_client_provider.dart';
import 'package:console/core/widgets/shop_switcher.dart';
import 'package:console/features/auth/data/auth_state_provider.dart';
import 'package:console/features/settings/data/shop_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedIn extends AuthStateNotifier {
  @override
  Future<AuthState> build() async => AuthState.authenticated;
}

Shop _shop(String id, {ShopStatus status = ShopStatus.SHOP_STATUS_ACTIVE}) =>
    Shop(id: id, name: 'Shop $id', slug: id, status: status);

/// In-memory stand-in for the commerce service's shop RPCs.
class _FakeShopBackend {
  _FakeShopBackend(this.shops, {this.pageSize = 100});

  final List<Shop> shops;
  final int pageSize;
  final List<ListShopsRequest> listRequests = [];

  CommerceServiceClient client() => CommerceServiceClient(
        FakeTransportBuilder()
            .unary(CommerceService.listShops, (req, _) {
              listRequests.add(req);
              final page = req.search.cursor.page;
              final start = page.isEmpty ? 0 : int.parse(page);
              final end = (start + pageSize).clamp(0, shops.length);
              return ListShopsResponse(
                shops: shops.sublist(start, end),
                nextPage: end < shops.length ? '$end' : '',
              );
            })
            .unary(CommerceService.createShop, (req, _) {
              final created = Shop(
                id: 'srv-generated-${shops.length}',
                name: req.name,
                slug: req.slug,
                status: ShopStatus.SHOP_STATUS_ACTIVE,
              );
              shops.add(created);
              return CreateShopResponse(shop: created);
            })
            .build(),
      );
}

ProviderContainer _container(_FakeShopBackend backend) {
  final container = ProviderContainer(
    overrides: [
      consoleAuthStateProvider.overrideWith(_SignedIn.new),
      commerceServiceClientProvider.overrideWithValue(backend.client()),
    ],
  );
  addTearDown(container.dispose);
  // Keep the listing mounted, as the shell's shop switcher does in the app.
  container.listen(shopListProvider, (_, _) {});
  return container;
}

void main() {
  group('resolveActiveShop', () {
    final disabled = _shop('a', status: ShopStatus.SHOP_STATUS_DISABLED);
    final active = _shop('b');
    final other = _shop('c');

    test('returns null when there are no shops', () {
      expect(resolveActiveShop(const [], 'x'), isNull);
    });

    test('prefers the explicitly selected shop', () {
      expect(resolveActiveShop([disabled, active, other], 'c'), other);
      expect(resolveActiveShop([disabled, active, other], 'a'), disabled);
    });

    test('defaults to the first active shop', () {
      expect(resolveActiveShop([disabled, active, other], null), active);
    });

    test('ignores a selection that is no longer listed', () {
      expect(resolveActiveShop([disabled, active], 'gone'), active);
    });

    test('falls back to the first shop when none is active', () {
      expect(resolveActiveShop([disabled], null), disabled);
    });
  });

  group('shop scope', () {
    test('tenant scope uses the listed shop id, not the partition', () async {
      final backend = _FakeShopBackend([
        _shop('disabled', status: ShopStatus.SHOP_STATUS_DISABLED),
        _shop('shop-1'),
      ]);
      final container = _container(backend);

      expect(container.read(tenantScopeProvider).shopId, isEmpty);
      await container.read(shopListProvider.future);

      final scope = container.read(tenantScopeProvider);
      expect(scope.shopId, 'shop-1');
      expect(scope.shopName, 'Shop shop-1');
    });

    test('pages through every ListShops page', () async {
      final backend = _FakeShopBackend(
        [for (var i = 0; i < 5; i++) _shop('shop-$i')],
        pageSize: 2,
      );
      final container = _container(backend);

      final shops = await container.read(shopListProvider.future);

      expect(shops.map((s) => s.id), [for (var i = 0; i < 5; i++) 'shop-$i']);
      expect(backend.listRequests, hasLength(3));
    });

    test('lists nothing while signed out', () async {
      final backend = _FakeShopBackend([_shop('shop-1')]);
      final container = ProviderContainer(
        overrides: [
          consoleAuthStateProvider.overrideWith(_SignedOut.new),
          commerceServiceClientProvider.overrideWithValue(backend.client()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(shopListProvider, (_, _) {});

      expect(await container.read(shopListProvider.future), isEmpty);
      expect(backend.listRequests, isEmpty);
    });

    test('switching shop updates the scope', () async {
      final backend = _FakeShopBackend([_shop('shop-1'), _shop('shop-2')]);
      final container = _container(backend);
      await container.read(shopListProvider.future);
      expect(container.read(tenantScopeProvider).shopId, 'shop-1');

      container.read(selectedShopIdProvider.notifier).select('shop-2');

      expect(container.read(tenantScopeProvider).shopId, 'shop-2');
    });

    test('CreateShop makes the server-generated shop active', () async {
      final backend = _FakeShopBackend([_shop('shop-1')]);
      final container = _container(backend);
      await container.read(shopListProvider.future);

      final created = await container
          .read(shopNotifierProvider.notifier)
          .create(name: 'Second', slug: 'second', description: '');
      await container.read(shopListProvider.future);

      expect(created.id, 'srv-generated-1');
      expect(container.read(tenantScopeProvider).shopId, 'srv-generated-1');
      expect((await container.read(currentShopProvider.future))?.name,
          'Second');
    });

    test('currentShopProvider is null when no shop exists yet', () async {
      final container = _container(_FakeShopBackend([]));
      expect(await container.read(currentShopProvider.future), isNull);
    });
  });

  group('ShopSwitcher', () {
    Future<ProviderContainer> pumpSwitcher(
      WidgetTester tester,
      List<Shop> shops,
    ) async {
      final container = ProviderContainer(
        overrides: [shopListProvider.overrideWith((ref) async => shops)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: Center(child: ShopSwitcher())),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('shows the single shop without a menu', (tester) async {
      await pumpSwitcher(tester, [_shop('only')]);
      expect(find.text('Shop only'), findsOneWidget);
      expect(find.byKey(const ValueKey('shop-switcher')), findsNothing);
    });

    testWidgets('offers a create hint when there are no shops',
        (tester) async {
      await pumpSwitcher(tester, const []);
      expect(find.text('No shop yet — create one'), findsOneWidget);
    });

    testWidgets('switches the active shop from the menu', (tester) async {
      final container =
          await pumpSwitcher(tester, [_shop('one'), _shop('two')]);
      expect(find.text('Shop one'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('shop-switcher')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Shop two'),
      );
      await tester.pumpAndSettle();

      expect(container.read(selectedShopIdProvider), 'two');
      expect(container.read(activeShopProvider)?.id, 'two');
      expect(find.text('Shop two'), findsOneWidget);
    });
  });
}

class _SignedOut extends AuthStateNotifier {
  @override
  Future<AuthState> build() async => AuthState.unauthenticated;
}
