import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/insemination_record.dart';
import '../../../core/services/service_locator.dart';
import '../data/insemination_repository.dart';

final inseminationRepositoryProvider =
    Provider<InseminationRepository>((_) => getIt<InseminationRepository>());

final inseminationListProvider = StreamProvider<List<InseminationRecord>>((ref) {
  final repo = ref.watch(inseminationRepositoryProvider);
  return repo.watch();
});

final inseminationFilterProvider = StateProvider<String>((_) => 'Tous');

final filteredInseminationsProvider = Provider<List<InseminationRecord>>((ref) {
  final recordsAsync = ref.watch(inseminationListProvider);
  final filter = ref.watch(inseminationFilterProvider);
  final records = recordsAsync.valueOrNull ?? [];
  if (filter == 'Tous') return records;
  return records.where((r) => r.status == filter).toList();
});

final inseminationStatsProvider = Provider<Map<String, int>>((ref) {
  final recordsAsync = ref.watch(inseminationListProvider);
  final records = recordsAsync.valueOrNull ?? [];
  return {
    'pending': records.where((r) => r.status == 'En attente').length,
    'confirmed': records.where((r) => r.status == 'Confirmée').length,
    'failed': records.where((r) => r.status == 'Échouée').length,
    'total': records.length,
  };
});
