import 'json_helpers.dart';

class Client {
  final String id;
  final String name;
  final String segment;
  final String contact;

  const Client({
    required this.id,
    required this.name,
    required this.segment,
    required this.contact,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'segment': segment,
      'contact': contact,
    };
  }

  static Client? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final segment = JsonHelpers.readString(json['segment']).trim();
    if (id.isEmpty || name.isEmpty || segment.isEmpty) {
      return null;
    }
    return Client(
      id: id,
      name: name,
      segment: segment,
      contact: JsonHelpers.readString(json['contact']).trim(),
    );
  }
}
