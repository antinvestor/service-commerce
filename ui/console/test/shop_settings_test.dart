import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:connectrpc/connect.dart' show Code, ConnectException;
import 'package:connectrpc/test.dart';
import 'package:console/core/services/commerce_client_provider.dart';
import 'package:console/features/auth/data/auth_state_provider.dart';
import 'package:console/features/settings/data/shop_providers.dart';
import 'package:console/features/settings/shop_settings_section.dart';
import 'package:console/features/settings/storefront_settings.dart';
import 'package:console/features/settings/webhook_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedIn extends AuthStateNotifier {
  @override
  Future<AuthState> build() async => AuthState.authenticated;
}

CommerceServiceClient _client({
  ResolveDefaultCurrencyResponse Function()? resolve,
  List<UpdateShopRequest>? updates,
  List<Shop> shops = const [],
}) {
  return CommerceServiceClient(
    FakeTransportBuilder()
        .unary(CommerceService.resolveDefaultCurrency, (req, _) {
          if (resolve == null) {
            throw ConnectException(Code.unavailable, 'down');
          }
          return resolve();
        })
        .unary(
          CommerceService.listShops,
          (req, _) => ListShopsResponse(shops: shops),
        )
        .unary(CommerceService.updateShop, (req, _) {
          updates?.add(req);
          return UpdateShopResponse(shop: Shop(id: req.id));
        })
        .build(),
  );
}

Future<void> _pumpNoShop(WidgetTester tester, CommerceServiceClient client) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        consoleAuthStateProvider.overrideWith(_SignedIn.new),
        commerceServiceClientProvider.overrideWithValue(client),
      ],
      child: const MaterialApp(home: Scaffold(body: ShopSettingsSection())),
    ),
  );
}

/// Opens [WebhookSettingsDialog] and returns a reader for what it popped.
Future<WebhookEdit? Function()> _openWebhookDialog(
  WidgetTester tester, {
  String url = '',
  bool secretSet = false,
}) async {
  WebhookEdit? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<WebhookEdit>(
              context: context,
              builder: (_) =>
                  WebhookSettingsDialog(initialUrl: url, secretSet: secretSet),
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  group('currencySourceHint', () {
    test('maps every source to its explanation', () {
      expect(
        currencySourceHint(CurrencySource.CURRENCY_SOURCE_PREFERENCE),
        'From your currency preference',
      );
      expect(
        currencySourceHint(CurrencySource.CURRENCY_SOURCE_DEVICE),
        "From your device's location",
      );
      expect(
        currencySourceHint(CurrencySource.CURRENCY_SOURCE_ADDRESS),
        'From your profile address',
      );
      expect(
        currencySourceHint(CurrencySource.CURRENCY_SOURCE_PLATFORM_DEFAULT),
        'Platform default',
      );
      expect(
        currencySourceHint(CurrencySource.CURRENCY_SOURCE_UNSPECIFIED),
        'Suggested default',
      );
    });
  });

  group('resolveDefaultCurrencySuggestion', () {
    test('uses the resolved currency and names its source', () async {
      final suggestion = await resolveDefaultCurrencySuggestion(
        _client(
          resolve: () => ResolveDefaultCurrencyResponse(
            currency: 'ugx',
            source: CurrencySource.CURRENCY_SOURCE_DEVICE,
          ),
        ),
      );
      expect(suggestion.currency, 'UGX');
      expect(suggestion.hint, startsWith("From your device's location"));
    });

    test('leaves the currency empty when the call fails', () async {
      final suggestion = await resolveDefaultCurrencySuggestion(_client());
      expect(suggestion.currency, isEmpty);
      expect(suggestion.hint, defaultCurrencyUnavailableHint);
    });
  });

  group('create shop form', () {
    testWidgets('pre-fills the resolved currency with its source', (
      tester,
    ) async {
      await _pumpNoShop(
        tester,
        _client(
          resolve: () => ResolveDefaultCurrencyResponse(
            currency: 'TZS',
            source: CurrencySource.CURRENCY_SOURCE_ADDRESS,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create shop'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Currency'),
      );
      expect(field.controller!.text, 'TZS');
      expect(find.textContaining('From your profile address'), findsOneWidget);
      expect(find.text('KES'), findsNothing);
    });

    testWidgets('leaves the currency empty and says why when lookup fails', (
      tester,
    ) async {
      await _pumpNoShop(tester, _client());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create shop'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Currency'),
      );
      expect(field.controller!.text, isEmpty);
      expect(find.text(defaultCurrencyUnavailableHint), findsOneWidget);
    });
  });

  group('validateWebhookUrl', () {
    test('accepts empty and public https URLs', () {
      expect(validateWebhookUrl(''), isNull);
      expect(validateWebhookUrl('  '), isNull);
      expect(validateWebhookUrl('https://hooks.example.com/commerce'), isNull);
      expect(validateWebhookUrl('https://8.8.8.8:8443/h?x=1'), isNull);
    });

    test('rejects non-https schemes', () {
      expect(validateWebhookUrl('http://example.com/h'), contains('https'));
      expect(validateWebhookUrl('ftp://example.com/h'), contains('https'));
    });

    test('rejects malformed URLs', () {
      expect(validateWebhookUrl('example.com/hook'), isNotNull);
      expect(validateWebhookUrl('https://'), isNotNull);
      expect(validateWebhookUrl('not a url'), isNotNull);
    });

    test('rejects credentials and fragments', () {
      expect(validateWebhookUrl('https://u:p@example.com/h'), isNotNull);
      expect(validateWebhookUrl('https://example.com/h#frag'), isNotNull);
    });

    test('rejects local and private hosts', () {
      for (final url in [
        'https://localhost/h',
        'https://api.localhost/h',
        'https://127.0.0.1/h',
        'https://10.1.2.3/h',
        'https://172.16.0.1/h',
        'https://192.168.1.10/h',
        'https://169.254.169.254/latest',
        'https://[::1]/h',
        'https://[fd00::1]/h',
      ]) {
        expect(validateWebhookUrl(url), contains('public'), reason: url);
      }
    });
  });

  group('WebhookSettingsDialog', () {
    testWidgets('blocks saving an http URL', (tester) async {
      await _openWebhookDialog(tester);
      await tester.enterText(
        find.byKey(const Key('webhook-url')),
        'http://example.com/hook',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('The webhook URL must use https.'), findsOneWidget);
      expect(find.byType(WebhookSettingsDialog), findsOneWidget);
    });

    testWidgets('returns the URL and a new secret', (tester) async {
      final result = await _openWebhookDialog(tester, secretSet: true);
      expect(
        find.text('A secret is set. Leave blank to keep it.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('webhook-url')),
        'https://hooks.example.com/c',
      );
      await tester.enterText(find.byKey(const Key('webhook-secret')), 's3cr3t');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(WebhookSettingsDialog), findsNothing);
      expect(result()?.url, 'https://hooks.example.com/c');
      expect(result()?.secret, 's3cr3t');
    });

    testWidgets('a blank secret keeps the stored one', (tester) async {
      final result = await _openWebhookDialog(
        tester,
        url: 'https://a.example.com',
        secretSet: true,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result()?.url, 'https://a.example.com');
      expect(result()?.secret, isNull);
    });
  });

  group('ShopNotifier.updateWebhook', () {
    test('masks only the webhook fields that were passed', () async {
      final updates = <UpdateShopRequest>[];
      final container = ProviderContainer(
        overrides: [
          consoleAuthStateProvider.overrideWith(_SignedIn.new),
          commerceServiceClientProvider.overrideWithValue(
            _client(updates: updates),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(shopNotifierProvider.notifier);

      await notifier.updateWebhook(id: 's1', url: 'https://x.example.com');
      await notifier.updateWebhook(id: 's1', secret: '');
      await notifier.updateWebhook(
        id: 's1',
        url: 'https://y.example.com',
        secret: 'new',
      );

      expect(updates[0].updateMask.paths, ['webhook_url']);
      expect(updates[0].webhookUrl, 'https://x.example.com');
      expect(updates[1].updateMask.paths, ['webhook_secret']);
      expect(updates[1].webhookSecret, isEmpty);
      expect(updates[2].updateMask.paths, ['webhook_url', 'webhook_secret']);
      expect(updates[2].webhookSecret, 'new');
    });
  });

  group('Storefront', () {
    test('masks public_storefront so closing it is written', () async {
      final updates = <UpdateShopRequest>[];
      final container = ProviderContainer(
        overrides: [
          consoleAuthStateProvider.overrideWith(_SignedIn.new),
          commerceServiceClientProvider.overrideWithValue(
            _client(updates: updates),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(shopNotifierProvider.notifier);

      await notifier.updateStorefront(id: 's1', enabled: true);
      await notifier.updateStorefront(id: 's1', enabled: false);

      expect(updates.map((u) => u.updateMask.paths), [
        ['public_storefront'],
        ['public_storefront'],
      ]);
      expect(updates.map((u) => u.publicStorefront), [true, false]);
    });

    testWidgets('shows the link when open and toggles it', (tester) async {
      final updates = <UpdateShopRequest>[];
      final shop = Shop(
        id: 's1',
        status: ShopStatus.SHOP_STATUS_ACTIVE,
        publicStorefront: true,
        storefrontUrl: 'https://api.example/commerce/shop/corner',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            consoleAuthStateProvider.overrideWith(_SignedIn.new),
            commerceServiceClientProvider.overrideWithValue(
              _client(updates: updates),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: StorefrontSettingsSection(shop: shop)),
          ),
        ),
      );

      expect(
        find.text('https://api.example/commerce/shop/corner'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('storefront-switch')));
      await tester.pumpAndSettle();
      expect(updates.single.publicStorefront, isFalse);
      expect(find.text('Storefront closed.'), findsOneWidget);
    });
  });

  group('ShopNotifier.updatePaymentPolicy', () {
    test('writes only payment_policy, and clears it with null', () async {
      final updates = <UpdateShopRequest>[];
      final container = ProviderContainer(
        overrides: [
          consoleAuthStateProvider.overrideWith(_SignedIn.new),
          commerceServiceClientProvider.overrideWithValue(
            _client(updates: updates),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(shopNotifierProvider.notifier);

      await notifier.updatePaymentPolicy(
        id: 's1',
        policy: PaymentPolicy(allowInstalments: true, minDepositPercent: 30),
      );
      await notifier.updatePaymentPolicy(id: 's1');

      expect(updates[0].updateMask.paths, ['payment_policy']);
      expect(updates[0].paymentPolicy.minDepositPercent, 30);
      expect(updates[1].updateMask.paths, ['payment_policy']);
      expect(updates[1].hasPaymentPolicy(), isFalse);
    });
  });

  group('paymentPolicySummary', () {
    test('describes an unset policy', () {
      expect(
        paymentPolicySummary(Shop(id: 's')).single,
        contains('Not configured'),
      );
    });

    test('describes an instalment policy', () {
      final lines = paymentPolicySummary(
        Shop(
          id: 's',
          paymentPolicy: PaymentPolicy(
            allowInstalments: true,
            minDepositPercent: 30,
            minInstalmentPercent: 10,
            balanceDueDays: 14,
            signalThresholds: [50, 75],
            cancelWhenOverdue: true,
          ),
        ),
      );
      expect(lines, contains('Minimum deposit: 30%'));
      expect(lines, contains('Fulfil at: 100% paid'));
      expect(lines, contains('Signal thresholds: 50%, 75%'));
      expect(lines.join('\n'), contains('14 days'));
    });
  });
}
