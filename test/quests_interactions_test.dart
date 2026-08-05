import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('quests are reachable and support add and complete actions', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Quests'));
    await tester.tap(find.text('Quests'));
    await tester.pumpAndSettle();

    expect(find.text('Park Cleanup Patrol'), findsOneWidget);

    await tester.tap(find.text('Quick Add'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Door Knock Sprint #'), findsOneWidget);

    await tester.tap(find.text('Complete').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
  });
}
