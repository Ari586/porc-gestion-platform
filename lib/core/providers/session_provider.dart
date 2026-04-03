import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/cloud_sync_service.dart';
import '../services/service_locator.dart';

class SessionNotifier extends StateNotifier<UserProfile?> {
  SessionNotifier() : super(null);

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
    return null;
  }

  void logout() => state = null;
}

final sessionProvider = StateNotifierProvider<SessionNotifier, UserProfile?>(
  (_) => SessionNotifier(),
);
