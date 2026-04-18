import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create user profile after registration
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? phoneNumber,
    String? farmName,
    String? location,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        farmName: farmName,
        location: location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        ...userModel.toMap(),
      });

      print('✓ User profile created: $uid');
    } catch (e) {
      print('✗ Create user profile error: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final data = await _firestoreService.read('users', uid);

      if (data != null) {
        return UserModel.fromMap(uid, data);
      }
      return null;
    } catch (e) {
      print('✗ Get user profile error: $e');
      rethrow;
    }
  }

  /// Stream profile updates in real time
  Stream<UserModel?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromMap(uid, snapshot.data()!);
    });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? farmName,
    String? location,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (farmName != null) updateData['farmName'] = farmName;
      if (location != null) updateData['location'] = location;

      if (updateData.isEmpty) {
        return;
      }

      await _firestoreService.update('users', uid, updateData);

      print('✓ User profile updated: $uid');
    } catch (e) {
      print('✗ Update user profile error: $e');
      rethrow;
    }
  }

  /// Delete user account (data cleanup)
  Future<void> deleteUserAccount(String uid) async {
    try {
      await _firestoreService.delete('users', uid);
      print('✓ User account deleted: $uid');
    } catch (e) {
      print('✗ Delete user account error: $e');
      rethrow;
    }
  }

  /// Create a default farm for the user
  Future<String> createDefaultFarm({
    required String uid,
    String farmName = 'My Farm',
    String? location,
  }) async {
    try {
      final farmData = {
        'name': farmName,
        'location': location ?? '',
        'ownerId': uid,
        'createdAt': DateTime.now(),
        'isDefault': true,
      };

      final farmId = await _firestoreService.create(
        'users/$uid/farms',
        farmData,
      );

      print('✓ Default farm created: $farmId');
      return farmId;
    } catch (e) {
      print('✗ Create default farm error: $e');
      rethrow;
    }
  }

  /// Get default farm ID for user
  /// Returns the first farm's ID (assumes single farm for MVP)
  Future<String?> getDefaultFarmId(String uid) async {
    try {
      // In MVP, we assume user has one farm
      // For multi-farm support, query for isDefault: true
      // This would need additional implementation
      // For now, return null - will be handled in UI
      return null;
    } catch (e) {
      print('✗ Get default farm error: $e');
      rethrow;
    }
  }
}
