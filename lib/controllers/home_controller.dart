import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class HomeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  Future<user?> getCurrentUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userSnapshot.exists) {
        return null;
      }

      // Convert Firestore data to user model
      user currentUser =
          user.fromFirebaseUser(firebaseUser, userSnapshot.data() as Map<String, dynamic>);

      // Sync with local database
      await _databaseService.insertUser(currentUser);

      return currentUser;
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }

  // Fetch friends and sync to local database
  Future<List<Friend>> loadFriends(String userId) async {
    try {
      // Fetch friends from Firestore
      List<Friend> friends = await _firebaseService.getFriends(userId);

      // Update upcoming events count and sync to local database
      for (var friend in friends) {
        int count = await _firebaseService.getUpcomingEventsCount(friend.friendId);
        friend.upcomingEventsCount = count;
        await _databaseService.insertFriend(friend);
      }

      return friends;
    } catch (e) {
      print("Error loading friends: $e");
      return [];
    }
  }

  // Add a friend and synchronize with local database
  Future<void> addFriend(String friendId) async {
    try {
      if (friendId.isEmpty) {
        throw ArgumentError("Friend ID must not be empty.");
      }

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No current user logged in.");
      }

      // Fetch friend data
      DocumentSnapshot friendSnapshot =
          await _firestore.collection('users').doc(friendId).get();

      if (!friendSnapshot.exists) {
        throw Exception("Friend not found.");
      }

      Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>;

      // Fetch current user data
      DocumentSnapshot currentUserSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!currentUserSnapshot.exists) {
        throw Exception("Current user data not found.");
      }

      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      var uuid = Uuid();

      // Create Friend objects for mutual friendship
      Friend newFriend = Friend(
        id: uuid.v4(),
        userId: currentUser.uid,
        friendId: friendId,
        friendName: friendData['fullName'] ?? 'Unknown',
        friendAvatar: friendData['profilePictureUrl'] ?? 'assets/images/default_avatar.JPG',
        upcomingEventsCount: 0,
      );

      Friend reciprocalFriend = Friend(
        id: uuid.v4(),
        userId: friendId,
        friendId: currentUser.uid,
        friendName: currentUserData['fullName'] ?? 'Unknown',
        friendAvatar: currentUserData['profilePictureUrl'] ?? 'assets/images/default_avatar.JPG',
        upcomingEventsCount: 0,
      );

      // Add to Firestore and local database
      await _firebaseService.addFriendToFirestore(newFriend);
      await _firebaseService.addFriendToFirestore(reciprocalFriend);
      await _databaseService.insertFriend(newFriend);
      await _databaseService.insertFriend(reciprocalFriend);

      // Refresh friend list
      await loadFriends(currentUser.uid);
    } catch (e) {
      print("Error adding friend: $e");
    }
  }

  // Search friends based on a query
  Future<List<Friend>> searchFriends(String query) async {
    try {
      List<Friend> friends = await _firebaseService.searchFriends(query);
      return friends;
    } catch (e) {
      print("Error searching friends: $e");
      return [];
    }
  }

  // Get potential friends
  Future<List<user>> getPotentialFriends() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      List<user> allUsers = usersSnapshot.docs
          .map((doc) => user.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      Set<String> friendIds =
          (await loadFriends(currentUser.uid)).map((f) => f.friendId).toSet();
      friendIds.add(currentUser.uid);

      return allUsers.where((u) => !friendIds.contains(u.id)).toList();
    } catch (e) {
      print("Error fetching potential friends: $e");
      return [];
    }
  }

  // Fetch friend's events
  Future<List<Map<String, dynamic>>> getFriendEvents(String friendId) async {
    try {
      List<Map<String, dynamic>> events = await _firebaseService.getFriendEvents(friendId);
      return events;
    } catch (e) {
      print("Error fetching friend's events: $e");
      return [];
    }
  }

  // Navigate to friend's gift list
  void navigateToGiftList(BuildContext context, Friend friend) {
    Navigator.pushNamed(
      context,
      '/giftList',
      arguments: friend,
    );
  }
  Stream<List<Friend>> getFriendsStream(String userId) {
  try {
    // Use Firestore to listen for real-time updates on the "friends" collection
    return FirebaseFirestore.instance
        .collection('friends') // Replace with your actual Firestore collection
        .where('userId', isEqualTo: userId) // Filter by userId
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Friend.fromFirestore(doc)) // Convert Firestore data to Friend model
            .toList());
  } catch (e) {
    print("Error fetching friends stream: $e");
    return Stream.value([]); // Return an empty list on error
  }
}

}
