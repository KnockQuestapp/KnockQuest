import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/app_routes.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('visit history logs visits, updates status, and opens map', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'agent@knockquest.io');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed(
      AppRoutes.leadDetails,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Visit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Interested'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Requested a callback next week');

    final beforeTotal = find.textContaining('Total:');
    expect(beforeTotal, findsOneWidget);

    await tester.tap(find.text('Log Visit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Visit logged: Interested'), findsOneWidget);

    final followUpCountBefore = LeadStore.instance.followUpsNotifier.value.length;

    await tester.ensureVisible(find.text('Add Follow Up'));
    await tester.tap(find.text('Add Follow Up'));
    await tester.pumpAndSettle();

    expect(LeadStore.instance.followUpsNotifier.value.length, followUpCountBefore + 1);

    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();

    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    final changeStatusButton = find.text('Change Status');
    await tester.scrollUntilVisible(
      changeStatusButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(changeStatusButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Warm Lead'));
    await tester.pumpAndSettle();

    expect(find.text('Lead status changed to Warm Lead.'), findsOneWidget);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed(
      AppRoutes.interactiveMap,
    );
    await tester.pumpAndSettle();

    expect(find.text('Save Boundary'), findsOneWidget);
  });
}
