import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/sow.dart';
import '../../../core/services/cloud_sync_service.dart';

class SowRepository {
  final CloudSyncService _sync;
  List<Sow> _cache = [];
  final _localController = StreamController<List<Sow>>.broadcast();

  SowRepository(this._sync);

  List<Sow> get sows => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _cache = _parseSows(data);
    _localController.add(_cache);
  }

  Stream<List<Sow>> watch() {
    if (!_sync.available) {
      debugPrint('[SowRepo] Firebase unavailable – using local-only mode');
      Future.microtask(() => _localController.add(_cache));
      return _localController.stream;
    }
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
    _localController.add(_cache);
    await _persist();
  }

  Future<void> update(Sow sow) async {
    _cache = _cache.map((s) => s.id == sow.id ? sow : s).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((s) => s.id != id).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'sows': _cache.map((s) => s.toJson()).toList(),
    });
  }
}
