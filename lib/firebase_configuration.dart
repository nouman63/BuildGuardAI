import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Android uses native resources generated from the local google-services.json.
/// Web uses an ignored --dart-define-from-file configuration file.
class FirebaseConfiguration {
  static FirebaseOptions? get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return null;
    if (kIsWeb) {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const appId = String.fromEnvironment('FIREBASE_APP_ID');
      const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      if (apiKey.isEmpty ||
          appId.isEmpty ||
          senderId.isEmpty ||
          projectId.isEmpty) {
        throw StateError(
            'Provide firebase.web.local.json. See FIREBASE_SETUP.md.');
      }
      return const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: senderId,
          projectId: projectId,
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
          storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'));
    }
    throw UnsupportedError('Firebase is configured for Android and web only.');
  }
}
