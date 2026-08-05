import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/app_routes.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() {
    LeadStore.instance.reset();
  });

  testWidgets('all named routes can be opened', (tester) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    for (final route in AppRoutes.all.where((r) => r != AppRoutes.login)) {
      navigator.pushNamed(route);
      await tester.pumpAndSettle();

      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'Expected route to render a scaffold: $route',
      );

      navigator.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('unknown route opens fallback page', (tester) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/route-that-does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('Route Not Found'), findsOneWidget);
    expect(find.textContaining('Unable to open route:'), findsOneWidget);
    expect(find.text('Back To Login'), findsOneWidget);
  });
}
