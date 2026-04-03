import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/models/sale_record.dart';

void main() {
  group('SaleRecord', () {
    test('fromJson parses valid sale', () {
      final json = {
        'id': 'sr1',
        'type': 'Porcelets',
        'clientId': 'c1',
        'date': '2026-03-28',
        'quantity': 12,
        'amount': 960000.0,
      };

      final record = SaleRecord.fromJson(json);
      expect(record, isNotNull);
      expect(record!.type, 'Porcelets');
      expect(record.quantity, 12);
      expect(record.amount, 960000.0);
    });

    test('fromJson returns null when quantity is 0 (validation)', () {
      final json = {
        'id': 'sr2',
        'type': 'Engraissés',
        'clientId': 'c2',
        'date': '2026-03-22',
        'quantity': 0,
        'amount': 100.0,
      };
      // SaleRecord.fromJson validates quantity > 0 and returns null if invalid
      final record = SaleRecord.fromJson(json);
      expect(record, isNull);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': 'sr3',
        'type': 'Semence',
        'clientId': 'c3',
        'date': '2026-03-15',
        'quantity': 20,
        'amount': 400000.0,
      };
      final record = SaleRecord.fromJson(json)!;
      final output = record.toJson();
      expect(output['type'], 'Semence');
      expect(output['quantity'], 20);
    });
  });
}
