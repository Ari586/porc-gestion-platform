import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/boar.dart';
import '../../../core/models/semen_quality_record.dart';
import '../../../core/services/service_locator.dart';
import '../data/boar_repository.dart';
import '../data/semen_quality_repository.dart';

final boarRepositoryProvider = Provider<BoarRepository>((_) => getIt<BoarRepository>());

final boarListProvider = StreamProvider<List<Boar>>((ref) {
  final repo = ref.watch(boarRepositoryProvider);
  return repo.watch();
});

final boarSearchQueryProvider = StateProvider<String>((_) => '');

final filteredBoarsProvider = Provider<List<Boar>>((ref) {
  final boarsAsync = ref.watch(boarListProvider);
  final query = ref.watch(boarSearchQueryProvider).toLowerCase();
  final boars = boarsAsync.valueOrNull ?? [];
  if (query.isEmpty) return boars;
  return boars.where((b) => b.code.toLowerCase().contains(query) || b.name.toLowerCase().contains(query)).toList();
});

// ── Semen Quality ───────────────────────────────────────────────────────

final semenQualityRepositoryProvider =
    Provider<SemenQualityRepository>((_) => getIt<SemenQualityRepository>());

final semenQualityListProvider = StreamProvider<List<SemenQualityRecord>>((ref) {
  final repo = ref.watch(semenQualityRepositoryProvider);
  return repo.watch();
});
