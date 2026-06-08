import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/src/widgets/product_card.dart';
import 'package:antinvestor_ui_catalog/src/widgets/product_status_badge.dart';
import 'package:antinvestor_ui_catalog/src/widgets/fulfilment_type_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard', () {
    late Product product;

    setUp(() {
      product = Product(
        id: 'prod-123',
        name: 'Test Widget Product',
        description: 'A product for testing',
        status: ProductStatus.PRODUCT_STATUS_ACTIVE,
        fulfilmentType: FulfilmentType.FULFILMENT_TYPE_PHYSICAL,
      );
    });

    Widget buildTestWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders product name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Test Widget Product'), findsOneWidget);
    });

    testWidgets('renders product status badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(ProductStatusBadge), findsOneWidget);
    });

    testWidgets('renders fulfilment type badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(FulfilmentTypeBadge), findsOneWidget);
    });

    testWidgets('shows description tooltip icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('invokes onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });

    testWidgets('falls back to ID when name is empty', (tester) async {
      product = Product(
        id: 'prod-456',
        status: ProductStatus.PRODUCT_STATUS_ACTIVE,
        fulfilmentType: FulfilmentType.FULFILMENT_TYPE_DIGITAL,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ));
      expect(find.text('prod-456'), findsOneWidget);
    });

    testWidgets('uses Card with elevation 0 and border radius 12',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      final shape = card.shape as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        BorderRadius.circular(12),
      );
    });
  });
}
