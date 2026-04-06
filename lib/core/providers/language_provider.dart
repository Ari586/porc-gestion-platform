import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider gérant la langue de l'application (Français ou Malagasy)
/// 'Français' est la valeur par défaut.
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('Français');

  void setLanguage(String lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});
