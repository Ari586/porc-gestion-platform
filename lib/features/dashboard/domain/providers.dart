import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../boars/domain/providers.dart';
import '../../sows/domain/providers.dart';
import '../../insemination/domain/providers.dart';
import '../../health/domain/providers.dart';

/// Aggregated dashboard KPIs derived from domain providers.
final dashboardKpiProvider = Provider<Map<String, dynamic>>((ref) {
  final boars = ref.watch(boarListProvider).valueOrNull ?? [];
  final sows = ref.watch(sowListProvider).valueOrNull ?? [];
  final iaStats = ref.watch(inseminationStatsProvider);
  final healthRecords = ref.watch(healthRecordListProvider).valueOrNull ?? [];
  final upcoming = ref.watch(upcomingVaccinationsProvider);

  final total = iaStats['total'] ?? 0;
  final confirmed = iaStats['confirmed'] ?? 0;
  final fertilityRate = total > 0 ? (confirmed / total * 100).round() : 0;

  return {
    'boarCount': boars.length,
    'sowCount': sows.length,
    'totalInseminations': total,
    'pendingInseminations': iaStats['pending'] ?? 0,
    'confirmedInseminations': confirmed,
    'failedInseminations': iaStats['failed'] ?? 0,
    'fertilityRate': fertilityRate,
    'healthRecordCount': healthRecords.length,
    'upcomingVaccinations': upcoming.length,
  };
});
