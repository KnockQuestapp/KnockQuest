// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:knockquest/src/knockquest_app.dart';

void main() {
  testWidgets('App shell renders map and quests tabs', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KnockQuestApp());

    expect(find.text('KnockQuest'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Quests'), findsOneWidget);

    await tester.tap(find.text('Quests'));
    await tester.pump();

    expect(find.text('Park Cleanup Patrol'), findsOneWidget);
  });
}
