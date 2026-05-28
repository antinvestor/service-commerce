import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:console/src/dashboard/widgets/kpi_card.dart';

void main() {
  testWidgets('KpiCard renders label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            label: "Today's sales",
            value: 'KSh 1,234',
            icon: Icons.attach_money,
            trend: '+5%',
          ),
        ),
      ),
    );

    expect(find.text("Today's sales"), findsOneWidget);
    expect(find.text('KSh 1,234'), findsOneWidget);
    expect(find.text('+5%'), findsOneWidget);
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
  });
}
