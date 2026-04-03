import 'json_helpers.dart';

class StockItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double alertThreshold;

  const StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.alertThreshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'alertThreshold': alertThreshold,
    };
  }

  static StockItem? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final name = JsonHelpers.readString(json['name']).trim();
    final category = JsonHelpers.readString(json['category']).trim();
    final unit = JsonHelpers.readString(json['unit']).trim();
    final quantity = JsonHelpers.readDouble(json['quantity']);
    final alertThreshold = JsonHelpers.readDouble(json['alertThreshold']);
    if (id.isEmpty || name.isEmpty || category.isEmpty || unit.isEmpty) {
      return null;
    }
    return StockItem(
      id: id,
      name: name,
      category: category,
      unit: unit,
      quantity: quantity,
      alertThreshold: alertThreshold,
    );
  }
}
