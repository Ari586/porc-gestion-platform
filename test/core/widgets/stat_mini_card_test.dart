import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/widgets/stat_mini_card.dart';

void main() {
  group('StatMiniCard', () {
    testWidgets('renders label, value, and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatMiniCard(
              label: 'Ventes',
              value: '42',
              icon: Icons.shopping_cart,
              iconColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Ventes'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });
  });
}
