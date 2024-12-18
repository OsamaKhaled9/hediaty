import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/core/models/user.dart';  // Import your user model
import 'package:crypto/crypto.dart';  // For hashing the password
import 'dart:convert';  // For UTF-8 encoding
import 'package:hediaty/core/models/friend.dart';  // Import friend model
import 'package:hediaty/core/models/event.dart';  // Import event model
import 'package:hediaty/core/models/gift.dart';  
//import 'package:hediaty/controllers/home_controller.dart';
import 'package:uuid/uuid.dart';

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
        'id': user.id,  // Explicitly store the user ID within the document
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
 /* Future<List<Friend>> getFriends(String userId) async {
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
  }*/
Future<List<Friend>> getFriends(String userId) async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('friends')
        .where('userId', isEqualTo: userId)
        .get();
    List<Friend> friends = snapshot.docs.map((doc) {
      try {
        return Friend.fromJson(doc.data() as Map<String, dynamic>);
      } catch (e) {
        print("Error processing document ${doc.id}: $e");
        return null; // Return null if there's an error
      }
    }).where((friend) => friend != null).cast<Friend>().toList(); // Filter out nulls
    return friends;
  } catch (e) {
    print("Error fetching friends: $e");
    return [];
  }
}






/*Future<void> addFriendToFirestore(Friend friend) async {
  var uuid = Uuid();
  String friendId = uuid.v4();  // Ensuring the ID is never empty
  print("Adding friend at path: users/${friend.userId}/friends/$friendId");

  try {
    await _firestore.collection('users').doc(friend.userId)
      .collection('friends').doc(friendId).set(friend.toJson());

    // Assuming friendId and userId are properly set
  } catch (e) {
    print("Error adding friend: $e");
    throw Exception("Error adding friend: $e");
  }
}*/

Future<void> addFriendToFirestore(Friend friend) async {
  if (friend.userId.isEmpty || friend.friendId.isEmpty) {
  throw ArgumentError("User ID and Friend ID must not be empty.");
}
  try {
    var uuid = Uuid();
    String friendshipId = uuid.v4();  // Unique ID for the friendship document
    print(friendshipId);
    await _firestore.collection('friends').doc(friendshipId).set({
      'userId': friend.userId,
      'friendId': friend.friendId,
      'friendName': friend.friendName,
      'friendAvatar': friend.friendAvatar,
      'upcomingEventsCount': friend.upcomingEventsCount,
    });

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
            try {
                return Friend.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
                print("Error processing friend data for document ${doc.id}: $e");
                return null; // Returning null for this document and filtering out later
            }
            }).where((friend) => friend != null).cast<Friend>().toList(); // Filter out nulls

      /*List<Friend> friends = snapshot.docs.map((doc) {
        return Friend(
          id: doc.id, // Use Firestore document ID as unique friend ID
          userId: doc['id'],
          friendId: doc['id'],  // Assuming this will be the friend to add
          friendName: doc['fullName'],
          friendAvatar: doc['profilePictureUrl'],
          upcomingEventsCount: 0,  // Default value, can be updated later
        );
      }).toList();*/
      
      return friends;
    } catch (e) {
      print("Error searching for friends: $e");
      return [];
    }
  }

Future<int> getUpcomingEventsCount(String friendId) async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: friendId) // Filter by friendId
        .get();

    final now = DateTime.now();

    // Count only events with future dates
    int upcomingEventsCount = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime eventDate = DateTime.parse(data['date']);
      return eventDate.isAfter(now);
    }).length;

    return upcomingEventsCount;
  } catch (e) {
    print("Error fetching upcoming events count: $e");
    return 0;
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

    Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
    
    // Validate the data before mapping
    if (data.isEmpty || !data.containsKey('id')) {
      print("Invalid user data: $data");
      return null;
    }

    return user.fromMap(data);
  } catch (e) {
    print("Failed to fetch user data: $e");
    return null;
  }
}

  Future<List<Map<String, dynamic>>> getFriendEvents(String friendId) async {
    try {
      // Query the `events` collection for the given friend ID
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('events') // Assume the collection name is 'events'
          .where('friendId', isEqualTo: friendId)
          .get();

      // Map each document to a Map containing event details and gift count
      List<Map<String, dynamic>> events = [];

      for (var doc in eventsSnapshot.docs) {
        String eventId = doc.id; // Event ID
        String eventName = doc['eventName'] ?? 'Unnamed Event';

        // Fetch the count of gifts associated with this event
        QuerySnapshot giftsSnapshot = await _firestore
            .collection('gifts') // Assume the collection name is 'gifts'
            .where('eventId', isEqualTo: eventId)
            .get();

        events.add({
          'eventId': eventId,
          'eventName': eventName,
          'giftCount': giftsSnapshot.size, // Number of gifts
        });
      }

      return events;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
     Future<user?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print("User not found.");
        return null;
      }
      return user.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<void> updateUser(user updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
    } catch (e) {
      print("Error updating user: $e");
    }
  }
  FirebaseFirestore getFirestoreInstance() {
  return _firestore;
}
Future<Event?> getEventDetails(String eventId) async {
  try {
    DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventId).get();

    if (!eventDoc.exists) {
      print("Event not found for ID: $eventId");
      return null;
    }

    return Event.fromMap(eventDoc.data() as Map<String, dynamic>, eventDoc.id);
  } catch (e) {
    print("Error fetching event details: $e");
    return null;
  }
}

Future<List<Gift>> getEventGifts(String eventId) async {
  try {
    QuerySnapshot giftSnapshot = await _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    return giftSnapshot.docs.map((doc) {
      return Gift.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  } catch (e) {
    print("Error fetching event gifts: $e");
    return [];
  }
}
Future<void> createGift(Gift gift) async {
  try {
    await _firestore.collection('gifts').doc(gift.id).set(gift.toJson());
    print("Gift created successfully: ${gift.id}");
  } catch (e) {
    print("Error creating gift: $e");
    throw Exception("Error creating gift: $e");
  }
}


Stream<List<Gift>> getGiftsByEvent(String eventId) {
  return _firestore
      .collection('gifts')
      .where('eventId', isEqualTo: eventId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Gift.fromMap(doc.data())).toList());
}

Future<void> updateGiftStatus(String giftId, String status, String? pledgerId) async {
  await _firestore.collection('gifts').doc(giftId).update({
    'status': status,
    'pledgedBy': pledgerId,
  });
}

Future<void> deleteGift(String giftId) async {
  await _firestore.collection('gifts').doc(giftId).delete();
}

Stream<List<Gift>> getGiftsByPledger(String userId) {
  return _firestore
      .collection('gifts')
      .where('pledgedBy', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Gift.fromMap(doc.data())).toList());
}
Future<Gift?> getGiftById(String giftId) async {
  try {
    DocumentSnapshot doc = await _firestore.collection('gifts').doc(giftId).get();
    if (doc.exists) {
      return Gift.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    print("Error fetching gift by ID: $e");
    return null;
  }
}

}
