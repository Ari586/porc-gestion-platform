import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/building_record.dart';
import '../../../core/models/batch_record.dart';
import '../../../core/models/growth_record.dart';
import '../../../core/services/service_locator.dart';
import '../data/breeding_repository.dart';

final breedingRepositoryProvider =
    Provider<BreedingRepository>((_) => getIt<BreedingRepository>());

final breedingDataProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(breedingRepositoryProvider);
  return repo.watch();
});

final buildingListProvider = Provider<List<BuildingRecord>>((ref) {
  final data = ref.watch(breedingDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['buildings'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => BuildingRecord.fromJson(j))
      .whereType<BuildingRecord>()
      .toList();
});

final batchListProvider = Provider<List<BatchRecord>>((ref) {
  final data = ref.watch(breedingDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['batches'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => BatchRecord.fromJson(j))
      .whereType<BatchRecord>()
      .toList();
});

final growthListProvider = Provider<List<GrowthRecord>>((ref) {
  final data = ref.watch(breedingDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['growths'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => GrowthRecord.fromJson(j))
      .whereType<GrowthRecord>()
      .toList();
});
