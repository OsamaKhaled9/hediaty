import 'dart:io';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:hediaty/services/session_service.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final SessionService _sessionService = SessionService();

  // Sign up user, authenticate, upload profile pic, and save data
Future<String?> signUpUser(user user, String password, File? profileImage) async {
  try {
    // Firebase Auth Sign Up
    UserCredential userCredential = await _firebaseService.signUpUser(user.email, password);
    user.id = userCredential.user?.uid ?? "";

    // Hash password for secure storage
    String hashedPassword = _firebaseService.hashPassword(password);
    user.passwordHash = hashedPassword;

    // Upload profile picture if provided
    if (profileImage != null) {
      user.profilePictureUrl = await _firebaseService.uploadProfilePicture(profileImage);
    }

    // Save user data to Firestore
    print("Saving user to Firestore: ${user.phoneNumber}");
    await _firebaseService.saveUserToFirestore(user);
    
    // Store user data in SQLite (local storage)
    await _databaseService.insertUser(user);

    // Save session
    await _sessionService.saveSession(true);

    return null;  // Success
  } catch (e) {
    return e.toString();
  }
}

}
