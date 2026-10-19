import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_pricing/src/screens/discount_rule_form.dart';
import 'package:antinvestor_ui_pricing/src/utils/discount_conditions.dart';
import 'package:antinvestor_ui_pricing/src/widgets/discount_conditions_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _strings(Value v) {
  expect(v.hasListValue(), isTrue, reason: 'expected a ListValue');
  return v.listValue.values.map((e) {
    expect(e.hasStringValue(), isTrue, reason: 'list items must be strings');
    return e.stringValue;
  }).toList();
}

void main() {
  group('DiscountConditions.toStruct', () {
    test(
      'encodes ID lists as ListValues of strings and quantity as number',
      () {
        final struct = const DiscountConditions(
          variantIds: ['var-1', 'var-2'],
          productIds: ['prod-1'],
          minQuantity: 5,
        ).toStruct();

        expect(
          struct.fields.keys,
          unorderedEquals(['variant_ids', 'product_ids', 'min_quantity']),
        );
        expect(_strings(struct.fields['variant_ids']!), ['var-1', 'var-2']);
        expect(_strings(struct.fields['product_ids']!), ['prod-1']);
        final min = struct.fields['min_quantity']!;
        expect(min.hasNumberValue(), isTrue);
        expect(min.numberValue, 5);
      },
    );

    test('omits empty lists and non-positive quantity', () {
      final struct = const DiscountConditions(
        variantIds: [' '],
        minQuantity: 0,
      ).toStruct();
      expect(struct.fields, isEmpty);
    });

    test('trims and de-duplicates IDs', () {
      final struct = const DiscountConditions(
        variantIds: [' a1b ', 'a1b', 'c2d'],
      ).toStruct();
      expect(_strings(struct.fields['variant_ids']!), ['a1b', 'c2d']);
    });

    test('round-trips through fromStruct and reports unsupported keys', () {
      final source = const DiscountConditions(
        productIds: ['prod-9'],
        minQuantity: 2.5,
      ).toStruct()..fields['customer_group'] = Value(stringValue: 'vip');

      final parsed = DiscountConditions.fromStruct(source);
      expect(parsed.productIds, ['prod-9']);
      expect(parsed.variantIds, isEmpty);
      expect(parsed.minQuantity, 2.5);
      expect(parsed.unsupportedKeys, ['customer_group']);
    });
  });

  group('buildConditionsStruct', () {
    final original = Struct(
      fields: {
        'min_quantity': Value(numberValue: 3),
        'region': Value(stringValue: 'nairobi'),
      },
    );

    test('keeps unsupported keys by default', () {
      final struct = buildConditionsStruct(
        const DiscountConditions(minQuantity: 4),
        original: original,
      );
      expect(struct.fields['min_quantity']!.numberValue, 4);
      expect(struct.fields['region']!.stringValue, 'nairobi');
    });

    test('drops unsupported keys when asked', () {
      final struct = buildConditionsStruct(
        const DiscountConditions(minQuantity: 4),
        original: original,
        dropUnsupported: true,
      );
      expect(struct.fields.keys, ['min_quantity']);
    });
  });

  test('parseIdList splits on commas, spaces and newlines', () {
    expect(parseIdList('a1, b2\nc3  a1'), ['a1', 'b2', 'c3']);
    expect(parseIdList('  '), isEmpty);
  });

  group('DiscountConditionsEditor', () {
    late DiscountConditions latest;
    final formKey = GlobalKey<FormState>();

    Future<void> pump(WidgetTester tester, DiscountConditions initial) {
      latest = initial;
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: DiscountConditionsEditor(
                  initial: initial,
                  onChanged: (c) => latest = c,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('explains that other keys are never applied', (tester) async {
      await pump(tester, const DiscountConditions());
      expect(find.text(discountConditionsHelp), findsOneWidget);
      expect(
        find.textContaining('never applied automatically'),
        findsOneWidget,
      );
    });

    testWidgets('builds a Struct from the entered values', (tester) async {
      await pump(tester, const DiscountConditions());

      await tester.enterText(
        find.byKey(const ValueKey('condition-variant-ids')),
        'var-1, var-2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('condition-product-ids')),
        'prod-1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('condition-min-quantity')),
        '10',
      );

      final struct = latest.toStruct();
      expect(_strings(struct.fields['variant_ids']!), ['var-1', 'var-2']);
      expect(_strings(struct.fields['product_ids']!), ['prod-1']);
      expect(struct.fields['min_quantity']!.numberValue, 10);
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('pre-fills from existing conditions', (tester) async {
      await pump(
        tester,
        const DiscountConditions(variantIds: ['v-a', 'v-b'], minQuantity: 3),
      );
      expect(find.text('v-a, v-b'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('rejects malformed IDs and negative quantities', (
      tester,
    ) async {
      await pump(tester, const DiscountConditions());
      await tester.enterText(
        find.byKey(const ValueKey('condition-variant-ids')),
        'Bad ID!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('condition-min-quantity')),
        '-1',
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Invalid variant ID: Bad'), findsOneWidget);
      expect(find.text('Enter a non-negative number'), findsOneWidget);
    });
  });
}
