import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aaj_kya_banau/main.dart';
import 'package:aaj_kya_banau/data/planner_catalog.dart';
import 'package:aaj_kya_banau/models/grocery_item.dart';

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
    expect(
      find.text('No recipes because you don’t have ingredients in your kitchen. Add pantry items to see what you can cook.'),
      findsOneWidget,
    );
    expect(find.text('Paneer Butter Masala'), findsNothing);

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly meal planner'), findsOneWidget);
    expect(find.text('Evening reminder'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Grocery cart'), findsOneWidget);
    expect(find.text('Blinkit (not connected)'), findsOneWidget);
  });

  test('planner offers five regionally varied choices and rotates the next day', () {
    expect(PlannerCatalog.categories.keys.toSet(), {'Breakfast', 'Lunch', 'Dinner', 'Snacks'});
    for (final category in PlannerCatalog.categories.keys) {
      final today = PlannerCatalog.optionsForDay(category, 17);
      final tomorrow = PlannerCatalog.optionsForDay(category, 18);
      expect(today, hasLength(5));
      expect(tomorrow, hasLength(5));
      expect(today.map((r) => r.id).toSet().intersection(tomorrow.map((r) => r.id).toSet()), isEmpty);
    }
  });

  test('grocery pack size is included in line total', () {
    const potato = GroceryItem(
      id: 'potato',
      name: 'Potato',
      emoji: '🥔',
      quantity: 1,
      unit: 'kg',
      price: 30,
      packSize: 10,
    );
    expect(potato.lineTotal, 300);
    expect(potato.copyWith(quantity: 2).lineTotal, 600);
    expect(potato.copyWith(packSize: 5).lineTotal, 150);
  });
}
