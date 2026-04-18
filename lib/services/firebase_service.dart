import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Singleton class for Firebase initialization
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Initialize Firebase with options
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✓ Firebase initialized successfully');
    } catch (e) {
      print('✗ Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Get Firebase app instance
  static FirebaseApp get app => Firebase.app();
}
