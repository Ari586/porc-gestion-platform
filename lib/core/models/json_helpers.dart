/// Shared JSON parsing helpers used by all model fromJson methods.
class JsonHelpers {
  JsonHelpers._();

  static String readString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(readString(value)) ?? 0;
  }

  static double readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(readString(value)) ?? 0;
  }

  static List<String> readStringList(dynamic value) {
    if (value is! List) return const [];
    final items = <String>[];
    for (final item in value) {
      final text = readString(item).trim();
      if (text.isEmpty || items.contains(text)) continue;
      items.add(text);
    }
    return items;
  }

  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return parsed.toLocal();
  }

  static List<Map<String, dynamic>> readObjectMapList(dynamic value) {
    if (value is! List) return const [];
    final items = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map) {
        items.add(Map<String, dynamic>.from(item));
      }
    }
    return items;
  }
}
