import 'package:antinvestor_ui_pricing/src/widgets/pricing_section_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('navigates to every pricing sub-page', (tester) async {
    Widget page(PricingSection section) => Scaffold(
      body: Column(
        children: [
          PricingSectionNav(current: section),
          Text('page:${section.name}'),
        ],
      ),
    );

    final router = GoRouter(
      initialLocation: '/pricing',
      routes: [
        GoRoute(
          path: '/pricing',
          builder: (_, _) => page(PricingSection.priceLists),
          routes: [
            GoRoute(
              path: 'overrides',
              builder: (_, _) => page(PricingSection.overrides),
            ),
            GoRoute(
              path: 'discounts',
              builder: (_, _) => page(PricingSection.discounts),
            ),
            GoRoute(
              path: 'checker',
              builder: (_, _) => page(PricingSection.checker),
            ),
          ],
        ),
      ],
    );
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('page:priceLists'), findsOneWidget);

    for (final section in [
      PricingSection.overrides,
      PricingSection.discounts,
      PricingSection.checker,
      PricingSection.priceLists,
    ]) {
      await tester.tap(find.text(section.label));
      await tester.pumpAndSettle();
      expect(find.text('page:${section.name}'), findsOneWidget);
    }
  });
}
