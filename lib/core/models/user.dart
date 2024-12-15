import 'package:crypto/crypto.dart';
import 'dart:convert';

class user {
  String id;
  String fullName;
  String email;
  String phoneNumber;
  String profilePictureUrl;
  String passwordHash; // Store password hash, not plain text

  user({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.passwordHash,
  });

  // Function to hash the password before storing it
  void setPassword(String password) {
    passwordHash = _hashPassword(password);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);  // Convert password to bytes
    final digest = sha256.convert(bytes);  // Hash using SHA256
    return digest.toString();  // Return the hashed password as a string
  }

  // Convert the user object to JSON for saving in SQLite
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'passwordHash': passwordHash, // Use the hashed password
    };
  }

  // Convert JSON back to a User object
  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      passwordHash: json['passwordHash'],
    );
  }
     factory user.fromMap(Map<String, dynamic> data) {
        return user(
            id: data['id'] as String? ?? '',
            fullName: data['fullName'] as String? ?? 'No Name',
            email: data['email'] as String? ?? 'No Email',
            phoneNumber: data['phoneNumber'] as String? ?? 'No Phone Number',
            profilePictureUrl: data['profilePictureUrl'] as String? ?? 'Default URL',
            passwordHash: data['passwordHash'] as String? ?? '',
        );
    }
}
