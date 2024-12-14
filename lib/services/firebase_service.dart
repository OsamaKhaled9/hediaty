import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/core/models/user.dart';  // Import your user model
import 'package:crypto/crypto.dart';  // For hashing the password
import 'dart:convert';  // For UTF-8 encoding

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user with email and password
  Future<UserCredential> signUpUser(String email, String password) async {
    try {
      // Create a new user with email and password
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Error signing up: $e");
    }
  }

  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File image) async {
    try {
      // Create a reference to store the profile picture in Firebase Storage
      String fileName = DateTime.now().toString();
      Reference storageRef = _storage.ref().child("profile_pictures/$fileName");
      
      // Upload the image
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading profile picture: $e");
    }
  }

  // Save user data to Firestore
  Future<void> saveUserToFirestore(user user) async {
    try {
      // Save user data in Firestore under the 'users' collection
      await _firestore.collection('users').doc(user.id).set({
        'fullName': user.fullName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profilePictureUrl': user.profilePictureUrl,
        'passwordHash': user.passwordHash,  // Store the hashed password

      });
    } catch (e) {
      throw Exception('Error saving user data to Firestore: $e');
    }
  }
    // Hash password using SHA256 (for secure storage)
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var hash = sha256.convert(bytes);  // Hash using SHA256
    return hash.toString();  // Return the hash as a string
  }
}
