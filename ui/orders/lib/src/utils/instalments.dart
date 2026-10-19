import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// Money is not re-exported by the commerce barrel, so it is imported from its
// generated source to build request amounts in the order's own type.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;
import 'package:fixnum/fixnum.dart';

export 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;

/// Minor units (cents) of a money value. Order amounts are validated and
/// compared in minor units so percent arithmetic stays exact.
int moneyToMinor(Money money) =>
    money.units.toInt() * 100 + money.nanos ~/ 10000000;

/// Builds a money value from minor units.
Money minorToMoney(int minor, String currencyCode) => Money(
  currencyCode: currencyCode,
  units: Int64(minor ~/ 100),
  nanos: (minor % 100) * 10000000,
);

/// Formats minor units as `KES 1250.00`.
String formatMinor(int minor, String currencyCode) {
  final sign = minor < 0 ? '-' : '';
  final abs = minor.abs();
  final amount = '$sign${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
  return currencyCode.isEmpty ? amount : '$currencyCode $amount';
}

/// Parses a decimal amount such as `1,250.5` into minor units. Returns null
/// for anything that is not a non-negative amount with at most two decimals.
int? parseMinor(String input) {
  final cleaned = input.trim().replaceAll(',', '');
  final match = RegExp(r'^(\d+)(?:\.(\d{0,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final whole = int.tryParse(match.group(1)!);
  if (whole == null) return null;
  final frac = (match.group(2) ?? '').padRight(2, '0');
  return whole * 100 + int.parse(frac);
}

/// Formats minor units as a plain decimal for an input field (`1250.00`).
String minorToInput(int minor) => formatMinor(minor, '');

/// The paying rules for one order: how much is owed and what the payment
/// policy snapshotted on the order allows the next instalment to be.
///
/// Mirrors the backend's CheckoutOrder checks so the buyer or operator sees
/// a problem before a checkout session is requested: a partial amount needs
/// instalments, must not exceed the balance, and must reach the deposit
/// share when nothing is paid yet or the minimum instalment share otherwise.
/// The whole balance is always accepted.
class InstalmentRules {
  const InstalmentRules({
    required this.totalMinor,
    required this.paidMinor,
    required this.balanceMinor,
    required this.currencyCode,
    required this.policy,
  });

  factory InstalmentRules.fromOrder(Order order) {
    final total = order.hasTotal() ? moneyToMinor(order.total) : 0;
    final paid = order.hasAmountPaid() ? moneyToMinor(order.amountPaid) : 0;
    final balance = order.hasBalance()
        ? moneyToMinor(order.balance)
        : (total - paid).clamp(0, total);
    final currency = order.total.currencyCode.isNotEmpty
        ? order.total.currencyCode
        : order.balance.currencyCode;
    return InstalmentRules(
      totalMinor: total,
      paidMinor: paid,
      balanceMinor: balance,
      currencyCode: currency,
      policy: order.hasPaymentPolicy() ? order.paymentPolicy : PaymentPolicy(),
    );
  }

  final int totalMinor;
  final int paidMinor;
  final int balanceMinor;
  final String currencyCode;
  final PaymentPolicy policy;

  bool get nothingPaid => paidMinor <= 0;

  /// Whether the next payment may be less than the whole balance.
  bool get allowsPartial => policy.allowInstalments && balanceMinor > 0;

  /// Share of the total paid so far, 0–100 (capped; overpayment shows 100).
  double get paidFraction {
    if (totalMinor <= 0) return balanceMinor > 0 ? 0 : 1;
    return (paidMinor / totalMinor).clamp(0.0, 1.0);
  }

  /// The policy share the next instalment must reach.
  int get requiredPercent =>
      nothingPaid ? policy.minDepositPercent : policy.minInstalmentPercent;

  /// Smallest amount accepted for the next payment. Without instalments it
  /// is the whole balance.
  int get minimumMinor {
    if (!allowsPartial) return balanceMinor;
    final pct = requiredPercent.clamp(0, 100);
    // Round up so the client never accepts less than the backend requires.
    final min = (totalMinor * pct + 99) ~/ 100;
    if (min <= 0) return balanceMinor > 0 ? 1 : 0;
    return min > balanceMinor ? balanceMinor : min;
  }

  /// Returns an error message for [amountMinor], or null when it may be paid.
  String? validate(int? amountMinor) {
    if (amountMinor == null) return 'Enter an amount such as 1250.00';
    if (amountMinor <= 0) return 'Enter an amount greater than zero';
    if (balanceMinor <= 0) return 'Nothing is left to pay on this order';
    if (amountMinor > balanceMinor) {
      return 'Cannot exceed the balance of '
          '${formatMinor(balanceMinor, currencyCode)}';
    }
    if (amountMinor == balanceMinor) return null;
    if (!policy.allowInstalments) {
      return 'This order must be paid in full '
          '(${formatMinor(balanceMinor, currencyCode)})';
    }
    final min = minimumMinor;
    if (amountMinor < min) {
      final what = nothingPaid ? 'The deposit' : 'Each instalment';
      return '$what must be at least $requiredPercent% of the total '
          '(${formatMinor(min, currencyCode)}), or the whole balance';
    }
    return null;
  }

  /// Validates a typed decimal amount; see [validate].
  String? validateInput(String? input) {
    if (input == null || input.trim().isEmpty) return 'Amount is required';
    final minor = parseMinor(input);
    if (minor == null) return 'Enter an amount such as 1250.00';
    return validate(minor);
  }
}

/// One-line human summary of a payment policy, e.g.
/// "Instalments allowed · 30% deposit · min 10% per instalment · balance
/// due within 14 days · fulfil at 50% · signals at 25/50/75%".
String paymentPolicySummary(PaymentPolicy policy) {
  if (!policy.allowInstalments) {
    final parts = <String>['Payment in full'];
    if (policy.signalThresholds.isNotEmpty) {
      parts.add('signals at ${policy.signalThresholds.join('/')}%');
    }
    return parts.join(' · ');
  }
  final parts = <String>['Instalments allowed'];
  if (policy.minDepositPercent > 0) {
    parts.add('${policy.minDepositPercent}% deposit');
  }
  if (policy.minInstalmentPercent > 0) {
    parts.add('min ${policy.minInstalmentPercent}% per instalment');
  }
  parts.add(
    policy.balanceDueDays > 0
        ? 'balance due within ${policy.balanceDueDays} days'
        : 'no balance deadline',
  );
  parts.add(
    policy.fulfilAtPercent > 0 && policy.fulfilAtPercent < 100
        ? 'fulfil at ${policy.fulfilAtPercent}% paid'
        : 'fulfil when fully paid',
  );
  if (policy.signalThresholds.isNotEmpty) {
    parts.add('signals at ${policy.signalThresholds.join('/')}%');
  }
  if (policy.cancelWhenOverdue) parts.add('cancelled when overdue');
  return parts.join(' · ');
}

/// `2026-09-29 14:05` in local time.
String formatDateTime(DateTime dt) {
  final l = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
}
