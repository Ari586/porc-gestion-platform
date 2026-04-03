import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/widgets/section_card.dart';

void main() {
  group('SectionCard', () {
    testWidgets('renders title and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionCard(
              title: 'Test Section',
              child: Text('Child content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionCard(
              title: 'Title',
              subtitle: '3 items',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('3 items'), findsOneWidget);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionCard(
              title: 'Title',
              actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
