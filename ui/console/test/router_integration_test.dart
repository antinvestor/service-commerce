import 'package:console/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts the full app and verifies it boots without crashing. The
/// auth guard will redirect to /login, so we simply assert a
/// MaterialApp is rendered.
void main() {
  testWidgets('ConsoleApp boots without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ConsoleApp()),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
