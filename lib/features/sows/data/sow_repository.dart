import 'dart:async';

import '../../../core/models/sow.dart';
import '../../../core/services/cloud_sync_service.dart';

class SowRepository {
  final CloudSyncService _sync;
  List<Sow> _cache = [];

  SowRepository(this._sync);

  List<Sow> get sows => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _cache = _parseSows(data);
  }

  Stream<List<Sow>> watch() {
    return _sync.watchLivestock().map(_parseSows);
  }

  List<Sow> _parseSows(Map<String, dynamic> data) {
    final raw = data['sows'];
    if (raw is! List) return _cache;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map((j) => Sow.fromJson(j))
        .whereType<Sow>()
        .toList();
    _cache = parsed;
    return parsed;
  }

  Future<void> add(Sow sow) async {
    _cache = [..._cache, sow];
    await _persist();
  }

  Future<void> update(Sow sow) async {
    _cache = _cache.map((s) => s.id == sow.id ? sow : s).toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((s) => s.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'sows': _cache.map((s) => s.toJson()).toList(),
    });
  }
}
