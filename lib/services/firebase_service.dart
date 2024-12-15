import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/core/models/user.dart';  // Import your user model
import 'package:crypto/crypto.dart';  // For hashing the password
import 'dart:convert';  // For UTF-8 encoding
import 'package:hediaty/core/models/friend.dart';  // Import friend model
import 'package:hediaty/controllers/home_controller.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the phone number is unique (no other users have this phone number)
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    QuerySnapshot result = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return result.docs.isEmpty;
  }

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

  // Fetch friends of a user from Firestore
  Future<List<Friend>> getFriends(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: userId)
          .get();
      
      List<Friend> friends = snapshot.docs.map((doc) {
        return Friend.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      
      return friends;
    } catch (e) {
      print("Error fetching friends: $e");
      return [];
    }
  }

  // Add a friend to Firestore (with mutual entries)
  Future<void> addFriendToFirestore(Friend friend) async {
    try {
      // Add friend to the current user's friends collection
      await _firestore.collection('friends').doc(friend.id).set(friend.toJson());
      
      // Add the reciprocal friend entry (i.e., both users have the other listed as a friend)
      Friend reciprocalFriend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: friend.friendId,
        friendId: friend.userId,
        friendName: friend.friendName,
        friendAvatar: friend.friendAvatar,
        upcomingEventsCount: 0,  // Default value, can be updated later
      );
      await _firestore.collection('friends').doc(reciprocalFriend.id).set(reciprocalFriend.toJson());
      
      print("Friend added successfully.");
    } catch (e) {
      print("Error adding friend: $e");
      throw Exception("Error adding friend: $e");
    }
  }

  // Search for a user by phone number or name
  Future<List<Friend>> searchFriends(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThan: query + 'z')  // Ensures fullName starts with query
          .get();
      
      List<Friend> friends = snapshot.docs.map((doc) {
        return Friend(
          id: doc.id, // Use Firestore document ID as unique friend ID
          userId: doc['id'],
          friendId: doc['id'],  // Assuming this will be the friend to add
          friendName: doc['fullName'],
          friendAvatar: doc['profilePictureUrl'],
          upcomingEventsCount: 0,  // Default value, can be updated later
        );
      }).toList();
      
      return friends;
    } catch (e) {
      print("Error searching for friends: $e");
      return [];
    }
  }

  // Fetch the number of upcoming events for a specific friend
  Future<int> getUpcomingEventsCount(String friendId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')  // Assuming events are stored in the 'events' collection
          .where('friendId', isEqualTo: friendId)
          .where('eventDate', isGreaterThan: Timestamp.now())  // Only future events
          .get();

      return snapshot.docs.length;  // Return the count of upcoming events
    } catch (e) {
      print("Error fetching upcoming events count: $e");
      return 0;  // Return 0 if there was an error
    }
  }

  // Get a user by phone number
  Future<user?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;  // Return null if no user is found
      } else {
        // Return user data
        var userData = snapshot.docs.first;
        return user.fromJson(userData.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user by phone number: $e");
      return null;  // Return null if there was an error
    }
  }

  // Hash password using SHA256 (for secure storage)
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var hash = sha256.convert(bytes);  // Hash using SHA256
    return hash.toString();  // Return the hash as a string
  }
   // Get current logged-in user from Firebase
Future<user?> getCurrentUser() async {
  User? firebaseUser = _auth.currentUser;
  
  if (firebaseUser == null) {
    print("Firebase auth: No current user logged in.");
    return null;
  }

  try {
    DocumentSnapshot userData = await _firestore.collection('users').doc(firebaseUser.uid).get();
    
    if (!userData.exists) {
      print("Firestore: No user data found for user ID ${firebaseUser.uid}");
      return null;
    }

    print("Fetched user data: ${userData.data()}");
    return user.fromMap(userData.data() as Map<String, dynamic>);
  } catch (e) {
    print("Failed to fetch user data: $e");
    return null;
  }
}


}
