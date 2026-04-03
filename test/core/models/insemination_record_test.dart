import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/models/insemination_record.dart';

void main() {
  group('InseminationRecord', () {
    test('fromJson parses required fields', () {
      final json = {
        'id': 'ia1',
        'sowCode': 'T-001',
        'boarCode': 'V-001',
        'semenLot': 'LOT-2026-01',
        'status': 'En attente',
        'inseminator': 'Jean',
        'dose1Date': '2026-03-20',
        'notes': '',
      };

      final record = InseminationRecord.fromJson(json);
      expect(record, isNotNull);
      expect(record!.sowCode, 'T-001');
      expect(record.boarCode, 'V-001');
      expect(record.status, 'En attente');
      expect(record.dose1Date.year, 2026);
      expect(record.dose1Date.month, 3);
      expect(record.dose1Date.day, 20);
    });

    test('fromJson returns null when required field is missing', () {
      final json = {
        'id': 'ia-x',
        'sowCode': 'T-001',
        'boarCode': 'V-001',
        // missing semenLot, inseminator
        'status': 'En attente',
        'dose1Date': '2026-03-20',
      };
      expect(InseminationRecord.fromJson(json), isNull);
    });

    test('fromJson handles nullable date fields', () {
      final json = {
        'id': 'ia2',
        'sowCode': 'T-002',
        'boarCode': 'V-002',
        'semenLot': 'LOT-2026-02',
        'status': 'Confirmée',
        'inseminator': 'Paul',
        'dose1Date': '2026-03-15',
        'dose2Date': '2026-03-16',
        'projectedReturnDate': '2026-04-05',
      };

      final record = InseminationRecord.fromJson(json)!;
      expect(record.dose2Date, isNotNull);
      expect(record.projectedReturnDate, isNotNull);
      expect(record.actualReturnDate, isNull);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': 'ia3',
        'sowCode': 'T-003',
        'boarCode': 'V-001',
        'semenLot': 'LOT-2026-03',
        'status': 'Échouée',
        'inseminator': 'Marie',
        'dose1Date': '2026-02-10',
        'notes': 'Échec retour chaleur',
      };

      final record = InseminationRecord.fromJson(json)!;
      final output = record.toJson();
      expect(output['sowCode'], 'T-003');
      expect(output['status'], 'Échouée');
      expect(output['semenLot'], 'LOT-2026-03');
    });
  });
}
