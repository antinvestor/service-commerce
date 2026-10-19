import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;
import 'package:antinvestor_ui_catalog/src/providers/catalog_transport_provider.dart';
import 'package:antinvestor_ui_catalog/src/screens/product_detail_screen.dart';
import 'package:antinvestor_ui_catalog/src/widgets/variant_edit_dialog.dart';
import 'package:connectrpc/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProductVariant _variant({Money? price, Int64? stock}) => ProductVariant(
  id: 'var-1',
  productId: 'prod-1',
  sku: 'SKU-1',
  name: 'Large',
  price: price ?? Money(currencyCode: 'KES', units: Int64(100)),
  stockQuantity: stock ?? Int64(5),
  status: ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE,
);

void main() {
  group('buildVariantUpdateRequest', () {
    test('masks price and stock so both are written', () {
      final request = buildVariantUpdateRequest(
        _variant(),
        name: ' Large ',
        price: '149.50',
        currency: 'kes',
        stock: '12',
        status: 'Disabled',
      );

      expect(request.variantId, 'var-1');
      expect(request.name, 'Large');
      expect(request.price.currencyCode, 'KES');
      expect(request.price.units, Int64(149));
      expect(request.price.nanos, 500000000);
      expect(request.stockQuantity, Int64(12));
      expect(
        request.status,
        ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED,
      );
      expect(
        request.updateMask.paths,
        containsAll(['name', 'price', 'stock_quantity', 'status']),
      );
    });

    test('masks sku and attributes only when they changed', () {
      final variant = _variant()..attributes['size'] = 'L';
      final unchanged = buildVariantUpdateRequest(
        variant,
        name: 'Large',
        price: '100',
        currency: 'KES',
        stock: '5',
        status: 'Active',
        sku: 'SKU-1',
        attributes: {'size': 'L'},
      );
      expect(unchanged.updateMask.paths, isNot(contains('sku')));
      expect(unchanged.updateMask.paths, isNot(contains('attributes')));

      final changed = buildVariantUpdateRequest(
        variant,
        name: 'Large',
        price: '99.5',
        currency: 'KES',
        stock: '5',
        status: 'Active',
        sku: ' SKU-2 ',
        attributes: {'size': 'XL', 'color': 'red'},
      );
      expect(changed.sku, 'SKU-2');
      expect(changed.attributes, {'size': 'XL', 'color': 'red'});
      expect(changed.updateMask.paths, containsAll(['sku', 'attributes']));
      expect(changed.price.units, Int64(99));
      expect(changed.price.nanos, 500000000);

      // Clearing every attribute is still masked so the server drops them.
      final cleared = buildVariantUpdateRequest(
        variant,
        name: 'Large',
        price: '100',
        currency: 'KES',
        stock: '5',
        status: 'Active',
        attributes: {},
      );
      expect(cleared.updateMask.paths, contains('attributes'));
      expect(cleared.attributes, isEmpty);
    });

    test('rejects invalid values with a readable message', () {
      FormatException? error(String price, String currency, String stock) {
        try {
          buildVariantUpdateRequest(
            _variant(),
            name: '',
            price: price,
            currency: currency,
            stock: stock,
            status: 'Active',
          );
          return null;
        } on FormatException catch (e) {
          return e;
        }
      }

      expect(error('abc', 'KES', '1')?.message, contains('Price'));
      expect(error('-5', 'KES', '1')?.message, contains('Price'));
      expect(error('10', 'KSHS', '1')?.message, contains('Currency'));
      expect(error('10', 'KES', '-1')?.message, contains('Stock'));
      expect(error('10', 'KES', '2.5')?.message, contains('Stock'));
      expect(error('10', 'KES', '0'), isNull);
    });
  });

  testWidgets('edits a variant price and stock from the product page', (
    tester,
  ) async {
    var variant = _variant();
    UpdateProductVariantRequest? sent;
    final transport = FakeTransportBuilder()
        .unary(
          CommerceService.getProduct,
          (req, _) => GetProductResponse(
            product: Product(id: req.id, shopId: 'shop-1', name: 'Tea'),
          ),
        )
        .unary(
          CommerceService.getShop,
          (req, _) => GetShopResponse(
            shop: Shop(id: req.id, currency: 'UGX'),
          ),
        )
        .unary(
          CommerceService.listProductVariants,
          (req, _) => ListProductVariantsResponse(productVariants: [variant]),
        )
        .unary(CommerceService.updateProductVariant, (req, _) {
          sent = req;
          variant = _variant(price: req.price, stock: req.stockQuantity);
          return UpdateProductVariantResponse(productVariant: variant);
        })
        .build();

    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogServiceClientProvider.overrideWithValue(
            CommerceServiceClient(transport),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ProductDetailScreen(productId: 'prod-1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('5 in stock'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit variant'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('variant-edit-price')),
      '250.75',
    );
    await tester.enterText(
      find.byKey(const ValueKey('variant-edit-stock')),
      '40',
    );
    await tester.enterText(
      find.byKey(const ValueKey('variant-edit-sku')),
      'SKU-9',
    );
    await tester.tap(find.text('Add attribute'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('attribute-key-0')),
      'size',
    );
    await tester.enterText(
      find.byKey(const ValueKey('attribute-value-0')),
      'L',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.price.units, Int64(250));
    expect(sent!.price.nanos, 750000000);
    expect(sent!.price.currencyCode, 'KES');
    expect(sent!.sku, 'SKU-9');
    expect(sent!.attributes, {'size': 'L'});
    expect(sent!.updateMask.paths, containsAll(['sku', 'attributes']));
    expect(sent!.stockQuantity, Int64(40));
    expect(sent!.updateMask.paths, contains('stock_quantity'));
    expect(find.text('Variant updated.'), findsOneWidget);
    expect(find.text('40 in stock'), findsOneWidget);
  });

  testWidgets('defaults an unpriced variant to the shop currency', (
    tester,
  ) async {
    final unpriced = ProductVariant(
      id: 'var-2',
      productId: 'prod-1',
      sku: 'SKU-2',
      stockQuantity: Int64(1),
      status: ProductVariantStatus.PRODUCT_VARIANT_STATUS_ACTIVE,
    );
    UpdateProductVariantRequest? sent;
    final transport = FakeTransportBuilder()
        .unary(
          CommerceService.getProduct,
          (req, _) => GetProductResponse(
            product: Product(id: req.id, shopId: 'shop-1', name: 'Tea'),
          ),
        )
        .unary(
          CommerceService.getShop,
          (req, _) => GetShopResponse(
            shop: Shop(id: req.id, currency: 'UGX'),
          ),
        )
        .unary(
          CommerceService.listProductVariants,
          (req, _) => ListProductVariantsResponse(productVariants: [unpriced]),
        )
        .unary(CommerceService.updateProductVariant, (req, _) {
          sent = req;
          return UpdateProductVariantResponse(productVariant: unpriced);
        })
        .build();

    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogServiceClientProvider.overrideWithValue(
            CommerceServiceClient(transport),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ProductDetailScreen(productId: 'prod-1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit variant'));
    await tester.pumpAndSettle();

    final currency = tester.widget<TextField>(
      find.byKey(const ValueKey('variant-edit-currency')),
    );
    expect(currency.controller!.text, 'UGX');

    await tester.enterText(
      find.byKey(const ValueKey('variant-edit-price')),
      '1500',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sent!.price.currencyCode, 'UGX');
    expect(sent!.price.units, Int64(1500));
  });
}
