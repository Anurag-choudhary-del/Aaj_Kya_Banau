import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aaj_kya_banau/main.dart';
import 'package:aaj_kya_banau/data/planner_catalog.dart';

void main() {
  testWidgets('home pantry and navigation load with an empty pantry', (tester) async {
    await tester.pumpWidget(const AajKyaBanauApp());
    await tester.pumpAndSettle();

    expect(find.text('Aaj kya banau?'), findsOneWidget);
    expect(find.text('Pantry is empty — scan or add items'), findsOneWidget);
    expect(find.text('Camera scan'), findsOneWidget);

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    expect(find.text('Recipe suggestions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Paneer Butter Masala'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Paneer Butter Masala'), findsOneWidget);

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly meal planner'), findsOneWidget);
    expect(find.text('Evening reminder'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Grocery cart'), findsOneWidget);
    expect(find.text('Blinkit (not connected)'), findsOneWidget);
  });

  test('planner offers five choices for every meal category', () {
    expect(PlannerCatalog.categories.keys.toSet(), {'Breakfast', 'Lunch', 'Dinner', 'Snacks'});
    for (final category in PlannerCatalog.categories.keys) {
      expect(PlannerCatalog.optionsForDay(category, 17), hasLength(5));
    }
  });

}
