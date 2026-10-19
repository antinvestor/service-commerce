import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePriceAmount', () {
    test('converts decimals to units and nanos', () {
      final cases = <String, (int, int)>{
        '99.50': (99, 500000000),
        '99.5': (99, 500000000),
        '100': (100, 0),
        '0': (0, 0),
        '0.01': (0, 10000000),
        '.75': (0, 750000000),
        '12.': (12, 0),
        '1,250.25': (1250, 250000000),
        ' 7.10 ': (7, 100000000),
      };
      cases.forEach((input, expected) {
        final result = parsePriceAmount(input);
        expect(result.units, Int64(expected.$1), reason: input);
        expect(result.nanos, expected.$2, reason: input);
      });
    });

    test('rounds to the nearest cent', () {
      expect(parsePriceAmount('1.234').nanos, 230000000);
      expect(parsePriceAmount('1.235').nanos, 240000000);
      final carried = parsePriceAmount('1.999');
      expect(carried.units, Int64(2));
      expect(carried.nanos, 0);
    });

    test('rejects empty, negative and non-numeric input', () {
      for (final input in ['', ' ', '-5', 'abc', '1.2.3', '1e5', '.']) {
        expect(
          () => parsePriceAmount(input),
          throwsFormatException,
          reason: input,
        );
      }
    });
  });

  test('formatPriceAmount renders an input-ready amount', () {
    expect(formatPriceAmount(Int64(100), 0), '100');
    expect(formatPriceAmount(Int64(99), 500000000), '99.50');
    expect(formatPriceAmount(Int64(0), 10000000), '0.01');
  });
}
