import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/semen_quality_record.dart';
import '../../../core/services/cloud_sync_service.dart';

class SemenQualityRepository {
  final CloudSyncService _sync;
  List<SemenQualityRecord> _cache = [];
  final _localController = StreamController<List<SemenQualityRecord>>.broadcast();

  SemenQualityRepository(this._sync);

  List<SemenQualityRecord> get records => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _cache = _parseRecords(data);
    _localController.add(_cache);
  }

  Stream<List<SemenQualityRecord>> watch() {
    if (!_sync.available) {
      debugPrint('[SemenQualityRepo] Firebase unavailable – using local-only mode');
      Future.microtask(() => _localController.add(_cache));
      return _localController.stream;
    }
    return _sync.watchLivestock().map(_parseRecords);
  }

  List<SemenQualityRecord> _parseRecords(Map<String, dynamic> data) {
    final raw = data['semenQualityRecords'];
    if (raw is! List) return _cache;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map((j) => SemenQualityRecord.fromJson(j))
        .whereType<SemenQualityRecord>()
        .toList();
    _cache = parsed;
    return parsed;
  }

  Future<void> add(SemenQualityRecord record) async {
    _cache = [..._cache, record];
    _localController.add(_cache);
    await _persist();
  }

  Future<void> update(SemenQualityRecord record) async {
    _cache = _cache.map((r) => r.id == record.id ? record : r).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((r) => r.id != id).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'semenQualityRecords': _cache.map((r) => r.toJson()).toList(),
    });
  }
}
