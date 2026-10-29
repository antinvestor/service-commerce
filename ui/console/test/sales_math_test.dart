import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;
import 'package:console/features/dashboard/data/sales_math.dart';
// fixnum comes with the protobuf SDK; the console cannot re-resolve its
// dependencies to list it (sibling SDKs need protobuf 6).
// ignore: depend_on_referenced_packages
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

OrderPayment _paid(String currency, int units, int nanos, DateTime at) =>
    OrderPayment(
      amount: Money(currencyCode: currency, units: Int64(units), nanos: nanos),
      paidAt: Timestamp.fromDateTime(at),
    );

void main() {
  final today = DateTime(2026, 10, 28);
  final morning = today.add(const Duration(hours: 9));
  final yesterday = today.subtract(const Duration(hours: 2));

  test('sums today\'s payments exactly, in minor units', () {
    final orders = [
      // Placed yesterday, an instalment paid today counts; yesterday's not.
      Order(
        payments: [
          _paid('KES', 100, 0, yesterday),
          _paid('KES', 0, 100000000, morning),
        ],
      ),
      Order(payments: [_paid('KES', 1249, 990000000, morning)]),
      // Another currency is never mixed in.
      Order(payments: [_paid('USD', 5, 0, morning)]),
    ];
    // 0.10 + 1249.99 = 1250.09: no float drift.
    expect(paidMinorSince(orders, today, 'KES'), 125009);
    expect(formatMinorMoney(125009, 'KES'), 'KES 1,250.09');
  });

  test('ten payments of 0.10 make exactly 1.00', () {
    final orders = [
      Order(
        payments: [
          for (var i = 0; i < 10; i++) _paid('KES', 0, 100000000, morning),
        ],
      ),
    ];
    expect(paidMinorSince(orders, today, 'KES'), 100);
    expect(formatMinorMoney(100, 'KES'), 'KES 1.00');
  });

  test('currencies without minor units are whole numbers', () {
    expect(currencyDigits('UGX'), 0);
    final orders = [
      Order(payments: [_paid('UGX', 15000, 0, morning)]),
    ];
    expect(paidMinorSince(orders, today, 'UGX'), 15000);
    expect(formatMinorMoney(15000, 'UGX'), 'UGX 15,000');
  });

  test('toMinor drops only sub-minor nanos', () {
    expect(toMinor(12, 345000000, 2), 1234);
    expect(toMinor(12, 999999999, 2), 1299);
    expect(toMinor(7, 0, 0), 7);
  });
}
