import 'json_helpers.dart';

class HealthRecord {
  final String id;
  final String animalType;
  final String animalCode;
  final String eventType;
  final DateTime eventDate;
  final String product;
  final String dose;
  final String reason;
  final DateTime? nextDate;
  final String responsible;
  final String notes;

  const HealthRecord({
    required this.id,
    required this.animalType,
    required this.animalCode,
    required this.eventType,
    required this.eventDate,
    required this.product,
    required this.dose,
    required this.reason,
    this.nextDate,
    required this.responsible,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalType': animalType,
      'animalCode': animalCode,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String(),
      'product': product,
      'dose': dose,
      'reason': reason,
      'nextDate': nextDate?.toIso8601String(),
      'responsible': responsible,
      'notes': notes,
    };
  }

  static HealthRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final animalType = JsonHelpers.readString(json['animalType']).trim();
    final animalCode = JsonHelpers.readString(json['animalCode']).trim();
    final eventType = JsonHelpers.readString(json['eventType']).trim();
    final eventDate = JsonHelpers.parseDate(JsonHelpers.readString(json['eventDate']));
    final product = JsonHelpers.readString(json['product']).trim();
    final dose = JsonHelpers.readString(json['dose']).trim();
    final reason = JsonHelpers.readString(json['reason']).trim();
    final responsible = JsonHelpers.readString(json['responsible']).trim();
    if (id.isEmpty || animalType.isEmpty || animalCode.isEmpty || eventType.isEmpty || eventDate == null || product.isEmpty || dose.isEmpty || reason.isEmpty || responsible.isEmpty) {
      return null;
    }
    return HealthRecord(
      id: id,
      animalType: animalType,
      animalCode: animalCode,
      eventType: eventType,
      eventDate: eventDate,
      product: product,
      dose: dose,
      reason: reason,
      nextDate: JsonHelpers.parseDate(JsonHelpers.readString(json['nextDate'])),
      responsible: responsible,
      notes: JsonHelpers.readString(json['notes']),
    );
  }
}
