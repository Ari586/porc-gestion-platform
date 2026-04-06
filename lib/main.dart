import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket_chat_call_page.dart';
import 'features/tantsahaup/tantsahaup_app.dart';
import 'theme/app_theme.dart';
import 'routing/app_router.dart';
import 'core/services/service_locator.dart';

// ── Firebase Configuration ───────────────────────────────────────────

const String _defaultFirebaseApiKey = 'AIzaSyAJhP6o3q9VVSdNjAdCoulSn4qBZfnvdMk';
const String _defaultFirebaseAppId = '1:868440634699:web:74450072a14a613bafa4ce';
const String _defaultFirebaseProjectId = 'porc-gestion-platform';
const String _defaultFirebaseMessagingSenderId = '868440634699';
const String _defaultFirebaseAuthDomain = 'porc-gestion-platform.firebaseapp.com';
const String _defaultFirebaseStorageBucket = 'porc-gestion-platform.firebasestorage.app';

// ── Main Entry Point ────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and Auth
  await _initializeRealtimeBackend();
  await _ensureRealtimeAuthSession();
  
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {}

  // Localizations and Service Locator
  await initializeDateFormatting('fr_FR', null);
  await setupServiceLocator();

  runApp(const ProviderScope(child: PigBreedingApp()));
}

// ── App Bootstrap ───────────────────────────────────────────────────

class PigBreedingApp extends ConsumerWidget {
  const PigBreedingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const useSocketDemo = bool.fromEnvironment('SOCKET_DEMO', defaultValue: false);
    const useTantsahaUpApp = bool.fromEnvironment('TANTSAHAUP_APP', defaultValue: false);
    
    final useTantsahaUpFromQuery = kIsWeb && Uri.base.queryParameters['app'] == 'tantsahaup';

    if (useTantsahaUpApp || useTantsahaUpFromQuery) {
      return MaterialApp(
        title: 'TantsahaUp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const TantsahaUpAppPage(),
      );
    }
    
    if (useSocketDemo) {
      return MaterialApp(
        title: 'Socket Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SocketChatCallPage(),
      );
    }

    // Default: New Modular PigIA app
    return MaterialApp.router(
      title: 'PigIA — Gestion Porcine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

// ── Firebase Helpers ────────────────────────────────────────────────

Future<void> _ensureRealtimeAuthSession() async {
  try {
    if (Firebase.apps.isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      final options = _firebaseOptionsFromEnvironment();
      if (options == null) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: options);
      }
    }
  } catch (_) {}
}

Future<void> _initializeRealtimeBackend() async {
  try {
    if (Firebase.apps.isNotEmpty) return;
    final options = _firebaseOptionsFromEnvironment();
    if (options == null) {
      await Firebase.initializeApp();
      return;
    }
    await Firebase.initializeApp(options: options);
  } catch (_) {}
}

FirebaseOptions? _firebaseOptionsFromEnvironment() {
  const apiKeyFromEnv = String.fromEnvironment('FIREBASE_API_KEY');
  const appIdFromEnv = String.fromEnvironment('FIREBASE_APP_ID');
  const projectIdFromEnv = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const messagingSenderIdFromEnv = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');

  final apiKey = apiKeyFromEnv.trim().isEmpty || apiKeyFromEnv.contains('secrets.FIREBASE')
      ? _defaultFirebaseApiKey : apiKeyFromEnv.trim();
  final appId = appIdFromEnv.trim().isEmpty || appIdFromEnv.contains('secrets.FIREBASE')
      ? _defaultFirebaseAppId : appIdFromEnv.trim();
  final projectId = projectIdFromEnv.trim().isEmpty || projectIdFromEnv.contains('secrets.FIREBASE')
      ? _defaultFirebaseProjectId : projectIdFromEnv.trim();
  final messagingSenderId = messagingSenderIdFromEnv.trim().isEmpty || messagingSenderIdFromEnv.contains('secrets.FIREBASE')
      ? _defaultFirebaseMessagingSenderId : messagingSenderIdFromEnv.trim();

  if (apiKey.isEmpty || appId.isEmpty || projectId.isEmpty || messagingSenderId.isEmpty) {
    return null;
  }

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    projectId: projectId,
    messagingSenderId: messagingSenderId,
    authDomain: _defaultFirebaseAuthDomain,
    storageBucket: _defaultFirebaseStorageBucket,
  );
}
