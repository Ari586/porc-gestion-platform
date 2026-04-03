class FirestorePaths {
  FirestorePaths._();

  // ── Realtime sync documents ────────────────────────────────────────
  static const String syncCollection = 'porc_realtime_sync';
  static const String usersSyncDoc = 'users_v2';
  static const String livestockSyncDoc = 'livestock_v2';
  static const String commercialSyncDoc = 'commercial_v2';
  static const String operationsSyncDoc = 'operations_v2';
  static const String chatSyncDoc = 'chat_v2';
  static const String newsSyncDoc = 'news_v2';

  // ── Per-record collections ─────────────────────────────────────────
  static const String usersCollection = 'porc_users_v1';
  static const String inseminationsCollection = 'porc_inseminations_v1';
  static const String healthRecordsCollection = 'porc_health_records_v1';
  static const String chatMessagesCollection = 'porc_chat_messages_v1';
  static const String fieldEventsCollection = 'porc_field_events_v1';

  // ── Communication ──────────────────────────────────────────────────
  static const String webrtcSignalingCollection = 'porc_webrtc_signaling';
  static const String presenceCollection = 'porc_presence_v1';
  static const String deviceTokensCollection = 'porc_device_tokens_v1';

  // ── Sync payload limits ────────────────────────────────────────────
  static const int chatSyncLimit = 180;
  static const int chatPayloadBudgetBytes = 850000;
  static const int newsSyncLimit = 80;
}
