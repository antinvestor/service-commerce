import 'package:fixnum/fixnum.dart';

final _pricePattern = RegExp(r'^\d+(\.\d*)?$|^\.\d+$');

/// Parses a decimal price typed by a person (e.g. `99.50`, `1,250`, `.5`)
/// into `google.type.Money` units and nanos, rounded to the nearest cent.
///
/// Thousands separators and spaces are ignored. Throws a [FormatException]
/// with a user-facing message when the input is empty, negative or not a
/// number.
({Int64 units, int nanos}) parsePriceAmount(String input) {
  final cleaned = input.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty || !_pricePattern.hasMatch(cleaned)) {
    throw const FormatException('Price must be a non-negative amount.');
  }

  final dot = cleaned.indexOf('.');
  final whole = dot < 0 ? cleaned : cleaned.substring(0, dot);
  final fraction = dot < 0 ? '' : cleaned.substring(dot + 1);

  var units = Int64.parseInt(whole.isEmpty ? '0' : whole);
  // Round to cents using the first three fractional digits.
  final digits = fraction.padRight(3, '0').substring(0, 3);
  var cents = int.parse(digits.substring(0, 2));
  if (int.parse(digits[2]) >= 5) cents++;
  if (cents == 100) {
    units += 1;
    cents = 0;
  }
  return (units: units, nanos: cents * 10000000);
}

/// Formats units + nanos as a plain decimal string for an input field:
/// `100` for whole amounts, `99.50` otherwise.
String formatPriceAmount(Int64 units, int nanos) {
  final cents = (nanos / 10000000).round();
  if (cents == 0) return units.toString();
  if (cents >= 100) return (units + 1).toString();
  return '$units.${cents.toString().padLeft(2, '0')}';
}
