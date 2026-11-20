import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Safe Firebase init: works without google-services.json / GoogleService-Info.plist.
/// Returns true only if Firebase actually initialised; otherwise the app
/// continues with local SharedPreferences storage only.
class FirebaseService {
  static bool initialized = false;

  static Future<bool> init() async {
    try {
      if (Firebase.apps.isNotEmpty) { initialized = true; return true; }
      await Firebase.initializeApp();
      initialized = true;
      debugPrint('Firebase initialised');
      return true;
    } catch (e) {
      debugPrint('Firebase not configured, using local storage only: $e');
      initialized = false;
      return false;
    }
  }
}
