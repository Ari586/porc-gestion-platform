import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:porc/main.dart';

void main() {
  testWidgets('loads the porc app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const PigBreedingApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
