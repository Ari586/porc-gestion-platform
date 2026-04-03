import 'json_helpers.dart';

class GrowthRecord {
  final String id;
  final String batchId;
  final DateTime date;
  final double avgWeight;
  final double dailyGain;

  const GrowthRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.avgWeight,
    required this.dailyGain,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'date': date.toIso8601String(),
      'avgWeight': avgWeight,
      'dailyGain': dailyGain,
    };
  }

  static GrowthRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final batchId = JsonHelpers.readString(json['batchId']).trim();
    final date = JsonHelpers.parseDate(JsonHelpers.readString(json['date']));
    final avgWeight = JsonHelpers.readDouble(json['avgWeight']);
    final dailyGain = JsonHelpers.readDouble(json['dailyGain']);
    if (id.isEmpty || batchId.isEmpty || date == null || avgWeight < 0 || dailyGain < 0) {
      return null;
    }
    return GrowthRecord(
      id: id,
      batchId: batchId,
      date: date,
      avgWeight: avgWeight,
      dailyGain: dailyGain,
    );
  }
}
