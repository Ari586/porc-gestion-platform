import 'package:flutter_test/flutter_test.dart';
import 'package:porc/core/models/sow.dart';

void main() {
  group('Sow', () {
    test('fromJson parses a complete JSON map', () {
      final json = {
        'id': 's1',
        'code': 'T-001',
        'name': 'Bella',
        'breed': 'Large White',
        'birthDate': '2023-03-20',
        'parity': 3,
        'breederId': 'farm1',
        'sireCode': 'V-001',
        'damCode': 'T-020',
        'notes': 'Excellente mère',
      };

      final sow = Sow.fromJson(json);
      expect(sow, isNotNull);
      expect(sow!.code, 'T-001');
      expect(sow.name, 'Bella');
      expect(sow.parity, 3);
      expect(sow.sireCode, 'V-001');
    });

    test('fromJson rejects parity <= 0', () {
      final json = {
        'id': 's2',
        'code': 'T-002',
        'name': 'Nala',
        'breed': 'Landrace',
        'birthDate': '2023-01-01',
        'parity': -1,
        'breederId': 'farm1',
      };
      final sow = Sow.fromJson(json);
      expect(sow, isNull);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': 's3',
        'code': 'T-003',
        'name': 'Luna',
        'breed': 'Duroc',
        'birthDate': '2022-12-01',
        'parity': 5,
        'breederId': '',
        'sireCode': '',
        'damCode': '',
        'notes': 'Test',
      };
      final sow = Sow.fromJson(json)!;
      final output = sow.toJson();
      expect(output['code'], 'T-003');
      expect(output['parity'], 5);
      expect(output['notes'], 'Test');
    });
  });
}
