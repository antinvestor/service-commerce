import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:connectrpc/connect.dart' show Transport;
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void _bigView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Transport transport, Widget home) => ProviderScope(
  overrides: [
    catalogServiceClientProvider.overrideWithValue(
      CommerceServiceClient(transport),
    ),
  ],
  child: MaterialApp(home: Scaffold(body: home)),
);

void main() {
  group('buildProductUpdateRequest', () {
    final product = Product(
      id: 'prod-1',
      shopId: 'shop-1',
      name: 'Tea',
      description: 'Loose leaf',
      attributes: {'origin': 'Kericho'},
      fulfilmentType: FulfilmentType.FULFILMENT_TYPE_PHYSICAL,
      status: ProductStatus.PRODUCT_STATUS_ACTIVE,
      paymentPolicy: PaymentPolicy(allowInstalments: true),
    );

    UpdateProductRequest? build({
      String name = 'Tea',
      Map<String, String>? attributes,
      FulfilmentType fulfilment = FulfilmentType.FULFILMENT_TYPE_PHYSICAL,
      ProductStatus status = ProductStatus.PRODUCT_STATUS_ACTIVE,
      PaymentPolicy? policy,
      bool keepPolicy = true,
    }) => buildProductUpdateRequest(
      product,
      name: name,
      description: 'Loose leaf',
      attributes: attributes ?? {'origin': 'Kericho'},
      fulfilmentType: fulfilment,
      status: status,
      paymentPolicy: keepPolicy
          ? (policy ?? PaymentPolicy(allowInstalments: true))
          : null,
    );

    test('returns null when nothing changed', () {
      expect(build(), isNull);
    });

    test('masks only the edited fields', () {
      final request = build(
        name: 'Green tea',
        fulfilment: FulfilmentType.FULFILMENT_TYPE_DIGITAL,
        status: ProductStatus.PRODUCT_STATUS_ARCHIVED,
        attributes: {'origin': 'Nandi'},
      )!;
      expect(request.id, 'prod-1');
      expect(request.updateMask.paths, [
        'name',
        'attributes',
        'fulfilment_type',
        'status',
      ]);
      expect(request.name, 'Green tea');
      expect(request.attributes, {'origin': 'Nandi'});
    });

    test('removing the override masks payment_policy with it unset', () {
      final request = build(keepPolicy: false)!;
      expect(request.updateMask.paths, ['payment_policy']);
      expect(request.hasPaymentPolicy(), isFalse);
    });

    test('changing the override sends it', () {
      final request = build(
        policy: PaymentPolicy(allowInstalments: true, minDepositPercent: 20),
      )!;
      expect(request.updateMask.paths, ['payment_policy']);
      expect(request.paymentPolicy.minDepositPercent, 20);
    });

    test('rejects an empty name or an invalid policy', () {
      expect(() => build(name: ' '), throwsFormatException);
      expect(
        () => build(
          policy: PaymentPolicy(allowInstalments: true, fulfilAtPercent: 101),
        ),
        throwsFormatException,
      );
    });
  });

  testWidgets('product detail shows the policy and edits the product', (
    tester,
  ) async {
    _bigView(tester);
    var product = Product(
      id: 'prod-1',
      shopId: 'shop-1',
      name: 'Tea',
      fulfilmentType: FulfilmentType.FULFILMENT_TYPE_DIGITAL,
      status: ProductStatus.PRODUCT_STATUS_ACTIVE,
      paymentPolicy: PaymentPolicy(
        allowInstalments: true,
        minDepositPercent: 30,
      ),
    );
    UpdateProductRequest? sent;
    final transport = FakeTransportBuilder()
        .unary(
          CommerceService.getProduct,
          (req, _) => GetProductResponse(product: product),
        )
        .unary(
          CommerceService.getShop,
          (req, _) => GetShopResponse(
            shop: Shop(
              id: req.id,
              currency: 'KES',
              paymentPolicy: PaymentPolicy(allowInstalments: false),
            ),
          ),
        )
        .unary(
          CommerceService.listProductVariants,
          (req, _) => ListProductVariantsResponse(),
        )
        .unary(CommerceService.updateProduct, (req, _) {
          sent = req;
          product = Product(
            id: product.id,
            shopId: product.shopId,
            name: req.name,
            fulfilmentType: product.fulfilmentType,
            status: product.status,
          );
          return UpdateProductResponse(product: product);
        })
        .build();

    await tester.pumpWidget(
      _app(transport, const ProductDetailScreen(productId: 'prod-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Digital'), findsWidgets);
    expect(find.textContaining('30% deposit'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('product-edit-name')),
      'Green tea',
    );
    await tester.tap(find.text("Override the shop's payment policy"));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.updateMask.paths, ['name', 'payment_policy']);
    expect(sent!.hasPaymentPolicy(), isFalse);
    expect(find.text('Product updated.'), findsOneWidget);
    expect(find.text('Green tea'), findsWidgets);
    expect(find.text('Shop policy (Pay in full)'), findsOneWidget);
  });

  testWidgets('catalog loads more products with the next page cursor', (
    tester,
  ) async {
    _bigView(tester);
    final requests = <ListProductsRequest>[];
    final transport = FakeTransportBuilder().unary(
      CommerceService.listProducts,
      (req, _) {
        requests.add(req);
        if (req.search.cursor.page.isEmpty) {
          return ListProductsResponse(
            products: [Product(id: 'p-1', name: 'First')],
            nextPage: 'cursor-2',
          );
        }
        return ListProductsResponse(
          products: [Product(id: 'p-2', name: 'Second')],
        );
      },
    ).build();

    await tester.pumpWidget(
      _app(transport, const CatalogBrowseScreen(shopId: 'shop-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(requests.last.search.cursor.page, 'cursor-2');
    expect(requests.last.shopId, 'shop-1');
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets(
    'variant create defaults to the shop currency and sends decimals',
    (tester) async {
      _bigView(tester);
      CreateProductVariantRequest? sent;
      final transport = FakeTransportBuilder()
          .unary(
            CommerceService.getShop,
            (req, _) => GetShopResponse(
              shop: Shop(id: req.id, currency: 'TZS'),
            ),
          )
          .unary(CommerceService.createProductVariant, (req, _) {
            sent = req;
            return CreateProductVariantResponse(
              productVariant: ProductVariant(
                id: 'v-1',
                productId: req.productId,
              ),
            );
          })
          .build();

      final router = GoRouter(
        initialLocation: '/new',
        routes: [
          GoRoute(
            path: '/new',
            builder: (_, _) => const VariantCreateScreen(
              productId: 'prod-1',
              shopId: 'shop-1',
            ),
          ),
          GoRoute(
            path: '/catalog/:id',
            builder: (_, _) => const Text('detail page'),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogServiceClientProvider.overrideWithValue(
              CommerceServiceClient(transport),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Continue').first);
      await tester.pumpAndSettle();

      final currency = tester.widget<TextFormField>(
        find.byKey(const ValueKey('variant-create-currency')),
      );
      expect(currency.controller!.text, 'TZS');
      expect(find.textContaining('KES'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('variant-create-price')),
        '99.50',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Variant').last);
      await tester.pumpAndSettle();

      expect(sent, isNotNull);
      expect(sent!.price.currencyCode, 'TZS');
      expect(sent!.price.units, Int64(99));
      expect(sent!.price.nanos, 500000000);
      expect(find.text('detail page'), findsOneWidget);
    },
  );
}
