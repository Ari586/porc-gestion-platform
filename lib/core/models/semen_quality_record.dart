import 'json_helpers.dart';

class SemenQualityRecord {
  final String id;
  final String lotCode;
  final String boarCode;
  final DateTime collectionDate;
  final DateTime? conditioningDateTime;
  final double concentration;
  final double estimatedSpzPerMl;
  final double motilityPercent;
  final double temperatureC;
  final int storageHours;
  final String approvedBy;
  final String notes;

  const SemenQualityRecord({
    required this.id,
    required this.lotCode,
    required this.boarCode,
    required this.collectionDate,
    this.conditioningDateTime,
    required this.concentration,
    this.estimatedSpzPerMl = 0,
    required this.motilityPercent,
    required this.temperatureC,
    required this.storageHours,
    required this.approvedBy,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotCode': lotCode,
      'boarCode': boarCode,
      'collectionDate': collectionDate.toIso8601String(),
      'conditioningDateTime': conditioningDateTime?.toIso8601String(),
      'concentration': concentration,
      'estimatedSpzPerMl': estimatedSpzPerMl,
      'motilityPercent': motilityPercent,
      'temperatureC': temperatureC,
      'storageHours': storageHours,
      'approvedBy': approvedBy,
      'notes': notes,
    };
  }

  static SemenQualityRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final lotCode = JsonHelpers.readString(json['lotCode']).trim();
    final boarCode = JsonHelpers.readString(json['boarCode']).trim();
    final collectionDate = JsonHelpers.parseDate(JsonHelpers.readString(json['collectionDate']));
    final concentration = JsonHelpers.readDouble(json['concentration']);
    final motilityPercent = JsonHelpers.readDouble(json['motilityPercent']);
    final temperatureC = JsonHelpers.readDouble(json['temperatureC']);
    final storageHours = JsonHelpers.readInt(json['storageHours']);
    final approvedBy = JsonHelpers.readString(json['approvedBy']).trim();
    if (id.isEmpty || lotCode.isEmpty || boarCode.isEmpty || collectionDate == null || concentration <= 0 || motilityPercent < 0 || temperatureC <= 0 || storageHours < 0 || approvedBy.isEmpty) {
      return null;
    }
    final estimatedSpzPerMl = JsonHelpers.readDouble(json['estimatedSpzPerMl']);
    return SemenQualityRecord(
      id: id,
      lotCode: lotCode,
      boarCode: boarCode,
      collectionDate: collectionDate,
      conditioningDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['conditioningDateTime'])),
      concentration: concentration,
      estimatedSpzPerMl: estimatedSpzPerMl <= 0 ? concentration : estimatedSpzPerMl,
      motilityPercent: motilityPercent,
      temperatureC: temperatureC,
      storageHours: storageHours,
      approvedBy: approvedBy,
      notes: JsonHelpers.readString(json['notes']).trim(),
    );
  }
}
