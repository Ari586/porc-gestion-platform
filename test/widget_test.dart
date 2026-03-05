// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:porc/main.dart';

void main() {
  testWidgets('Connexion puis affichage du dashboard', (
    WidgetTester tester,
  ) async {
    await initializeDateFormatting('fr_FR', null);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PigBreedingApp());
    await tester.pumpAndSettle();

    expect(find.text('Connexion Utilisateur'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'Admin@2026');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('TABLEAU DE BORD REPRODUCTION PORCINE'), findsOneWidget);
  });
}
