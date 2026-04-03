import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/sow.dart';
import '../../../core/services/service_locator.dart';
import '../data/sow_repository.dart';

final sowRepositoryProvider = Provider<SowRepository>((_) => getIt<SowRepository>());

final sowListProvider = StreamProvider<List<Sow>>((ref) {
  final repo = ref.watch(sowRepositoryProvider);
  return repo.watch();
});

final sowSearchQueryProvider = StateProvider<String>((_) => '');

final filteredSowsProvider = Provider<List<Sow>>((ref) {
  final sowsAsync = ref.watch(sowListProvider);
  final query = ref.watch(sowSearchQueryProvider).toLowerCase();
  final sows = sowsAsync.valueOrNull ?? [];
  if (query.isEmpty) return sows;
  return sows.where((s) => s.code.toLowerCase().contains(query) || s.name.toLowerCase().contains(query)).toList();
});
