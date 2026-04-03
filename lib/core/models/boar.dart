import 'json_helpers.dart';

class Boar {
  final String id;
  final String code;
  final String name;
  final String breed;
  final DateTime birthDate;
  final String origin;
  final String breederId;
  final String sireCode;
  final String damCode;
  final String semenType;
  final DateTime? semenArrivalDateTime;
  final DateTime? freshCollectionDateTime;
  final double freshQuantityMl;
  final double freshMotilityPercent;
  final double freshForceScore;
  final double freshEstimatedSpzPerMl;
  final int collectionFrequencyPerWeek;
  final int collectionFrequencyPerMonth;
  final String frozenLotNumber;
  final DateTime? frozenCollectionDate;
  final String frozenOrigin;
  final String frozenBreed;
  final String preparedSemenLotNumber;
  final DateTime? semenPackagingDateTime;
  final double preparedEstimatedSpzPerMl;
  final String labTechnicianCode;
  final String labTechnicianName;
  final String notes;
  final String imageBase64;

  const Boar({
    required this.id,
    required this.code,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.origin,
    this.breederId = '',
    this.sireCode = '',
    this.damCode = '',
    this.semenType = 'Fraîche',
    this.semenArrivalDateTime,
    this.freshCollectionDateTime,
    this.freshQuantityMl = 0,
    this.freshMotilityPercent = 0,
    this.freshForceScore = 0,
    this.freshEstimatedSpzPerMl = 0,
    this.collectionFrequencyPerWeek = 0,
    this.collectionFrequencyPerMonth = 0,
    this.frozenLotNumber = '',
    this.frozenCollectionDate,
    this.frozenOrigin = '',
    this.frozenBreed = '',
    this.preparedSemenLotNumber = '',
    this.semenPackagingDateTime,
    this.preparedEstimatedSpzPerMl = 0,
    this.labTechnicianCode = '',
    this.labTechnicianName = '',
    this.notes = '',
    this.imageBase64 = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
      'origin': origin,
      'breederId': breederId,
      'sireCode': sireCode,
      'damCode': damCode,
      'semenType': semenType,
      'semenArrivalDateTime': semenArrivalDateTime?.toIso8601String(),
      'freshCollectionDateTime': freshCollectionDateTime?.toIso8601String(),
      'freshQuantityMl': freshQuantityMl,
      'freshMotilityPercent': freshMotilityPercent,
      'freshForceScore': freshForceScore,
      'freshEstimatedSpzPerMl': freshEstimatedSpzPerMl,
      'collectionFrequencyPerWeek': collectionFrequencyPerWeek,
      'collectionFrequencyPerMonth': collectionFrequencyPerMonth,
      'frozenLotNumber': frozenLotNumber,
      'frozenCollectionDate': frozenCollectionDate?.toIso8601String(),
      'frozenOrigin': frozenOrigin,
      'frozenBreed': frozenBreed,
      'preparedSemenLotNumber': preparedSemenLotNumber,
      'semenPackagingDateTime': semenPackagingDateTime?.toIso8601String(),
      'preparedEstimatedSpzPerMl': preparedEstimatedSpzPerMl,
      'labTechnicianCode': labTechnicianCode,
      'labTechnicianName': labTechnicianName,
      'notes': notes,
      'imageBase64': imageBase64,
    };
  }

  static Boar? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final code = JsonHelpers.readString(json['code']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final breed = JsonHelpers.readString(json['breed']).trim();
    final origin = JsonHelpers.readString(json['origin']).trim();
    final birthDate = JsonHelpers.parseDate(JsonHelpers.readString(json['birthDate']));
    if (id.isEmpty || code.isEmpty || name.isEmpty || breed.isEmpty || origin.isEmpty || birthDate == null) {
      return null;
    }
    return Boar(
      id: id,
      code: code,
      name: name,
      breed: breed,
      birthDate: birthDate,
      origin: origin,
      breederId: JsonHelpers.readString(json['breederId']).trim(),
      sireCode: JsonHelpers.readString(json['sireCode']).trim(),
      damCode: JsonHelpers.readString(json['damCode']).trim(),
      semenType: JsonHelpers.readString(json['semenType']).trim().isEmpty
          ? 'Fraîche'
          : JsonHelpers.readString(json['semenType']).trim(),
      semenArrivalDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['semenArrivalDateTime'])),
      freshCollectionDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['freshCollectionDateTime'])),
      freshQuantityMl: JsonHelpers.readDouble(json['freshQuantityMl']),
      freshMotilityPercent: JsonHelpers.readDouble(json['freshMotilityPercent']),
      freshForceScore: JsonHelpers.readDouble(json['freshForceScore']),
      freshEstimatedSpzPerMl: JsonHelpers.readDouble(json['freshEstimatedSpzPerMl']),
      collectionFrequencyPerWeek: JsonHelpers.readInt(json['collectionFrequencyPerWeek']),
      collectionFrequencyPerMonth: JsonHelpers.readInt(json['collectionFrequencyPerMonth']),
      frozenLotNumber: JsonHelpers.readString(json['frozenLotNumber']).trim(),
      frozenCollectionDate: JsonHelpers.parseDate(JsonHelpers.readString(json['frozenCollectionDate'])),
      frozenOrigin: JsonHelpers.readString(json['frozenOrigin']).trim(),
      frozenBreed: JsonHelpers.readString(json['frozenBreed']).trim(),
      preparedSemenLotNumber: JsonHelpers.readString(json['preparedSemenLotNumber']).trim(),
      semenPackagingDateTime: JsonHelpers.parseDateTime(JsonHelpers.readString(json['semenPackagingDateTime'])),
      preparedEstimatedSpzPerMl: JsonHelpers.readDouble(json['preparedEstimatedSpzPerMl']),
      labTechnicianCode: JsonHelpers.readString(json['labTechnicianCode']).trim(),
      labTechnicianName: JsonHelpers.readString(json['labTechnicianName']).trim(),
      notes: JsonHelpers.readString(json['notes']),
      imageBase64: JsonHelpers.readString(json['imageBase64']),
    );
  }
}
