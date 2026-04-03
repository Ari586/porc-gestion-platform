import 'json_helpers.dart';

class InseminationRecord {
  final String id;
  final String sowCode;
  final String boarCode;
  final String semenLot;
  final DateTime? weaningDate;
  final DateTime? proestrusDateTime;
  final DateTime? oestrusStartDateTime;
  final DateTime? oestrusEndDateTime;
  final DateTime? firstStandingHeatDateTime;
  final DateTime dose1Date;
  final DateTime? dose2Date;
  final DateTime? projectedReturnDate;
  final DateTime? actualReturnDate;
  final String observations;
  final String inseminator;
  final String status;
  final String notes;

  const InseminationRecord({
    required this.id,
    required this.sowCode,
    required this.boarCode,
    required this.semenLot,
    this.weaningDate,
    this.proestrusDateTime,
    this.oestrusStartDateTime,
    this.oestrusEndDateTime,
    this.firstStandingHeatDateTime,
    required this.dose1Date,
    this.dose2Date,
    this.projectedReturnDate,
    this.actualReturnDate,
    this.observations = '',
    required this.inseminator,
    required this.status,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sowCode': sowCode,
      'boarCode': boarCode,
      'semenLot': semenLot,
      'weaningDate': weaningDate?.toIso8601String(),
      'proestrusDateTime': proestrusDateTime?.toIso8601String(),
      'oestrusStartDateTime': oestrusStartDateTime?.toIso8601String(),
      'oestrusEndDateTime': oestrusEndDateTime?.toIso8601String(),
      'firstStandingHeatDateTime': firstStandingHeatDateTime?.toIso8601String(),
      'dose1Date': dose1Date.toIso8601String(),
      'dose2Date': dose2Date?.toIso8601String(),
      'projectedReturnDate': projectedReturnDate?.toIso8601String(),
      'actualReturnDate': actualReturnDate?.toIso8601String(),
      'observations': observations,
      'inseminator': inseminator,
      'status': status,
      'notes': notes,
    };
  }

  static InseminationRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final sowCode = JsonHelpers.readString(json['sowCode']).trim();
    final boarCode = JsonHelpers.readString(json['boarCode']).trim();
    final semenLot = JsonHelpers.readString(json['semenLot']).trim();
    final dose1Date = JsonHelpers.parseDate(JsonHelpers.readString(json['dose1Date']));
    final inseminator = JsonHelpers.readString(json['inseminator']).trim();
    final status = JsonHelpers.readString(json['status']).trim();
    if (id.isEmpty || sowCode.isEmpty || boarCode.isEmpty || semenLot.isEmpty || dose1Date == null || inseminator.isEmpty || status.isEmpty) {
      return null;
    }
    return InseminationRecord(
      id: id,
      sowCode: sowCode,
      boarCode: boarCode,
      semenLot: semenLot,
      weaningDate: JsonHelpers.parseDate(JsonHelpers.readString(json['weaningDate'])) ??
          JsonHelpers.parseDateTime(JsonHelpers.readString(json['weaningDate'])),
      proestrusDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['proestrusDateTime'])),
      oestrusStartDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['oestrusStartDateTime'])),
      oestrusEndDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['oestrusEndDateTime'])),
      firstStandingHeatDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['firstStandingHeatDateTime'])),
      dose1Date: dose1Date,
      dose2Date: JsonHelpers.parseDate(JsonHelpers.readString(json['dose2Date'])),
      projectedReturnDate: JsonHelpers.parseDate(JsonHelpers.readString(json['projectedReturnDate'])) ??
          JsonHelpers.parseDateTime(JsonHelpers.readString(json['projectedReturnDate'])),
      actualReturnDate: JsonHelpers.parseDate(JsonHelpers.readString(json['actualReturnDate'])) ??
          JsonHelpers.parseDateTime(JsonHelpers.readString(json['actualReturnDate'])),
      observations: JsonHelpers.readString(json['observations']),
      inseminator: inseminator,
      status: status,
      notes: JsonHelpers.readString(json['notes']),
    );
  }
}
