import 'package:console/features/dashboard/data/dashboard_providers.dart';
import 'package:console/features/dashboard/widgets/recent_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders quiet empty state when the feed has no entries',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RecentActivityList(entries: []))),
    );

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('No recent activity yet.'), findsOneWidget);
  });

  testWidgets('renders one tile per entry with title and subtitle',
      (tester) async {
    final entries = [
      RecentActivityEntry(
        title: 'Purchase order created',
        subtitle: 'Service commerce · PO-318',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RecentActivityEntry(
        title: 'Batch updated',
        subtitle: 'Service manufacturing · B-1042',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RecentActivityList(entries: entries))),
    );

    expect(find.text('Purchase order created'), findsOneWidget);
    expect(find.text('Service commerce · PO-318'), findsOneWidget);
    expect(find.text('Batch updated'), findsOneWidget);
    expect(find.text('No recent activity yet.'), findsNothing);
    expect(find.text('5m ago'), findsOneWidget);
    expect(find.text('2h ago'), findsOneWidget);
  });
}
