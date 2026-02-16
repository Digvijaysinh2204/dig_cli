import 'import.dart';

class FirebaseUtils {
  FirebaseUtils._();

  /// Safely initializes Firebase, handling duplicate app errors and missing configurations.
  static Future<void> safeInitialize() async {
    try {
      final options = AppConfig.firebaseOptions;

      if (options == null) {
        kLog(
          content:
              'Firebase is not configured (Empty Project ID). Skipping initialization.',
          title: 'FIREBASE',
        );
        return;
      }

      if (Firebase.apps.isNotEmpty) {
        kLog(content: 'Firebase already initialized.', title: 'FIREBASE');
        return;
      }

      await Firebase.initializeApp(options: options);
      kLog(content: 'Firebase initialized successfully.', title: 'FIREBASE');
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        kLog(
          content: 'Firebase already initialized (Duplicate App).',
          title: 'FIREBASE',
        );
      } else {
        kLog(content: 'Firebase Initialization Error: $e', title: 'FIREBASE');
        kLog(
          content: 'Note: App will continue to run without Firebase features.',
          title: 'FIREBASE',
        );
      }
    }
  }
}
