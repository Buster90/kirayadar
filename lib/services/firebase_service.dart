import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Safe Firebase init: works without google-services.json / GoogleService-Info.plist.
/// Returns true only if Firebase actually initialised; otherwise the app
/// continues with local SharedPreferences storage only.
///
/// Firestore offline persistence is enabled here (before any Firestore
/// use) so reads/writes keep working with no network and sync when back
/// online. No anonymous sign-in is done here on purpose: signing in would
/// change auth state. Phone Auth (the OTP flow) will sign the landlord in
/// later, and FirestoreService then uses that UID as the landlord ID.
class FirebaseService {
  static bool initialized = false;

  static Future<bool> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        initialized = true;
      } else {
        try {
          // Real project config (lib/firebase_options.dart) when available.
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } on UnsupportedError {
          // Platform has no registered app yet (web/iOS): try the native
          // config files (google-services.json / GoogleService-Info.plist).
          await Firebase.initializeApp();
        }
        initialized = true;
      }
      // Enable offline persistence. Must be set before Firestore is used;
      // a failure here must not mark Firebase as uninitialised.
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint('Firestore persistence could not be set: $e');
      }
      debugPrint('Firebase initialised');
      return true;
    } catch (e) {
      debugPrint('Firebase not configured, using local storage only: $e');
      initialized = false;
      return false;
    }
  }
}
