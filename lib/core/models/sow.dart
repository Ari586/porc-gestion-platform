import 'json_helpers.dart';

class Sow {
  final String id;
  final String code;
  final String name;
  final String breed;
  final DateTime birthDate;
  final int parity;
  final String breederId;
  final String sireCode;
  final String damCode;
  final String notes;
  final String imageBase64;

  const Sow({
    required this.id,
    required this.code,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.parity,
    this.breederId = '',
    this.sireCode = '',
    this.damCode = '',
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
      'parity': parity,
      'breederId': breederId,
      'sireCode': sireCode,
      'damCode': damCode,
      'notes': notes,
      'imageBase64': imageBase64,
    };
  }

  static Sow? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final code = JsonHelpers.readString(json['code']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final breed = JsonHelpers.readString(json['breed']).trim();
    final birthDate = JsonHelpers.parseDate(JsonHelpers.readString(json['birthDate']));
    final parity = JsonHelpers.readInt(json['parity']);
    if (id.isEmpty || code.isEmpty || name.isEmpty || breed.isEmpty || birthDate == null || parity <= 0) {
      return null;
    }
    return Sow(
      id: id,
      code: code,
      name: name,
      breed: breed,
      birthDate: birthDate,
      parity: parity,
      breederId: JsonHelpers.readString(json['breederId']).trim(),
      sireCode: JsonHelpers.readString(json['sireCode']).trim(),
      damCode: JsonHelpers.readString(json['damCode']).trim(),
      notes: JsonHelpers.readString(json['notes']),
      imageBase64: JsonHelpers.readString(json['imageBase64']),
    );
  }
}
