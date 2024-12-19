import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class user {
  String id;
  String fullName;
  String email;
  String phoneNumber;
  String profilePictureUrl;
  String passwordHash; // Store password hash, not plain text
  bool isNotificationsEnabled; // Added field for notification settings

  user({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.passwordHash,
    this.isNotificationsEnabled  = false, // Default to false for compatibility
  });

  // Function to hash the password before storing it
  void setPassword(String password) {
    passwordHash = _hashPassword(password);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash using SHA256
    return digest.toString(); // Return the hashed password as a string
  }

  // Convert the user object to JSON for saving in SQLite or Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'passwordHash': passwordHash, // Use the hashed password
      'isNotificationsEnabled': isNotificationsEnabled, // Add new field
    };
  }

  // Convert JSON back to a user object
  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      passwordHash: json['passwordHash'],
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? false, // Handle missing field
    );
  }

  // Convert Map (e.g., from SQLite) back to a user object
  factory user.fromMap(Map<String, dynamic> data) {
    return user(
      id: data['id'] as String? ?? '',
      fullName: data['fullName'] as String? ?? 'No Name',
      email: data['email'] as String? ?? 'No Email',
      phoneNumber: data['phoneNumber'] as String? ?? 'No Phone Number',
      profilePictureUrl: data['profilePictureUrl'] as String? ?? 'default_avatar.jpg',
      passwordHash: data['passwordHash'] as String? ?? '',
      isNotificationsEnabled: data['isNotificationsEnabled'] as bool? ?? false, // Handle missing field
    );
  }

  // Create a user object from Firebase User and additional data
  factory user.fromFirebaseUser(User firebaseUser, Map<String, dynamic> additionalData) {
    return user(
      id: firebaseUser.uid,
      fullName: additionalData['fullName'] ?? '',
      email: firebaseUser.email ?? '',
      phoneNumber: additionalData['phoneNumber'] ?? '',
      profilePictureUrl: additionalData['profilePictureUrl'] ?? 'default_avatar.jpg',
      passwordHash: additionalData['passwordHash'] ?? '',
      isNotificationsEnabled: additionalData['isNotificationsEnabled'] ?? false, // Handle missing field
    );
  }
  // CopyWith method
  user copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    String? passwordHash,
    bool? isNotificationsEnabled,
  }) {
    return user(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      passwordHash: passwordHash ?? this.passwordHash,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }

}
