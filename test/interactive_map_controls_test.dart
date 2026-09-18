import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:knockquest/src/knockquest_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_storage.dart';
import 'package:knockquest/src/state/lead_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initTestStorage();
    LeadStore.instance.reset();
  });

  testWidgets('map search, filters, range, and save controls are interactive', (
    tester,
  ) async {
    await tester.pumpWidget(const KnockQuestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'agent@knockquest.io',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Map'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Circle')).style?.color, Colors.white);

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

    final mapRect = tester.getRect(find.byType(FlutterMap));
    await tester.tapAt(mapRect.topLeft + const Offset(60, 200));
    await tester.pumpAndSettle();
    expect(find.text('Undo Point'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Undo Point'))
          .style
          ?.foregroundColor
          ?.resolve({}),
      Colors.white,
    );
    expect(
      tester.widget<CircleLayer>(find.byType(CircleLayer).first).circles,
      hasLength(1),
    );
    await tester.tap(find.text('Save Boundary'));
    await tester.pumpAndSettle();
    expect(find.text('Circle saved.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Polygon'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('Polygon')).style?.color,
      Colors.white,
    );
    for (final offset in [
      const Offset(60, 200),
      const Offset(110, 230),
      const Offset(75, 290),
    ]) {
      await tester.tapAt(mapRect.topLeft + offset);
      await tester.pumpAndSettle();
    }
    final draftPolygon = tester
        .widget<PolygonLayer>(find.byType(PolygonLayer))
        .polygons
        .single;
    expect(draftPolygon.points.toSet(), hasLength(3));
    expect(
      tester.getRect(find.text('Save Boundary')).bottom,
      lessThanOrEqualTo(mapRect.bottom),
    );
    await tester.tap(find.text('Save Boundary'));
    await tester.pumpAndSettle();
    expect(find.text('Polygon saved.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Route'));
    await tester.pumpAndSettle();
    for (final offset in [const Offset(60, 210), const Offset(100, 270)]) {
      await tester.tapAt(mapRect.topLeft + offset);
      await tester.pumpAndSettle();
    }
    expect(
      tester.widget<PolylineLayer>(find.byType(PolylineLayer)).polylines,
      hasLength(1),
    );
    await tester.tap(find.text('Save Boundary'));
    await tester.pumpAndSettle();
    expect(find.text('Route saved.'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Map'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CircleLayer>(find.byType(CircleLayer).first).circles,
      hasLength(1),
    );
    expect(
      tester.widget<PolygonLayer>(find.byType(PolygonLayer)).polygons,
      hasLength(1),
    );
    expect(
      tester.widget<PolylineLayer>(find.byType(PolylineLayer)).polylines,
      hasLength(1),
    );
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Own your area.'), findsOneWidget);
  });
}
