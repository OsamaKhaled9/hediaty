import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
String newId = uuid.v4();  // Generate a version 4 UUID

class HomeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  /*Future<user> getCurrentUser() async {
    user? currentUser = await _firebaseService.getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not found");
    }
    return currentUser;
  }*/
      Future<user?> getCurrentUser() async {
        User? firebaseUser = _auth.currentUser;

        if (firebaseUser == null) {
            return null; // No user logged in
        }

        try {
            DocumentSnapshot userData = await _firestore.collection('users').doc(firebaseUser.uid).get();
            
            if (!userData.exists) {
                return null; // User data not found in Firestore
            }

            // Convert DocumentSnapshot to your custom user model
            return user.fromFirebaseUser(firebaseUser, userData.data() as Map<String, dynamic>);
        } catch (e) {
            print("Failed to fetch user data: $e");
            return null;
        }
    }

  // Fetches friends from Firestore and updates local storage
  Future<List<Friend>> loadFriends(String userId) async {
    try {
      // Fetch friends from Firestore
      List<Friend> friends = await _firebaseService.getFriends(userId);
      print("Is there friends ?: $friends");
      // For each friend, fetch the upcoming events count
      for (var friend in friends) {
        int count = await _firebaseService.getUpcomingEventsCount(friend.friendId);
        friend.upcomingEventsCount = count;
        
        // Update local database with friend details
       // await _databaseService.insertFriend(friend);
      }
      
      return friends;
    } catch (e) {
      print("Error loading friends: $e");
      return [];
    }
  }

  /*// Adds a new friend by phone number
  Future<void> addFriend(String phoneNumber) async {
    try {
      // 1. Check if the user exists by phone number
      var user = await _firebaseService.getUserByPhoneNumber(phoneNumber);

      if (user == null) {
        // If user does not exist, handle this case (show error message)
        throw Exception("User not found.");
      }

      // 2. Create a friend object
      Friend newFriend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID generation
        userId: user.id,
        friendId: user.id, // The user that is being added
        friendName: user.fullName,
        friendAvatar: user.profilePictureUrl, // Assuming this is in the user object
        upcomingEventsCount: 0, // Default value, can be updated later
      );

      // 3. Add to Firestore (both ways for mutual friendship)
      await _firebaseService.addFriendToFirestore(newFriend);

      // 4. Update local database with the new friend
      await _databaseService.insertFriend(newFriend);

      // 5. Optionally update friends list
      loadFriends(user.id);
    } catch (e) {
      print("Error adding friend: $e");
    }
  }*/

  Future<void> addFriend(String friendId) async {
  if (friendId.isEmpty) {
    print("Friend ID cannot be empty.");
    throw ArgumentError("Friend ID must not be empty.");
  }

  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user logged in.");
      throw Exception("No current user logged in.");
    }

    DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
    if (!friendSnapshot.exists) {
      print("Friend not found.");
      throw Exception("Friend not found.");
    }

    Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>;
    if (friendData == null) {
      print("Friend data is null.");
      throw Exception("Friend data is not available.");
    }

    var uuid = Uuid();
    Friend newFriend = Friend(
      id: uuid.v4(),
      userId: currentUser.uid,
      friendId: friendId,
      friendName: friendData['fullName'] as String? ?? 'Unknown',
      friendAvatar: friendData['profilePictureUrl'] as String? ?? 'assets/images/default_avatar.png',
      upcomingEventsCount: 0,
    );

    Friend reciprocalFriend = Friend(
      id: uuid.v4(),
      userId: friendId,
      friendId: currentUser.uid,
      friendName: currentUser.displayName ?? 'Unknown',
      friendAvatar: currentUser.photoURL ?? 'assets/images/default_avatar.png',
      upcomingEventsCount: 0,
    );

    // Add to Firestore for both users
    await _firebaseService.addFriendToFirestore(newFriend);
    await _firebaseService.addFriendToFirestore(reciprocalFriend);

    // Optionally update local database and refresh friend list
   /* await _databaseService.insertFriend(newFriend);
    await _databaseService.insertFriend(reciprocalFriend);*/
    print("currentUser.uid");
    await loadFriends(currentUser.uid);
  } catch (e) {
    print("Error adding friend: $e");
    throw Exception("Error adding friend: $e");
  }
}



  // Search friends based on query (e.g., name or phone number)
  Future<List<Friend>> searchFriends(String query) async {
    try {
      // Fetch matching friends from Firestore based on query
      List<Friend> friends = await _firebaseService.searchFriends(query);
      return friends;
    } catch (e) {
      print("Error searching friends: $e");
      return [];
    }
  }

  // Navigate to a friend's gift list page
  void navigateToGiftList(BuildContext context, Friend friend) {
    Navigator.pushNamed(
      context, 
      '/giftList', 
      arguments: friend,
    );
  }
  
  Future<List<user>> getPotentialFriends() async {
  User? currentUser = _auth.currentUser;
  if (currentUser == null) {
    return []; // Return empty if no user is logged in
  }

  try {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    List<user> allUsers = usersSnapshot.docs
      .map((doc) => user.fromMap(doc.data() as Map<String, dynamic>))
      .toList();

    Set<String> friendIds = (await loadFriends(currentUser.uid)).map((f) => f.friendId).toSet();
    friendIds.add(currentUser.uid); // Include current user's ID to exclude from potential friends

    return allUsers.where((u) => !friendIds.contains(u.id)).toList();
  } catch (e) {
    print("Failed to fetch potential friends: $e");
    return [];
  }
}

  
}
