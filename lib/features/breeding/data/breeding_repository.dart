import 'dart:async';

import '../../../core/models/building_record.dart';
import '../../../core/models/batch_record.dart';
import '../../../core/models/growth_record.dart';
import '../../../core/services/cloud_sync_service.dart';

class BreedingRepository {
  final CloudSyncService _sync;
  List<BuildingRecord> _buildings = [];
  List<BatchRecord> _batches = [];
  List<GrowthRecord> _growths = [];

  BreedingRepository(this._sync);

  List<BuildingRecord> get buildings => List.unmodifiable(_buildings);
  List<BatchRecord> get batches => List.unmodifiable(_batches);
  List<GrowthRecord> get growths => List.unmodifiable(_growths);

  Future<void> load() async {
    final data = await _sync.fetchLivestock();
    _parseAll(data);
  }

  Stream<Map<String, dynamic>> watch() => _sync.watchLivestock();

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

  Future<void> addBuilding(BuildingRecord building) async {
    _buildings = [..._buildings, building];
    await _persist();
  }

  Future<void> addBatch(BatchRecord batch) async {
    _batches = [..._batches, batch];
    await _persist();
  }

  Future<void> addGrowth(GrowthRecord growth) async {
    _growths = [..._growths, growth];
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveLivestock({
      'buildings': _buildings.map((b) => b.toJson()).toList(),
      'batches': _batches.map((b) => b.toJson()).toList(),
      'growths': _growths.map((g) => g.toJson()).toList(),
    });
  }
}
