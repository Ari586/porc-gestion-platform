import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/sale_record.dart';
import '../../../core/models/stock_item.dart';
import '../../../core/models/client.dart';
import '../../../core/models/supplier.dart';
import '../../../core/services/service_locator.dart';
import '../data/commercial_repository.dart';

final commercialRepositoryProvider =
    Provider<CommercialRepository>((_) => getIt<CommercialRepository>());

final commercialDataProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(commercialRepositoryProvider);
  return repo.watch();
});

final salesListProvider = Provider<List<SaleRecord>>((ref) {
  final data = ref.watch(commercialDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['sales'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => SaleRecord.fromJson(j))
      .whereType<SaleRecord>()
      .toList();
});

final stockListProvider = Provider<List<StockItem>>((ref) {
  final data = ref.watch(commercialDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['stocks'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => StockItem.fromJson(j))
      .whereType<StockItem>()
      .toList();
});

final clientListProvider = Provider<List<Client>>((ref) {
  final data = ref.watch(commercialDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['clients'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => Client.fromJson(j))
      .whereType<Client>()
      .toList();
});

final supplierListProvider = Provider<List<Supplier>>((ref) {
  final data = ref.watch(commercialDataProvider).valueOrNull;
  if (data == null) return [];
  final raw = data['suppliers'];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((j) => Supplier.fromJson(j))
      .whereType<Supplier>()
      .toList();
});
