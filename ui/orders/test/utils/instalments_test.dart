import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_orders/src/utils/instalments.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) => Money(currencyCode: 'KES', units: Int64(units));

InstalmentRules _rules({
  int total = 100000,
  int paid = 0,
  bool allow = true,
  int deposit = 30,
  int instalment = 20,
}) => InstalmentRules(
  totalMinor: total,
  paidMinor: paid,
  balanceMinor: total - paid,
  currencyCode: 'KES',
  policy: PaymentPolicy(
    allowInstalments: allow,
    minDepositPercent: deposit,
    minInstalmentPercent: instalment,
  ),
);

void main() {
  group('parseMinor', () {
    test('parses whole and decimal amounts', () {
      expect(parseMinor('1250'), 125000);
      expect(parseMinor('1,250.5'), 125050);
      expect(parseMinor(' 0.07 '), 7);
    });

    test('rejects malformed amounts and more than two decimals', () {
      expect(parseMinor(''), isNull);
      expect(parseMinor('abc'), isNull);
      expect(parseMinor('-5'), isNull);
      expect(parseMinor('1.234'), isNull);
    });
  });

  test('money round-trips through minor units', () {
    final money = minorToMoney(125050, 'KES');
    expect(money.units, Int64(1250));
    expect(money.nanos, 500000000);
    expect(moneyToMinor(money), 125050);
    expect(formatMinor(125050, 'KES'), 'KES 1250.50');
  });

  group('InstalmentRules.validate', () {
    test('first payment must reach the deposit', () {
      final rules = _rules();
      expect(rules.minimumMinor, 30000);
      expect(rules.validate(29999), contains('deposit must be at least 30%'));
      expect(rules.validate(30000), isNull);
    });

    test('later payments must reach the minimum instalment', () {
      final rules = _rules(paid: 40000);
      expect(rules.minimumMinor, 20000);
      expect(
        rules.validate(19999),
        contains('instalment must be at least 20%'),
      );
      expect(rules.validate(20000), isNull);
    });

    test('the whole balance is always accepted', () {
      // Balance 150.00 is below the 20% (200.00) minimum instalment.
      final rules = _rules(paid: 85000);
      expect(rules.minimumMinor, 15000);
      expect(rules.validate(15000), isNull);
    });

    test('cannot exceed the balance', () {
      final rules = _rules(paid: 40000);
      expect(rules.validate(60001), contains('Cannot exceed the balance'));
    });

    test('without instalments only the whole balance is accepted', () {
      final rules = _rules(allow: false);
      expect(rules.allowsPartial, isFalse);
      expect(rules.minimumMinor, 100000);
      expect(rules.validate(50000), contains('must be paid in full'));
      expect(rules.validate(100000), isNull);
    });

    test('rejects zero and unparsable input', () {
      final rules = _rules();
      expect(rules.validate(0), isNotNull);
      expect(rules.validateInput(''), 'Amount is required');
      expect(rules.validateInput('12.345'), isNotNull);
      expect(rules.validateInput('300'), isNull);
    });

    test('rounds percentage minimums up', () {
      // 30% of 333.33 is 99.999, which must round up to 100.00.
      final rules = _rules(total: 33333);
      expect(rules.minimumMinor, 10000);
    });
  });

  test('fromOrder reads amounts, balance and policy from the order', () {
    final rules = InstalmentRules.fromOrder(
      Order(
        total: _kes(1000),
        amountPaid: _kes(400),
        balance: _kes(600),
        paymentPolicy: PaymentPolicy(allowInstalments: true),
      ),
    );
    expect(rules.totalMinor, 100000);
    expect(rules.paidMinor, 40000);
    expect(rules.balanceMinor, 60000);
    expect(rules.paidFraction, closeTo(0.4, 1e-9));
    expect(rules.currencyCode, 'KES');
  });

  test('policy summary describes the terms', () {
    final summary = paymentPolicySummary(
      PaymentPolicy(
        allowInstalments: true,
        minDepositPercent: 30,
        balanceDueDays: 14,
        fulfilAtPercent: 50,
        signalThresholds: [25, 50],
      ),
    );
    expect(summary, contains('30% deposit'));
    expect(summary, contains('within 14 days'));
    expect(summary, contains('fulfil at 50%'));
    expect(summary, contains('25/50%'));
    expect(paymentPolicySummary(PaymentPolicy()), 'Payment in full');
  });
}
