import 'dart:async';

import '../../../core/models/boar.dart';
import '../../../core/services/cloud_sync_service.dart';

class BoarRepository {
  final CloudSyncService _sync;
  List<Boar> _cache = [];

  BoarRepository(this._sync);

  List<Boar> get boars => List.unmodifiable(_cache);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _cache = _parseBoars(data);
  }

  Stream<List<Boar>> watch() {
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
    await _persist();
  }

  Future<void> update(Boar boar) async {
    _cache = _cache.map((b) => b.id == boar.id ? boar : b).toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache = _cache.where((b) => b.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'boars': _cache.map((b) => b.toJson()).toList(),
    });
  }
}
