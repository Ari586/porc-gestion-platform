import 'dart:async';

import '../../../core/models/insemination_record.dart';
import '../../../core/services/cloud_sync_service.dart';

class InseminationRepository {
  final CloudSyncService _sync;
  List<InseminationRecord> _cache = [];

  InseminationRepository(this._sync);

  List<InseminationRecord> get records => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchOperations();
    _cache = _parseRecords(data);
  }

  Stream<List<InseminationRecord>> watch() {
    return _sync.watchOperations().map(_parseRecords);
  }

  List<InseminationRecord> _parseRecords(Map<String, dynamic> data) {
    final raw = data['inseminations'];
    if (raw is! List) return _cache;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map((j) => InseminationRecord.fromJson(j))
        .whereType<InseminationRecord>()
        .toList();
    _cache = parsed;
    return parsed;
  }

  Future<void> add(InseminationRecord record) async {
    _cache = [..._cache, record];
    await _persist();
  }

  Future<void> update(InseminationRecord record) async {
    _cache = _cache.map((r) => r.id == record.id ? record : r).toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((r) => r.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveOperations({
      'inseminations': _cache.map((r) => r.toJson()).toList(),
    });
  }
}
