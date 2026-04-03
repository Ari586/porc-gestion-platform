import 'json_helpers.dart';

class Supplier {
  final String id;
  final String name;
  final String category;
  final String contact;

  const Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.contact,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'contact': contact,
    };
  }

  static Supplier? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final category = JsonHelpers.readString(json['category']).trim();
    if (id.isEmpty || name.isEmpty || category.isEmpty) {
      return null;
    }
    return Supplier(
      id: id,
      name: name,
      category: category,
      contact: JsonHelpers.readString(json['contact']).trim(),
    );
  }
}
