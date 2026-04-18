import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPreferences {
  final bool lowFeedAlerts;
  final bool mortalityAlerts;
  final bool generalAlerts;

  const NotificationPreferences({
    required this.lowFeedAlerts,
    required this.mortalityAlerts,
    required this.generalAlerts,
  });

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      lowFeedAlerts: true,
      mortalityAlerts: true,
      generalAlerts: true,
    );
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return NotificationPreferences.defaults();
    }

    return NotificationPreferences(
      lowFeedAlerts: (map['lowFeedAlerts'] as bool?) ?? true,
      mortalityAlerts: (map['mortalityAlerts'] as bool?) ?? true,
      generalAlerts: (map['generalAlerts'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lowFeedAlerts': lowFeedAlerts,
      'mortalityAlerts': mortalityAlerts,
      'generalAlerts': generalAlerts,
      'updatedAt': DateTime.now(),
    };
  }
}

class NotificationPreferencesService {
  NotificationPreferencesService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _docRef(String uid) {
    return _db.collection('users').doc(uid).collection('settings').doc('notifications');
  }

  static Future<NotificationPreferences> getPreferences(String uid) async {
    final snapshot = await _docRef(uid).get();
    return NotificationPreferences.fromMap(snapshot.data());
  }

  static Stream<NotificationPreferences> streamPreferences(String uid) {
    return _docRef(uid).snapshots().map(
          (snapshot) => NotificationPreferences.fromMap(snapshot.data()),
        );
  }

  static Future<void> savePreferences({
    required String uid,
    required NotificationPreferences preferences,
  }) async {
    await _docRef(uid).set(preferences.toMap(), SetOptions(merge: true));
  }
}
