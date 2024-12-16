import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*class ProfileController {
  final FirebaseService _firebaseService = FirebaseService();

Future<user?> loadUserProfile(String userId) async {
  try {
    DocumentSnapshot userData = await FirebaseService().getFirestoreInstance().collection('users').doc(userId).get();
    if (!userData.exists) return null;
    return user.fromMap(userData.data() as Map<String, dynamic>);
  } catch (e) {
    print("Error loading user profile: $e");
    return null;
  }
}

  Future<void> updateUserProfile(user user) async {
    await _firebaseService.updateUser(user);
  }
}*/


class ProfileController {
  final FirebaseService _firebaseService = FirebaseService();

  Future<user?> loadUserProfile(String userId) async {
    return await _firebaseService.getUserById(userId); // Use the new method
  }

  void updateNotificationSetting(user updatedUser) {
    _firebaseService.updateUser(updatedUser); // Update in Firestore
  }
}

