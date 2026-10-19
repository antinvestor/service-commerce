import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<PaymentPolicy?>> _pump(
  WidgetTester tester, {
  PaymentPolicy? initial,
  bool allowInherit = false,
}) async {
  final emitted = <PaymentPolicy?>[];
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PaymentPolicyEditor(
            initial: initial,
            allowInherit: allowInherit,
            onChanged: emitted.add,
          ),
        ),
      ),
    ),
  );
  return emitted;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

void main() {
  testWidgets('toggling instalments reveals the rules and reports them', (
    tester,
  ) async {
    final emitted = await _pump(tester);

    expect(find.text('Minimum deposit (%)'), findsNothing);
    await tester.tap(find.text('Allow instalments'));
    await tester.pumpAndSettle();
    expect(find.text('Minimum deposit (%)'), findsOneWidget);
    expect(emitted.last!.allowInstalments, isTrue);

    await tester.enterText(_field('Minimum deposit (%)'), '30');
    await tester.enterText(_field('Balance due (days)'), '14');
    await tester.enterText(_field('Fulfil at (%)'), '50');
    await tester.tap(find.text('Cancel when overdue'));
    await tester.pumpAndSettle();

    final policy = emitted.last!;
    expect(policy.minDepositPercent, 30);
    expect(policy.balanceDueDays, 14);
    expect(policy.fulfilAtPercent, 50);
    expect(policy.cancelWhenOverdue, isTrue);
    expect(validatePaymentPolicy(policy), isNull);

    await tester.tap(find.text('Allow instalments'));
    await tester.pumpAndSettle();
    expect(find.text('Minimum deposit (%)'), findsNothing);
    expect(emitted.last, PaymentPolicy(allowInstalments: false));
  });

  testWidgets('flags out-of-range values', (tester) async {
    final emitted = await _pump(
      tester,
      initial: PaymentPolicy(allowInstalments: true),
    );

    await tester.enterText(_field('Minimum deposit (%)'), '150');
    await tester.pump();
    expect(find.text('Enter 0 to 100'), findsOneWidget);
    expect(validatePaymentPolicy(emitted.last), contains('deposit'));

    await tester.enterText(_field('Minimum deposit (%)'), '20');
    await tester.enterText(_field('Balance due (days)'), '4000');
    await tester.pump();
    expect(find.text('Enter 0 to 3650'), findsOneWidget);
    expect(validatePaymentPolicy(emitted.last), contains('Balance due'));
  });

  testWidgets('threshold chips are sorted, deduplicated and range-checked', (
    tester,
  ) async {
    final emitted = await _pump(
      tester,
      initial: PaymentPolicy(allowInstalments: true, signalThresholds: [50]),
    );
    final input = find.byKey(const ValueKey('payment-policy-threshold-input'));

    for (final value in ['75', '25', '50']) {
      await tester.enterText(input, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }
    expect(emitted.last!.signalThresholds, [25, 50, 75]);
    expect(find.text('25%'), findsOneWidget);

    await tester.enterText(input, '0');
    await tester.tap(find.byTooltip('Add threshold'));
    await tester.pump();
    expect(find.text('Enter a whole number from 1 to 100'), findsOneWidget);
    expect(emitted.last!.signalThresholds, [25, 50, 75]);

    await tester.tap(find.byTooltip('Remove 50%'));
    await tester.pump();
    expect(emitted.last!.signalThresholds, [25, 75]);
  });

  testWidgets('inherit mode reports null until overridden', (tester) async {
    final emitted = await _pump(tester, allowInherit: true);

    expect(find.text('Use the shop policy'), findsOneWidget);
    expect(find.text('Allow instalments'), findsNothing);

    await tester.tap(find.text("Override the shop's payment policy"));
    await tester.pumpAndSettle();
    expect(find.text('Allow instalments'), findsOneWidget);
    expect(emitted.last, isNotNull);

    await tester.tap(find.text("Override the shop's payment policy"));
    await tester.pumpAndSettle();
    expect(emitted.last, isNull);
    expect(find.text('Allow instalments'), findsNothing);
  });

  testWidgets('an existing override starts in override mode', (tester) async {
    await _pump(
      tester,
      allowInherit: true,
      initial: PaymentPolicy(allowInstalments: true, minDepositPercent: 40),
    );
    expect(find.text('Allow instalments'), findsOneWidget);
    final deposit = tester.widget<TextField>(_field('Minimum deposit (%)'));
    expect(deposit.controller!.text, '40');
  });

  test('validatePaymentPolicy ignores rules when instalments are off', () {
    expect(validatePaymentPolicy(null), isNull);
    expect(
      validatePaymentPolicy(
        PaymentPolicy(allowInstalments: false, minDepositPercent: 500),
      ),
      isNull,
    );
    expect(
      validatePaymentPolicy(
        PaymentPolicy(allowInstalments: true, signalThresholds: [0]),
      ),
      contains('thresholds'),
    );
  });
}
