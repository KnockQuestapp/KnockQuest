import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('map search, filters, range, and save controls are interactive', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Map'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Oak Street');
    await tester.pumpAndSettle();

    expect(find.textContaining('Searching: Oak Street'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.textContaining('Search query: "Oak Street"'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('1km'));
    await tester.tap(find.text('1km'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save Boundary'));
    await tester.tap(find.text('Save Boundary'));
    await tester.pumpAndSettle();

    expect(
      find.text('Boundary saved (1km) for "Oak Street"'),
      findsOneWidget,
    );
  });
}
