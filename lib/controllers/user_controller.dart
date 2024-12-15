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
Future<String?> signUpUser(user user, String password,String phoneNumber, String avatarPath) async {
  
  try {
      // Check if phone number is unique
      bool isUnique = await _firebaseService.isPhoneNumberUnique(phoneNumber);
      if (!isUnique) {
        return 'Phone number already in use';
      }
    // Firebase Auth Sign Up
    UserCredential userCredential = await _firebaseService.signUpUser(user.email, password);
    user.id = userCredential.user?.uid ?? "";

    // Save avatar path (either default or selected from assets)
    user.profilePictureUrl = avatarPath.isNotEmpty ? avatarPath : 'assets/images/default_avatar.JPG';  // Default if no selection

    // Store user data in SQLite (optional, can be removed if not using SQLite)
    print("Saving user data to local: ${user.toJson()}");  // Debug log

    await _databaseService.insertUser(user);

    // Save user data to Firestore

    print("Saving user data to Firestore: ${user.toString()}");  // Debug log

    await _firebaseService.saveUserToFirestore(user, avatarPath);

    // Save session
    await _sessionService.saveSession(true);

    return null;  // Success
  } catch (e) {
    return e.toString();
  }
}
}