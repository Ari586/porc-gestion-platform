import 'json_helpers.dart';

class PigletCareRecord {
  final String id;
  final String animalCode;
  final String groupName;
  final DateTime eventDate;
  final String eventType;
  final String details;
  final String responsible;
  final DateTime? nextDate;

  const PigletCareRecord({
    required this.id,
    required this.animalCode,
    required this.groupName,
    required this.eventDate,
    required this.eventType,
    required this.details,
    required this.responsible,
    this.nextDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalCode': animalCode,
      'groupName': groupName,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType,
      'details': details,
      'responsible': responsible,
      'nextDate': nextDate?.toIso8601String(),
    };
  }

  static PigletCareRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final animalCode = JsonHelpers.readString(json['animalCode']).trim();
    final groupName = JsonHelpers.readString(json['groupName']).trim();
    final eventDate = JsonHelpers.parseDate(JsonHelpers.readString(json['eventDate']));
    final eventType = JsonHelpers.readString(json['eventType']).trim();
    final details = JsonHelpers.readString(json['details']).trim();
    final responsible = JsonHelpers.readString(json['responsible']).trim();
    if (id.isEmpty || animalCode.isEmpty || groupName.isEmpty || eventDate == null || eventType.isEmpty || details.isEmpty || responsible.isEmpty) {
      return null;
    }
    return PigletCareRecord(
      id: id,
      animalCode: animalCode,
      groupName: groupName,
      eventDate: eventDate,
      eventType: eventType,
      details: details,
      responsible: responsible,
      nextDate: JsonHelpers.parseDate(JsonHelpers.readString(json['nextDate'])),
    );
  }
}
