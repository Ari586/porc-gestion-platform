import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/health_record.dart';
import '../../../core/services/service_locator.dart';
import '../data/health_repository.dart';

final healthRepositoryProvider =
    Provider<HealthRepository>((_) => getIt<HealthRepository>());

final healthRecordListProvider = StreamProvider<List<HealthRecord>>((ref) {
  final repo = ref.watch(healthRepositoryProvider);
  return repo.watch();
});

final healthFilterProvider = StateProvider<String>((_) => 'Tous');

final filteredHealthRecordsProvider = Provider<List<HealthRecord>>((ref) {
  final recordsAsync = ref.watch(healthRecordListProvider);
  final filter = ref.watch(healthFilterProvider);
  final records = recordsAsync.valueOrNull ?? [];
  if (filter == 'Tous') return records;
  return records.where((r) => r.eventType == filter).toList();
});

final upcomingVaccinationsProvider = Provider<List<HealthRecord>>((ref) {
  final recordsAsync = ref.watch(healthRecordListProvider);
  final records = recordsAsync.valueOrNull ?? [];
  final now = DateTime.now();
  return records
      .where((r) => r.nextDate != null && r.nextDate!.isAfter(now))
      .toList()
    ..sort((a, b) => a.nextDate!.compareTo(b.nextDate!));
});
