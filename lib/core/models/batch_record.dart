import 'json_helpers.dart';

class BatchRecord {
  final String id;
  final String name;
  final String stage;
  final DateTime startDate;
  final int animals;
  final double avgWeight;

  const BatchRecord({
    required this.id,
    required this.name,
    required this.stage,
    required this.startDate,
    required this.animals,
    required this.avgWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage': stage,
      'startDate': startDate.toIso8601String(),
      'animals': animals,
      'avgWeight': avgWeight,
    };
  }

  static BatchRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final stage = JsonHelpers.readString(json['stage']).trim();
    final startDate = JsonHelpers.parseDate(JsonHelpers.readString(json['startDate']));
    final animals = JsonHelpers.readInt(json['animals']);
    final avgWeight = JsonHelpers.readDouble(json['avgWeight']);
    if (id.isEmpty || name.isEmpty || stage.isEmpty || startDate == null || animals <= 0 || avgWeight < 0) {
      return null;
    }
    return BatchRecord(
      id: id,
      name: name,
      stage: stage,
      startDate: startDate,
      animals: animals,
      avgWeight: avgWeight,
    );
  }
}
