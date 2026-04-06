import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/sale_record.dart';
import '../../../core/models/stock_item.dart';
import '../../../core/models/client.dart';
import '../../../core/models/supplier.dart';
import '../../../core/services/cloud_sync_service.dart';

class CommercialRepository {
  final CloudSyncService _sync;
  List<SaleRecord> _sales = [];
  List<StockItem> _stocks = [];
  List<Client> _clients = [];
  List<Supplier> _suppliers = [];
  final _localController = StreamController<Map<String, dynamic>>.broadcast();

  CommercialRepository(this._sync);

  List<SaleRecord> get sales => List.unmodifiable(_sales);
  List<StockItem> get stocks => List.unmodifiable(_stocks);
  List<Client> get clients => List.unmodifiable(_clients);
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  Future<void> load() async {
    final data = await _sync.fetchCommercial();
    _parseAll(data);
    _localController.add(_buildLocalMap());
  }

  Stream<Map<String, dynamic>> watch() {
    if (!_sync.available) {
      debugPrint('[CommercialRepo] Firebase unavailable – using local-only mode');
      Future.microtask(() => _localController.add(_buildLocalMap()));
      return _localController.stream;
    }
    return _sync.watchCommercial().map((data) {
      _parseAll(data);
      return data;
    });
  }

  void _parseAll(Map<String, dynamic> data) {
    final rawSales = data['sales'];
    if (rawSales is List) {
      _sales = rawSales.whereType<Map<String, dynamic>>().map((j) => SaleRecord.fromJson(j)).whereType<SaleRecord>().toList();
    }
    final rawStocks = data['stocks'];
    if (rawStocks is List) {
      _stocks = rawStocks.whereType<Map<String, dynamic>>().map((j) => StockItem.fromJson(j)).whereType<StockItem>().toList();
    }
    final rawClients = data['clients'];
    if (rawClients is List) {
      _clients = rawClients.whereType<Map<String, dynamic>>().map((j) => Client.fromJson(j)).whereType<Client>().toList();
    }
    final rawSuppliers = data['suppliers'];
    if (rawSuppliers is List) {
      _suppliers = rawSuppliers.whereType<Map<String, dynamic>>().map((j) => Supplier.fromJson(j)).whereType<Supplier>().toList();
    }
  }

  Map<String, dynamic> _buildLocalMap() {
    return {
      'sales': _sales.map((s) => s.toJson()).toList(),
      'stocks': _stocks.map((s) => s.toJson()).toList(),
      'clients': _clients.map((c) => c.toJson()).toList(),
      'suppliers': _suppliers.map((s) => s.toJson()).toList(),
    };
  }

  Future<void> addSale(SaleRecord sale) async {
    _sales = [..._sales, sale];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> addClient(Client client) async {
    _clients = [..._clients, client];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> addSupplier(Supplier supplier) async {
    _suppliers = [..._suppliers, supplier];
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> updateStock(StockItem item) async {
    _stocks = _stocks.map((s) => s.id == item.id ? item : s).toList();
    _localController.add(_buildLocalMap());
    await _persist();
  }

  Future<void> _persist() async {
    await _sync.saveCommercial(_buildLocalMap());
  }
}
