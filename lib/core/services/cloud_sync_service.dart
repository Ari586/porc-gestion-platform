import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_paths.dart';
import 'auth_service.dart';

/// Orchestrates bidirectional sync between local state and Firestore
/// bulk-sync documents.
class CloudSyncService {
  final AuthService _auth;

  CloudSyncService(this._auth);

  bool get available => Firebase.apps.isNotEmpty && _auth.hasAuthSession;
  String get _uid => _auth.firebaseAuthUid;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  DocumentReference _syncDoc(String docId) =>
      _db.collection(FirestorePaths.syncCollection).doc(docId);

  // ── Read ─────────────────────────────────────────────────────────────

  /// Fetch a full sync document and return its parsed JSON map.
  Future<Map<String, dynamic>> fetchDocument(String docId) async {
    if (!available) {
      debugPrint('[CloudSync] Firebase unavailable – fetchDocument($docId) returning empty map');
      return {};
    }
    try {
      final snap = await _syncDoc(docId).get();
      return snap.data() as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('[CloudSync] fetchDocument($docId) error: $e');
      return {};
    }
  }

  /// Listen to realtime updates on a sync document.
  /// Returns a single empty-map emission when Firebase is not available,
  /// so StreamProviders resolve to `data` instead of staying in `loading`.
  Stream<Map<String, dynamic>> watchDocument(String docId) {
    if (!available) {
      debugPrint('[CloudSync] Firebase unavailable – watchDocument($docId) emitting empty seed');
      return Stream.value(<String, dynamic>{});
    }
    return _syncDoc(docId)
        .snapshots()
        .map((snap) => snap.data() as Map<String, dynamic>? ?? {});
  }

  // ── Write ────────────────────────────────────────────────────────────

  /// Merge-update a sync document with the given payload.
  Future<void> mergeDocument(String docId, Map<String, dynamic> data) async {
    if (!available) {
      debugPrint('[CloudSync] Firebase unavailable – mergeDocument($docId) skipped (local-only mode)');
      return;
    }
    try {
      data['lastModifiedBy'] = _uid;
      data['lastModifiedAt'] = FieldValue.serverTimestamp();
      await _syncDoc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[CloudSync] mergeDocument($docId) error: $e');
    }
  }

  /// Overwrite a specific key inside a sync document.
  Future<void> setDocumentKey(
      String docId, String key, dynamic value) async {
    await mergeDocument(docId, {key: value});
  }

  // ── Convenience per-domain methods ───────────────────────────────────

  Future<Map<String, dynamic>> fetchLivestock() =>
      fetchDocument(FirestorePaths.livestockSyncDoc);
  Stream<Map<String, dynamic>> watchLivestock() =>
      watchDocument(FirestorePaths.livestockSyncDoc);

  Future<Map<String, dynamic>> fetchCommercial() =>
      fetchDocument(FirestorePaths.commercialSyncDoc);
  Stream<Map<String, dynamic>> watchCommercial() =>
      watchDocument(FirestorePaths.commercialSyncDoc);

  Future<Map<String, dynamic>> fetchOperations() =>
      fetchDocument(FirestorePaths.operationsSyncDoc);
  Stream<Map<String, dynamic>> watchOperations() =>
      watchDocument(FirestorePaths.operationsSyncDoc);

  Future<Map<String, dynamic>> fetchUsers() =>
      fetchDocument(FirestorePaths.usersSyncDoc);

  Future<Map<String, dynamic>> fetchChat() =>
      fetchDocument(FirestorePaths.chatSyncDoc);
  Stream<Map<String, dynamic>> watchChat() =>
      watchDocument(FirestorePaths.chatSyncDoc);

  Future<Map<String, dynamic>> fetchNews() =>
      fetchDocument(FirestorePaths.newsSyncDoc);
  Stream<Map<String, dynamic>> watchNews() =>
      watchDocument(FirestorePaths.newsSyncDoc);

  // ── Bulk save helpers ────────────────────────────────────────────────

  Future<void> saveLivestock(Map<String, dynamic> data) =>
      mergeDocument(FirestorePaths.livestockSyncDoc, data);
  Future<void> saveCommercial(Map<String, dynamic> data) =>
      mergeDocument(FirestorePaths.commercialSyncDoc, data);
  Future<void> saveOperations(Map<String, dynamic> data) =>
      mergeDocument(FirestorePaths.operationsSyncDoc, data);
  Future<void> saveChat(Map<String, dynamic> data) =>
      mergeDocument(FirestorePaths.chatSyncDoc, data);
  Future<void> saveNews(Map<String, dynamic> data) =>
      mergeDocument(FirestorePaths.newsSyncDoc, data);
}
