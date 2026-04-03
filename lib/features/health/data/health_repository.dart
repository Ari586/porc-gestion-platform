import 'dart:async';

import '../../../core/models/health_record.dart';
import '../../../core/services/cloud_sync_service.dart';

class HealthRepository {
  final CloudSyncService _sync;
  List<HealthRecord> _cache = [];

  HealthRepository(this._sync);

  List<HealthRecord> get records => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchOperations();
    _cache = _parseRecords(data);
  }

  Stream<List<HealthRecord>> watch() {
    return _sync.watchOperations().map(_parseRecords);
  }

  List<HealthRecord> _parseRecords(Map<String, dynamic> data) {
    final raw = data['healthRecords'];
    if (raw is! List) return _cache;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map((j) => HealthRecord.fromJson(j))
        .whereType<HealthRecord>()
        .toList();
    _cache = parsed;
    return parsed;
  }

  Future<void> add(HealthRecord record) async {
    _cache = [..._cache, record];
    await _persist();
  }

  Future<void> update(HealthRecord record) async {
    _cache = _cache.map((r) => r.id == record.id ? record : r).toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((r) => r.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveOperations({
      'healthRecords': _cache.map((r) => r.toJson()).toList(),
    });
  }
}
