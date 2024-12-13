import 'dart:io';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:hediaty/services/session_service.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Correct import for UserCredential

class UserController {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final SessionService _sessionService = SessionService();

  Future<String?> signUpUser(user user, String password, File? profileImage) async {
    try {
      // Firebase Auth Sign Up
      UserCredential userCredential = await _firebaseService.signUpUser(user.email, password);
      user.id = userCredential.user?.uid ?? "";

      // Upload profile picture if provided
      if (profileImage != null) {
        user.profilePictureUrl = await _firebaseService.uploadProfilePicture(profileImage);
      }

      // Store user data in SQLite
      await _databaseService.insertUser(user);

      // Save session
      await _sessionService.saveSession(true);

      return null;  // Success
    } catch (e) {
      return e.toString();
    }
  }
}
