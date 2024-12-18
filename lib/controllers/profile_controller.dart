import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<user?> loadUserProfile(String userId) async {
    return await _firebaseService.getUserById(userId); // Use the new method
  }

  /// Update notification settings
  Future<void> updateNotificationSetting(user updatedUser) async {
    await _firestore.collection('users').doc(updatedUser.id).update({
      'isNotificationsEnabled': updatedUser.isNotificationsEnabled,
    });
  }
    /// Updates the user profile in Firestore
  Future<void> updateUserProfile(user updatedUser) async {
    try {
      // Update user data in Firestore
      await _firestore.collection('users').doc(updatedUser.id).update({
        'fullName': updatedUser.fullName,
        'email': updatedUser.email,
        'phoneNumber': updatedUser.phoneNumber,
        'profilePictureUrl': updatedUser.profilePictureUrl,
        'isNotificationsEnabled': updatedUser.isNotificationsEnabled,
      });

      print("User profile updated successfully in Firestore.");
    } catch (e) {
      print("Error updating user profile in Firestore: $e");
      throw Exception("Failed to update user profile.");
    }
  }
   /// Stream to listen to real-time updates of the user profile
  Stream<user?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return user.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
  
}

