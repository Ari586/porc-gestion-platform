import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  String get firebaseAuthUid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid?.trim() ?? '';
  }

  bool get hasAuthSession => firebaseAuthUid.isNotEmpty;

  Future<void> ensureAuthSession() async {
    if (!isFirebaseAvailable) return;
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (_) {
      // Keep local-only mode if auth init fails.
    }
  }

  Future<void> signOut() async {
    if (!isFirebaseAvailable) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
