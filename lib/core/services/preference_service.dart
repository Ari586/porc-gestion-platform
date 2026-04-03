import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    final p = await prefs;
    return p.getString(key) ?? defaultValue;
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final p = await prefs;
    return p.getBool(key) ?? defaultValue;
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final p = await prefs;
    return p.getInt(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  Future<void> remove(String key) async {
    final p = await prefs;
    await p.remove(key);
  }
}
