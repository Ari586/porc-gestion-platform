import 'json_helpers.dart';

class SaleRecord {
  final String id;
  final String type;
  final String clientId;
  final DateTime date;
  final int quantity;
  final double amount;

  const SaleRecord({
    required this.id,
    required this.type,
    required this.clientId,
    required this.date,
    required this.quantity,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'clientId': clientId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'amount': amount,
    };
  }

  static SaleRecord? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final type = JsonHelpers.readString(json['type']).trim();
    final clientId = JsonHelpers.readString(json['clientId']).trim();
    final date = JsonHelpers.parseDate(JsonHelpers.readString(json['date']));
    final quantity = JsonHelpers.readInt(json['quantity']);
    final amount = JsonHelpers.readDouble(json['amount']);
    if (id.isEmpty || type.isEmpty || clientId.isEmpty || date == null || quantity <= 0 || amount <= 0) {
      return null;
    }
    return SaleRecord(
      id: id,
      type: type,
      clientId: clientId,
      date: date,
      quantity: quantity,
      amount: amount,
    );
  }
}
