import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_pricing/src/widgets/discount_approval_status.dart';
import 'package:antinvestor_ui_pricing/src/widgets/discount_rule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DiscountRule _rule({
  bool requiresApproval = true,
  String approvedBy = '',
  DateTime? approvedAt,
}) {
  final rule = DiscountRule(
    id: 'rule-1',
    name: 'Bulk 10%',
    discountType: DiscountType.DISCOUNT_TYPE_PERCENTAGE,
    value: 10,
    appliesTo: DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM,
    status: DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE,
    requiresApproval: requiresApproval,
    approvedBy: approvedBy,
  );
  if (approvedAt != null) rule.approvedAt = Timestamp.fromDateTime(approvedAt);
  return rule;
}

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('DiscountApprovalState.of', () {
    test('not required when approval is off', () {
      expect(
        DiscountApprovalState.of(_rule(requiresApproval: false)),
        DiscountApprovalState.notRequired,
      );
    });

    test('pending when required and not approved', () {
      expect(DiscountApprovalState.of(_rule()), DiscountApprovalState.pending);
    });

    test('approved when approver or approval time is set', () {
      expect(
        DiscountApprovalState.of(_rule(approvedBy: 'prof-1')),
        DiscountApprovalState.approved,
      );
      expect(
        DiscountApprovalState.of(_rule(approvedAt: DateTime.utc(2026, 9, 1))),
        DiscountApprovalState.approved,
      );
    });
  });

  group('DiscountApprovalStatus', () {
    testWidgets('renders nothing when approval is not required', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DiscountApprovalStatus(
            rule: _rule(requiresApproval: false),
            onApprove: () {},
          ),
        ),
      );
      expect(find.text('Pending approval'), findsNothing);
      expect(find.text('Approved'), findsNothing);
      expect(find.text('Approve'), findsNothing);
    });

    testWidgets('pending shows badge and an Approve button that calls back', (
      tester,
    ) async {
      var approved = 0;
      await tester.pumpWidget(
        _wrap(
          DiscountApprovalStatus(rule: _rule(), onApprove: () => approved++),
        ),
      );
      expect(find.text('Pending approval'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      expect(approved, 1);
    });

    testWidgets('pending without onApprove hides the button', (tester) async {
      await tester.pumpWidget(_wrap(DiscountApprovalStatus(rule: _rule())));
      expect(find.text('Pending approval'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
    });

    testWidgets('disables Approve while approving', (tester) async {
      var approved = 0;
      await tester.pumpWidget(
        _wrap(
          DiscountApprovalStatus(
            rule: _rule(),
            approving: true,
            onApprove: () => approved++,
          ),
        ),
      );
      await tester.tap(find.text('Approve'));
      expect(approved, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('approved shows who approved and when', (tester) async {
      final at = DateTime(2026, 9, 28, 14, 5);
      await tester.pumpWidget(
        _wrap(
          DiscountApprovalStatus(
            rule: _rule(approvedBy: 'prof-42', approvedAt: at),
            onApprove: () {},
          ),
        ),
      );
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('by prof-42 on 2026-09-28 14:05'), findsOneWidget);
      expect(find.text('Pending approval'), findsNothing);
      expect(find.text('Approve'), findsNothing);
    });
  });

  group('DiscountRuleCard approval', () {
    testWidgets('shows pending badge and approve action', (tester) async {
      var approved = false;
      await tester.pumpWidget(
        _wrap(
          DiscountRuleCard(rule: _rule(), onApprove: () => approved = true),
        ),
      );
      expect(find.text('Pending approval'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      expect(approved, isTrue);
    });

    testWidgets('omits approval UI for rules that do not need it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DiscountRuleCard(
            rule: _rule(requiresApproval: false),
            onApprove: () {},
          ),
        ),
      );
      expect(find.text('Pending approval'), findsNothing);
      expect(find.text('Approve'), findsNothing);
    });
  });
}
