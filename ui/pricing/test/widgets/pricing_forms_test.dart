import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/common/v1/money.pb.dart'
    show Money;
import 'package:antinvestor_ui_pricing/src/screens/customer_price_override_form.dart';
import 'package:antinvestor_ui_pricing/src/screens/discount_rule_form.dart';
import 'package:antinvestor_ui_pricing/src/screens/price_list_entry_form.dart';
import 'package:antinvestor_ui_pricing/src/screens/price_list_form.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Holds what a dialog popped.
class _Result<T> {
  T? value;
}

/// Pumps a host page, opens [dialog] and records its popped value in the
/// returned holder.
Future<_Result<T>> _openDialog<T>(
  WidgetTester tester,
  Widget dialog, {
  Size size = const Size(1200, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final result = _Result<T>();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result.value = await showDialog<T>(
                context: context,
                builder: (_) => dialog,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('price list form defaults currency to the shop currency', (
    tester,
  ) async {
    final result = await _openDialog<PriceListSaveRequest>(
      tester,
      const PriceListFormDialog(shopId: 'shop-1', defaultCurrency: 'UGX'),
    );
    expect(find.text('UGX'), findsOneWidget);
    expect(find.text('Shop currency: UGX'), findsOneWidget);
    expect(find.text('Valid From'), findsOneWidget);
    expect(find.text('Valid Until'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Wholesale',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(result.value!.currency, 'UGX');
    expect(result.value!.shopId, 'shop-1');
    expect(result.value!.hasValidFrom(), isFalse);
  });

  testWidgets('discount form saves the conditions Struct', (tester) async {
    final result = await _openDialog<DiscountRuleSaveRequest>(
      tester,
      const DiscountRuleFormDialog(shopId: 'shop-1'),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Bulk buy',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Value'), '15');
    await tester.enterText(
      find.byKey(const ValueKey('condition-product-ids')),
      'prod-1, prod-2',
    );
    await tester.enterText(
      find.byKey(const ValueKey('condition-min-quantity')),
      '6',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final saved = result.value!;
    expect(saved.name, 'Bulk buy');
    expect(saved.value, 15);
    final fields = saved.conditions.fields;
    expect(fields.keys, unorderedEquals(['product_ids', 'min_quantity']));
    expect(fields['product_ids']!.listValue.values.map((v) => v.stringValue), [
      'prod-1',
      'prod-2',
    ]);
    expect(fields['min_quantity']!.numberValue, 6);
  });

  testWidgets(
    'dropping the approval requirement is an explicit masked change',
    (tester) async {
      final existing = DiscountRule(
        id: 'rule-1',
        shopId: 'shop-1',
        name: 'Staff',
        discountType: DiscountType.DISCOUNT_TYPE_PERCENTAGE,
        value: 10,
        appliesTo: DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM,
        requiresApproval: true,
        status: DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE,
      );
      final result = await _openDialog<DiscountRuleSaveRequest>(
        tester,
        DiscountRuleFormDialog(shopId: 'shop-1', existing: existing),
      );
      expect(
        find.textContaining('needs discount approval permission'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Requires approval'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = result.value!;
      expect(saved.id, 'rule-1');
      expect(saved.requiresApproval, isFalse);
      expect(saved.updateMask.paths, ['requires_approval']);
    },
  );

  testWidgets('a plain edit sends no update mask', (tester) async {
    final existing = DiscountRule(
      id: 'rule-2',
      shopId: 'shop-1',
      name: 'Bulk',
      discountType: DiscountType.DISCOUNT_TYPE_PERCENTAGE,
      value: 5,
      appliesTo: DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM,
      status: DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE,
    );
    final result = await _openDialog<DiscountRuleSaveRequest>(
      tester,
      DiscountRuleFormDialog(shopId: 'shop-1', existing: existing),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result.value!.hasUpdateMask(), isFalse);
  });

  testWidgets('override form validates IDs and converts price to money', (
    tester,
  ) async {
    final result = await _openDialog<CustomerPriceOverrideSaveRequest>(
      tester,
      const CustomerPriceOverrideDialog(
        shopId: 'shop-1',
        defaultCurrency: 'KES',
      ),
    );

    await tester.tap(find.text('Create'));
    await tester.pump();
    expect(find.text('Customer ID is required'), findsOneWidget);
    expect(find.text('Variant ID is required'), findsOneWidget);
    expect(result.value, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Customer ID'),
      'cust-123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Product Variant ID'),
      'var-9',
    );
    await tester.enterText(
      find.byKey(const ValueKey('override-price')),
      '1250.75',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final saved = result.value!;
    expect(saved.customerId, 'cust-123');
    expect(saved.productVariantId, 'var-9');
    expect(saved.unitPrice.currencyCode, 'KES');
    expect(saved.unitPrice.units, Int64(1250));
    expect(saved.unitPrice.nanos, 750000000);
    expect(
      saved.status,
      CustomerPriceOverrideStatus.CUSTOMER_PRICE_OVERRIDE_STATUS_ACTIVE,
    );
  });

  group('price list entry', () {
    testWidgets('validates and returns the variant, price and band', (
      tester,
    ) async {
      final result = await _openDialog<PriceListEntryInput>(
        tester,
        const PriceListEntryDialog(shopId: 'shop-1', currency: 'KES'),
      );
      await tester.tap(find.byKey(const ValueKey('entry-save')));
      await tester.pumpAndSettle();
      expect(find.text('Price is required'), findsOneWidget);
      expect(result.value, isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Product Variant ID'),
        'var-tea',
      );
      await tester.enterText(find.byKey(const ValueKey('entry-price')), '95.5');
      await tester.enterText(find.byKey(const ValueKey('entry-min')), '10');
      await tester.tap(find.byKey(const ValueKey('entry-save')));
      await tester.pumpAndSettle();

      expect(result.value, (
        variantId: 'var-tea',
        price: '95.5',
        minQuantity: 10,
        maxQuantity: 0,
      ));
    });

    testWidgets('keeps the variant of an existing entry', (tester) async {
      await _openDialog<PriceListEntryInput>(
        tester,
        PriceListEntryDialog(
          shopId: 'shop-1',
          currency: 'KES',
          existing: PriceListEntry(
            id: 'e-1',
            productVariantId: 'var-tea',
            unitPrice: Money(currencyCode: 'KES', units: Int64(90)),
          ),
        ),
      );
      final field = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Product Variant ID'),
      );
      expect(field.enabled, isFalse);
      expect(find.text('Search products'), findsNothing);
    });
  });

  group('phone width', () {
    const phone = Size(360, 800);

    testWidgets('every pricing form fits a phone', (tester) async {
      for (final dialog in <Widget>[
        const PriceListEntryDialog(shopId: 'shop-1', currency: 'KES'),
        const PriceListFormDialog(shopId: 'shop-1', defaultCurrency: 'KES'),
        const DiscountRuleFormDialog(shopId: 'shop-1'),
        const CustomerPriceOverrideDialog(
          shopId: 'shop-1',
          defaultCurrency: 'KES',
        ),
      ]) {
        await _openDialog<Object>(tester, dialog, size: phone);
        expect(
          tester.takeException(),
          isNull,
          reason: '${dialog.runtimeType} overflows',
        );
      }
    });
  });
}
