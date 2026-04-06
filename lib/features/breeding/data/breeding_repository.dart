import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/building_record.dart';
import '../../../core/models/batch_record.dart';
import '../../../core/models/growth_record.dart';
import '../../../core/services/cloud_sync_service.dart';

class BreedingRepository {
  final CloudSyncService _sync;
  List<BuildingRecord> _buildings = [];
  List<BatchRecord> _batches = [];
  List<GrowthRecord> _growths = [];
  final _localController = StreamController<Map<String, dynamic>>.broadcast();

  BreedingRepository(this._sync);

  List<BuildingRecord> get buildings => List.unmodifiable(_buildings);
  List<BatchRecord> get batches => List.unmodifiable(_batches);
  List<GrowthRecord> get growths => List.unmodifiable(_growths);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _parseAll(data);
    _localController.add(_buildLocalMap());
  }

  Stream<Map<String, dynamic>> watch() {
    if (!_sync.available) {
      debugPrint('[BreedingRepo] Firebase unavailable – using local-only mode');
      Future.microtask(() => _localController.add(_buildLocalMap()));
      return _localController.stream;
    }
    return _sync.watchLivestock().map((data) {
      _parseAll(data);
      return data;
    });
  }

  void _parseAll(Map<String, dynamic> data) {
    final rawBuildings = data['buildings'];
    if (rawBuildings is List) {
      _buildings = rawBuildings.whereType<Map<String, dynamic>>().map((j) => BuildingRecord.fromJson(j)).whereType<BuildingRecord>().toList();
    }
    final rawBatches = data['batches'];
    if (rawBatches is List) {
      _batches = rawBatches.whereType<Map<String, dynamic>>().map((j) => BatchRecord.fromJson(j)).whereType<BatchRecord>().toList();
    }
    final rawGrowths = data['growths'];
    if (rawGrowths is List) {
      _growths = rawGrowths.whereType<Map<String, dynamic>>().map((j) => GrowthRecord.fromJson(j)).whereType<GrowthRecord>().toList();
    }
  }

  Map<String, dynamic> _buildLocalMap() {
    return {
      'buildings': _buildings.map((b) => b.toJson()).toList(),
      'batches': _batches.map((b) => b.toJson()).toList(),
      'growths': _growths.map((g) => g.toJson()).toList(),
    };
  }

  Future<void> addBuilding(BuildingRecord building) async {
    _buildings = [..._buildings, building];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> addBatch(BatchRecord batch) async {
    _batches = [..._batches, batch];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> addGrowth(GrowthRecord growth) async {
    _growths = [..._growths, growth];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock(_buildLocalMap());
  }
}
