import 'json_helpers.dart';

class BuildingRecord {
  final String id;
  final String name;
  final String type;
  final int capacity;
  final int occupied;

  const BuildingRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.occupied,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'capacity': capacity,
      'occupied': occupied,
    };
  }

  static BuildingRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final type = JsonHelpers.readString(json['type']).trim();
    final capacity = JsonHelpers.readInt(json['capacity']);
    final occupied = JsonHelpers.readInt(json['occupied']);
    if (id.isEmpty || name.isEmpty || type.isEmpty || capacity <= 0 || occupied < 0) {
      return null;
    }
    return BuildingRecord(
      id: id,
      name: name,
      type: type,
      capacity: capacity,
      occupied: occupied > capacity ? capacity : occupied,
    );
  }
}
