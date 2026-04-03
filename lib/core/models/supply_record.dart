import 'json_helpers.dart';

class SupplyRecord {
  final String id;
  final String category;
  final String supplierId;
  final DateTime date;
  final double amount;
  final String notes;

  const SupplyRecord({
    required this.id,
    required this.category,
    required this.supplierId,
    required this.date,
    required this.amount,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'supplierId': supplierId,
      'date': date.toIso8601String(),
      'amount': amount,
      'notes': notes,
    };
  }

  static SupplyRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final category = JsonHelpers.readString(json['category']).trim();
    final supplierId = JsonHelpers.readString(json['supplierId']).trim();
    final date = JsonHelpers.parseDate(JsonHelpers.readString(json['date']));
    final amount = JsonHelpers.readDouble(json['amount']);
    if (id.isEmpty || category.isEmpty || supplierId.isEmpty || date == null || amount <= 0) {
      return null;
    }
    return SupplyRecord(
      id: id,
      category: category,
      supplierId: supplierId,
      date: date,
      amount: amount,
      notes: JsonHelpers.readString(json['notes']),
    );
  }
}
