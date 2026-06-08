import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_pricing/src/widgets/price_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceListCard', () {
    late PriceList priceList;

    setUp(() {
      priceList = PriceList(
        id: 'pl-123',
        name: 'Wholesale Prices',
        currency: 'KES',
        priority: 10,
        status: PriceListStatus.PRICE_LIST_STATUS_ACTIVE,
      );
    });

    Widget buildTestWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: PriceListCard(
            priceList: priceList,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders price list name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Wholesale Prices'), findsOneWidget);
    });

    testWidgets('renders currency and priority', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('KES | P10'), findsOneWidget);
    });

    testWidgets('invokes onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(PriceListCard));
      expect(tapped, isTrue);
    });

    testWidgets('falls back to ID when name is empty', (tester) async {
      priceList = PriceList(
        id: 'pl-456',
        currency: 'USD',
        status: PriceListStatus.PRICE_LIST_STATUS_DRAFT,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PriceListCard(priceList: priceList),
        ),
      ));
      expect(find.text('pl-456'), findsOneWidget);
    });

    testWidgets('uses Card with elevation 0 and border radius 12',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });
  });
}
