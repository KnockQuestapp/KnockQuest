import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/app_routes.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('add lead updates dashboard and lead details', (tester) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Lead'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(13));

    await tester.enterText(fields.at(0), 'Taylor');
    await tester.enterText(fields.at(1), 'Morgan');
    await tester.enterText(fields.at(2), '555-111-2222');

    await tester.ensureVisible(find.text('Save Lead'));
    await tester.tap(find.text('Save Lead'));
    await tester.pumpAndSettle();

    expect(find.text('Lead saved: Taylor Morgan'), findsOneWidget);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed(
      AppRoutes.leadDetails,
    );
    await tester.pumpAndSettle();

    expect(find.text('Taylor Morgan'), findsOneWidget);
  });
}
