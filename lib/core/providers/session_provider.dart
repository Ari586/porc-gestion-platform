import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/cloud_sync_service.dart';
import '../services/preference_service.dart';
import '../services/service_locator.dart';

class SessionNotifier extends StateNotifier<UserProfile?> {
  static const _sessionKey = 'auth_session_profile';

  SessionNotifier() : super(null) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final json = await getIt<PreferenceService>().getString(_sessionKey);
      if (json.isNotEmpty) {
        state = UserProfile.fromJson(jsonDecode(json));
      }
    } catch (_) {}
  }

  Future<String?> login(String login, String password) async {
    List<UserProfile> users = [];
    try {
      final data = await getIt<CloudSyncService>().fetchUsers();
      final raw = data['users'];
      if (raw is List) {
        users = raw
            .whereType<Map<String, dynamic>>()
            .map((j) => UserProfile.fromJson(j))
            .whereType<UserProfile>()
            .toList();
      }
    } catch (_) {}
    if (users.isEmpty) users = MockData.users;

    final match = users
        .where((u) => u.login == login.trim() && u.password == password)
        .firstOrNull;

    if (match == null) return 'Identifiant ou mot de passe incorrect';
    
    state = match;
    try {
      await getIt<PreferenceService>().setString(_sessionKey, jsonEncode(match.toJson()));
    } catch (_) {}
    
    return null;
  }

  Future<void> logout() async {
    state = null;
    try {
      await getIt<PreferenceService>().remove(_sessionKey);
    } catch (_) {}
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, UserProfile?>(
  (_) => SessionNotifier(),
);
