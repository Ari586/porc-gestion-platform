import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'Empty',
              actionLabel: 'Add',
              onAction: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.text('Add'));
      expect(pressed, isTrue);
    });
  });
}
