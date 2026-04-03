import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/models/health_record.dart';

void main() {
  group('HealthRecord', () {
    test('fromJson parses a complete JSON map', () {
      final json = {
        'id': 'h1',
        'animalType': 'Truie',
        'animalCode': 'T-001',
        'eventType': 'Vaccination',
        'eventDate': '2026-03-25',
        'product': 'Vaccin Parvo',
        'dose': '2ml',
        'reason': 'Calendrier vaccinal',
        'nextDate': '2026-09-25',
        'responsible': 'Dr Rakoto',
        'notes': 'RAS',
      };

      final record = HealthRecord.fromJson(json);
      expect(record, isNotNull);
      expect(record!.animalCode, 'T-001');
      expect(record.eventType, 'Vaccination');
      expect(record.product, 'Vaccin Parvo');
      expect(record.nextDate, isNotNull);
      expect(record.nextDate!.month, 9);
    });

    test('fromJson handles missing nextDate', () {
      final json = {
        'id': 'h2',
        'animalType': 'Verrat',
        'animalCode': 'V-001',
        'eventType': 'Traitement',
        'eventDate': '2026-03-20',
        'product': 'Antibiotique',
        'dose': '5ml',
        'reason': 'Infection',
        'responsible': 'Dr Rakoto',
        'notes': '',
      };

      final record = HealthRecord.fromJson(json)!;
      expect(record.nextDate, isNull);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': 'h3',
        'animalType': 'Truie',
        'animalCode': 'T-002',
        'eventType': 'Vaccination',
        'eventDate': '2026-01-15',
        'product': 'PCV2',
        'dose': '1ml',
        'reason': 'Protocole',
        'nextDate': '2026-07-15',
        'responsible': 'Marie',
        'notes': '',
      };

      final record = HealthRecord.fromJson(json)!;
      final output = record.toJson();
      expect(output['animalCode'], 'T-002');
      expect(output['eventType'], 'Vaccination');
    });
  });
}
