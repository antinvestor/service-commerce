import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_customers/src/widgets/customer_card.dart';
import 'package:antinvestor_ui_customers/src/widgets/customer_credit_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerCard', () {
    late ProfileObject profile;

    setUp(() {
      profile = ProfileObject(
        id: 'cust-123',
        type: ProfileType.PERSON,
        state: STATE.ACTIVE,
        properties: Struct(
          fields: {
            'name': Value(stringValue: 'Jane Doe'),
          },
        ),
      );
    });

    Widget buildTestWidget({
      VoidCallback? onTap,
      double? balanceAmount,
      CreditStatus creditStatus = CreditStatus.paidUp,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CustomerCard(
            profile: profile,
            onTap: onTap,
            balanceAmount: balanceAmount,
            creditStatus: creditStatus,
          ),
        ),
      );
    }

    testWidgets('renders customer name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('renders credit badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(CustomerCreditBadge), findsOneWidget);
    });

    testWidgets('shows balance when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        balanceAmount: 1500.50,
        creditStatus: CreditStatus.hasBalance,
      ));
      expect(find.text('1500.50'), findsOneWidget);
      expect(find.text('balance'), findsOneWidget);
    });

    testWidgets('invokes onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(CustomerCard));
      expect(tapped, isTrue);
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
