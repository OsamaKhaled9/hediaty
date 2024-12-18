import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:hediaty/services/session_service.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final SessionService _sessionService = SessionService();

  // Sign up user, authenticate, upload profile pic, and save data
  Future<String?> signUpUser(user user, String password, String phoneNumber, String avatarPath) async {
    try {
      // Check if phone number is unique
      bool isUnique = await _firebaseService.isPhoneNumberUnique(phoneNumber);
      if (!isUnique) {
        return 'Phone number already in use';
      }

      // Firebase Auth Sign Up
      UserCredential userCredential = await _firebaseService.signUpUser(user.email, password);
      user.id = userCredential.user?.uid ?? "";

      // Save avatar path
      user.profilePictureUrl = avatarPath.isNotEmpty ? avatarPath : 'assets/images/default_avatar.JPG';

      // Save user to local SQLite
      await _databaseService.insertUser(user);

      // Save user to Firestore
      await _firebaseService.saveUserToFirestore(user, avatarPath);

      // Save session state
      await _sessionService.saveSession(true);

      return null; // Sign-up success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  // Load user profile from Firestore and sync to SQLite
  Future<user?> loadUserProfile(String userId) async {
  try {
    // Fetch user data from Firestore
    user? firestoreUser = await _firebaseService.getUserById(userId);

    if (firestoreUser != null) {
      // Check if the user already exists in SQLite
      user? localUser = await _databaseService.getUser(userId);

      if (localUser == null) {
        // Insert only if the user doesn't already exist
        await _databaseService.insertUser(firestoreUser);
        print("User inserted into local database.");
      } else {
        print("User already exists in local database.");
      }
    }

    return firestoreUser;
  } catch (e) {
    print("Error loading user profile: $e");
    return null;
  }
}

}
