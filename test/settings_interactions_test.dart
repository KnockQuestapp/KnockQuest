import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('crm toggles and subscription plans are interactive', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CRM & Integrations'));
    await tester.tap(find.text('CRM & Integrations'));
    await tester.pumpAndSettle();

    expect(find.text('Connected Services'), findsOneWidget);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    expect(find.text('Paused - Sync disabled'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Subscription & Themes'));
    await tester.tap(find.text('Subscription & Themes'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Choose Plan').last);
    await tester.tap(find.text('Choose Plan').last);
    await tester.pumpAndSettle();

    expect(find.text('Plan updated: Team'), findsOneWidget);
  });
}
