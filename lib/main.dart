import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const PigBreedingApp());
}

class PigBreedingApp extends StatelessWidget {
  const PigBreedingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion IA Porcine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class Roles {
  static const String admin = 'Responsable';
  static const String breeder = 'Éleveur';
  static const String inseminator = 'Inséminateur';
  static const String vet = 'Vétérinaire';
}

class AppTabs {
  static const String dashboard = 'dashboard';
  static const String administration = 'administration';
  static const String services = 'services';
  static const String elevage = 'elevage';
  static const String inseminations = 'inseminations';
  static const String boars = 'boars';
  static const String sows = 'sows';
  static const String pedigree = 'pedigree';
  static const String health = 'health';
  static const String commercial = 'commercial';
  static const String logiciel = 'logiciel';
  static const String users = 'users';
}

class UserProfile {
  final String id;
  final String code;
  final String name;
  final String role;
  final String avatar;
  final String login;
  final String password;

  const UserProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.role,
    required this.avatar,
    required this.login,
    required this.password,
  });
}

class Boar {
  final String id;
  final String code;
  final String name;
  final String breed;
  final DateTime birthDate;
  final String origin;
  final String breederId;
  final String sireCode;
  final String damCode;
  final String semenType;
  final String notes;
  final String imageBase64;

  const Boar({
    required this.id,
    required this.code,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.origin,
    this.breederId = '',
    this.sireCode = '',
    this.damCode = '',
    this.semenType = 'Fraîche',
    this.notes = '',
    this.imageBase64 = '',
  });
}

class Sow {
  final String id;
  final String code;
  final String name;
  final String breed;
  final DateTime birthDate;
  final int parity;
  final String breederId;
  final String sireCode;
  final String damCode;
  final String notes;

  const Sow({
    required this.id,
    required this.code,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.parity,
    this.breederId = '',
    this.sireCode = '',
    this.damCode = '',
    this.notes = '',
  });
}

class InseminationRecord {
  final String id;
  final String sowCode;
  final String boarCode;
  final String semenLot;
  final DateTime dose1Date;
  final DateTime? dose2Date;
  final String inseminator;
  final String status;
  final String notes;

  const InseminationRecord({
    required this.id,
    required this.sowCode,
    required this.boarCode,
    required this.semenLot,
    required this.dose1Date,
    this.dose2Date,
    required this.inseminator,
    required this.status,
    this.notes = '',
  });
}

class HealthRecord {
  final String id;
  final String animalType;
  final String animalCode;
  final String eventType;
  final DateTime eventDate;
  final String product;
  final String dose;
  final String reason;
  final DateTime? nextDate;
  final String responsible;
  final String notes;

  const HealthRecord({
    required this.id,
    required this.animalType,
    required this.animalCode,
    required this.eventType,
    required this.eventDate,
    required this.product,
    required this.dose,
    required this.reason,
    this.nextDate,
    required this.responsible,
    this.notes = '',
  });
}

class Client {
  final String id;
  final String name;
  final String segment;
  final String contact;

  const Client({
    required this.id,
    required this.name,
    required this.segment,
    required this.contact,
  });
}

class Supplier {
  final String id;
  final String name;
  final String category;
  final String contact;

  const Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.contact,
  });
}

class SaleRecord {
  final String id;
  final String type;
  final String clientId;
  final DateTime date;
  final int quantity;
  final double amount;

  const SaleRecord({
    required this.id,
    required this.type,
    required this.clientId,
    required this.date,
    required this.quantity,
    required this.amount,
  });
}

class SupplyRecord {
  final String id;
  final String category;
  final String supplierId;
  final DateTime date;
  final double amount;
  final String notes;

  const SupplyRecord({
    required this.id,
    required this.category,
    required this.supplierId,
    required this.date,
    required this.amount,
    this.notes = '',
  });
}

class StockItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double alertThreshold;

  const StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.alertThreshold,
  });
}

class BuildingRecord {
  final String id;
  final String name;
  final String type;
  final int capacity;
  final int occupied;

  const BuildingRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.occupied,
  });
}

class BatchRecord {
  final String id;
  final String name;
  final String stage;
  final DateTime startDate;
  final int animals;
  final double avgWeight;

  const BatchRecord({
    required this.id,
    required this.name,
    required this.stage,
    required this.startDate,
    required this.animals,
    required this.avgWeight,
  });
}

class GrowthRecord {
  final String id;
  final String batchId;
  final DateTime date;
  final double avgWeight;
  final double dailyGain;

  const GrowthRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.avgWeight,
    required this.dailyGain,
  });
}

const List<UserProfile> initialUsers = [
  UserProfile(
    id: 'U1',
    code: 'ADM-01',
    name: 'Jean Responsable',
    role: Roles.admin,
    avatar: 'J',
    login: 'admin',
    password: 'Admin@2026',
  ),
  UserProfile(
    id: 'U2',
    code: 'ELV-01',
    name: 'Marc Éleveur',
    role: Roles.breeder,
    avatar: 'M',
    login: 'eleveur',
    password: 'Elevage@2026',
  ),
  UserProfile(
    id: 'U3',
    code: 'INS-01',
    name: 'Paul Insem',
    role: Roles.inseminator,
    avatar: 'P',
    login: 'insemination',
    password: 'Insem@2026',
  ),
  UserProfile(
    id: 'U4',
    code: 'VET-01',
    name: 'Lucie Véto',
    role: Roles.vet,
    avatar: 'L',
    login: 'veto',
    password: 'Sante@2026',
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _prefsUsersKey = 'porc_users_v1';
  static const String _prefsBoarsKey = 'porc_boars_v1';
  static const String _prefsSowsKey = 'porc_sows_v1';
  static const String _prefsInseminationsKey = 'porc_inseminations_v1';
  static const String _prefsHealthKey = 'porc_health_v1';
  static const String _prefsClientsKey = 'porc_clients_v1';
  static const String _prefsSuppliersKey = 'porc_suppliers_v1';
  static const String _prefsSalesKey = 'porc_sales_v1';
  static const String _prefsSuppliesKey = 'porc_supplies_v1';
  static const String _prefsPreferredBoarCodeKey = 'porc_preferred_boar_v1';
  static const String _prefsCurrentUserIdKey = 'porc_current_user_v1';
  static const String _prefsSalesFilterKey = 'porc_sales_filter_v1';
  static const String _prefsActiveTabKey = 'porc_active_tab_v1';
  static const String _prefsAuthenticatedKey = 'porc_authenticated_v1';
  static const String _prefsGestationMonthKey = 'porc_gestation_month_v1';
  static const String _prefsSelectedGestationDateKey =
      'porc_gestation_selected_date_v1';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<UserProfile> _users = List<UserProfile>.from(initialUsers);

  UserProfile _currentUser = initialUsers.first;
  String _activeTab = AppTabs.dashboard;
  bool _isAuthenticated = false;
  bool _hidePassword = true;
  String? _authError;
  DateTime _gestationCalendarMonth = DateTime.now();
  DateTime? _selectedGestationDate;
  String? _preferredBoarCode;
  bool _stateLoading = true;

  final List<Boar> _boars = [
    Boar(
      id: 'B1',
      code: 'VR-1001',
      name: 'Atlas',
      breed: 'Large White',
      birthDate: DateTime(2023, 4, 2),
      origin: 'Station Alpha',
      breederId: 'U2',
      sireCode: 'VR-900',
      damCode: 'TV-300',
      semenType: 'Fraîche',
    ),
    Boar(
      id: 'B2',
      code: 'VR-1002',
      name: 'Titan',
      breed: 'Landrace',
      birthDate: DateTime(2023, 6, 14),
      origin: 'Station Beta',
      breederId: 'U2',
      sireCode: 'VR-910',
      damCode: 'TV-280',
      semenType: 'Congelée',
    ),
  ];

  final List<Sow> _sows = [
    Sow(
      id: 'S1',
      code: 'TR-2001',
      name: 'Nova',
      breed: 'Large White',
      birthDate: DateTime(2023, 1, 22),
      parity: 2,
      breederId: 'U2',
      sireCode: 'VR-880',
      damCode: 'TR-1200',
    ),
    Sow(
      id: 'S2',
      code: 'TR-2002',
      name: 'Luna',
      breed: 'Duroc',
      birthDate: DateTime(2022, 11, 9),
      parity: 3,
      breederId: 'U2',
      sireCode: 'VR-870',
      damCode: 'TR-1180',
    ),
  ];

  final List<InseminationRecord> _inseminations = [
    InseminationRecord(
      id: 'IA1',
      sowCode: 'TR-2001',
      boarCode: 'VR-1001',
      semenLot: 'LOT-IA-2405',
      dose1Date: DateTime.now().subtract(const Duration(days: 8)),
      dose2Date: DateTime.now().subtract(const Duration(days: 8, hours: -8)),
      inseminator: 'Paul Insem',
      status: 'Gestante confirmée',
      notes: 'Bon comportement post-IA',
    ),
    InseminationRecord(
      id: 'IA2',
      sowCode: 'TR-2002',
      boarCode: 'VR-1002',
      semenLot: 'LOT-IA-2406',
      dose1Date: DateTime.now().subtract(const Duration(days: 3)),
      inseminator: 'Paul Insem',
      status: 'En attente diagnostic',
    ),
  ];

  final List<HealthRecord> _healthRecords = [
    HealthRecord(
      id: 'H1',
      animalType: 'Truie',
      animalCode: 'TR-2001',
      eventType: 'Vaccin',
      eventDate: DateTime.now().subtract(const Duration(days: 14)),
      product: 'Parvovax',
      dose: '2 ml',
      reason: 'Rappel pré-gestation',
      nextDate: DateTime.now().add(const Duration(days: 16)),
      responsible: 'Lucie Véto',
    ),
    HealthRecord(
      id: 'H2',
      animalType: 'Verrat',
      animalCode: 'VR-1002',
      eventType: 'Traitement',
      eventDate: DateTime.now().subtract(const Duration(days: 5)),
      product: 'Ivermectine',
      dose: '1.5 ml',
      reason: 'Vermifuge',
      responsible: 'Lucie Véto',
    ),
  ];

  String _salesFilter = '30 jours';
  final List<String> _salesFilterOptions = const [
    '7 jours',
    '30 jours',
    '90 jours',
    '12 mois',
  ];

  final List<Client> _clients = [
    Client(
      id: 'CL1',
      name: 'Boucherie Andry',
      segment: 'Charcutier',
      contact: '+261 34 00 01 001',
    ),
    Client(
      id: 'CL2',
      name: 'Ferme Rakoto',
      segment: 'Éleveur porcelets',
      contact: '+261 34 00 01 002',
    ),
    Client(
      id: 'CL3',
      name: 'Marché Central',
      segment: 'Autre vente',
      contact: '+261 34 00 01 003',
    ),
  ];

  final List<Supplier> _suppliers = [
    Supplier(
      id: 'SUP1',
      name: 'NutriFeed',
      category: 'Aliments',
      contact: 'contact@nutrifeed.mg',
    ),
    Supplier(
      id: 'SUP2',
      name: 'GenDose',
      category: 'Doses semence',
      contact: 'contact@gendose.mg',
    ),
    Supplier(
      id: 'SUP3',
      name: 'PharmaVet',
      category: 'Médicaments',
      contact: 'contact@pharmavet.mg',
    ),
  ];

  final List<SaleRecord> _salesRecords = [
    SaleRecord(
      id: 'SLE1',
      type: 'Vente de porcs (charcutiers)',
      clientId: 'CL1',
      date: DateTime.now().subtract(const Duration(days: 5)),
      quantity: 12,
      amount: 4200000,
    ),
    SaleRecord(
      id: 'SLE2',
      type: 'Vente de porcelets',
      clientId: 'CL2',
      date: DateTime.now().subtract(const Duration(days: 12)),
      quantity: 24,
      amount: 3600000,
    ),
    SaleRecord(
      id: 'SLE3',
      type: 'Autre vente',
      clientId: 'CL3',
      date: DateTime.now().subtract(const Duration(days: 20)),
      quantity: 8,
      amount: 1200000,
    ),
    SaleRecord(
      id: 'SLE4',
      type: 'Vente de porcs (charcutiers)',
      clientId: 'CL1',
      date: DateTime.now().subtract(const Duration(days: 33)),
      quantity: 10,
      amount: 3400000,
    ),
    SaleRecord(
      id: 'SLE5',
      type: 'Vente de porcelets',
      clientId: 'CL2',
      date: DateTime.now().subtract(const Duration(days: 46)),
      quantity: 18,
      amount: 2700000,
    ),
  ];

  final List<SupplyRecord> _supplyRecords = [
    SupplyRecord(
      id: 'SP1',
      category: 'Aliments',
      supplierId: 'SUP1',
      date: DateTime.now().subtract(const Duration(days: 4)),
      amount: 1800000,
      notes: 'Ravitaillement concentré croissance',
    ),
    SupplyRecord(
      id: 'SP2',
      category: 'Doses semence',
      supplierId: 'SUP2',
      date: DateTime.now().subtract(const Duration(days: 11)),
      amount: 950000,
      notes: 'Lot semence IA',
    ),
    SupplyRecord(
      id: 'SP3',
      category: 'Médicaments',
      supplierId: 'SUP3',
      date: DateTime.now().subtract(const Duration(days: 17)),
      amount: 620000,
      notes: 'Vaccins et vermifuge',
    ),
  ];

  final List<StockItem> _stockItems = const [
    StockItem(
      id: 'ST1',
      name: 'Aliment croissance',
      category: 'Aliments',
      unit: 'kg',
      quantity: 1450,
      alertThreshold: 600,
    ),
    StockItem(
      id: 'ST2',
      name: 'Aliment gestation',
      category: 'Aliments',
      unit: 'kg',
      quantity: 920,
      alertThreshold: 500,
    ),
    StockItem(
      id: 'ST3',
      name: 'Doses semence LW',
      category: 'Doses',
      unit: 'dose',
      quantity: 42,
      alertThreshold: 20,
    ),
    StockItem(
      id: 'ST4',
      name: 'Doses semence LR',
      category: 'Doses',
      unit: 'dose',
      quantity: 18,
      alertThreshold: 20,
    ),
  ];

  final List<BuildingRecord> _buildings = const [
    BuildingRecord(
      id: 'BLD1',
      name: 'Bâtiment A',
      type: 'Maternité',
      capacity: 40,
      occupied: 34,
    ),
    BuildingRecord(
      id: 'BLD2',
      name: 'Bâtiment B',
      type: 'Gestation',
      capacity: 60,
      occupied: 48,
    ),
    BuildingRecord(
      id: 'BLD3',
      name: 'Bâtiment C',
      type: 'Post-sevrage',
      capacity: 120,
      occupied: 92,
    ),
  ];

  final List<BatchRecord> _batchRecords = [
    BatchRecord(
      id: 'BT1',
      name: 'Bande Jan-26',
      stage: 'Croissance',
      startDate: DateTime(2026, 1, 10),
      animals: 78,
      avgWeight: 42.5,
    ),
    BatchRecord(
      id: 'BT2',
      name: 'Bande Fev-26',
      stage: 'Post-sevrage',
      startDate: DateTime(2026, 2, 5),
      animals: 96,
      avgWeight: 21.7,
    ),
    BatchRecord(
      id: 'BT3',
      name: 'Bande Mar-26',
      stage: 'Maternité',
      startDate: DateTime(2026, 3, 1),
      animals: 55,
      avgWeight: 7.8,
    ),
  ];

  final List<GrowthRecord> _growthRecords = [
    GrowthRecord(
      id: 'GR1',
      batchId: 'BT1',
      date: DateTime.now().subtract(const Duration(days: 14)),
      avgWeight: 38.2,
      dailyGain: 0.62,
    ),
    GrowthRecord(
      id: 'GR2',
      batchId: 'BT1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      avgWeight: 41.3,
      dailyGain: 0.64,
    ),
    GrowthRecord(
      id: 'GR3',
      batchId: 'BT2',
      date: DateTime.now().subtract(const Duration(days: 7)),
      avgWeight: 20.9,
      dailyGain: 0.47,
    ),
    GrowthRecord(
      id: 'GR4',
      batchId: 'BT3',
      date: DateTime.now().subtract(const Duration(days: 3)),
      avgWeight: 7.3,
      dailyGain: 0.29,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDefaultState();
    _loadPersistedState();
  }

  @override
  Widget build(BuildContext context) {
    if (_stateLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return Scaffold(body: _buildLoginScreen());
    }
    _ensureActiveTabAccess();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 980;
    final contentPadding = screenWidth > 720 ? 24.0 : 12.0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) SizedBox(width: 280, child: _buildSidebar()),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(isDesktop),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(contentPadding),
                      child: _buildActiveContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canAddForTab(_activeTab)
          ? FloatingActionButton.extended(
              onPressed: _openAddDialogForTab,
              icon: Icon(_fabIconForTab(_activeTab)),
              label: Text(_fabLabelForTab(_activeTab)),
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initializeDefaultState() {
    if (_users.isNotEmpty) {
      _currentUser = _users.first;
    }
    if (_boars.isNotEmpty) {
      _preferredBoarCode = _boars.first.code;
    }
    final today = _currentDate();
    _gestationCalendarMonth = DateTime(today.year, today.month, 1);
    _selectedGestationDate = today;
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = _decodeObjectListOrNull(prefs.getString(_prefsUsersKey));
      final boarsRaw = _decodeObjectListOrNull(prefs.getString(_prefsBoarsKey));
      final sowsRaw = _decodeObjectListOrNull(prefs.getString(_prefsSowsKey));
      final inseminationsRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsInseminationsKey),
      );
      final healthRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsHealthKey),
      );
      final clientsRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsClientsKey),
      );
      final suppliersRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsSuppliersKey),
      );
      final salesRaw = _decodeObjectListOrNull(prefs.getString(_prefsSalesKey));
      final suppliesRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsSuppliesKey),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (usersRaw != null) {
          final loadedUsers = usersRaw
              .map(_userFromJson)
              .whereType<UserProfile>()
              .toList();
          _users
            ..clear()
            ..addAll(loadedUsers.isNotEmpty ? loadedUsers : initialUsers);
        }

        if (boarsRaw != null) {
          _boars
            ..clear()
            ..addAll(boarsRaw.map(_boarFromJson).whereType<Boar>());
        }

        if (sowsRaw != null) {
          _sows
            ..clear()
            ..addAll(sowsRaw.map(_sowFromJson).whereType<Sow>());
        }

        if (inseminationsRaw != null) {
          _inseminations
            ..clear()
            ..addAll(
              inseminationsRaw
                  .map(_inseminationFromJson)
                  .whereType<InseminationRecord>(),
            );
        }

        if (healthRaw != null) {
          _healthRecords
            ..clear()
            ..addAll(healthRaw.map(_healthFromJson).whereType<HealthRecord>());
        }

        if (clientsRaw != null) {
          _clients
            ..clear()
            ..addAll(clientsRaw.map(_clientFromJson).whereType<Client>());
        }

        if (suppliersRaw != null) {
          _suppliers
            ..clear()
            ..addAll(suppliersRaw.map(_supplierFromJson).whereType<Supplier>());
        }

        if (salesRaw != null) {
          _salesRecords
            ..clear()
            ..addAll(salesRaw.map(_saleFromJson).whereType<SaleRecord>());
        }

        if (suppliesRaw != null) {
          _supplyRecords
            ..clear()
            ..addAll(
              suppliesRaw.map(_supplyFromJson).whereType<SupplyRecord>(),
            );
        }

        final savedUserId = _readString(
          prefs.getString(_prefsCurrentUserIdKey),
        );
        if (savedUserId.isNotEmpty) {
          _currentUser = _findUserById(savedUserId) ?? _currentUser;
        }
        if (_findUserById(_currentUser.id) == null && _users.isNotEmpty) {
          _currentUser = _users.first;
        }

        _preferredBoarCode = _resolvePreferredBoarCode(
          prefs.getString(_prefsPreferredBoarCodeKey),
        );

        final savedSalesFilter = prefs.getString(_prefsSalesFilterKey);
        if (savedSalesFilter != null &&
            _salesFilterOptions.contains(savedSalesFilter)) {
          _salesFilter = savedSalesFilter;
        }

        final savedMonth = _parseDateFromString(
          prefs.getString(_prefsGestationMonthKey),
        );
        if (savedMonth != null) {
          _gestationCalendarMonth = DateTime(
            savedMonth.year,
            savedMonth.month,
            1,
          );
        }

        final savedSelectedDate = _parseDateFromString(
          prefs.getString(_prefsSelectedGestationDateKey),
        );
        if (savedSelectedDate != null) {
          _selectedGestationDate = savedSelectedDate;
        }

        _isAuthenticated = prefs.getBool(_prefsAuthenticatedKey) ?? false;

        final savedTab = prefs.getString(_prefsActiveTabKey);
        if (savedTab != null && savedTab.trim().isNotEmpty) {
          _activeTab = savedTab;
        }
        _ensureActiveTabAccess();

        _stateLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _stateLoading = false);
    }
  }

  Future<void> _persistState() async {
    if (_stateLoading) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsUsersKey,
        jsonEncode(_users.map(_userToJson).toList()),
      );
      await prefs.setString(
        _prefsBoarsKey,
        jsonEncode(_boars.map(_boarToJson).toList()),
      );
      await prefs.setString(
        _prefsSowsKey,
        jsonEncode(_sows.map(_sowToJson).toList()),
      );
      await prefs.setString(
        _prefsInseminationsKey,
        jsonEncode(_inseminations.map(_inseminationToJson).toList()),
      );
      await prefs.setString(
        _prefsHealthKey,
        jsonEncode(_healthRecords.map(_healthToJson).toList()),
      );
      await prefs.setString(
        _prefsClientsKey,
        jsonEncode(_clients.map(_clientToJson).toList()),
      );
      await prefs.setString(
        _prefsSuppliersKey,
        jsonEncode(_suppliers.map(_supplierToJson).toList()),
      );
      await prefs.setString(
        _prefsSalesKey,
        jsonEncode(_salesRecords.map(_saleToJson).toList()),
      );
      await prefs.setString(
        _prefsSuppliesKey,
        jsonEncode(_supplyRecords.map(_supplyToJson).toList()),
      );
      if (_preferredBoarCode == null || _preferredBoarCode!.trim().isEmpty) {
        await prefs.remove(_prefsPreferredBoarCodeKey);
      } else {
        await prefs.setString(_prefsPreferredBoarCodeKey, _preferredBoarCode!);
      }
      await prefs.setString(_prefsCurrentUserIdKey, _currentUser.id);
      await prefs.setString(_prefsSalesFilterKey, _salesFilter);
      await prefs.setString(_prefsActiveTabKey, _activeTab);
      await prefs.setBool(_prefsAuthenticatedKey, _isAuthenticated);
      await prefs.setString(
        _prefsGestationMonthKey,
        _normalizeDate(_gestationCalendarMonth).toIso8601String(),
      );
      if (_selectedGestationDate == null) {
        await prefs.remove(_prefsSelectedGestationDateKey);
      } else {
        await prefs.setString(
          _prefsSelectedGestationDateKey,
          _normalizeDate(_selectedGestationDate!).toIso8601String(),
        );
      }
    } catch (_) {
      // Keep UI responsive even if local persistence fails.
    }
  }

  List<Map<String, dynamic>>? _decodeObjectListOrNull(String? raw) {
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return null;
      }
      final items = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is Map) {
          items.add(Map<String, dynamic>.from(item));
        }
      }
      return items;
    } catch (_) {
      return null;
    }
  }

  String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(_readString(value)) ?? 0;
  }

  DateTime? _parseDateFromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String? _resolvePreferredBoarCode(String? rawCode) {
    if (_boars.isEmpty) {
      return null;
    }
    final normalized = _readString(rawCode).trim().toLowerCase();
    if (normalized.isEmpty) {
      return _boars.first.code;
    }
    for (final boar in _boars) {
      if (boar.code.trim().toLowerCase() == normalized) {
        return boar.code;
      }
    }
    return _boars.first.code;
  }

  Map<String, dynamic> _userToJson(UserProfile user) {
    return {
      'id': user.id,
      'code': user.code,
      'name': user.name,
      'role': user.role,
      'avatar': user.avatar,
      'login': user.login,
      'password': user.password,
    };
  }

  UserProfile? _userFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final code = _readString(json['code']).trim();
    final name = _readString(json['name']).trim();
    final role = _readString(json['role']).trim();
    final avatar = _readString(json['avatar']).trim();
    final login = _readString(json['login']).trim();
    final password = _readString(json['password']);
    if (id.isEmpty ||
        code.isEmpty ||
        name.isEmpty ||
        role.isEmpty ||
        avatar.isEmpty ||
        login.isEmpty ||
        password.isEmpty) {
      return null;
    }
    return UserProfile(
      id: id,
      code: code,
      name: name,
      role: role,
      avatar: avatar,
      login: login,
      password: password,
    );
  }

  Map<String, dynamic> _boarToJson(Boar boar) {
    return {
      'id': boar.id,
      'code': boar.code,
      'name': boar.name,
      'breed': boar.breed,
      'birthDate': boar.birthDate.toIso8601String(),
      'origin': boar.origin,
      'breederId': boar.breederId,
      'sireCode': boar.sireCode,
      'damCode': boar.damCode,
      'semenType': boar.semenType,
      'notes': boar.notes,
      'imageBase64': boar.imageBase64,
    };
  }

  Boar? _boarFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final code = _readString(json['code']).trim();
    final name = _readString(json['name']).trim();
    final breed = _readString(json['breed']).trim();
    final origin = _readString(json['origin']).trim();
    final birthDate = _parseDateFromString(_readString(json['birthDate']));
    if (id.isEmpty ||
        code.isEmpty ||
        name.isEmpty ||
        breed.isEmpty ||
        origin.isEmpty ||
        birthDate == null) {
      return null;
    }
    return Boar(
      id: id,
      code: code,
      name: name,
      breed: breed,
      birthDate: birthDate,
      origin: origin,
      breederId: _readString(json['breederId']).trim(),
      sireCode: _readString(json['sireCode']).trim(),
      damCode: _readString(json['damCode']).trim(),
      semenType: _readString(json['semenType']).trim().isEmpty
          ? 'Fraîche'
          : _readString(json['semenType']).trim(),
      notes: _readString(json['notes']),
      imageBase64: _readString(json['imageBase64']),
    );
  }

  Map<String, dynamic> _sowToJson(Sow sow) {
    return {
      'id': sow.id,
      'code': sow.code,
      'name': sow.name,
      'breed': sow.breed,
      'birthDate': sow.birthDate.toIso8601String(),
      'parity': sow.parity,
      'breederId': sow.breederId,
      'sireCode': sow.sireCode,
      'damCode': sow.damCode,
      'notes': sow.notes,
    };
  }

  Sow? _sowFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final code = _readString(json['code']).trim();
    final name = _readString(json['name']).trim();
    final breed = _readString(json['breed']).trim();
    final birthDate = _parseDateFromString(_readString(json['birthDate']));
    final parity = _readInt(json['parity']);
    if (id.isEmpty ||
        code.isEmpty ||
        name.isEmpty ||
        breed.isEmpty ||
        birthDate == null ||
        parity <= 0) {
      return null;
    }
    return Sow(
      id: id,
      code: code,
      name: name,
      breed: breed,
      birthDate: birthDate,
      parity: parity,
      breederId: _readString(json['breederId']).trim(),
      sireCode: _readString(json['sireCode']).trim(),
      damCode: _readString(json['damCode']).trim(),
      notes: _readString(json['notes']),
    );
  }

  Map<String, dynamic> _inseminationToJson(InseminationRecord record) {
    return {
      'id': record.id,
      'sowCode': record.sowCode,
      'boarCode': record.boarCode,
      'semenLot': record.semenLot,
      'dose1Date': record.dose1Date.toIso8601String(),
      'dose2Date': record.dose2Date?.toIso8601String(),
      'inseminator': record.inseminator,
      'status': record.status,
      'notes': record.notes,
    };
  }

  InseminationRecord? _inseminationFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final sowCode = _readString(json['sowCode']).trim();
    final boarCode = _readString(json['boarCode']).trim();
    final semenLot = _readString(json['semenLot']).trim();
    final dose1Date = _parseDateFromString(_readString(json['dose1Date']));
    final dose2Date = _parseDateFromString(_readString(json['dose2Date']));
    final inseminator = _readString(json['inseminator']).trim();
    final status = _readString(json['status']).trim();
    if (id.isEmpty ||
        sowCode.isEmpty ||
        boarCode.isEmpty ||
        semenLot.isEmpty ||
        dose1Date == null ||
        inseminator.isEmpty ||
        status.isEmpty) {
      return null;
    }
    return InseminationRecord(
      id: id,
      sowCode: sowCode,
      boarCode: boarCode,
      semenLot: semenLot,
      dose1Date: dose1Date,
      dose2Date: dose2Date,
      inseminator: inseminator,
      status: status,
      notes: _readString(json['notes']),
    );
  }

  Map<String, dynamic> _healthToJson(HealthRecord record) {
    return {
      'id': record.id,
      'animalType': record.animalType,
      'animalCode': record.animalCode,
      'eventType': record.eventType,
      'eventDate': record.eventDate.toIso8601String(),
      'product': record.product,
      'dose': record.dose,
      'reason': record.reason,
      'nextDate': record.nextDate?.toIso8601String(),
      'responsible': record.responsible,
      'notes': record.notes,
    };
  }

  HealthRecord? _healthFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final animalType = _readString(json['animalType']).trim();
    final animalCode = _readString(json['animalCode']).trim();
    final eventType = _readString(json['eventType']).trim();
    final eventDate = _parseDateFromString(_readString(json['eventDate']));
    final product = _readString(json['product']).trim();
    final dose = _readString(json['dose']).trim();
    final reason = _readString(json['reason']).trim();
    final responsible = _readString(json['responsible']).trim();
    if (id.isEmpty ||
        animalType.isEmpty ||
        animalCode.isEmpty ||
        eventType.isEmpty ||
        eventDate == null ||
        product.isEmpty ||
        dose.isEmpty ||
        reason.isEmpty ||
        responsible.isEmpty) {
      return null;
    }
    return HealthRecord(
      id: id,
      animalType: animalType,
      animalCode: animalCode,
      eventType: eventType,
      eventDate: eventDate,
      product: product,
      dose: dose,
      reason: reason,
      nextDate: _parseDateFromString(_readString(json['nextDate'])),
      responsible: responsible,
      notes: _readString(json['notes']),
    );
  }

  Map<String, dynamic> _clientToJson(Client client) {
    return {
      'id': client.id,
      'name': client.name,
      'segment': client.segment,
      'contact': client.contact,
    };
  }

  Client? _clientFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final name = _readString(json['name']).trim();
    final segment = _readString(json['segment']).trim();
    if (id.isEmpty || name.isEmpty || segment.isEmpty) {
      return null;
    }
    return Client(
      id: id,
      name: name,
      segment: segment,
      contact: _readString(json['contact']).trim(),
    );
  }

  Map<String, dynamic> _supplierToJson(Supplier supplier) {
    return {
      'id': supplier.id,
      'name': supplier.name,
      'category': supplier.category,
      'contact': supplier.contact,
    };
  }

  Supplier? _supplierFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final name = _readString(json['name']).trim();
    final category = _readString(json['category']).trim();
    if (id.isEmpty || name.isEmpty || category.isEmpty) {
      return null;
    }
    return Supplier(
      id: id,
      name: name,
      category: category,
      contact: _readString(json['contact']).trim(),
    );
  }

  Map<String, dynamic> _saleToJson(SaleRecord sale) {
    return {
      'id': sale.id,
      'type': sale.type,
      'clientId': sale.clientId,
      'date': sale.date.toIso8601String(),
      'quantity': sale.quantity,
      'amount': sale.amount,
    };
  }

  SaleRecord? _saleFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final type = _readString(json['type']).trim();
    final clientId = _readString(json['clientId']).trim();
    final date = _parseDateFromString(_readString(json['date']));
    final quantity = _readInt(json['quantity']);
    final amount = _readDouble(json['amount']);
    if (id.isEmpty ||
        type.isEmpty ||
        clientId.isEmpty ||
        date == null ||
        quantity <= 0 ||
        amount <= 0) {
      return null;
    }
    return SaleRecord(
      id: id,
      type: type,
      clientId: clientId,
      date: date,
      quantity: quantity,
      amount: amount,
    );
  }

  Map<String, dynamic> _supplyToJson(SupplyRecord supply) {
    return {
      'id': supply.id,
      'category': supply.category,
      'supplierId': supply.supplierId,
      'date': supply.date.toIso8601String(),
      'amount': supply.amount,
      'notes': supply.notes,
    };
  }

  SupplyRecord? _supplyFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final category = _readString(json['category']).trim();
    final supplierId = _readString(json['supplierId']).trim();
    final date = _parseDateFromString(_readString(json['date']));
    final amount = _readDouble(json['amount']);
    if (id.isEmpty ||
        category.isEmpty ||
        supplierId.isEmpty ||
        date == null ||
        amount <= 0) {
      return null;
    }
    return SupplyRecord(
      id: id,
      category: category,
      supplierId: supplierId,
      date: date,
      amount: amount,
      notes: _readString(json['notes']),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.piggyBank,
                  color: Color(0xFF2DD4BF),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PORC GESTION',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_canAccessTab(AppTabs.dashboard))
            _buildNavItem(
              icon: LucideIcons.layoutDashboard,
              label: 'Tableau de bord',
              tabId: AppTabs.dashboard,
            ),
          if (_canAccessTab(AppTabs.administration))
            _buildNavItem(
              icon: LucideIcons.users,
              label: 'Interface & Admin',
              tabId: AppTabs.administration,
            ),
          if (_canAccessTab(AppTabs.services))
            _buildNavItem(
              icon: LucideIcons.shieldCheck,
              label: 'Pack Services',
              tabId: AppTabs.services,
            ),
          if (_canAccessTab(AppTabs.elevage))
            _buildNavItem(
              icon: LucideIcons.piggyBank,
              label: 'Gestion Élevage',
              tabId: AppTabs.elevage,
            ),
          if (_canAccessTab(AppTabs.commercial))
            _buildNavItem(
              icon: LucideIcons.layers,
              label: 'Commercial & Stock',
              tabId: AppTabs.commercial,
            ),
          if (_canAccessTab(AppTabs.inseminations))
            _buildNavItem(
              icon: LucideIcons.syringe,
              label: 'Reproduction IA',
              tabId: AppTabs.inseminations,
            ),
          if (_canAccessTab(AppTabs.boars))
            _buildNavItem(
              icon: LucideIcons.badgeInfo,
              label: 'Verrats',
              tabId: AppTabs.boars,
            ),
          if (_canAccessTab(AppTabs.sows))
            _buildNavItem(
              icon: LucideIcons.piggyBank,
              label: 'Truies',
              tabId: AppTabs.sows,
            ),
          if (_canAccessTab(AppTabs.pedigree))
            _buildNavItem(
              icon: LucideIcons.dna,
              label: 'Pedigree',
              tabId: AppTabs.pedigree,
            ),
          if (_canAccessTab(AppTabs.health))
            _buildNavItem(
              icon: LucideIcons.shieldCheck,
              label: 'Vaccins & Traitements',
              tabId: AppTabs.health,
            ),
          if (_canAccessTab(AppTabs.logiciel))
            _buildNavItem(
              icon: LucideIcons.badgeInfo,
              label: 'Caractéristiques',
              tabId: AppTabs.logiciel,
            ),
          if (_canAccessTab(AppTabs.users))
            _buildNavItem(
              icon: LucideIcons.users,
              label: 'Utilisateurs',
              tabId: AppTabs.users,
            ),
          const Spacer(),
          _buildCurrentUserCard(),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    final dateLabel = DateFormat(
      'EEEE d MMMM y',
      'fr_FR',
    ).format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDFA), Color(0xFFE2E8F0)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF0F766E),
                        child: Icon(
                          LucideIcons.piggyBank,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Connexion Utilisateur',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gestion d\'élevage porcin • $dateLabel',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _loginController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      hintText: 'admin',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    onSubmitted: (_) => _attemptLogin(),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_authError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _authError!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _attemptLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Sécurité active: les accès sont gérés par l\'administrateur.\n'
                      'Utilisez votre login personnel et votre mot de passe.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String tabId,
  }) {
    final isActive = _activeTab == tabId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!_canAccessTab(tabId)) {
            _showError('Accès refusé pour le rôle ${_currentUser.role}.');
            return;
          }
          setState(() => _activeTab = tabId);
          _persistState();
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F766E) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF14B8A6),
                child: Text(
                  _currentUser.avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _currentUser.role,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'Login: ${_currentUser.login}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF475569)),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Déconnexion'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 650;

    return Container(
      height: 66,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isDesktop)
                  IconButton(
                    icon: const Icon(LucideIcons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                Expanded(
                  child: Text(
                    _titleForTab(_activeTab),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: compact ? 13 : 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'AUJOURD\'HUI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                DateFormat(
                  compact ? 'd MMM' : 'EEEE d MMMM',
                  'fr_FR',
                ).format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContent() {
    if (!_canAccessTab(_activeTab)) {
      return _buildSectionCard(
        title: 'Accès restreint',
        subtitle: 'Ce module n\'est pas disponible pour votre rôle.',
        child: Text(
          'Rôle actuel: ${_currentUser.role}. Contactez le responsable si vous avez besoin d\'un accès supplémentaire.',
          style: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      );
    }

    switch (_activeTab) {
      case AppTabs.dashboard:
        return _buildDashboard();
      case AppTabs.administration:
        return _buildAdministrationHub();
      case AppTabs.services:
        return _buildServicesPack();
      case AppTabs.elevage:
        return _buildElevageHub();
      case AppTabs.inseminations:
        return _buildInseminationManagement();
      case AppTabs.boars:
        return _buildBoarManagement();
      case AppTabs.sows:
        return _buildSowManagement();
      case AppTabs.pedigree:
        return _buildPedigreeManagement();
      case AppTabs.health:
        return _buildHealthManagement();
      case AppTabs.commercial:
        return _buildCommercialHub();
      case AppTabs.logiciel:
        return _buildSoftwareFeatures();
      case AppTabs.users:
        return _buildUsersManagement();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdministrationHub() {
    final adminProfile = _adminUserProfile();
    final filteredSales = _filteredSalesRecords();
    final filteredRevenue = filteredSales.fold<double>(
      0,
      (sum, sale) => sum + sale.amount,
    );

    final clientRows = _clients
        .map(
          (client) => DataRow(
            cells: [
              DataCell(Text(client.name)),
              DataCell(Text(client.segment)),
              DataCell(Text(client.contact)),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer client',
                  onPressed: () => _deleteClient(client.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    final supplierRows = _suppliers
        .map(
          (supplier) => DataRow(
            cells: [
              DataCell(Text(supplier.name)),
              DataCell(Text(supplier.category)),
              DataCell(Text(supplier.contact)),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer fournisseur',
                  onPressed: () => _deleteSupplier(supplier.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Interface et Administration',
          subtitle:
              'Tableau de bord, profil admin, évolution des ventes et pilotage partenaires',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 860;
                  final summary = [
                    _buildMiniIndicator(
                      label: 'Tableau de bord',
                      value: '${_boars.length + _sows.length} animaux',
                      color: const Color(0xFF0284C7),
                    ),
                    _buildMiniIndicator(
                      label: 'Profil admin',
                      value: adminProfile.name,
                      color: const Color(0xFF7C3AED),
                    ),
                    _buildMiniIndicator(
                      label: 'Évolution des ventes',
                      value: _formatAmount(filteredRevenue),
                      color: const Color(0xFF15803D),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: summary[0]),
                        const SizedBox(width: 12),
                        Expanded(child: summary[1]),
                        const SizedBox(width: 12),
                        Expanded(child: summary[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      summary[0],
                      const SizedBox(height: 10),
                      summary[1],
                      const SizedBox(height: 10),
                      summary[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildSalesFilterControl(),
              const SizedBox(height: 12),
              _buildSalesEvolutionChart(filteredSales),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Clients',
          subtitle: 'Base commerciale active',
          emptyMessage: 'Aucun client enregistré.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddClientDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter client'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('CLIENT')),
            DataColumn(label: Text('SEGMENT')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: clientRows,
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Fournisseurs',
          subtitle: 'Partenaires ravitaillement et intrants',
          emptyMessage: 'Aucun fournisseur enregistré.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddSupplierDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter fournisseur'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('FOURNISSEUR')),
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: supplierRows,
        ),
      ],
    );
  }

  Widget _buildServicesPack() {
    final services = <_ServiceOffer>[
      const _ServiceOffer(
        title: 'Suivi vétérinaire',
        description:
            'Prévention sanitaire, protocoles vaccinaux et contrôle régulier des reproducteurs.',
        icon: LucideIcons.stethoscope,
        color: Color(0xFF0F766E),
        cadence: 'Hebdomadaire',
        deliverable: 'Plan vaccinal et suivi morbidité',
      ),
      const _ServiceOffer(
        title: 'Intervention d\'urgence',
        description:
            'Assistance rapide sur troubles reproductifs, mise-bas difficile et urgences sanitaires.',
        icon: LucideIcons.zap,
        color: Color(0xFF2563EB),
        cadence: '< 2h',
        deliverable: 'Protocole de stabilisation terrain',
      ),
      const _ServiceOffer(
        title: 'Suivi de performances',
        description:
            'Pilotage des KPI IA, fertilité, prolificité et croissance pour corriger les sous-performances.',
        icon: LucideIcons.barChart3,
        color: Color(0xFF16A34A),
        cadence: 'Mensuel',
        deliverable: 'Rapport KPI + plan correctif',
      ),
      const _ServiceOffer(
        title: 'Sécurisation élevage',
        description:
            'Renforcement biosécurité, traçabilité et conformité des pratiques d\'élevage.',
        icon: LucideIcons.shieldCheck,
        color: Color(0xFF1D4ED8),
        cadence: 'Mensuel',
        deliverable: 'Audit biosécurité + CAPA',
      ),
      const _ServiceOffer(
        title: 'Bien-être animal',
        description:
            'Amélioration des conditions d\'ambiance, logement, stress et conduite en maternité.',
        icon: LucideIcons.heart,
        color: Color(0xFFEA580C),
        cadence: 'Quinzaine',
        deliverable: 'Plan bien-être et confort',
      ),
      const _ServiceOffer(
        title: 'Management d\'équipe',
        description:
            'Organisation opérationnelle, routines de suivi et montée en compétence du personnel.',
        icon: LucideIcons.users,
        color: Color(0xFF7C3AED),
        cadence: 'Mensuel',
        deliverable: 'SOP terrain + brief équipe',
      ),
    ];
    final protocols = <_ServiceProtocol>[
      const _ServiceProtocol(
        title: 'Détection chaleurs et IA',
        window: 'J0 à J1',
        detail:
            'Observation 2x/jour, reflexe d\'immobilité, IA1 puis IA2 selon protocole élevage.',
        critical: true,
      ),
      const _ServiceProtocol(
        title: 'Contrôle retour chaleur',
        window: 'J21',
        detail:
            'Vérifier retour en chaleur et isoler les femelles à ré-inséminer.',
        critical: true,
      ),
      const _ServiceProtocol(
        title: 'Diagnostic de gestation',
        window: 'J28 à J35',
        detail:
            'Échographie et validation statut; mise à jour du plan de lot gestation.',
        critical: true,
      ),
      const _ServiceProtocol(
        title: 'Préparation mise-bas',
        window: 'J107 à J114',
        detail:
            'Entrée maternité, hygiène de case, matériel néonatal, protocole colostrum.',
        critical: true,
      ),
      const _ServiceProtocol(
        title: 'Sevrage et relance',
        window: 'J21 post-partum',
        detail:
            'Sevrage technique, état corporel truie et plan de relance reproduction.',
        critical: false,
      ),
    ];
    final serviceBenchmarks = _buildServiceBenchmarks();
    final biosecurityItems = _buildBiosecurityItems();
    final actionPlan = _computeBreedingActions();
    final protocolCriticalCount = protocols
        .where((item) => item.critical)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Pack Services & Accompagnement',
          subtitle:
              'Approche terrain orientée résultat: reproductif, sanitaire, technique et économique',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 860;
                  final indicators = [
                    _buildMiniIndicator(
                      label: 'Services actifs',
                      value: '${services.length}',
                      color: const Color(0xFF0284C7),
                    ),
                    _buildMiniIndicator(
                      label: 'Protocoles critiques',
                      value: '$protocolCriticalCount',
                      color: const Color(0xFFB45309),
                    ),
                    _buildMiniIndicator(
                      label: 'Interventions 30j',
                      value: '${actionPlan.length}',
                      color: const Color(0xFF15803D),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: indicators[0]),
                        const SizedBox(width: 12),
                        Expanded(child: indicators[1]),
                        const SizedBox(width: 12),
                        Expanded(child: indicators[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      indicators[0],
                      const SizedBox(height: 10),
                      indicators[1],
                      const SizedBox(height: 10),
                      indicators[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text('Suivi vétérinaire')),
                  Chip(label: Text('Intervention d\'urgence')),
                  Chip(label: Text('Suivi de performances')),
                  Chip(label: Text('Sécurisation élevage')),
                  Chip(label: Text('Bien-être animal')),
                  Chip(label: Text('Management d\'équipe')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 1220
                ? 3
                : width > 760
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: width > 760 ? 1.28 : 1.15,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: services.map(_buildServiceOfferCard).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Protocoles Techniques Prioritaires',
          subtitle:
              'Référentiel opérationnel recommandé pour une conduite reproduction rigoureuse',
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: protocols.length,
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final protocol = protocols[index];
              final color = protocol.critical
                  ? const Color(0xFFB91C1C)
                  : const Color(0xFF15803D);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(
                    protocol.critical
                        ? LucideIcons.alertTriangle
                        : LucideIcons.checkCircle2,
                    color: color,
                  ),
                ),
                title: Text(
                  protocol.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${protocol.window} • ${protocol.detail}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    protocol.critical ? 'Critique' : 'Standard',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Plan d\'Intervention Terrain (30 jours)',
          subtitle:
              'Actions programmées avec priorité et responsable recommandé',
          emptyMessage: 'Aucune intervention planifiée sur 30 jours.',
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('INTERVENTION')),
            DataColumn(label: Text('DÉTAIL')),
            DataColumn(label: Text('PRIORITÉ')),
            DataColumn(label: Text('RESPONSABLE')),
          ],
          rows: actionPlan
              .map(
                (action) => DataRow(
                  cells: [
                    DataCell(Text(_formatDate(action.dueDate))),
                    DataCell(Text(action.title)),
                    DataCell(Text(action.detail)),
                    DataCell(Text(_servicePriorityLabel(action.priority))),
                    DataCell(Text(_serviceResponsibleForAction(action))),
                  ],
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Référentiel de Performance',
          subtitle:
              'Comparaison des résultats actuels avec les cibles techniques élevage',
          child: Column(
            children: serviceBenchmarks
                .map(
                  (benchmark) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildServiceBenchmarkRow(benchmark),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Audit Biosécurité Express',
          subtitle:
              'Points de contrôle critiques pour limiter les pertes sanitaires et reproductives',
          child: Column(
            children: biosecurityItems
                .map((item) => _buildBiosecurityAuditRow(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceOfferCard(_ServiceOffer service) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: service.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: service.color),
          ),
          const SizedBox(height: 12),
          Text(
            service.title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadence: ${service.cadence}',
            style: TextStyle(
              color: service.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            'Livrable: ${service.deliverable}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _showInfo('Service "${service.title}" consulté.');
            },
            icon: const Icon(LucideIcons.chevronRight, size: 16),
            label: const Text('Voir le détail'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBenchmarkRow(_ServiceBenchmark benchmark) {
    final safeTarget = benchmark.targetValue <= 0 ? 1.0 : benchmark.targetValue;
    final ratio = (benchmark.currentValue / safeTarget).clamp(0.0, 1.0);
    final reached = benchmark.currentValue >= benchmark.targetValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                benchmark.label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${benchmark.currentValue.toStringAsFixed(0)}${benchmark.unit} / '
              '${benchmark.targetValue.toStringAsFixed(0)}${benchmark.unit}',
              style: TextStyle(
                color: reached
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB91C1C),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: ratio,
            backgroundColor: benchmark.color.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(benchmark.color),
          ),
        ),
      ],
    );
  }

  Widget _buildBiosecurityAuditRow(_BiosecurityItem item) {
    final color = item.ok ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.ok ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.detail,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ServiceBenchmark> _buildServiceBenchmarks() {
    final successCount = _inseminations
        .where((record) => _isSuccessfulStatus(record.status))
        .length;
    final failedCount = _inseminations
        .where((record) => _isFailedStatus(record.status))
        .length;
    final pendingCount = math.max(
      0,
      _inseminations.length - successCount - failedCount,
    );
    final decided = successCount + failedCount;
    final fertilityRate = decided == 0 ? 0.0 : (successCount / decided) * 100;
    final diagCoverage = _inseminations.isEmpty
        ? 0.0
        : ((_inseminations.length - pendingCount) / _inseminations.length) *
              100;
    final totalAnimals = _boars.length + _sows.length;
    final completePedigree =
        _boars
            .where(
              (boar) => boar.sireCode.isNotEmpty && boar.damCode.isNotEmpty,
            )
            .length +
        _sows
            .where((sow) => sow.sireCode.isNotEmpty && sow.damCode.isNotEmpty)
            .length;
    final pedigreeCoverage = totalAnimals == 0
        ? 0.0
        : (completePedigree / totalAnimals) * 100;
    final healthPlanned = _healthRecords
        .where((record) => record.nextDate != null)
        .length;
    final healthCoverage = _healthRecords.isEmpty
        ? 0.0
        : (healthPlanned / _healthRecords.length) * 100;

    return [
      _ServiceBenchmark(
        label: 'Taux de fertilité IA',
        currentValue: fertilityRate,
        targetValue: 85,
        unit: '%',
        color: Color(0xFF15803D),
      ),
      _ServiceBenchmark(
        label: 'Couverture diagnostic J28',
        currentValue: diagCoverage,
        targetValue: 95,
        unit: '%',
        color: Color(0xFF0284C7),
      ),
      _ServiceBenchmark(
        label: 'Complétude pedigree',
        currentValue: pedigreeCoverage,
        targetValue: 90,
        unit: '%',
        color: Color(0xFF7C3AED),
      ),
      _ServiceBenchmark(
        label: 'Actes santé planifiés',
        currentValue: healthCoverage,
        targetValue: 80,
        unit: '%',
        color: Color(0xFFEA580C),
      ),
    ];
  }

  List<_BiosecurityItem> _buildBiosecurityItems() {
    final missingLot = _inseminations.any(
      (record) => record.semenLot.trim().isEmpty,
    );
    final dosesInAlert = _stockItems
        .where((item) => item.category.toLowerCase().contains('dose'))
        .any((item) => item.quantity <= item.alertThreshold);
    final hasBoarTreatment = _healthRecords.any(
      (record) =>
          record.animalType.toLowerCase().contains('verrat') &&
          record.eventType.toLowerCase().contains('traitement'),
    );
    final hasVaccinationPlan = _healthRecords.any(
      (record) =>
          record.eventType.toLowerCase().contains('vaccin') &&
          record.nextDate != null,
    );
    final hasBuildingSaturation = _buildings.any(
      (building) => (building.occupied / building.capacity) > 0.9,
    );

    return [
      _BiosecurityItem(
        title: 'Traçabilité des lots de semence',
        detail: missingLot
            ? 'Des IA sans lot semence existent: compléter immédiatement.'
            : 'Tous les enregistrements IA contiennent un lot traçable.',
        ok: !missingLot,
      ),
      _BiosecurityItem(
        title: 'Stock doses semence',
        detail: dosesInAlert
            ? 'Seuil critique atteint: planifier ravitaillement sous 7 jours.'
            : 'Niveau de doses compatible avec le planning IA.',
        ok: !dosesInAlert,
      ),
      _BiosecurityItem(
        title: 'Plan vaccinal et rappels',
        detail: hasVaccinationPlan
            ? 'Rappels vaccinaux planifiés pour les reproducteurs.'
            : 'Aucun rappel vaccinal planifié: risque sanitaire à corriger.',
        ok: hasVaccinationPlan,
      ),
      _BiosecurityItem(
        title: 'Traitement verrats',
        detail: hasBoarTreatment
            ? 'Historique traitement verrats présent (suivi sanitaire actif).'
            : 'Aucun traitement verrat enregistré récemment.',
        ok: hasBoarTreatment,
      ),
      _BiosecurityItem(
        title: 'Occupation bâtiments',
        detail: hasBuildingSaturation
            ? 'Saturation > 90% observée: ajuster densité et flux de lot.'
            : 'Occupation bâtiment sous contrôle.',
        ok: !hasBuildingSaturation,
      ),
    ];
  }

  String _servicePriorityLabel(_ActionPriority priority) {
    switch (priority) {
      case _ActionPriority.high:
        return 'Haute';
      case _ActionPriority.medium:
        return 'Moyenne';
      case _ActionPriority.low:
        return 'Normale';
    }
  }

  String _serviceResponsibleForAction(_BreedingAction action) {
    if (action.icon == LucideIcons.shieldCheck) {
      return _firstUserNameByRole(Roles.vet);
    }
    if (action.icon == LucideIcons.syringe ||
        action.icon == LucideIcons.badgeInfo) {
      return _firstUserNameByRole(Roles.inseminator);
    }
    if (action.icon == LucideIcons.piggyBank) {
      return _firstUserNameByRole(Roles.breeder);
    }
    return _adminUserProfile().name;
  }

  Widget _buildElevageHub() {
    final buildingRows = _buildings
        .map(
          (building) => DataRow(
            cells: [
              DataCell(Text(building.name)),
              DataCell(Text(building.type)),
              DataCell(Text('${building.capacity}')),
              DataCell(Text('${building.occupied}')),
              DataCell(
                Text(
                  '${((building.occupied / building.capacity) * 100).round()}%',
                ),
              ),
            ],
          ),
        )
        .toList();

    final batchRows = _batchRecords
        .map(
          (batch) => DataRow(
            cells: [
              DataCell(Text(batch.name)),
              DataCell(Text(batch.stage)),
              DataCell(Text(_formatDate(batch.startDate))),
              DataCell(Text('${batch.animals}')),
              DataCell(Text('${batch.avgWeight.toStringAsFixed(1)} kg')),
            ],
          ),
        )
        .toList();

    final growthRows = _growthRecords
        .map(
          (growth) => DataRow(
            cells: [
              DataCell(Text(_batchNameForId(growth.batchId))),
              DataCell(Text(_formatDate(growth.date))),
              DataCell(Text('${growth.avgWeight.toStringAsFixed(1)} kg')),
              DataCell(Text('${growth.dailyGain.toStringAsFixed(2)} kg/j')),
            ],
          ),
        )
        .toList();

    final inventoryRows = [
      DataRow(
        cells: [
          const DataCell(Text('Verrats')),
          DataCell(Text('${_boars.length}')),
          DataCell(Text(_topBreedFromBoars())),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Truies')),
          DataCell(Text('${_sows.length}')),
          DataCell(Text(_topBreedFromSows())),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(
            Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          DataCell(
            Text(
              '${_boars.length + _sows.length}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const DataCell(Text('-')),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Gestion d\'Élevage Porcin',
          subtitle:
              'Porcherie / bâtiment, cycle de production, bandes et performance de croissance',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Porcherie / Bâtiment')),
              Chip(label: Text('Cycle de production')),
              Chip(label: Text('Gestion des bandes')),
              Chip(label: Text('Suivi de croissance')),
              Chip(label: Text('Inventaire des animaux')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Porcherie / Bâtiment',
          subtitle: 'Capacité et occupation par bâtiment',
          emptyMessage: 'Aucun bâtiment renseigné.',
          columns: const [
            DataColumn(label: Text('BÂTIMENT')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('CAPACITÉ')),
            DataColumn(label: Text('OCCUPÉS')),
            DataColumn(label: Text('TAUX OCCUPATION')),
          ],
          rows: buildingRows,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Cycle de production',
          subtitle: 'Référentiel standard reproduction et croissance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. Détection des chaleurs et planning d\'insémination'),
              Text('2. Gestation avec contrôle technique J28'),
              Text('3. Mise bas et conduite maternité'),
              Text('4. Sevrage et transfert post-sevrage'),
              Text('5. Croissance / finition jusqu\'à vente'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion des bandes',
          subtitle: 'Suivi des lots de production',
          emptyMessage: 'Aucune bande disponible.',
          columns: const [
            DataColumn(label: Text('BANDE')),
            DataColumn(label: Text('STADE')),
            DataColumn(label: Text('DÉBUT')),
            DataColumn(label: Text('ANIMAUX')),
            DataColumn(label: Text('POIDS MOYEN')),
          ],
          rows: batchRows,
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Suivi de croissance',
          subtitle: 'Poids moyen et gain moyen quotidien',
          emptyMessage: 'Aucune mesure de croissance.',
          columns: const [
            DataColumn(label: Text('BANDE')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('POIDS MOYEN')),
            DataColumn(label: Text('GMQ')),
          ],
          rows: growthRows,
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Inventaire des animaux',
          subtitle: 'Effectif actuel par catégorie',
          emptyMessage: 'Aucun animal inventorié.',
          columns: const [
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('EFFECTIF')),
            DataColumn(label: Text('RACE DOMINANTE')),
          ],
          rows: inventoryRows,
        ),
      ],
    );
  }

  Widget _buildCommercialHub() {
    final filteredSales = _filteredSalesRecords();
    final filteredSupplies = _filteredSupplyRecords();
    final totalRevenue = filteredSales.fold<double>(
      0,
      (sum, sale) => sum + sale.amount,
    );
    final totalExpense = filteredSupplies.fold<double>(
      0,
      (sum, supply) => sum + supply.amount,
    );

    final salesByType = <String, double>{
      'Vente de porcs (charcutiers)': 0,
      'Vente de porcelets': 0,
      'Autre vente': 0,
    };
    for (final sale in filteredSales) {
      salesByType[sale.type] = (salesByType[sale.type] ?? 0) + sale.amount;
    }

    final salesRows = filteredSales
        .map(
          (sale) => DataRow(
            cells: [
              DataCell(Text(_formatDate(sale.date))),
              DataCell(Text(sale.type)),
              DataCell(Text(_clientNameForId(sale.clientId))),
              DataCell(Text('${sale.quantity}')),
              DataCell(Text(_formatAmount(sale.amount))),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer vente',
                  onPressed: () => _deleteSaleRecord(sale.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    final stockRows = _stockItems
        .map(
          (item) => DataRow(
            cells: [
              DataCell(Text(item.name)),
              DataCell(Text(item.category)),
              DataCell(
                Text('${item.quantity.toStringAsFixed(0)} ${item.unit}'),
              ),
              DataCell(
                Text('${item.alertThreshold.toStringAsFixed(0)} ${item.unit}'),
              ),
              DataCell(
                Text(
                  item.quantity <= item.alertThreshold ? 'Alerte' : 'OK',
                  style: TextStyle(
                    color: item.quantity <= item.alertThreshold
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    final supplyRows = filteredSupplies
        .map(
          (supply) => DataRow(
            cells: [
              DataCell(Text(_formatDate(supply.date))),
              DataCell(Text(supply.category)),
              DataCell(Text(_supplierNameForId(supply.supplierId))),
              DataCell(Text(_formatAmount(supply.amount))),
              DataCell(Text(supply.notes.isEmpty ? '-' : supply.notes)),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer ravitaillement',
                  onPressed: () => _deleteSupplyRecord(supply.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Gestion Commerciale et Stock',
          subtitle:
              'Gestion des ventes, stock aliments/doses, ravitaillements et pilotage financier',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalesFilterControl(),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 860;
                  final cards = [
                    _buildMiniIndicator(
                      label: 'Total revenu',
                      value: _formatAmount(totalRevenue),
                      color: const Color(0xFF15803D),
                    ),
                    _buildMiniIndicator(
                      label: 'Total dépense',
                      value: _formatAmount(totalExpense),
                      color: const Color(0xFFB91C1C),
                    ),
                    _buildMiniIndicator(
                      label: 'Marge brute',
                      value: _formatAmount(totalRevenue - totalExpense),
                      color: const Color(0xFF2563EB),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[1]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 10),
                      cards[1],
                      const SizedBox(height: 10),
                      cards[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildAmountChip(
                    'Vente de porcs (charcutiers)',
                    salesByType['Vente de porcs (charcutiers)'] ?? 0,
                  ),
                  _buildAmountChip(
                    'Vente de porcelets',
                    salesByType['Vente de porcelets'] ?? 0,
                  ),
                  _buildAmountChip(
                    'Autre vente',
                    salesByType['Autre vente'] ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion des ventes',
          subtitle: 'Vente de porcs (charcutiers), porcelets et autres ventes',
          emptyMessage: 'Aucune vente enregistrée sur la période.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddSaleDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter vente'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('CLIENT')),
            DataColumn(label: Text('QUANTITÉ')),
            DataColumn(label: Text('MONTANT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: salesRows,
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion de stock (Aliments / Doses)',
          subtitle: 'Disponibilité des intrants critiques',
          emptyMessage: 'Aucun stock renseigné.',
          columns: const [
            DataColumn(label: Text('ARTICLE')),
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('STOCK ACTUEL')),
            DataColumn(label: Text('SEUIL')),
            DataColumn(label: Text('STATUT')),
          ],
          rows: stockRows,
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Ravitaillements',
          subtitle: 'Achats et approvisionnements de la période filtrée',
          emptyMessage: 'Aucun ravitaillement sur la période.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddSupplyDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter ravitaillement'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('FOURNISSEUR')),
            DataColumn(label: Text('MONTANT')),
            DataColumn(label: Text('NOTE')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: supplyRows,
        ),
      ],
    );
  }

  Widget _buildSoftwareFeatures() {
    final validUntil = _currentDate().add(const Duration(days: 365));

    return _buildSectionCard(
      title: 'Caractéristiques du Logiciel',
      subtitle: 'Principes de conception et durée de validité',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.checkCircle, color: Color(0xFF15803D)),
            title: Text('Intuitive'),
            subtitle: Text('Navigation claire par module métier.'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.checkCircle, color: Color(0xFF15803D)),
            title: Text('Complète'),
            subtitle: Text(
              'Administration, élevage, reproduction, commercial et stock.',
            ),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.checkCircle, color: Color(0xFF15803D)),
            title: Text('Simple'),
            subtitle: Text('Saisie rapide et tableaux de suivi décisionnel.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month, color: Color(0xFF2563EB)),
            title: const Text('Durée de validité'),
            subtitle: Text(
              'Licence annuelle valide jusqu\'au ${_formatDate(validUntil)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final today = _currentDate();
    final successCount = _inseminations
        .where((record) => _isSuccessfulStatus(record.status))
        .length;
    final failedCount = _inseminations
        .where((record) => _isFailedStatus(record.status))
        .length;
    final pendingCount = math.max(
      0,
      _inseminations.length - successCount - failedCount,
    );
    final decidedCount = successCount + failedCount;
    final successRate = decidedCount == 0
        ? 0
        : ((successCount / decidedCount) * 100).round();
    final overdueDiagnosisCount = _inseminations.where((record) {
      if (_isSuccessfulStatus(record.status) ||
          _isFailedStatus(record.status)) {
        return false;
      }
      final diagnosisDate = _expectedPregnancyCheckDate(record);
      return today.isAfter(diagnosisDate.add(const Duration(days: 7)));
    }).length;
    final farrowingSoonCount = _inseminations.where((record) {
      if (!_isSuccessfulStatus(record.status)) {
        return false;
      }
      final farrowingDate = _expectedFarrowingDate(record);
      final daysToFarrowing = farrowingDate.difference(today).inDays;
      return daysToFarrowing >= 0 && daysToFarrowing <= 14;
    }).length;
    final actionPlan = _computeBreedingActions();
    final expertTips = _buildExpertRecommendations(
      successRate: successRate,
      overdueDiagnosisCount: overdueDiagnosisCount,
      farrowingSoonCount: farrowingSoonCount,
      pendingCount: pendingCount,
    );

    final nextHealthActions = _healthRecords.where((record) {
      if (record.nextDate == null) {
        return false;
      }
      final limit = today.add(const Duration(days: 14));
      return !record.nextDate!.isBefore(today) &&
          !record.nextDate!.isAfter(limit);
    }).toList()..sort((a, b) => a.nextDate!.compareTo(b.nextDate!));

    final recentIa = List<InseminationRecord>.from(_inseminations)
      ..sort((a, b) => b.dose1Date.compareTo(a.dose1Date));
    final breederAnimalStats = _computeBreederAnimalStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 1550
                ? 7
                : width > 1250
                ? 4
                : width > 900
                ? 3
                : width > 560
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _buildStatCard(
                  title: 'Verrats actifs',
                  value: '${_boars.length}',
                  icon: LucideIcons.badgeInfo,
                  color: const Color(0xFF0284C7),
                ),
                _buildStatCard(
                  title: 'Truies suivies',
                  value: '${_sows.length}',
                  icon: LucideIcons.piggyBank,
                  color: const Color(0xFF7C3AED),
                ),
                _buildStatCard(
                  title: 'IA enregistrées',
                  value: '${_inseminations.length}',
                  icon: LucideIcons.syringe,
                  color: const Color(0xFFEA580C),
                ),
                _buildStatCard(
                  title: 'Taux réussite IA',
                  value: '$successRate%',
                  icon: LucideIcons.trendingUp,
                  color: const Color(0xFF16A34A),
                ),
                _buildStatCard(
                  title: 'Actes santé',
                  value: '${_healthRecords.length}',
                  icon: LucideIcons.shieldCheck,
                  color: const Color(0xFF0F766E),
                ),
                _buildStatCard(
                  title: 'Diag en retard',
                  value: '$overdueDiagnosisCount',
                  icon: LucideIcons.badgeInfo,
                  color: const Color(0xFFB91C1C),
                ),
                _buildStatCard(
                  title: 'Mise-bas <= 14j',
                  value: '$farrowingSoonCount',
                  icon: LucideIcons.piggyBank,
                  color: const Color(0xFF2563EB),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _buildInseminationOutcomeCharts(
          successCount: successCount,
          failedCount: failedCount,
          pendingCount: pendingCount,
          successRate: successRate,
        ),
        const SizedBox(height: 16),
        _buildBreedingActionPlanCard(actionPlan),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 980) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRecentInseminationCard(
                      recentIa.take(5).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUpcomingHealthCard(
                      nextHealthActions.take(5).toList(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildRecentInseminationCard(recentIa.take(5).toList()),
                const SizedBox(height: 16),
                _buildUpcomingHealthCard(nextHealthActions.take(5).toList()),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _buildPedigreeCoverageCard(),
        const SizedBox(height: 16),
        _buildBreederAnimalSection(breederAnimalStats),
        const SizedBox(height: 16),
        _buildExpertRecommendationsCard(expertTips),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInseminationOutcomeCharts({
    required int successCount,
    required int failedCount,
    required int pendingCount,
    required int successRate,
  }) {
    final total = successCount + failedCount + pendingCount;
    final failedOrPendingCount = failedCount + pendingCount;

    return _buildSectionCard(
      title: 'Diagrammes IA réussie / pas réussie',
      subtitle: 'Répartition des issues d\'insémination',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 860;
          final donut = _buildOutcomeDonutChart(
            successCount: successCount,
            failedCount: failedCount,
            pendingCount: pendingCount,
            total: total,
          );

          final detail = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOutcomeBar(
                label: 'Réussie',
                value: successCount,
                total: total,
                color: const Color(0xFF15803D),
              ),
              _buildOutcomeBar(
                label: 'Pas réussie',
                value: failedCount,
                total: total,
                color: const Color(0xFFB91C1C),
              ),
              _buildOutcomeBar(
                label: 'En attente',
                value: pendingCount,
                total: total,
                color: const Color(0xFFB45309),
              ),
              const SizedBox(height: 10),
              Text(
                'Taux de réussite (dossiers clôturés): $successRate% '
                '($successCount réussies / ${successCount + failedCount})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total pas réussie + en attente: $failedOrPendingCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                donut,
                const SizedBox(width: 24),
                Expanded(child: detail),
              ],
            );
          }

          return Column(children: [donut, const SizedBox(height: 16), detail]);
        },
      ),
    );
  }

  Widget _buildOutcomeDonutChart({
    required int successCount,
    required int failedCount,
    required int pendingCount,
    required int total,
  }) {
    return SizedBox(
      width: 190,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(190),
              painter: _OutcomeDonutPainter(
                total: total.toDouble(),
                segments: [
                  _OutcomeSegment(
                    value: successCount.toDouble(),
                    color: const Color(0xFF15803D),
                  ),
                  _OutcomeSegment(
                    value: failedCount.toDouble(),
                    color: const Color(0xFFB91C1C),
                  ),
                  _OutcomeSegment(
                    value: pendingCount.toDouble(),
                    color: const Color(0xFFB45309),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  'IA totales',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeBar({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final ratio = total == 0 ? 0.0 : value / total;
    final percent = (ratio * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                '$value ($percent%)',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              backgroundColor: color.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingActionPlanCard(List<_BreedingAction> actions) {
    return _buildSectionCard(
      title: 'Plan d\'action reproduction (30 jours)',
      subtitle:
          'Échéances techniques: chaleur J21, diagnostic J28, mise-bas J114',
      child: actions.isEmpty
          ? _buildEmptyState(
              'Aucune action prioritaire sur les 30 prochains jours.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final action = actions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: action.color.withValues(alpha: 0.12),
                    child: Icon(action.icon, color: action.color),
                  ),
                  title: Text(
                    action.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${action.detail} • ${_formatDate(action.dueDate)} (${_relativeDayLabel(action.dueDate)})',
                  ),
                  trailing: _buildPriorityBadge(action.priority),
                );
              },
            ),
    );
  }

  Widget _buildPriorityBadge(_ActionPriority priority) {
    late final Color color;
    late final String label;
    switch (priority) {
      case _ActionPriority.high:
        color = const Color(0xFFB91C1C);
        label = 'Haute';
        break;
      case _ActionPriority.medium:
        color = const Color(0xFFB45309);
        label = 'Moyenne';
        break;
      case _ActionPriority.low:
        color = const Color(0xFF15803D);
        label = 'Normale';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildExpertRecommendationsCard(List<String> recommendations) {
    return _buildSectionCard(
      title: 'Recommandations Expert Élevage',
      subtitle:
          'Ajustements conseillés pour améliorer la performance reproduction',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        LucideIcons.badgeInfo,
                        size: 16,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecentInseminationCard(List<InseminationRecord> records) {
    return _buildSectionCard(
      title: 'Inséminations récentes',
      subtitle: 'Suivi dose, verrat utilisé et statut',
      child: records.isEmpty
          ? _buildEmptyState('Aucune insémination enregistrée.')
          : Column(
              children: records.map((record) {
                final boar = _findBoar(record.boarCode);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(LucideIcons.syringe, color: Color(0xFF0284C7)),
                  ),
                  title: Text(
                    '${record.sowCode} x ${record.boarCode}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${_formatDate(record.dose1Date)} • ${boar?.breed ?? 'Race inconnue'}',
                  ),
                  trailing: Text(
                    record.status,
                    style: TextStyle(
                      color: _isSuccessfulStatus(record.status)
                          ? const Color(0xFF15803D)
                          : _isFailedStatus(record.status)
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildUpcomingHealthCard(List<HealthRecord> records) {
    return _buildSectionCard(
      title: 'Vaccins / traitements à venir',
      subtitle: 'Échéances des 14 prochains jours',
      child: records.isEmpty
          ? _buildEmptyState('Aucune échéance santé dans les 14 jours.')
          : Column(
              children: records.map((record) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: record.eventType == 'Vaccin'
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFFEDD5),
                    child: Icon(
                      record.eventType == 'Vaccin'
                          ? LucideIcons.shieldCheck
                          : LucideIcons.pill,
                      color: record.eventType == 'Vaccin'
                          ? const Color(0xFF15803D)
                          : const Color(0xFFEA580C),
                    ),
                  ),
                  title: Text(
                    '${record.animalType} ${record.animalCode} - ${record.product}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Prochaine date: ${_formatDate(record.nextDate!)}',
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPedigreeCoverageCard() {
    final totalAnimals = _boars.length + _sows.length;
    final animalsWithSire =
        _boars.where((boar) => boar.sireCode.isNotEmpty).length +
        _sows.where((sow) => sow.sireCode.isNotEmpty).length;
    final animalsWithDam =
        _boars.where((boar) => boar.damCode.isNotEmpty).length +
        _sows.where((sow) => sow.damCode.isNotEmpty).length;

    final sireRate = totalAnimals == 0
        ? 0
        : ((animalsWithSire / totalAnimals) * 100).round();
    final damRate = totalAnimals == 0
        ? 0
        : ((animalsWithDam / totalAnimals) * 100).round();

    return _buildSectionCard(
      title: 'Qualité des données pedigree',
      subtitle: 'Complétude des informations de filiation',
      child: Row(
        children: [
          Expanded(
            child: _buildMiniIndicator(
              label: 'Père renseigné',
              value: '$sireRate%',
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniIndicator(
              label: 'Mère renseignée',
              value: '$damRate%',
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniIndicator(
              label: 'Animaux suivis',
              value: '$totalAnimals',
              color: const Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreederAnimalSection(List<_BreederAnimalStat> breederStats) {
    final rows = breederStats
        .map(
          (stat) => DataRow(
            cells: [
              DataCell(Text(stat.breederName)),
              DataCell(Text('${stat.boarCount}')),
              DataCell(Text('${stat.sowCount}')),
              DataCell(
                Text(
                  '${stat.totalAnimals}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        )
        .toList();

    return _buildDataTableSection(
      title: 'Section Éleveurs',
      subtitle: 'Nom des éleveurs et nombre d\'animaux suivis',
      emptyMessage: 'Aucun éleveur ou animal enregistré.',
      columns: const [
        DataColumn(label: Text('ÉLEVEUR')),
        DataColumn(label: Text('VERRATS')),
        DataColumn(label: Text('TRUIES')),
        DataColumn(label: Text('TOTAL ANIMAUX')),
      ],
      rows: rows,
    );
  }

  List<_BreederAnimalStat> _computeBreederAnimalStats() {
    final boarCountByBreeder = <String, int>{};
    final sowCountByBreeder = <String, int>{};

    for (final boar in _boars) {
      final breederId = boar.breederId.trim();
      boarCountByBreeder[breederId] = (boarCountByBreeder[breederId] ?? 0) + 1;
    }

    for (final sow in _sows) {
      final breederId = sow.breederId.trim();
      sowCountByBreeder[breederId] = (sowCountByBreeder[breederId] ?? 0) + 1;
    }

    final breederIds = <String>{
      ..._breeders.map((breeder) => breeder.id),
      ...boarCountByBreeder.keys,
      ...sowCountByBreeder.keys,
    };

    final stats = breederIds
        .map(
          (breederId) => _BreederAnimalStat(
            breederId: breederId,
            breederName: _breederNameForId(breederId),
            boarCount: boarCountByBreeder[breederId] ?? 0,
            sowCount: sowCountByBreeder[breederId] ?? 0,
          ),
        )
        .toList();

    stats.sort((a, b) {
      final byTotal = b.totalAnimals.compareTo(a.totalAnimals);
      if (byTotal != 0) {
        return byTotal;
      }
      return a.breederName.compareTo(b.breederName);
    });

    return stats;
  }

  Widget _buildMiniIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInseminationManagement() {
    final rows = _inseminations.map((record) {
      final boar = _findBoar(record.boarCode);
      final expectedHeatReturn = _expectedHeatReturnDate(record);
      final expectedDiagnosis = _expectedPregnancyCheckDate(record);
      final expectedFarrowing = _expectedFarrowingDate(record);
      final nextAction = _nextInseminationActionInfo(record);

      return DataRow(
        cells: [
          DataCell(Text(_formatDate(record.dose1Date))),
          DataCell(Text(_formatDate(expectedHeatReturn))),
          DataCell(Text(_formatDate(expectedDiagnosis))),
          DataCell(Text(record.sowCode)),
          DataCell(Text(record.boarCode)),
          DataCell(Text(boar?.breed ?? '-')),
          DataCell(Text(record.semenLot)),
          DataCell(Text(record.inseminator)),
          DataCell(Text(record.status)),
          DataCell(
            Text(
              nextAction.label,
              style: TextStyle(
                color: nextAction.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DataCell(Text(_formatDate(expectedFarrowing))),
          DataCell(
            IconButton(
              tooltip: 'Supprimer IA',
              onPressed: () => _deleteInsemination(record.id),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGestationCalendarSection(),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion des inséminations',
          subtitle:
              'Planning d\'insémination, détection des chaleurs, date de saillie / '
              'insémination, suivi de gestation, mise bas et sevrage',
          emptyMessage: 'Aucune IA enregistrée.',
          columns: const [
            DataColumn(label: Text('DATE IA1')),
            DataColumn(label: Text('RETOUR J21')),
            DataColumn(label: Text('DIAG J28')),
            DataColumn(label: Text('TRUIE')),
            DataColumn(label: Text('VERRAT')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('LOT SEMENCE')),
            DataColumn(label: Text('INSÉMINATEUR')),
            DataColumn(label: Text('STATUT')),
            DataColumn(label: Text('PROCHAINE ACTION')),
            DataColumn(label: Text('MISE-BAS PRÉVUE')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: rows,
        ),
      ],
    );
  }

  Widget _buildGestationCalendarSection() {
    final monthStart = DateTime(
      _gestationCalendarMonth.year,
      _gestationCalendarMonth.month,
      1,
    );
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leadingEmptyCells = monthStart.weekday - 1;
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final eventsByDay = _buildGestationCalendarEvents();
    final selectedDate = _selectedGestationDate == null
        ? _currentDate()
        : _normalizeDate(_selectedGestationDate!);
    final selectedEvents =
        eventsByDay[_normalizeDate(selectedDate)] ??
        const <_GestationCalendarEvent>[];
    const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return _buildSectionCard(
      title: 'Calendrier de gestation porcine',
      subtitle:
          'Vue mensuelle des échéances IA, retour chaleur J21, diagnostic J28, mise-bas J114',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mois précédent',
                onPressed: () => _changeGestationCalendarMonth(-1),
                icon: const Icon(LucideIcons.chevronLeft),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(monthStart),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Mois suivant',
                onPressed: () => _changeGestationCalendarMonth(1),
                icon: const Icon(LucideIcons.chevronRight),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  final today = _currentDate();
                  setState(() {
                    _gestationCalendarMonth = DateTime(
                      today.year,
                      today.month,
                      1,
                    );
                    _selectedGestationDate = today;
                  });
                  _persistState();
                },
                child: const Text('Aujourd\'hui'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGestationLegendChip(
                label: 'IA',
                color: const Color(0xFF0F766E),
              ),
              _buildGestationLegendChip(
                label: 'Retour J21',
                color: const Color(0xFFB45309),
              ),
              _buildGestationLegendChip(
                label: 'Diag J28',
                color: const Color(0xFF0284C7),
              ),
              _buildGestationLegendChip(
                label: 'Mise-bas J114',
                color: const Color(0xFF16A34A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: weekDays
                .map(
                  (dayName) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        dayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingEmptyCells + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }

              final dayDate = DateTime(
                monthStart.year,
                monthStart.month,
                dayNumber,
              );
              final normalizedDay = _normalizeDate(dayDate);
              final dayEvents =
                  eventsByDay[normalizedDay] ??
                  const <_GestationCalendarEvent>[];
              final isSelected = _isSameDate(normalizedDay, selectedDate);
              final isToday = _isSameDate(normalizedDay, _currentDate());

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() => _selectedGestationDate = normalizedDay);
                  _persistState();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isToday
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (dayEvents.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${dayEvents.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      if (dayEvents.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: dayEvents
                              .take(4)
                              .map((event) => _buildDayMarker(event.color))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildSelectedGestationDayCard(selectedDate, selectedEvents),
        ],
      ),
    );
  }

  Widget _buildSelectedGestationDayCard(
    DateTime selectedDate,
    List<_GestationCalendarEvent> events,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions du ${_formatDate(selectedDate)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            const Text(
              'Aucune action planifiée sur cette date.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(event.icon, size: 16, color: event.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.label,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      event.type,
                      style: TextStyle(
                        color: event.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGestationLegendChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDayMarker(color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMarker(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildBoarManagement() {
    final rows = _boars
        .map(
          (boar) => DataRow(
            cells: [
              DataCell(_buildBoarPhoto(boar, size: 44)),
              DataCell(Text(boar.code)),
              DataCell(Text(boar.name)),
              DataCell(Text(boar.breed)),
              DataCell(Text(_formatDate(boar.birthDate))),
              DataCell(Text(boar.origin)),
              DataCell(Text(boar.sireCode.isEmpty ? '-' : boar.sireCode)),
              DataCell(Text(boar.damCode.isEmpty ? '-' : boar.damCode)),
              DataCell(Text(boar.semenType)),
              DataCell(
                Text(
                  _isPreferredBoar(boar.code) ? 'Oui' : '-',
                  style: TextStyle(
                    color: _isPreferredBoar(boar.code)
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer verrat',
                  onPressed: () => _deleteBoar(boar.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Catalogue visuel des géniteurs',
          subtitle:
              'Les éleveurs peuvent comparer les verrats et sélectionner le géniteur préféré',
          child: _boars.isEmpty
              ? _buildEmptyState('Aucun verrat disponible pour sélection.')
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width > 1180
                        ? 4
                        : width > 820
                        ? 3
                        : width > 560
                        ? 2
                        : 1;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: width > 560 ? 1.35 : 1.18,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: _boars
                          .map((boar) => _buildBoarCatalogCard(boar))
                          .toList(),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion des verrats',
          subtitle:
              'Référentiel mâles reproducteurs, photo et disponibilité de semence',
          emptyMessage: 'Aucun verrat enregistré.',
          columns: const [
            DataColumn(label: Text('PHOTO')),
            DataColumn(label: Text('CODE')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('NAISSANCE')),
            DataColumn(label: Text('ORIGINE')),
            DataColumn(label: Text('PÈRE')),
            DataColumn(label: Text('MÈRE')),
            DataColumn(label: Text('TYPE SEMENCE')),
            DataColumn(label: Text('GÉNITEUR PRÉFÉRÉ')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: rows,
        ),
      ],
    );
  }

  Widget _buildBoarCatalogCard(Boar boar) {
    final selected = _isPreferredBoar(boar.code);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBoarPhoto(boar, size: 62),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boar.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${boar.code} • ${boar.breed}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Origine: ${boar.origin}',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Text(
            'Type semence: ${boar.semenType}',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: selected
                ? FilledButton.icon(
                    onPressed: () => _setPreferredBoar(boar.code),
                    icon: const Icon(LucideIcons.checkCircle2, size: 16),
                    label: const Text('Géniteur sélectionné'),
                  )
                : OutlinedButton.icon(
                    onPressed: () => _setPreferredBoar(boar.code),
                    icon: const Icon(LucideIcons.badgeInfo, size: 16),
                    label: const Text('Choisir ce géniteur'),
                  ),
          ),
        ],
      ),
    );
  }

  bool _isPreferredBoar(String boarCode) {
    return _preferredBoarCode != null &&
        _preferredBoarCode!.toLowerCase() == boarCode.toLowerCase();
  }

  void _setPreferredBoar(String boarCode) {
    setState(() => _preferredBoarCode = boarCode);
    _persistState();
    _showInfo('Géniteur préféré défini: $boarCode');
  }

  Future<String?> _pickImageAsBase64() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final bytes = result.files.single.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showError('Image invalide. Choisissez un autre fichier.');
        return null;
      }
      const maxImageBytes = 350 * 1024;
      if (bytes.length > maxImageBytes) {
        _showError(
          'Image trop lourde (> 350 KB). Réduisez la taille pour garantir la sauvegarde locale.',
        );
        return null;
      }
      return base64Encode(bytes);
    } catch (_) {
      _showError('Impossible de charger l\'image.');
      return null;
    }
  }

  Widget _buildBoarPhoto(Boar boar, {double size = 52}) {
    if (boar.imageBase64.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          LucideIcons.image,
          color: Color(0xFF64748B),
          size: 18,
        ),
      );
    }

    try {
      final bytes = base64Decode(boar.imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          LucideIcons.alertTriangle,
          color: Color(0xFFB91C1C),
          size: 18,
        ),
      );
    }
  }

  Widget _buildImagePreviewBox(String imageBase64, {double size = 92}) {
    if (imageBase64.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.image, color: Color(0xFF64748B)),
      );
    }
    try {
      final bytes = base64Decode(imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFB91C1C)),
      );
    }
  }

  Widget _buildSowManagement() {
    final rows = _sows
        .map(
          (sow) => DataRow(
            cells: [
              DataCell(Text(sow.code)),
              DataCell(Text(sow.name)),
              DataCell(Text(sow.breed)),
              DataCell(Text(_formatDate(sow.birthDate))),
              DataCell(Text('${sow.parity}')),
              DataCell(Text(sow.sireCode.isEmpty ? '-' : sow.sireCode)),
              DataCell(Text(sow.damCode.isEmpty ? '-' : sow.damCode)),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer truie',
                  onPressed: () => _deleteSow(sow.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    return _buildDataTableSection(
      title: 'Gestion des truies',
      subtitle: 'Suivi reproductrices, parité et informations de lignée',
      emptyMessage: 'Aucune truie enregistrée.',
      columns: const [
        DataColumn(label: Text('CODE')),
        DataColumn(label: Text('NOM')),
        DataColumn(label: Text('RACE')),
        DataColumn(label: Text('NAISSANCE')),
        DataColumn(label: Text('PARITÉ')),
        DataColumn(label: Text('PÈRE')),
        DataColumn(label: Text('MÈRE')),
        DataColumn(label: Text('ACTIONS')),
      ],
      rows: rows,
    );
  }

  Widget _buildPedigreeManagement() {
    final rows = <DataRow>[
      ..._boars.map(
        (boar) => DataRow(
          cells: [
            const DataCell(Text('Verrat')),
            DataCell(Text(boar.code)),
            DataCell(Text(boar.name)),
            DataCell(Text(boar.breed)),
            DataCell(Text(boar.sireCode.isEmpty ? '-' : boar.sireCode)),
            DataCell(Text(boar.damCode.isEmpty ? '-' : boar.damCode)),
            DataCell(Text(boar.origin)),
          ],
        ),
      ),
      ..._sows.map(
        (sow) => DataRow(
          cells: [
            const DataCell(Text('Truie')),
            DataCell(Text(sow.code)),
            DataCell(Text(sow.name)),
            DataCell(Text(sow.breed)),
            DataCell(Text(sow.sireCode.isEmpty ? '-' : sow.sireCode)),
            DataCell(Text(sow.damCode.isEmpty ? '-' : sow.damCode)),
            DataCell(const Text('-')),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        _buildSectionCard(
          title: 'Gestion pedigree',
          subtitle:
              'Arbre généalogique simplifié (père/mère) pour chaque animal',
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  'Conseil: renseignez systématiquement le code père/mère lors de '
                  'la création de verrats et truies pour une traçabilité génétique complète.',
                  style: TextStyle(color: Color(0xFF334155), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Registre de filiation',
          subtitle: 'Consolidé verrats et truies',
          emptyMessage: 'Aucune donnée pedigree disponible.',
          columns: const [
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('CODE')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('PÈRE')),
            DataColumn(label: Text('MÈRE')),
            DataColumn(label: Text('ORIGINE')),
          ],
          rows: rows,
        ),
      ],
    );
  }

  Widget _buildHealthManagement() {
    final rows = _healthRecords
        .map(
          (record) => DataRow(
            cells: [
              DataCell(Text(_formatDate(record.eventDate))),
              DataCell(Text(record.eventType)),
              DataCell(Text('${record.animalType} ${record.animalCode}')),
              DataCell(Text(record.product)),
              DataCell(Text(record.dose)),
              DataCell(Text(record.reason)),
              DataCell(
                Text(
                  record.nextDate == null ? '-' : _formatDate(record.nextDate!),
                ),
              ),
              DataCell(Text(record.responsible)),
              DataCell(
                IconButton(
                  tooltip: 'Supprimer acte',
                  onPressed: () => _deleteHealthRecord(record.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();

    return _buildDataTableSection(
      title: 'Vaccins et traitements',
      subtitle: 'Historique sanitaire reproducteurs et truies',
      emptyMessage: 'Aucun acte santé enregistré.',
      columns: const [
        DataColumn(label: Text('DATE')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('ANIMAL')),
        DataColumn(label: Text('PRODUIT')),
        DataColumn(label: Text('DOSE')),
        DataColumn(label: Text('MOTIF')),
        DataColumn(label: Text('PROCHAINE DATE')),
        DataColumn(label: Text('RESPONSABLE')),
        DataColumn(label: Text('ACTIONS')),
      ],
      rows: rows,
    );
  }

  Widget _buildUsersManagement() {
    final adminCount = _users.where((user) => user.role == Roles.admin).length;
    final rows = _users
        .map(
          (user) => DataRow(
            cells: [
              DataCell(Text(user.code)),
              DataCell(Text(user.name)),
              DataCell(Text(user.role)),
              DataCell(Text(user.login)),
              const DataCell(Text('********')),
              DataCell(
                Text(
                  user.id == _currentUser.id ? 'Session active' : '-',
                  style: TextStyle(
                    color: user.id == _currentUser.id
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier utilisateur',
                      onPressed: () => _showEditUserDialog(user),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Changer mot de passe',
                      onPressed: () => _showChangeUserPasswordDialog(user),
                      icon: const Icon(
                        Icons.key_outlined,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer utilisateur',
                      onPressed: () => _deleteUser(user.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Administration des accès',
          subtitle:
              'Gestion des comptes, des rôles et des mots de passe de connexion',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              final indicators = [
                _buildMiniIndicator(
                  label: 'Utilisateurs',
                  value: '${_users.length}',
                  color: const Color(0xFF0284C7),
                ),
                _buildMiniIndicator(
                  label: 'Administrateurs',
                  value: '$adminCount',
                  color: const Color(0xFF7C3AED),
                ),
                _buildMiniIndicator(
                  label: 'Connecté',
                  value: _currentUser.login,
                  color: const Color(0xFF15803D),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: indicators[0]),
                    const SizedBox(width: 12),
                    Expanded(child: indicators[1]),
                    const SizedBox(width: 12),
                    Expanded(child: indicators[2]),
                  ],
                );
              }

              return Column(
                children: [
                  indicators[0],
                  const SizedBox(height: 10),
                  indicators[1],
                  const SizedBox(height: 10),
                  indicators[2],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTableSection(
          title: 'Gestion des utilisateurs',
          subtitle: 'Créer, modifier, sécuriser les comptes et gérer les rôles',
          emptyMessage: 'Aucun utilisateur enregistré.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter utilisateur'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('CODE')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('RÔLE')),
            DataColumn(label: Text('LOGIN')),
            DataColumn(label: Text('MOT DE PASSE')),
            DataColumn(label: Text('SESSION')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: rows,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDataTableSection({
    required String title,
    required String subtitle,
    required String emptyMessage,
    required List<DataColumn> columns,
    required List<DataRow> rows,
    List<Widget> actions = const [],
  }) {
    return _buildSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actions.isNotEmpty) ...[
            Wrap(spacing: 8, runSpacing: 8, children: actions),
            const SizedBox(height: 12),
          ],
          rows.isEmpty
              ? _buildEmptyState(emptyMessage)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                    dataTextStyle: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                    columns: columns,
                    rows: rows,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<String> _allowedTabsForRole(String role) {
    switch (role) {
      case Roles.admin:
      case Roles.inseminator:
        return const [
          AppTabs.dashboard,
          AppTabs.administration,
          AppTabs.services,
          AppTabs.elevage,
          AppTabs.inseminations,
          AppTabs.boars,
          AppTabs.sows,
          AppTabs.pedigree,
          AppTabs.health,
          AppTabs.commercial,
          AppTabs.logiciel,
          AppTabs.users,
        ];
      case Roles.breeder:
        return const [
          AppTabs.dashboard,
          AppTabs.elevage,
          AppTabs.boars,
          AppTabs.sows,
          AppTabs.pedigree,
        ];
      case Roles.vet:
        return const [AppTabs.dashboard, AppTabs.health];
      default:
        return const [AppTabs.dashboard];
    }
  }

  bool _canAccessTab(String tabId) {
    return _allowedTabsForRole(_currentUser.role).contains(tabId);
  }

  String _defaultTabForCurrentUser() {
    final allowed = _allowedTabsForRole(_currentUser.role);
    if (allowed.contains(AppTabs.dashboard)) {
      return AppTabs.dashboard;
    }
    if (allowed.isNotEmpty) {
      return allowed.first;
    }
    return AppTabs.dashboard;
  }

  void _ensureActiveTabAccess() {
    if (_canAccessTab(_activeTab)) {
      return;
    }
    _activeTab = _defaultTabForCurrentUser();
    _persistState();
  }

  String _titleForTab(String tabId) {
    switch (tabId) {
      case AppTabs.dashboard:
        return 'TABLEAU DE BORD REPRODUCTION PORCINE';
      case AppTabs.administration:
        return 'INTERFACE ET ADMINISTRATION';
      case AppTabs.services:
        return 'PACK SERVICES & ACCOMPAGNEMENT';
      case AppTabs.elevage:
        return 'GESTION D\'ÉLEVAGE PORCIN';
      case AppTabs.inseminations:
        return 'GESTION DES INSÉMINATIONS';
      case AppTabs.boars:
        return 'GESTION DES VERRATS';
      case AppTabs.sows:
        return 'GESTION DES TRUIES';
      case AppTabs.pedigree:
        return 'GESTION PEDIGREE';
      case AppTabs.health:
        return 'VACCINS ET TRAITEMENTS';
      case AppTabs.commercial:
        return 'GESTION COMMERCIALE ET STOCK';
      case AppTabs.logiciel:
        return 'CARACTÉRISTIQUES DU LOGICIEL';
      case AppTabs.users:
        return 'UTILISATEURS';
      default:
        return 'PORC GESTION';
    }
  }

  bool _canAddForTab(String tabId) {
    if (!_canAccessTab(tabId)) {
      return false;
    }
    return !const {
      AppTabs.users,
      AppTabs.administration,
      AppTabs.services,
      AppTabs.elevage,
      AppTabs.commercial,
      AppTabs.logiciel,
    }.contains(tabId);
  }

  IconData _fabIconForTab(String tabId) {
    switch (tabId) {
      case AppTabs.inseminations:
      case AppTabs.dashboard:
        return LucideIcons.syringe;
      case AppTabs.boars:
        return LucideIcons.badgeInfo;
      case AppTabs.sows:
        return LucideIcons.piggyBank;
      case AppTabs.pedigree:
        return LucideIcons.dna;
      case AppTabs.health:
        return LucideIcons.shieldCheck;
      default:
        return LucideIcons.plus;
    }
  }

  String _fabLabelForTab(String tabId) {
    switch (tabId) {
      case AppTabs.dashboard:
      case AppTabs.inseminations:
        return 'Ajouter IA';
      case AppTabs.boars:
        return 'Ajouter Verrat';
      case AppTabs.sows:
        return 'Ajouter Truie';
      case AppTabs.pedigree:
        return 'Ajouter Animal';
      case AppTabs.health:
        return 'Ajouter Acte Santé';
      default:
        return 'Ajouter';
    }
  }

  void _openAddDialogForTab() {
    if (!_canAccessTab(_activeTab)) {
      _showError('Accès refusé pour le rôle ${_currentUser.role}.');
      return;
    }
    switch (_activeTab) {
      case AppTabs.dashboard:
      case AppTabs.inseminations:
        _showAddInseminationDialog();
        break;
      case AppTabs.boars:
        _showAddBoarDialog();
        break;
      case AppTabs.sows:
        _showAddSowDialog();
        break;
      case AppTabs.pedigree:
        _showAddAnimalDialogFromPedigree();
        break;
      case AppTabs.health:
        _showAddHealthDialog();
        break;
      default:
        break;
    }
  }

  void _showAddAnimalDialogFromPedigree() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.badgeInfo),
                title: const Text('Ajouter un verrat'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddBoarDialog();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.piggyBank),
                title: const Text('Ajouter une truie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddSowDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddBoarDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final birthDateCtrl = TextEditingController();
    final originCtrl = TextEditingController();
    final sireCtrl = TextEditingController();
    final damCtrl = TextEditingController();
    final semenTypeCtrl = TextEditingController(text: 'Fraîche');
    final notesCtrl = TextEditingController();
    final breeders = _breeders;
    String selectedBreederId = _currentUser.role == Roles.breeder
        ? _currentUser.id
        : (breeders.isNotEmpty ? breeders.first.id : '');
    String selectedImageBase64 = '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouveau Verrat'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(codeCtrl, 'Code verrat *', hint: 'VR-3001'),
                      _dialogField(nameCtrl, 'Nom verrat *'),
                      _dialogField(breedCtrl, 'Race *', hint: 'Large White'),
                      _dialogField(
                        birthDateCtrl,
                        'Date naissance *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        originCtrl,
                        'Origine *',
                        hint: 'Station Alpha',
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBreederId,
                        decoration: const InputDecoration(
                          labelText: 'Éleveur responsable',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Non affecté'),
                          ),
                          ...breeders.map(
                            (breeder) => DropdownMenuItem(
                              value: breeder.id,
                              child: Text(breeder.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBreederId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(sireCtrl, 'Code père (optionnel)'),
                      _dialogField(damCtrl, 'Code mère (optionnel)'),
                      _dialogField(
                        semenTypeCtrl,
                        'Type semence',
                        hint: 'Fraîche / Congelée',
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(selectedImageBase64, size: 88),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Photo verrat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final imageBase64 =
                                            await _pickImageAsBase64();
                                        if (imageBase64 == null) {
                                          return;
                                        }
                                        setModalState(
                                          () =>
                                              selectedImageBase64 = imageBase64,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('Ajouter image'),
                                    ),
                                    if (selectedImageBase64.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setModalState(
                                            () => selectedImageBase64 = '',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                        ),
                                        label: const Text('Retirer'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _dialogField(notesCtrl, 'Notes', maxLines: 2),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final birthDate = _tryParseDate(birthDateCtrl.text.trim());
                    if (codeCtrl.text.trim().isEmpty ||
                        nameCtrl.text.trim().isEmpty ||
                        breedCtrl.text.trim().isEmpty ||
                        originCtrl.text.trim().isEmpty ||
                        birthDate == null) {
                      _showError(
                        'Champs requis manquants: code, nom, race, origine, date valide.',
                      );
                      return;
                    }

                    setState(() {
                      _boars.insert(
                        0,
                        Boar(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          code: codeCtrl.text.trim(),
                          name: nameCtrl.text.trim(),
                          breed: breedCtrl.text.trim(),
                          birthDate: birthDate,
                          origin: originCtrl.text.trim(),
                          breederId: selectedBreederId,
                          sireCode: sireCtrl.text.trim(),
                          damCode: damCtrl.text.trim(),
                          semenType: semenTypeCtrl.text.trim().isEmpty
                              ? 'Fraîche'
                              : semenTypeCtrl.text.trim(),
                          notes: notesCtrl.text.trim(),
                          imageBase64: selectedImageBase64,
                        ),
                      );
                      if (_preferredBoarCode == null ||
                          _preferredBoarCode!.trim().isEmpty) {
                        _preferredBoarCode = codeCtrl.text.trim();
                      }
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        codeCtrl,
        nameCtrl,
        breedCtrl,
        birthDateCtrl,
        originCtrl,
        sireCtrl,
        damCtrl,
        semenTypeCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showAddSowDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final birthDateCtrl = TextEditingController();
    final parityCtrl = TextEditingController(text: '1');
    final sireCtrl = TextEditingController();
    final damCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final breeders = _breeders;
    String selectedBreederId = _currentUser.role == Roles.breeder
        ? _currentUser.id
        : (breeders.isNotEmpty ? breeders.first.id : '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle Truie'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(codeCtrl, 'Code truie *', hint: 'TR-3001'),
                      _dialogField(nameCtrl, 'Nom truie *'),
                      _dialogField(breedCtrl, 'Race *', hint: 'Duroc'),
                      _dialogField(
                        birthDateCtrl,
                        'Date naissance *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        parityCtrl,
                        'Parité *',
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBreederId,
                        decoration: const InputDecoration(
                          labelText: 'Éleveur responsable',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Non affecté'),
                          ),
                          ...breeders.map(
                            (breeder) => DropdownMenuItem(
                              value: breeder.id,
                              child: Text(breeder.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBreederId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(sireCtrl, 'Code père (optionnel)'),
                      _dialogField(damCtrl, 'Code mère (optionnel)'),
                      _dialogField(notesCtrl, 'Notes', maxLines: 2),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final birthDate = _tryParseDate(birthDateCtrl.text.trim());
                    final parity = int.tryParse(parityCtrl.text.trim());

                    if (codeCtrl.text.trim().isEmpty ||
                        nameCtrl.text.trim().isEmpty ||
                        breedCtrl.text.trim().isEmpty ||
                        birthDate == null ||
                        parity == null) {
                      _showError(
                        'Champs requis manquants: code, nom, race, date valide, parité.',
                      );
                      return;
                    }

                    setState(() {
                      _sows.insert(
                        0,
                        Sow(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          code: codeCtrl.text.trim(),
                          name: nameCtrl.text.trim(),
                          breed: breedCtrl.text.trim(),
                          birthDate: birthDate,
                          parity: parity,
                          breederId: selectedBreederId,
                          sireCode: sireCtrl.text.trim(),
                          damCode: damCtrl.text.trim(),
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        codeCtrl,
        nameCtrl,
        breedCtrl,
        birthDateCtrl,
        parityCtrl,
        sireCtrl,
        damCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showAddInseminationDialog() {
    if (_boars.isEmpty || _sows.isEmpty) {
      _showError('Ajoutez d\'abord au moins un verrat et une truie.');
      return;
    }

    final lotCtrl = TextEditingController();
    final dose1Ctrl = TextEditingController();
    final dose2Ctrl = TextEditingController();
    final inseminatorCtrl = TextEditingController(text: _currentUser.name);
    final notesCtrl = TextEditingController();

    String selectedSowCode = _sows.first.code;
    final initialPreferredBoar = _preferredBoarCode;
    final hasPreferredBoar =
        initialPreferredBoar != null &&
        _boars.any(
          (boar) =>
              boar.code.toLowerCase() == initialPreferredBoar.toLowerCase(),
        );
    String selectedBoarCode = hasPreferredBoar
        ? initialPreferredBoar
        : _boars.first.code;
    String selectedStatus = 'En attente diagnostic';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle Insémination'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedSowCode,
                        decoration: const InputDecoration(
                          labelText: 'Truie *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _sows
                            .map(
                              (sow) => DropdownMenuItem(
                                value: sow.code,
                                child: Text('${sow.code} - ${sow.name}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedSowCode = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBoarCode,
                        decoration: const InputDecoration(
                          labelText: 'Verrat *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _boars
                            .map(
                              (boar) => DropdownMenuItem(
                                value: boar.code,
                                child: Text(
                                  '${_isPreferredBoar(boar.code) ? '⭐ ' : ''}'
                                  '${boar.code} - ${boar.name} (${boar.breed})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBoarCode = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Choix visuel du géniteur',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _boars.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final boar = _boars[index];
                            final selected = boar.code == selectedBoarCode;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setModalState(
                                  () => selectedBoarCode = boar.code,
                                );
                              },
                              child: Container(
                                width: 148,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFDCFCE7)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildBoarPhoto(boar, size: 52),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            boar.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            boar.code,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_isPreferredBoar(boar.code))
                                            const Text(
                                              'Géniteur recommandé',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF0F766E),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        lotCtrl,
                        'Lot semence *',
                        hint: 'LOT-IA-2410',
                      ),
                      _dialogField(
                        dose1Ctrl,
                        'Date 1ère dose *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        dose2Ctrl,
                        'Date 2ème dose (optionnel)',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(inseminatorCtrl, 'Inséminateur *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'En attente diagnostic',
                            child: Text('En attente diagnostic'),
                          ),
                          DropdownMenuItem(
                            value: 'Gestante confirmée',
                            child: Text('Gestante confirmée'),
                          ),
                          DropdownMenuItem(
                            value: 'Échec / retour chaleur',
                            child: Text('Échec / retour chaleur'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(notesCtrl, 'Notes', maxLines: 2),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final dose1Date = _tryParseDate(dose1Ctrl.text.trim());
                    DateTime? dose2Date;

                    if (dose1Date == null || lotCtrl.text.trim().isEmpty) {
                      _showError(
                        'Veuillez renseigner une date IA1 valide et le lot semence.',
                      );
                      return;
                    }

                    if (dose2Ctrl.text.trim().isNotEmpty) {
                      dose2Date = _tryParseDate(dose2Ctrl.text.trim());
                      if (dose2Date == null) {
                        _showError('Date IA2 invalide.');
                        return;
                      }
                    }

                    setState(() {
                      _inseminations.insert(
                        0,
                        InseminationRecord(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          sowCode: selectedSowCode,
                          boarCode: selectedBoarCode,
                          semenLot: lotCtrl.text.trim(),
                          dose1Date: dose1Date,
                          dose2Date: dose2Date,
                          inseminator: inseminatorCtrl.text.trim().isEmpty
                              ? _currentUser.name
                              : inseminatorCtrl.text.trim(),
                          status: selectedStatus,
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        lotCtrl,
        dose1Ctrl,
        dose2Ctrl,
        inseminatorCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showAddHealthDialog() {
    if (_boars.isEmpty && _sows.isEmpty) {
      _showError('Ajoutez d\'abord un verrat ou une truie.');
      return;
    }

    final dateCtrl = TextEditingController();
    final productCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final nextDateCtrl = TextEditingController();
    final responsibleCtrl = TextEditingController(text: _currentUser.name);
    final notesCtrl = TextEditingController();

    String selectedAnimalType = _sows.isNotEmpty ? 'Truie' : 'Verrat';
    String selectedEventType = 'Vaccin';
    String? selectedAnimalCode = _sows.isNotEmpty
        ? _sows.first.code
        : (_boars.isNotEmpty ? _boars.first.code : null);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final animalCodes = selectedAnimalType == 'Truie'
                ? _sows.map((sow) => sow.code).toList()
                : _boars.map((boar) => boar.code).toList();

            if (animalCodes.isNotEmpty &&
                !animalCodes.contains(selectedAnimalCode)) {
              selectedAnimalCode = animalCodes.first;
            }

            return AlertDialog(
              title: const Text('Nouveau Vaccin / Traitement'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedAnimalType,
                        decoration: const InputDecoration(
                          labelText: 'Type animal',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Truie',
                            child: Text('Truie'),
                          ),
                          DropdownMenuItem(
                            value: 'Verrat',
                            child: Text('Verrat'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              selectedAnimalType = value;
                              final updatedCodes = value == 'Truie'
                                  ? _sows.map((sow) => sow.code).toList()
                                  : _boars.map((boar) => boar.code).toList();
                              selectedAnimalCode = updatedCodes.isNotEmpty
                                  ? updatedCodes.first
                                  : null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (animalCodes.isEmpty)
                        const Text(
                          'Aucun animal disponible pour ce type.',
                          style: TextStyle(color: Color(0xFFB91C1C)),
                        )
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            '$selectedAnimalType-${selectedAnimalCode ?? ''}',
                          ),
                          initialValue: selectedAnimalCode,
                          decoration: const InputDecoration(
                            labelText: 'Code animal *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: animalCodes
                              .map(
                                (code) => DropdownMenuItem(
                                  value: code,
                                  child: Text(code),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedAnimalCode = value);
                            }
                          },
                        ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Type acte',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Vaccin',
                            child: Text('Vaccin'),
                          ),
                          DropdownMenuItem(
                            value: 'Traitement',
                            child: Text('Traitement'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedEventType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        dateCtrl,
                        'Date acte *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(productCtrl, 'Produit *'),
                      _dialogField(doseCtrl, 'Dose *', hint: '2 ml'),
                      _dialogField(reasonCtrl, 'Motif *'),
                      _dialogField(
                        nextDateCtrl,
                        'Prochaine date (optionnel)',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(responsibleCtrl, 'Responsable *'),
                      _dialogField(notesCtrl, 'Notes', maxLines: 2),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final eventDate = _tryParseDate(dateCtrl.text.trim());
                    DateTime? nextDate;

                    if (selectedAnimalCode == null ||
                        eventDate == null ||
                        productCtrl.text.trim().isEmpty ||
                        doseCtrl.text.trim().isEmpty ||
                        reasonCtrl.text.trim().isEmpty ||
                        responsibleCtrl.text.trim().isEmpty) {
                      _showError(
                        'Veuillez renseigner animal, date valide, produit, dose, motif et responsable.',
                      );
                      return;
                    }

                    if (nextDateCtrl.text.trim().isNotEmpty) {
                      nextDate = _tryParseDate(nextDateCtrl.text.trim());
                      if (nextDate == null) {
                        _showError('Date de rappel invalide.');
                        return;
                      }
                    }

                    setState(() {
                      _healthRecords.insert(
                        0,
                        HealthRecord(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          animalType: selectedAnimalType,
                          animalCode: selectedAnimalCode!,
                          eventType: selectedEventType,
                          eventDate: eventDate,
                          product: productCtrl.text.trim(),
                          dose: doseCtrl.text.trim(),
                          reason: reasonCtrl.text.trim(),
                          nextDate: nextDate,
                          responsible: responsibleCtrl.text.trim(),
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                    });
                    _persistState();

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        dateCtrl,
        productCtrl,
        doseCtrl,
        reasonCtrl,
        nextDateCtrl,
        responsibleCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showAddClientDialog() {
    final nameCtrl = TextEditingController();
    final segmentCtrl = TextEditingController(text: 'Charcutier');
    final contactCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouveau client'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Nom client *'),
                _dialogField(
                  segmentCtrl,
                  'Segment *',
                  hint: 'Charcutier / Éleveur porcelets / Autre vente',
                ),
                _dialogField(contactCtrl, 'Contact'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    segmentCtrl.text.trim().isEmpty) {
                  _showError('Nom client et segment sont requis.');
                  return;
                }

                setState(() {
                  _clients.insert(
                    0,
                    Client(
                      id: _newId('CL'),
                      name: nameCtrl.text.trim(),
                      segment: segmentCtrl.text.trim(),
                      contact: contactCtrl.text.trim(),
                    ),
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Client ajouté.');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ).then((_) => _disposeControllers([nameCtrl, segmentCtrl, contactCtrl]));
  }

  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Aliments');
    final contactCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouveau fournisseur'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Nom fournisseur *'),
                _dialogField(
                  categoryCtrl,
                  'Catégorie *',
                  hint: 'Aliments / Doses semence / Médicaments',
                ),
                _dialogField(contactCtrl, 'Contact'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    categoryCtrl.text.trim().isEmpty) {
                  _showError('Nom fournisseur et catégorie sont requis.');
                  return;
                }

                setState(() {
                  _suppliers.insert(
                    0,
                    Supplier(
                      id: _newId('SUP'),
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      contact: contactCtrl.text.trim(),
                    ),
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Fournisseur ajouté.');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ).then((_) => _disposeControllers([nameCtrl, categoryCtrl, contactCtrl]));
  }

  void _showAddSaleDialog() {
    if (_clients.isEmpty) {
      _showError('Ajoutez d\'abord un client.');
      return;
    }

    final dateCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    String selectedType = 'Vente de porcs (charcutiers)';
    String selectedClientId = _clients.first.id;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle vente'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type vente *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Vente de porcs (charcutiers)',
                            child: Text('Vente de porcs (charcutiers)'),
                          ),
                          DropdownMenuItem(
                            value: 'Vente de porcelets',
                            child: Text('Vente de porcelets'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre vente',
                            child: Text('Autre vente'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClientId,
                        decoration: const InputDecoration(
                          labelText: 'Client *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client.id,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedClientId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        dateCtrl,
                        'Date vente *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        quantityCtrl,
                        'Quantité *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        amountCtrl,
                        'Montant (Ar) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final date = _tryParseDate(dateCtrl.text.trim());
                    final quantity = int.tryParse(quantityCtrl.text.trim());
                    final amount = _tryParseAmount(amountCtrl.text.trim());

                    if (date == null ||
                        quantity == null ||
                        quantity <= 0 ||
                        amount == null ||
                        amount <= 0) {
                      _showError(
                        'Veuillez renseigner date valide, quantité > 0 et montant > 0.',
                      );
                      return;
                    }

                    setState(() {
                      _salesRecords.insert(
                        0,
                        SaleRecord(
                          id: _newId('SLE'),
                          type: selectedType,
                          clientId: selectedClientId,
                          date: date,
                          quantity: quantity,
                          amount: amount,
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Vente ajoutée.');
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _disposeControllers([dateCtrl, quantityCtrl, amountCtrl]));
  }

  void _showAddSupplyDialog() {
    if (_suppliers.isEmpty) {
      _showError('Ajoutez d\'abord un fournisseur.');
      return;
    }

    final dateCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    String selectedCategory = 'Aliments';
    String selectedSupplierId = _suppliers.first.id;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouveau ravitaillement'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Aliments',
                            child: Text('Aliments'),
                          ),
                          DropdownMenuItem(
                            value: 'Doses semence',
                            child: Text('Doses semence'),
                          ),
                          DropdownMenuItem(
                            value: 'Médicaments',
                            child: Text('Médicaments'),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSupplierId,
                        decoration: const InputDecoration(
                          labelText: 'Fournisseur *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _suppliers
                            .map(
                              (supplier) => DropdownMenuItem(
                                value: supplier.id,
                                child: Text(supplier.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedSupplierId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        dateCtrl,
                        'Date ravitaillement *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        amountCtrl,
                        'Montant (Ar) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(notesCtrl, 'Notes'),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final date = _tryParseDate(dateCtrl.text.trim());
                    final amount = _tryParseAmount(amountCtrl.text.trim());

                    if (date == null || amount == null || amount <= 0) {
                      _showError(
                        'Veuillez renseigner une date valide et un montant > 0.',
                      );
                      return;
                    }

                    setState(() {
                      _supplyRecords.insert(
                        0,
                        SupplyRecord(
                          id: _newId('SP'),
                          category: selectedCategory,
                          supplierId: selectedSupplierId,
                          date: date,
                          amount: amount,
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Ravitaillement ajouté.');
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _disposeControllers([dateCtrl, amountCtrl, notesCtrl]));
  }

  void _showAddUserDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final loginCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = Roles.breeder;
    bool hidePassword = true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvel utilisateur'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(
                        codeCtrl,
                        'Code utilisateur *',
                        hint: 'USR-01',
                      ),
                      _dialogField(nameCtrl, 'Nom complet *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Rôle *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Roles.admin,
                            child: Text(Roles.admin),
                          ),
                          DropdownMenuItem(
                            value: Roles.breeder,
                            child: Text(Roles.breeder),
                          ),
                          DropdownMenuItem(
                            value: Roles.inseminator,
                            child: Text(Roles.inseminator),
                          ),
                          DropdownMenuItem(
                            value: Roles.vet,
                            child: Text(Roles.vet),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        loginCtrl,
                        'Login *',
                        hint: 'identifiant de connexion',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: passwordCtrl,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe *',
                            hintText: '8 caractères min (lettres + chiffres)',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setModalState(
                                  () => hidePassword = !hidePassword,
                                );
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final code = codeCtrl.text.trim();
                    final name = nameCtrl.text.trim();
                    final login = loginCtrl.text.trim().toLowerCase();
                    final password = passwordCtrl.text;

                    if (code.isEmpty ||
                        name.isEmpty ||
                        login.isEmpty ||
                        password.isEmpty) {
                      _showError(
                        'Veuillez remplir code, nom, rôle, login et mot de passe.',
                      );
                      return;
                    }
                    if (_isDuplicateUserCode(code)) {
                      _showError('Code utilisateur déjà utilisé.');
                      return;
                    }
                    if (_isDuplicateUserLogin(login)) {
                      _showError('Login déjà utilisé.');
                      return;
                    }
                    if (!_isStrongPassword(password)) {
                      _showError(
                        'Mot de passe faible: minimum 8 caractères avec lettres et chiffres.',
                      );
                      return;
                    }

                    final avatar = _avatarFromName(name);
                    final user = UserProfile(
                      id: _newId('U'),
                      code: code,
                      name: name,
                      role: selectedRole,
                      avatar: avatar,
                      login: login,
                      password: password,
                    );

                    setState(() => _users.insert(0, user));
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Utilisateur ajouté.');
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([codeCtrl, nameCtrl, loginCtrl, passwordCtrl]),
    );
  }

  void _showEditUserDialog(UserProfile user) {
    final codeCtrl = TextEditingController(text: user.code);
    final nameCtrl = TextEditingController(text: user.name);
    final loginCtrl = TextEditingController(text: user.login);
    String selectedRole = user.role;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Modifier ${user.name}'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(codeCtrl, 'Code utilisateur *'),
                      _dialogField(nameCtrl, 'Nom complet *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Rôle *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Roles.admin,
                            child: Text(Roles.admin),
                          ),
                          DropdownMenuItem(
                            value: Roles.breeder,
                            child: Text(Roles.breeder),
                          ),
                          DropdownMenuItem(
                            value: Roles.inseminator,
                            child: Text(Roles.inseminator),
                          ),
                          DropdownMenuItem(
                            value: Roles.vet,
                            child: Text(Roles.vet),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogField(loginCtrl, 'Login *'),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final code = codeCtrl.text.trim();
                    final name = nameCtrl.text.trim();
                    final login = loginCtrl.text.trim().toLowerCase();

                    if (code.isEmpty || name.isEmpty || login.isEmpty) {
                      _showError('Code, nom et login sont obligatoires.');
                      return;
                    }
                    if (_isDuplicateUserCode(code, ignoreUserId: user.id)) {
                      _showError('Code utilisateur déjà utilisé.');
                      return;
                    }
                    if (_isDuplicateUserLogin(login, ignoreUserId: user.id)) {
                      _showError('Login déjà utilisé.');
                      return;
                    }
                    final adminCount = _users
                        .where((item) => item.role == Roles.admin)
                        .length;
                    if (user.role == Roles.admin &&
                        selectedRole != Roles.admin &&
                        adminCount <= 1) {
                      _showError(
                        'Impossible de retirer le rôle du dernier administrateur.',
                      );
                      return;
                    }

                    final updated = UserProfile(
                      id: user.id,
                      code: code,
                      name: name,
                      role: selectedRole,
                      avatar: _avatarFromName(name),
                      login: login,
                      password: user.password,
                    );

                    final index = _users.indexWhere(
                      (item) => item.id == user.id,
                    );
                    if (index < 0) {
                      return;
                    }

                    setState(() {
                      _users[index] = updated;
                      if (_currentUser.id == updated.id) {
                        _currentUser = updated;
                      }
                      _ensureActiveTabAccess();
                    });
                    _persistState();

                    Navigator.of(dialogContext).pop();
                    _showInfo('Utilisateur mis à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _disposeControllers([codeCtrl, nameCtrl, loginCtrl]));
  }

  void _showChangeUserPasswordDialog(UserProfile user) {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool hidePassword = true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Mot de passe - ${user.login}'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: passwordCtrl,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe *',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setModalState(() => hidePassword = !hidePassword);
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: hidePassword,
                      decoration: const InputDecoration(
                        labelText: 'Confirmation mot de passe *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final password = passwordCtrl.text;
                    final confirm = confirmCtrl.text;

                    if (password.isEmpty || confirm.isEmpty) {
                      _showError(
                        'Renseignez le nouveau mot de passe et sa confirmation.',
                      );
                      return;
                    }
                    if (password != confirm) {
                      _showError(
                        'La confirmation du mot de passe ne correspond pas.',
                      );
                      return;
                    }
                    if (!_isStrongPassword(password)) {
                      _showError(
                        'Mot de passe faible: minimum 8 caractères avec lettres et chiffres.',
                      );
                      return;
                    }

                    final index = _users.indexWhere(
                      (item) => item.id == user.id,
                    );
                    if (index < 0) {
                      return;
                    }
                    final updated = UserProfile(
                      id: user.id,
                      code: user.code,
                      name: user.name,
                      role: user.role,
                      avatar: user.avatar,
                      login: user.login,
                      password: password,
                    );

                    setState(() {
                      _users[index] = updated;
                      if (_currentUser.id == updated.id) {
                        _currentUser = updated;
                      }
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Mot de passe mis à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _disposeControllers([passwordCtrl, confirmCtrl]));
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  UserProfile _adminUserProfile() {
    for (final user in _users) {
      if (user.role == Roles.admin) {
        return user;
      }
    }
    return _currentUser;
  }

  DateTime _salesFilterStartDate() {
    final now = _currentDate();
    switch (_salesFilter) {
      case '7 jours':
        return now.subtract(const Duration(days: 7));
      case '30 jours':
        return now.subtract(const Duration(days: 30));
      case '90 jours':
        return now.subtract(const Duration(days: 90));
      case '12 mois':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  List<SaleRecord> _filteredSalesRecords() {
    final start = _salesFilterStartDate();
    final end = _currentDate().add(const Duration(days: 1));
    final filtered = _salesRecords
        .where((sale) => !sale.date.isBefore(start) && sale.date.isBefore(end))
        .toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  List<SupplyRecord> _filteredSupplyRecords() {
    final start = _salesFilterStartDate();
    final end = _currentDate().add(const Duration(days: 1));
    final filtered = _supplyRecords
        .where(
          (supply) => !supply.date.isBefore(start) && supply.date.isBefore(end),
        )
        .toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Widget _buildSalesFilterControl() {
    return Row(
      children: [
        const Text(
          'Filtrer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _salesFilter,
            underline: const SizedBox.shrink(),
            items: _salesFilterOptions
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _salesFilter = value);
              _persistState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSalesEvolutionChart(List<SaleRecord> filteredSales) {
    if (filteredSales.isEmpty) {
      return _buildEmptyState('Aucune vente sur la période filtrée.');
    }

    final start = _salesFilterStartDate();
    final end = _currentDate().add(const Duration(days: 1));
    final totalDays = math.max(1, end.difference(start).inDays);
    final bucketCount = math.min(6, totalDays);
    final stepDays = math.max(1, (totalDays / bucketCount).ceil());
    final amounts = List<double>.filled(bucketCount, 0);

    for (final sale in filteredSales) {
      final delta = sale.date.difference(start).inDays;
      if (delta < 0 || delta >= totalDays) {
        continue;
      }
      var index = (delta / stepDays).floor();
      if (index >= bucketCount) {
        index = bucketCount - 1;
      }
      amounts[index] += sale.amount;
    }

    final maxAmount = amounts.reduce(math.max);
    final adjustedMax = maxAmount <= 0 ? 1.0 : maxAmount;

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bucketCount; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(amounts[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: math.max(8, 120 * (amounts[i] / adjustedMax)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat(
                        'd MMM',
                        'fr_FR',
                      ).format(start.add(Duration(days: i * stepDays))),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: ${_formatAmount(amount)}',
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  void _attemptLogin() {
    final login = _loginController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(
        () => _authError = 'Veuillez saisir le login et le mot de passe.',
      );
      return;
    }

    UserProfile? matchedUser;
    for (final user in _users) {
      if (user.login.toLowerCase() == login ||
          user.code.toLowerCase() == login) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null || matchedUser.password != password) {
      setState(() => _authError = 'Login ou mot de passe invalide.');
      return;
    }

    setState(() {
      _currentUser = matchedUser!;
      _isAuthenticated = true;
      _authError = null;
      _activeTab = _defaultTabForCurrentUser();
    });
    _persistState();
    _loginController.clear();
    _passwordController.clear();
    _showInfo('Connexion réussie: ${_currentUser.name}');
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _authError = null;
      _activeTab = AppTabs.dashboard;
      _hidePassword = true;
    });
    _persistState();
    _loginController.clear();
    _passwordController.clear();
  }

  String _clientNameForId(String clientId) {
    for (final client in _clients) {
      if (client.id == clientId) {
        return client.name;
      }
    }
    return 'Client inconnu';
  }

  String _supplierNameForId(String supplierId) {
    for (final supplier in _suppliers) {
      if (supplier.id == supplierId) {
        return supplier.name;
      }
    }
    return 'Fournisseur inconnu';
  }

  String _batchNameForId(String batchId) {
    for (final batch in _batchRecords) {
      if (batch.id == batchId) {
        return batch.name;
      }
    }
    return 'Bande inconnue';
  }

  String _topBreedFromBoars() {
    if (_boars.isEmpty) {
      return '-';
    }
    final counts = <String, int>{};
    for (final boar in _boars) {
      counts[boar.breed] = (counts[boar.breed] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _topBreedFromSows() {
    if (_sows.isEmpty) {
      return '-';
    }
    final counts = <String, int>{};
    for (final sow in _sows) {
      counts[sow.breed] = (counts[sow.breed] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'Ar ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  double? _tryParseAmount(String rawValue) {
    final normalized = rawValue
        .trim()
        .replaceAll(' ', '')
        .replaceAll("'", '')
        .replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF15803D),
        ),
      );
  }

  Future<bool> _confirmDeletion({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteInsemination(String recordId) async {
    final index = _inseminations.indexWhere((record) => record.id == recordId);
    if (index < 0) {
      return;
    }
    final record = _inseminations[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette insémination ?',
      message:
          'Truie ${record.sowCode} / Verrat ${record.boarCode}. Cette action est irréversible.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _inseminations.removeAt(index));
    _persistState();
    _showInfo('Insémination supprimée.');
  }

  Future<void> _deleteBoar(String boarId) async {
    final index = _boars.indexWhere((boar) => boar.id == boarId);
    if (index < 0) {
      return;
    }
    final boar = _boars[index];

    final usedInInsemination = _inseminations.any(
      (record) => record.boarCode.toLowerCase() == boar.code.toLowerCase(),
    );
    if (usedInInsemination) {
      _showError(
        'Impossible de supprimer ${boar.code}: utilisé dans des inséminations.',
      );
      return;
    }

    final usedInHealthRecords = _healthRecords.any(
      (record) =>
          record.animalType.toLowerCase().contains('verrat') &&
          record.animalCode.toLowerCase() == boar.code.toLowerCase(),
    );
    if (usedInHealthRecords) {
      _showError(
        'Impossible de supprimer ${boar.code}: utilisé dans des actes santé.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer le verrat ${boar.code} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _boars.removeAt(index);
      if (_isPreferredBoar(boar.code)) {
        _preferredBoarCode = _boars.isNotEmpty ? _boars.first.code : null;
      }
    });
    _persistState();
    _showInfo('Verrat ${boar.code} supprimé.');
  }

  Future<void> _deleteSow(String sowId) async {
    final index = _sows.indexWhere((sow) => sow.id == sowId);
    if (index < 0) {
      return;
    }
    final sow = _sows[index];

    final usedInInsemination = _inseminations.any(
      (record) => record.sowCode.toLowerCase() == sow.code.toLowerCase(),
    );
    if (usedInInsemination) {
      _showError(
        'Impossible de supprimer ${sow.code}: utilisée dans des inséminations.',
      );
      return;
    }

    final usedInHealthRecords = _healthRecords.any(
      (record) =>
          record.animalType.toLowerCase().contains('truie') &&
          record.animalCode.toLowerCase() == sow.code.toLowerCase(),
    );
    if (usedInHealthRecords) {
      _showError(
        'Impossible de supprimer ${sow.code}: utilisée dans des actes santé.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer la truie ${sow.code} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _sows.removeAt(index));
    _persistState();
    _showInfo('Truie ${sow.code} supprimée.');
  }

  Future<void> _deleteHealthRecord(String recordId) async {
    final index = _healthRecords.indexWhere((record) => record.id == recordId);
    if (index < 0) {
      return;
    }
    final record = _healthRecords[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer cet acte santé ?',
      message:
          '${record.eventType} sur ${record.animalType} ${record.animalCode}.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _healthRecords.removeAt(index));
    _persistState();
    _showInfo('Acte santé supprimé.');
  }

  Future<void> _deleteClient(String clientId) async {
    final index = _clients.indexWhere((client) => client.id == clientId);
    if (index < 0) {
      return;
    }
    final client = _clients[index];

    final usedInSales = _salesRecords.any((sale) => sale.clientId == clientId);
    if (usedInSales) {
      _showError(
        'Impossible de supprimer ${client.name}: client utilisé dans des ventes.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer le client ${client.name} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _clients.removeAt(index));
    _persistState();
    _showInfo('Client supprimé.');
  }

  Future<void> _deleteSupplier(String supplierId) async {
    final index = _suppliers.indexWhere(
      (supplier) => supplier.id == supplierId,
    );
    if (index < 0) {
      return;
    }
    final supplier = _suppliers[index];

    final usedInSupplies = _supplyRecords.any(
      (supply) => supply.supplierId == supplierId,
    );
    if (usedInSupplies) {
      _showError(
        'Impossible de supprimer ${supplier.name}: fournisseur utilisé dans des ravitaillements.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer le fournisseur ${supplier.name} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _suppliers.removeAt(index));
    _persistState();
    _showInfo('Fournisseur supprimé.');
  }

  Future<void> _deleteSaleRecord(String saleId) async {
    final index = _salesRecords.indexWhere((sale) => sale.id == saleId);
    if (index < 0) {
      return;
    }
    final sale = _salesRecords[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette vente ?',
      message:
          '${sale.type} du ${_formatDate(sale.date)} (${_formatAmount(sale.amount)}).',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _salesRecords.removeAt(index));
    _persistState();
    _showInfo('Vente supprimée.');
  }

  Future<void> _deleteSupplyRecord(String supplyId) async {
    final index = _supplyRecords.indexWhere((supply) => supply.id == supplyId);
    if (index < 0) {
      return;
    }
    final supply = _supplyRecords[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer ce ravitaillement ?',
      message:
          '${supply.category} du ${_formatDate(supply.date)} (${_formatAmount(supply.amount)}).',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _supplyRecords.removeAt(index));
    _persistState();
    _showInfo('Ravitaillement supprimé.');
  }

  Future<void> _deleteUser(String userId) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      return;
    }
    final user = _users[index];

    if (user.id == _currentUser.id) {
      _showError('Impossible de supprimer votre propre compte actif.');
      return;
    }

    final adminCount = _users.where((item) => item.role == Roles.admin).length;
    if (user.role == Roles.admin && adminCount <= 1) {
      _showError('Impossible de supprimer le dernier administrateur.');
      return;
    }

    final assignedInBoars = _boars.any((boar) => boar.breederId == user.id);
    final assignedInSows = _sows.any((sow) => sow.breederId == user.id);
    if (assignedInBoars || assignedInSows) {
      _showError(
        'Utilisateur affecté à des animaux. Réaffectez les verrats/truies avant suppression.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer ${user.name} ?',
      message:
          'Compte ${user.login} (${user.role}). Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _users.removeAt(index));
    _persistState();
    _showInfo('Utilisateur supprimé.');
  }

  bool _isDuplicateUserCode(String code, {String? ignoreUserId}) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _users.any(
      (user) =>
          user.id != ignoreUserId &&
          user.code.trim().toLowerCase() == normalized,
    );
  }

  bool _isDuplicateUserLogin(String login, {String? ignoreUserId}) {
    final normalized = login.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _users.any(
      (user) =>
          user.id != ignoreUserId &&
          user.login.trim().toLowerCase() == normalized,
    );
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) {
      return false;
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    return hasLetter && hasDigit;
  }

  String _avatarFromName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) {
      return 'U';
    }
    return clean.substring(0, 1).toUpperCase();
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final ctrl in controllers) {
      ctrl.dispose();
    }
  }

  Boar? _findBoar(String code) {
    for (final boar in _boars) {
      if (boar.code.toLowerCase() == code.toLowerCase()) {
        return boar;
      }
    }
    return null;
  }

  List<UserProfile> get _breeders =>
      _users.where((user) => user.role == Roles.breeder).toList();

  UserProfile? _findUserById(String id) {
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  String _firstUserNameByRole(String role) {
    for (final user in _users) {
      if (user.role == role) {
        return user.name;
      }
    }
    return _adminUserProfile().name;
  }

  String _breederNameForId(String breederId) {
    if (breederId.trim().isEmpty) {
      return 'Non affecté';
    }
    return _findUserById(breederId)?.name ?? 'Éleveur inconnu';
  }

  DateTime _currentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _expectedHeatReturnDate(InseminationRecord record) {
    return record.dose1Date.add(const Duration(days: 21));
  }

  DateTime _expectedPregnancyCheckDate(InseminationRecord record) {
    return record.dose1Date.add(const Duration(days: 28));
  }

  DateTime _expectedFarrowingDate(InseminationRecord record) {
    return record.dose1Date.add(const Duration(days: 114));
  }

  void _changeGestationCalendarMonth(int monthDelta) {
    final nextMonth = DateTime(
      _gestationCalendarMonth.year,
      _gestationCalendarMonth.month + monthDelta,
      1,
    );
    setState(() {
      _gestationCalendarMonth = nextMonth;
      final referenceDate = _selectedGestationDate ?? nextMonth;
      final maxDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      final day = math.min(referenceDate.day, maxDay);
      _selectedGestationDate = DateTime(nextMonth.year, nextMonth.month, day);
    });
    _persistState();
  }

  Map<DateTime, List<_GestationCalendarEvent>> _buildGestationCalendarEvents() {
    final events = <DateTime, List<_GestationCalendarEvent>>{};

    void addEvent({
      required DateTime date,
      required String label,
      required String type,
      required Color color,
      required IconData icon,
    }) {
      final key = _normalizeDate(date);
      final list = events.putIfAbsent(key, () => <_GestationCalendarEvent>[]);
      list.add(
        _GestationCalendarEvent(
          date: key,
          label: label,
          type: type,
          color: color,
          icon: icon,
        ),
      );
    }

    for (final record in _inseminations) {
      final pair = '${record.sowCode} x ${record.boarCode}';

      addEvent(
        date: record.dose1Date,
        label: 'IA1 $pair (lot ${record.semenLot})',
        type: 'IA',
        color: const Color(0xFF0F766E),
        icon: LucideIcons.syringe,
      );

      if (record.dose2Date != null) {
        addEvent(
          date: record.dose2Date!,
          label: 'IA2 $pair',
          type: 'IA',
          color: const Color(0xFF0F766E),
          icon: LucideIcons.syringe,
        );
      }

      if (!_isFailedStatus(record.status)) {
        addEvent(
          date: _expectedHeatReturnDate(record),
          label: 'Contrôle retour chaleur J21 - ${record.sowCode}',
          type: 'J21',
          color: const Color(0xFFB45309),
          icon: LucideIcons.badgeInfo,
        );
        addEvent(
          date: _expectedPregnancyCheckDate(record),
          label: 'Diagnostic gestation J28 - ${record.sowCode}',
          type: 'J28',
          color: const Color(0xFF0284C7),
          icon: LucideIcons.stethoscope,
        );
      }

      if (_isSuccessfulStatus(record.status)) {
        addEvent(
          date: _expectedFarrowingDate(record),
          label: 'Mise-bas prévue J114 - ${record.sowCode}',
          type: 'J114',
          color: const Color(0xFF16A34A),
          icon: LucideIcons.piggyBank,
        );
      }

      if (_isFailedStatus(record.status)) {
        addEvent(
          date: _expectedHeatReturnDate(record),
          label: 'Replanifier IA - ${record.sowCode}',
          type: 'ALERTE',
          color: const Color(0xFFB91C1C),
          icon: LucideIcons.alertTriangle,
        );
      }
    }

    for (final record in _healthRecords) {
      if (record.nextDate == null) {
        continue;
      }
      addEvent(
        date: record.nextDate!,
        label:
            '${record.eventType} ${record.animalType} ${record.animalCode} (${record.product})',
        type: 'SANTÉ',
        color: record.eventType == 'Vaccin'
            ? const Color(0xFF15803D)
            : const Color(0xFFEA580C),
        icon: record.eventType == 'Vaccin'
            ? LucideIcons.shieldCheck
            : LucideIcons.pill,
      );
    }

    for (final dayEvents in events.values) {
      dayEvents.sort((a, b) => a.label.compareTo(b.label));
    }

    return events;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _relativeDayLabel(DateTime date) {
    final days = date.difference(_currentDate()).inDays;
    if (days == 0) {
      return 'aujourd\'hui';
    }
    if (days > 0) {
      return 'dans $days j';
    }
    return 'retard ${days.abs()} j';
  }

  _ActionPriority _priorityFromDueDate(DateTime dueDate) {
    final days = dueDate.difference(_currentDate()).inDays;
    if (days <= 2) {
      return _ActionPriority.high;
    }
    if (days <= 7) {
      return _ActionPriority.medium;
    }
    return _ActionPriority.low;
  }

  List<_BreedingAction> _computeBreedingActions() {
    final now = _currentDate();
    final limit = now.add(const Duration(days: 30));
    final actions = <_BreedingAction>[];

    for (final record in _inseminations) {
      final heatDate = _expectedHeatReturnDate(record);
      final diagnosisDate = _expectedPregnancyCheckDate(record);
      final farrowingDate = _expectedFarrowingDate(record);

      if (!_isSuccessfulStatus(record.status) &&
          !_isFailedStatus(record.status)) {
        if (!heatDate.isBefore(now) && !heatDate.isAfter(limit)) {
          actions.add(
            _BreedingAction(
              title: 'Surveiller retour chaleur',
              detail: '${record.sowCode} après IA avec ${record.boarCode}',
              dueDate: heatDate,
              priority: _priorityFromDueDate(heatDate),
              color: const Color(0xFFB45309),
              icon: LucideIcons.badgeInfo,
            ),
          );
        }

        if (!diagnosisDate.isBefore(now) && !diagnosisDate.isAfter(limit)) {
          actions.add(
            _BreedingAction(
              title: 'Diagnostic de gestation',
              detail: 'Échographie recommandée pour ${record.sowCode}',
              dueDate: diagnosisDate,
              priority: _priorityFromDueDate(diagnosisDate),
              color: const Color(0xFF0F766E),
              icon: LucideIcons.syringe,
            ),
          );
        } else if (diagnosisDate.isBefore(now)) {
          actions.add(
            _BreedingAction(
              title: 'Diagnostic en retard',
              detail: '${record.sowCode} (IA ${_formatDate(record.dose1Date)})',
              dueDate: diagnosisDate,
              priority: _ActionPriority.high,
              color: const Color(0xFFB91C1C),
              icon: LucideIcons.badgeInfo,
            ),
          );
        }
      }

      if (_isSuccessfulStatus(record.status) &&
          !farrowingDate.isBefore(now) &&
          !farrowingDate.isAfter(limit)) {
        actions.add(
          _BreedingAction(
            title: 'Préparer mise-bas',
            detail: '${record.sowCode} (maternité, colostrum, surveillance)',
            dueDate: farrowingDate,
            priority: _priorityFromDueDate(farrowingDate),
            color: const Color(0xFF2563EB),
            icon: LucideIcons.piggyBank,
          ),
        );
      }
    }

    for (final record in _healthRecords) {
      if (record.nextDate == null) {
        continue;
      }
      if (record.nextDate!.isBefore(now) || record.nextDate!.isAfter(limit)) {
        continue;
      }
      actions.add(
        _BreedingAction(
          title: '${record.eventType} programmé',
          detail:
              '${record.animalType} ${record.animalCode} - ${record.product}',
          dueDate: record.nextDate!,
          priority: _priorityFromDueDate(record.nextDate!),
          color: const Color(0xFF15803D),
          icon: LucideIcons.shieldCheck,
        ),
      );
    }

    actions.sort((a, b) {
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) {
        return byDate;
      }
      return a.priority.index.compareTo(b.priority.index);
    });

    return actions.take(10).toList();
  }

  List<String> _buildExpertRecommendations({
    required int successRate,
    required int overdueDiagnosisCount,
    required int farrowingSoonCount,
    required int pendingCount,
  }) {
    final recommendations = <String>[];

    if (successRate < 75) {
      recommendations.add(
        'Renforcer la détection des chaleurs et vérifier la qualité semence '
        '(mobilité, température de conservation, délai post-collecte).',
      );
    } else {
      recommendations.add(
        'Maintenir le protocole IA actuel: le taux de réussite est satisfaisant.',
      );
    }

    if (overdueDiagnosisCount > 0) {
      recommendations.add(
        '$overdueDiagnosisCount diagnostic(s) de gestation sont en retard: '
        'programmer échographie/contrôle cette semaine.',
      );
    }

    if (pendingCount > 0) {
      recommendations.add(
        '$pendingCount dossier(s) IA en attente: verrouiller un planning J21/J28/J35 '
        'pour éviter les pertes de suivi.',
      );
    }

    if (farrowingSoonCount > 0) {
      recommendations.add(
        '$farrowingSoonCount mise(s)-bas attendue(s) sous 14 jours: préparer cases '
        'maternité, matériel néonatal et protocole colostrum.',
      );
    }

    if (_healthRecords.where((record) => record.nextDate != null).isEmpty) {
      recommendations.add(
        'Aucun rappel santé programmé: planifier les protocoles vaccin/vermifuge '
        'par lot pour sécuriser les performances de reproduction.',
      );
    }

    if (recommendations.length < 3) {
      recommendations.add(
        'Suivre la parité des truies et réformer progressivement les animaux '
        'à faible performance reproductive.',
      );
    }

    return recommendations;
  }

  _InseminationActionInfo _nextInseminationActionInfo(
    InseminationRecord record,
  ) {
    final now = _currentDate();

    if (_isFailedStatus(record.status)) {
      return const _InseminationActionInfo(
        label: 'Replanifier IA',
        color: Color(0xFFB91C1C),
      );
    }

    if (_isSuccessfulStatus(record.status)) {
      final farrowingDate = _expectedFarrowingDate(record);
      final daysToFarrow = farrowingDate.difference(now).inDays;
      if (daysToFarrow < 0) {
        return const _InseminationActionInfo(
          label: 'Mise-bas dépassée',
          color: Color(0xFFB91C1C),
        );
      }
      if (daysToFarrow <= 14) {
        return const _InseminationActionInfo(
          label: 'Préparer maternité',
          color: Color(0xFF2563EB),
        );
      }
      return const _InseminationActionInfo(
        label: 'Suivi gestation',
        color: Color(0xFF15803D),
      );
    }

    final diagnosisDate = _expectedPregnancyCheckDate(record);
    if (diagnosisDate.isBefore(now)) {
      return const _InseminationActionInfo(
        label: 'Diagnostic en retard',
        color: Color(0xFFB91C1C),
      );
    }

    final heatReturnDate = _expectedHeatReturnDate(record);
    if (!heatReturnDate.isBefore(now)) {
      return const _InseminationActionInfo(
        label: 'Surveillance chaleur J21',
        color: Color(0xFFB45309),
      );
    }

    return const _InseminationActionInfo(
      label: 'Diagnostic gestation J28',
      color: Color(0xFF0F766E),
    );
  }

  bool _isSuccessfulStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized.contains('gestant') ||
        normalized.contains('réussi') ||
        normalized.contains('reussi') ||
        normalized.contains('succès') ||
        normalized.contains('succes');
  }

  bool _isFailedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized.contains('échec') ||
        normalized.contains('echec') ||
        normalized.contains('non réussi') ||
        normalized.contains('non reussi') ||
        normalized.contains('failed');
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  DateTime? _tryParseDate(String rawDate) {
    final value = rawDate.trim();
    if (value.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final normalized = value.replaceAll('/', '-').replaceAll('.', '-');
    final parts = normalized.split('-');
    if (parts.length != 3) {
      return null;
    }

    if (parts[0].length == 4) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      return _safeDate(year, month, day);
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    return _safeDate(year, month, day);
  }

  DateTime? _safeDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) {
      return null;
    }

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    return date;
  }

  double _dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 620 ? 540 : screenWidth * 0.9;
  }
}

class _OutcomeSegment {
  final double value;
  final Color color;

  const _OutcomeSegment({required this.value, required this.color});
}

class _OutcomeDonutPainter extends CustomPainter {
  final double total;
  final List<_OutcomeSegment> segments;

  const _OutcomeDonutPainter({required this.total, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.13;
    final radiusRect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - strokeWidth / 2,
    );

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE2E8F0);
    canvas.drawArc(radiusRect, 0, math.pi * 2, false, backgroundPaint);

    if (total <= 0) {
      return;
    }

    const gap = 0.055;
    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) {
        continue;
      }
      final sweep = (segment.value / total) * math.pi * 2;
      final adjustedSweep = math.max(0.0, sweep - gap);
      if (adjustedSweep <= 0) {
        startAngle += sweep;
        continue;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(radiusRect, startAngle, adjustedSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _OutcomeDonutPainter oldDelegate) {
    if (oldDelegate.total != total) {
      return true;
    }
    if (oldDelegate.segments.length != segments.length) {
      return true;
    }
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].value != segments[i].value ||
          oldDelegate.segments[i].color != segments[i].color) {
        return true;
      }
    }
    return false;
  }
}

class _BreederAnimalStat {
  final String breederId;
  final String breederName;
  final int boarCount;
  final int sowCount;

  const _BreederAnimalStat({
    required this.breederId,
    required this.breederName,
    required this.boarCount,
    required this.sowCount,
  });

  int get totalAnimals => boarCount + sowCount;
}

enum _ActionPriority { high, medium, low }

class _BreedingAction {
  final String title;
  final String detail;
  final DateTime dueDate;
  final _ActionPriority priority;
  final Color color;
  final IconData icon;

  const _BreedingAction({
    required this.title,
    required this.detail,
    required this.dueDate,
    required this.priority,
    required this.color,
    required this.icon,
  });
}

class _InseminationActionInfo {
  final String label;
  final Color color;

  const _InseminationActionInfo({required this.label, required this.color});
}

class _GestationCalendarEvent {
  final DateTime date;
  final String label;
  final String type;
  final Color color;
  final IconData icon;

  const _GestationCalendarEvent({
    required this.date,
    required this.label,
    required this.type,
    required this.color,
    required this.icon,
  });
}

class _ServiceOffer {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String cadence;
  final String deliverable;

  const _ServiceOffer({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.cadence,
    required this.deliverable,
  });
}

class _ServiceProtocol {
  final String title;
  final String window;
  final String detail;
  final bool critical;

  const _ServiceProtocol({
    required this.title,
    required this.window,
    required this.detail,
    required this.critical,
  });
}

class _ServiceBenchmark {
  final String label;
  final double currentValue;
  final double targetValue;
  final String unit;
  final Color color;

  const _ServiceBenchmark({
    required this.label,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.color,
  });
}

class _BiosecurityItem {
  final String title;
  final String detail;
  final bool ok;

  const _BiosecurityItem({
    required this.title,
    required this.detail,
    required this.ok,
  });
}
