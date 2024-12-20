import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/services/notification_service.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = Color(0xFF2A6BFF);
  final Color backgroundColor = Color(0xFFF2F2F2);
  final Color textColor = Color(0xFF333333);

  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
   StreamSubscription? _notificationSubscription;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotificationListener();
  }

 void _initializeNotificationListener() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final currentUserId = currentUser.uid;

    try {
      // Listen to Firestore for real-time updates
      _notificationSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientUserId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'notificationBody': data['notificationBody'],
              'timestamp': (data['timestamp'] as Timestamp).toDate(),
            };
          }).toList();
        });
      }, onError: (error) {
        print("Error listening for notifications from Firestore: $error");
      });

      // Listen for new notifications via GiftController
      GiftController()
          .listenForNotifications(currentUserId)
          .listen((notification) async {
        final notificationData = notification as Map<String, dynamic>;

        // Show the notification on the phone
        await NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
          title: notificationData['title'] ?? 'New Notification',
          body: notificationData['notificationBody'] ?? 'You have a new notification',
        );

        // Add the notification to Firestore
        await FirebaseFirestore.instance.collection('notifications').add({
          'recipientUserId': currentUserId,
          'notificationBody': notificationData['notificationBody'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }, onError: (error) {
        print("Error listening for notifications via GiftController: $error");
      });
    } catch (e) {
      print("Error initializing notification listener: $e");
    }
  } else {
    print("No user logged in, cannot start notification listener.");
  }
}


  Stream<user?> _getCurrentUserStream(HomeController homeController) async* {
    yield await homeController.getCurrentUser();
  }

  Stream<List<Friend>> _getFriendsStream(HomeController homeController, String userId) {
    return homeController.getFriendsStream(userId);
  }

Stream<int> _getEventCountStream(EventController eventController, String friendId) {
  return eventController.getEventCountStream(friendId);
}

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final eventController = Provider.of<EventController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: !_isSearching
            ? const Text("Home", style: TextStyle(color: Colors.white))
            : TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Friends",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (_) {
                  setState(() {}); // Rebuild the UI to filter friends
                },
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Logic for showing notifications modal
              _showNotificationsModal(context);
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<user?>(
        stream: _getCurrentUserStream(homeController),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (userSnapshot.hasError) {
            return Center(child: Text("Error: ${userSnapshot.error}"));
          }

          final currentUser = userSnapshot.data;
          if (currentUser == null) {
            return Center(child: Text("No user logged in."));
          }

          return Column(
            children: [
              StreamBuilder<int>(
                stream: _getEventCountStream(eventController, currentUser.id),
                builder: (context, eventSnapshot) {
                  final eventCount = eventSnapshot.data ?? 0;
                  return _buildTopSection(currentUser, eventCount);
                },
              ),
              Expanded(
                child: StreamBuilder<List<Friend>>(
                  stream: _getFriendsStream(homeController, currentUser.id),
                  builder: (context, friendsSnapshot) {
                    if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: primaryColor));
                    }
                    if (friendsSnapshot.hasError) {
                      return Center(child: Text("Error loading friends: ${friendsSnapshot.error}"));
                    }

                    final friends = friendsSnapshot.data ?? [];
                    final filteredFriends = _searchController.text.isNotEmpty
                        ? friends
                            .where((friend) => friend.friendName
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase()))
                            .toList()
                        : friends;

                    return _buildFriendsList(friends, Provider.of<EventController>(context, listen: false));
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendModal(context, homeController),
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Footer(),
    );
  }

  Widget _buildTopSection(user currentUser, int eventCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.8),
            backgroundColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: currentUser.profilePictureUrl.isNotEmpty
                  ? AssetImage(currentUser.profilePictureUrl)
                  : AssetImage("assets/images/default_avatar.JPG"),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, ${currentUser.fullName}!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                ),
                SizedBox(height: 4),
                Text(
                  "You have $eventCount events",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFriendsList(List<Friend> friends, EventController eventController) {
  return friends.isEmpty
      ? Center(child: Text("No friends found", style: TextStyle(color: textColor)))
      : ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return StreamBuilder<int>(
  stream: _getEventCountStream(eventController, friends[index].friendId),
  builder: (context, snapshot) {
    final eventCount = snapshot.data ?? 0;
    final updatedFriend = Friend(
      id: friends[index].id, // Include the 'id' field
      userId: friends[index].userId, // Include the 'userId' field
      friendId: friends[index].friendId,
      friendName: friends[index].friendName,
      friendAvatar: friends[index].friendAvatar,
      upcomingEventsCount: eventCount,
    );
    return FriendListItem(friend: updatedFriend);
  },
);

          },
        );
}
void _showNotificationsModal(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) return;

  // Fetch notifications from Firestore
  final notificationsRef = FirebaseFirestore.instance.collection('notifications');
  final userNotifications = await notificationsRef
      .where('recipientUserId', isEqualTo: currentUser.uid)
      .orderBy('timestamp', descending: true)
      .get();

  final notifications = userNotifications.docs.map((doc) => doc.data()).toList();

  // Show the modal
  showModalBottomSheet(
    context: context,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final String notificationBody =
                            notification['notificationBody'] ?? 'No Details';

                        return ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.blue),
                          title: Text(
                            notificationBody,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}


  void _showAddFriendModal(BuildContext context, HomeController homeController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<user>>(
          future: homeController.getPotentialFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No potential friends found", style: TextStyle(color: textColor)));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(snapshot.data![index].profilePictureUrl),
                  ),
                  title: Text(snapshot.data![index].fullName, style: TextStyle(color: textColor)),
                  onTap: () {
                    homeController.addFriend(snapshot.data![index].id);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
