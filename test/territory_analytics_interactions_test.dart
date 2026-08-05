import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('territory search/sort and analytics period filters interact', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Territories'));
    await tester.tap(find.text('Territories'));
    await tester.pumpAndSettle();

    expect(find.text('Oakwood Heights'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'NotFound');
    await tester.pumpAndSettle();

    expect(find.text('No territories match your search.'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Export'));
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('GCI This Month'), findsOneWidget);

    await tester.tap(find.text('All Time'));
    await tester.pumpAndSettle();

    expect(find.text('GCI All Time'), findsOneWidget);
    expect(find.text(r'$463,920.00'), findsOneWidget);
  });
}
