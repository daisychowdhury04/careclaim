// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:careclaim/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CareClaimApp(),
      ),
    );

    // Verify the dashboard title is visible.
    expect(find.textContaining('Claims Dashboard'), findsOneWidget);
  });
}
