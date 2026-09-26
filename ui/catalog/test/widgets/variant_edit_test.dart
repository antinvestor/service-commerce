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
      expect(request.status,
          ProductVariantStatus.PRODUCT_VARIANT_STATUS_DISABLED);
      expect(request.updateMask.paths,
          containsAll(['name', 'price', 'stock_quantity', 'status']));
    });

    test('rejects invalid values with a readable message', () {
      FormatException? error(String price, String currency, String stock) {
        try {
          buildVariantUpdateRequest(_variant(),
              name: '',
              price: price,
              currency: currency,
              stock: stock,
              status: 'Active');
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

  testWidgets('edits a variant price and stock from the product page',
      (tester) async {
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
          catalogServiceClientProvider
              .overrideWithValue(CommerceServiceClient(transport)),
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

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    // Fields: name, price, currency, stock.
    await tester.enterText(fields.at(1), '250');
    await tester.enterText(fields.at(3), '40');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.price.units, Int64(250));
    expect(sent!.stockQuantity, Int64(40));
    expect(sent!.updateMask.paths, contains('stock_quantity'));
    expect(find.text('Variant updated.'), findsOneWidget);
    expect(find.text('40 in stock'), findsOneWidget);
  });
}
