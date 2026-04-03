import 'json_helpers.dart';

class FarrowingRecord {
  final String id;
  final String sowCode;
  final DateTime farrowingDate;
  final int totalBorn;
  final int bornAlive;
  final int stillborn;
  final int mummified;
  final int weaned;
  final int preWeaningDeaths;
  final double avgBirthWeight;
  final String majorIssue;
  final String responsible;
  final String notes;

  const FarrowingRecord({
    required this.id,
    required this.sowCode,
    required this.farrowingDate,
    required this.totalBorn,
    required this.bornAlive,
    required this.stillborn,
    required this.mummified,
    required this.weaned,
    required this.preWeaningDeaths,
    required this.avgBirthWeight,
    this.majorIssue = '',
    required this.responsible,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sowCode': sowCode,
      'farrowingDate': farrowingDate.toIso8601String(),
      'totalBorn': totalBorn,
      'bornAlive': bornAlive,
      'stillborn': stillborn,
      'mummified': mummified,
      'weaned': weaned,
      'preWeaningDeaths': preWeaningDeaths,
      'avgBirthWeight': avgBirthWeight,
      'majorIssue': majorIssue,
      'responsible': responsible,
      'notes': notes,
    };
  }

  static FarrowingRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final sowCode = JsonHelpers.readString(json['sowCode']).trim();
    final farrowingDate = JsonHelpers.parseDate(JsonHelpers.readString(json['farrowingDate']));
    final totalBorn = JsonHelpers.readInt(json['totalBorn']);
    final bornAlive = JsonHelpers.readInt(json['bornAlive']);
    final stillborn = JsonHelpers.readInt(json['stillborn']);
    final mummified = JsonHelpers.readInt(json['mummified']);
    final weaned = JsonHelpers.readInt(json['weaned']);
    final preWeaningDeaths = JsonHelpers.readInt(json['preWeaningDeaths']);
    final avgBirthWeight = JsonHelpers.readDouble(json['avgBirthWeight']);
    final responsible = JsonHelpers.readString(json['responsible']).trim();
    if (id.isEmpty || sowCode.isEmpty || farrowingDate == null || totalBorn < 0 || bornAlive < 0 || stillborn < 0 || mummified < 0 || weaned < 0 || preWeaningDeaths < 0 || avgBirthWeight < 0 || responsible.isEmpty) {
      return null;
    }
    return FarrowingRecord(
      id: id,
      sowCode: sowCode,
      farrowingDate: farrowingDate,
      totalBorn: totalBorn,
      bornAlive: bornAlive,
      stillborn: stillborn,
      mummified: mummified,
      weaned: weaned,
      preWeaningDeaths: preWeaningDeaths,
      avgBirthWeight: avgBirthWeight,
      majorIssue: JsonHelpers.readString(json['majorIssue']).trim(),
      responsible: responsible,
      notes: JsonHelpers.readString(json['notes']).trim(),
    );
  }
}
