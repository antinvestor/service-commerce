import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show Order;
import 'package:intl/intl.dart';

/// Money arithmetic for the dashboard figures: integer minor units, never
/// floating point.

/// ISO 4217 minor-unit digits of [currency] (2 when unknown).
int currencyDigits(String currency) {
  if (currency.isEmpty) return 2;
  try {
    return NumberFormat.currency(name: currency).decimalDigits ?? 2;
  } catch (_) {
    return 2;
  }
}

/// Integer minor units of a Money's [units] and [nanos] for a currency with
/// [digits] minor digits; sub-minor nanos are dropped.
int toMinor(int units, int nanos, int digits) {
  var scale = 1;
  for (var i = 0; i < digits; i++) {
    scale *= 10;
  }
  return units * scale + nanos ~/ (1000000000 ~/ scale);
}

/// What was paid on [orders] at or after [since], in [currency] minor units:
/// each instalment counts on the day it was paid, whenever the order was
/// placed. Payments in another currency are left out rather than mixed in.
int paidMinorSince(List<Order> orders, DateTime since, String currency) {
  final digits = currencyDigits(currency);
  var total = 0;
  for (final order in orders) {
    for (final payment in order.payments) {
      if (!payment.hasPaidAt() || !payment.hasAmount()) continue;
      if (payment.paidAt.toDateTime().toLocal().isBefore(since)) continue;
      final amount = payment.amount;
      if (currency.isNotEmpty &&
          amount.currencyCode.toUpperCase() != currency) {
        continue;
      }
      total += toMinor(amount.units.toInt(), amount.nanos, digits);
    }
  }
  return total;
}

/// Formats [minor] units of [currency], e.g. `KES 1,250.00`, without going
/// through floating point.
String formatMinorMoney(int minor, String currency) {
  final digits = currencyDigits(currency);
  var scale = 1;
  for (var i = 0; i < digits; i++) {
    scale *= 10;
  }
  final sign = minor < 0 ? '-' : '';
  final abs = minor.abs();
  final whole = NumberFormat('#,##0').format(abs ~/ scale);
  final fraction = digits == 0
      ? ''
      : '.${(abs % scale).toString().padLeft(digits, '0')}';
  final amount = '$sign$whole$fraction';
  return currency.isEmpty ? amount : '$currency $amount';
}
