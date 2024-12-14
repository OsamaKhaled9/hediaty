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
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('User Created: ${userCredential.user?.uid}');  // Debugging print statement
    return userCredential;
  } catch (e) {
    print('Error signing up: $e');  // Debugging error print
    throw Exception("Error signing up: $e");
  }
}


  // Save user data and avatar path to Firestore
Future<String> saveUserToFirestore(user user, String selectedAvatarPath) async {
  try {
    // Hash the password
    user.passwordHash = hashPassword(user.passwordHash);
        print('User Created: $user,$selectedAvatarPath');  // Debugging print statement

    // Save user data to Firestore
    await _firestore.collection('users').doc(user.id).set({
      'fullName': user.fullName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'profilePictureUrl': selectedAvatarPath,  // Store the selected avatar path
      'passwordHash': user.passwordHash,  // Store the hashed password
    });

    return 'User data saved successfully!';  // Success message
  } catch (e) {
    return e.toString();  // Return error message
  }
}
/*
  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File image) async {
    try {
      // Create a unique file name for the image
      String fileName = DateTime.now().toString();
      Reference storageRef = _storage.ref().child("profile_pictures/$fileName");
      
      // Upload the image
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;  // Return the download URL of the image
    } catch (e) {
      throw Exception("Error uploading profile picture: $e");
    }
  }
*/
  // Hash password using SHA256 (for secure storage)
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var hash = sha256.convert(bytes);  // Hash using SHA256
    return hash.toString();  // Return the hash as a string
  }
}
