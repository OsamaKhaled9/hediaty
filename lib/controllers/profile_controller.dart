import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load user profile and sync Firestore with local database
  Future<user?> loadUserProfile(String userId) async {
    try {
      // Fetch user data from Firestore
      user? firestoreUser = await _firebaseService.getUserById(userId);

      if (firestoreUser != null) {
        // Sync Firestore user data to SQLite
        await _databaseService.insertUser(firestoreUser);
      }

      return firestoreUser;
    } catch (e) {
      print("Error loading user profile: $e");
      return null;
    }
  }

  // Update user profile in Firestore and SQLite
  Future<void> updateUserProfile(user updatedUser) async {
    try {
      // Update Firestore
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());

      // Update SQLite
      await _databaseService.insertUser(updatedUser);

      print("User profile updated successfully.");
    } catch (e) {
      print("Error updating user profile: $e");
      throw Exception("Failed to update user profile.");
    }
  }

  // Stream user profile updates from Firestore
  Stream<user?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return user.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update notification settings
  Future<void> updateNotificationSetting(user updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.id).update({
        'isNotificationsEnabled': updatedUser.isNotificationsEnabled,
      });

      // Update SQLite
      await _databaseService.insertUser(updatedUser);
    } catch (e) {
      print("Error updating notification settings: $e");
      throw Exception("Failed to update notification settings.");
    }
  }
}
