import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/boar.dart';
import '../../../core/services/cloud_sync_service.dart';

class BoarRepository {
  final CloudSyncService _sync;
  List<Boar> _cache = [];
  final _localController = StreamController<List<Boar>>.broadcast();

  BoarRepository(this._sync);

  List<Boar> get boars => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _cache = _parseBoars(data);
    _localController.add(_cache);
  }

  Stream<List<Boar>> watch() {
    if (!_sync.available) {
      // Local-only mode: emit cache immediately then listen for local changes
      debugPrint('[BoarRepo] Firebase unavailable – using local-only mode');
      Future.microtask(() => _localController.add(_cache));
      return _localController.stream;
    }
    return _sync.watchLivestock().map(_parseBoars);
  }

  List<Boar> _parseBoars(Map<String, dynamic> data) {
    final raw = data['boars'];
    if (raw is! List) return _cache;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map((j) => Boar.fromJson(j))
        .whereType<Boar>()
        .toList();
    _cache = parsed;
    return parsed;
  }

  Future<void> add(Boar boar) async {
    _cache = [..._cache, boar];
    _localController.add(_cache);
    await _persist();
  }

  Future<void> update(Boar boar) async {
    _cache = _cache.map((b) => b.id == boar.id ? boar : b).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((b) => b.id != id).toList();
    _localController.add(_cache);
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'boars': _cache.map((b) => b.toJson()).toList(),
    });
  }
}
