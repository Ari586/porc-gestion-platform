import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _defaultFirebaseApiKey = 'AIzaSyAJhP6o3q9VVSdNjAdCoulSn4qBZfnvdMk';
const String _defaultFirebaseAppId =
    '1:868440634699:web:74450072a14a613bafa4ce';
const String _defaultFirebaseProjectId = 'porc-gestion-platform';
const String _defaultFirebaseMessagingSenderId = '868440634699';
const String _defaultFirebaseAuthDomain =
    'porc-gestion-platform.firebaseapp.com';
const String _defaultFirebaseStorageBucket =
    'porc-gestion-platform.firebasestorage.app';

class AppSpacing {
  static const double zero = 0;
  static const double s1 = 1;
  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s5 = 5;
  static const double s6 = 6;
  static const double s7 = 7;
  static const double s8 = 8;
  static const double s9 = 9;
  static const double s10 = 10;
  static const double s11 = 11;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s58 = 58;
  static const double s72 = 72;

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  static const double xxxl = 22;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeRealtimeBackend();
  await initializeDateFormatting('fr_FR', null);
  runApp(const PigBreedingApp());
}

Future<void> _initializeRealtimeBackend() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    final options = _firebaseOptionsFromEnvironment();
    if (options == null) {
      await Firebase.initializeApp();
      return;
    }
    await Firebase.initializeApp(options: options);
  } catch (_) {
    // Keep local mode available if Firebase is not configured.
  }
}

FirebaseOptions? _firebaseOptionsFromEnvironment() {
  const apiKeyFromEnv = String.fromEnvironment('FIREBASE_API_KEY');
  const appIdFromEnv = String.fromEnvironment('FIREBASE_APP_ID');
  const projectIdFromEnv = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const messagingSenderIdFromEnv = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  final apiKey = apiKeyFromEnv.trim().isEmpty
      ? _defaultFirebaseApiKey
      : apiKeyFromEnv.trim();
  final appId = appIdFromEnv.trim().isEmpty
      ? _defaultFirebaseAppId
      : appIdFromEnv.trim();
  final projectId = projectIdFromEnv.trim().isEmpty
      ? _defaultFirebaseProjectId
      : projectIdFromEnv.trim();
  final messagingSenderId = messagingSenderIdFromEnv.trim().isEmpty
      ? _defaultFirebaseMessagingSenderId
      : messagingSenderIdFromEnv.trim();

  if (apiKey.isEmpty ||
      appId.isEmpty ||
      projectId.isEmpty ||
      messagingSenderId.isEmpty) {
    return null;
  }

  const authDomainFromEnv = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  const storageBucketFromEnv = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  const iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  const androidClientId = String.fromEnvironment('FIREBASE_ANDROID_CLIENT_ID');
  const iosClientId = String.fromEnvironment('FIREBASE_IOS_CLIENT_ID');
  const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');
  const databaseURL = String.fromEnvironment('FIREBASE_DATABASE_URL');
  final authDomain = authDomainFromEnv.trim().isEmpty
      ? _defaultFirebaseAuthDomain
      : authDomainFromEnv.trim();
  final storageBucket = storageBucketFromEnv.trim().isEmpty
      ? _defaultFirebaseStorageBucket
      : storageBucketFromEnv.trim();

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    projectId: projectId,
    messagingSenderId: messagingSenderId,
    authDomain: authDomain.isEmpty ? null : authDomain,
    storageBucket: storageBucket.isEmpty ? null : storageBucket,
    iosBundleId: iosBundleId.isEmpty ? null : iosBundleId,
    androidClientId: androidClientId.isEmpty ? null : androidClientId,
    iosClientId: iosClientId.isEmpty ? null : iosClientId,
    measurementId: measurementId.isEmpty ? null : measurementId,
    databaseURL: databaseURL.isEmpty ? null : databaseURL,
  );
}

class PigBreedingApp extends StatelessWidget {
  const PigBreedingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PigIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF0F766E),
          surface: const Color(0xFFF1F5F9),
          surfaceContainerHighest: const Color(0xFFE2E8F0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
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
  static const String profile = 'profile';
  static const String actualites = 'actualites';
  static const String administration = 'administration';
  static const String messenger = 'messenger';
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
  final String address;
  final String contact;
  final String fokontany;
  final String commune;
  final String district;
  final String region;
  final String bio;
  final String profileImageBase64;
  final String coverImageBase64;
  final String login;
  final String password;

  const UserProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.role,
    required this.avatar,
    this.address = '',
    this.contact = '',
    this.fokontany = '',
    this.commune = '',
    this.district = '',
    this.region = '',
    this.bio = '',
    this.profileImageBase64 = '',
    this.coverImageBase64 = '',
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
  final String imageBase64;

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
    this.imageBase64 = '',
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

class AnimalSaleListing {
  final String id;
  final String category;
  final String animalCode;
  final String animalName;
  final String breed;
  final int quantity;
  final double unitPrice;
  final double weightKg;
  final DateTime publishedDate;
  final String sellerId;
  final String sellerName;
  final String contact;
  final String location;
  final String status;
  final bool isPublished;
  final String description;
  final String imageBase64;

  const AnimalSaleListing({
    required this.id,
    required this.category,
    required this.animalCode,
    required this.animalName,
    required this.breed,
    required this.quantity,
    required this.unitPrice,
    this.weightKg = 0,
    required this.publishedDate,
    required this.sellerId,
    required this.sellerName,
    required this.contact,
    required this.location,
    this.status = 'Disponible',
    this.isPublished = true,
    this.description = '',
    this.imageBase64 = '',
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

class PigletCareRecord {
  final String id;
  final String animalCode;
  final String groupName;
  final DateTime eventDate;
  final String eventType;
  final String details;
  final String responsible;
  final DateTime? nextDate;

  const PigletCareRecord({
    required this.id,
    required this.animalCode,
    required this.groupName,
    required this.eventDate,
    required this.eventType,
    required this.details,
    required this.responsible,
    this.nextDate,
  });
}

class FarrowingRecord {
  final String id;
  final String sowCode;
  final DateTime farrowingDate;
  final int totalBorn;
  final int bornAlive;
  final int stillborn;
  final int mummified;
  final int weaned;
  final int preWeaningDeaths;
  final double avgBirthWeight;
  final String majorIssue;
  final String responsible;
  final String notes;

  const FarrowingRecord({
    required this.id,
    required this.sowCode,
    required this.farrowingDate,
    required this.totalBorn,
    required this.bornAlive,
    required this.stillborn,
    required this.mummified,
    required this.weaned,
    required this.preWeaningDeaths,
    required this.avgBirthWeight,
    this.majorIssue = '',
    required this.responsible,
    this.notes = '',
  });
}

class SemenQualityRecord {
  final String id;
  final String lotCode;
  final String boarCode;
  final DateTime collectionDate;
  final double concentration;
  final double motilityPercent;
  final double temperatureC;
  final int storageHours;
  final String approvedBy;
  final String notes;

  const SemenQualityRecord({
    required this.id,
    required this.lotCode,
    required this.boarCode,
    required this.collectionDate,
    required this.concentration,
    required this.motilityPercent,
    required this.temperatureC,
    required this.storageHours,
    required this.approvedBy,
    this.notes = '',
  });
}

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String actorCode;
  final String actorName;
  final String module;
  final String action;
  final String detail;
  final String severity;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.actorCode,
    required this.actorName,
    required this.module,
    required this.action,
    required this.detail,
    required this.severity,
  });
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final List<String> readByUserIds;
  final String messageType;
  final String mediaBase64;
  final String mediaName;
  final String mediaMimeType;
  final int mediaSizeBytes;
  final String callType;
  final String callStatus;
  final int callDurationSeconds;
  final String callSessionId;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.readByUserIds = const [],
    this.messageType = 'text',
    this.mediaBase64 = '',
    this.mediaName = '',
    this.mediaMimeType = '',
    this.mediaSizeBytes = 0,
    this.callType = '',
    this.callStatus = '',
    this.callDurationSeconds = 0,
    this.callSessionId = '',
  });

  ChatMessage copyWith({List<String>? readByUserIds}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: sentAt,
      readByUserIds: readByUserIds ?? this.readByUserIds,
      messageType: messageType,
      mediaBase64: mediaBase64,
      mediaName: mediaName,
      mediaMimeType: mediaMimeType,
      mediaSizeBytes: mediaSizeBytes,
      callType: callType,
      callStatus: callStatus,
      callDurationSeconds: callDurationSeconds,
      callSessionId: callSessionId,
    );
  }
}

class NewsComment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const NewsComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });
}

class NewsPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime createdAt;
  final String imageBase64;
  final String imageName;
  final List<String> likedByUserIds;
  final List<NewsComment> comments;

  const NewsPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.createdAt,
    this.imageBase64 = '',
    this.imageName = '',
    this.likedByUserIds = const [],
    this.comments = const [],
  });
}

const List<UserProfile> initialUsers = [
  UserProfile(
    id: 'U1',
    code: 'ADM-01',
    name: 'Jean Responsable',
    role: Roles.admin,
    avatar: 'J',
    address: 'Lot A12 Antananarivo',
    contact: '+261 34 00 01 000',
    fokontany: 'Antanetibe',
    commune: 'Antananarivo',
    district: 'Antananarivo I',
    region: 'Analamanga',
    login: 'admin',
    password: 'Admin@2026',
  ),
  UserProfile(
    id: 'U2',
    code: 'ELV-01',
    name: 'Marc Éleveur',
    role: Roles.breeder,
    avatar: 'M',
    address: 'Ferme Andoharanofotsy',
    contact: '+261 34 00 01 002',
    fokontany: 'Ambohimanarina',
    commune: 'Andoharanofotsy',
    district: 'Antananarivo Atsimondrano',
    region: 'Analamanga',
    login: 'eleveur',
    password: 'Elevage@2026',
  ),
  UserProfile(
    id: 'U3',
    code: 'INS-01',
    name: 'Paul Insem',
    role: Roles.inseminator,
    avatar: 'P',
    address: 'Zone rurale Itaosy',
    contact: '+261 34 00 01 003',
    fokontany: 'Itaosy Avaratra',
    commune: 'Itaosy',
    district: 'Antananarivo Atsimondrano',
    region: 'Analamanga',
    login: 'insemination',
    password: 'Insem@2026',
  ),
  UserProfile(
    id: 'U4',
    code: 'VET-01',
    name: 'Lucie Véto',
    role: Roles.vet,
    avatar: 'L',
    address: 'Clinique Vet Ambatobe',
    contact: '+261 34 00 01 004',
    fokontany: 'Ambatobe',
    commune: 'Antananarivo',
    district: 'Antananarivo II',
    region: 'Analamanga',
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
  static const Color _surfaceSlate = Color(0xFFF1F5F9);
  static const Color _accentTeal = Color(0xFF0D9488);
  static const Color _accentTealDeep = Color(0xFF0F766E);
  static const Color _sidebarDark = Color(0xFF0B1220);
  static const Color _sidebarDarkSoft = Color(0xFF111C33);
  static const Color _newsCanvasTop = Color(0xFFFFF4E8);
  static const Color _newsCanvasBottom = Color(0xFFE8F4FF);
  static const Color _newsCardSurface = Color(0xFFFFFCF7);
  static const Color _newsCardBorder = Color(0xFFEAD8C5);
  static const Color _newsHeaderGradientStart = Color(0xFFB45309);
  static const Color _newsHeaderGradientEnd = Color(0xFF0F766E);
  static const Color _newsMutedText = Color(0xFF5B6475);
  static const Color _durocChatHeader = Color(0xFF6B4B3E);
  static const Color _durocChatHeaderSoft = Color(0xFF8A6450);
  static const Color _durocChatOutgoingBubble = Color(0xFFD9F3C3);
  static const Color _durocChatIncomingBubble = Color(0xFFFFFBF8);
  static const Color _durocChatBackgroundTop = Color(0xFFF9F2EC);
  static const Color _durocChatBackgroundBottom = Color(0xFFF3E8DF);
  static const Color _durocChatInputSurface = Color(0xFFF7EFE8);
  static const String _passwordHashPrefix = 'sha256:';
  static const int _maxSessionHours = 12;
  static const String _teamConversationId = 'GROUP_ALL_USERS';
  static const int _chatImageMaxBytes = 320 * 1024;
  static const int _chatAudioMaxBytes = 600 * 1024;
  static const int _chatVideoMaxBytes = 900 * 1024;
  static const String _brandLogoAsset = 'assets/branding/pigia_logo.jpg';
  static const String _prefsUsersKey = 'porc_users_v1';
  static const String _prefsBoarsKey = 'porc_boars_v1';
  static const String _prefsSowsKey = 'porc_sows_v1';
  static const String _prefsInseminationsKey = 'porc_inseminations_v1';
  static const String _prefsHealthKey = 'porc_health_v1';
  static const String _prefsClientsKey = 'porc_clients_v1';
  static const String _prefsSuppliersKey = 'porc_suppliers_v1';
  static const String _prefsSalesKey = 'porc_sales_v1';
  static const String _prefsAnimalSaleListingsKey =
      'porc_animal_sale_listings_v1';
  static const String _prefsSuppliesKey = 'porc_supplies_v1';
  static const String _prefsBuildingsKey = 'porc_buildings_v1';
  static const String _prefsBatchesKey = 'porc_batches_v1';
  static const String _prefsGrowthKey = 'porc_growth_v1';
  static const String _prefsPigletCareKey = 'porc_piglet_care_v1';
  static const String _prefsFarrowingKey = 'porc_farrowing_v1';
  static const String _prefsSemenQualityKey = 'porc_semen_quality_v1';
  static const String _prefsAuditLogsKey = 'porc_audit_logs_v1';
  static const String _prefsTaskDoneKey = 'porc_task_done_v1';
  static const String _prefsPreferredBoarCodeKey = 'porc_preferred_boar_v1';
  static const String _prefsCurrentUserIdKey = 'porc_current_user_v1';
  static const String _prefsSalesFilterKey = 'porc_sales_filter_v1';
  static const String _prefsActiveTabKey = 'porc_active_tab_v1';
  static const String _prefsAuthenticatedKey = 'porc_authenticated_v1';
  static const String _prefsLastAuthAtKey = 'porc_last_auth_at_v1';
  static const String _prefsGestationMonthKey = 'porc_gestation_month_v1';
  static const String _prefsSelectedGestationDateKey =
      'porc_gestation_selected_date_v1';
  static const String _prefsPigletMonthKey = 'porc_piglet_month_v1';
  static const String _prefsSelectedPigletDateKey =
      'porc_piglet_selected_date_v1';
  static const String _prefsChatMessagesKey = 'porc_chat_messages_v1';
  static const String _prefsNewsPostsKey = 'porc_news_posts_v1';
  static const String _prefsActiveConversationKey =
      'porc_active_conversation_v1';
  static const String _cloudSyncCollection = 'porc_realtime_sync';
  static const String _cloudSyncDocumentId = 'chat_news_v1';
  static const int _cloudChatSyncLimit = 180;
  static const int _cloudNewsSyncLimit = 80;
  static const int _cloudInlineMediaBase64MaxLength = 48000;
  static const int _incomingCallMaxAgeMinutes = 2;
  static const String _callRingingStatus = 'En sonnerie';
  static const String _callAcceptedStatus = 'Accepté';
  static const String _callRejectedStatus = 'Refusé';
  static const List<String> _newsFeedFilters = [
    'Tous',
    'Élevage',
    'IA',
    'Santé',
    'Vente',
    'Photos',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _chatComposerController = TextEditingController();
  final TextEditingController _messengerSearchController =
      TextEditingController();
  final TextEditingController _headerSearchController = TextEditingController();
  final List<UserProfile> _users = List<UserProfile>.from(initialUsers);

  UserProfile _currentUser = initialUsers.first;
  String _activeTab = AppTabs.dashboard;
  bool _isAuthenticated = false;
  bool _hidePassword = true;
  String? _authError;
  DateTime? _lastAuthAt;
  DateTime _gestationCalendarMonth = DateTime.now();
  DateTime? _selectedGestationDate;
  DateTime _pigletCalendarMonth = DateTime.now();
  DateTime? _selectedPigletDate;
  String? _preferredBoarCode;
  String? _selectedPedigreeAnimalCode;
  String _activeChatConversationId = _teamConversationId;
  bool _isMobileMessengerThreadOpen = false;
  String _messengerConversationFilter = '';
  String _newsFeedFilter = 'Tous';
  bool _chatReadSyncScheduled = false;
  final Map<String, bool> _taskDoneById = <String, bool>{};
  final Map<String, Uint8List> _imageBytesCache = <String, Uint8List>{};
  final List<AuditLogEntry> _auditLogs = [];
  int _failedLoginAttempts = 0;
  DateTime? _loginLockedUntil;
  bool _stateLoading = true;
  final String _cloudClientId =
      'CLIENT-${DateTime.now().microsecondsSinceEpoch}';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _cloudSyncSubscription;
  Timer? _cloudSyncDebounceTimer;
  int _lastCloudVersionSeen = 0;
  bool _cloudSyncActive = false;
  bool _cloudApplyingSnapshot = false;
  _IncomingCallOffer? _incomingCallOffer;
  Timer? _incomingCallRingtoneTimer;

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

  final List<AnimalSaleListing> _animalSaleListings = [
    AnimalSaleListing(
      id: 'ASL1',
      category: 'Verrat',
      animalCode: 'VR-1001',
      animalName: 'Atlas',
      breed: 'Large White',
      quantity: 1,
      unitPrice: 2800000,
      weightKg: 185,
      publishedDate: DateTime.now().subtract(const Duration(days: 2)),
      sellerId: 'U2',
      sellerName: 'Marc Éleveur',
      contact: '+261 34 00 01 002',
      location: 'Andoharanofotsy / Analamanga',
      status: 'Disponible',
      isPublished: true,
      description:
          'Verrat confirmé en station, bonne qualité semence et pedigree renseigné.',
    ),
    AnimalSaleListing(
      id: 'ASL2',
      category: 'Porcelets',
      animalCode: 'LOT-PORC-27',
      animalName: 'Lot porcelets sevrés',
      breed: 'Croisé LW x LR',
      quantity: 18,
      unitPrice: 160000,
      weightKg: 8.6,
      publishedDate: DateTime.now().subtract(const Duration(days: 1)),
      sellerId: 'U2',
      sellerName: 'Marc Éleveur',
      contact: '+261 34 00 01 002',
      location: 'Itaosy / Analamanga',
      status: 'Disponible',
      isPublished: true,
      description:
          'Porcelets vaccinés et sevrés, disponibles pour engraissement.',
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

  final List<BuildingRecord> _buildings = [
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

  final List<PigletCareRecord> _pigletCareRecords = [
    PigletCareRecord(
      id: 'PC1',
      animalCode: 'TR-2001',
      groupName: 'Portée Nova',
      eventDate: DateTime.now().subtract(const Duration(days: 1)),
      eventType: 'Colostrum',
      details: 'Contrôle prise colostrum des porcelets',
      responsible: 'Marc Éleveur',
      nextDate: DateTime.now().add(const Duration(days: 2)),
    ),
    PigletCareRecord(
      id: 'PC2',
      animalCode: 'TR-2002',
      groupName: 'Portée Luna',
      eventDate: DateTime.now().add(const Duration(days: 4)),
      eventType: 'Supplémentation fer',
      details: 'Injection fer porcelets J3',
      responsible: 'Marc Éleveur',
    ),
  ];

  final List<FarrowingRecord> _farrowingRecords = [
    FarrowingRecord(
      id: 'FAR1',
      sowCode: 'TR-2001',
      farrowingDate: DateTime.now().subtract(const Duration(days: 18)),
      totalBorn: 14,
      bornAlive: 12,
      stillborn: 1,
      mummified: 1,
      weaned: 11,
      preWeaningDeaths: 1,
      avgBirthWeight: 1.42,
      majorIssue: 'Léger écrasement J2',
      responsible: 'Marc Éleveur',
    ),
    FarrowingRecord(
      id: 'FAR2',
      sowCode: 'TR-2002',
      farrowingDate: DateTime.now().subtract(const Duration(days: 39)),
      totalBorn: 13,
      bornAlive: 11,
      stillborn: 2,
      mummified: 0,
      weaned: 10,
      preWeaningDeaths: 1,
      avgBirthWeight: 1.36,
      responsible: 'Marc Éleveur',
    ),
  ];

  final List<SemenQualityRecord> _semenQualityRecords = [
    SemenQualityRecord(
      id: 'SQ1',
      lotCode: 'LOT-IA-2405',
      boarCode: 'VR-1001',
      collectionDate: DateTime.now().subtract(const Duration(days: 9)),
      concentration: 2.9,
      motilityPercent: 82,
      temperatureC: 16.5,
      storageHours: 24,
      approvedBy: 'Lucie Véto',
      notes: 'Conforme protocole',
    ),
    SemenQualityRecord(
      id: 'SQ2',
      lotCode: 'LOT-IA-2406',
      boarCode: 'VR-1002',
      collectionDate: DateTime.now().subtract(const Duration(days: 4)),
      concentration: 2.4,
      motilityPercent: 69,
      temperatureC: 18.7,
      storageHours: 36,
      approvedBy: 'Lucie Véto',
      notes: 'Surveillance renforcée',
    ),
  ];

  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: 'MSG1',
      conversationId: _teamConversationId,
      senderId: 'U1',
      senderName: 'Jean Responsable',
      text:
          'Bienvenue sur la messagerie interne. Utilisez ce canal pour les infos urgentes de terrain.',
      sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
      readByUserIds: ['U1', 'U2', 'U3', 'U4'],
    ),
    ChatMessage(
      id: 'MSG2',
      conversationId: _teamConversationId,
      senderId: 'U3',
      senderName: 'Paul Insem',
      text:
          'Tournée IA demain matin: Fokontany Antanetibe puis Commune Antananarivo.',
      sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      readByUserIds: ['U1', 'U3'],
    ),
    ChatMessage(
      id: 'MSG3',
      conversationId: 'DM|U1|U4',
      senderId: 'U4',
      senderName: 'Lucie Véto',
      text:
          'Merci de valider le ravitaillement vaccins avant vendredi pour la prophylaxie.',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 35)),
      readByUserIds: ['U1', 'U4'],
    ),
  ];

  final List<NewsPost> _newsPosts = [
    NewsPost(
      id: 'POST1',
      authorId: 'U2',
      authorName: 'Marc Éleveur',
      authorRole: Roles.breeder,
      text:
          'Mise-bas réussie sur TR-2001 ce matin: 12 nés vivants. Protocole colostrum lancé immédiatement.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6, minutes: 20)),
      likedByUserIds: ['U1', 'U3'],
      comments: [
        NewsComment(
          id: 'COM1',
          authorId: 'U4',
          authorName: 'Lucie Véto',
          text: 'Parfait. Faites bien le suivi température sur les 48h.',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 5, minutes: 50),
          ),
        ),
      ],
    ),
    NewsPost(
      id: 'POST2',
      authorId: 'U3',
      authorName: 'Paul Insem',
      authorRole: Roles.inseminator,
      text:
          'Tournée IA confirmée demain: Fokontany Antanetibe -> Commune Itaosy. Merci de préparer les truies identifiées.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
      likedByUserIds: ['U1'],
      comments: [],
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
    final isMobile = screenWidth < 760;
    final isMessengerMobileFullBleed =
        isMobile && _activeTab == AppTabs.messenger;
    final contentPadding = isMobile
        ? (isMessengerMobileFullBleed ? AppSpacing.zero : AppSpacing.s10)
        : (screenWidth > 720 ? AppSpacing.s24 : AppSpacing.s12);
    final showExtendedFab = screenWidth >= 520;
    final desktopMaxContentWidth = screenWidth >= 1700
        ? 1560.0
        : (screenWidth >= 1320 ? 1440.0 : 1320.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : SizedBox(
              width: math.min(340, screenWidth * 0.9),
              child: Drawer(child: _buildSidebar()),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) SizedBox(width: 280, child: _buildSidebar()),
            Expanded(
              child: Column(
                children: [
                  if (!isMessengerMobileFullBleed) _buildHeader(isDesktop),
                  if (!isMessengerMobileFullBleed && _incomingCallOffer != null)
                    _buildIncomingCallBanner(),
                  Expanded(
                    child: isMessengerMobileFullBleed
                        ? _buildActiveContent()
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(contentPadding),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final slide =
                                    Tween<Offset>(
                                      begin: const Offset(0.025, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    );
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slide,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<String>(_activeTab),
                                child: isDesktop
                                    ? Align(
                                        alignment: Alignment.topCenter,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: desktopMaxContentWidth,
                                          ),
                                          child: _buildActiveContent(),
                                        ),
                                      )
                                    : _buildActiveContent(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: isMobile
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: _canAddForTab(_activeTab)
          ? (showExtendedFab
                ? FloatingActionButton.extended(
                    onPressed: _openAddDialogForTab,
                    icon: Icon(_fabIconForTab(_activeTab)),
                    label: Text(_fabLabelForTab(_activeTab)),
                    elevation: 10,
                    extendedPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s18,
                      vertical: AppSpacing.s2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: _accentTealDeep,
                    foregroundColor: Colors.white,
                  )
                : FloatingActionButton(
                    onPressed: _openAddDialogForTab,
                    elevation: 10,
                    backgroundColor: _accentTealDeep,
                    foregroundColor: Colors.white,
                    child: Icon(_fabIconForTab(_activeTab)),
                  ))
          : null,
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _chatComposerController.dispose();
    _messengerSearchController.dispose();
    _headerSearchController.dispose();
    _cloudSyncDebounceTimer?.cancel();
    _cloudSyncSubscription?.cancel();
    _stopIncomingCallRingtone();
    _imageBytesCache.clear();
    super.dispose();
  }

  void _initializeDefaultState() {
    if (_users.isNotEmpty) {
      _currentUser = _users.first;
    }
    _migrateLegacyPasswords();
    if (_boars.isNotEmpty) {
      _preferredBoarCode = _boars.first.code;
    }
    _selectedPedigreeAnimalCode = _resolveSelectedPedigreeCode(
      _selectedPedigreeAnimalCode,
      _allPedigreeNodes(),
    );
    final today = _currentDate();
    _gestationCalendarMonth = DateTime(today.year, today.month, 1);
    _selectedGestationDate = today;
    _pigletCalendarMonth = DateTime(today.year, today.month, 1);
    _selectedPigletDate = today;
    _activeChatConversationId = _teamConversationId;
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
      final animalSaleListingsRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsAnimalSaleListingsKey),
      );
      final suppliesRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsSuppliesKey),
      );
      final buildingsRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsBuildingsKey),
      );
      final batchesRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsBatchesKey),
      );
      final growthRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsGrowthKey),
      );
      final pigletCareRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsPigletCareKey),
      );
      final farrowingRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsFarrowingKey),
      );
      final semenQualityRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsSemenQualityKey),
      );
      final auditRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsAuditLogsKey),
      );
      final chatRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsChatMessagesKey),
      );
      final newsPostsRaw = _decodeObjectListOrNull(
        prefs.getString(_prefsNewsPostsKey),
      );
      final taskDoneRaw = _decodeObjectMapOrNull(
        prefs.getString(_prefsTaskDoneKey),
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

        if (animalSaleListingsRaw != null) {
          _animalSaleListings
            ..clear()
            ..addAll(
              animalSaleListingsRaw
                  .map(_animalSaleListingFromJson)
                  .whereType<AnimalSaleListing>(),
            );
        }

        if (suppliesRaw != null) {
          _supplyRecords
            ..clear()
            ..addAll(
              suppliesRaw.map(_supplyFromJson).whereType<SupplyRecord>(),
            );
        }

        if (buildingsRaw != null) {
          _buildings
            ..clear()
            ..addAll(
              buildingsRaw.map(_buildingFromJson).whereType<BuildingRecord>(),
            );
        }

        if (batchesRaw != null) {
          _batchRecords
            ..clear()
            ..addAll(batchesRaw.map(_batchFromJson).whereType<BatchRecord>());
        }

        if (growthRaw != null) {
          _growthRecords
            ..clear()
            ..addAll(growthRaw.map(_growthFromJson).whereType<GrowthRecord>());
        }

        if (pigletCareRaw != null) {
          _pigletCareRecords
            ..clear()
            ..addAll(
              pigletCareRaw
                  .map(_pigletCareFromJson)
                  .whereType<PigletCareRecord>(),
            );
        }

        if (farrowingRaw != null) {
          _farrowingRecords
            ..clear()
            ..addAll(
              farrowingRaw.map(_farrowingFromJson).whereType<FarrowingRecord>(),
            );
        }

        if (semenQualityRaw != null) {
          _semenQualityRecords
            ..clear()
            ..addAll(
              semenQualityRaw
                  .map(_semenQualityFromJson)
                  .whereType<SemenQualityRecord>(),
            );
        }

        if (auditRaw != null) {
          _auditLogs
            ..clear()
            ..addAll(
              auditRaw.map(_auditLogFromJson).whereType<AuditLogEntry>(),
            );
        }

        if (chatRaw != null) {
          _chatMessages
            ..clear()
            ..addAll(
              chatRaw.map(_chatMessageFromJson).whereType<ChatMessage>(),
            );
        }

        if (newsPostsRaw != null) {
          _newsPosts
            ..clear()
            ..addAll(newsPostsRaw.map(_newsPostFromJson).whereType<NewsPost>());
        }

        if (taskDoneRaw != null) {
          _taskDoneById
            ..clear()
            ..addAll(
              taskDoneRaw.map(
                (key, value) =>
                    MapEntry(key, value.toString().toLowerCase() == 'true'),
              ),
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

        final savedPigletMonth = _parseDateFromString(
          prefs.getString(_prefsPigletMonthKey),
        );
        if (savedPigletMonth != null) {
          _pigletCalendarMonth = DateTime(
            savedPigletMonth.year,
            savedPigletMonth.month,
            1,
          );
        }

        final savedSelectedPigletDate = _parseDateFromString(
          prefs.getString(_prefsSelectedPigletDateKey),
        );
        if (savedSelectedPigletDate != null) {
          _selectedPigletDate = savedSelectedPigletDate;
        }

        _isAuthenticated = prefs.getBool(_prefsAuthenticatedKey) ?? false;
        _lastAuthAt = _parseDateTimeFromString(
          prefs.getString(_prefsLastAuthAtKey),
        );
        if (_isAuthenticated &&
            _lastAuthAt != null &&
            DateTime.now().difference(_lastAuthAt!).inHours >=
                _maxSessionHours) {
          _isAuthenticated = false;
          _authError =
              'Session expirée (plus de ${_maxSessionHours}h). Veuillez vous reconnecter.';
        }

        final savedTab = prefs.getString(_prefsActiveTabKey);
        if (savedTab != null && savedTab.trim().isNotEmpty) {
          _activeTab = savedTab;
        }
        final savedConversation = _readString(
          prefs.getString(_prefsActiveConversationKey),
        ).trim();
        if (savedConversation.isNotEmpty) {
          _activeChatConversationId = savedConversation;
        }
        _selectedPedigreeAnimalCode = _resolveSelectedPedigreeCode(
          _selectedPedigreeAnimalCode,
          _allPedigreeNodes(),
        );
        _ensureActiveTabAccess();

        _stateLoading = false;
      });
      _syncIncomingCallOffer();

      final migrated = _migrateLegacyPasswords();
      if (migrated) {
        _persistState();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _stateLoading = false);
    }
    _startCloudRealtimeSync();
  }

  Future<void> _persistState({bool pushCloud = true}) async {
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
        _prefsAnimalSaleListingsKey,
        jsonEncode(_animalSaleListings.map(_animalSaleListingToJson).toList()),
      );
      await prefs.setString(
        _prefsSuppliesKey,
        jsonEncode(_supplyRecords.map(_supplyToJson).toList()),
      );
      await prefs.setString(
        _prefsBuildingsKey,
        jsonEncode(_buildings.map(_buildingToJson).toList()),
      );
      await prefs.setString(
        _prefsBatchesKey,
        jsonEncode(_batchRecords.map(_batchToJson).toList()),
      );
      await prefs.setString(
        _prefsGrowthKey,
        jsonEncode(_growthRecords.map(_growthToJson).toList()),
      );
      await prefs.setString(
        _prefsPigletCareKey,
        jsonEncode(_pigletCareRecords.map(_pigletCareToJson).toList()),
      );
      await prefs.setString(
        _prefsFarrowingKey,
        jsonEncode(_farrowingRecords.map(_farrowingToJson).toList()),
      );
      await prefs.setString(
        _prefsSemenQualityKey,
        jsonEncode(_semenQualityRecords.map(_semenQualityToJson).toList()),
      );
      await prefs.setString(
        _prefsAuditLogsKey,
        jsonEncode(_auditLogs.map(_auditLogToJson).toList()),
      );
      await prefs.setString(
        _prefsChatMessagesKey,
        jsonEncode(_chatMessages.map(_chatMessageToJson).toList()),
      );
      await prefs.setString(
        _prefsNewsPostsKey,
        jsonEncode(_newsPosts.map(_newsPostToJson).toList()),
      );
      await prefs.setString(_prefsTaskDoneKey, jsonEncode(_taskDoneById));
      if (_preferredBoarCode == null || _preferredBoarCode!.trim().isEmpty) {
        await prefs.remove(_prefsPreferredBoarCodeKey);
      } else {
        await prefs.setString(_prefsPreferredBoarCodeKey, _preferredBoarCode!);
      }
      await prefs.setString(_prefsCurrentUserIdKey, _currentUser.id);
      await prefs.setString(_prefsSalesFilterKey, _salesFilter);
      await prefs.setString(_prefsActiveTabKey, _activeTab);
      await prefs.setString(
        _prefsActiveConversationKey,
        _activeChatConversationId,
      );
      await prefs.setBool(_prefsAuthenticatedKey, _isAuthenticated);
      if (_lastAuthAt == null) {
        await prefs.remove(_prefsLastAuthAtKey);
      } else {
        await prefs.setString(
          _prefsLastAuthAtKey,
          _lastAuthAt!.toIso8601String(),
        );
      }
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
      await prefs.setString(
        _prefsPigletMonthKey,
        _normalizeDate(_pigletCalendarMonth).toIso8601String(),
      );
      if (_selectedPigletDate == null) {
        await prefs.remove(_prefsSelectedPigletDateKey);
      } else {
        await prefs.setString(
          _prefsSelectedPigletDateKey,
          _normalizeDate(_selectedPigletDate!).toIso8601String(),
        );
      }
      if (pushCloud) {
        _scheduleCloudSyncPush();
      }
    } catch (_) {
      // Keep UI responsive even if local persistence fails.
    }
  }

  bool _isCloudSyncAvailable() {
    return Firebase.apps.isNotEmpty;
  }

  DocumentReference<Map<String, dynamic>> get _cloudSyncDocRef {
    return FirebaseFirestore.instance
        .collection(_cloudSyncCollection)
        .doc(_cloudSyncDocumentId);
  }

  Future<void> _startCloudRealtimeSync() async {
    if (!mounted || _cloudSyncActive || !_isCloudSyncAvailable()) {
      return;
    }
    try {
      final initialSnapshot = await _cloudSyncDocRef.get();
      _applyCloudSnapshot(initialSnapshot.data());
      _cloudSyncSubscription = _cloudSyncDocRef.snapshots().listen(
        (snapshot) {
          _applyCloudSnapshot(snapshot.data());
        },
        onError: (_) {
          // Keep local mode if realtime stream fails.
        },
      );
      _cloudSyncActive = true;
      _scheduleCloudSyncPush();
    } catch (_) {
      _cloudSyncActive = false;
    }
  }

  void _scheduleCloudSyncPush() {
    if (!mounted ||
        !_cloudSyncActive ||
        !_isCloudSyncAvailable() ||
        _cloudApplyingSnapshot ||
        _stateLoading) {
      return;
    }
    _cloudSyncDebounceTimer?.cancel();
    _cloudSyncDebounceTimer = Timer(const Duration(milliseconds: 900), () {
      _pushCloudSnapshotNow();
    });
  }

  Future<void> _pushCloudSnapshotNow() async {
    if (!mounted ||
        !_cloudSyncActive ||
        !_isCloudSyncAvailable() ||
        _cloudApplyingSnapshot ||
        _stateLoading) {
      return;
    }

    final version = DateTime.now().millisecondsSinceEpoch;
    final payload = <String, dynamic>{
      'version': version,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtMsClient': version,
      'updatedByUserId': _currentUser.id,
      'updatedByClientId': _cloudClientId,
      'chatMessages': _buildCloudChatPayload(),
      'newsPosts': _buildCloudNewsPayload(),
    };

    try {
      await _cloudSyncDocRef.set(payload, SetOptions(merge: true));
      _lastCloudVersionSeen = math.max(_lastCloudVersionSeen, version);
    } catch (_) {
      // Keep app usable offline or when backend is unavailable.
    }
  }

  void _applyCloudSnapshot(Map<String, dynamic>? data) {
    if (!mounted || data == null || data.isEmpty) {
      return;
    }

    var remoteVersion = _readInt(data['version']);
    if (remoteVersion <= 0) {
      remoteVersion = _readInt(data['updatedAtMsClient']);
    }
    if (remoteVersion <= 0) {
      final rawUpdatedAt = data['updatedAt'];
      if (rawUpdatedAt is Timestamp) {
        remoteVersion = rawUpdatedAt.millisecondsSinceEpoch;
      } else {
        final parsed = _parseDateTimeFromString(_readString(rawUpdatedAt));
        remoteVersion = parsed?.millisecondsSinceEpoch ?? 0;
      }
    }
    if (remoteVersion <= _lastCloudVersionSeen) {
      return;
    }

    final hasChat = data.containsKey('chatMessages');
    final hasNews = data.containsKey('newsPosts');
    if (!hasChat && !hasNews) {
      _lastCloudVersionSeen = remoteVersion;
      return;
    }

    final remoteChat = hasChat
        ? _readObjectMapList(
            data['chatMessages'],
          ).map(_chatMessageFromJson).whereType<ChatMessage>().toList()
        : const <ChatMessage>[];
    final remoteNews = hasNews
        ? _readObjectMapList(
            data['newsPosts'],
          ).map(_newsPostFromJson).whereType<NewsPost>().toList()
        : const <NewsPost>[];

    final sortedChat = List<ChatMessage>.from(remoteChat)
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final sortedNews = List<NewsPost>.from(remoteNews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (sortedChat.length > 2500) {
      sortedChat.removeRange(0, sortedChat.length - 2500);
    }
    if (sortedNews.length > 400) {
      sortedNews.removeRange(400, sortedNews.length);
    }

    _cloudApplyingSnapshot = true;
    setState(() {
      if (hasChat) {
        _chatMessages
          ..clear()
          ..addAll(sortedChat);
      }
      if (hasNews) {
        _newsPosts
          ..clear()
          ..addAll(sortedNews);
      }
      _lastCloudVersionSeen = remoteVersion;
    });
    _cloudApplyingSnapshot = false;
    _syncIncomingCallOffer();
    _persistState(pushCloud: false);
  }

  List<Map<String, dynamic>> _readObjectMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final items = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map) {
        items.add(Map<String, dynamic>.from(item));
      }
    }
    return items;
  }

  List<Map<String, dynamic>> _buildCloudChatPayload() {
    final sorted = List<ChatMessage>.from(_chatMessages)
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final fromIndex = math.max(0, sorted.length - _cloudChatSyncLimit);
    final limited = sorted.sublist(fromIndex);
    return limited.map(_chatMessageToCloudJson).toList();
  }

  Map<String, dynamic> _chatMessageToCloudJson(ChatMessage message) {
    return {
      'id': message.id,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'text': message.text,
      'sentAt': message.sentAt.toIso8601String(),
      'readByUserIds': message.readByUserIds,
      'messageType': message.messageType,
      'mediaBase64': _cloudTrimBase64(message.mediaBase64),
      'mediaName': message.mediaName,
      'mediaMimeType': message.mediaMimeType,
      'mediaSizeBytes': message.mediaSizeBytes,
      'callType': message.callType,
      'callStatus': message.callStatus,
      'callDurationSeconds': message.callDurationSeconds,
      'callSessionId': message.callSessionId,
    };
  }

  List<Map<String, dynamic>> _buildCloudNewsPayload() {
    final sorted = List<NewsPost>.from(_newsPosts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limited = sorted.take(_cloudNewsSyncLimit).toList();
    return limited.map(_newsPostToCloudJson).toList();
  }

  Map<String, dynamic> _newsPostToCloudJson(NewsPost post) {
    return {
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'text': post.text,
      'createdAt': post.createdAt.toIso8601String(),
      'imageBase64': _cloudTrimBase64(post.imageBase64),
      'imageName': post.imageName,
      'likedByUserIds': post.likedByUserIds,
      'comments': post.comments.take(40).map(_newsCommentToJson).toList(),
    };
  }

  String _cloudTrimBase64(String raw) {
    final value = raw.trim();
    if (value.length > _cloudInlineMediaBase64MaxLength) {
      return '';
    }
    return value;
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

  Map<String, dynamic>? _decodeObjectMapOrNull(String? raw) {
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(decoded);
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

  List<String> _readStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final items = <String>[];
    for (final item in value) {
      final text = _readString(item).trim();
      if (text.isEmpty || items.contains(text)) {
        continue;
      }
      items.add(text);
    }
    return items;
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

  DateTime? _parseDateTimeFromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
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

  List<_PedigreeTreeNode> _allPedigreeNodes() {
    final nodesByCode = <String, _PedigreeTreeNode>{};

    for (final boar in _boars) {
      final node = _PedigreeTreeNode(
        code: boar.code,
        name: boar.name,
        type: 'Verrat',
        breed: boar.breed,
        birthDate: boar.birthDate,
        breederId: boar.breederId,
        sireCode: boar.sireCode,
        damCode: boar.damCode,
        origin: boar.origin,
      );
      nodesByCode[_normalizeLookup(boar.code)] = node;
    }

    for (final sow in _sows) {
      final key = _normalizeLookup(sow.code);
      if (nodesByCode.containsKey(key)) {
        continue;
      }
      nodesByCode[key] = _PedigreeTreeNode(
        code: sow.code,
        name: sow.name,
        type: 'Truie',
        breed: sow.breed,
        birthDate: sow.birthDate,
        breederId: sow.breederId,
        sireCode: sow.sireCode,
        damCode: sow.damCode,
        origin: '',
      );
    }

    final nodes = nodesByCode.values.toList()
      ..sort((a, b) {
        if (a.type != b.type) {
          return a.type == 'Verrat' ? -1 : 1;
        }
        return a.code.compareTo(b.code);
      });
    return nodes;
  }

  String? _resolveSelectedPedigreeCode(
    String? rawCode,
    List<_PedigreeTreeNode> nodes,
  ) {
    if (nodes.isEmpty) {
      return null;
    }
    final normalized = _normalizeLookup(_readString(rawCode));
    if (normalized.isEmpty) {
      return nodes.first.code;
    }
    for (final node in nodes) {
      if (_normalizeLookup(node.code) == normalized) {
        return node.code;
      }
    }
    return nodes.first.code;
  }

  Map<String, dynamic> _userToJson(UserProfile user) {
    return {
      'id': user.id,
      'code': user.code,
      'name': user.name,
      'role': user.role,
      'avatar': user.avatar,
      'address': user.address,
      'contact': user.contact,
      'fokontany': user.fokontany,
      'commune': user.commune,
      'district': user.district,
      'region': user.region,
      'bio': user.bio,
      'profileImageBase64': user.profileImageBase64,
      'coverImageBase64': user.coverImageBase64,
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
    var address = _readString(json['address']).trim();
    var contact = _readString(json['contact']).trim();
    var fokontany = _readString(json['fokontany']).trim();
    var commune = _readString(json['commune']).trim();
    var district = _readString(json['district']).trim();
    var region = _readString(json['region']).trim();
    var bio = _readString(json['bio']).trim();
    var profileImageBase64 = _readString(json['profileImageBase64']).trim();
    var coverImageBase64 = _readString(json['coverImageBase64']).trim();
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

    UserProfile? fallbackUser;
    for (final user in initialUsers) {
      if (user.id == id ||
          user.code.toLowerCase() == code.toLowerCase() ||
          user.login.toLowerCase() == login.toLowerCase()) {
        fallbackUser = user;
        break;
      }
    }
    if (address.isEmpty && fallbackUser != null) {
      address = fallbackUser.address;
    }
    if (contact.isEmpty && fallbackUser != null) {
      contact = fallbackUser.contact;
    }
    if (fokontany.isEmpty && fallbackUser != null) {
      fokontany = fallbackUser.fokontany;
    }
    if (commune.isEmpty && fallbackUser != null) {
      commune = fallbackUser.commune;
    }
    if (district.isEmpty && fallbackUser != null) {
      district = fallbackUser.district;
    }
    if (region.isEmpty && fallbackUser != null) {
      region = fallbackUser.region;
    }
    if (bio.isEmpty && fallbackUser != null) {
      bio = fallbackUser.bio;
    }
    if (profileImageBase64.isEmpty && fallbackUser != null) {
      profileImageBase64 = fallbackUser.profileImageBase64;
    }
    if (coverImageBase64.isEmpty && fallbackUser != null) {
      coverImageBase64 = fallbackUser.coverImageBase64;
    }

    return UserProfile(
      id: id,
      code: code,
      name: name,
      role: role,
      avatar: avatar,
      address: address,
      contact: contact,
      fokontany: fokontany,
      commune: commune,
      district: district,
      region: region,
      bio: bio,
      profileImageBase64: profileImageBase64,
      coverImageBase64: coverImageBase64,
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
      'imageBase64': sow.imageBase64,
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
      imageBase64: _readString(json['imageBase64']),
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

  Map<String, dynamic> _animalSaleListingToJson(AnimalSaleListing listing) {
    return {
      'id': listing.id,
      'category': listing.category,
      'animalCode': listing.animalCode,
      'animalName': listing.animalName,
      'breed': listing.breed,
      'quantity': listing.quantity,
      'unitPrice': listing.unitPrice,
      'weightKg': listing.weightKg,
      'publishedDate': listing.publishedDate.toIso8601String(),
      'sellerId': listing.sellerId,
      'sellerName': listing.sellerName,
      'contact': listing.contact,
      'location': listing.location,
      'status': listing.status,
      'isPublished': listing.isPublished,
      'description': listing.description,
      'imageBase64': listing.imageBase64,
    };
  }

  AnimalSaleListing? _animalSaleListingFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final category = _readString(json['category']).trim();
    final animalCode = _readString(json['animalCode']).trim();
    final animalName = _readString(json['animalName']).trim();
    final breed = _readString(json['breed']).trim();
    final quantity = _readInt(json['quantity']);
    final unitPrice = _readDouble(json['unitPrice']);
    final weightKg = _readDouble(json['weightKg']);
    final publishedDate = _parseDateFromString(
      _readString(json['publishedDate']),
    );
    final sellerId = _readString(json['sellerId']).trim();
    final sellerName = _readString(json['sellerName']).trim();
    final contact = _readString(json['contact']).trim();
    final location = _readString(json['location']).trim();
    final status = _readString(json['status']).trim();
    final isPublishedRaw = _readString(json['isPublished']).trim();
    final isPublished = isPublishedRaw.toLowerCase() != 'false';
    final description = _readString(json['description']).trim();
    final imageBase64 = _readString(json['imageBase64']).trim();

    if (id.isEmpty ||
        category.isEmpty ||
        animalCode.isEmpty ||
        animalName.isEmpty ||
        quantity <= 0 ||
        unitPrice <= 0 ||
        publishedDate == null ||
        sellerName.isEmpty ||
        status.isEmpty) {
      return null;
    }

    return AnimalSaleListing(
      id: id,
      category: category,
      animalCode: animalCode,
      animalName: animalName,
      breed: breed,
      quantity: quantity,
      unitPrice: unitPrice,
      weightKg: weightKg,
      publishedDate: publishedDate,
      sellerId: sellerId,
      sellerName: sellerName,
      contact: contact,
      location: location,
      status: status,
      isPublished: isPublished,
      description: description,
      imageBase64: imageBase64,
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

  Map<String, dynamic> _buildingToJson(BuildingRecord building) {
    return {
      'id': building.id,
      'name': building.name,
      'type': building.type,
      'capacity': building.capacity,
      'occupied': building.occupied,
    };
  }

  BuildingRecord? _buildingFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final name = _readString(json['name']).trim();
    final type = _readString(json['type']).trim();
    final capacity = _readInt(json['capacity']);
    final occupied = _readInt(json['occupied']);
    if (id.isEmpty ||
        name.isEmpty ||
        type.isEmpty ||
        capacity <= 0 ||
        occupied < 0) {
      return null;
    }
    return BuildingRecord(
      id: id,
      name: name,
      type: type,
      capacity: capacity,
      occupied: occupied > capacity ? capacity : occupied,
    );
  }

  Map<String, dynamic> _batchToJson(BatchRecord batch) {
    return {
      'id': batch.id,
      'name': batch.name,
      'stage': batch.stage,
      'startDate': batch.startDate.toIso8601String(),
      'animals': batch.animals,
      'avgWeight': batch.avgWeight,
    };
  }

  BatchRecord? _batchFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final name = _readString(json['name']).trim();
    final stage = _readString(json['stage']).trim();
    final startDate = _parseDateFromString(_readString(json['startDate']));
    final animals = _readInt(json['animals']);
    final avgWeight = _readDouble(json['avgWeight']);
    if (id.isEmpty ||
        name.isEmpty ||
        stage.isEmpty ||
        startDate == null ||
        animals <= 0 ||
        avgWeight < 0) {
      return null;
    }
    return BatchRecord(
      id: id,
      name: name,
      stage: stage,
      startDate: startDate,
      animals: animals,
      avgWeight: avgWeight,
    );
  }

  Map<String, dynamic> _growthToJson(GrowthRecord growth) {
    return {
      'id': growth.id,
      'batchId': growth.batchId,
      'date': growth.date.toIso8601String(),
      'avgWeight': growth.avgWeight,
      'dailyGain': growth.dailyGain,
    };
  }

  GrowthRecord? _growthFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final batchId = _readString(json['batchId']).trim();
    final date = _parseDateFromString(_readString(json['date']));
    final avgWeight = _readDouble(json['avgWeight']);
    final dailyGain = _readDouble(json['dailyGain']);
    if (id.isEmpty ||
        batchId.isEmpty ||
        date == null ||
        avgWeight < 0 ||
        dailyGain < 0) {
      return null;
    }
    return GrowthRecord(
      id: id,
      batchId: batchId,
      date: date,
      avgWeight: avgWeight,
      dailyGain: dailyGain,
    );
  }

  Map<String, dynamic> _pigletCareToJson(PigletCareRecord record) {
    return {
      'id': record.id,
      'animalCode': record.animalCode,
      'groupName': record.groupName,
      'eventDate': record.eventDate.toIso8601String(),
      'eventType': record.eventType,
      'details': record.details,
      'responsible': record.responsible,
      'nextDate': record.nextDate?.toIso8601String(),
    };
  }

  PigletCareRecord? _pigletCareFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final animalCode = _readString(json['animalCode']).trim();
    final groupName = _readString(json['groupName']).trim();
    final eventDate = _parseDateFromString(_readString(json['eventDate']));
    final eventType = _readString(json['eventType']).trim();
    final details = _readString(json['details']).trim();
    final responsible = _readString(json['responsible']).trim();
    if (id.isEmpty ||
        animalCode.isEmpty ||
        groupName.isEmpty ||
        eventDate == null ||
        eventType.isEmpty ||
        details.isEmpty ||
        responsible.isEmpty) {
      return null;
    }
    return PigletCareRecord(
      id: id,
      animalCode: animalCode,
      groupName: groupName,
      eventDate: eventDate,
      eventType: eventType,
      details: details,
      responsible: responsible,
      nextDate: _parseDateFromString(_readString(json['nextDate'])),
    );
  }

  Map<String, dynamic> _farrowingToJson(FarrowingRecord record) {
    return {
      'id': record.id,
      'sowCode': record.sowCode,
      'farrowingDate': record.farrowingDate.toIso8601String(),
      'totalBorn': record.totalBorn,
      'bornAlive': record.bornAlive,
      'stillborn': record.stillborn,
      'mummified': record.mummified,
      'weaned': record.weaned,
      'preWeaningDeaths': record.preWeaningDeaths,
      'avgBirthWeight': record.avgBirthWeight,
      'majorIssue': record.majorIssue,
      'responsible': record.responsible,
      'notes': record.notes,
    };
  }

  FarrowingRecord? _farrowingFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final sowCode = _readString(json['sowCode']).trim();
    final farrowingDate = _parseDateFromString(
      _readString(json['farrowingDate']),
    );
    final totalBorn = _readInt(json['totalBorn']);
    final bornAlive = _readInt(json['bornAlive']);
    final stillborn = _readInt(json['stillborn']);
    final mummified = _readInt(json['mummified']);
    final weaned = _readInt(json['weaned']);
    final preWeaningDeaths = _readInt(json['preWeaningDeaths']);
    final avgBirthWeight = _readDouble(json['avgBirthWeight']);
    final responsible = _readString(json['responsible']).trim();

    if (id.isEmpty ||
        sowCode.isEmpty ||
        farrowingDate == null ||
        totalBorn < 0 ||
        bornAlive < 0 ||
        stillborn < 0 ||
        mummified < 0 ||
        weaned < 0 ||
        preWeaningDeaths < 0 ||
        avgBirthWeight < 0 ||
        responsible.isEmpty) {
      return null;
    }

    return FarrowingRecord(
      id: id,
      sowCode: sowCode,
      farrowingDate: farrowingDate,
      totalBorn: totalBorn,
      bornAlive: bornAlive,
      stillborn: stillborn,
      mummified: mummified,
      weaned: weaned,
      preWeaningDeaths: preWeaningDeaths,
      avgBirthWeight: avgBirthWeight,
      majorIssue: _readString(json['majorIssue']).trim(),
      responsible: responsible,
      notes: _readString(json['notes']).trim(),
    );
  }

  Map<String, dynamic> _semenQualityToJson(SemenQualityRecord record) {
    return {
      'id': record.id,
      'lotCode': record.lotCode,
      'boarCode': record.boarCode,
      'collectionDate': record.collectionDate.toIso8601String(),
      'concentration': record.concentration,
      'motilityPercent': record.motilityPercent,
      'temperatureC': record.temperatureC,
      'storageHours': record.storageHours,
      'approvedBy': record.approvedBy,
      'notes': record.notes,
    };
  }

  SemenQualityRecord? _semenQualityFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final lotCode = _readString(json['lotCode']).trim();
    final boarCode = _readString(json['boarCode']).trim();
    final collectionDate = _parseDateFromString(
      _readString(json['collectionDate']),
    );
    final concentration = _readDouble(json['concentration']);
    final motilityPercent = _readDouble(json['motilityPercent']);
    final temperatureC = _readDouble(json['temperatureC']);
    final storageHours = _readInt(json['storageHours']);
    final approvedBy = _readString(json['approvedBy']).trim();
    if (id.isEmpty ||
        lotCode.isEmpty ||
        boarCode.isEmpty ||
        collectionDate == null ||
        concentration <= 0 ||
        motilityPercent < 0 ||
        temperatureC <= 0 ||
        storageHours < 0 ||
        approvedBy.isEmpty) {
      return null;
    }
    return SemenQualityRecord(
      id: id,
      lotCode: lotCode,
      boarCode: boarCode,
      collectionDate: collectionDate,
      concentration: concentration,
      motilityPercent: motilityPercent,
      temperatureC: temperatureC,
      storageHours: storageHours,
      approvedBy: approvedBy,
      notes: _readString(json['notes']).trim(),
    );
  }

  Map<String, dynamic> _auditLogToJson(AuditLogEntry entry) {
    return {
      'id': entry.id,
      'timestamp': entry.timestamp.toIso8601String(),
      'actorCode': entry.actorCode,
      'actorName': entry.actorName,
      'module': entry.module,
      'action': entry.action,
      'detail': entry.detail,
      'severity': entry.severity,
    };
  }

  AuditLogEntry? _auditLogFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final timestamp = _parseDateTimeFromString(_readString(json['timestamp']));
    final actorCode = _readString(json['actorCode']).trim();
    final actorName = _readString(json['actorName']).trim();
    final module = _readString(json['module']).trim();
    final action = _readString(json['action']).trim();
    final detail = _readString(json['detail']).trim();
    final severity = _readString(json['severity']).trim();
    if (id.isEmpty ||
        timestamp == null ||
        actorCode.isEmpty ||
        actorName.isEmpty ||
        module.isEmpty ||
        action.isEmpty ||
        severity.isEmpty) {
      return null;
    }
    return AuditLogEntry(
      id: id,
      timestamp: timestamp,
      actorCode: actorCode,
      actorName: actorName,
      module: module,
      action: action,
      detail: detail,
      severity: severity,
    );
  }

  Map<String, dynamic> _chatMessageToJson(ChatMessage message) {
    return {
      'id': message.id,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'text': message.text,
      'sentAt': message.sentAt.toIso8601String(),
      'readByUserIds': message.readByUserIds,
      'messageType': message.messageType,
      'mediaBase64': message.mediaBase64,
      'mediaName': message.mediaName,
      'mediaMimeType': message.mediaMimeType,
      'mediaSizeBytes': message.mediaSizeBytes,
      'callType': message.callType,
      'callStatus': message.callStatus,
      'callDurationSeconds': message.callDurationSeconds,
      'callSessionId': message.callSessionId,
    };
  }

  ChatMessage? _chatMessageFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final conversationId = _readString(json['conversationId']).trim();
    final senderId = _readString(json['senderId']).trim();
    final senderName = _readString(json['senderName']).trim();
    final text = _readString(json['text']).trim();
    final sentAt = _parseDateTimeFromString(_readString(json['sentAt']));
    final messageType = _readString(json['messageType']).trim().isEmpty
        ? 'text'
        : _readString(json['messageType']).trim();
    final mediaBase64 = _readString(json['mediaBase64']).trim();
    final mediaName = _readString(json['mediaName']).trim();
    final mediaMimeType = _readString(json['mediaMimeType']).trim();
    final mediaSizeBytes = _readInt(json['mediaSizeBytes']);
    final callType = _readString(json['callType']).trim();
    final callStatus = _readString(json['callStatus']).trim();
    final callDurationSeconds = _readInt(json['callDurationSeconds']);
    final callSessionId = _readString(json['callSessionId']).trim();
    if (id.isEmpty ||
        conversationId.isEmpty ||
        senderId.isEmpty ||
        senderName.isEmpty ||
        sentAt == null) {
      return null;
    }
    final hasRenderableBody =
        text.isNotEmpty ||
        mediaBase64.isNotEmpty ||
        messageType == 'call' ||
        messageType == 'audio' ||
        messageType == 'video' ||
        messageType == 'image';
    if (!hasRenderableBody) {
      return null;
    }
    var readBy = _readStringList(json['readByUserIds']);
    if (!readBy.contains(senderId)) {
      readBy = [...readBy, senderId];
    }
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: sentAt,
      readByUserIds: readBy,
      messageType: messageType,
      mediaBase64: mediaBase64,
      mediaName: mediaName,
      mediaMimeType: mediaMimeType,
      mediaSizeBytes: mediaSizeBytes,
      callType: callType,
      callStatus: callStatus,
      callDurationSeconds: callDurationSeconds,
      callSessionId: callSessionId,
    );
  }

  Map<String, dynamic> _newsCommentToJson(NewsComment comment) {
    return {
      'id': comment.id,
      'authorId': comment.authorId,
      'authorName': comment.authorName,
      'text': comment.text,
      'createdAt': comment.createdAt.toIso8601String(),
    };
  }

  NewsComment? _newsCommentFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final authorId = _readString(json['authorId']).trim();
    final authorName = _readString(json['authorName']).trim();
    final text = _readString(json['text']).trim();
    final createdAt = _parseDateTimeFromString(_readString(json['createdAt']));
    if (id.isEmpty || authorName.isEmpty || text.isEmpty || createdAt == null) {
      return null;
    }
    return NewsComment(
      id: id,
      authorId: authorId,
      authorName: authorName,
      text: text,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> _newsPostToJson(NewsPost post) {
    return {
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'text': post.text,
      'createdAt': post.createdAt.toIso8601String(),
      'imageBase64': post.imageBase64,
      'imageName': post.imageName,
      'likedByUserIds': post.likedByUserIds,
      'comments': post.comments.map(_newsCommentToJson).toList(),
    };
  }

  NewsPost? _newsPostFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']).trim();
    final authorId = _readString(json['authorId']).trim();
    final authorName = _readString(json['authorName']).trim();
    final authorRole = _readString(json['authorRole']).trim();
    final text = _readString(json['text']).trim();
    final createdAt = _parseDateTimeFromString(_readString(json['createdAt']));
    final imageBase64 = _readString(json['imageBase64']).trim();
    final imageName = _readString(json['imageName']).trim();
    if (id.isEmpty ||
        authorName.isEmpty ||
        createdAt == null ||
        (text.isEmpty && imageBase64.isEmpty)) {
      return null;
    }

    final comments = <NewsComment>[];
    if (json['comments'] is List) {
      for (final item in (json['comments'] as List)) {
        if (item is! Map) {
          continue;
        }
        final comment = _newsCommentFromJson(Map<String, dynamic>.from(item));
        if (comment != null) {
          comments.add(comment);
        }
      }
    }
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return NewsPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole.isEmpty ? Roles.breeder : authorRole,
      text: text,
      createdAt: createdAt,
      imageBase64: imageBase64,
      imageName: imageName,
      likedByUserIds: _readStringList(json['likedByUserIds']),
      comments: comments,
    );
  }

  Widget _buildSidebar() {
    final navItems = <Widget>[
      if (_canAccessTab(AppTabs.dashboard))
        _buildNavItem(
          icon: LucideIcons.layoutDashboard,
          label: 'Tableau de bord',
          tabId: AppTabs.dashboard,
        ),
      if (_canAccessTab(AppTabs.profile))
        _buildNavItem(
          icon: Icons.account_circle_outlined,
          label: 'Mon Profil',
          tabId: AppTabs.profile,
        ),
      if (_canAccessTab(AppTabs.actualites))
        _buildNavItem(
          icon: Icons.dynamic_feed_outlined,
          label: 'Actualités',
          tabId: AppTabs.actualites,
        ),
      if (_canAccessTab(AppTabs.messenger))
        _buildNavItem(
          icon: Icons.forum_outlined,
          label: 'Messagerie',
          tabId: AppTabs.messenger,
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
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sidebarDark, _sidebarDarkSoft],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebarBrandHeader(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.xxs,
                    bottom: AppSpacing.xs,
                  ),
                  children: navItems,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildCurrentUserCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarBrandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandLogo(
          height: AppSpacing.s72,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        const SizedBox(height: AppSpacing.s6),
        const Text(
          'PigIA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ],
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: _buildLoginCard(dateLabel),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(String dateLabel) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xxxl),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _buildBrandLogo(
                height: AppSpacing.s72,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Connexion Utilisateur',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              'Gestion d\'élevage porcin • $dateLabel',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
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
            const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.sm),
              Text(
                _authError!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _attemptLogin,
                icon: const Icon(Icons.login),
                label: const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildLoginSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSecurityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSpacing.md),
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
    );
  }

  Widget _buildBrandLogo({required double height, BorderRadius? borderRadius}) {
    final image = Image.asset(
      _brandLogoAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height * 0.56,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _accentTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(color: _accentTeal.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                LucideIcons.piggyBank,
                color: Color(0xFF0F766E),
                size: AppSpacing.xxl,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'PIGIA',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (borderRadius == null) {
      return image;
    }
    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String tabId,
  }) {
    final isActive = _activeTab == tabId;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (!_canAccessTab(tabId)) {
            _showError('Accès refusé pour le rôle ${_currentUser.role}.');
            return;
          }
          setState(() {
            _activeTab = tabId;
            if (tabId != AppTabs.messenger) {
              _isMobileMessengerThreadOpen = false;
            }
          });
          _persistState();
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s14,
            vertical: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? _accentTeal.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? Border.all(color: _accentTeal.withValues(alpha: 0.75))
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _accentTeal.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFFCCFBF1)
                    : const Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.s10),
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
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildUserAvatar(_currentUser, radius: 18),
              const SizedBox(width: AppSpacing.s10),
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
          const SizedBox(height: AppSpacing.s10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              'Login: ${_currentUser.login}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
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
    final compact = screenWidth < 680;
    final tiny = screenWidth < 430;
    final showDate = screenWidth >= 700;
    final showSearch = screenWidth >= 1180;
    final showLoginBadge = screenWidth >= 980;
    final notificationCount = _headerNotificationCount();

    if (_activeTab == AppTabs.actualites) {
      return Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_newsHeaderGradientStart, _newsHeaderGradientEnd],
          ),
          border: Border(bottom: BorderSide(color: Color(0xFF0B5B55))),
        ),
        child: Row(
          children: [
            if (!isDesktop)
              IconButton(
                tooltip: 'Menu',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(LucideIcons.menu, color: Colors.white),
              ),
            const Expanded(
              child: Text(
                'Actualités',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Créer une publication',
                onPressed: _showAddNewsPostDialog,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            _buildHeaderNotificationButton(notificationCount),
          ],
        ),
      );
    }

    return Container(
      height: tiny ? 68 : 78,
      padding: EdgeInsets.symmetric(
        horizontal: tiny
            ? AppSpacing.s6
            : (compact ? AppSpacing.s10 : AppSpacing.s18),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDCE4EE))),
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
                if (!showSearch)
                  IconButton(
                    tooltip: 'Recherche',
                    onPressed: _openSearchDialog,
                    icon: const Icon(Icons.search, color: Color(0xFF334155)),
                  ),
                Expanded(
                  child: showSearch
                      ? _buildHeaderSearchField()
                      : Text(
                          compact
                              ? _compactTitleForTab(_activeTab)
                              : _titleForTab(_activeTab),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: tiny ? 11 : (compact ? 13 : 17),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          _buildHeaderNotificationButton(notificationCount),
          if (showDate) ...[
            const SizedBox(width: AppSpacing.s10),
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
          const SizedBox(width: AppSpacing.s8),
          if (showLoginBadge)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s7,
              ),
              decoration: BoxDecoration(
                color: _surfaceSlate,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE4EE)),
              ),
              child: Row(
                children: [
                  _buildUserAvatar(_currentUser, radius: 12),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Login: ${_currentUser.login}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (showLoginBadge) const SizedBox(width: AppSpacing.s8),
          if (showLoginBadge)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentTealDeep,
                side: BorderSide(color: _accentTeal.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s10,
                ),
              ),
              onPressed: () {
                setState(() => _activeTab = AppTabs.profile);
                _persistState();
              },
              icon: const Icon(Icons.account_circle_outlined, size: 16),
              label: const Text('Profil'),
            ),
          if (showLoginBadge) const SizedBox(width: AppSpacing.s8),
          if (showLoginBadge)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s10,
                ),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Déconnexion'),
            )
          else
            IconButton(
              tooltip: 'Déconnexion',
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color(0xFF334155)),
            ),
        ],
      ),
    );
  }

  Widget _buildIncomingCallBanner() {
    final offer = _incomingCallOffer;
    if (offer == null) {
      return const SizedBox.shrink();
    }
    final isVideo = offer.callType == 'video';
    final callLabel = isVideo ? 'Appel vidéo entrant' : 'Appel audio entrant';
    final subtitle =
        '${offer.callerName} • ${_chatDayLabel(offer.sentAt)} ${_chatClockLabel(offer.sentAt)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7ED),
        border: Border(bottom: BorderSide(color: Color(0xFFFED7AA))),
      ),
      child: Wrap(
        spacing: AppSpacing.s10,
        runSpacing: AppSpacing.s8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.call_rounded,
              color: const Color(0xFFB45309),
              size: 18,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callLabel,
                  style: const TextStyle(
                    color: Color(0xFF7C2D12),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _rejectIncomingCallOffer,
            icon: const Icon(Icons.call_end_outlined, size: 16),
            label: const Text('Refuser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
            ),
          ),
          FilledButton.icon(
            onPressed: _acceptIncomingCallOffer,
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Accepter'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _surfaceSlate,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE4EE)),
      ),
      child: TextField(
        controller: _headerSearchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _handleHeaderSearchSubmitted,
        decoration: const InputDecoration(
          hintText: 'Recherche rapide: IA, truie, verrat, santé, actualités...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
          contentPadding: EdgeInsets.only(top: AppSpacing.s10),
        ),
      ),
    );
  }

  Widget _buildHeaderNotificationButton(int notificationCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _surfaceSlate,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCE4EE)),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotificationsSheet,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF334155),
            ),
          ),
        ),
        if (notificationCount > 0)
          Positioned(
            top: -5,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s6,
                vertical: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                notificationCount > 99 ? '99+' : '$notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _headerNotificationCount() {
    final notifications = _buildHeaderNotifications();
    var total = notifications.fold<int>(0, (sum, item) => sum + item.count);
    if (total < 0) {
      total = 0;
    }
    if (total > 999) {
      total = 999;
    }
    return total;
  }

  List<_HeaderNotificationEntry> _buildHeaderNotifications() {
    final now = _currentDate();
    final unreadMessages = _chatMessages.where((message) {
      if (!_isConversationVisibleForCurrentUser(message.conversationId)) {
        return false;
      }
      if (message.conversationId == _teamConversationId &&
          !_isTeamConversationUserIdAllowed(message.senderId)) {
        return false;
      }
      if (message.senderId == _currentUser.id) {
        return false;
      }
      return !message.readByUserIds.contains(_currentUser.id);
    }).length;
    final overdueDiagnostics = _inseminations.where((record) {
      if (_isSuccessfulStatus(record.status) ||
          _isFailedStatus(record.status)) {
        return false;
      }
      return now.isAfter(
        _expectedPregnancyCheckDate(record).add(const Duration(days: 7)),
      );
    }).length;
    final upcomingHealth = _healthRecords.where((record) {
      if (record.nextDate == null) {
        return false;
      }
      final due = _normalizeDate(record.nextDate!);
      return !due.isBefore(now) &&
          !due.isAfter(now.add(const Duration(days: 3)));
    }).length;
    final pendingTasks = _buildOperationalTasks().where((task) {
      if (task.done) {
        return false;
      }
      return !task.dueDate.isAfter(now.add(const Duration(days: 3)));
    }).length;

    return [
      _HeaderNotificationEntry(
        title: 'Messages non lus',
        detail: unreadMessages > 0
            ? '$unreadMessages message(s) à lire dans la messagerie.'
            : 'Aucun message non lu.',
        count: unreadMessages,
        icon: Icons.forum_outlined,
        color: const Color(0xFF0EA5E9),
        tabId: AppTabs.messenger,
      ),
      _HeaderNotificationEntry(
        title: 'Diagnostics IA en retard',
        detail: overdueDiagnostics > 0
            ? '$overdueDiagnostics truie(s) à diagnostiquer rapidement.'
            : 'Aucun retard de diagnostic IA.',
        count: overdueDiagnostics,
        icon: LucideIcons.syringe,
        color: const Color(0xFFEA580C),
        tabId: AppTabs.inseminations,
      ),
      _HeaderNotificationEntry(
        title: 'Rappels santé imminents',
        detail: upcomingHealth > 0
            ? '$upcomingHealth acte(s) santé à réaliser sous 72h.'
            : 'Aucun rappel santé urgent.',
        count: upcomingHealth,
        icon: LucideIcons.shieldCheck,
        color: const Color(0xFF16A34A),
        tabId: AppTabs.health,
      ),
      _HeaderNotificationEntry(
        title: 'Tâches terrain à exécuter',
        detail: pendingTasks > 0
            ? '$pendingTasks tâche(s) proche échéance.'
            : 'Aucune tâche urgente.',
        count: pendingTasks,
        icon: LucideIcons.layoutDashboard,
        color: const Color(0xFF7C3AED),
        tabId: AppTabs.dashboard,
      ),
    ];
  }

  void _openNotificationsSheet() {
    final notifications = _buildHeaderNotifications();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s4,
              AppSpacing.s16,
              AppSpacing.s16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications opérationnelles',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),
                ...notifications.map((item) {
                  final disabled = item.count <= 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFDCE4EE)),
                      ),
                      tileColor: Colors.white,
                      leading: CircleAvatar(
                        backgroundColor: item.color.withValues(alpha: 0.12),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(item.detail),
                      trailing: disabled
                          ? const Icon(Icons.check, color: Color(0xFF94A3B8))
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s10,
                                vertical: AppSpacing.s6,
                              ),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${item.count}',
                                style: TextStyle(
                                  color: item.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                      onTap: disabled
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              _setActiveTabFromHeader(item.tabId);
                            },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSearchDialog() {
    final searchCtrl = TextEditingController(
      text: _headerSearchController.text,
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recherche rapide'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: TextField(
              controller: searchCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                Navigator.of(dialogContext).pop();
                _handleHeaderSearchSubmitted(value);
              },
              decoration: const InputDecoration(
                hintText: 'Ex: truie TR-2001, messagerie, santé, vente...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleHeaderSearchSubmitted(searchCtrl.text);
              },
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    ).then((_) => searchCtrl.dispose());
  }

  void _handleHeaderSearchSubmitted(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return;
    }

    _headerSearchController.text = query;
    final normalized = _normalizeLookup(query);
    final routeMap = <String, List<String>>{
      AppTabs.dashboard: ['dashboard', 'tableau', 'kpi', 'suivi'],
      AppTabs.actualites: [
        'actualite',
        'actualité',
        'feed',
        'timeline',
        'post',
      ],
      AppTabs.messenger: ['message', 'messagerie', 'chat', 'discussion'],
      AppTabs.services: ['service', 'accompagnement', 'pack'],
      AppTabs.elevage: [
        'elevage',
        'élevage',
        'bande',
        'batiment',
        'croissance',
      ],
      AppTabs.inseminations: ['ia', 'insemination', 'insémination', 'semence'],
      AppTabs.boars: ['verrat', 'boar', 'geniteur', 'géniteur'],
      AppTabs.sows: ['truie', 'sow', 'mise-bas', 'gestation'],
      AppTabs.pedigree: ['pedigree', 'pedigree', 'ascendance', 'consanguinite'],
      AppTabs.health: ['sante', 'santé', 'vaccin', 'traitement'],
      AppTabs.commercial: [
        'vente',
        'commercial',
        'stock',
        'annonce',
        'publier',
      ],
      AppTabs.administration: [
        'admin',
        'administration',
        'inseminateur',
        'eleveur',
      ],
      AppTabs.users: ['utilisateur', 'login', 'mot de passe', 'compte'],
      AppTabs.profile: ['profil', 'photo'],
    };

    for (final entry in routeMap.entries) {
      for (final token in entry.value) {
        if (normalized.contains(_normalizeLookup(token))) {
          _setActiveTabFromHeader(entry.key);
          _showInfo(
            'Recherche: ouverture du module "${_titleForTab(entry.key)}".',
          );
          return;
        }
      }
    }

    Boar? boar;
    for (final item in _boars) {
      if (_normalizeLookup(item.code).contains(normalized) ||
          _normalizeLookup(item.name).contains(normalized)) {
        boar = item;
        break;
      }
    }
    if (boar != null) {
      _setActiveTabFromHeader(AppTabs.boars);
      _showInfo('Résultat trouvé: verrat ${boar.code} - ${boar.name}.');
      return;
    }

    Sow? sow;
    for (final item in _sows) {
      if (_normalizeLookup(item.code).contains(normalized) ||
          _normalizeLookup(item.name).contains(normalized)) {
        sow = item;
        break;
      }
    }
    if (sow != null) {
      _setActiveTabFromHeader(AppTabs.sows);
      _showInfo('Résultat trouvé: truie ${sow.code} - ${sow.name}.');
      return;
    }

    _showInfo(
      'Aucun résultat direct pour "$query". Essayez un mot-clé module.',
    );
  }

  void _setActiveTabFromHeader(String tabId) {
    if (!_canAccessTab(tabId)) {
      _showError('Accès refusé pour ce module (${_currentUser.role}).');
      return;
    }
    setState(() {
      _activeTab = tabId;
      if (tabId != AppTabs.messenger) {
        _isMobileMessengerThreadOpen = false;
      }
    });
    _persistState();
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
      case AppTabs.profile:
        return _buildProfileHub();
      case AppTabs.actualites:
        return _buildNewsFeedHub();
      case AppTabs.messenger:
        return _buildMessengerHub();
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
    final inseminatorRecaps = _computeInseminatorRecaps();
    final breederIaRecaps = _computeBreederIaRecaps();
    final breederControlRecaps = _computeBreederControlRecaps();
    final districtRecaps = _computeDistrictPerformanceRecaps();
    final qualityRecaps = _computeBreederDataQualityRecaps();

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

    final inseminatorRows = inseminatorRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.user.code)),
              DataCell(Text(recap.user.name)),
              DataCell(
                Text(recap.user.address.isEmpty ? '-' : recap.user.address),
              ),
              DataCell(
                Text(recap.user.contact.isEmpty ? '-' : recap.user.contact),
              ),
              DataCell(
                Text(recap.user.fokontany.isEmpty ? '-' : recap.user.fokontany),
              ),
              DataCell(
                Text(recap.user.commune.isEmpty ? '-' : recap.user.commune),
              ),
              DataCell(
                Text(recap.user.district.isEmpty ? '-' : recap.user.district),
              ),
              DataCell(
                Text(recap.user.region.isEmpty ? '-' : recap.user.region),
              ),
              DataCell(Text('${recap.totalIa}')),
              DataCell(
                Text(
                  '${recap.successRate}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DataCell(
                Text(
                  _formatAmount(recap.totalIaCost),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        )
        .toList();

    final breederIaRows = breederIaRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.user.code)),
              DataCell(Text(recap.user.name)),
              DataCell(
                Text(recap.user.address.isEmpty ? '-' : recap.user.address),
              ),
              DataCell(
                Text(recap.user.contact.isEmpty ? '-' : recap.user.contact),
              ),
              DataCell(Text(_territoryLabel(recap.user))),
              DataCell(Text('${recap.sowsToInseminate}')),
              DataCell(
                Text(
                  '${recap.successRate}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        )
        .toList();

    final breederControlRows = breederControlRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.user.code)),
              DataCell(Text(recap.user.name)),
              DataCell(Text(_territoryLabel(recap.user))),
              DataCell(Text('${recap.totalPigs}')),
              DataCell(Text('${recap.sowCount}')),
              DataCell(Text('${recap.iaCount}')),
              DataCell(Text('${recap.overdueIaDiagnosis}')),
              DataCell(Text('${recap.overdueHealthActions}')),
              DataCell(
                Text(
                  recap.riskLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: recap.riskScore >= 4
                        ? const Color(0xFFB91C1C)
                        : recap.riskScore >= 2
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
    final districtRows = districtRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.region)),
              DataCell(Text(recap.district)),
              DataCell(Text('${recap.inseminators}')),
              DataCell(Text('${recap.totalIa}')),
              DataCell(
                Text(
                  '${recap.successRate}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DataCell(Text('${recap.overdueDiagnosis}')),
            ],
          ),
        )
        .toList();
    final qualityRows = qualityRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.user.code)),
              DataCell(Text(recap.user.name)),
              DataCell(Text(_territoryLabel(recap.user))),
              DataCell(
                Text('${recap.sowsWithCompletePedigree}/${recap.sowCount}'),
              ),
              DataCell(Text('${recap.sowsWithIaPlan}/${recap.sowCount}')),
              DataCell(Text('${recap.healthCoverageRate}%')),
              DataCell(
                Text(
                  '${recap.qualityScore}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DataCell(
                Text(
                  recap.qualityStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: recap.qualityScore >= 80
                        ? const Color(0xFF15803D)
                        : recap.qualityScore >= 60
                        ? const Color(0xFFB45309)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
    final auditRows = _auditLogs
        .take(60)
        .map(
          (entry) => DataRow(
            cells: [
              DataCell(Text(_formatDateTime(entry.timestamp))),
              DataCell(Text(entry.actorCode)),
              DataCell(Text(entry.module)),
              DataCell(Text(entry.action)),
              DataCell(Text(entry.detail.isEmpty ? '-' : entry.detail)),
              DataCell(
                Text(
                  entry.severity,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: entry.severity == 'WARN'
                        ? const Color(0xFFB45309)
                        : entry.severity == 'ERROR'
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
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
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: summary[1]),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: summary[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      summary[0],
                      const SizedBox(height: AppSpacing.s10),
                      summary[1],
                      const SizedBox(height: AppSpacing.s10),
                      summary[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s14),
              _buildSalesFilterControl(),
              const SizedBox(height: AppSpacing.s12),
              _buildSalesEvolutionChart(filteredSales),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Récapitulation suivi inséminateurs',
          subtitle:
              'Code, coordonnées terrain, nombre IA vita, taux de réussite et coût total IA',
          emptyMessage: 'Aucun inséminateur disponible.',
          columns: const [
            DataColumn(label: Text('CODE INSÉMINATEUR')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('ADRESSE')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('FOKONTANY')),
            DataColumn(label: Text('COMMUNE')),
            DataColumn(label: Text('DISTRICT')),
            DataColumn(label: Text('RÉGION')),
            DataColumn(label: Text('NOMBRE IA VITA')),
            DataColumn(label: Text('TAUX RÉUSSITE IA')),
            DataColumn(label: Text('COÛT IA')),
          ],
          rows: inseminatorRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Récapitulation gestion éleveurs (truies pour IA)',
          subtitle:
              'Code, coordonnées, truies à faire IA et taux de réussite IA',
          emptyMessage: 'Aucun éleveur disponible.',
          columns: const [
            DataColumn(label: Text('CODE ÉLEVEUR')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('ADRESSE')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('LOCALISATION')),
            DataColumn(label: Text('TRUIES À FAIRE IA')),
            DataColumn(label: Text('TAUX RÉUSSITE IA')),
          ],
          rows: breederIaRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Contrôle éleveurs et porcs',
          subtitle:
              'Surveillance terrain: effectif porcin, retards IA/santé et niveau de risque',
          emptyMessage: 'Aucun éleveur à contrôler.',
          columns: const [
            DataColumn(label: Text('CODE ÉLEVEUR')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('LOCALISATION')),
            DataColumn(label: Text('TOTAL PORCS')),
            DataColumn(label: Text('TRUIES')),
            DataColumn(label: Text('IA RÉALISÉES')),
            DataColumn(label: Text('RETARD DIAG IA')),
            DataColumn(label: Text('RETARD SANTÉ')),
            DataColumn(label: Text('NIVEAU CONTRÔLE')),
          ],
          rows: breederControlRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Performance terrain par district',
          subtitle:
              'Suivi inséminateurs terrain par district/région avec taux de réussite et retards',
          emptyMessage: 'Aucune performance terrain disponible.',
          columns: const [
            DataColumn(label: Text('RÉGION')),
            DataColumn(label: Text('DISTRICT')),
            DataColumn(label: Text('INSÉMINATEURS')),
            DataColumn(label: Text('IA RÉALISÉES')),
            DataColumn(label: Text('TAUX RÉUSSITE IA')),
            DataColumn(label: Text('DIAG EN RETARD')),
          ],
          rows: districtRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Qualité des données par éleveur',
          subtitle:
              'Complétude pedigree, plan IA, couverture santé et score qualité opérationnelle',
          emptyMessage: 'Aucun score qualité disponible.',
          columns: const [
            DataColumn(label: Text('CODE ÉLEVEUR')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('LOCALISATION')),
            DataColumn(label: Text('PEDIGREE')),
            DataColumn(label: Text('PLAN IA')),
            DataColumn(label: Text('COUVERTURE SANTÉ')),
            DataColumn(label: Text('SCORE')),
            DataColumn(label: Text('STATUT')),
          ],
          rows: qualityRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Journal d\'audit opérationnel',
          subtitle: 'Traçabilité des actions critiques utilisateurs et terrain',
          emptyMessage: 'Aucun événement d\'audit.',
          columns: const [
            DataColumn(label: Text('DATE/HEURE')),
            DataColumn(label: Text('ACTEUR')),
            DataColumn(label: Text('MODULE')),
            DataColumn(label: Text('ACTION')),
            DataColumn(label: Text('DÉTAIL')),
            DataColumn(label: Text('SÉVÉRITÉ')),
          ],
          rows: auditRows,
        ),
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
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
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: indicators[1]),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: indicators[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      indicators[0],
                      const SizedBox(height: AppSpacing.s10),
                      indicators[1],
                      const SizedBox(height: AppSpacing.s10),
                      indicators[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s12),
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
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
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
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s5,
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
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
        _buildSectionCard(
          title: 'Référentiel de Performance',
          subtitle:
              'Comparaison des résultats actuels avec les cibles techniques élevage',
          child: Column(
            children: serviceBenchmarks
                .map(
                  (benchmark) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: _buildServiceBenchmarkRow(benchmark),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
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
      padding: const EdgeInsets.all(AppSpacing.s18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: service.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: service.color),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            service.title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            service.description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
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
            const SizedBox(width: AppSpacing.s8),
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
        const SizedBox(height: AppSpacing.s6),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s12),
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
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.s2),
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
                  building.capacity <= 0
                      ? '-'
                      : '${((building.occupied / building.capacity) * 100).round()}%',
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier bâtiment',
                      onPressed: () => _showEditBuildingDialog(building),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer bâtiment',
                      onPressed: () => _deleteBuilding(building.id),
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

    final batchRows = _batchRecords
        .map(
          (batch) => DataRow(
            cells: [
              DataCell(Text(batch.name)),
              DataCell(Text(batch.stage)),
              DataCell(Text(_formatDate(batch.startDate))),
              DataCell(Text('${batch.animals}')),
              DataCell(Text('${batch.avgWeight.toStringAsFixed(1)} kg')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier bande',
                      onPressed: () => _showEditBatchDialog(batch),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer bande',
                      onPressed: () => _deleteBatch(batch.id),
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

    final growthRows = _growthRecords
        .map(
          (growth) => DataRow(
            cells: [
              DataCell(Text(_batchNameForId(growth.batchId))),
              DataCell(Text(_formatDate(growth.date))),
              DataCell(Text('${growth.avgWeight.toStringAsFixed(1)} kg')),
              DataCell(Text('${growth.dailyGain.toStringAsFixed(2)} kg/j')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier suivi croissance',
                      onPressed: () => _showEditGrowthDialog(growth),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer suivi croissance',
                      onPressed: () => _deleteGrowthRecord(growth.id),
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

    final farrowingRows = _farrowingRecords
        .map(
          (record) => DataRow(
            cells: [
              DataCell(Text(_formatDate(record.farrowingDate))),
              DataCell(Text(record.sowCode)),
              DataCell(Text('${record.totalBorn}')),
              DataCell(Text('${record.bornAlive}')),
              DataCell(Text('${record.stillborn}')),
              DataCell(Text('${record.mummified}')),
              DataCell(Text('${record.weaned}')),
              DataCell(Text('${record.preWeaningDeaths}')),
              DataCell(Text('${record.avgBirthWeight.toStringAsFixed(2)} kg')),
              DataCell(Text(record.responsible)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier portée',
                      onPressed: () => _showEditFarrowingDialog(record),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer portée',
                      onPressed: () => _deleteFarrowingRecord(record.id),
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

    final pigletRows = _pigletCareRecords
        .map(
          (record) => DataRow(
            cells: [
              DataCell(Text(_formatDate(record.eventDate))),
              DataCell(Text(record.groupName)),
              DataCell(Text(record.animalCode)),
              DataCell(Text(record.eventType)),
              DataCell(Text(record.responsible)),
              DataCell(
                Text(
                  record.nextDate == null ? '-' : _formatDate(record.nextDate!),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier prise en charge',
                      onPressed: () => _showEditPigletCareDialog(record),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer prise en charge',
                      onPressed: () => _deletePigletCareRecord(record.id),
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

    final animalSaleRows = _buildAnimalSaleListingRows(
      _animalSaleListingsForElevage(),
    );

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text('Porcherie / Bâtiment')),
                  Chip(label: Text('Cycle de production')),
                  Chip(label: Text('Gestion des bandes')),
                  Chip(label: Text('Suivi de croissance')),
                  Chip(label: Text('Maternité / Portées')),
                  Chip(label: Text('Calendrier de gestation')),
                  Chip(label: Text('Prise en charge porcelets')),
                  Chip(label: Text('Inventaire des animaux')),
                ],
              ),
              const SizedBox(height: AppSpacing.s10),
              const Text(
                'Les éleveurs peuvent ajouter et modifier les données d\'élevage '
                '(bâtiments, bandes, croissance, soins porcelets) directement ici.',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildGestationCalendarSection(),
        const SizedBox(height: AppSpacing.s16),
        _buildPigletCareCalendarSection(),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Porcherie / Bâtiment',
          subtitle: 'Capacité et occupation par bâtiment',
          emptyMessage: 'Aucun bâtiment renseigné.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddBuildingDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter bâtiment'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('BÂTIMENT')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('CAPACITÉ')),
            DataColumn(label: Text('OCCUPÉS')),
            DataColumn(label: Text('TAUX OCCUPATION')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: buildingRows,
        ),
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Gestion des bandes',
          subtitle: 'Suivi des lots de production',
          emptyMessage: 'Aucune bande disponible.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddBatchDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter bande'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('BANDE')),
            DataColumn(label: Text('STADE')),
            DataColumn(label: Text('DÉBUT')),
            DataColumn(label: Text('ANIMAUX')),
            DataColumn(label: Text('POIDS MOYEN')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: batchRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Suivi de croissance',
          subtitle: 'Poids moyen et gain moyen quotidien',
          emptyMessage: 'Aucune mesure de croissance.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddGrowthDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter suivi croissance'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('BANDE')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('POIDS MOYEN')),
            DataColumn(label: Text('GMQ')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: growthRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Maternité / Portées',
          subtitle:
              'Suivi mise-bas, nés vivants, pertes néonatales, sevrage et poids naissance',
          emptyMessage: 'Aucune mise-bas enregistrée.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddFarrowingDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter mise-bas'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('TRUIE')),
            DataColumn(label: Text('NÉS TOTAL')),
            DataColumn(label: Text('NÉS VIVANTS')),
            DataColumn(label: Text('MORT-NÉS')),
            DataColumn(label: Text('MOMIFIÉS')),
            DataColumn(label: Text('SEVRÉS')),
            DataColumn(label: Text('MORT PRÉ-SEVRAGE')),
            DataColumn(label: Text('POIDS NAISSANCE')),
            DataColumn(label: Text('RESPONSABLE')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: farrowingRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Prise en charge des porcelets',
          subtitle:
              'Interventions post-mise-bas: colostrum, soins néonataux, supplémentation',
          emptyMessage: 'Aucune prise en charge porcelets enregistrée.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddPigletCareDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter prise en charge'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('PORTÉE / GROUPE')),
            DataColumn(label: Text('TRUIE')),
            DataColumn(label: Text('TYPE SOIN')),
            DataColumn(label: Text('RESPONSABLE')),
            DataColumn(label: Text('PROCHAINE DATE')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: pigletRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Publication animaux à vendre',
          subtitle:
              'Diffusion des verrats, truies et lots de porcelets disponibles à la vente',
          emptyMessage: 'Aucune annonce animale enregistrée.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddAnimalSaleListingDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Publier animal'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('PHOTO')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('CODE / LOT')),
            DataColumn(label: Text('ANIMAL')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('QTÉ')),
            DataColumn(label: Text('PRIX UNITAIRE')),
            DataColumn(label: Text('VENDEUR')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('LOCALISATION')),
            DataColumn(label: Text('STATUT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: animalSaleRows,
        ),
        const SizedBox(height: AppSpacing.s16),
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

    final allAnimalSaleListings = _animalSaleListingsForCommercial();
    final publishedAnimalSaleCount = allAnimalSaleListings
        .where((listing) => listing.isPublished)
        .length;
    final soldAnimalSaleCount = allAnimalSaleListings
        .where((listing) => _normalizeLookup(listing.status).contains('vendu'))
        .length;
    final animalSaleRows = _buildAnimalSaleListingRows(allAnimalSaleListings);

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
              const SizedBox(height: AppSpacing.s12),
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
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: cards[1]),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: cards[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: AppSpacing.s10),
                      cards[1],
                      const SizedBox(height: AppSpacing.s10),
                      cards[2],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s12),
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
              const SizedBox(height: AppSpacing.s12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 860;
                  final indicators = [
                    _buildMiniIndicator(
                      label: 'Annonces marché',
                      value: '${allAnimalSaleListings.length}',
                      color: const Color(0xFF0284C7),
                    ),
                    _buildMiniIndicator(
                      label: 'Annonces publiées',
                      value: '$publishedAnimalSaleCount',
                      color: const Color(0xFF15803D),
                    ),
                    _buildMiniIndicator(
                      label: 'Annonces vendues',
                      value: '$soldAnimalSaleCount',
                      color: const Color(0xFFB45309),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: indicators[0]),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: indicators[1]),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: indicators[2]),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      indicators[0],
                      const SizedBox(height: AppSpacing.s10),
                      indicators[1],
                      const SizedBox(height: AppSpacing.s10),
                      indicators[2],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Animaux publiés pour vente',
          subtitle:
              'Marketplace interne: publication, suivi, réservation et statut vendu',
          emptyMessage: 'Aucune annonce animale disponible.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddAnimalSaleListingDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Publier animal'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('PHOTO')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('CATÉGORIE')),
            DataColumn(label: Text('CODE / LOT')),
            DataColumn(label: Text('ANIMAL')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('QTÉ')),
            DataColumn(label: Text('PRIX UNITAIRE')),
            DataColumn(label: Text('VENDEUR')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('LOCALISATION')),
            DataColumn(label: Text('STATUT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: animalSaleRows,
        ),
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
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
    final zootechKpis = _computeZootechKpis();
    final operationalTasks = _buildOperationalTasks();
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
                  badgeLabel: 'Génétique',
                ),
                _buildStatCard(
                  title: 'Truies suivies',
                  value: '${_sows.length}',
                  icon: LucideIcons.piggyBank,
                  color: const Color(0xFF2563EB),
                  badgeLabel: 'Gestation',
                ),
                _buildStatCard(
                  title: 'IA enregistrées',
                  value: '${_inseminations.length}',
                  icon: LucideIcons.syringe,
                  color: const Color(0xFFEA580C),
                  badgeLabel: 'Reproduction',
                ),
                _buildStatCard(
                  title: 'Taux réussite IA',
                  value: '$successRate%',
                  icon: LucideIcons.trendingUp,
                  color: const Color(0xFF16A34A),
                  badgeLabel: 'Performance',
                ),
                _buildStatCard(
                  title: 'Actes santé',
                  value: '${_healthRecords.length}',
                  icon: LucideIcons.shieldCheck,
                  color: const Color(0xFF0F766E),
                  badgeLabel: 'Sanitaire',
                ),
                _buildStatCard(
                  title: 'Diag en retard',
                  value: '$overdueDiagnosisCount',
                  icon: LucideIcons.badgeInfo,
                  color: const Color(0xFFB91C1C),
                  badgeLabel: 'Alerte',
                ),
                _buildStatCard(
                  title: 'Mise-bas <= 14j',
                  value: '$farrowingSoonCount',
                  icon: LucideIcons.piggyBank,
                  color: const Color(0xFFDB2777),
                  badgeLabel: 'Maternité',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildInseminationOutcomeCharts(
          successCount: successCount,
          failedCount: failedCount,
          pendingCount: pendingCount,
          successRate: successRate,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildBreedingActionPlanCard(actionPlan),
        const SizedBox(height: AppSpacing.s16),
        _buildZootechKpiSection(zootechKpis),
        const SizedBox(height: AppSpacing.s16),
        _buildOperationalTasksSection(operationalTasks),
        const SizedBox(height: AppSpacing.s20),
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
                  const SizedBox(width: AppSpacing.s16),
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
                const SizedBox(height: AppSpacing.s16),
                _buildUpcomingHealthCard(nextHealthActions.take(5).toList()),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildPedigreeCoverageCard(),
        const SizedBox(height: AppSpacing.s16),
        _buildBreederAnimalSection(breederAnimalStats),
        const SizedBox(height: AppSpacing.s16),
        _buildExpertRecommendationsCard(expertTips),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? badgeLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE4EE)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.11),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badgeLabel != null && badgeLabel.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
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
              const SizedBox(height: AppSpacing.s10),
              Text(
                'Taux de réussite (dossiers clôturés): $successRate% '
                '($successCount réussies / ${successCount + failedCount})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
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
                const SizedBox(width: AppSpacing.s24),
                Expanded(child: detail),
              ],
            );
          }

          return Column(
            children: [
              donut,
              const SizedBox(height: AppSpacing.s16),
              detail,
            ],
          );
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
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
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
          const SizedBox(height: AppSpacing.s6),
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

  List<_ZootechKpi> _computeZootechKpis() {
    final litterCount = _farrowingRecords.length;
    final totalBornAlive = _farrowingRecords.fold<int>(
      0,
      (sum, record) => sum + record.bornAlive,
    );
    final totalWeaned = _farrowingRecords.fold<int>(
      0,
      (sum, record) => sum + record.weaned,
    );
    final totalPreWeaningDeaths = _farrowingRecords.fold<int>(
      0,
      (sum, record) => sum + record.preWeaningDeaths,
    );
    final avgBornAlive = litterCount == 0 ? 0 : totalBornAlive / litterCount;
    final avgWeaned = litterCount == 0 ? 0 : totalWeaned / litterCount;
    final preWeaningMortality = totalBornAlive <= 0
        ? 0
        : (totalPreWeaningDeaths / totalBornAlive) * 100;

    final successfulIa = _inseminations
        .where((record) => _isSuccessfulStatus(record.status))
        .length;
    final iaFarrowingRate = _inseminations.isEmpty
        ? 0
        : (successfulIa / _inseminations.length) * 100;

    final averageBirthWeight = litterCount == 0
        ? 0
        : _farrowingRecords.fold<double>(
                0,
                (sum, record) => sum + record.avgBirthWeight,
              ) /
              litterCount;

    return [
      _ZootechKpi(
        label: 'Taux mise-bas / IA',
        value: '${iaFarrowingRate.toStringAsFixed(1)}%',
        target: '>= 80%',
        color: iaFarrowingRate >= 80
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309),
      ),
      _ZootechKpi(
        label: 'Nés vivants / portée',
        value: avgBornAlive.toStringAsFixed(1),
        target: '>= 11',
        color: avgBornAlive >= 11
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309),
      ),
      _ZootechKpi(
        label: 'Sevrés / portée',
        value: avgWeaned.toStringAsFixed(1),
        target: '>= 10',
        color: avgWeaned >= 10
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309),
      ),
      _ZootechKpi(
        label: 'Mortalité pré-sevrage',
        value: '${preWeaningMortality.toStringAsFixed(1)}%',
        target: '<= 10%',
        color: preWeaningMortality <= 10
            ? const Color(0xFF15803D)
            : const Color(0xFFB91C1C),
      ),
      _ZootechKpi(
        label: 'Poids naissance moyen',
        value: '${averageBirthWeight.toStringAsFixed(2)} kg',
        target: '>= 1.30 kg',
        color: averageBirthWeight >= 1.30
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309),
      ),
    ];
  }

  Widget _buildZootechKpiSection(List<_ZootechKpi> kpis) {
    return _buildSectionCard(
      title: 'KPI Zootechniques',
      subtitle:
          'Mise-bas, prolificité, sevrage, mortalité pré-sevrage et poids naissance',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width > 1100
              ? 5
              : width > 860
              ? 3
              : width > 560
              ? 2
              : 1;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: kpis
                .map(
                  (kpi) => Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: kpi.color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kpi.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kpi.label,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          kpi.value,
                          style: TextStyle(
                            color: kpi.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Cible ${kpi.target}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  List<_OperationalTaskItem> _buildOperationalTasks() {
    final tasks = <_OperationalTaskItem>[];

    void addTask({
      required String id,
      required DateTime dueDate,
      required String module,
      required String title,
      required String responsible,
      required _ActionPriority priority,
    }) {
      tasks.add(
        _OperationalTaskItem(
          id: id,
          dueDate: _normalizeDate(dueDate),
          module: module,
          title: title,
          responsible: responsible,
          priority: priority,
          done: _taskDoneById[id] ?? false,
        ),
      );
    }

    for (final ia in _inseminations) {
      final ref = '${ia.sowCode}-${ia.boarCode}-${_formatDate(ia.dose1Date)}';
      if (!_isSuccessfulStatus(ia.status) && !_isFailedStatus(ia.status)) {
        final j21 = _expectedHeatReturnDate(ia);
        final j28 = _expectedPregnancyCheckDate(ia);
        final j35 = ia.dose1Date.add(const Duration(days: 35));
        addTask(
          id: 'TASK-IA-J21-$ref',
          dueDate: j21,
          module: 'Reproduction',
          title: 'Contrôle retour chaleur J21 - ${ia.sowCode}',
          responsible: ia.inseminator,
          priority: _priorityFromDueDate(j21),
        );
        addTask(
          id: 'TASK-IA-J28-$ref',
          dueDate: j28,
          module: 'Reproduction',
          title: 'Diagnostic gestation J28 - ${ia.sowCode}',
          responsible: ia.inseminator,
          priority: _priorityFromDueDate(j28),
        );
        addTask(
          id: 'TASK-IA-J35-$ref',
          dueDate: j35,
          module: 'Reproduction',
          title: 'Validation gestation J35 - ${ia.sowCode}',
          responsible: ia.inseminator,
          priority: _priorityFromDueDate(j35),
        );
      }
      if (_isSuccessfulStatus(ia.status)) {
        final j114 = _expectedFarrowingDate(ia);
        addTask(
          id: 'TASK-IA-J114-$ref',
          dueDate: j114,
          module: 'Maternité',
          title: 'Préparer mise-bas J114 - ${ia.sowCode}',
          responsible: _firstUserNameByRole(Roles.breeder),
          priority: _priorityFromDueDate(j114),
        );
      }
    }

    for (final record in _pigletCareRecords) {
      if (record.nextDate == null) {
        continue;
      }
      final taskId =
          'TASK-PC-${record.id}-${_formatDate(record.nextDate!)}-${record.eventType}';
      addTask(
        id: taskId,
        dueDate: record.nextDate!,
        module: 'Porcelets',
        title: 'Rappel ${record.eventType} - ${record.groupName}',
        responsible: record.responsible,
        priority: _priorityFromDueDate(record.nextDate!),
      );
    }

    for (final health in _healthRecords) {
      if (health.nextDate == null) {
        continue;
      }
      final taskId =
          'TASK-H-${health.id}-${_formatDate(health.nextDate!)}-${health.eventType}';
      addTask(
        id: taskId,
        dueDate: health.nextDate!,
        module: 'Santé',
        title:
            '${health.eventType} ${health.animalType} ${health.animalCode} (${health.product})',
        responsible: health.responsible,
        priority: _priorityFromDueDate(health.nextDate!),
      );
    }

    for (final farrowing in _farrowingRecords) {
      final weaningDate = farrowing.farrowingDate.add(const Duration(days: 28));
      addTask(
        id: 'TASK-FAR-SEVRAGE-${farrowing.id}-${_formatDate(weaningDate)}',
        dueDate: weaningDate,
        module: 'Maternité',
        title: 'Sevrage portée ${farrowing.sowCode}',
        responsible: farrowing.responsible,
        priority: _priorityFromDueDate(weaningDate),
      );
      if (farrowing.preWeaningDeaths > 0 ||
          farrowing.majorIssue.trim().isNotEmpty) {
        final reviewDate = farrowing.farrowingDate.add(const Duration(days: 1));
        addTask(
          id: 'TASK-FAR-REVUE-${farrowing.id}-${_formatDate(reviewDate)}',
          dueDate: reviewDate,
          module: 'Maternité',
          title: 'Revue pertes néonatales ${farrowing.sowCode}',
          responsible: _firstUserNameByRole(Roles.vet),
          priority: _ActionPriority.high,
        );
      }
    }

    tasks.sort((a, b) {
      final byDone = a.done == b.done
          ? 0
          : (a.done ? 1 : -1); // open tasks first
      if (byDone != 0) {
        return byDone;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return tasks;
  }

  void _toggleOperationalTask(_OperationalTaskItem task, bool done) {
    setState(() => _taskDoneById[task.id] = done);
    _addAuditLog(
      module: 'TASKS',
      action: done ? 'TASK_DONE' : 'TASK_REOPEN',
      detail: '${task.module} • ${task.title}',
      severity: done ? 'INFO' : 'WARN',
    );
    _persistState();
  }

  Widget _buildOperationalTasksSection(List<_OperationalTaskItem> tasks) {
    final rows = tasks
        .take(20)
        .map(
          (task) => DataRow(
            cells: [
              DataCell(Text(_formatDate(task.dueDate))),
              DataCell(Text(task.module)),
              DataCell(
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: task.done ? FontWeight.w500 : FontWeight.w700,
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              DataCell(Text(task.responsible)),
              DataCell(_buildPriorityBadge(task.priority)),
              DataCell(
                Checkbox(
                  value: task.done,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _toggleOperationalTask(task, value);
                  },
                ),
              ),
            ],
          ),
        )
        .toList();

    return _buildDataTableSection(
      title: 'Tâches opérationnelles (terrain)',
      subtitle:
          'Pilotage exécution: J21/J28/J35/J114, rappels santé et prise en charge porcelets',
      emptyMessage: 'Aucune tâche générée.',
      columns: const [
        DataColumn(label: Text('ÉCHÉANCE')),
        DataColumn(label: Text('MODULE')),
        DataColumn(label: Text('ACTION')),
        DataColumn(label: Text('RESPONSABLE')),
        DataColumn(label: Text('PRIORITÉ')),
        DataColumn(label: Text('FAIT')),
      ],
      rows: rows,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s5,
      ),
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
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.s2),
                      child: Icon(
                        LucideIcons.badgeInfo,
                        size: 16,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 760;
          final cards = [
            _buildMiniIndicator(
              label: 'Père renseigné',
              value: '$sireRate%',
              color: const Color(0xFF2563EB),
            ),
            _buildMiniIndicator(
              label: 'Mère renseignée',
              value: '$damRate%',
              color: const Color(0xFF7C3AED),
            ),
            _buildMiniIndicator(
              label: 'Animaux suivis',
              value: '$totalAnimals',
              color: const Color(0xFF0F766E),
            ),
          ];

          if (isWide) {
            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: cards[1]),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: cards[2]),
              ],
            );
          }

          return Column(
            children: [
              cards[0],
              const SizedBox(height: AppSpacing.s10),
              cards[1],
              const SizedBox(height: AppSpacing.s10),
              cards[2],
            ],
          );
        },
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

  List<_InseminatorRecap> _computeInseminatorRecaps() {
    final inseminators = _users
        .where((user) => user.role == Roles.inseminator)
        .toList();

    final recaps = inseminators.map((inseminator) {
      final records = _inseminations
          .where((record) => _recordMatchesInseminator(record, inseminator))
          .toList();
      final successCount = records
          .where((record) => _isSuccessfulStatus(record.status))
          .length;
      final failedCount = records
          .where((record) => _isFailedStatus(record.status))
          .length;
      final totalCost = records.fold<double>(
        0,
        (sum, record) => sum + _estimatedIaCost(record),
      );

      return _InseminatorRecap(
        user: inseminator,
        totalIa: records.length,
        successIa: successCount,
        failedIa: failedCount,
        totalIaCost: totalCost,
      );
    }).toList();

    recaps.sort((a, b) {
      final byIaCount = b.totalIa.compareTo(a.totalIa);
      if (byIaCount != 0) {
        return byIaCount;
      }
      return a.user.name.compareTo(b.user.name);
    });

    return recaps;
  }

  List<_BreederIaRecap> _computeBreederIaRecaps() {
    final breeders = _users
        .where((user) => user.role == Roles.breeder)
        .toList();
    final today = _currentDate();

    final recaps = breeders.map((breeder) {
      final breederSows = _sows
          .where((sow) => sow.breederId.trim() == breeder.id.trim())
          .toList();
      final breederSowCodes = breederSows
          .map((sow) => _normalizeLookup(sow.code))
          .toSet();
      final breederRecords = _inseminations
          .where(
            (record) =>
                breederSowCodes.contains(_normalizeLookup(record.sowCode)),
          )
          .toList();

      final successCount = breederRecords
          .where((record) => _isSuccessfulStatus(record.status))
          .length;
      final failedCount = breederRecords
          .where((record) => _isFailedStatus(record.status))
          .length;

      var sowsToInseminate = 0;
      for (final sow in breederSows) {
        final latestRecord = _latestInseminationForSow(sow.code);
        if (latestRecord == null) {
          sowsToInseminate++;
          continue;
        }
        if (_isFailedStatus(latestRecord.status)) {
          sowsToInseminate++;
          continue;
        }
        if (_isSuccessfulStatus(latestRecord.status)) {
          continue;
        }
        final diagnosisLimit = _expectedPregnancyCheckDate(
          latestRecord,
        ).add(const Duration(days: 7));
        if (today.isAfter(diagnosisLimit)) {
          sowsToInseminate++;
        }
      }

      return _BreederIaRecap(
        user: breeder,
        sowsToInseminate: sowsToInseminate,
        successIa: successCount,
        failedIa: failedCount,
      );
    }).toList();

    recaps.sort((a, b) {
      final bySows = b.sowsToInseminate.compareTo(a.sowsToInseminate);
      if (bySows != 0) {
        return bySows;
      }
      return a.user.name.compareTo(b.user.name);
    });

    return recaps;
  }

  List<_BreederControlRecap> _computeBreederControlRecaps() {
    final breeders = _users
        .where((user) => user.role == Roles.breeder)
        .toList();
    final today = _currentDate();
    final controlRows = <_BreederControlRecap>[];

    for (final breeder in breeders) {
      final boars = _boars
          .where((boar) => boar.breederId.trim() == breeder.id.trim())
          .toList();
      final sows = _sows
          .where((sow) => sow.breederId.trim() == breeder.id.trim())
          .toList();
      final sowCodes = sows.map((sow) => _normalizeLookup(sow.code)).toSet();
      final breederIaRecords = _inseminations
          .where(
            (record) => sowCodes.contains(_normalizeLookup(record.sowCode)),
          )
          .toList();

      final overdueIaDiagnosis = breederIaRecords.where((record) {
        if (_isSuccessfulStatus(record.status) ||
            _isFailedStatus(record.status)) {
          return false;
        }
        final dueDate = _expectedPregnancyCheckDate(
          record,
        ).add(const Duration(days: 7));
        return today.isAfter(dueDate);
      }).length;

      final overdueHealthActions = _healthRecords.where((record) {
        if (record.nextDate == null) {
          return false;
        }
        final breederId = _breederIdForAnimal(
          animalType: record.animalType,
          animalCode: record.animalCode,
        );
        if (breederId != breeder.id) {
          return false;
        }
        return today.isAfter(record.nextDate!);
      }).length;

      controlRows.add(
        _BreederControlRecap(
          user: breeder,
          boarCount: boars.length,
          sowCount: sows.length,
          iaCount: breederIaRecords.length,
          overdueIaDiagnosis: overdueIaDiagnosis,
          overdueHealthActions: overdueHealthActions,
        ),
      );
    }

    controlRows.sort((a, b) {
      final byRisk = b.riskScore.compareTo(a.riskScore);
      if (byRisk != 0) {
        return byRisk;
      }
      return a.user.name.compareTo(b.user.name);
    });

    return controlRows;
  }

  List<_DistrictPerformanceRecap> _computeDistrictPerformanceRecaps() {
    final recapsByDistrict = <String, _DistrictPerformanceAccumulator>{};
    final today = _currentDate();

    for (final inseminator in _users.where(
      (user) => user.role == Roles.inseminator,
    )) {
      final district = inseminator.district.trim().isEmpty
          ? 'District non renseigné'
          : inseminator.district.trim();
      final region = inseminator.region.trim().isEmpty
          ? 'Région non renseignée'
          : inseminator.region.trim();
      final key = '${region.toLowerCase()}|${district.toLowerCase()}';
      final acc = recapsByDistrict.putIfAbsent(
        key,
        () =>
            _DistrictPerformanceAccumulator(region: region, district: district),
      );
      acc.inseminators.add(inseminator.id);

      final records = _inseminations
          .where((record) => _recordMatchesInseminator(record, inseminator))
          .toList();
      for (final record in records) {
        acc.totalIa++;
        if (_isSuccessfulStatus(record.status)) {
          acc.successIa++;
        }
        if (_isFailedStatus(record.status)) {
          acc.failedIa++;
        }
        if (!_isSuccessfulStatus(record.status) &&
            !_isFailedStatus(record.status)) {
          final diagnosisLimit = _expectedPregnancyCheckDate(
            record,
          ).add(const Duration(days: 7));
          if (today.isAfter(diagnosisLimit)) {
            acc.overdueDiagnosis++;
          }
        }
      }
    }

    final result = recapsByDistrict.values
        .map(
          (acc) => _DistrictPerformanceRecap(
            region: acc.region,
            district: acc.district,
            inseminators: acc.inseminators.length,
            totalIa: acc.totalIa,
            successIa: acc.successIa,
            failedIa: acc.failedIa,
            overdueDiagnosis: acc.overdueDiagnosis,
          ),
        )
        .toList();
    result.sort((a, b) {
      final byIa = b.totalIa.compareTo(a.totalIa);
      if (byIa != 0) {
        return byIa;
      }
      return a.district.compareTo(b.district);
    });
    return result;
  }

  List<_BreederQualityRecap> _computeBreederDataQualityRecaps() {
    final breeders = _users
        .where((user) => user.role == Roles.breeder)
        .toList();
    final recaps = <_BreederQualityRecap>[];

    for (final breeder in breeders) {
      final sows = _sows
          .where((sow) => sow.breederId.trim() == breeder.id.trim())
          .toList();
      final completePedigree = sows
          .where(
            (sow) =>
                sow.sireCode.trim().isNotEmpty && sow.damCode.trim().isNotEmpty,
          )
          .length;

      final sowsWithIaPlan = sows.where((sow) {
        final latest = _latestInseminationForSow(sow.code);
        return latest != null;
      }).length;

      final healthRecordsForBreeder = _healthRecords.where((record) {
        final breederId = _breederIdForAnimal(
          animalType: record.animalType,
          animalCode: record.animalCode,
        );
        return breederId == breeder.id;
      }).toList();
      final healthWithNext = healthRecordsForBreeder
          .where((record) => record.nextDate != null)
          .length;
      final healthCoverage = healthRecordsForBreeder.isEmpty
          ? 0
          : ((healthWithNext / healthRecordsForBreeder.length) * 100).round();

      final pedigreeScore = sows.isEmpty
          ? 0
          : ((completePedigree / sows.length) * 100).round();
      final iaPlanScore = sows.isEmpty
          ? 0
          : ((sowsWithIaPlan / sows.length) * 100).round();
      final qualityScore =
          ((pedigreeScore * 0.4) +
                  (iaPlanScore * 0.35) +
                  (healthCoverage * 0.25))
              .round();

      recaps.add(
        _BreederQualityRecap(
          user: breeder,
          sowCount: sows.length,
          sowsWithCompletePedigree: completePedigree,
          sowsWithIaPlan: sowsWithIaPlan,
          healthCoverageRate: healthCoverage,
          qualityScore: qualityScore,
        ),
      );
    }

    recaps.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    return recaps;
  }

  String _territoryLabel(UserProfile user) {
    final parts = <String>[
      user.fokontany.trim(),
      user.commune.trim(),
      user.district.trim(),
      user.region.trim(),
    ].where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '-';
    }
    return parts.join(' / ');
  }

  String _breederIdForAnimal({
    required String animalType,
    required String animalCode,
  }) {
    final normalizedCode = _normalizeLookup(animalCode);
    final isSowType = _normalizeLookup(animalType).contains('truie');
    if (isSowType) {
      for (final sow in _sows) {
        if (_normalizeLookup(sow.code) == normalizedCode) {
          return sow.breederId.trim();
        }
      }
      return '';
    }
    for (final boar in _boars) {
      if (_normalizeLookup(boar.code) == normalizedCode) {
        return boar.breederId.trim();
      }
    }
    return '';
  }

  bool _recordMatchesInseminator(
    InseminationRecord record,
    UserProfile inseminator,
  ) {
    final raw = _normalizeLookup(record.inseminator);
    if (raw.isEmpty) {
      return false;
    }
    final byName = _normalizeLookup(inseminator.name);
    final byCode = _normalizeLookup(inseminator.code);
    final byLogin = _normalizeLookup(inseminator.login);

    if (raw == byName || raw == byCode || raw == byLogin) {
      return true;
    }
    return byName.isNotEmpty && raw.contains(byName);
  }

  String _normalizeLookup(String value) => value.trim().toLowerCase();

  double _estimatedIaCost(InseminationRecord record) {
    var cost = 35000.0;
    if (record.dose2Date != null) {
      cost += 12000;
    }
    final boar = _findBoar(record.boarCode);
    if (boar != null &&
        boar.semenType.trim().toLowerCase().contains('congel')) {
      cost += 8000;
    }
    return cost;
  }

  InseminationRecord? _latestInseminationForSow(String sowCode) {
    final normalizedSowCode = _normalizeLookup(sowCode);
    InseminationRecord? latest;

    for (final record in _inseminations) {
      if (_normalizeLookup(record.sowCode) != normalizedSowCode) {
        continue;
      }
      if (latest == null || record.dose1Date.isAfter(latest.dose1Date)) {
        latest = record;
      }
    }

    return latest;
  }

  List<_SemenLotRecap> _computeSemenLotRecaps() {
    final byLot = <String, _SemenLotRecapBuilder>{};

    for (final record in _inseminations) {
      final lot = record.semenLot.trim().isEmpty
          ? 'LOT-UNKNOWN'
          : record.semenLot.trim();
      final key = '${lot.toLowerCase()}::${record.boarCode.toLowerCase()}';
      final builder = byLot.putIfAbsent(
        key,
        () => _SemenLotRecapBuilder(
          lot: lot,
          boarCode: record.boarCode,
          boarBreed: _findBoar(record.boarCode)?.breed ?? 'Race inconnue',
        ),
      );
      builder.totalIa += 1;
      builder.totalDoses += record.dose2Date == null ? 1 : 2;
      if (_isSuccessfulStatus(record.status)) {
        builder.successIa += 1;
      } else if (_isFailedStatus(record.status)) {
        builder.failedIa += 1;
      }
    }

    final recaps = byLot.values
        .map(
          (item) => _SemenLotRecap(
            lot: item.lot,
            boarCode: item.boarCode,
            boarBreed: item.boarBreed,
            totalIa: item.totalIa,
            totalDoses: item.totalDoses,
            successIa: item.successIa,
            failedIa: item.failedIa,
          ),
        )
        .toList();

    recaps.sort((a, b) {
      final byIa = b.totalIa.compareTo(a.totalIa);
      if (byIa != 0) {
        return byIa;
      }
      return a.lot.compareTo(b.lot);
    });

    return recaps;
  }

  List<_SowIaFollowUp> _computeSowIaFollowUps() {
    final followUps = <_SowIaFollowUp>[];

    for (final sow in _sows) {
      final latest = _latestInseminationForSow(sow.code);
      if (latest == null) {
        followUps.add(
          _SowIaFollowUp(
            sow: sow,
            lastInseminationDateLabel: '-',
            statusLabel: 'À programmer',
            statusColor: const Color(0xFFB45309),
            nextAction: 'Planifier IA',
            nextDateLabel: 'Dès que chaleur détectée',
          ),
        );
        continue;
      }

      if (_isFailedStatus(latest.status)) {
        final retryDate = _expectedHeatReturnDate(latest);
        followUps.add(
          _SowIaFollowUp(
            sow: sow,
            lastInseminationDateLabel: _formatDate(latest.dose1Date),
            statusLabel: 'Échec / ré-IA',
            statusColor: const Color(0xFFB91C1C),
            nextAction: 'Reprogrammer insémination',
            nextDateLabel: _formatDate(retryDate),
          ),
        );
        continue;
      }

      if (_isSuccessfulStatus(latest.status)) {
        final farrowingDate = _expectedFarrowingDate(latest);
        followUps.add(
          _SowIaFollowUp(
            sow: sow,
            lastInseminationDateLabel: _formatDate(latest.dose1Date),
            statusLabel: 'Gestante confirmée',
            statusColor: const Color(0xFF15803D),
            nextAction: 'Préparer mise-bas',
            nextDateLabel: _formatDate(farrowingDate),
          ),
        );
        continue;
      }

      final diagnosisDate = _expectedPregnancyCheckDate(latest);
      followUps.add(
        _SowIaFollowUp(
          sow: sow,
          lastInseminationDateLabel: _formatDate(latest.dose1Date),
          statusLabel: 'En attente diagnostic',
          statusColor: const Color(0xFF0F766E),
          nextAction: 'Diagnostic gestation J28',
          nextDateLabel: _formatDate(diagnosisDate),
        ),
      );
    }

    followUps.sort((a, b) {
      final byStatus = a.statusLabel.compareTo(b.statusLabel);
      if (byStatus != 0) {
        return byStatus;
      }
      return a.sow.code.compareTo(b.sow.code);
    });

    return followUps;
  }

  Widget _buildMiniIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
          const SizedBox(height: AppSpacing.s8),
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
    final semenLotRecaps = _computeSemenLotRecaps();
    final semenQualityRows = _semenQualityRecords
        .map(
          (record) => DataRow(
            cells: [
              DataCell(Text(_formatDate(record.collectionDate))),
              DataCell(Text(record.lotCode)),
              DataCell(Text(record.boarCode)),
              DataCell(
                Text('${record.concentration.toStringAsFixed(2)} Md/ml'),
              ),
              DataCell(Text('${record.motilityPercent.toStringAsFixed(0)}%')),
              DataCell(Text('${record.temperatureC.toStringAsFixed(1)} °C')),
              DataCell(Text('${record.storageHours} h')),
              DataCell(Text(record.approvedBy)),
              DataCell(
                Text(
                  _semenQualityStatus(record),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _semenQualityStatus(record) == 'Conforme'
                        ? const Color(0xFF15803D)
                        : _semenQualityStatus(record) == 'Surveiller'
                        ? const Color(0xFFB45309)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier contrôle semence',
                      onPressed: () => _showEditSemenQualityDialog(record),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer contrôle semence',
                      onPressed: () => _deleteSemenQualityRecord(record.id),
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
    final semenRows = semenLotRecaps
        .map(
          (recap) => DataRow(
            cells: [
              DataCell(Text(recap.lot)),
              DataCell(Text(recap.boarCode)),
              DataCell(Text(recap.boarBreed)),
              DataCell(Text('${recap.totalDoses}')),
              DataCell(Text('${recap.totalIa}')),
              DataCell(Text('${recap.successIa}')),
              DataCell(Text('${recap.failedIa}')),
              DataCell(
                Text(
                  '${recap.successRate}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DataCell(
                Text(
                  recap.qualityLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: recap.qualityLabel == 'Surveiller'
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
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
        _buildGestationCalendarSection(),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Qualité semence (contrôle laboratoire)',
          subtitle:
              'Chaîne froide, concentration, motilité et durée de conservation par lot',
          emptyMessage: 'Aucun contrôle qualité semence.',
          actions: [
            FilledButton.icon(
              onPressed: _showAddSemenQualityDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Ajouter contrôle semence'),
            ),
          ],
          columns: const [
            DataColumn(label: Text('DATE COLLECTE')),
            DataColumn(label: Text('LOT')),
            DataColumn(label: Text('VERRAT')),
            DataColumn(label: Text('CONCENTRATION')),
            DataColumn(label: Text('MOTILITÉ')),
            DataColumn(label: Text('TEMPÉRATURE')),
            DataColumn(label: Text('STOCKAGE')),
            DataColumn(label: Text('VALIDÉ PAR')),
            DataColumn(label: Text('STATUT')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: semenQualityRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Suivi semence (lots IA)',
          subtitle:
              'Traçabilité des doses par lot, performance et qualité d\'utilisation',
          emptyMessage: 'Aucun lot semence utilisé.',
          columns: const [
            DataColumn(label: Text('LOT SEMENCE')),
            DataColumn(label: Text('VERRAT')),
            DataColumn(label: Text('RACE')),
            DataColumn(label: Text('DOSES UTILISÉES')),
            DataColumn(label: Text('IA RÉALISÉES')),
            DataColumn(label: Text('IA RÉUSSIES')),
            DataColumn(label: Text('IA ÉCHECS')),
            DataColumn(label: Text('TAUX RÉUSSITE')),
            DataColumn(label: Text('STATUT QUALITÉ')),
          ],
          rows: semenRows,
        ),
        const SizedBox(height: AppSpacing.s16),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final compactCalendar = screenWidth < 760;
    final tinyCalendar = screenWidth < 440;

    return _buildSectionCard(
      title: 'Calendrier de gestation porcine',
      subtitle:
          'Vue mensuelle des échéances IA, retour chaleur J21, diagnostic J28, mise-bas J114',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tinyCalendar)
            Column(
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
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mois suivant',
                      onPressed: () => _changeGestationCalendarMonth(1),
                      icon: const Icon(LucideIcons.chevronRight),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.today_outlined, size: 14),
                    label: const Text('Aujourd\'hui'),
                  ),
                ),
              ],
            )
          else
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
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: compactCalendar ? 14 : 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mois suivant',
                  onPressed: () => _changeGestationCalendarMonth(1),
                  icon: const Icon(LucideIcons.chevronRight),
                ),
                const SizedBox(width: AppSpacing.s8),
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
          const SizedBox(height: AppSpacing.s8),
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
          const SizedBox(height: AppSpacing.s12),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = tinyCalendar ? 3.0 : (compactCalendar ? 4.0 : 6.0);
              final availableWidth = math.max(220.0, constraints.maxWidth);
              final cellWidth = (availableWidth - (gap * 6)) / 7;
              final targetCellHeight = tinyCalendar
                  ? 42.0
                  : (compactCalendar ? 50.0 : 62.0);
              final childAspectRatio = (cellWidth / targetCellHeight).clamp(
                1.35,
                3.5,
              );

              return Column(
                children: [
                  Row(
                    children: weekDays
                        .map(
                          (dayName) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compactCalendar
                                    ? AppSpacing.s4
                                    : AppSpacing.s6,
                              ),
                              child: Text(
                                dayName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: tinyCalendar
                                      ? 10
                                      : (compactCalendar ? 11 : 12),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
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
                      final isSelected = _isSameDate(
                        normalizedDay,
                        selectedDate,
                      );
                      final isToday = _isSameDate(
                        normalizedDay,
                        _currentDate(),
                      );

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(
                            () => _selectedGestationDate = normalizedDay,
                          );
                          _persistState();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.all(
                            tinyCalendar
                                ? AppSpacing.s3
                                : (compactCalendar
                                      ? AppSpacing.s4
                                      : AppSpacing.s6),
                          ),
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
                                        fontSize: tinyCalendar ? 11 : 12,
                                        color: isToday
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (dayEvents.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.s4,
                                        vertical: AppSpacing.s1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${dayEvents.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: tinyCalendar ? 8 : 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              if (dayEvents.isNotEmpty)
                                Wrap(
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: dayEvents
                                      .take(
                                        tinyCalendar
                                            ? 2
                                            : (compactCalendar ? 3 : 4),
                                      )
                                      .map(
                                        (event) => _buildDayMarker(event.color),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s14),
          _buildSelectedGestationDayCard(selectedDate, selectedEvents),
        ],
      ),
    );
  }

  Widget _buildPigletCareCalendarSection() {
    final monthStart = DateTime(
      _pigletCalendarMonth.year,
      _pigletCalendarMonth.month,
      1,
    );
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leadingEmptyCells = monthStart.weekday - 1;
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final eventsByDay = _buildPigletCareCalendarEvents();
    final selectedDate = _selectedPigletDate == null
        ? _currentDate()
        : _normalizeDate(_selectedPigletDate!);
    final selectedEvents =
        eventsByDay[_normalizeDate(selectedDate)] ??
        const <_GestationCalendarEvent>[];
    const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final screenWidth = MediaQuery.of(context).size.width;
    final compactCalendar = screenWidth < 760;
    final tinyCalendar = screenWidth < 440;

    return _buildSectionCard(
      title: 'Calendrier prise en charge porcelets',
      subtitle:
          'Vue mensuelle des soins néonataux, rappels et actions de sevrage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tinyCalendar)
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mois précédent',
                      onPressed: () => _changePigletCalendarMonth(-1),
                      icon: const Icon(LucideIcons.chevronLeft),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', 'fr_FR').format(monthStart),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mois suivant',
                      onPressed: () => _changePigletCalendarMonth(1),
                      icon: const Icon(LucideIcons.chevronRight),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final today = _currentDate();
                      setState(() {
                        _pigletCalendarMonth = DateTime(
                          today.year,
                          today.month,
                          1,
                        );
                        _selectedPigletDate = today;
                      });
                      _persistState();
                    },
                    icon: const Icon(Icons.today_outlined, size: 14),
                    label: const Text('Aujourd\'hui'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                IconButton(
                  tooltip: 'Mois précédent',
                  onPressed: () => _changePigletCalendarMonth(-1),
                  icon: const Icon(LucideIcons.chevronLeft),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy', 'fr_FR').format(monthStart),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: compactCalendar ? 14 : 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mois suivant',
                  onPressed: () => _changePigletCalendarMonth(1),
                  icon: const Icon(LucideIcons.chevronRight),
                ),
                const SizedBox(width: AppSpacing.s8),
                OutlinedButton(
                  onPressed: () {
                    final today = _currentDate();
                    setState(() {
                      _pigletCalendarMonth = DateTime(
                        today.year,
                        today.month,
                        1,
                      );
                      _selectedPigletDate = today;
                    });
                    _persistState();
                  },
                  child: const Text('Aujourd\'hui'),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGestationLegendChip(
                label: 'Soin',
                color: const Color(0xFF0F766E),
              ),
              _buildGestationLegendChip(
                label: 'Rappel',
                color: const Color(0xFFB45309),
              ),
              _buildGestationLegendChip(
                label: 'Alerte',
                color: const Color(0xFFB91C1C),
              ),
              _buildGestationLegendChip(
                label: 'Protocole',
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = tinyCalendar ? 3.0 : (compactCalendar ? 4.0 : 6.0);
              final availableWidth = math.max(220.0, constraints.maxWidth);
              final cellWidth = (availableWidth - (gap * 6)) / 7;
              final targetCellHeight = tinyCalendar
                  ? 42.0
                  : (compactCalendar ? 50.0 : 62.0);
              final childAspectRatio = (cellWidth / targetCellHeight).clamp(
                1.35,
                3.5,
              );

              return Column(
                children: [
                  Row(
                    children: weekDays
                        .map(
                          (dayName) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compactCalendar
                                    ? AppSpacing.s4
                                    : AppSpacing.s6,
                              ),
                              child: Text(
                                dayName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: tinyCalendar
                                      ? 10
                                      : (compactCalendar ? 11 : 12),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
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
                      final isSelected = _isSameDate(
                        normalizedDay,
                        selectedDate,
                      );
                      final isToday = _isSameDate(
                        normalizedDay,
                        _currentDate(),
                      );

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() => _selectedPigletDate = normalizedDay);
                          _persistState();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.all(
                            tinyCalendar
                                ? AppSpacing.s3
                                : (compactCalendar
                                      ? AppSpacing.s4
                                      : AppSpacing.s6),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFEA580C)
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
                                        fontSize: tinyCalendar ? 11 : 12,
                                        color: isToday
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (dayEvents.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.s4,
                                        vertical: AppSpacing.s1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C2D12),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${dayEvents.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: tinyCalendar ? 8 : 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              if (dayEvents.isNotEmpty)
                                Wrap(
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: dayEvents
                                      .take(
                                        tinyCalendar
                                            ? 2
                                            : (compactCalendar ? 3 : 4),
                                      )
                                      .map(
                                        (event) => _buildDayMarker(event.color),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s14),
          _buildSelectedPigletDayCard(selectedDate, selectedEvents),
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
      padding: const EdgeInsets.all(AppSpacing.s14),
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
          const SizedBox(height: AppSpacing.s8),
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
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(event.icon, size: 16, color: event.color),
                    const SizedBox(width: AppSpacing.s8),
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

  Widget _buildSelectedPigletDayCard(
    DateTime selectedDate,
    List<_GestationCalendarEvent> events,
  ) {
    final compact = MediaQuery.of(context).size.width < 520;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suivi porcelets du ${_formatDate(selectedDate)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showAddPigletCareDialog(initialDate: selectedDate),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('Ajouter'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Suivi porcelets du ${_formatDate(selectedDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _showAddPigletCareDialog(initialDate: selectedDate),
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.s10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _showAddPigletCareDialog(
                  initialDate: selectedDate,
                  initialEventType: 'Coupe dents',
                  initialDetails: 'Coupe dents porcelets',
                ),
                child: const Text('Coupe dents'),
              ),
              OutlinedButton(
                onPressed: () => _showAddPigletCareDialog(
                  initialDate: selectedDate,
                  initialEventType: 'Supplémentation fer',
                  initialDetails: 'Injection fer porcelets',
                ),
                child: const Text('Injection fer'),
              ),
              OutlinedButton(
                onPressed: () => _showAddPigletCareDialog(
                  initialDate: selectedDate,
                  initialEventType: 'Vaccination porcelets',
                  initialDetails: 'Vaccination porcelets',
                ),
                child: const Text('Vaccination'),
              ),
              OutlinedButton(
                onPressed: () => _showAddPigletCareDialog(
                  initialDate: selectedDate,
                  initialEventType: 'Sevrage',
                  initialDetails: 'Sevrage et transfert post-sevrage',
                ),
                child: const Text('Sevrage'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          if (events.isEmpty)
            const Text(
              'Aucun suivi porcelet planifié sur cette date.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(event.icon, size: 16, color: event.color),
                    const SizedBox(width: AppSpacing.s8),
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
    final compact = MediaQuery.of(context).size.width < 460;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.s8 : AppSpacing.s10,
        vertical: compact ? AppSpacing.s5 : AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDayMarker(color),
          const SizedBox(width: AppSpacing.s6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 11 : 12,
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
        const SizedBox(height: AppSpacing.s16),
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
      padding: const EdgeInsets.all(AppSpacing.s14),
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
              const SizedBox(width: AppSpacing.s10),
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
          const SizedBox(height: AppSpacing.s10),
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

    final bytes = _decodeImageBytesCached(boar.imageBase64);
    if (bytes == null) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
    );
  }

  Widget _buildSowPhoto(Sow sow, {double size = 52}) {
    if (sow.imageBase64.trim().isEmpty) {
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

    final bytes = _decodeImageBytesCached(sow.imageBase64);
    if (bytes == null) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
    );
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
    final bytes = _decodeImageBytesCached(imageBase64);
    if (bytes == null) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
    );
  }

  Widget _buildSowManagement() {
    final rows = _sows
        .map(
          (sow) => DataRow(
            cells: [
              DataCell(_buildSowPhoto(sow, size: 44)),
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
    final sowFollowUps = _computeSowIaFollowUps();
    final followUpRows = sowFollowUps
        .map(
          (item) => DataRow(
            cells: [
              DataCell(Text(item.sow.code)),
              DataCell(Text(item.sow.name)),
              DataCell(Text(_breederNameForId(item.sow.breederId))),
              DataCell(Text(item.lastInseminationDateLabel)),
              DataCell(
                Text(
                  item.statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: item.statusColor,
                  ),
                ),
              ),
              DataCell(Text(item.nextAction)),
              DataCell(Text(item.nextDateLabel)),
            ],
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataTableSection(
          title: 'Suivi truies pour IA',
          subtitle:
              'Pilotage des reproductrices: dernière IA, statut et prochaine action',
          emptyMessage: 'Aucune truie suivie pour IA.',
          columns: const [
            DataColumn(label: Text('CODE')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('ÉLEVEUR')),
            DataColumn(label: Text('DERNIÈRE IA')),
            DataColumn(label: Text('STATUT IA')),
            DataColumn(label: Text('PROCHAINE ACTION')),
            DataColumn(label: Text('DATE CIBLE')),
          ],
          rows: followUpRows,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Gestion des truies',
          subtitle:
              'Suivi reproductrices, photo, parité et informations de lignée',
          emptyMessage: 'Aucune truie enregistrée.',
          columns: const [
            DataColumn(label: Text('PHOTO')),
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
        ),
      ],
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
    var riskyPairings = 0;
    var safePairings = 0;
    for (final sow in _sows) {
      for (final boar in _boars) {
        final issue = _consanguinityIssue(sow.code, boar.code);
        if (issue == null) {
          safePairings++;
        } else {
          riskyPairings++;
        }
      }
    }

    final consanguinityAlerts = <_ConsanguinityAlert>[];
    for (final record in _inseminations) {
      final issue = _consanguinityIssue(record.sowCode, record.boarCode);
      if (issue == null) {
        continue;
      }
      consanguinityAlerts.add(
        _ConsanguinityAlert(
          date: record.dose1Date,
          sowCode: record.sowCode,
          boarCode: record.boarCode,
          status: record.status,
          issue: issue,
        ),
      );
    }
    consanguinityAlerts.sort((a, b) => b.date.compareTo(a.date));

    final alertRows = consanguinityAlerts
        .map(
          (alert) => DataRow(
            cells: [
              DataCell(Text(_formatDate(alert.date))),
              DataCell(Text(alert.sowCode)),
              DataCell(Text(alert.boarCode)),
              DataCell(Text(alert.status)),
              DataCell(
                Text(
                  alert.issue,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
    final pedigreeNodes = _allPedigreeNodes();
    final selectedPedigreeCode = _resolveSelectedPedigreeCode(
      _selectedPedigreeAnimalCode,
      pedigreeNodes,
    );
    final selectedNode = selectedPedigreeCode == null
        ? null
        : _pedigreeNodeByCode(selectedPedigreeCode);
    final sireNode = selectedNode == null
        ? null
        : _pedigreeNodeByCode(selectedNode.sireCode);
    final damNode = selectedNode == null
        ? null
        : _pedigreeNodeByCode(selectedNode.damCode);
    final paternalSireNode = sireNode == null
        ? null
        : _pedigreeNodeByCode(sireNode.sireCode);
    final paternalDamNode = sireNode == null
        ? null
        : _pedigreeNodeByCode(sireNode.damCode);
    final maternalSireNode = damNode == null
        ? null
        : _pedigreeNodeByCode(damNode.sireCode);
    final maternalDamNode = damNode == null
        ? null
        : _pedigreeNodeByCode(damNode.damCode);
    final knownAncestors = [
      sireNode,
      damNode,
      paternalSireNode,
      paternalDamNode,
      maternalSireNode,
      maternalDamNode,
    ].whereType<_PedigreeTreeNode>().length;
    final missingAncestors = math.max(0, 6 - knownAncestors);
    final ancestryCoverage = ((knownAncestors / 6) * 100).round();

    return Column(
      children: [
        _buildSectionCard(
          title: 'Gestion pedigree',
          subtitle:
              'Arbre généalogique visuel (animal, parents et grands-parents)',
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
        const SizedBox(height: AppSpacing.s16),
        _buildSectionCard(
          title: 'Arbre généalogique détaillé',
          subtitle:
              'Sélectionnez un animal pour visualiser sa lignée complète sur 3 générations',
          child: pedigreeNodes.isEmpty
              ? _buildEmptyState(
                  'Aucun animal disponible pour construire un arbre généalogique.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedPedigreeCode,
                      decoration: const InputDecoration(
                        labelText: 'Animal racine',
                        helperText: 'Code, nom et type de l\'animal à analyser',
                        border: OutlineInputBorder(),
                      ),
                      items: pedigreeNodes
                          .map(
                            (node) => DropdownMenuItem<String>(
                              value: node.code,
                              child: Text(
                                '${node.code} • ${node.name} (${node.type})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedPedigreeAnimalCode = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 860;
                        final indicators = [
                          _buildMiniIndicator(
                            label: 'Ascendants trouvés',
                            value: '$knownAncestors / 6',
                            color: const Color(0xFF2563EB),
                          ),
                          _buildMiniIndicator(
                            label: 'Liens manquants',
                            value: '$missingAncestors',
                            color: const Color(0xFFB45309),
                          ),
                          _buildMiniIndicator(
                            label: 'Couverture lignée',
                            value: '$ancestryCoverage%',
                            color: const Color(0xFF15803D),
                          ),
                        ];
                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: indicators[0]),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: indicators[1]),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: indicators[2]),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            indicators[0],
                            const SizedBox(height: AppSpacing.s10),
                            indicators[1],
                            const SizedBox(height: AppSpacing.s10),
                            indicators[2],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.s14),
                    if (selectedNode == null)
                      _buildEmptyState(
                        'Impossible de charger cet animal. Vérifiez son code.',
                      )
                    else
                      _buildPedigreeTreeChart(
                        root: selectedNode,
                        sire: sireNode,
                        dam: damNode,
                        paternalSire: paternalSireNode,
                        paternalDam: paternalDamNode,
                        maternalSire: maternalSireNode,
                        maternalDam: maternalDamNode,
                      ),
                    const SizedBox(height: AppSpacing.s12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: selectedNode == null
                              ? null
                              : () => _showPedigreeEditorDialog(
                                  selectedNode.code,
                                ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Modifier manuel / auto'),
                        ),
                        OutlinedButton.icon(
                          onPressed: selectedNode == null
                              ? null
                              : () => _autoAssignPedigreeForAnimal(
                                  selectedNode.code,
                                ),
                          icon: const Icon(
                            Icons.auto_fix_high_outlined,
                            size: 16,
                          ),
                          label: const Text('Auto sur cet animal'),
                        ),
                        OutlinedButton.icon(
                          onPressed: pedigreeNodes.isEmpty
                              ? null
                              : _autoAssignPedigreeForAllAnimals,
                          icon: const Icon(Icons.hub_outlined, size: 16),
                          label: const Text('Auto global'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildSectionCard(
          title: 'Amélioration descendance & anti-consanguinité',
          subtitle:
              'Sécurisation génétique des accouplements et amélioration continue de la lignée porcine',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              final indicators = [
                _buildMiniIndicator(
                  label: 'Couplages sécurisés',
                  value: '$safePairings',
                  color: const Color(0xFF15803D),
                ),
                _buildMiniIndicator(
                  label: 'Couplages à risque',
                  value: '$riskyPairings',
                  color: const Color(0xFFB91C1C),
                ),
                _buildMiniIndicator(
                  label: 'Alertes actives',
                  value: '${consanguinityAlerts.length}',
                  color: const Color(0xFFB45309),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: indicators[0]),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(child: indicators[1]),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(child: indicators[2]),
                  ],
                );
              }

              return Column(
                children: [
                  indicators[0],
                  const SizedBox(height: AppSpacing.s10),
                  indicators[1],
                  const SizedBox(height: AppSpacing.s10),
                  indicators[2],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
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
        const SizedBox(height: AppSpacing.s16),
        _buildDataTableSection(
          title: 'Alertes consanguinité',
          subtitle:
              'Contrôle des IA réalisées pour éviter les croisements à risque',
          emptyMessage: 'Aucune alerte consanguinité détectée.',
          columns: const [
            DataColumn(label: Text('DATE IA')),
            DataColumn(label: Text('TRUIE')),
            DataColumn(label: Text('VERRAT')),
            DataColumn(label: Text('STATUT IA')),
            DataColumn(label: Text('MOTIF')),
          ],
          rows: alertRows,
        ),
      ],
    );
  }

  _PedigreeTreeNode? _pedigreeNodeByCode(String code) {
    final normalizedCode = _normalizeLookup(code);
    if (normalizedCode.isEmpty) {
      return null;
    }

    for (final boar in _boars) {
      if (_normalizeLookup(boar.code) == normalizedCode) {
        return _PedigreeTreeNode(
          code: boar.code,
          name: boar.name,
          type: 'Verrat',
          breed: boar.breed,
          birthDate: boar.birthDate,
          breederId: boar.breederId,
          sireCode: boar.sireCode,
          damCode: boar.damCode,
          origin: boar.origin,
        );
      }
    }

    for (final sow in _sows) {
      if (_normalizeLookup(sow.code) == normalizedCode) {
        return _PedigreeTreeNode(
          code: sow.code,
          name: sow.name,
          type: 'Truie',
          breed: sow.breed,
          birthDate: sow.birthDate,
          breederId: sow.breederId,
          sireCode: sow.sireCode,
          damCode: sow.damCode,
          origin: '',
        );
      }
    }

    return null;
  }

  Widget _buildPedigreeTreeChart({
    required _PedigreeTreeNode root,
    required _PedigreeTreeNode? sire,
    required _PedigreeTreeNode? dam,
    required _PedigreeTreeNode? paternalSire,
    required _PedigreeTreeNode? paternalDam,
    required _PedigreeTreeNode? maternalSire,
    required _PedigreeTreeNode? maternalDam,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 980;

        final parentSection = isWide
            ? Row(
                children: [
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Père',
                      node: sire,
                      accent: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Mère',
                      node: dam,
                      accent: const Color(0xFFDB2777),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildPedigreeNodeCard(
                    relation: 'Père',
                    node: sire,
                    accent: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  _buildPedigreeNodeCard(
                    relation: 'Mère',
                    node: dam,
                    accent: const Color(0xFFDB2777),
                  ),
                ],
              );

        final grandParentSection = isWide
            ? Row(
                children: [
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Grand-père paternel',
                      node: paternalSire,
                      accent: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Grand-mère paternelle',
                      node: paternalDam,
                      accent: const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Grand-père maternel',
                      node: maternalSire,
                      accent: const Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: _buildPedigreeNodeCard(
                      relation: 'Grand-mère maternelle',
                      node: maternalDam,
                      accent: const Color(0xFFD946EF),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPedigreeNodeCard(
                          relation: 'Grand-père paternel',
                          node: paternalSire,
                          accent: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: _buildPedigreeNodeCard(
                          relation: 'Grand-mère paternelle',
                          node: paternalDam,
                          accent: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPedigreeNodeCard(
                          relation: 'Grand-père maternel',
                          node: maternalSire,
                          accent: const Color(0xFF0891B2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: _buildPedigreeNodeCard(
                          relation: 'Grand-mère maternelle',
                          node: maternalDam,
                          accent: const Color(0xFFD946EF),
                        ),
                      ),
                    ],
                  ),
                ],
              );

        final rootCardWidth = math.min(420.0, constraints.maxWidth);

        return Column(
          children: [
            Center(
              child: SizedBox(
                width: rootCardWidth,
                child: _buildPedigreeNodeCard(
                  relation: 'Animal sélectionné',
                  node: root,
                  accent: const Color(0xFF0F766E),
                  highlighted: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            _buildPedigreeTreeConnector(widthFactor: isWide ? 0.45 : 0.7),
            const SizedBox(height: AppSpacing.s10),
            parentSection,
            const SizedBox(height: AppSpacing.s8),
            _buildPedigreeTreeConnector(widthFactor: isWide ? 0.95 : 0.8),
            const SizedBox(height: AppSpacing.s10),
            grandParentSection,
          ],
        );
      },
    );
  }

  Widget _buildPedigreeNodeCard({
    required String relation,
    required _PedigreeTreeNode? node,
    required Color accent,
    bool highlighted = false,
  }) {
    final isMissing = node == null;
    final borderColor = isMissing
        ? const Color(0xFFDCE4EE)
        : accent.withValues(alpha: highlighted ? 0.7 : 0.45);

    return Container(
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: highlighted ? 1.6 : 1.2),
        boxShadow: isMissing
            ? const []
            : [
                BoxShadow(
                  color: accent.withValues(alpha: highlighted ? 0.14 : 0.09),
                  blurRadius: highlighted ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            relation.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            isMissing ? 'Non renseigné' : '${node.code} • ${node.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMissing
                  ? const Color(0xFF64748B)
                  : const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            isMissing
                ? 'Ajoutez la filiation pour compléter la lignée.'
                : '${node.type} • ${node.breed}',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (!isMissing) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              'P: ${node.sireCode.isEmpty ? '-' : node.sireCode} • '
              'M: ${node.damCode.isEmpty ? '-' : node.damCode}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (node.origin.isNotEmpty)
              Text(
                'Origine: ${node.origin}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPedigreeTreeConnector({
    required double widthFactor,
    double verticalHeight = 12,
  }) {
    const lineColor = Color(0xFFCBD5E1);
    final effectiveWidthFactor = widthFactor.clamp(0.15, 1.0).toDouble();

    return Column(
      children: [
        Container(width: 2, height: verticalHeight, color: lineColor),
        FractionallySizedBox(
          widthFactor: effectiveWidthFactor,
          child: Container(height: 2, color: lineColor),
        ),
      ],
    );
  }

  void _showPedigreeEditorDialog(String animalCode) {
    final node = _pedigreeNodeByCode(animalCode);
    if (node == null) {
      _showError('Animal introuvable pour modifier le pedigree.');
      return;
    }

    final sireCtrl = TextEditingController(text: node.sireCode);
    final damCtrl = TextEditingController(text: node.damCode);
    var quickSireValue = '';
    var quickDamValue = '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final boarOptions =
                _boars
                    .where(
                      (boar) =>
                          _normalizeLookup(boar.code) !=
                          _normalizeLookup(node.code),
                    )
                    .toList()
                  ..sort((a, b) => a.code.compareTo(b.code));
            final sowOptions =
                _sows
                    .where(
                      (sow) =>
                          _normalizeLookup(sow.code) !=
                          _normalizeLookup(node.code),
                    )
                    .toList()
                  ..sort((a, b) => a.code.compareTo(b.code));

            return AlertDialog(
              title: const Text('Modifier pedigree (manuel / auto)'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.s10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'Animal cible: ${node.code} • ${node.name} (${node.type})',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        sireCtrl,
                        'Code père (manuel)',
                        hint: 'Ex: VR-1001',
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: quickSireValue,
                        decoration: const InputDecoration(
                          labelText: 'Choix rapide père (verrat)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Choisir un verrat'),
                          ),
                          ...boarOptions.map(
                            (boar) => DropdownMenuItem(
                              value: boar.code,
                              child: Text('${boar.code} - ${boar.name}'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return;
                          }
                          setModalState(() {
                            sireCtrl.text = value;
                            quickSireValue = '';
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        damCtrl,
                        'Code mère (manuel)',
                        hint: 'Ex: TR-2001',
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: quickDamValue,
                        decoration: const InputDecoration(
                          labelText: 'Choix rapide mère (truie)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Choisir une truie'),
                          ),
                          ...sowOptions.map(
                            (sow) => DropdownMenuItem(
                              value: sow.code,
                              child: Text('${sow.code} - ${sow.name}'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return;
                          }
                          setModalState(() {
                            damCtrl.text = value;
                            quickDamValue = '';
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      OutlinedButton.icon(
                        onPressed: () {
                          final suggestion = _suggestPedigreeLinksForAnimal(
                            node.code,
                          );
                          if (suggestion.sireCode.isEmpty &&
                              suggestion.damCode.isEmpty) {
                            _showError(
                              'Aucune proposition automatique disponible.',
                            );
                            return;
                          }
                          setModalState(() {
                            sireCtrl.text = suggestion.sireCode;
                            damCtrl.text = suggestion.damCode;
                          });
                        },
                        icon: const Icon(
                          Icons.auto_fix_high_outlined,
                          size: 16,
                        ),
                        label: const Text('Proposer automatiquement'),
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
                    final sireCode = sireCtrl.text.trim();
                    final damCode = damCtrl.text.trim();
                    final animalCodeNormalized = _normalizeLookup(node.code);

                    if (sireCode.isNotEmpty &&
                        _normalizeLookup(sireCode) == animalCodeNormalized) {
                      _showError(
                        'Le père ne peut pas être le même animal (${node.code}).',
                      );
                      return;
                    }
                    if (damCode.isNotEmpty &&
                        _normalizeLookup(damCode) == animalCodeNormalized) {
                      _showError(
                        'La mère ne peut pas être le même animal (${node.code}).',
                      );
                      return;
                    }
                    if (sireCode.isNotEmpty &&
                        damCode.isNotEmpty &&
                        _normalizeLookup(sireCode) ==
                            _normalizeLookup(damCode)) {
                      _showError(
                        'Les codes père et mère doivent être différents.',
                      );
                      return;
                    }

                    final changed = _savePedigreeLinks(
                      animalCode: node.code,
                      sireCode: sireCode,
                      damCode: damCode,
                      auditAction: 'MANUAL_PEDIGREE_UPDATE',
                      feedbackLabel:
                          'Pedigree mis à jour pour ${node.code} (${node.name}).',
                    );
                    Navigator.of(dialogContext).pop();
                    if (!changed) {
                      _showInfo(
                        'Aucune modification détectée pour ${node.code}.',
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _disposeControllers([sireCtrl, damCtrl]));
  }

  bool _applyPedigreeLinksInState({
    required String animalCode,
    required String sireCode,
    required String damCode,
  }) {
    final normalizedAnimalCode = _normalizeLookup(animalCode);
    final normalizedSire = sireCode.trim();
    final normalizedDam = damCode.trim();

    for (var i = 0; i < _boars.length; i++) {
      final boar = _boars[i];
      if (_normalizeLookup(boar.code) != normalizedAnimalCode) {
        continue;
      }
      if (_normalizeLookup(boar.sireCode) == _normalizeLookup(normalizedSire) &&
          _normalizeLookup(boar.damCode) == _normalizeLookup(normalizedDam)) {
        return false;
      }
      _boars[i] = Boar(
        id: boar.id,
        code: boar.code,
        name: boar.name,
        breed: boar.breed,
        birthDate: boar.birthDate,
        origin: boar.origin,
        breederId: boar.breederId,
        sireCode: normalizedSire,
        damCode: normalizedDam,
        semenType: boar.semenType,
        notes: boar.notes,
        imageBase64: boar.imageBase64,
      );
      return true;
    }

    for (var i = 0; i < _sows.length; i++) {
      final sow = _sows[i];
      if (_normalizeLookup(sow.code) != normalizedAnimalCode) {
        continue;
      }
      if (_normalizeLookup(sow.sireCode) == _normalizeLookup(normalizedSire) &&
          _normalizeLookup(sow.damCode) == _normalizeLookup(normalizedDam)) {
        return false;
      }
      _sows[i] = Sow(
        id: sow.id,
        code: sow.code,
        name: sow.name,
        breed: sow.breed,
        birthDate: sow.birthDate,
        parity: sow.parity,
        breederId: sow.breederId,
        sireCode: normalizedSire,
        damCode: normalizedDam,
        notes: sow.notes,
        imageBase64: sow.imageBase64,
      );
      return true;
    }

    return false;
  }

  bool _savePedigreeLinks({
    required String animalCode,
    required String sireCode,
    required String damCode,
    required String auditAction,
    required String feedbackLabel,
  }) {
    var changed = false;
    final cleanSireCode = sireCode.trim();
    final cleanDamCode = damCode.trim();

    setState(() {
      changed = _applyPedigreeLinksInState(
        animalCode: animalCode,
        sireCode: cleanSireCode,
        damCode: cleanDamCode,
      );
      if (changed) {
        _selectedPedigreeAnimalCode = animalCode;
      }
    });

    if (!changed) {
      return false;
    }

    _addAuditLog(
      module: 'PEDIGREE',
      action: auditAction,
      detail:
          '$animalCode -> père: ${cleanSireCode.isEmpty ? '-' : cleanSireCode}, '
          'mère: ${cleanDamCode.isEmpty ? '-' : cleanDamCode}',
    );
    _persistState();
    _showInfo(feedbackLabel);
    return true;
  }

  void _autoAssignPedigreeForAnimal(String animalCode) {
    final node = _pedigreeNodeByCode(animalCode);
    if (node == null) {
      _showError('Animal introuvable pour l\'assignation automatique.');
      return;
    }

    final suggestion = _suggestPedigreeLinksForAnimal(node.code);
    if (suggestion.sireCode.isEmpty && suggestion.damCode.isEmpty) {
      _showError('Aucune proposition automatique disponible.');
      return;
    }

    final changed = _savePedigreeLinks(
      animalCode: node.code,
      sireCode: suggestion.sireCode,
      damCode: suggestion.damCode,
      auditAction: 'AUTO_PEDIGREE_UPDATE',
      feedbackLabel: 'Pedigree auto appliqué pour ${node.code}.',
    );
    if (!changed) {
      _showInfo(
        'Aucune modification automatique nécessaire pour ${node.code}.',
      );
    }
  }

  void _autoAssignPedigreeForAllAnimals() {
    final nodes = _allPedigreeNodes();
    if (nodes.isEmpty) {
      _showError('Aucun animal disponible pour l\'assignation automatique.');
      return;
    }

    var updatedCount = 0;
    setState(() {
      for (final node in nodes) {
        final suggestion = _suggestPedigreeLinksForAnimal(node.code);
        final changed = _applyPedigreeLinksInState(
          animalCode: node.code,
          sireCode: suggestion.sireCode,
          damCode: suggestion.damCode,
        );
        if (changed) {
          updatedCount++;
        }
      }
      _selectedPedigreeAnimalCode = _resolveSelectedPedigreeCode(
        _selectedPedigreeAnimalCode,
        _allPedigreeNodes(),
      );
    });

    if (updatedCount <= 0) {
      _showInfo('Aucune mise à jour automatique nécessaire.');
      return;
    }

    _addAuditLog(
      module: 'PEDIGREE',
      action: 'AUTO_PEDIGREE_GLOBAL',
      detail: '$updatedCount pedigree(s) mis à jour automatiquement.',
      severity: 'WARN',
    );
    _persistState();
    _showInfo('$updatedCount pedigree(s) mis à jour automatiquement.');
  }

  ({String sireCode, String damCode}) _suggestPedigreeLinksForAnimal(
    String animalCode,
  ) {
    final node = _pedigreeNodeByCode(animalCode);
    if (node == null) {
      return (sireCode: '', damCode: '');
    }

    var sireCode = node.sireCode.trim();
    var damCode = node.damCode.trim();

    if (sireCode.isEmpty) {
      sireCode = _suggestSireCodeForPedigree(node);
    }
    if (damCode.isEmpty) {
      damCode = _suggestDamCodeForPedigree(node, excludedCode: sireCode);
    }
    if (sireCode.isNotEmpty &&
        damCode.isNotEmpty &&
        _normalizeLookup(sireCode) == _normalizeLookup(damCode)) {
      damCode = _suggestDamCodeForPedigree(node, excludedCode: sireCode);
    }

    return (sireCode: sireCode, damCode: damCode);
  }

  String _suggestSireCodeForPedigree(_PedigreeTreeNode target) {
    final normalizedTargetCode = _normalizeLookup(target.code);
    const minimumAgeGapDays = 180;

    final olderCandidates = _boars.where((boar) {
      if (_normalizeLookup(boar.code) == normalizedTargetCode) {
        return false;
      }
      return target.birthDate.difference(boar.birthDate).inDays >=
          minimumAgeGapDays;
    }).toList();

    final candidates = olderCandidates.isNotEmpty
        ? olderCandidates
        : _boars
              .where(
                (boar) => _normalizeLookup(boar.code) != normalizedTargetCode,
              )
              .toList();
    if (candidates.isEmpty) {
      return '';
    }

    candidates.sort((a, b) {
      final scoreA = _scoreBoarCandidateForPedigree(a, target);
      final scoreB = _scoreBoarCandidateForPedigree(b, target);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.birthDate.compareTo(b.birthDate);
    });

    return candidates.first.code;
  }

  String _suggestDamCodeForPedigree(
    _PedigreeTreeNode target, {
    String excludedCode = '',
  }) {
    final excluded = <String>{
      _normalizeLookup(target.code),
      if (excludedCode.trim().isNotEmpty) _normalizeLookup(excludedCode),
    };
    const minimumAgeGapDays = 180;

    final olderCandidates = _sows.where((sow) {
      final code = _normalizeLookup(sow.code);
      if (excluded.contains(code)) {
        return false;
      }
      return target.birthDate.difference(sow.birthDate).inDays >=
          minimumAgeGapDays;
    }).toList();

    final candidates = olderCandidates.isNotEmpty
        ? olderCandidates
        : _sows
              .where((sow) => !excluded.contains(_normalizeLookup(sow.code)))
              .toList();
    if (candidates.isEmpty) {
      return '';
    }

    candidates.sort((a, b) {
      final scoreA = _scoreSowCandidateForPedigree(a, target);
      final scoreB = _scoreSowCandidateForPedigree(b, target);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.birthDate.compareTo(b.birthDate);
    });

    return candidates.first.code;
  }

  int _scoreBoarCandidateForPedigree(Boar boar, _PedigreeTreeNode target) {
    var score = 0;
    if (_normalizeLookup(boar.breed) == _normalizeLookup(target.breed)) {
      score += 40;
    }
    if (target.breederId.trim().isNotEmpty &&
        _normalizeLookup(boar.breederId) ==
            _normalizeLookup(target.breederId)) {
      score += 18;
    }
    final ageGap = target.birthDate.difference(boar.birthDate).inDays;
    if (ageGap >= 540) {
      score += 16;
    } else if (ageGap >= 365) {
      score += 12;
    } else if (ageGap >= 240) {
      score += 8;
    } else if (ageGap >= 180) {
      score += 4;
    }

    final inseminationCount = _inseminations
        .where(
          (record) =>
              _normalizeLookup(record.boarCode) == _normalizeLookup(boar.code),
        )
        .length;
    score += math.min(12, inseminationCount * 2);
    return score;
  }

  int _scoreSowCandidateForPedigree(Sow sow, _PedigreeTreeNode target) {
    var score = 0;
    if (_normalizeLookup(sow.breed) == _normalizeLookup(target.breed)) {
      score += 40;
    }
    if (target.breederId.trim().isNotEmpty &&
        _normalizeLookup(sow.breederId) == _normalizeLookup(target.breederId)) {
      score += 18;
    }
    final ageGap = target.birthDate.difference(sow.birthDate).inDays;
    if (ageGap >= 540) {
      score += 16;
    } else if (ageGap >= 365) {
      score += 12;
    } else if (ageGap >= 240) {
      score += 8;
    } else if (ageGap >= 180) {
      score += 4;
    }
    score += math.min(10, sow.parity * 2);
    final farrowingCount = _farrowingRecords
        .where(
          (record) =>
              _normalizeLookup(record.sowCode) == _normalizeLookup(sow.code),
        )
        .length;
    score += math.min(8, farrowingCount * 2);
    return score;
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

  Widget _buildProfileHub() {
    final user = _currentUser;
    final activity = _auditLogs
        .where(
          (entry) =>
              entry.actorCode.toLowerCase() == user.code.toLowerCase() ||
              entry.actorName.toLowerCase() == user.name.toLowerCase(),
        )
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildUserCoverPhoto(user, height: 210),
                  Positioned(
                    left: 24,
                    bottom: -44,
                    child: _buildUserAvatar(
                      user,
                      radius: 44,
                      ringColor: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: FilledButton.icon(
                      onPressed: _showEditMyProfileDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Modifier profil'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s58,
                  AppSpacing.s24,
                  AppSpacing.s22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${user.role} • ${user.code} • @${user.login}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s10),
                    Text(
                      user.bio.trim().isEmpty
                          ? 'Ajoutez une bio pour décrire votre rôle terrain et vos objectifs.'
                          : user.bio.trim(),
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildProfileChip(
                          icon: Icons.home_outlined,
                          text: user.address.isEmpty
                              ? 'Adresse non renseignée'
                              : user.address,
                        ),
                        _buildProfileChip(
                          icon: Icons.call_outlined,
                          text: user.contact.isEmpty
                              ? 'Contact non renseigné'
                              : user.contact,
                        ),
                        _buildProfileChip(
                          icon: Icons.location_on_outlined,
                          text: _territoryLabel(user),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildSectionCard(
          title: 'Infos Profil',
          subtitle: 'Informations personnelles et zone d\'intervention',
          child: Column(
            children: [
              _buildProfileRow('Nom complet', user.name),
              _buildProfileRow('Rôle', user.role),
              _buildProfileRow('Code utilisateur', user.code),
              _buildProfileRow('Login', user.login),
              _buildProfileRow(
                'Contact',
                user.contact.isEmpty ? '-' : user.contact,
              ),
              _buildProfileRow(
                'Adresse',
                user.address.isEmpty ? '-' : user.address,
              ),
              _buildProfileRow(
                'Zone terrain',
                _territoryLabel(user),
                withDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildSectionCard(
          title: 'Activité récente',
          subtitle: 'Historique des dernières actions sur la plateforme',
          child: activity.isEmpty
              ? _buildEmptyState('Aucune activité enregistrée.')
              : ListView.separated(
                  itemCount: activity.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = activity[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE0F2FE),
                        child: Icon(
                          Icons.bolt_outlined,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      title: Text(
                        '${entry.module} • ${entry.action}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${entry.detail}\n${_formatDateTime(entry.timestamp)}',
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF334155)),
          const SizedBox(width: AppSpacing.s6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(
    String label,
    String value, {
    bool withDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      decoration: BoxDecoration(
        border: withDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsFeedHub() {
    final posts = List<NewsPost>.from(_newsPosts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final filteredPosts = _filteredNewsPostsForFeed(posts);
    final isCompact = MediaQuery.of(context).size.width < 400;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_newsCanvasTop, _newsCanvasBottom],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _newsCardBorder.withValues(alpha: 0.55)),
      ),
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.s8 : AppSpacing.s10,
        isCompact ? AppSpacing.s8 : AppSpacing.s10,
        isCompact ? AppSpacing.s8 : AppSpacing.s10,
        90,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNewsFeedHeader(
            totalPosts: posts.length,
            visiblePosts: filteredPosts.length,
          ),
          const SizedBox(height: AppSpacing.s10),
          _buildNewsComposerCard(),
          const SizedBox(height: AppSpacing.s10),
          _buildNewsFilterBar(posts),
          const SizedBox(height: AppSpacing.s12),
          if (filteredPosts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: _newsCardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _newsCardBorder),
              ),
              child: const Text(
                'Aucune publication pour ce filtre. Essayez "Tous" ou créez une nouvelle publication.',
                style: TextStyle(
                  color: _newsMutedText,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            )
          else
            ListView.separated(
              itemCount: filteredPosts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, index) =>
                  const SizedBox(height: AppSpacing.s10),
              itemBuilder: (context, index) =>
                  _buildNewsPostCard(filteredPosts[index]),
            ),
        ],
      ),
    );
  }

  List<NewsPost> _filteredNewsPostsForFeed(List<NewsPost> posts) {
    if (!_newsFeedFilters.contains(_newsFeedFilter) ||
        _newsFeedFilter == 'Tous') {
      return posts;
    }
    return posts
        .where((post) => _matchesNewsFeedFilter(post, _newsFeedFilter))
        .toList();
  }

  bool _matchesNewsFeedFilter(NewsPost post, String filter) {
    if (filter == 'Tous') {
      return true;
    }
    if (filter == 'Photos') {
      return post.imageBase64.trim().isNotEmpty;
    }
    return _newsCategoryForPost(post) == filter;
  }

  String _newsCategoryForPost(NewsPost post) {
    final normalized = _normalizeLookup(
      '${post.text} ${post.imageName} ${post.authorRole}',
    );
    if (normalized.contains('vente') ||
        normalized.contains('vendre') ||
        normalized.contains('disponible') ||
        normalized.contains('prix') ||
        normalized.contains('march')) {
      return 'Vente';
    }
    if (normalized.contains('vaccin') ||
        normalized.contains('traitement') ||
        normalized.contains('sante') ||
        normalized.contains('santé') ||
        normalized.contains('prophylaxie') ||
        normalized.contains('alerte') ||
        normalized.contains('urgence')) {
      return 'Santé';
    }
    if (normalized.contains('insemin') ||
        normalized.contains('insémin') ||
        normalized.contains(' ia ') ||
        normalized.startsWith('ia') ||
        normalized.contains('semence') ||
        normalized.contains('chaleur') ||
        normalized.contains('diagnostic')) {
      return 'IA';
    }
    if (post.imageBase64.trim().isNotEmpty) {
      return 'Photos';
    }
    return 'Élevage';
  }

  Color _newsCategoryColor(String category) {
    switch (category) {
      case 'IA':
        return const Color(0xFF0E7490);
      case 'Santé':
        return const Color(0xFFC2410C);
      case 'Vente':
        return const Color(0xFFB91C1C);
      case 'Photos':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF0F766E);
    }
  }

  Widget _buildNewsFeedHeader({
    required int totalPosts,
    required int visiblePosts,
  }) {
    final isFiltered = _newsFeedFilter != 'Tous';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_newsHeaderGradientStart, _newsHeaderGradientEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _newsHeaderGradientEnd.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Actualités',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Text(
            isFiltered
                ? '$visiblePosts / $totalPosts'
                : '$totalPosts publication(s)',
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsFilterBar(List<NewsPost> posts) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _newsFeedFilters.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.s6),
        itemBuilder: (context, index) {
          final filter = _newsFeedFilters[index];
          final count = posts
              .where((post) => _matchesNewsFeedFilter(post, filter))
              .length;
          return _buildNewsFilterChip(filter: filter, count: count);
        },
      ),
    );
  }

  Widget _buildNewsFilterChip({required String filter, required int count}) {
    final selected = _newsFeedFilter == filter;
    final accent = _newsCategoryColor(filter);
    return InkWell(
      onTap: () {
        if (_newsFeedFilter == filter) {
          return;
        }
        setState(() => _newsFeedFilter = filter);
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.18) : _newsCardSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.62) : _newsCardBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Text(
          '$filter ($count)',
          style: TextStyle(
            color: selected ? accent : _newsMutedText,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNewsComposerCard() {
    final firstName = _currentUser.name.trim().split(' ').first;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s12,
        AppSpacing.s12,
        AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: _newsCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _newsCardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildUserAvatar(_currentUser, radius: 20),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: InkWell(
                  onTap: _showAddNewsPostDialog,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s14,
                      vertical: AppSpacing.s11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEDD9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFF1D7BC)),
                    ),
                    child: Text(
                      'Que voulez-vous partager, $firstName ?',
                      style: const TextStyle(
                        color: Color(0xFF7A5A44),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          const Divider(height: 1, color: Color(0xFFECCFB0)),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: _buildNewsComposerQuickButton(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF0EA5A4),
                  label: 'Photo',
                  onTap: _showAddNewsPostDialog,
                ),
              ),
              Expanded(
                child: _buildNewsComposerQuickButton(
                  icon: LucideIcons.syringe,
                  color: const Color(0xFF15803D),
                  label: 'Annonce IA',
                  onTap: _showAddNewsPostDialog,
                ),
              ),
              Expanded(
                child: _buildNewsComposerQuickButton(
                  icon: LucideIcons.shieldCheck,
                  color: const Color(0xFFB45309),
                  label: 'Alerte Santé',
                  onTap: _showAddNewsPostDialog,
                ),
              ),
              Expanded(
                child: _buildNewsComposerQuickButton(
                  icon: Icons.sell_outlined,
                  color: const Color(0xFF0369A1),
                  label: 'Vente',
                  onTap: _showAddNewsPostDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsComposerQuickButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.s4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsPostCard(NewsPost post) {
    final isLiked = post.likedByUserIds.contains(_currentUser.id);
    final canManage = _canManageNewsPost(post);
    final category = _newsCategoryForPost(post);
    final categoryColor = _newsCategoryColor(category);
    final authorProfile = _findUserById(post.authorId);
    final comments = List<NewsComment>.from(post.comments)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final visibleComments = comments.length > 2
        ? comments.sublist(comments.length - 2)
        : comments;
    final shareCount =
        ((post.likedByUserIds.length + post.comments.length) ~/ 3).clamp(
          0,
          999,
        );

    return Container(
      decoration: BoxDecoration(
        color: _newsCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _newsCardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              AppSpacing.s12,
              AppSpacing.s12,
              AppSpacing.s8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNewsAuthorAvatar(authorProfile, post.authorName),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        '${post.authorRole} • ${_newsTimeLabel(post.createdAt)}',
                        style: const TextStyle(
                          color: _newsMutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildNewsCategoryBadge(label: category, color: categoryColor),
                _buildNewsPostMenu(post: post, canManage: canManage),
              ],
            ),
          ),
          if (post.text.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s12,
                AppSpacing.zero,
                AppSpacing.s12,
                AppSpacing.s8,
              ),
              child: Text(
                post.text.trim(),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (post.imageBase64.trim().isNotEmpty) ...[
            _buildNewsPostImage(post.imageBase64),
            if (post.imageName.trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s6,
                  AppSpacing.s12,
                  AppSpacing.s4,
                ),
                child: Text(
                  post.imageName.trim(),
                  style: const TextStyle(
                    color: _newsMutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
          _buildNewsStatsRow(post: post, shareCount: shareCount),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s6,
              AppSpacing.zero,
              AppSpacing.s6,
              AppSpacing.s2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNewsActionButton(
                    icon: isLiked
                        ? Icons.thumb_up_alt
                        : Icons.thumb_up_alt_outlined,
                    label: 'J’aime',
                    color: isLiked ? const Color(0xFF0E7490) : _newsMutedText,
                    onTap: () => _toggleNewsLike(post.id),
                  ),
                ),
                Expanded(
                  child: _buildNewsActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Commenter',
                    color: _newsMutedText,
                    onTap: () => _showAddNewsCommentDialog(post),
                  ),
                ),
                Expanded(
                  child: _buildNewsActionButton(
                    icon: Icons.share_outlined,
                    label: 'Partager',
                    color: _newsMutedText,
                    onTap: () => _showInfo('Partage interne enregistré.'),
                  ),
                ),
              ],
            ),
          ),
          if (comments.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Divider(height: 14),
            ),
            if (comments.length > visibleComments.length)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.zero,
                  AppSpacing.s12,
                  AppSpacing.s4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: AppSpacing.s4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      _showInfo(
                        '${comments.length} commentaires disponibles sur cette publication.',
                      );
                    },
                    child: Text(
                      'Voir plus de commentaires (${comments.length})',
                      style: const TextStyle(
                        color: Color(0xFF0E7490),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ...visibleComments.map(_buildNewsCommentPreview),
            const SizedBox(height: AppSpacing.s2),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsCategoryBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildNewsPostMenu({required NewsPost post, required bool canManage}) {
    return PopupMenuButton<String>(
      tooltip: 'Options',
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            _showAddNewsPostDialog(existing: post);
            return;
          case 'delete':
            _deleteNewsPost(post.id);
            return;
          case 'copy':
            await Clipboard.setData(ClipboardData(text: post.text));
            _showInfo('Texte de publication copié.');
            return;
          case 'hide':
            _showInfo('Publication masquée localement (simulation).');
            return;
          case 'report':
            _showInfo('Signalement transmis au responsable.');
            return;
          default:
            return;
        }
      },
      itemBuilder: (context) {
        if (canManage) {
          return const [
            PopupMenuItem<String>(value: 'edit', child: Text('Modifier')),
            PopupMenuItem<String>(value: 'delete', child: Text('Supprimer')),
            PopupMenuItem<String>(
              value: 'copy',
              child: Text('Copier le texte'),
            ),
          ];
        }
        return const [
          PopupMenuItem<String>(value: 'copy', child: Text('Copier le texte')),
          PopupMenuItem<String>(value: 'hide', child: Text('Masquer')),
          PopupMenuItem<String>(value: 'report', child: Text('Signaler')),
        ];
      },
      icon: const Icon(Icons.more_horiz, color: _newsMutedText),
    );
  }

  Widget _buildNewsStatsRow({required NewsPost post, required int shareCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s6,
        AppSpacing.s12,
        AppSpacing.zero,
      ),
      child: Wrap(
        spacing: AppSpacing.s10,
        runSpacing: AppSpacing.s4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                size: 14,
                color: const Color(0xFFDC2626).withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.s4),
              Text(
                '${post.likedByUserIds.length} réaction(s)',
                style: const TextStyle(
                  color: _newsMutedText,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            '${post.comments.length} commentaire(s)',
            style: const TextStyle(
              color: _newsMutedText,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            '$shareCount partage(s)',
            style: const TextStyle(
              color: _newsMutedText,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCommentPreview(NewsComment comment) {
    final commentUser = _findUserById(comment.authorId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.zero,
        AppSpacing.s12,
        AppSpacing.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNewsAuthorAvatar(commentUser, comment.authorName, radius: 14),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF1E4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1D8C1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        _newsTimeLabel(comment.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF8B97A9),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    comment.text,
                    style: const TextStyle(
                      color: _newsMutedText,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
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

  Widget _buildNewsAuthorAvatar(
    UserProfile? user,
    String fallbackName, {
    double radius = 18,
  }) {
    if (user != null) {
      return _buildUserAvatar(user, radius: radius);
    }
    final initial = fallbackName.trim().isEmpty
        ? '?'
        : fallbackName.trim().substring(0, 1).toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFB45309),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: math.max(11, radius * 0.55),
        ),
      ),
    );
  }

  Widget _buildNewsPostImage(String imageBase64) {
    final bytes = _decodeImageBytesCached(imageBase64);
    if (bytes == null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFB91C1C)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        bytes,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      ),
    );
  }

  bool _canManageNewsPost(NewsPost post) {
    return post.authorId == _currentUser.id || _currentUser.role == Roles.admin;
  }

  String _newsTimeLabel(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) {
      return 'à l\'instant';
    }
    if (diff.inMinutes < 60) {
      return 'il y a ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'il y a ${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return 'il y a ${diff.inDays} j';
    }
    return _formatDateTime(timestamp);
  }

  Future<void> _showAddNewsPostDialog({NewsPost? existing}) async {
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    String selectedImageBase64 = existing?.imageBase64 ?? '';
    String selectedImageName = existing?.imageName ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEdit = existing != null;
            return AlertDialog(
              title: Text(
                isEdit ? 'Modifier publication' : 'Nouvelle publication',
              ),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildUserAvatar(_currentUser, radius: 16),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              _currentUser.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      TextField(
                        controller: textCtrl,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Texte de publication',
                          hintText:
                              'Ex: Mise-bas, protocole IA, alerte sanitaire, disponibilité porcelets...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      _buildImagePreviewBox(selectedImageBase64, size: 110),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final image = await _pickImageAsBase64();
                              if (image == null) {
                                return;
                              }
                              final generatedName =
                                  'post-${DateTime.now().millisecondsSinceEpoch}.jpg';
                              setModalState(() {
                                selectedImageBase64 = image;
                                selectedImageName = generatedName;
                              });
                            },
                            icon: const Icon(Icons.image_outlined, size: 16),
                            label: const Text('Ajouter image'),
                          ),
                          if (selectedImageBase64.trim().isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  selectedImageBase64 = '';
                                  selectedImageName = '';
                                });
                              },
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Retirer image'),
                            ),
                        ],
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
                    final text = textCtrl.text.trim();
                    if (text.isEmpty && selectedImageBase64.trim().isEmpty) {
                      _showError(
                        'La publication doit contenir un texte ou une image.',
                      );
                      return;
                    }

                    if (isEdit) {
                      final index = _newsPosts.indexWhere(
                        (post) => post.id == existing.id,
                      );
                      if (index < 0) {
                        _showError('Publication introuvable.');
                        return;
                      }
                      final old = _newsPosts[index];
                      final updated = NewsPost(
                        id: old.id,
                        authorId: old.authorId,
                        authorName: old.authorName,
                        authorRole: old.authorRole,
                        text: text,
                        createdAt: old.createdAt,
                        imageBase64: selectedImageBase64.trim(),
                        imageName: selectedImageName.trim(),
                        likedByUserIds: old.likedByUserIds,
                        comments: old.comments,
                      );
                      setState(() => _newsPosts[index] = updated);
                      _addAuditLog(
                        module: 'ACTUALITES',
                        action: 'UPDATE_POST',
                        detail:
                            'Publication modifiée ${updated.id} par ${_currentUser.code}',
                      );
                      _persistState();
                      Navigator.of(dialogContext).pop();
                      _showInfo('Publication mise à jour.');
                      return;
                    }

                    final newPost = NewsPost(
                      id: _newId('POST'),
                      authorId: _currentUser.id,
                      authorName: _currentUser.name,
                      authorRole: _currentUser.role,
                      text: text,
                      createdAt: DateTime.now(),
                      imageBase64: selectedImageBase64.trim(),
                      imageName: selectedImageName.trim(),
                      likedByUserIds: const [],
                      comments: const [],
                    );
                    setState(() => _newsPosts.insert(0, newPost));
                    _addAuditLog(
                      module: 'ACTUALITES',
                      action: 'CREATE_POST',
                      detail: 'Publication créée ${newPost.id}',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Publication publiée.');
                  },
                  child: Text(isEdit ? 'Mettre à jour' : 'Publier'),
                ),
              ],
            );
          },
        );
      },
    );

    textCtrl.dispose();
  }

  void _showAddNewsCommentDialog(NewsPost post) {
    final commentCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter un commentaire'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: TextField(
              controller: commentCtrl,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Commentaire *',
                border: OutlineInputBorder(),
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
                final text = commentCtrl.text.trim();
                if (text.isEmpty) {
                  _showError('Le commentaire est vide.');
                  return;
                }
                _addNewsComment(post.id, text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Publier'),
            ),
          ],
        );
      },
    ).then((_) => commentCtrl.dispose());
  }

  void _addNewsComment(String postId, String text) {
    final index = _newsPosts.indexWhere((post) => post.id == postId);
    if (index < 0) {
      _showError('Publication introuvable.');
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _showError('Le commentaire est vide.');
      return;
    }
    final target = _newsPosts[index];
    final comments = List<NewsComment>.from(target.comments)
      ..add(
        NewsComment(
          id: _newId('COM'),
          authorId: _currentUser.id,
          authorName: _currentUser.name,
          text: trimmed,
          createdAt: DateTime.now(),
        ),
      );
    final updated = NewsPost(
      id: target.id,
      authorId: target.authorId,
      authorName: target.authorName,
      authorRole: target.authorRole,
      text: target.text,
      createdAt: target.createdAt,
      imageBase64: target.imageBase64,
      imageName: target.imageName,
      likedByUserIds: target.likedByUserIds,
      comments: comments,
    );
    setState(() => _newsPosts[index] = updated);
    _persistState();
    _showInfo('Commentaire publié.');
  }

  void _toggleNewsLike(String postId) {
    final index = _newsPosts.indexWhere((post) => post.id == postId);
    if (index < 0) {
      return;
    }
    final target = _newsPosts[index];
    final likes = List<String>.from(target.likedByUserIds);
    if (likes.contains(_currentUser.id)) {
      likes.remove(_currentUser.id);
    } else {
      likes.add(_currentUser.id);
    }
    final updated = NewsPost(
      id: target.id,
      authorId: target.authorId,
      authorName: target.authorName,
      authorRole: target.authorRole,
      text: target.text,
      createdAt: target.createdAt,
      imageBase64: target.imageBase64,
      imageName: target.imageName,
      likedByUserIds: likes,
      comments: target.comments,
    );
    setState(() => _newsPosts[index] = updated);
    _persistState();
  }

  Future<void> _deleteNewsPost(String postId) async {
    final index = _newsPosts.indexWhere((post) => post.id == postId);
    if (index < 0) {
      return;
    }
    final target = _newsPosts[index];
    if (!_canManageNewsPost(target)) {
      _showError('Vous ne pouvez pas supprimer cette publication.');
      return;
    }
    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette publication ?',
      message: 'Cette action supprimera aussi ses commentaires.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _newsPosts.removeAt(index));
    _addAuditLog(
      module: 'ACTUALITES',
      action: 'DELETE_POST',
      detail: 'Publication supprimée ${target.id}',
    );
    _persistState();
    _showInfo('Publication supprimée.');
  }

  Widget _buildUserAvatar(
    UserProfile user, {
    double radius = 18,
    Color ringColor = Colors.transparent,
  }) {
    final size = radius * 2;
    final imageBase64 = user.profileImageBase64.trim();
    final border = ringColor == Colors.transparent
        ? null
        : Border.all(color: ringColor, width: 3);

    if (imageBase64.isNotEmpty) {
      final bytes = _decodeImageBytesCached(imageBase64);
      if (bytes != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, border: border),
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF14B8A6),
      child: Text(
        user.avatar,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: math.max(11, radius * 0.55),
        ),
      ),
    );
  }

  Widget _buildUserCoverPhoto(UserProfile user, {double height = 180}) {
    final imageBase64 = user.coverImageBase64.trim();
    if (imageBase64.isNotEmpty) {
      final bytes = _decodeImageBytesCached(imageBase64);
      if (bytes != null) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          child: Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF1D4ED8)],
        ),
      ),
    );
  }

  Widget _buildCoverPreviewBox(String imageBase64, {double height = 100}) {
    if (imageBase64.trim().isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.landscape_outlined, color: Colors.white),
      );
    }
    final bytes = _decodeImageBytesCached(imageBase64);
    if (bytes == null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFB91C1C)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  void _showEditMyProfileDialog() {
    final user = _currentUser;
    final nameCtrl = TextEditingController(text: user.name);
    final bioCtrl = TextEditingController(text: user.bio);
    final addressCtrl = TextEditingController(text: user.address);
    final contactCtrl = TextEditingController(text: user.contact);
    final fokontanyCtrl = TextEditingController(text: user.fokontany);
    final communeCtrl = TextEditingController(text: user.commune);
    final districtCtrl = TextEditingController(text: user.district);
    final regionCtrl = TextEditingController(text: user.region);
    String profileImageBase64 = user.profileImageBase64;
    String coverImageBase64 = user.coverImageBase64;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Modifier mon profil'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCoverPreviewBox(coverImageBase64, height: 104),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final image = await _pickImageAsBase64();
                              if (image == null) {
                                return;
                              }
                              setModalState(() => coverImageBase64 = image);
                            },
                            icon: const Icon(Icons.image_outlined, size: 16),
                            label: const Text('Photo couverture'),
                          ),
                          if (coverImageBase64.trim().isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() => coverImageBase64 = '');
                              },
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Retirer'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(profileImageBase64, size: 84),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final image = await _pickImageAsBase64();
                                    if (image == null) {
                                      return;
                                    }
                                    setModalState(
                                      () => profileImageBase64 = image,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.account_circle_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Photo profil'),
                                ),
                                if (profileImageBase64.trim().isNotEmpty)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setModalState(
                                        () => profileImageBase64 = '',
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(nameCtrl, 'Nom complet *'),
                      _dialogField(bioCtrl, 'Bio', maxLines: 3),
                      _dialogField(addressCtrl, 'Adresse *'),
                      _dialogField(contactCtrl, 'Contact *'),
                      _dialogField(fokontanyCtrl, 'Fokontany *'),
                      _dialogField(communeCtrl, 'Commune *'),
                      _dialogField(districtCtrl, 'District *'),
                      _dialogField(regionCtrl, 'Région *'),
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
                    final name = nameCtrl.text.trim();
                    final address = addressCtrl.text.trim();
                    final contact = contactCtrl.text.trim();
                    final fokontany = fokontanyCtrl.text.trim();
                    final commune = communeCtrl.text.trim();
                    final district = districtCtrl.text.trim();
                    final region = regionCtrl.text.trim();

                    if (name.isEmpty ||
                        address.isEmpty ||
                        contact.isEmpty ||
                        fokontany.isEmpty ||
                        commune.isEmpty ||
                        district.isEmpty ||
                        region.isEmpty) {
                      _showError(
                        'Nom, adresse, contact et zone terrain sont obligatoires.',
                      );
                      return;
                    }

                    final updated = UserProfile(
                      id: user.id,
                      code: user.code,
                      name: name,
                      role: user.role,
                      avatar: _avatarFromName(name),
                      address: address,
                      contact: contact,
                      fokontany: fokontany,
                      commune: commune,
                      district: district,
                      region: region,
                      bio: bioCtrl.text.trim(),
                      profileImageBase64: profileImageBase64,
                      coverImageBase64: coverImageBase64,
                      login: user.login,
                      password: user.password,
                    );

                    final index = _users.indexWhere(
                      (item) => item.id == user.id,
                    );
                    if (index < 0) {
                      _showError('Profil utilisateur introuvable.');
                      return;
                    }

                    setState(() {
                      _users[index] = updated;
                      _currentUser = updated;
                    });
                    _addAuditLog(
                      module: 'PROFILE',
                      action: 'UPDATE_PROFILE',
                      detail: 'Profil mis à jour (${updated.code})',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Profil mis à jour.');
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
        nameCtrl,
        bioCtrl,
        addressCtrl,
        contactCtrl,
        fokontanyCtrl,
        communeCtrl,
        districtCtrl,
        regionCtrl,
      ]),
    );
  }

  Widget _buildMessengerHub() {
    final conversations = _buildChatConversationSummaries();
    final isMobile = MediaQuery.of(context).size.width < 760;
    if (conversations.isEmpty) {
      if (isMobile) {
        return _buildMessengerMobileChatListScreen(
          conversations: const [],
          activeConversationId: null,
        );
      }
      return _buildSectionCard(
        title: 'Messagerie Interne',
        subtitle:
            'Communication instantanée entre responsable, inséminateurs, vétérinaires et éleveurs',
        child: _buildEmptyState('Aucune conversation disponible.'),
      );
    }

    final activeConversationId = _resolveActiveConversationId(conversations);
    final activeConversation = conversations.firstWhere(
      (conversation) => conversation.id == activeConversationId,
      orElse: () => conversations.first,
    );
    _markConversationAsReadDeferred(activeConversation.id);
    final messages = _messagesForConversation(activeConversation.id);

    if (isMobile) {
      return _buildMessengerMobileExperience(
        conversations: conversations,
        activeConversation: activeConversation,
        messages: messages,
      );
    }

    return _buildSectionCard(
      title: 'Messagerie Interne',
      subtitle:
          'Canal équipe + discussions directes (style WhatsApp/Telegram) pour la coordination terrain',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 980;
          final maxHeight = isWide
              ? math.max(
                  520.0,
                  math.min(700.0, MediaQuery.of(context).size.height * 0.78),
                )
              : math.max(
                  560.0,
                  math.min(760.0, MediaQuery.of(context).size.height * 0.86),
                );

          final thread = _buildMessengerThread(
            activeConversation: activeConversation,
            messages: messages,
            maxHeight: maxHeight,
          );

          if (isWide) {
            return SizedBox(
              height: maxHeight,
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildMessengerConversationList(
                      conversations: conversations,
                      activeConversationId: activeConversation.id,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(child: thread),
                ],
              ),
            );
          }

          return _buildMessengerMobileShell(
            conversations: conversations,
            activeConversation: activeConversation,
            messages: messages,
            maxHeight: maxHeight,
          );
        },
      ),
    );
  }

  Widget _buildMessengerMobileExperience({
    required List<_ChatConversationSummary> conversations,
    required _ChatConversationSummary activeConversation,
    required List<ChatMessage> messages,
  }) {
    if (_isMobileMessengerThreadOpen) {
      return _buildMessengerMobileThreadScreen(
        activeConversation: activeConversation,
        messages: messages,
      );
    }
    return _buildMessengerMobileChatListScreen(
      conversations: conversations,
      activeConversationId: activeConversation.id,
    );
  }

  Widget _buildMessengerMobileChatListScreen({
    required List<_ChatConversationSummary> conversations,
    required String? activeConversationId,
  }) {
    final filteredConversations = _filteredChatConversations(conversations);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: _durocChatBackgroundBottom),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s6,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_durocChatHeader, _durocChatHeaderSoft],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Menu',
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.s2),
                const Expanded(
                  child: Text(
                    'Discussions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Nouveau message',
                  onPressed: () {
                    if (conversations.isNotEmpty) {
                      _openMobileMessengerConversation(conversations.first.id);
                    }
                  },
                  icon: const Icon(Icons.chat_outlined, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Options',
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s10,
              AppSpacing.s8,
              AppSpacing.s10,
              AppSpacing.s8,
            ),
            color: _durocChatInputSurface,
            child: _buildMessengerMobileConversationSearchField(),
          ),
          Expanded(
            child: filteredConversations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      child: Text(
                        _messengerConversationFilter.trim().isEmpty
                            ? 'Aucune conversation disponible.'
                            : 'Aucun résultat pour "${_messengerConversationFilter.trim()}".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredConversations.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: AppSpacing.s4),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s8,
                      AppSpacing.s8,
                      AppSpacing.s8,
                      AppSpacing.s8,
                    ),
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final isActive = conversation.id == activeConversationId;
                      return _buildMessengerMobileConversationTile(
                        conversation: conversation,
                        isActive: isActive,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerMobileConversationSearchField() {
    if (_messengerSearchController.text != _messengerConversationFilter) {
      _messengerSearchController.value = TextEditingValue(
        text: _messengerConversationFilter,
        selection: TextSelection.collapsed(
          offset: _messengerConversationFilter.length,
        ),
      );
    }

    return TextField(
      controller: _messengerSearchController,
      onChanged: (value) {
        setState(() => _messengerConversationFilter = value);
      },
      decoration: InputDecoration(
        hintText: 'Rechercher',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _messengerConversationFilter.trim().isEmpty
            ? null
            : IconButton(
                tooltip: 'Effacer',
                onPressed: () {
                  _messengerSearchController.clear();
                  setState(() => _messengerConversationFilter = '');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s10,
        ),
      ),
    );
  }

  Widget _buildMessengerMobileConversationTile({
    required _ChatConversationSummary conversation,
    required bool isActive,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openMobileMessengerConversation(conversation.id),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: conversation.avatarColor.withValues(alpha: 0.16),
              child: Text(
                conversation.avatarLabel,
                style: TextStyle(
                  color: conversation.avatarColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    conversation.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.lastMessageAt == null
                      ? '-'
                      : _chatTimeLabel(conversation.lastMessageAt!),
                  style: TextStyle(
                    color: isActive
                        ? _durocChatHeader
                        : const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s7,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: _durocChatHeader,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessengerMobileThreadScreen({
    required _ChatConversationSummary activeConversation,
    required List<ChatMessage> messages,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = math.max(220.0, screenWidth * 0.76);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_durocChatBackgroundTop, _durocChatBackgroundBottom],
        ),
      ),
      child: Column(
        children: [
          _buildMessengerMobileThreadHeader(activeConversation),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                      child: Text(
                        'Aucun message pour cette conversation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s8,
                      AppSpacing.s10,
                      AppSpacing.s8,
                      AppSpacing.s10,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final previous = index > 0 ? messages[index - 1] : null;
                      final showDateChip =
                          previous == null ||
                          !_isSameDate(previous.sentAt, message.sentAt);
                      final isMine = message.senderId == _currentUser.id;
                      final showSender = !isMine && activeConversation.isGroup;
                      final readByOthers = message.readByUserIds.any(
                        (userId) => userId != message.senderId,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateChip) ...[
                            _buildMessengerMobileDateSeparator(message.sentAt),
                            const SizedBox(height: AppSpacing.s8),
                          ],
                          Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxBubbleWidth,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.s8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s11,
                                  vertical: AppSpacing.s8,
                                ),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? _durocChatOutgoingBubble
                                      : _durocChatIncomingBubble,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(
                                      isMine ? 18 : AppSpacing.s6,
                                    ),
                                    bottomRight: Radius.circular(
                                      isMine ? AppSpacing.s6 : 18,
                                    ),
                                  ),
                                  border: isMine
                                      ? null
                                      : Border.all(
                                          color: const Color(0xFFE9DFD7),
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showSender)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.s4,
                                        ),
                                        child: Text(
                                          message.senderName,
                                          style: const TextStyle(
                                            color: Color(0xFF8A6450),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    _buildChatMessageContent(
                                      message: message,
                                      isMine: isMine,
                                      mineTextColor: const Color(0xFF0F172A),
                                      mineSubTextColor: const Color(0xFF64748B),
                                    ),
                                    const SizedBox(height: AppSpacing.s4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _chatClockLabel(message.sentAt),
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (isMine) ...[
                                          const SizedBox(width: AppSpacing.s4),
                                          Icon(
                                            readByOthers
                                                ? Icons.done_all_rounded
                                                : Icons.done_rounded,
                                            size: 13,
                                            color: readByOthers
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _buildMessengerMobileInputBar(activeConversation.id),
        ],
      ),
    );
  }

  Widget _buildMessengerMobileThreadHeader(
    _ChatConversationSummary activeConversation,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s6,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_durocChatHeader, _durocChatHeaderSoft],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Retour',
            onPressed: () {
              setState(() => _isMobileMessengerThreadOpen = false);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              activeConversation.avatarLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeConversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _messengerMobilePresenceLabel(activeConversation),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Appel audio',
            onPressed: () => _startChatCall(activeConversation.id, 'audio'),
            icon: const Icon(Icons.call_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Appel vidéo',
            onPressed: () => _startChatCall(activeConversation.id, 'video'),
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Options',
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerMobileInputBar(String conversationId) {
    return Container(
      width: double.infinity,
      color: _durocChatInputSurface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s8,
        AppSpacing.s8,
        AppSpacing.s8,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _durocChatHeader.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Pièce jointe',
                onPressed: () => _openMessengerAttachmentSheet(conversationId),
                icon: const Icon(
                  Icons.add_rounded,
                  color: _durocChatHeader,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Expanded(
                      child: TextField(
                        controller: _chatComposerController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendChatMessage(conversationId),
                        decoration: const InputDecoration(
                          hintText: 'Écrire un message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: AppSpacing.s10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _chatComposerController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: _durocChatHeader,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: hasText ? 'Envoyer' : 'Audio',
                    onPressed: hasText
                        ? () => _sendChatMessage(conversationId)
                        : () => _pickAndSendChatAttachment(
                            conversationId,
                            'audio',
                          ),
                    icon: Icon(
                      hasText ? Icons.send_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessengerMobileDateSeparator(DateTime date) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _chatDayLabel(date),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _messengerMobilePresenceLabel(_ChatConversationSummary conversation) {
    if (conversation.id == _teamConversationId) {
      return 'en ligne';
    }
    if (conversation.lastMessageAt == null) {
      return 'en ligne';
    }
    return 'actif à ${_chatClockLabel(conversation.lastMessageAt!)}';
  }

  Widget _buildMessengerMobileShell({
    required List<_ChatConversationSummary> conversations,
    required _ChatConversationSummary activeConversation,
    required List<ChatMessage> messages,
    required double maxHeight,
  }) {
    final filteredConversations = _filteredChatConversations(conversations);

    if (_isMobileMessengerThreadOpen) {
      return _buildMessengerThread(
        activeConversation: activeConversation,
        messages: messages,
        maxHeight: maxHeight,
        showBackButton: true,
        onBack: () {
          setState(() => _isMobileMessengerThreadOpen = false);
        },
        mobile: true,
      );
    }

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessengerConversationSearchField(),
          const SizedBox(height: AppSpacing.s10),
          Expanded(
            child: filteredConversations.isEmpty
                ? _buildEmptyState(
                    _messengerConversationFilter.trim().isEmpty
                        ? 'Aucune conversation disponible.'
                        : 'Aucune conversation trouvée pour "${_messengerConversationFilter.trim()}".',
                  )
                : ListView.separated(
                    itemCount: filteredConversations.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final isActive = conversation.id == activeConversation.id;
                      return _buildMessengerConversationTile(
                        conversation: conversation,
                        isActive: isActive,
                        mobile: true,
                        onTap: () =>
                            _openMobileMessengerConversation(conversation.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<_ChatConversationSummary> _filteredChatConversations(
    List<_ChatConversationSummary> conversations,
  ) {
    final query = _messengerConversationFilter.trim();
    if (query.isEmpty) {
      return conversations;
    }
    final normalized = _normalizeLookup(query);
    return conversations.where((conversation) {
      return _normalizeLookup(conversation.title).contains(normalized) ||
          _normalizeLookup(conversation.subtitle).contains(normalized) ||
          _normalizeLookup(conversation.preview).contains(normalized);
    }).toList();
  }

  void _openMobileMessengerConversation(String conversationId) {
    final targetConversationId = conversationId.trim().isEmpty
        ? _teamConversationId
        : conversationId.trim();
    if (targetConversationId == _teamConversationId &&
        !_canCurrentUserAccessTeamConversation()) {
      _showError(_teamConversationAccessError());
      return;
    }
    setState(() {
      _isMobileMessengerThreadOpen = true;
      _activeChatConversationId = targetConversationId;
      _markConversationAsReadInState(_activeChatConversationId);
    });
    _persistState();
  }

  Widget _buildMessengerConversationSearchField() {
    if (_messengerSearchController.text != _messengerConversationFilter) {
      _messengerSearchController.value = TextEditingValue(
        text: _messengerConversationFilter,
        selection: TextSelection.collapsed(
          offset: _messengerConversationFilter.length,
        ),
      );
    }
    return TextField(
      controller: _messengerSearchController,
      onChanged: (value) {
        setState(() => _messengerConversationFilter = value);
      },
      decoration: InputDecoration(
        hintText: 'Rechercher une discussion...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _messengerConversationFilter.trim().isEmpty
            ? null
            : IconButton(
                tooltip: 'Effacer',
                onPressed: () {
                  _messengerSearchController.clear();
                  setState(() => _messengerConversationFilter = '');
                },
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE4EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE4EE)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      ),
    );
  }

  Widget _buildMessengerConversationList({
    required List<_ChatConversationSummary> conversations,
    required String activeConversationId,
  }) {
    final filteredConversations = _filteredChatConversations(conversations);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE4EE)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s12,
              AppSpacing.s12,
              AppSpacing.s12,
              AppSpacing.s6,
            ),
            child: Row(
              children: [
                Icon(Icons.forum_outlined, size: 16, color: Color(0xFF0F766E)),
                SizedBox(width: AppSpacing.s8),
                Text(
                  'Conversations',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              AppSpacing.zero,
              AppSpacing.s12,
              AppSpacing.s10,
            ),
            child: _buildMessengerConversationSearchField(),
          ),
          const Divider(height: 1, color: Color(0xFFDCE4EE)),
          Expanded(
            child: filteredConversations.isEmpty
                ? _buildEmptyState(
                    _messengerConversationFilter.trim().isEmpty
                        ? 'Aucune conversation disponible.'
                        : 'Aucun résultat pour "${_messengerConversationFilter.trim()}".',
                  )
                : ListView.separated(
                    itemCount: filteredConversations.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: AppSpacing.s2),
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final isActive = conversation.id == activeConversationId;
                      return _buildMessengerConversationTile(
                        conversation: conversation,
                        isActive: isActive,
                        onTap: () =>
                            _setActiveChatConversation(conversation.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerConversationTile({
    required _ChatConversationSummary conversation,
    required bool isActive,
    required VoidCallback onTap,
    bool mobile = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? _accentTeal.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: mobile
              ? Border.all(
                  color: isActive
                      ? _accentTeal.withValues(alpha: 0.45)
                      : const Color(0xFFDCE4EE),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? AppSpacing.s12 : AppSpacing.s10,
          vertical: mobile ? AppSpacing.s12 : AppSpacing.s10,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: mobile ? 22 : 18,
                  backgroundColor: conversation.avatarColor.withValues(
                    alpha: 0.16,
                  ),
                  child: Text(
                    conversation.avatarLabel,
                    style: TextStyle(
                      color: conversation.avatarColor,
                      fontWeight: FontWeight.w800,
                      fontSize: mobile ? 13 : 12,
                    ),
                  ),
                ),
                if (isActive)
                  const Positioned(
                    right: -1,
                    bottom: -1,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFF16A34A),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      fontSize: mobile ? 14 : 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    conversation.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    conversation.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.lastMessageAt == null
                      ? '-'
                      : _chatTimeLabel(conversation.lastMessageAt!),
                  style: TextStyle(
                    color: isActive ? _accentTealDeep : const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s7,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: _accentTealDeep,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessengerThread({
    required _ChatConversationSummary activeConversation,
    required List<ChatMessage> messages,
    required double maxHeight,
    bool showBackButton = false,
    VoidCallback? onBack,
    bool mobile = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = mobile ? math.max(220.0, screenWidth * 0.76) : 440.0;
    final borderRadius = mobile ? 18.0 : 22.0;

    return Container(
      height: maxHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFDCE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10,
              vertical: AppSpacing.s10,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    tooltip: 'Retour',
                    onPressed:
                        onBack ??
                        () {
                          setState(() => _isMobileMessengerThreadOpen = false);
                        },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Text(
                    activeConversation.avatarLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeConversation.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: mobile ? 14 : 15,
                        ),
                      ),
                      Text(
                        _chatThreadSubtitle(activeConversation),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Appel audio',
                  onPressed: () =>
                      _startChatCall(activeConversation.id, 'audio'),
                  icon: const Icon(Icons.call_outlined, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Appel vidéo',
                  onPressed: () =>
                      _startChatCall(activeConversation.id, 'video'),
                  icon: const Icon(
                    Icons.videocam_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5FBFA), Color(0xFFEEF7F6)],
                ),
              ),
              child: messages.isEmpty
                  ? _buildEmptyState(
                      'Aucun message pour cette conversation. Écrivez le premier message.',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? AppSpacing.s8 : AppSpacing.s12,
                        vertical: AppSpacing.s12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final previous = index > 0 ? messages[index - 1] : null;
                        final showDateChip =
                            previous == null ||
                            !_isSameDate(previous.sentAt, message.sentAt);
                        final isMine = message.senderId == _currentUser.id;
                        final showSender =
                            !isMine && activeConversation.isGroup;
                        final readByOthers = message.readByUserIds.any(
                          (userId) => userId != message.senderId,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateChip) ...[
                              _buildMessengerDateChip(message.sentAt),
                              const SizedBox(height: AppSpacing.s6),
                            ],
                            Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxBubbleWidth,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.s8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s11,
                                    vertical: AppSpacing.s8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? const Color(0xFF0F766E)
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        isMine ? 16 : 5,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMine ? 5 : 16,
                                      ),
                                    ),
                                    border: Border.all(
                                      color: isMine
                                          ? const Color(0xFF0D9488)
                                          : const Color(0xFFDCE4EE),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isMine
                                            ? const Color(
                                                0xFF0F766E,
                                              ).withValues(alpha: 0.20)
                                            : const Color(
                                                0xFF0F172A,
                                              ).withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showSender)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.s4,
                                          ),
                                          child: Text(
                                            message.senderName,
                                            style: const TextStyle(
                                              color: Color(0xFF5EEAD4),
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      _buildChatMessageContent(
                                        message: message,
                                        isMine: isMine,
                                      ),
                                      const SizedBox(height: AppSpacing.s4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _chatClockLabel(message.sentAt),
                                            style: TextStyle(
                                              color: isMine
                                                  ? Colors.white70
                                                  : const Color(0xFF64748B),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (isMine) ...[
                                            const SizedBox(
                                              width: AppSpacing.s5,
                                            ),
                                            Icon(
                                              readByOthers
                                                  ? Icons.done_all_rounded
                                                  : Icons.done_rounded,
                                              size: 13,
                                              color: readByOthers
                                                  ? const Color(0xFFBFDBFE)
                                                  : Colors.white70,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              mobile ? AppSpacing.s8 : AppSpacing.s12,
              AppSpacing.s8,
              mobile ? AppSpacing.s8 : AppSpacing.s12,
              mobile ? AppSpacing.s10 : AppSpacing.s12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFDCE4EE))),
            ),
            child: Column(
              children: [
                if (!mobile)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickAndSendChatAttachment(
                            activeConversation.id,
                            'image',
                          ),
                          icon: const Icon(Icons.image_outlined, size: 16),
                          label: const Text('Image'),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        OutlinedButton.icon(
                          onPressed: () => _pickAndSendChatAttachment(
                            activeConversation.id,
                            'video',
                          ),
                          icon: const Icon(Icons.videocam_outlined, size: 16),
                          label: const Text('Vidéo'),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        OutlinedButton.icon(
                          onPressed: () => _pickAndSendChatAttachment(
                            activeConversation.id,
                            'audio',
                          ),
                          icon: const Icon(
                            Icons.multitrack_audio_outlined,
                            size: 16,
                          ),
                          label: const Text('Audio'),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    if (mobile) ...[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0F766E,
                          ).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Pièce jointe',
                          onPressed: () => _openMessengerAttachmentSheet(
                            activeConversation.id,
                          ),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    Expanded(
                      child: TextField(
                        controller: _chatComposerController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) =>
                            _sendChatMessage(activeConversation.id),
                        decoration: InputDecoration(
                          hintText: 'Écrire un message...',
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE4EE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE4EE),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s14,
                            vertical: AppSpacing.s10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F766E),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: 'Envoyer',
                        onPressed: () =>
                            _sendChatMessage(activeConversation.id),
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerDateChip(DateTime date) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _chatDayLabel(date),
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _openMessengerAttachmentSheet(String conversationId) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Envoyer une image'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndSendChatAttachment(conversationId, 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Envoyer une vidéo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndSendChatAttachment(conversationId, 'video');
                },
              ),
              ListTile(
                leading: const Icon(Icons.multitrack_audio_outlined),
                title: const Text('Envoyer un audio'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndSendChatAttachment(conversationId, 'audio');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _chatThreadSubtitle(_ChatConversationSummary conversation) {
    if (conversation.id == _teamConversationId) {
      return '${_teamConversationParticipantCount()} participant(s)';
    }
    if (conversation.unreadCount > 0) {
      return '${conversation.unreadCount} nouveau(x) message(s)';
    }
    if (conversation.lastMessageAt != null) {
      return 'Actif ${_chatTimeLabel(conversation.lastMessageAt!)}';
    }
    return conversation.subtitle;
  }

  Widget _buildUsersManagement() {
    final rows = _users
        .map(
          (user) => DataRow(
            cells: [
              DataCell(_buildUserAvatar(user, radius: 16)),
              DataCell(Text(user.code)),
              DataCell(Text(user.name)),
              DataCell(Text(user.address.isEmpty ? '-' : user.address)),
              DataCell(Text(user.contact.isEmpty ? '-' : user.contact)),
              DataCell(Text(_territoryLabel(user))),
              DataCell(Text(user.role)),
              DataCell(Text(user.login)),
              DataCell(
                Text(
                  _authStateLabel(user),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _authStateLabel(user) == 'Hashé'
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
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
                  label: 'MDP hashés',
                  value:
                      '${_users.where((user) => _isHashedPassword(user.password)).length}/${_users.length}',
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
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(child: indicators[1]),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(child: indicators[2]),
                  ],
                );
              }

              return Column(
                children: [
                  indicators[0],
                  const SizedBox(height: AppSpacing.s10),
                  indicators[1],
                  const SizedBox(height: AppSpacing.s10),
                  indicators[2],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
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
            DataColumn(label: Text('PHOTO')),
            DataColumn(label: Text('CODE')),
            DataColumn(label: Text('NOM')),
            DataColumn(label: Text('ADRESSE')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('ZONE TERRAIN')),
            DataColumn(label: Text('RÔLE')),
            DataColumn(label: Text('LOGIN')),
            DataColumn(label: Text('SÉCURITÉ MDP')),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 520;

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(compact ? AppSpacing.s14 : AppSpacing.xxxl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFDCE4EE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x110F172A),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: compact ? 16 : 18,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: compact ? 12 : 16),
            child,
          ],
        ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 560;

    return _buildSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actions.isNotEmpty) ...[
            Wrap(spacing: 8, runSpacing: 8, children: actions),
            const SizedBox(height: AppSpacing.s12),
          ],
          rows.isEmpty
              ? _buildEmptyState(emptyMessage)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF334155),
                    ),
                    dataTextStyle: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    horizontalMargin: compact ? 8 : 24,
                    columnSpacing: compact ? 12 : 24,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
      decoration: BoxDecoration(
        color: _surfaceSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE4EE)),
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
          AppTabs.profile,
          AppTabs.actualites,
          AppTabs.messenger,
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
          AppTabs.profile,
          AppTabs.actualites,
          AppTabs.messenger,
          AppTabs.elevage,
          AppTabs.boars,
          AppTabs.sows,
          AppTabs.pedigree,
        ];
      case Roles.vet:
        return const [
          AppTabs.dashboard,
          AppTabs.profile,
          AppTabs.actualites,
          AppTabs.messenger,
          AppTabs.health,
        ];
      default:
        return const [
          AppTabs.dashboard,
          AppTabs.profile,
          AppTabs.actualites,
          AppTabs.messenger,
        ];
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
      case AppTabs.profile:
        return 'PROFIL UTILISATEUR';
      case AppTabs.actualites:
        return 'ACTUALITÉS ÉLEVAGE';
      case AppTabs.messenger:
        return 'MESSAGERIE INTERNE ÉLEVAGE';
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
        return 'PIGIA';
    }
  }

  String _compactTitleForTab(String tabId) {
    switch (tabId) {
      case AppTabs.dashboard:
        return 'Tableau de bord';
      case AppTabs.profile:
        return 'Mon profil';
      case AppTabs.actualites:
        return 'Actualités';
      case AppTabs.messenger:
        return 'Messagerie';
      case AppTabs.administration:
        return 'Administration';
      case AppTabs.services:
        return 'Pack services';
      case AppTabs.elevage:
        return 'Élevage';
      case AppTabs.inseminations:
        return 'Inséminations IA';
      case AppTabs.boars:
        return 'Verrats';
      case AppTabs.sows:
        return 'Truies';
      case AppTabs.pedigree:
        return 'Pedigree';
      case AppTabs.health:
        return 'Santé';
      case AppTabs.commercial:
        return 'Commercial & Stock';
      case AppTabs.logiciel:
        return 'Caractéristiques';
      case AppTabs.users:
        return 'Utilisateurs';
      default:
        return 'PigIA';
    }
  }

  bool _canAddForTab(String tabId) {
    if (!_canAccessTab(tabId)) {
      return false;
    }
    return !const {
      AppTabs.users,
      AppTabs.administration,
      AppTabs.profile,
      AppTabs.messenger,
      AppTabs.services,
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
      case AppTabs.actualites:
        return Icons.edit_rounded;
      case AppTabs.sows:
        return LucideIcons.piggyBank;
      case AppTabs.pedigree:
        return LucideIcons.dna;
      case AppTabs.elevage:
        return LucideIcons.layers;
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
      case AppTabs.actualites:
        return 'Publier';
      case AppTabs.sows:
        return 'Ajouter Truie';
      case AppTabs.pedigree:
        return 'Ajouter Animal';
      case AppTabs.elevage:
        return 'Ajouter donnée élevage';
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
      case AppTabs.actualites:
        _showAddNewsPostDialog();
        break;
      case AppTabs.sows:
        _showAddSowDialog();
        break;
      case AppTabs.pedigree:
        _showAddAnimalDialogFromPedigree();
        break;
      case AppTabs.elevage:
        _showAddElevageActionSheet();
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

  void _showAddElevageActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Ajouter un bâtiment'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddBuildingDialog();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.layers),
                title: const Text('Ajouter une bande'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddBatchDialog();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trendingUp),
                title: const Text('Ajouter un suivi croissance'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddGrowthDialog();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.piggyBank),
                title: const Text('Ajouter une mise-bas'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddFarrowingDialog();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.piggyBank),
                title: const Text('Ajouter une prise en charge porcelets'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddPigletCareDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Publier un animal à vendre'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddAnimalSaleListingDialog();
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(sireCtrl, 'Code père (optionnel)'),
                      _dialogField(damCtrl, 'Code mère (optionnel)'),
                      _dialogField(
                        semenTypeCtrl,
                        'Type semence',
                        hint: 'Fraîche / Congelée',
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(selectedImageBase64, size: 88),
                          const SizedBox(width: AppSpacing.s10),
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
                                const SizedBox(height: AppSpacing.s6),
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
                      const SizedBox(height: AppSpacing.s12),
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
    String selectedImageBase64 = '';

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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(sireCtrl, 'Code père (optionnel)'),
                      _dialogField(damCtrl, 'Code mère (optionnel)'),
                      const SizedBox(height: AppSpacing.s2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(selectedImageBase64, size: 88),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Photo truie',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s6),
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
                      const SizedBox(height: AppSpacing.s12),
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
                          imageBase64: selectedImageBase64,
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s8),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _boars.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: AppSpacing.s8),
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
                                padding: const EdgeInsets.all(AppSpacing.s8),
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
                                    const SizedBox(width: AppSpacing.s8),
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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

                    final consanguinityIssue = _consanguinityIssue(
                      selectedSowCode,
                      selectedBoarCode,
                    );
                    if (consanguinityIssue != null) {
                      _showError(
                        'IA bloquée (consanguinité): $consanguinityIssue.',
                      );
                      return;
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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

  void _showAddBuildingDialog() {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'Gestation');
    final capacityCtrl = TextEditingController();
    final occupiedCtrl = TextEditingController(text: '0');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouveau bâtiment'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Nom bâtiment *', hint: 'Bâtiment D'),
                _dialogField(
                  typeCtrl,
                  'Type *',
                  hint: 'Maternité / Gestation / Post-sevrage',
                ),
                _dialogField(
                  capacityCtrl,
                  'Capacité *',
                  keyboardType: TextInputType.number,
                ),
                _dialogField(
                  occupiedCtrl,
                  'Occupés *',
                  keyboardType: TextInputType.number,
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
                final name = nameCtrl.text.trim();
                final type = typeCtrl.text.trim();
                final capacity = int.tryParse(capacityCtrl.text.trim());
                final occupied = int.tryParse(occupiedCtrl.text.trim());

                if (name.isEmpty ||
                    type.isEmpty ||
                    capacity == null ||
                    occupied == null) {
                  _showError(
                    'Veuillez renseigner nom, type, capacité et occupés.',
                  );
                  return;
                }
                if (capacity <= 0) {
                  _showError('La capacité doit être > 0.');
                  return;
                }
                if (occupied < 0 || occupied > capacity) {
                  _showError('Le nombre occupé doit être entre 0 et capacité.');
                  return;
                }

                setState(() {
                  _buildings.insert(
                    0,
                    BuildingRecord(
                      id: _newId('BLD'),
                      name: name,
                      type: type,
                      capacity: capacity,
                      occupied: occupied,
                    ),
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Bâtiment ajouté.');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ).then(
      (_) =>
          _disposeControllers([nameCtrl, typeCtrl, capacityCtrl, occupiedCtrl]),
    );
  }

  void _showEditBuildingDialog(BuildingRecord building) {
    final nameCtrl = TextEditingController(text: building.name);
    final typeCtrl = TextEditingController(text: building.type);
    final capacityCtrl = TextEditingController(text: '${building.capacity}');
    final occupiedCtrl = TextEditingController(text: '${building.occupied}');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Modifier ${building.name}'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Nom bâtiment *'),
                _dialogField(typeCtrl, 'Type *'),
                _dialogField(
                  capacityCtrl,
                  'Capacité *',
                  keyboardType: TextInputType.number,
                ),
                _dialogField(
                  occupiedCtrl,
                  'Occupés *',
                  keyboardType: TextInputType.number,
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
                final index = _buildings.indexWhere(
                  (item) => item.id == building.id,
                );
                if (index < 0) {
                  Navigator.of(dialogContext).pop();
                  _showError('Bâtiment introuvable.');
                  return;
                }

                final name = nameCtrl.text.trim();
                final type = typeCtrl.text.trim();
                final capacity = int.tryParse(capacityCtrl.text.trim());
                final occupied = int.tryParse(occupiedCtrl.text.trim());

                if (name.isEmpty ||
                    type.isEmpty ||
                    capacity == null ||
                    occupied == null) {
                  _showError(
                    'Veuillez renseigner nom, type, capacité et occupés.',
                  );
                  return;
                }
                if (capacity <= 0) {
                  _showError('La capacité doit être > 0.');
                  return;
                }
                if (occupied < 0 || occupied > capacity) {
                  _showError('Le nombre occupé doit être entre 0 et capacité.');
                  return;
                }

                setState(() {
                  _buildings[index] = BuildingRecord(
                    id: building.id,
                    name: name,
                    type: type,
                    capacity: capacity,
                    occupied: occupied,
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Bâtiment mis à jour.');
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    ).then(
      (_) =>
          _disposeControllers([nameCtrl, typeCtrl, capacityCtrl, occupiedCtrl]),
    );
  }

  void _showAddBatchDialog() {
    final nameCtrl = TextEditingController();
    final stageCtrl = TextEditingController(text: 'Maternité');
    final startDateCtrl = TextEditingController();
    final animalsCtrl = TextEditingController();
    final avgWeightCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle bande'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Nom bande *', hint: 'Bande Avr-26'),
                  _dialogField(
                    stageCtrl,
                    'Stade *',
                    hint: 'Maternité / Post-sevrage / Croissance',
                  ),
                  _dialogField(
                    startDateCtrl,
                    'Date début *',
                    hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                  ),
                  _dialogField(
                    animalsCtrl,
                    'Nombre animaux *',
                    keyboardType: TextInputType.number,
                  ),
                  _dialogField(
                    avgWeightCtrl,
                    'Poids moyen (kg) *',
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
                final name = nameCtrl.text.trim();
                final stage = stageCtrl.text.trim();
                final startDate = _tryParseDate(startDateCtrl.text.trim());
                final animals = int.tryParse(animalsCtrl.text.trim());
                final avgWeight = _tryParseAmount(avgWeightCtrl.text.trim());

                if (name.isEmpty ||
                    stage.isEmpty ||
                    startDate == null ||
                    animals == null ||
                    avgWeight == null) {
                  _showError(
                    'Veuillez renseigner nom, stade, date valide, effectif et poids.',
                  );
                  return;
                }
                if (animals <= 0) {
                  _showError('Le nombre d\'animaux doit être > 0.');
                  return;
                }
                if (avgWeight < 0) {
                  _showError('Le poids moyen doit être >= 0.');
                  return;
                }

                setState(() {
                  _batchRecords.insert(
                    0,
                    BatchRecord(
                      id: _newId('BT'),
                      name: name,
                      stage: stage,
                      startDate: startDate,
                      animals: animals,
                      avgWeight: avgWeight,
                    ),
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Bande ajoutée.');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ).then(
      (_) => _disposeControllers([
        nameCtrl,
        stageCtrl,
        startDateCtrl,
        animalsCtrl,
        avgWeightCtrl,
      ]),
    );
  }

  void _showEditBatchDialog(BatchRecord batch) {
    final nameCtrl = TextEditingController(text: batch.name);
    final stageCtrl = TextEditingController(text: batch.stage);
    final startDateCtrl = TextEditingController(
      text: _formatDate(batch.startDate),
    );
    final animalsCtrl = TextEditingController(text: '${batch.animals}');
    final avgWeightCtrl = TextEditingController(
      text: batch.avgWeight.toStringAsFixed(1),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Modifier ${batch.name}'),
          content: SizedBox(
            width: _dialogWidth(dialogContext),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Nom bande *'),
                  _dialogField(stageCtrl, 'Stade *'),
                  _dialogField(
                    startDateCtrl,
                    'Date début *',
                    hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                  ),
                  _dialogField(
                    animalsCtrl,
                    'Nombre animaux *',
                    keyboardType: TextInputType.number,
                  ),
                  _dialogField(
                    avgWeightCtrl,
                    'Poids moyen (kg) *',
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
                final index = _batchRecords.indexWhere(
                  (item) => item.id == batch.id,
                );
                if (index < 0) {
                  Navigator.of(dialogContext).pop();
                  _showError('Bande introuvable.');
                  return;
                }

                final name = nameCtrl.text.trim();
                final stage = stageCtrl.text.trim();
                final startDate = _tryParseDate(startDateCtrl.text.trim());
                final animals = int.tryParse(animalsCtrl.text.trim());
                final avgWeight = _tryParseAmount(avgWeightCtrl.text.trim());

                if (name.isEmpty ||
                    stage.isEmpty ||
                    startDate == null ||
                    animals == null ||
                    avgWeight == null) {
                  _showError(
                    'Veuillez renseigner nom, stade, date valide, effectif et poids.',
                  );
                  return;
                }
                if (animals <= 0) {
                  _showError('Le nombre d\'animaux doit être > 0.');
                  return;
                }
                if (avgWeight < 0) {
                  _showError('Le poids moyen doit être >= 0.');
                  return;
                }

                setState(() {
                  _batchRecords[index] = BatchRecord(
                    id: batch.id,
                    name: name,
                    stage: stage,
                    startDate: startDate,
                    animals: animals,
                    avgWeight: avgWeight,
                  );
                });
                _persistState();
                Navigator.of(dialogContext).pop();
                _showInfo('Bande mise à jour.');
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    ).then(
      (_) => _disposeControllers([
        nameCtrl,
        stageCtrl,
        startDateCtrl,
        animalsCtrl,
        avgWeightCtrl,
      ]),
    );
  }

  void _showAddGrowthDialog() {
    if (_batchRecords.isEmpty) {
      _showError('Ajoutez d\'abord une bande.');
      return;
    }

    final dateCtrl = TextEditingController();
    final avgWeightCtrl = TextEditingController();
    final dailyGainCtrl = TextEditingController();
    String selectedBatchId = _batchRecords.first.id;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouveau suivi croissance'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedBatchId,
                        decoration: const InputDecoration(
                          labelText: 'Bande *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _batchRecords
                            .map(
                              (batch) => DropdownMenuItem(
                                value: batch.id,
                                child: Text(batch.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBatchId = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        dateCtrl,
                        'Date mesure *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        avgWeightCtrl,
                        'Poids moyen (kg) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        dailyGainCtrl,
                        'GMQ (kg/j) *',
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
                    final avgWeight = _tryParseAmount(
                      avgWeightCtrl.text.trim(),
                    );
                    final dailyGain = _tryParseAmount(
                      dailyGainCtrl.text.trim(),
                    );

                    if (date == null ||
                        avgWeight == null ||
                        dailyGain == null) {
                      _showError(
                        'Veuillez renseigner une date valide, poids moyen et GMQ.',
                      );
                      return;
                    }
                    if (avgWeight < 0 || dailyGain < 0) {
                      _showError('Le poids moyen et GMQ doivent être >= 0.');
                      return;
                    }

                    setState(() {
                      _growthRecords.insert(
                        0,
                        GrowthRecord(
                          id: _newId('GR'),
                          batchId: selectedBatchId,
                          date: date,
                          avgWeight: avgWeight,
                          dailyGain: dailyGain,
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Suivi croissance ajouté.');
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([dateCtrl, avgWeightCtrl, dailyGainCtrl]),
    );
  }

  void _showEditGrowthDialog(GrowthRecord growth) {
    if (_batchRecords.isEmpty) {
      _showError('Aucune bande disponible pour ce suivi.');
      return;
    }

    final dateCtrl = TextEditingController(text: _formatDate(growth.date));
    final avgWeightCtrl = TextEditingController(
      text: growth.avgWeight.toStringAsFixed(1),
    );
    final dailyGainCtrl = TextEditingController(
      text: growth.dailyGain.toStringAsFixed(2),
    );
    String selectedBatchId =
        _batchRecords.any((item) => item.id == growth.batchId)
        ? growth.batchId
        : _batchRecords.first.id;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Modifier suivi croissance'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedBatchId,
                        decoration: const InputDecoration(
                          labelText: 'Bande *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _batchRecords
                            .map(
                              (batch) => DropdownMenuItem(
                                value: batch.id,
                                child: Text(batch.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBatchId = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        dateCtrl,
                        'Date mesure *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        avgWeightCtrl,
                        'Poids moyen (kg) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        dailyGainCtrl,
                        'GMQ (kg/j) *',
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
                    final index = _growthRecords.indexWhere(
                      (item) => item.id == growth.id,
                    );
                    if (index < 0) {
                      Navigator.of(dialogContext).pop();
                      _showError('Suivi croissance introuvable.');
                      return;
                    }

                    final date = _tryParseDate(dateCtrl.text.trim());
                    final avgWeight = _tryParseAmount(
                      avgWeightCtrl.text.trim(),
                    );
                    final dailyGain = _tryParseAmount(
                      dailyGainCtrl.text.trim(),
                    );

                    if (date == null ||
                        avgWeight == null ||
                        dailyGain == null) {
                      _showError(
                        'Veuillez renseigner une date valide, poids moyen et GMQ.',
                      );
                      return;
                    }
                    if (avgWeight < 0 || dailyGain < 0) {
                      _showError('Le poids moyen et GMQ doivent être >= 0.');
                      return;
                    }

                    setState(() {
                      _growthRecords[index] = GrowthRecord(
                        id: growth.id,
                        batchId: selectedBatchId,
                        date: date,
                        avgWeight: avgWeight,
                        dailyGain: dailyGain,
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Suivi croissance mis à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([dateCtrl, avgWeightCtrl, dailyGainCtrl]),
    );
  }

  String _semenQualityStatus(SemenQualityRecord record) {
    var score = 0;
    if (record.concentration >= 2.5) {
      score++;
    }
    if (record.motilityPercent >= 70) {
      score++;
    }
    if (record.temperatureC >= 15 && record.temperatureC <= 18) {
      score++;
    }
    if (record.storageHours <= 24) {
      score++;
    }
    if (score >= 4) {
      return 'Conforme';
    }
    if (score >= 2) {
      return 'Surveiller';
    }
    return 'Critique';
  }

  void _showAddSemenQualityDialog() {
    if (_boars.isEmpty) {
      _showError('Ajoutez d\'abord un verrat.');
      return;
    }
    final lotCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final concentrationCtrl = TextEditingController();
    final motilityCtrl = TextEditingController();
    final tempCtrl = TextEditingController(text: '16.0');
    final storageCtrl = TextEditingController(text: '24');
    final approvedByCtrl = TextEditingController(
      text: _firstUserNameByRole(Roles.vet),
    );
    final notesCtrl = TextEditingController();
    String selectedBoarCode = _boars.first.code;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouveau contrôle semence'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(
                        lotCtrl,
                        'Lot semence *',
                        hint: 'LOT-IA-2412',
                      ),
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
                                child: Text('${boar.code} - ${boar.name}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBoarCode = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        dateCtrl,
                        'Date collecte *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        concentrationCtrl,
                        'Concentration (Md/ml) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        motilityCtrl,
                        'Motilité (%) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        tempCtrl,
                        'Température stockage (°C) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        storageCtrl,
                        'Durée stockage (heures) *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(approvedByCtrl, 'Validé par *'),
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
                    final lot = lotCtrl.text.trim();
                    final date = _tryParseDate(dateCtrl.text.trim());
                    final concentration = _tryParseAmount(
                      concentrationCtrl.text.trim(),
                    );
                    final motility = _tryParseAmount(motilityCtrl.text.trim());
                    final temperature = _tryParseAmount(tempCtrl.text.trim());
                    final storage = int.tryParse(storageCtrl.text.trim());
                    final approvedBy = approvedByCtrl.text.trim();

                    if (lot.isEmpty ||
                        date == null ||
                        concentration == null ||
                        motility == null ||
                        temperature == null ||
                        storage == null ||
                        approvedBy.isEmpty) {
                      _showError(
                        'Veuillez remplir lot, date valide, mesures et validateur.',
                      );
                      return;
                    }
                    if (concentration <= 0 ||
                        motility < 0 ||
                        motility > 100 ||
                        temperature <= 0 ||
                        storage < 0) {
                      _showError(
                        'Mesures invalides: concentration > 0, motilité 0-100, température > 0, stockage >= 0.',
                      );
                      return;
                    }

                    final record = SemenQualityRecord(
                      id: _newId('SQ'),
                      lotCode: lot,
                      boarCode: selectedBoarCode,
                      collectionDate: date,
                      concentration: concentration,
                      motilityPercent: motility,
                      temperatureC: temperature,
                      storageHours: storage,
                      approvedBy: approvedBy,
                      notes: notesCtrl.text.trim(),
                    );
                    setState(() => _semenQualityRecords.insert(0, record));
                    _addAuditLog(
                      module: 'SEMENCE',
                      action: 'CREATE_SEMEN_QUALITY',
                      detail:
                          'Lot ${record.lotCode} • statut ${_semenQualityStatus(record)}',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Contrôle semence ajouté.');
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
        dateCtrl,
        concentrationCtrl,
        motilityCtrl,
        tempCtrl,
        storageCtrl,
        approvedByCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showEditSemenQualityDialog(SemenQualityRecord record) {
    if (_boars.isEmpty) {
      _showError('Aucun verrat disponible.');
      return;
    }
    final lotCtrl = TextEditingController(text: record.lotCode);
    final dateCtrl = TextEditingController(
      text: _formatDate(record.collectionDate),
    );
    final concentrationCtrl = TextEditingController(
      text: record.concentration.toStringAsFixed(2),
    );
    final motilityCtrl = TextEditingController(
      text: record.motilityPercent.toStringAsFixed(0),
    );
    final tempCtrl = TextEditingController(
      text: record.temperatureC.toStringAsFixed(1),
    );
    final storageCtrl = TextEditingController(text: '${record.storageHours}');
    final approvedByCtrl = TextEditingController(text: record.approvedBy);
    final notesCtrl = TextEditingController(text: record.notes);
    String selectedBoarCode = _boars.any((boar) => boar.code == record.boarCode)
        ? record.boarCode
        : _boars.first.code;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Modifier contrôle semence'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(lotCtrl, 'Lot semence *'),
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
                                child: Text('${boar.code} - ${boar.name}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedBoarCode = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(dateCtrl, 'Date collecte *'),
                      _dialogField(
                        concentrationCtrl,
                        'Concentration (Md/ml) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        motilityCtrl,
                        'Motilité (%) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        tempCtrl,
                        'Température stockage (°C) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        storageCtrl,
                        'Durée stockage (heures) *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(approvedByCtrl, 'Validé par *'),
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
                    final index = _semenQualityRecords.indexWhere(
                      (item) => item.id == record.id,
                    );
                    if (index < 0) {
                      Navigator.of(dialogContext).pop();
                      _showError('Contrôle semence introuvable.');
                      return;
                    }
                    final lot = lotCtrl.text.trim();
                    final date = _tryParseDate(dateCtrl.text.trim());
                    final concentration = _tryParseAmount(
                      concentrationCtrl.text.trim(),
                    );
                    final motility = _tryParseAmount(motilityCtrl.text.trim());
                    final temperature = _tryParseAmount(tempCtrl.text.trim());
                    final storage = int.tryParse(storageCtrl.text.trim());
                    final approvedBy = approvedByCtrl.text.trim();

                    if (lot.isEmpty ||
                        date == null ||
                        concentration == null ||
                        motility == null ||
                        temperature == null ||
                        storage == null ||
                        approvedBy.isEmpty) {
                      _showError(
                        'Veuillez remplir lot, date valide, mesures et validateur.',
                      );
                      return;
                    }
                    if (concentration <= 0 ||
                        motility < 0 ||
                        motility > 100 ||
                        temperature <= 0 ||
                        storage < 0) {
                      _showError(
                        'Mesures invalides: concentration > 0, motilité 0-100, température > 0, stockage >= 0.',
                      );
                      return;
                    }

                    final updated = SemenQualityRecord(
                      id: record.id,
                      lotCode: lot,
                      boarCode: selectedBoarCode,
                      collectionDate: date,
                      concentration: concentration,
                      motilityPercent: motility,
                      temperatureC: temperature,
                      storageHours: storage,
                      approvedBy: approvedBy,
                      notes: notesCtrl.text.trim(),
                    );
                    setState(() => _semenQualityRecords[index] = updated);
                    _addAuditLog(
                      module: 'SEMENCE',
                      action: 'UPDATE_SEMEN_QUALITY',
                      detail: 'Lot ${updated.lotCode} mis à jour',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Contrôle semence mis à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        lotCtrl,
        dateCtrl,
        concentrationCtrl,
        motilityCtrl,
        tempCtrl,
        storageCtrl,
        approvedByCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showAddPigletCareDialog({
    DateTime? initialDate,
    String? initialEventType,
    String? initialSowCode,
    String? initialGroupName,
    String? initialDetails,
  }) {
    if (_sows.isEmpty) {
      _showError('Ajoutez d\'abord une truie pour lier la portée.');
      return;
    }

    final groupNameCtrl = TextEditingController(
      text: initialGroupName ?? 'Portée',
    );
    final eventDateCtrl = TextEditingController(
      text: initialDate == null ? '' : _formatDate(initialDate),
    );
    final detailsCtrl = TextEditingController(text: initialDetails ?? '');
    final responsibleCtrl = TextEditingController(text: _currentUser.name);
    final nextDateCtrl = TextEditingController();

    final availableEventTypes = const <String>[
      'Colostrum',
      'Coupe dents',
      'Supplémentation fer',
      'Castration',
      'Vaccination porcelets',
      'Traitement',
      'Sevrage',
    ];
    final sowCodes = _sows.map((sow) => sow.code).toList();
    String selectedSowCode =
        initialSowCode != null &&
            sowCodes.any(
              (code) => code.toLowerCase() == initialSowCode.toLowerCase(),
            )
        ? sowCodes.firstWhere(
            (code) => code.toLowerCase() == initialSowCode.toLowerCase(),
          )
        : _sows.first.code;
    String selectedEventType = availableEventTypes.contains(initialEventType)
        ? initialEventType!
        : 'Colostrum';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle prise en charge porcelets'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedSowCode,
                        decoration: const InputDecoration(
                          labelText: 'Truie / portée *',
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(groupNameCtrl, 'Nom portée / groupe *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Type soin *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: availableEventTypes
                            .map(
                              (eventType) => DropdownMenuItem(
                                value: eventType,
                                child: Text(eventType),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedEventType = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        eventDateCtrl,
                        'Date soin *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        nextDateCtrl,
                        'Prochaine date (optionnel)',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(responsibleCtrl, 'Responsable *'),
                      _dialogField(
                        detailsCtrl,
                        'Détails / observations *',
                        maxLines: 2,
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
                    final groupName = groupNameCtrl.text.trim();
                    final eventDate = _tryParseDate(eventDateCtrl.text.trim());
                    final responsible = responsibleCtrl.text.trim();
                    final details = detailsCtrl.text.trim();
                    DateTime? nextDate;

                    if (groupName.isEmpty ||
                        eventDate == null ||
                        responsible.isEmpty ||
                        details.isEmpty) {
                      _showError(
                        'Veuillez renseigner portée, date valide, responsable et détails.',
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
                      _pigletCareRecords.insert(
                        0,
                        PigletCareRecord(
                          id: _newId('PC'),
                          animalCode: selectedSowCode,
                          groupName: groupName,
                          eventDate: eventDate,
                          eventType: selectedEventType,
                          details: details,
                          responsible: responsible,
                          nextDate: nextDate,
                        ),
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Prise en charge porcelets ajoutée.');
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
        groupNameCtrl,
        eventDateCtrl,
        detailsCtrl,
        responsibleCtrl,
        nextDateCtrl,
      ]),
    );
  }

  void _showEditPigletCareDialog(PigletCareRecord record) {
    if (_sows.isEmpty) {
      _showError('Aucune truie disponible.');
      return;
    }

    final groupNameCtrl = TextEditingController(text: record.groupName);
    final eventDateCtrl = TextEditingController(
      text: _formatDate(record.eventDate),
    );
    final detailsCtrl = TextEditingController(text: record.details);
    final responsibleCtrl = TextEditingController(text: record.responsible);
    final nextDateCtrl = TextEditingController(
      text: record.nextDate == null ? '' : _formatDate(record.nextDate!),
    );

    String selectedSowCode = _sows.any((sow) => sow.code == record.animalCode)
        ? record.animalCode
        : _sows.first.code;
    final availableEventTypes = const <String>[
      'Colostrum',
      'Coupe dents',
      'Supplémentation fer',
      'Castration',
      'Vaccination porcelets',
      'Traitement',
      'Sevrage',
    ];
    String selectedEventType = availableEventTypes.contains(record.eventType)
        ? record.eventType
        : 'Traitement';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Modifier prise en charge porcelets'),
              content: SizedBox(
                width: _dialogWidth(dialogContext),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedSowCode,
                        decoration: const InputDecoration(
                          labelText: 'Truie / portée *',
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(groupNameCtrl, 'Nom portée / groupe *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Type soin *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: availableEventTypes
                            .map(
                              (eventType) => DropdownMenuItem(
                                value: eventType,
                                child: Text(eventType),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedEventType = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        eventDateCtrl,
                        'Date soin *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        nextDateCtrl,
                        'Prochaine date (optionnel)',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(responsibleCtrl, 'Responsable *'),
                      _dialogField(
                        detailsCtrl,
                        'Détails / observations *',
                        maxLines: 2,
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
                    final index = _pigletCareRecords.indexWhere(
                      (item) => item.id == record.id,
                    );
                    if (index < 0) {
                      Navigator.of(dialogContext).pop();
                      _showError('Prise en charge introuvable.');
                      return;
                    }

                    final groupName = groupNameCtrl.text.trim();
                    final eventDate = _tryParseDate(eventDateCtrl.text.trim());
                    final responsible = responsibleCtrl.text.trim();
                    final details = detailsCtrl.text.trim();
                    DateTime? nextDate;

                    if (groupName.isEmpty ||
                        eventDate == null ||
                        responsible.isEmpty ||
                        details.isEmpty) {
                      _showError(
                        'Veuillez renseigner portée, date valide, responsable et détails.',
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
                      _pigletCareRecords[index] = PigletCareRecord(
                        id: record.id,
                        animalCode: selectedSowCode,
                        groupName: groupName,
                        eventDate: eventDate,
                        eventType: selectedEventType,
                        details: details,
                        responsible: responsible,
                        nextDate: nextDate,
                      );
                    });
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Prise en charge mise à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        groupNameCtrl,
        eventDateCtrl,
        detailsCtrl,
        responsibleCtrl,
        nextDateCtrl,
      ]),
    );
  }

  void _showAddFarrowingDialog() {
    if (_sows.isEmpty) {
      _showError('Ajoutez d\'abord une truie.');
      return;
    }

    final dateCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final aliveCtrl = TextEditingController();
    final stillCtrl = TextEditingController(text: '0');
    final mumCtrl = TextEditingController(text: '0');
    final weanedCtrl = TextEditingController();
    final preWeaningCtrl = TextEditingController(text: '0');
    final weightCtrl = TextEditingController(text: '1.30');
    final issueCtrl = TextEditingController();
    final responsibleCtrl = TextEditingController(text: _currentUser.name);
    final notesCtrl = TextEditingController();
    String selectedSowCode = _sows.first.code;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle mise-bas'),
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        dateCtrl,
                        'Date mise-bas *',
                        hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                      ),
                      _dialogField(
                        totalCtrl,
                        'Nés total *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        aliveCtrl,
                        'Nés vivants *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        stillCtrl,
                        'Mort-nés',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        mumCtrl,
                        'Momifiés',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        weanedCtrl,
                        'Sevrés *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        preWeaningCtrl,
                        'Mortalité pré-sevrage',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        weightCtrl,
                        'Poids naissance moyen (kg) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(issueCtrl, 'Problème majeur'),
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
                    final date = _tryParseDate(dateCtrl.text.trim());
                    final total = int.tryParse(totalCtrl.text.trim());
                    final alive = int.tryParse(aliveCtrl.text.trim());
                    final still = int.tryParse(stillCtrl.text.trim()) ?? 0;
                    final mum = int.tryParse(mumCtrl.text.trim()) ?? 0;
                    final weaned = int.tryParse(weanedCtrl.text.trim());
                    final pre = int.tryParse(preWeaningCtrl.text.trim()) ?? 0;
                    final weight = _tryParseAmount(weightCtrl.text.trim());
                    final responsible = responsibleCtrl.text.trim();

                    if (date == null ||
                        total == null ||
                        alive == null ||
                        weaned == null ||
                        weight == null ||
                        responsible.isEmpty) {
                      _showError(
                        'Veuillez renseigner date valide, effectifs, poids et responsable.',
                      );
                      return;
                    }
                    if (total < 0 ||
                        alive < 0 ||
                        still < 0 ||
                        mum < 0 ||
                        weaned < 0 ||
                        pre < 0) {
                      _showError('Les effectifs doivent être positifs.');
                      return;
                    }
                    if (alive + still + mum > total) {
                      _showError(
                        'Incohérence: vivants + mort-nés + momifiés > nés total.',
                      );
                      return;
                    }
                    if (weaned > alive) {
                      _showError(
                        'Le nombre sevré ne peut pas dépasser les nés vivants.',
                      );
                      return;
                    }
                    if (pre > alive) {
                      _showError(
                        'La mortalité pré-sevrage ne peut pas dépasser les nés vivants.',
                      );
                      return;
                    }
                    if (weight <= 0) {
                      _showError('Le poids naissance moyen doit être > 0.');
                      return;
                    }

                    final record = FarrowingRecord(
                      id: _newId('FAR'),
                      sowCode: selectedSowCode,
                      farrowingDate: date,
                      totalBorn: total,
                      bornAlive: alive,
                      stillborn: still,
                      mummified: mum,
                      weaned: weaned,
                      preWeaningDeaths: pre,
                      avgBirthWeight: weight,
                      majorIssue: issueCtrl.text.trim(),
                      responsible: responsible,
                      notes: notesCtrl.text.trim(),
                    );
                    setState(() => _farrowingRecords.insert(0, record));
                    _addAuditLog(
                      module: 'MATERNITE',
                      action: 'CREATE_FARROWING',
                      detail:
                          'Mise-bas ${record.sowCode} (${record.bornAlive} nés vivants)',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Mise-bas enregistrée.');
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
        totalCtrl,
        aliveCtrl,
        stillCtrl,
        mumCtrl,
        weanedCtrl,
        preWeaningCtrl,
        weightCtrl,
        issueCtrl,
        responsibleCtrl,
        notesCtrl,
      ]),
    );
  }

  void _showEditFarrowingDialog(FarrowingRecord record) {
    if (_sows.isEmpty) {
      _showError('Aucune truie disponible.');
      return;
    }

    final dateCtrl = TextEditingController(
      text: _formatDate(record.farrowingDate),
    );
    final totalCtrl = TextEditingController(text: '${record.totalBorn}');
    final aliveCtrl = TextEditingController(text: '${record.bornAlive}');
    final stillCtrl = TextEditingController(text: '${record.stillborn}');
    final mumCtrl = TextEditingController(text: '${record.mummified}');
    final weanedCtrl = TextEditingController(text: '${record.weaned}');
    final preWeaningCtrl = TextEditingController(
      text: '${record.preWeaningDeaths}',
    );
    final weightCtrl = TextEditingController(
      text: record.avgBirthWeight.toStringAsFixed(2),
    );
    final issueCtrl = TextEditingController(text: record.majorIssue);
    final responsibleCtrl = TextEditingController(text: record.responsible);
    final notesCtrl = TextEditingController(text: record.notes);
    String selectedSowCode = _sows.any((sow) => sow.code == record.sowCode)
        ? record.sowCode
        : _sows.first.code;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Modifier mise-bas'),
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(dateCtrl, 'Date mise-bas *'),
                      _dialogField(
                        totalCtrl,
                        'Nés total *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        aliveCtrl,
                        'Nés vivants *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        stillCtrl,
                        'Mort-nés',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        mumCtrl,
                        'Momifiés',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        weanedCtrl,
                        'Sevrés *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        preWeaningCtrl,
                        'Mortalité pré-sevrage',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        weightCtrl,
                        'Poids naissance moyen (kg) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(issueCtrl, 'Problème majeur'),
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
                    final index = _farrowingRecords.indexWhere(
                      (item) => item.id == record.id,
                    );
                    if (index < 0) {
                      Navigator.of(dialogContext).pop();
                      _showError('Mise-bas introuvable.');
                      return;
                    }

                    final date = _tryParseDate(dateCtrl.text.trim());
                    final total = int.tryParse(totalCtrl.text.trim());
                    final alive = int.tryParse(aliveCtrl.text.trim());
                    final still = int.tryParse(stillCtrl.text.trim()) ?? 0;
                    final mum = int.tryParse(mumCtrl.text.trim()) ?? 0;
                    final weaned = int.tryParse(weanedCtrl.text.trim());
                    final pre = int.tryParse(preWeaningCtrl.text.trim()) ?? 0;
                    final weight = _tryParseAmount(weightCtrl.text.trim());
                    final responsible = responsibleCtrl.text.trim();

                    if (date == null ||
                        total == null ||
                        alive == null ||
                        weaned == null ||
                        weight == null ||
                        responsible.isEmpty) {
                      _showError(
                        'Veuillez renseigner date valide, effectifs, poids et responsable.',
                      );
                      return;
                    }
                    if (total < 0 ||
                        alive < 0 ||
                        still < 0 ||
                        mum < 0 ||
                        weaned < 0 ||
                        pre < 0) {
                      _showError('Les effectifs doivent être positifs.');
                      return;
                    }
                    if (alive + still + mum > total) {
                      _showError(
                        'Incohérence: vivants + mort-nés + momifiés > nés total.',
                      );
                      return;
                    }
                    if (weaned > alive) {
                      _showError(
                        'Le nombre sevré ne peut pas dépasser les nés vivants.',
                      );
                      return;
                    }
                    if (pre > alive) {
                      _showError(
                        'La mortalité pré-sevrage ne peut pas dépasser les nés vivants.',
                      );
                      return;
                    }
                    if (weight <= 0) {
                      _showError('Le poids naissance moyen doit être > 0.');
                      return;
                    }

                    final updated = FarrowingRecord(
                      id: record.id,
                      sowCode: selectedSowCode,
                      farrowingDate: date,
                      totalBorn: total,
                      bornAlive: alive,
                      stillborn: still,
                      mummified: mum,
                      weaned: weaned,
                      preWeaningDeaths: pre,
                      avgBirthWeight: weight,
                      majorIssue: issueCtrl.text.trim(),
                      responsible: responsible,
                      notes: notesCtrl.text.trim(),
                    );
                    setState(() => _farrowingRecords[index] = updated);
                    _addAuditLog(
                      module: 'MATERNITE',
                      action: 'UPDATE_FARROWING',
                      detail: 'Mise-bas ${updated.sowCode} mise à jour',
                    );
                    _persistState();
                    Navigator.of(dialogContext).pop();
                    _showInfo('Mise-bas mise à jour.');
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => _disposeControllers([
        dateCtrl,
        totalCtrl,
        aliveCtrl,
        stillCtrl,
        mumCtrl,
        weanedCtrl,
        preWeaningCtrl,
        weightCtrl,
        issueCtrl,
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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
                      const SizedBox(height: AppSpacing.s12),
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

  void _showAddAnimalSaleListingDialog() {
    _showAnimalSaleListingDialog();
  }

  void _showEditAnimalSaleListingDialog(AnimalSaleListing listing) {
    if (!_canManageAnimalSaleListing(listing)) {
      _showError('Vous ne pouvez pas modifier cette annonce.');
      return;
    }
    _showAnimalSaleListingDialog(existing: listing);
  }

  void _showAnimalSaleListingDialog({AnimalSaleListing? existing}) {
    final codeCtrl = TextEditingController(text: existing?.animalCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.animalName ?? '');
    final breedCtrl = TextEditingController(text: existing?.breed ?? '');
    final quantityCtrl = TextEditingController(
      text: existing == null ? '1' : '${existing.quantity}',
    );
    final unitPriceCtrl = TextEditingController(
      text: existing == null ? '' : existing.unitPrice.toStringAsFixed(0),
    );
    final weightCtrl = TextEditingController(
      text: existing == null
          ? ''
          : (existing.weightKg <= 0
                ? ''
                : existing.weightKg.toStringAsFixed(1)),
    );
    final sellerCtrl = TextEditingController(
      text: existing?.sellerName ?? _currentUser.name,
    );
    final contactCtrl = TextEditingController(
      text: existing?.contact.isNotEmpty == true
          ? existing!.contact
          : _currentUser.contact,
    );
    final territory = _territoryLabel(_currentUser);
    final locationCtrl = TextEditingController(
      text: existing?.location.isNotEmpty == true
          ? existing!.location
          : (territory == '-' ? '' : territory),
    );
    final descriptionCtrl = TextEditingController(
      text: existing?.description ?? '',
    );

    String selectedCategory = existing?.category ?? 'Porcelets';
    String selectedStatus = existing?.status ?? 'Disponible';
    bool isPublished = existing?.isPublished ?? true;
    String selectedImageBase64 = existing?.imageBase64 ?? '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? 'Publier un animal à vendre'
                    : 'Modifier annonce de vente',
              ),
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
                            value: 'Verrat',
                            child: Text('Verrat'),
                          ),
                          DropdownMenuItem(
                            value: 'Truie',
                            child: Text('Truie'),
                          ),
                          DropdownMenuItem(
                            value: 'Porcelets',
                            child: Text('Porcelets'),
                          ),
                          DropdownMenuItem(
                            value: 'Porc charcutier',
                            child: Text('Porc charcutier'),
                          ),
                          DropdownMenuItem(
                            value: 'Lot mixte',
                            child: Text('Lot mixte'),
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        codeCtrl,
                        'Code animal / lot *',
                        hint: 'VR-1001 ou LOT-PORC-01',
                      ),
                      _dialogField(nameCtrl, 'Nom animal / lot *'),
                      _dialogField(
                        breedCtrl,
                        'Race',
                        hint: 'Large White / Croisé / ...',
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(selectedImageBase64, size: 88),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final image = await _pickImageAsBase64();
                                    if (image == null) {
                                      return;
                                    }
                                    setModalState(
                                      () => selectedImageBase64 = image,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Ajouter image'),
                                ),
                                if (selectedImageBase64.trim().isNotEmpty)
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        quantityCtrl,
                        'Quantité *',
                        keyboardType: TextInputType.number,
                      ),
                      _dialogField(
                        unitPriceCtrl,
                        'Prix unitaire (Ar) *',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(
                        weightCtrl,
                        'Poids moyen (kg)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _dialogField(sellerCtrl, 'Nom vendeur *'),
                      _dialogField(contactCtrl, 'Contact vendeur'),
                      _dialogField(locationCtrl, 'Localisation'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut commercial',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Disponible',
                            child: Text('Disponible'),
                          ),
                          DropdownMenuItem(
                            value: 'Réservé',
                            child: Text('Réservé'),
                          ),
                          DropdownMenuItem(
                            value: 'Vendu',
                            child: Text('Vendu'),
                          ),
                          DropdownMenuItem(
                            value: 'Retiré',
                            child: Text('Retiré'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Annonce publiée'),
                        subtitle: Text(
                          isPublished
                              ? 'Visible dans le marché de vente'
                              : 'Mode brouillon (non visible)',
                        ),
                        value: isPublished,
                        onChanged: (value) {
                          setModalState(() => isPublished = value);
                        },
                      ),
                      _dialogField(descriptionCtrl, 'Description', maxLines: 3),
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
                    final quantity = int.tryParse(quantityCtrl.text.trim());
                    final unitPrice = _tryParseAmount(
                      unitPriceCtrl.text.trim(),
                    );
                    final weightKg = weightCtrl.text.trim().isEmpty
                        ? 0.0
                        : (_tryParseAmount(weightCtrl.text.trim()) ?? -1);
                    final sellerName = sellerCtrl.text.trim();

                    if (code.isEmpty ||
                        name.isEmpty ||
                        quantity == null ||
                        quantity <= 0 ||
                        unitPrice == null ||
                        unitPrice <= 0 ||
                        sellerName.isEmpty) {
                      _showError(
                        'Code, nom, quantité > 0, prix > 0 et vendeur sont requis.',
                      );
                      return;
                    }
                    if (weightKg < 0) {
                      _showError('Poids moyen invalide.');
                      return;
                    }

                    final persistedImage = selectedImageBase64.trim().isEmpty
                        ? _resolveAnimalSaleImageBase64(
                            AnimalSaleListing(
                              id: 'TMP',
                              category: selectedCategory,
                              animalCode: code,
                              animalName: name,
                              breed: breedCtrl.text.trim(),
                              quantity: quantity,
                              unitPrice: unitPrice,
                              weightKg: weightKg,
                              publishedDate: _currentDate(),
                              sellerId: existing?.sellerId.isNotEmpty == true
                                  ? existing!.sellerId
                                  : _currentUser.id,
                              sellerName: sellerName,
                              contact: contactCtrl.text.trim(),
                              location: locationCtrl.text.trim(),
                              status: selectedStatus,
                              isPublished: isPublished,
                              description: descriptionCtrl.text.trim(),
                              imageBase64: '',
                            ),
                          )
                        : selectedImageBase64.trim();

                    final now = _currentDate();
                    final listing = AnimalSaleListing(
                      id: existing?.id ?? _newId('ASL'),
                      category: selectedCategory,
                      animalCode: code,
                      animalName: name,
                      breed: breedCtrl.text.trim(),
                      quantity: quantity,
                      unitPrice: unitPrice,
                      weightKg: weightKg,
                      publishedDate: existing == null
                          ? now
                          : (!existing.isPublished && isPublished
                                ? now
                                : existing.publishedDate),
                      sellerId: existing?.sellerId.isNotEmpty == true
                          ? existing!.sellerId
                          : _currentUser.id,
                      sellerName: sellerName,
                      contact: contactCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                      status: selectedStatus,
                      isPublished: isPublished,
                      description: descriptionCtrl.text.trim(),
                      imageBase64: persistedImage,
                    );

                    if (existing == null) {
                      setState(() => _animalSaleListings.insert(0, listing));
                      _addAuditLog(
                        module: 'COMMERCIAL',
                        action: 'CREATE_ANIMAL_LISTING',
                        detail:
                            'Annonce ${listing.category} ${listing.animalCode} créée',
                      );
                      _showInfo('Annonce publiée.');
                    } else {
                      final index = _animalSaleListings.indexWhere(
                        (item) => item.id == existing.id,
                      );
                      if (index < 0) {
                        _showError('Annonce introuvable.');
                        return;
                      }
                      setState(() => _animalSaleListings[index] = listing);
                      _addAuditLog(
                        module: 'COMMERCIAL',
                        action: 'UPDATE_ANIMAL_LISTING',
                        detail:
                            'Annonce ${listing.category} ${listing.animalCode} mise à jour',
                      );
                      _showInfo('Annonce mise à jour.');
                    }

                    _persistState();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(existing == null ? 'Publier' : 'Mettre à jour'),
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
        quantityCtrl,
        unitPriceCtrl,
        weightCtrl,
        sellerCtrl,
        contactCtrl,
        locationCtrl,
        descriptionCtrl,
      ]),
    );
  }

  void _showAddUserDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final fokontanyCtrl = TextEditingController();
    final communeCtrl = TextEditingController();
    final districtCtrl = TextEditingController();
    final regionCtrl = TextEditingController();
    final loginCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = Roles.breeder;
    String profileImageBase64 = '';
    String coverImageBase64 = '';
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
                      _buildCoverPreviewBox(coverImageBase64, height: 96),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final image = await _pickImageAsBase64();
                              if (image == null) {
                                return;
                              }
                              setModalState(() => coverImageBase64 = image);
                            },
                            icon: const Icon(Icons.image_outlined, size: 16),
                            label: const Text('Couverture'),
                          ),
                          if (coverImageBase64.trim().isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() => coverImageBase64 = '');
                              },
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Retirer'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(profileImageBase64, size: 84),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final image = await _pickImageAsBase64();
                                    if (image == null) {
                                      return;
                                    }
                                    setModalState(
                                      () => profileImageBase64 = image,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.account_circle_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Photo profil'),
                                ),
                                if (profileImageBase64.trim().isNotEmpty)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setModalState(
                                        () => profileImageBase64 = '',
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        codeCtrl,
                        'Code utilisateur *',
                        hint: 'USR-01',
                      ),
                      _dialogField(nameCtrl, 'Nom complet *'),
                      _dialogField(bioCtrl, 'Bio', maxLines: 3),
                      _dialogField(addressCtrl, 'Adresse *'),
                      _dialogField(contactCtrl, 'Contact *'),
                      _dialogField(fokontanyCtrl, 'Fokontany *'),
                      _dialogField(communeCtrl, 'Commune *'),
                      _dialogField(districtCtrl, 'District *'),
                      _dialogField(regionCtrl, 'Région *'),
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
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(
                        loginCtrl,
                        'Login *',
                        hint: 'identifiant de connexion',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
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
                    final address = addressCtrl.text.trim();
                    final contact = contactCtrl.text.trim();
                    final fokontany = fokontanyCtrl.text.trim();
                    final commune = communeCtrl.text.trim();
                    final district = districtCtrl.text.trim();
                    final region = regionCtrl.text.trim();
                    final login = loginCtrl.text.trim().toLowerCase();
                    final password = passwordCtrl.text;

                    if (code.isEmpty ||
                        name.isEmpty ||
                        address.isEmpty ||
                        contact.isEmpty ||
                        fokontany.isEmpty ||
                        commune.isEmpty ||
                        district.isEmpty ||
                        region.isEmpty ||
                        login.isEmpty ||
                        password.isEmpty) {
                      _showError(
                        'Veuillez remplir code, nom, adresse, contact, fokontany, commune, district, région, rôle, login et mot de passe.',
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
                      address: address,
                      contact: contact,
                      fokontany: fokontany,
                      commune: commune,
                      district: district,
                      region: region,
                      bio: bioCtrl.text.trim(),
                      profileImageBase64: profileImageBase64,
                      coverImageBase64: coverImageBase64,
                      login: login,
                      password: _hashPassword(password),
                    );

                    setState(() => _users.insert(0, user));
                    _addAuditLog(
                      module: 'USERS',
                      action: 'CREATE_USER',
                      detail:
                          'Création utilisateur ${user.code} (${user.role})',
                    );
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
      (_) => _disposeControllers([
        codeCtrl,
        nameCtrl,
        bioCtrl,
        addressCtrl,
        contactCtrl,
        fokontanyCtrl,
        communeCtrl,
        districtCtrl,
        regionCtrl,
        loginCtrl,
        passwordCtrl,
      ]),
    );
  }

  void _showEditUserDialog(UserProfile user) {
    final codeCtrl = TextEditingController(text: user.code);
    final nameCtrl = TextEditingController(text: user.name);
    final bioCtrl = TextEditingController(text: user.bio);
    final addressCtrl = TextEditingController(text: user.address);
    final contactCtrl = TextEditingController(text: user.contact);
    final fokontanyCtrl = TextEditingController(text: user.fokontany);
    final communeCtrl = TextEditingController(text: user.commune);
    final districtCtrl = TextEditingController(text: user.district);
    final regionCtrl = TextEditingController(text: user.region);
    final loginCtrl = TextEditingController(text: user.login);
    String selectedRole = user.role;
    String profileImageBase64 = user.profileImageBase64;
    String coverImageBase64 = user.coverImageBase64;

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
                      _buildCoverPreviewBox(coverImageBase64, height: 96),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final image = await _pickImageAsBase64();
                              if (image == null) {
                                return;
                              }
                              setModalState(() => coverImageBase64 = image);
                            },
                            icon: const Icon(Icons.image_outlined, size: 16),
                            label: const Text('Couverture'),
                          ),
                          if (coverImageBase64.trim().isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() => coverImageBase64 = '');
                              },
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Retirer'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewBox(profileImageBase64, size: 84),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final image = await _pickImageAsBase64();
                                    if (image == null) {
                                      return;
                                    }
                                    setModalState(
                                      () => profileImageBase64 = image,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.account_circle_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Photo profil'),
                                ),
                                if (profileImageBase64.trim().isNotEmpty)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setModalState(
                                        () => profileImageBase64 = '',
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _dialogField(codeCtrl, 'Code utilisateur *'),
                      _dialogField(nameCtrl, 'Nom complet *'),
                      _dialogField(bioCtrl, 'Bio', maxLines: 3),
                      _dialogField(addressCtrl, 'Adresse *'),
                      _dialogField(contactCtrl, 'Contact *'),
                      _dialogField(fokontanyCtrl, 'Fokontany *'),
                      _dialogField(communeCtrl, 'Commune *'),
                      _dialogField(districtCtrl, 'District *'),
                      _dialogField(regionCtrl, 'Région *'),
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
                      const SizedBox(height: AppSpacing.s12),
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
                    final address = addressCtrl.text.trim();
                    final contact = contactCtrl.text.trim();
                    final fokontany = fokontanyCtrl.text.trim();
                    final commune = communeCtrl.text.trim();
                    final district = districtCtrl.text.trim();
                    final region = regionCtrl.text.trim();
                    final login = loginCtrl.text.trim().toLowerCase();

                    if (code.isEmpty ||
                        name.isEmpty ||
                        address.isEmpty ||
                        contact.isEmpty ||
                        fokontany.isEmpty ||
                        commune.isEmpty ||
                        district.isEmpty ||
                        region.isEmpty ||
                        login.isEmpty) {
                      _showError(
                        'Code, nom, adresse, contact, fokontany, commune, district, région et login sont obligatoires.',
                      );
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
                      address: address,
                      contact: contact,
                      fokontany: fokontany,
                      commune: commune,
                      district: district,
                      region: region,
                      bio: bioCtrl.text.trim(),
                      profileImageBase64: profileImageBase64,
                      coverImageBase64: coverImageBase64,
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
                    _addAuditLog(
                      module: 'USERS',
                      action: 'UPDATE_USER',
                      detail: 'Utilisateur ${updated.code} mis à jour',
                    );
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
    ).then(
      (_) => _disposeControllers([
        codeCtrl,
        nameCtrl,
        bioCtrl,
        addressCtrl,
        contactCtrl,
        fokontanyCtrl,
        communeCtrl,
        districtCtrl,
        regionCtrl,
        loginCtrl,
      ]),
    );
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
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
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
                      address: user.address,
                      contact: user.contact,
                      fokontany: user.fokontany,
                      commune: user.commune,
                      district: user.district,
                      region: user.region,
                      bio: user.bio,
                      profileImageBase64: user.profileImageBase64,
                      coverImageBase64: user.coverImageBase64,
                      login: user.login,
                      password: _hashPassword(password),
                    );

                    setState(() {
                      _users[index] = updated;
                      if (_currentUser.id == updated.id) {
                        _currentUser = updated;
                      }
                    });
                    _addAuditLog(
                      module: 'USERS',
                      action: 'CHANGE_PASSWORD',
                      detail: 'Mot de passe modifié pour ${user.code}',
                      severity: 'WARN',
                    );
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
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
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
        const SizedBox(width: AppSpacing.s10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
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
                    const SizedBox(height: AppSpacing.s4),
                    Container(
                      height: math.max(8, 120 * (amounts[i] / adjustedMax)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s8,
      ),
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

  List<AnimalSaleListing> _animalSaleListingsForElevage() {
    final onlyOwnListings = _currentUser.role == Roles.breeder;
    final listings = _animalSaleListings.where((listing) {
      if (!onlyOwnListings) {
        return true;
      }
      return _isAnimalSaleOwnedByCurrentUser(listing);
    }).toList();
    listings.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return listings;
  }

  List<AnimalSaleListing> _animalSaleListingsForCommercial() {
    final listings = List<AnimalSaleListing>.from(_animalSaleListings);
    listings.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return listings;
  }

  List<DataRow> _buildAnimalSaleListingRows(List<AnimalSaleListing> listings) {
    return listings
        .map(
          (listing) => DataRow(
            cells: [
              DataCell(_buildAnimalSaleListingPhoto(listing, size: 44)),
              DataCell(Text(_formatDate(listing.publishedDate))),
              DataCell(Text(listing.category)),
              DataCell(Text(listing.animalCode)),
              DataCell(Text(listing.animalName)),
              DataCell(Text(listing.breed.isEmpty ? '-' : listing.breed)),
              DataCell(Text('${listing.quantity}')),
              DataCell(Text(_formatAmount(listing.unitPrice))),
              DataCell(Text(listing.sellerName)),
              DataCell(Text(listing.contact.isEmpty ? '-' : listing.contact)),
              DataCell(Text(listing.location.isEmpty ? '-' : listing.location)),
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.status,
                      style: TextStyle(
                        color: _animalSaleStatusColor(listing.status),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      listing.isPublished ? 'Publié' : 'Brouillon',
                      style: TextStyle(
                        color: listing.isPublished
                            ? const Color(0xFF15803D)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                _canManageAnimalSaleListing(listing)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: listing.isPublished
                                ? 'Retirer de la vente'
                                : 'Publier',
                            onPressed: () =>
                                _toggleAnimalSalePublication(listing.id),
                            icon: Icon(
                              listing.isPublished
                                  ? Icons.visibility_off_outlined
                                  : Icons.public_outlined,
                              color: listing.isPublished
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF15803D),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Modifier annonce',
                            onPressed: () =>
                                _showEditAnimalSaleListingDialog(listing),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Supprimer annonce',
                            onPressed: () =>
                                _deleteAnimalSaleListing(listing.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      )
                    : const Text('-'),
              ),
            ],
          ),
        )
        .toList();
  }

  Widget _buildAnimalSaleListingPhoto(
    AnimalSaleListing listing, {
    double size = 52,
  }) {
    return _buildImagePreviewBox(
      _resolveAnimalSaleImageBase64(listing),
      size: size,
    );
  }

  String _resolveAnimalSaleImageBase64(AnimalSaleListing listing) {
    if (listing.imageBase64.trim().isNotEmpty) {
      return listing.imageBase64.trim();
    }
    final code = listing.animalCode.trim();
    if (code.isEmpty) {
      return '';
    }
    final boar = _findBoar(code);
    if (boar != null && boar.imageBase64.trim().isNotEmpty) {
      return boar.imageBase64.trim();
    }
    final sow = _findSow(code);
    if (sow != null && sow.imageBase64.trim().isNotEmpty) {
      return sow.imageBase64.trim();
    }
    return '';
  }

  bool _isAnimalSaleOwnedByCurrentUser(AnimalSaleListing listing) {
    final currentId = _currentUser.id.trim().toLowerCase();
    final sellerId = listing.sellerId.trim().toLowerCase();
    if (sellerId.isNotEmpty && sellerId == currentId) {
      return true;
    }
    return listing.sellerName.trim().toLowerCase() ==
        _currentUser.name.trim().toLowerCase();
  }

  bool _canManageAnimalSaleListing(AnimalSaleListing listing) {
    if (_currentUser.role == Roles.admin ||
        _currentUser.role == Roles.inseminator) {
      return true;
    }
    if (_currentUser.role == Roles.breeder) {
      return _isAnimalSaleOwnedByCurrentUser(listing);
    }
    return false;
  }

  Color _animalSaleStatusColor(String status) {
    final normalized = _normalizeLookup(status);
    if (normalized.contains('vendu')) {
      return const Color(0xFF475569);
    }
    if (normalized.contains('reserve')) {
      return const Color(0xFFB45309);
    }
    if (normalized.contains('disponible')) {
      return const Color(0xFF15803D);
    }
    return const Color(0xFF2563EB);
  }

  void _attemptLogin() {
    final login = _loginController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (_loginLockedUntil != null &&
        DateTime.now().isBefore(_loginLockedUntil!)) {
      final remainingMinutes = _loginLockedUntil!
          .difference(DateTime.now())
          .inMinutes
          .clamp(1, 999);
      setState(
        () => _authError =
            'Compte temporairement verrouillé. Réessayez dans $remainingMinutes minute(s).',
      );
      return;
    }

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

    if (matchedUser == null || !_verifyPassword(matchedUser, password)) {
      _failedLoginAttempts++;
      if (_failedLoginAttempts >= 5) {
        _loginLockedUntil = DateTime.now().add(const Duration(minutes: 5));
        _failedLoginAttempts = 0;
      }
      _addAuditLog(
        module: 'AUTH',
        action: 'LOGIN_FAIL',
        detail: 'Tentative échouée pour login=$login',
        severity: 'WARN',
      );
      setState(() => _authError = 'Login ou mot de passe invalide.');
      _persistState();
      return;
    }

    setState(() {
      _currentUser = matchedUser!;
      _isAuthenticated = true;
      _authError = null;
      _activeTab = _defaultTabForCurrentUser();
      _failedLoginAttempts = 0;
      _loginLockedUntil = null;
      _lastAuthAt = DateTime.now();
    });
    _syncIncomingCallOffer();
    _addAuditLog(
      module: 'AUTH',
      action: 'LOGIN_SUCCESS',
      detail: 'Connexion réussie pour ${_currentUser.code}',
    );
    _persistState();
    _loginController.clear();
    _passwordController.clear();
    _showInfo('Connexion réussie: ${_currentUser.name}');
  }

  void _logout() {
    _addAuditLog(
      module: 'AUTH',
      action: 'LOGOUT',
      detail: 'Déconnexion utilisateur ${_currentUser.code}',
    );
    setState(() {
      _isAuthenticated = false;
      _authError = null;
      _activeTab = AppTabs.dashboard;
      _hidePassword = true;
      _lastAuthAt = null;
      _incomingCallOffer = null;
    });
    _stopIncomingCallRingtone();
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

  Future<void> _deleteBuilding(String buildingId) async {
    final index = _buildings.indexWhere(
      (building) => building.id == buildingId,
    );
    if (index < 0) {
      return;
    }
    final building = _buildings[index];

    if (_buildings.length <= 1) {
      _showError(
        'Impossible de supprimer le dernier bâtiment. Gardez au moins une structure.',
      );
      return;
    }

    if (building.occupied > 0) {
      _showError(
        'Impossible de supprimer ${building.name}: ${building.occupied} animal(aux) sont encore affectés.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer le bâtiment ${building.name} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'ELEVAGE',
      action: 'DELETE_BUILDING',
      detail: 'Bâtiment ${building.name} supprimé',
      severity: 'WARN',
    );
    setState(() => _buildings.removeAt(index));
    _persistState();
    _showInfo('Bâtiment ${building.name} supprimé.');
  }

  Future<void> _deleteBatch(String batchId) async {
    final index = _batchRecords.indexWhere((batch) => batch.id == batchId);
    if (index < 0) {
      return;
    }
    final batch = _batchRecords[index];

    final usedInGrowth = _growthRecords.any(
      (growth) => growth.batchId == batch.id,
    );
    if (usedInGrowth) {
      _showError(
        'Impossible de supprimer ${batch.name}: des suivis de croissance sont liés à cette bande.',
      );
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer la bande ${batch.name} ?',
      message: 'Cette suppression est définitive.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'ELEVAGE',
      action: 'DELETE_BATCH',
      detail: 'Bande ${batch.name} supprimée',
      severity: 'WARN',
    );
    setState(() => _batchRecords.removeAt(index));
    _persistState();
    _showInfo('Bande ${batch.name} supprimée.');
  }

  Future<void> _deleteGrowthRecord(String growthId) async {
    final index = _growthRecords.indexWhere((growth) => growth.id == growthId);
    if (index < 0) {
      return;
    }
    final growth = _growthRecords[index];
    final batchName = _batchNameForId(growth.batchId);

    final confirmed = await _confirmDeletion(
      title: 'Supprimer ce suivi croissance ?',
      message:
          '$batchName du ${_formatDate(growth.date)} (${growth.avgWeight.toStringAsFixed(1)} kg).',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'ELEVAGE',
      action: 'DELETE_GROWTH',
      detail: 'Suivi croissance supprimé ($batchName)',
      severity: 'WARN',
    );
    setState(() => _growthRecords.removeAt(index));
    _persistState();
    _showInfo('Suivi croissance supprimé.');
  }

  Future<void> _deletePigletCareRecord(String recordId) async {
    final index = _pigletCareRecords.indexWhere(
      (record) => record.id == recordId,
    );
    if (index < 0) {
      return;
    }
    final record = _pigletCareRecords[index];

    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette prise en charge ?',
      message:
          '${record.groupName} / ${record.eventType} du ${_formatDate(record.eventDate)}.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'PORCELETS',
      action: 'DELETE_PIGLET_CARE',
      detail: '${record.groupName} / ${record.eventType}',
      severity: 'WARN',
    );
    setState(() => _pigletCareRecords.removeAt(index));
    _persistState();
    _showInfo('Prise en charge porcelets supprimée.');
  }

  Future<void> _deleteSemenQualityRecord(String recordId) async {
    final index = _semenQualityRecords.indexWhere(
      (record) => record.id == recordId,
    );
    if (index < 0) {
      return;
    }
    final record = _semenQualityRecords[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer ce contrôle semence ?',
      message:
          '${record.lotCode} / ${record.boarCode} (${_formatDate(record.collectionDate)}).',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'SEMENCE',
      action: 'DELETE_SEMEN_QUALITY',
      detail: 'Lot ${record.lotCode} supprimé',
      severity: 'WARN',
    );
    setState(() => _semenQualityRecords.removeAt(index));
    _persistState();
    _showInfo('Contrôle semence supprimé.');
  }

  Future<void> _deleteFarrowingRecord(String recordId) async {
    final index = _farrowingRecords.indexWhere(
      (record) => record.id == recordId,
    );
    if (index < 0) {
      return;
    }
    final record = _farrowingRecords[index];
    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette mise-bas ?',
      message:
          '${record.sowCode} du ${_formatDate(record.farrowingDate)} (nés vivants: ${record.bornAlive}).',
    );
    if (!confirmed || !mounted) {
      return;
    }
    _addAuditLog(
      module: 'MATERNITE',
      action: 'DELETE_FARROWING',
      detail: '${record.sowCode} / ${_formatDate(record.farrowingDate)}',
      severity: 'WARN',
    );
    setState(() => _farrowingRecords.removeAt(index));
    _persistState();
    _showInfo('Mise-bas supprimée.');
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

  Future<void> _toggleAnimalSalePublication(String listingId) async {
    final index = _animalSaleListings.indexWhere(
      (listing) => listing.id == listingId,
    );
    if (index < 0) {
      return;
    }
    final listing = _animalSaleListings[index];
    if (!_canManageAnimalSaleListing(listing)) {
      _showError('Vous ne pouvez pas modifier cette annonce.');
      return;
    }

    final nextPublished = !listing.isPublished;
    final updated = AnimalSaleListing(
      id: listing.id,
      category: listing.category,
      animalCode: listing.animalCode,
      animalName: listing.animalName,
      breed: listing.breed,
      quantity: listing.quantity,
      unitPrice: listing.unitPrice,
      weightKg: listing.weightKg,
      publishedDate: nextPublished ? _currentDate() : listing.publishedDate,
      sellerId: listing.sellerId,
      sellerName: listing.sellerName,
      contact: listing.contact,
      location: listing.location,
      status: listing.status,
      isPublished: nextPublished,
      description: listing.description,
      imageBase64: listing.imageBase64,
    );

    setState(() => _animalSaleListings[index] = updated);
    _addAuditLog(
      module: 'COMMERCIAL',
      action: nextPublished
          ? 'PUBLISH_ANIMAL_LISTING'
          : 'UNPUBLISH_ANIMAL_LISTING',
      detail:
          '${updated.category} ${updated.animalCode} (${nextPublished ? 'publiée' : 'retirée'})',
    );
    _persistState();
    _showInfo(
      nextPublished
          ? 'Annonce publiée sur le marché.'
          : 'Annonce retirée du marché.',
    );
  }

  Future<void> _deleteAnimalSaleListing(String listingId) async {
    final index = _animalSaleListings.indexWhere(
      (listing) => listing.id == listingId,
    );
    if (index < 0) {
      return;
    }
    final listing = _animalSaleListings[index];
    if (!_canManageAnimalSaleListing(listing)) {
      _showError('Vous ne pouvez pas supprimer cette annonce.');
      return;
    }

    final confirmed = await _confirmDeletion(
      title: 'Supprimer cette annonce ?',
      message:
          '${listing.category} ${listing.animalCode} - ${listing.animalName}.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _animalSaleListings.removeAt(index));
    _addAuditLog(
      module: 'COMMERCIAL',
      action: 'DELETE_ANIMAL_LISTING',
      detail: '${listing.category} ${listing.animalCode} supprimée',
      severity: 'WARN',
    );
    _persistState();
    _showInfo('Annonce supprimée.');
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
    _addAuditLog(
      module: 'USERS',
      action: 'DELETE_USER',
      detail: 'Suppression utilisateur ${user.code} (${user.role})',
      severity: 'WARN',
    );
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

  bool _isHashedPassword(String value) {
    return value.startsWith(_passwordHashPrefix) &&
        value.length > _passwordHashPrefix.length + 16;
  }

  String _hashPassword(String password) {
    final hash = sha256.convert(utf8.encode(password)).toString();
    return '$_passwordHashPrefix$hash';
  }

  bool _verifyPassword(UserProfile user, String password) {
    final stored = user.password;
    if (_isHashedPassword(stored)) {
      return stored == _hashPassword(password);
    }
    return stored == password;
  }

  bool _migrateLegacyPasswords() {
    var changed = false;
    for (var i = 0; i < _users.length; i++) {
      final user = _users[i];
      if (_isHashedPassword(user.password)) {
        continue;
      }
      _users[i] = UserProfile(
        id: user.id,
        code: user.code,
        name: user.name,
        role: user.role,
        avatar: user.avatar,
        address: user.address,
        contact: user.contact,
        fokontany: user.fokontany,
        commune: user.commune,
        district: user.district,
        region: user.region,
        bio: user.bio,
        profileImageBase64: user.profileImageBase64,
        coverImageBase64: user.coverImageBase64,
        login: user.login,
        password: _hashPassword(user.password),
      );
      changed = true;
    }
    if (changed) {
      _currentUser = _findUserById(_currentUser.id) ?? _currentUser;
    }
    return changed;
  }

  void _addAuditLog({
    required String module,
    required String action,
    required String detail,
    String severity = 'INFO',
    UserProfile? actor,
  }) {
    final user = actor ?? _currentUser;
    final entry = AuditLogEntry(
      id: _newId('LOG'),
      timestamp: DateTime.now(),
      actorCode: user.code,
      actorName: user.name,
      module: module,
      action: action,
      detail: detail,
      severity: severity,
    );
    setState(() {
      _auditLogs.insert(0, entry);
      if (_auditLogs.length > 500) {
        _auditLogs.removeRange(500, _auditLogs.length);
      }
    });
  }

  String _authStateLabel(UserProfile user) {
    return _isHashedPassword(user.password) ? 'Hashé' : 'À migrer';
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

  Sow? _findSow(String code) {
    for (final sow in _sows) {
      if (sow.code.toLowerCase() == code.toLowerCase()) {
        return sow;
      }
    }
    return null;
  }

  String? _consanguinityIssue(String sowCode, String boarCode) {
    final sow = _findSow(sowCode);
    final boar = _findBoar(boarCode);
    if (sow == null || boar == null) {
      return null;
    }

    final boarCodeNormalized = _normalizeLookup(boar.code);
    final sowCodeNormalized = _normalizeLookup(sow.code);
    final sowSire = _normalizeLookup(sow.sireCode);
    final sowDam = _normalizeLookup(sow.damCode);
    final boarSire = _normalizeLookup(boar.sireCode);
    final boarDam = _normalizeLookup(boar.damCode);

    if (boarCodeNormalized == sowSire && sowSire.isNotEmpty) {
      return 'le verrat sélectionné est le père direct de la truie';
    }
    if (boarCodeNormalized == sowDam && sowDam.isNotEmpty) {
      return 'le verrat sélectionné est lié à la mère de la truie';
    }
    if (boarSire == sowSire && boarSire.isNotEmpty) {
      return 'la truie et le verrat partagent le même père (${sow.sireCode})';
    }
    if (boarDam == sowDam && boarDam.isNotEmpty) {
      return 'la truie et le verrat partagent la même mère (${sow.damCode})';
    }
    if (boarSire == sowCodeNormalized && boarSire.isNotEmpty) {
      return 'la truie est ascendant direct du verrat (père du verrat)';
    }
    if (boarDam == sowCodeNormalized && boarDam.isNotEmpty) {
      return 'la truie est ascendant direct du verrat (mère du verrat)';
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

  String _directConversationId(String userIdA, String userIdB) {
    final ids = [userIdA.trim(), userIdB.trim()]..sort();
    return 'DM|${ids[0]}|${ids[1]}';
  }

  String _callSessionIdForMessage(ChatMessage message) {
    final sessionId = message.callSessionId.trim();
    if (sessionId.isNotEmpty) {
      return sessionId;
    }
    return message.id;
  }

  bool _isCallRingingStatus(String status) {
    final normalized = _normalizeLookup(status);
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.contains('sonnerie') || normalized.contains('ringing');
  }

  ChatMessage? _findLatestIncomingCallInvitation() {
    final sorted = List<ChatMessage>.from(_chatMessages)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    final closedSessions = <String>{};
    for (final message in sorted) {
      if (_normalizeLookup(message.messageType) != 'call') {
        continue;
      }
      if (!_isConversationVisibleForCurrentUser(message.conversationId)) {
        continue;
      }
      final sessionId = _callSessionIdForMessage(message);
      if (closedSessions.contains(sessionId)) {
        continue;
      }
      if (!_isCallRingingStatus(message.callStatus)) {
        closedSessions.add(sessionId);
        continue;
      }
      if (DateTime.now().difference(message.sentAt).inMinutes >
          _incomingCallMaxAgeMinutes) {
        closedSessions.add(sessionId);
        continue;
      }
      if (message.senderId == _currentUser.id) {
        continue;
      }
      return message;
    }
    return null;
  }

  void _playIncomingCallTone() {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Keep ringing workflow even if sound API is unavailable.
    }
  }

  void _startIncomingCallRingtone() {
    if (_incomingCallOffer == null || !_isAuthenticated) {
      return;
    }
    if (_incomingCallRingtoneTimer != null) {
      return;
    }
    _playIncomingCallTone();
    _incomingCallRingtoneTimer = Timer.periodic(const Duration(seconds: 2), (
      _,
    ) {
      if (!mounted || !_isAuthenticated || _incomingCallOffer == null) {
        _stopIncomingCallRingtone();
        return;
      }
      _playIncomingCallTone();
    });
  }

  void _stopIncomingCallRingtone() {
    _incomingCallRingtoneTimer?.cancel();
    _incomingCallRingtoneTimer = null;
  }

  void _syncIncomingCallOffer() {
    if (!mounted || !_isAuthenticated) {
      if (_incomingCallOffer != null) {
        setState(() => _incomingCallOffer = null);
      }
      _stopIncomingCallRingtone();
      return;
    }

    final incoming = _findLatestIncomingCallInvitation();
    if (incoming == null) {
      if (_incomingCallOffer != null) {
        setState(() => _incomingCallOffer = null);
      }
      _stopIncomingCallRingtone();
      return;
    }

    final sessionId = _callSessionIdForMessage(incoming);
    if (_incomingCallOffer?.sessionId == sessionId) {
      _startIncomingCallRingtone();
      return;
    }

    setState(() {
      _incomingCallOffer = _IncomingCallOffer(
        sessionId: sessionId,
        conversationId: incoming.conversationId,
        callerId: incoming.senderId,
        callerName: incoming.senderName,
        callType: incoming.callType.trim().toLowerCase() == 'video'
            ? 'video'
            : 'audio',
        sentAt: incoming.sentAt,
      );
    });
    _startIncomingCallRingtone();
    _showInfo(
      'Appel ${_incomingCallOffer!.callType == 'video' ? 'vidéo' : 'audio'} entrant: ${_incomingCallOffer!.callerName}',
    );
  }

  Future<void> _acceptIncomingCallOffer() async {
    final offer = _incomingCallOffer;
    if (offer == null) {
      return;
    }
    if (!_canCurrentUserPostToConversation(offer.conversationId)) {
      _showError(_teamConversationAccessError());
      return;
    }
    final callLabel = offer.callType == 'video' ? 'vidéo' : 'audio';
    _stopIncomingCallRingtone();
    setState(() {
      _incomingCallOffer = null;
      _activeChatConversationId = offer.conversationId;
      _activeTab = AppTabs.messenger;
    });

    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: offer.conversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: 'Appel $callLabel accepté',
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
        messageType: 'call',
        callType: offer.callType,
        callStatus: _callAcceptedStatus,
        callSessionId: offer.sessionId,
      ),
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'ACCEPT_CALL',
      detail: 'Appel $callLabel accepté (${offer.callerName})',
    );

    final durationSeconds = await _showActiveCallDialog(
      callType: offer.callType,
      title: offer.callerName,
      remoteUserId: offer.callerId,
      remoteUserName: offer.callerName,
    );
    if (!mounted) {
      return;
    }

    final callStatus = durationSeconds == null ? 'Manqué' : 'Terminé';
    final callText = durationSeconds == null
        ? 'Appel $callLabel manqué'
        : 'Appel $callLabel terminé (${_formatDuration(durationSeconds)})';
    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: offer.conversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: callText,
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
        messageType: 'call',
        callType: offer.callType,
        callStatus: callStatus,
        callDurationSeconds: durationSeconds ?? 0,
        callSessionId: offer.sessionId,
      ),
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: durationSeconds == null ? 'MISS_CALL' : 'END_CALL',
      detail: durationSeconds == null
          ? 'Appel $callLabel manqué (${offer.callerName})'
          : 'Appel $callLabel terminé (${offer.callerName}, ${_formatDuration(durationSeconds)})',
    );
    _persistState();
    _syncIncomingCallOffer();
  }

  void _rejectIncomingCallOffer() {
    final offer = _incomingCallOffer;
    if (offer == null) {
      return;
    }
    if (!_canCurrentUserPostToConversation(offer.conversationId)) {
      _showError(_teamConversationAccessError());
      return;
    }
    final callLabel = offer.callType == 'video' ? 'vidéo' : 'audio';
    _stopIncomingCallRingtone();
    setState(() => _incomingCallOffer = null);
    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: offer.conversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: 'Appel $callLabel refusé',
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
        messageType: 'call',
        callType: offer.callType,
        callStatus: _callRejectedStatus,
        callSessionId: offer.sessionId,
      ),
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'REJECT_CALL',
      detail: 'Appel $callLabel refusé (${offer.callerName})',
    );
    _persistState();
  }

  bool _isTeamConversationRoleAllowed(String role) {
    final normalized = _normalizeLookup(role);
    return normalized == _normalizeLookup(Roles.admin) ||
        normalized == _normalizeLookup(Roles.inseminator) ||
        normalized == _normalizeLookup(Roles.vet) ||
        normalized == 'administrateur' ||
        normalized == 'admin';
  }

  bool _isTeamConversationUserAllowed(UserProfile user) {
    return _isTeamConversationRoleAllowed(user.role);
  }

  bool _isTeamConversationUserIdAllowed(String userId) {
    final user = _findUserById(userId.trim());
    if (user == null) {
      return false;
    }
    return _isTeamConversationUserAllowed(user);
  }

  bool _canCurrentUserAccessTeamConversation() {
    return _isTeamConversationUserAllowed(_currentUser);
  }

  bool _isConversationVisibleForCurrentUser(String conversationId) {
    if (conversationId == _teamConversationId) {
      return _canCurrentUserAccessTeamConversation();
    }
    if (!conversationId.startsWith('DM|')) {
      return false;
    }
    final parts = conversationId.split('|');
    if (parts.length != 3) {
      return false;
    }
    return parts[1] == _currentUser.id || parts[2] == _currentUser.id;
  }

  int _teamConversationParticipantCount() {
    var total = 0;
    for (final user in _users) {
      if (_isTeamConversationUserAllowed(user)) {
        total++;
      }
    }
    return total;
  }

  bool _canCurrentUserPostToConversation(String conversationId) {
    if (conversationId != _teamConversationId) {
      return true;
    }
    return _canCurrentUserAccessTeamConversation();
  }

  String _teamConversationAccessError() {
    return 'Canal équipe réservé aux rôles Responsable/Administrateur, Inséminateur et Vétérinaire.';
  }

  bool _isMessageReadByUser(ChatMessage message, String userId) {
    return message.readByUserIds.contains(userId.trim());
  }

  int _unreadCountForConversation(String conversationId) {
    var unread = 0;
    for (final message in _messagesForConversation(conversationId)) {
      if (message.senderId == _currentUser.id) {
        continue;
      }
      if (_isMessageReadByUser(message, _currentUser.id)) {
        continue;
      }
      unread++;
    }
    return unread;
  }

  bool _markConversationAsReadInState(String conversationId) {
    var changed = false;
    for (var i = 0; i < _chatMessages.length; i++) {
      final message = _chatMessages[i];
      if (message.conversationId != conversationId ||
          (conversationId == _teamConversationId &&
              !_isTeamConversationUserIdAllowed(message.senderId)) ||
          message.senderId == _currentUser.id ||
          _isMessageReadByUser(message, _currentUser.id)) {
        continue;
      }
      _chatMessages[i] = message.copyWith(
        readByUserIds: [...message.readByUserIds, _currentUser.id],
      );
      changed = true;
    }
    return changed;
  }

  void _markConversationAsReadDeferred(String conversationId) {
    if (_chatReadSyncScheduled ||
        _unreadCountForConversation(conversationId) == 0) {
      return;
    }
    _chatReadSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _chatReadSyncScheduled = false;
        return;
      }
      var changed = false;
      setState(() {
        changed = _markConversationAsReadInState(conversationId);
        _chatReadSyncScheduled = false;
      });
      if (changed) {
        _persistState();
      }
    });
  }

  List<ChatMessage> _messagesForConversation(String conversationId) {
    final messages = _chatMessages.where((message) {
      if (message.conversationId != conversationId) {
        return false;
      }
      if (conversationId == _teamConversationId &&
          !_isTeamConversationUserIdAllowed(message.senderId)) {
        return false;
      }
      return true;
    }).toList();
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  String _resolveActiveConversationId(
    List<_ChatConversationSummary> conversations,
  ) {
    for (final conversation in conversations) {
      if (conversation.id == _activeChatConversationId) {
        return conversation.id;
      }
    }
    return conversations.first.id;
  }

  List<_ChatConversationSummary> _buildChatConversationSummaries() {
    final summaries = <_ChatConversationSummary>[];
    if (_canCurrentUserAccessTeamConversation()) {
      final groupMessages = _messagesForConversation(_teamConversationId);
      final groupLast = groupMessages.isEmpty ? null : groupMessages.last;
      summaries.add(
        _ChatConversationSummary(
          id: _teamConversationId,
          title: 'Canal Équipe',
          subtitle: '${_teamConversationParticipantCount()} utilisateur(s)',
          preview: groupLast == null
              ? 'Aucun message pour le moment.'
              : _clipText(_chatMessagePreview(groupLast), 64),
          lastMessageAt: groupLast?.sentAt,
          unreadCount: _unreadCountForConversation(_teamConversationId),
          avatarLabel: 'EQ',
          avatarColor: const Color(0xFF0F766E),
          isGroup: true,
        ),
      );
    }

    final peers = _users.where((user) => user.id != _currentUser.id).toList();
    for (final peer in peers) {
      final conversationId = _directConversationId(_currentUser.id, peer.id);
      final messages = _messagesForConversation(conversationId);
      final last = messages.isEmpty ? null : messages.last;
      summaries.add(
        _ChatConversationSummary(
          id: conversationId,
          title: peer.name,
          subtitle: '${peer.role} • ${peer.code}',
          preview: last == null
              ? 'Démarrer la conversation'
              : _clipText(_chatMessagePreview(last), 64),
          lastMessageAt: last?.sentAt,
          unreadCount: _unreadCountForConversation(conversationId),
          avatarLabel: peer.avatar,
          avatarColor: _roleColor(peer.role),
        ),
      );
    }

    summaries.sort((a, b) {
      if (a.isGroup && !b.isGroup) {
        return -1;
      }
      if (!a.isGroup && b.isGroup) {
        return 1;
      }
      final aTime = a.lastMessageAt;
      final bTime = b.lastMessageAt;
      if (aTime == null && bTime == null) {
        return a.title.compareTo(b.title);
      }
      if (aTime == null) {
        return 1;
      }
      if (bTime == null) {
        return -1;
      }
      return bTime.compareTo(aTime);
    });

    return summaries;
  }

  void _setActiveChatConversation(String conversationId) {
    final targetConversationId = conversationId.trim().isEmpty
        ? _teamConversationId
        : conversationId.trim();
    if (targetConversationId == _teamConversationId &&
        !_canCurrentUserAccessTeamConversation()) {
      _showError(_teamConversationAccessError());
      return;
    }
    setState(() {
      _activeChatConversationId = targetConversationId;
      _markConversationAsReadInState(_activeChatConversationId);
    });
    _persistState();
  }

  void _sendChatMessage(String conversationId) {
    final text = _chatComposerController.text.trim();
    if (text.isEmpty) {
      _showError('Écrivez un message avant d\'envoyer.');
      return;
    }

    final targetConversationId = _resolveChatConversationId(conversationId);
    if (!_canCurrentUserPostToConversation(targetConversationId)) {
      _showError(_teamConversationAccessError());
      return;
    }
    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: targetConversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: text,
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
      ),
      clearComposer: true,
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'SEND_MESSAGE',
      detail:
          'Message envoyé (${targetConversationId == _teamConversationId ? 'Canal équipe' : 'conversation directe'})',
    );
    _persistState();
  }

  String _resolveChatConversationId(String conversationId) {
    final normalized = conversationId.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    if (_canCurrentUserAccessTeamConversation()) {
      return _teamConversationId;
    }
    for (final user in _users) {
      if (user.id != _currentUser.id) {
        return _directConversationId(_currentUser.id, user.id);
      }
    }
    return _teamConversationId;
  }

  void _appendChatMessage(ChatMessage message, {bool clearComposer = false}) {
    setState(() {
      _chatMessages.add(message);
      if (_chatMessages.length > 2500) {
        _chatMessages.removeRange(0, _chatMessages.length - 2500);
      }
      _activeChatConversationId = message.conversationId;
      _markConversationAsReadInState(message.conversationId);
    });
    if (clearComposer) {
      _chatComposerController.clear();
    }
    _syncIncomingCallOffer();
    _persistState();
  }

  Future<void> _pickAndSendChatAttachment(
    String conversationId,
    String messageType,
  ) async {
    FileType pickerType = FileType.custom;
    List<String>? allowedExtensions;
    var maxBytes = _chatImageMaxBytes;
    var label = 'Pièce jointe';

    switch (messageType) {
      case 'image':
        pickerType = FileType.image;
        maxBytes = _chatImageMaxBytes;
        label = 'Image';
        break;
      case 'video':
        pickerType = FileType.custom;
        allowedExtensions = const ['mp4', 'mov', 'avi', 'mkv', 'webm'];
        maxBytes = _chatVideoMaxBytes;
        label = 'Vidéo';
        break;
      case 'audio':
        pickerType = FileType.custom;
        allowedExtensions = const ['mp3', 'wav', 'm4a', 'aac', 'ogg'];
        maxBytes = _chatAudioMaxBytes;
        label = 'Audio';
        break;
      default:
        _showError('Type de pièce jointe non supporté.');
        return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowedExtensions: allowedExtensions,
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showError('$label invalide. Réessayez avec un autre fichier.');
        return;
      }
      if (bytes.length > maxBytes) {
        final maxLabel = _formatFileSize(maxBytes);
        _showError(
          '$label trop lourd (${_formatFileSize(bytes.length)}). Limite: $maxLabel.',
        );
        return;
      }

      final name = file.name.trim().isEmpty ? '$label.bin' : file.name.trim();
      final extension = file.extension == null
          ? _fileExtensionFromName(name)
          : file.extension!.toLowerCase();
      final mimeType = _chatMimeTypeForAttachment(
        messageType: messageType,
        extension: extension,
      );

      _sendChatAttachment(
        conversationId: conversationId,
        messageType: messageType,
        mediaBase64: base64Encode(bytes),
        mediaName: name,
        mediaMimeType: mimeType,
        mediaSizeBytes: bytes.length,
      );
    } catch (_) {
      _showError('Impossible de charger la pièce jointe.');
    }
  }

  String _fileExtensionFromName(String filename) {
    final index = filename.lastIndexOf('.');
    if (index < 0 || index >= filename.length - 1) {
      return '';
    }
    return filename.substring(index + 1).toLowerCase();
  }

  String _chatMimeTypeForAttachment({
    required String messageType,
    required String extension,
  }) {
    switch (messageType) {
      case 'image':
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            return 'image/jpeg';
          case 'png':
            return 'image/png';
          case 'webp':
            return 'image/webp';
          case 'gif':
            return 'image/gif';
          default:
            return 'image/*';
        }
      case 'video':
        switch (extension) {
          case 'mp4':
            return 'video/mp4';
          case 'mov':
            return 'video/quicktime';
          case 'avi':
            return 'video/x-msvideo';
          case 'mkv':
            return 'video/x-matroska';
          case 'webm':
            return 'video/webm';
          default:
            return 'video/*';
        }
      case 'audio':
        switch (extension) {
          case 'mp3':
            return 'audio/mpeg';
          case 'wav':
            return 'audio/wav';
          case 'm4a':
            return 'audio/mp4';
          case 'aac':
            return 'audio/aac';
          case 'ogg':
            return 'audio/ogg';
          default:
            return 'audio/*';
        }
      default:
        return 'application/octet-stream';
    }
  }

  void _sendChatAttachment({
    required String conversationId,
    required String messageType,
    required String mediaBase64,
    required String mediaName,
    required String mediaMimeType,
    required int mediaSizeBytes,
  }) {
    final targetConversationId = _resolveChatConversationId(conversationId);
    if (!_canCurrentUserPostToConversation(targetConversationId)) {
      _showError(_teamConversationAccessError());
      return;
    }
    final label = switch (messageType) {
      'image' => 'Image',
      'video' => 'Vidéo',
      'audio' => 'Audio',
      _ => 'Pièce jointe',
    };

    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: targetConversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: '$label envoyé',
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
        messageType: messageType,
        mediaBase64: mediaBase64,
        mediaName: mediaName,
        mediaMimeType: mediaMimeType,
        mediaSizeBytes: mediaSizeBytes,
      ),
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'SEND_MEDIA',
      detail:
          '$label envoyé (${targetConversationId == _teamConversationId ? 'Canal équipe' : 'conversation directe'})',
    );
    _persistState();
    _showInfo('$label envoyé.');
  }

  Future<void> _startChatCall(String conversationId, String callType) async {
    final targetConversationId = _resolveChatConversationId(conversationId);
    if (!_canCurrentUserPostToConversation(targetConversationId)) {
      _showError(_teamConversationAccessError());
      return;
    }
    final normalizedType = callType.trim().toLowerCase() == 'video'
        ? 'video'
        : 'audio';
    final sessionId = _newId('CALL');
    final callLabel = normalizedType == 'video' ? 'vidéo' : 'audio';
    final title = targetConversationId == _teamConversationId
        ? 'Canal Équipe'
        : _conversationTitleById(targetConversationId);

    _appendChatMessage(
      ChatMessage(
        id: _newId('MSG'),
        conversationId: targetConversationId,
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        text: 'Appel $callLabel entrant',
        sentAt: DateTime.now(),
        readByUserIds: [_currentUser.id],
        messageType: 'call',
        callType: normalizedType,
        callStatus: _callRingingStatus,
        callSessionId: sessionId,
      ),
    );
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'START_CALL',
      detail: 'Appel $callLabel en sonnerie ($title)',
    );
    _persistState();
    _showInfo(
      'Appel $callLabel en sonnerie. Le destinataire peut accepter ou refuser.',
    );
  }

  String _conversationTitleById(String conversationId) {
    if (conversationId == _teamConversationId) {
      return 'Canal Équipe';
    }
    for (final user in _users) {
      if (conversationId.contains(user.id) && user.id != _currentUser.id) {
        return user.name;
      }
    }
    return 'Conversation directe';
  }

  Future<int?> _showActiveCallDialog({
    required String callType,
    required String title,
    String? remoteUserId,
    String? remoteUserName,
  }) async {
    var elapsedSeconds = 0;
    Timer? ticker;
    var tickerStarted = false;
    final isVideo = callType == 'video';
    final localUser = _currentUser;
    final remoteUser = _findUserById(_readString(remoteUserId).trim());
    final trimmedRemoteName = _readString(remoteUserName).trim();
    final remoteName = trimmedRemoteName.isEmpty ? title : trimmedRemoteName;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final maxWidth = math.min(
          MediaQuery.of(dialogContext).size.width * 0.9,
          560.0,
        );
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!tickerStarted) {
              tickerStarted = true;
              ticker = Timer.periodic(const Duration(seconds: 1), (_) {
                if (!context.mounted) {
                  ticker?.cancel();
                  return;
                }
                setModalState(() => elapsedSeconds++);
              });
            }

            return AlertDialog(
              title: Text(
                isVideo ? 'Appel vidéo en cours' : 'Appel audio en cours',
              ),
              content: SizedBox(
                width: maxWidth,
                child: isVideo
                    ? _buildActiveVideoCallContent(
                        localUser: localUser,
                        remoteUser: remoteUser,
                        remoteName: remoteName,
                        elapsedSeconds: elapsedSeconds,
                      )
                    : _buildActiveAudioCallContent(
                        title: remoteName,
                        elapsedSeconds: elapsedSeconds,
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Appel manqué'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(elapsedSeconds),
                  icon: const Icon(Icons.call_end, size: 16),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                  ),
                  label: const Text('Terminer'),
                ),
              ],
            );
          },
        );
      },
    );

    ticker?.cancel();
    return result;
  }

  Widget _buildActiveAudioCallContent({
    required String title,
    required int elapsedSeconds,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
          child: const Icon(
            Icons.call_outlined,
            color: Color(0xFF0F766E),
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          _formatDuration(elapsedSeconds),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        const Text(
          'Appel en cours. Utilisez "Terminer" pour clôturer le journal d’appel.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveVideoCallContent({
    required UserProfile localUser,
    required UserProfile? remoteUser,
    required String remoteName,
    required int elapsedSeconds,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildInCallVideoTile(
                  user: remoteUser,
                  label: remoteName,
                  accentColor: const Color(0xFF0F766E),
                ),
              ),
              Positioned(
                top: AppSpacing.s8,
                right: AppSpacing.s8,
                width: 128,
                height: 78,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.s8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _buildInCallVideoTile(
                    user: localUser,
                    label: 'Vous',
                    accentColor: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Row(
          children: [
            const Icon(
              Icons.videocam_outlined,
              color: Color(0xFF0F766E),
              size: 18,
            ),
            const SizedBox(width: AppSpacing.s6),
            Expanded(
              child: Text(
                remoteName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              _formatDuration(elapsedSeconds),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s6),
        const Text(
          'Aperçu vidéo actif. Utilisez "Terminer" pour clôturer l’appel.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInCallVideoTile({
    required UserProfile? user,
    required String label,
    required Color accentColor,
  }) {
    final avatarLabel = _inCallAvatarLabel(user, label);
    final imageBase64 = user?.profileImageBase64.trim() ?? '';
    final imageBytes = imageBase64.isEmpty
        ? null
        : _decodeImageBytesCached(imageBase64);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.s8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageBytes != null)
            Image.memory(imageBytes, fit: BoxFit.cover)
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.85),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    avatarLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: AppSpacing.s6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
              child: Text(
                label.trim().isEmpty ? 'Participant' : label.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _inCallAvatarLabel(UserProfile? user, String fallbackLabel) {
    final avatar = user?.avatar.trim() ?? '';
    if (avatar.isNotEmpty) {
      return avatar.substring(0, 1).toUpperCase();
    }
    final trimmed = fallbackLabel.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatDuration(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _chatMessagePreview(ChatMessage message) {
    switch (message.messageType) {
      case 'image':
        final imageName = message.mediaName.trim().isEmpty
            ? 'Image'
            : message.mediaName.trim();
        return 'Image: $imageName';
      case 'video':
        final videoName = message.mediaName.trim().isEmpty
            ? 'Vidéo'
            : message.mediaName.trim();
        return 'Vidéo: $videoName';
      case 'audio':
        final audioName = message.mediaName.trim().isEmpty
            ? 'Audio'
            : message.mediaName.trim();
        return 'Audio: $audioName';
      case 'call':
        final callLabel = message.callType == 'video'
            ? 'Appel vidéo'
            : 'Appel audio';
        final status = message.callStatus.trim().isEmpty
            ? ''
            : ' ${message.callStatus.trim()}';
        final duration = message.callDurationSeconds > 0
            ? ' (${_formatDuration(message.callDurationSeconds)})'
            : '';
        return '$callLabel$status$duration';
      default:
        final text = message.text.trim();
        return text.isEmpty ? 'Message' : text;
    }
  }

  Widget _buildChatMessageContent({
    required ChatMessage message,
    required bool isMine,
    Color? mineTextColor,
    Color? mineSubTextColor,
  }) {
    final textColor = isMine
        ? (mineTextColor ?? Colors.white)
        : const Color(0xFF0F172A);
    final subTextColor = isMine
        ? (mineSubTextColor ?? Colors.white70)
        : const Color(0xFF64748B);
    final messageType = message.messageType.trim().toLowerCase();

    if (messageType == 'image') {
      if (message.mediaBase64.trim().isEmpty) {
        return Text(
          message.text.trim().isEmpty ? 'Image indisponible.' : message.text,
          style: TextStyle(
            color: textColor,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        );
      }
      final bytes = _decodeImageBytesCached(message.mediaBase64);
      if (bytes != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.trim().isNotEmpty &&
                message.text.trim() != 'Image envoyé')
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s6),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                width: 220,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              message.mediaName.trim().isEmpty ? 'Image' : message.mediaName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (message.mediaSizeBytes > 0)
              Text(
                _formatFileSize(message.mediaSizeBytes),
                style: TextStyle(
                  color: subTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
          ],
        );
      }
      return Text(
        'Image corrompue ou non lisible.',
        style: TextStyle(
          color: textColor,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (messageType == 'video' || messageType == 'audio') {
      final isVideo = messageType == 'video';
      final title = isVideo ? 'Vidéo jointe' : 'Audio joint';
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s9),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVideo
                  ? Icons.videocam_outlined
                  : Icons.multitrack_audio_outlined,
              color: textColor,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    message.mediaName.trim().isEmpty
                        ? (isVideo ? 'video.bin' : 'audio.bin')
                        : message.mediaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  if (message.mediaSizeBytes > 0)
                    Text(
                      _formatFileSize(message.mediaSizeBytes),
                      style: TextStyle(
                        color: subTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (messageType == 'call') {
      final isVideo = message.callType.trim().toLowerCase() == 'video';
      final callLabel = isVideo ? 'Appel vidéo' : 'Appel audio';
      final status = message.callStatus.trim().isEmpty
          ? 'Journal'
          : message.callStatus.trim();
      final canRespond =
          !isMine &&
          _isCallRingingStatus(status) &&
          _incomingCallOffer != null &&
          _incomingCallOffer!.sessionId == _callSessionIdForMessage(message);
      final duration = message.callDurationSeconds > 0
          ? ' • ${_formatDuration(message.callDurationSeconds)}'
          : '';
      final bodyText = message.text.trim().isEmpty
          ? '$callLabel $status$duration'
          : message.text.trim();

      return Container(
        padding: const EdgeInsets.all(AppSpacing.s9),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVideo ? Icons.videocam_outlined : Icons.call_outlined,
              color: textColor,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bodyText,
                    style: TextStyle(
                      color: textColor,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Statut: $status',
                    style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  if (canRespond) ...[
                    const SizedBox(height: AppSpacing.s6),
                    Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s6,
                      children: [
                        OutlinedButton(
                          onPressed: _rejectIncomingCallOffer,
                          child: const Text('Refuser'),
                        ),
                        FilledButton(
                          onPressed: _acceptIncomingCallOffer,
                          child: const Text('Accepter'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      message.text,
      style: TextStyle(
        color: textColor,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '-';
    }
    if (bytes < 1024) {
      return '$bytes o';
    }
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb >= 10 ? 1 : 2)} MB';
  }

  Uint8List? _decodeImageBytesCached(String base64Value) {
    final normalized = base64Value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final cached = _imageBytesCache[normalized];
    if (cached != null) {
      return cached;
    }

    try {
      final bytes = base64Decode(normalized);
      if (_imageBytesCache.length >= 220) {
        _imageBytesCache.remove(_imageBytesCache.keys.first);
      }
      _imageBytesCache[normalized] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  String _chatTimeLabel(DateTime dateTime) {
    final today = _currentDate();
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (messageDay == today) {
      return DateFormat('HH:mm', 'fr_FR').format(dateTime);
    }
    if (messageDay.year == today.year) {
      return DateFormat('d MMM', 'fr_FR').format(dateTime);
    }
    return DateFormat('dd/MM/yy', 'fr_FR').format(dateTime);
  }

  String _chatClockLabel(DateTime dateTime) {
    return DateFormat('HH:mm', 'fr_FR').format(dateTime);
  }

  String _chatDayLabel(DateTime dateTime) {
    final today = _currentDate();
    final messageDay = _normalizeDate(dateTime);
    final diffDays = messageDay.difference(today).inDays;
    if (diffDays == 0) {
      return 'Aujourd\'hui';
    }
    if (diffDays == -1) {
      return 'Hier';
    }
    return DateFormat('EEEE d MMMM', 'fr_FR').format(dateTime);
  }

  String _clipText(String text, int maxChars) {
    final value = text.trim();
    if (value.length <= maxChars) {
      return value;
    }
    return '${value.substring(0, maxChars - 3)}...';
  }

  Color _roleColor(String role) {
    switch (role) {
      case Roles.admin:
        return const Color(0xFF7C3AED);
      case Roles.inseminator:
        return const Color(0xFFEA580C);
      case Roles.vet:
        return const Color(0xFF15803D);
      case Roles.breeder:
      default:
        return const Color(0xFF2563EB);
    }
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

  void _changePigletCalendarMonth(int monthDelta) {
    final nextMonth = DateTime(
      _pigletCalendarMonth.year,
      _pigletCalendarMonth.month + monthDelta,
      1,
    );
    setState(() {
      _pigletCalendarMonth = nextMonth;
      final referenceDate = _selectedPigletDate ?? nextMonth;
      final maxDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      final day = math.min(referenceDate.day, maxDay);
      _selectedPigletDate = DateTime(nextMonth.year, nextMonth.month, day);
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

  Map<DateTime, List<_GestationCalendarEvent>>
  _buildPigletCareCalendarEvents() {
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

    for (final record in _pigletCareRecords) {
      addEvent(
        date: record.eventDate,
        label:
            '${record.eventType} - ${record.groupName} (${record.animalCode})',
        type: 'SOIN',
        color: const Color(0xFF0F766E),
        icon: LucideIcons.piggyBank,
      );

      if (record.nextDate != null) {
        addEvent(
          date: record.nextDate!,
          label:
              'Rappel ${record.eventType} - ${record.groupName} (${record.animalCode})',
          type: 'RAPPEL',
          color: const Color(0xFFB45309),
          icon: Icons.calendar_month,
        );
      }
    }

    final protocolTemplates =
        <
          ({
            int dayOffset,
            String eventType,
            String matchKeyword,
            String detail,
            Color color,
            IconData icon,
          })
        >[
          (
            dayOffset: 0,
            eventType: 'Colostrum',
            matchKeyword: 'colostrum',
            detail: 'Prise colostrum + désinfection ombilic',
            color: const Color(0xFF0F766E),
            icon: LucideIcons.piggyBank,
          ),
          (
            dayOffset: 1,
            eventType: 'Coupe dents',
            matchKeyword: 'dent',
            detail: 'Coupe des dents et contrôle vitalité',
            color: const Color(0xFF2563EB),
            icon: Icons.content_cut,
          ),
          (
            dayOffset: 3,
            eventType: 'Supplémentation fer',
            matchKeyword: 'fer',
            detail: 'Injection fer porcelets J3',
            color: const Color(0xFFB45309),
            icon: LucideIcons.syringe,
          ),
          (
            dayOffset: 7,
            eventType: 'Castration',
            matchKeyword: 'castration',
            detail: 'Castration mâles + analgésie',
            color: const Color(0xFF7C3AED),
            icon: LucideIcons.badgeInfo,
          ),
          (
            dayOffset: 21,
            eventType: 'Vaccination porcelets',
            matchKeyword: 'vaccin',
            detail: 'Vaccination porcelets',
            color: const Color(0xFF15803D),
            icon: LucideIcons.shieldCheck,
          ),
          (
            dayOffset: 28,
            eventType: 'Sevrage',
            matchKeyword: 'sevrage',
            detail: 'Sevrage et transfert post-sevrage',
            color: const Color(0xFFEA580C),
            icon: LucideIcons.piggyBank,
          ),
        ];

    final today = _currentDate();
    for (final farrowing in _farrowingRecords) {
      for (final template in protocolTemplates) {
        final protocolDate = _normalizeDate(
          farrowing.farrowingDate.add(Duration(days: template.dayOffset)),
        );
        final alreadyLogged = _pigletCareRecords.any((record) {
          return _normalizeLookup(record.animalCode) ==
                  _normalizeLookup(farrowing.sowCode) &&
              _isSameDate(_normalizeDate(record.eventDate), protocolDate) &&
              _normalizeLookup(
                record.eventType,
              ).contains(_normalizeLookup(template.matchKeyword));
        });
        if (alreadyLogged) {
          continue;
        }

        addEvent(
          date: protocolDate,
          label:
              'Protocole ${template.eventType} - Portée ${farrowing.sowCode} (J${template.dayOffset} • ${template.detail})',
          type: 'PROTO',
          color: template.color,
          icon: template.icon,
        );
        if (protocolDate.isBefore(today)) {
          addEvent(
            date: today,
            label:
                'Retard protocole ${template.eventType} - Portée ${farrowing.sowCode}',
            type: 'ALERTE',
            color: const Color(0xFFB91C1C),
            icon: LucideIcons.alertTriangle,
          );
        }
      }
    }

    for (final record in _pigletCareRecords) {
      if (record.nextDate == null) {
        continue;
      }
      if (!record.nextDate!.isBefore(today)) {
        continue;
      }
      addEvent(
        date: today,
        label:
            'Soin en retard: ${record.eventType} - ${record.groupName} (${record.animalCode})',
        type: 'ALERTE',
        color: const Color(0xFFB91C1C),
        icon: LucideIcons.alertTriangle,
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(dateTime);
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

class _InseminatorRecap {
  final UserProfile user;
  final int totalIa;
  final int successIa;
  final int failedIa;
  final double totalIaCost;

  const _InseminatorRecap({
    required this.user,
    required this.totalIa,
    required this.successIa,
    required this.failedIa,
    required this.totalIaCost,
  });

  int get successRate {
    final decided = successIa + failedIa;
    if (decided == 0) {
      return 0;
    }
    return ((successIa / decided) * 100).round();
  }
}

class _BreederIaRecap {
  final UserProfile user;
  final int sowsToInseminate;
  final int successIa;
  final int failedIa;

  const _BreederIaRecap({
    required this.user,
    required this.sowsToInseminate,
    required this.successIa,
    required this.failedIa,
  });

  int get successRate {
    final decided = successIa + failedIa;
    if (decided == 0) {
      return 0;
    }
    return ((successIa / decided) * 100).round();
  }
}

class _BreederControlRecap {
  final UserProfile user;
  final int boarCount;
  final int sowCount;
  final int iaCount;
  final int overdueIaDiagnosis;
  final int overdueHealthActions;

  const _BreederControlRecap({
    required this.user,
    required this.boarCount,
    required this.sowCount,
    required this.iaCount,
    required this.overdueIaDiagnosis,
    required this.overdueHealthActions,
  });

  int get totalPigs => boarCount + sowCount;

  int get riskScore => overdueIaDiagnosis * 2 + overdueHealthActions;

  String get riskLabel {
    if (riskScore >= 4) {
      return 'Risque élevé';
    }
    if (riskScore >= 2) {
      return 'Risque modéré';
    }
    return 'Sous contrôle';
  }
}

class _DistrictPerformanceAccumulator {
  final String region;
  final String district;
  final Set<String> inseminators = <String>{};
  int totalIa = 0;
  int successIa = 0;
  int failedIa = 0;
  int overdueDiagnosis = 0;

  _DistrictPerformanceAccumulator({
    required this.region,
    required this.district,
  });
}

class _DistrictPerformanceRecap {
  final String region;
  final String district;
  final int inseminators;
  final int totalIa;
  final int successIa;
  final int failedIa;
  final int overdueDiagnosis;

  const _DistrictPerformanceRecap({
    required this.region,
    required this.district,
    required this.inseminators,
    required this.totalIa,
    required this.successIa,
    required this.failedIa,
    required this.overdueDiagnosis,
  });

  int get successRate {
    final decided = successIa + failedIa;
    if (decided == 0) {
      return 0;
    }
    return ((successIa / decided) * 100).round();
  }
}

class _BreederQualityRecap {
  final UserProfile user;
  final int sowCount;
  final int sowsWithCompletePedigree;
  final int sowsWithIaPlan;
  final int healthCoverageRate;
  final int qualityScore;

  const _BreederQualityRecap({
    required this.user,
    required this.sowCount,
    required this.sowsWithCompletePedigree,
    required this.sowsWithIaPlan,
    required this.healthCoverageRate,
    required this.qualityScore,
  });

  String get qualityStatus {
    if (qualityScore >= 80) {
      return 'Très bon';
    }
    if (qualityScore >= 60) {
      return 'Moyen';
    }
    return 'Critique';
  }
}

class _SemenLotRecap {
  final String lot;
  final String boarCode;
  final String boarBreed;
  final int totalIa;
  final int totalDoses;
  final int successIa;
  final int failedIa;

  const _SemenLotRecap({
    required this.lot,
    required this.boarCode,
    required this.boarBreed,
    required this.totalIa,
    required this.totalDoses,
    required this.successIa,
    required this.failedIa,
  });

  int get successRate {
    final decided = successIa + failedIa;
    if (decided == 0) {
      return 0;
    }
    return ((successIa / decided) * 100).round();
  }

  String get qualityLabel {
    if (failedIa > successIa) {
      return 'Surveiller';
    }
    return 'Conforme';
  }
}

class _SemenLotRecapBuilder {
  final String lot;
  final String boarCode;
  final String boarBreed;
  int totalIa = 0;
  int totalDoses = 0;
  int successIa = 0;
  int failedIa = 0;

  _SemenLotRecapBuilder({
    required this.lot,
    required this.boarCode,
    required this.boarBreed,
  });
}

class _SowIaFollowUp {
  final Sow sow;
  final String lastInseminationDateLabel;
  final String statusLabel;
  final Color statusColor;
  final String nextAction;
  final String nextDateLabel;

  const _SowIaFollowUp({
    required this.sow,
    required this.lastInseminationDateLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.nextAction,
    required this.nextDateLabel,
  });
}

class _PedigreeTreeNode {
  final String code;
  final String name;
  final String type;
  final String breed;
  final DateTime birthDate;
  final String breederId;
  final String sireCode;
  final String damCode;
  final String origin;

  const _PedigreeTreeNode({
    required this.code,
    required this.name,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.breederId,
    required this.sireCode,
    required this.damCode,
    required this.origin,
  });
}

class _ConsanguinityAlert {
  final DateTime date;
  final String sowCode;
  final String boarCode;
  final String status;
  final String issue;

  const _ConsanguinityAlert({
    required this.date,
    required this.sowCode,
    required this.boarCode,
    required this.status,
    required this.issue,
  });
}

class _ChatConversationSummary {
  final String id;
  final String title;
  final String subtitle;
  final String preview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String avatarLabel;
  final Color avatarColor;
  final bool isGroup;

  const _ChatConversationSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.avatarLabel,
    required this.avatarColor,
    this.isGroup = false,
  });
}

class _IncomingCallOffer {
  final String sessionId;
  final String conversationId;
  final String callerId;
  final String callerName;
  final String callType;
  final DateTime sentAt;

  const _IncomingCallOffer({
    required this.sessionId,
    required this.conversationId,
    required this.callerId,
    required this.callerName,
    required this.callType,
    required this.sentAt,
  });
}

class _HeaderNotificationEntry {
  final String title;
  final String detail;
  final int count;
  final IconData icon;
  final Color color;
  final String tabId;

  const _HeaderNotificationEntry({
    required this.title,
    required this.detail,
    required this.count,
    required this.icon,
    required this.color,
    required this.tabId,
  });
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

class _ZootechKpi {
  final String label;
  final String value;
  final String target;
  final Color color;

  const _ZootechKpi({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });
}

class _OperationalTaskItem {
  final String id;
  final DateTime dueDate;
  final String module;
  final String title;
  final String responsible;
  final _ActionPriority priority;
  final bool done;

  const _OperationalTaskItem({
    required this.id,
    required this.dueDate,
    required this.module,
    required this.title,
    required this.responsible,
    required this.priority,
    required this.done,
  });
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
