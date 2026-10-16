import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aaj_kya_banau/main.dart';

void main() {
  testWidgets('home pantry and navigation load', (tester) async {
    await tester.pumpWidget(const AajKyaBanauApp());

    expect(find.text('Aaj kya banau?'), findsOneWidget);
    expect(find.text('Onion'), findsOneWidget);
    expect(find.text('Camera scan'), findsOneWidget);

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    expect(find.text('AI recipe suggestions'), findsOneWidget);
    // The recipe list is scrollable; bring later recipe cards into the viewport.
    await tester.scrollUntilVisible(
      find.text('Paneer Butter Masala'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Paneer Butter Masala'), findsOneWidget);

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly meal planner'), findsOneWidget);
    expect(find.text('Evening reminder'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Grocery cart'), findsOneWidget);
    expect(find.text('Blinkit Delivery'), findsOneWidget);
  });
}
