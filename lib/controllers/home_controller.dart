import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';

class HomeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  
  Future<user> getCurrentUser() async {
    user? currentUser = await _firebaseService.getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not found");
    }
    return currentUser;
  }

  // Fetches friends from Firestore and updates local storage
  Future<List<Friend>> loadFriends(String userId) async {
    try {
      // Fetch friends from Firestore
      List<Friend> friends = await _firebaseService.getFriends(userId);
      
      // For each friend, fetch the upcoming events count
      for (var friend in friends) {
        int count = await _firebaseService.getUpcomingEventsCount(friend.friendId);
        friend.upcomingEventsCount = count;
        
        // Update local database with friend details
        await _databaseService.insertFriend(friend);
      }
      
      return friends;
    } catch (e) {
      print("Error loading friends: $e");
      return [];
    }
  }

  // Adds a new friend by phone number
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

  
}
