import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = Color(0xFF2A6BFF);
  final Color backgroundColor = Color(0xFFF2F2F2);
  final Color textColor = Color(0xFF333333);

  TextEditingController _searchController = TextEditingController();
  StreamSubscription<void>? _notificationSubscription;
  bool _isSearching = false;

  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
    _initializeNotificationListener();
  }

  Future<void> _initializePage() async {
    final homeController = Provider.of<HomeController>(context, listen: false);
    try {
      var currentUser = await homeController.getCurrentUser();
      if (currentUser != null) {
        await _loadFriends(currentUser.id, homeController);
      }
    } catch (e) {
      print("Error initializing page: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

void _initializeNotificationListener() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final currentUserId = currentUser.uid;

    try {
      // Listen for new notifications and store them
      _notificationSubscription = GiftController()
          .listenForNotifications(currentUserId)
          .listen((notification) async {
        final notificationData = notification as Map<String, dynamic>;

        // Update the notifications list for the modal
        setState(() {
          _notifications.add(notificationData);
        });

        // Show the notification on the phone
        await NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
          title: notificationData['title'] ?? 'New Notification',
          body: notificationData['message'] ?? 'You have a new notification',
        );
      }, onError: (error) {
        print("Error while listening for notifications: $error");
      });
    } catch (e) {
      print("Error during notification initialization: $e");
    }
  } else {
    print("No user logged in, cannot start notification listener.");
  }
}

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _searchController.dispose();
    // Clear notifications on dispose instead of init
    _clearNotifications();
    super.dispose();
  }

  Future<void> _clearNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final notificationsRef = FirebaseFirestore.instance.collection('notifications');
      final userNotifications = await notificationsRef
          .where('recipientUserId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in userNotifications.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _loadFriends(String userId, HomeController controller) async {
    try {
      List<Friend> friends = await controller.loadFriends(userId);
      if (mounted) {
        setState(() {
          _allFriends = friends;
          _filteredFriends = friends;
        });
      }
    } catch (e) {
      print("Error loading friends: $e");
    }
  }

  // Improved search functionality with debouncing
  Timer? _debounce;
  void _filterFriends(String query, List<Friend> allFriends) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          _filteredFriends = allFriends;
        } else {
          _filteredFriends = allFriends
              .where((friend) =>
                  friend.friendName.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    });
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

                        final Timestamp? timestamp =
                            notification['timestamp'] as Timestamp?;

                        final String formattedTime = timestamp != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                                    timestamp.millisecondsSinceEpoch)
                                .toLocal()
                                .toString()
                                .substring(0, 19) // Format the timestamp
                            : 'Unknown time';

                        return ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.blue),
                          title: Text(
                            notificationBody,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            formattedTime,
                            style: const TextStyle(color: Colors.black45, fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final eventController = Provider.of<EventController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<user?>(
        future: homeController.getCurrentUser(),
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

          return FutureBuilder<List<Friend>>(
            future: homeController.loadFriends(currentUser.id),
            builder: (context, friendsSnapshot) {
              if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (friendsSnapshot.hasError) {
                return Center(child: Text("Error loading friends: ${friendsSnapshot.error}"));
              }
              
              final allFriends = friendsSnapshot.data ?? [];
              if (_filteredFriends.isEmpty) {
                _filteredFriends = allFriends;
              }

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopSection(currentUser, eventController),
                      if (_isSearching) _buildSearchBar(allFriends),
                      _buildFriendsList(allFriends),
                    ],
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isSearching ? Icons.close : Icons.search,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();
                                _filteredFriends = allFriends;
                              }
                            });
                          },
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications, color: Colors.white),
                              onPressed: () => _showNotificationsModal(context),
                            ),
                            if (_notifications.isNotEmpty)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    '${_notifications.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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

  // Keep your existing _buildTopSection, _buildFriendsList, and _showAddFriendModal methods...
  // [Previous implementations remain unchanged]

  Widget _buildTopSection(user currentUser, EventController eventController) {
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                FutureBuilder<int>(
                  future: eventController.getEventCount(currentUser.id),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text("Loading events...",
                          style: TextStyle(color: textColor));
                    }
                    if (eventSnapshot.hasError) {
                      return Text("Error loading events",
                          style: TextStyle(color: textColor));
                    }
                    final eventCount = eventSnapshot.data ?? 0;
                    return Text(
                      "You have $eventCount events",
                      style: TextStyle(fontSize: 16, color: textColor),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildSearchBar(List<Friend> allFriends) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: "Search Friends",
          labelStyle: TextStyle(color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          prefixIcon: Icon(Icons.search, color: primaryColor),
        ),
        style: TextStyle(color: textColor),
        onChanged: (query) => _filterFriends(query, allFriends),
      ),
    );
  }

  Widget _buildFriendsList(List<Friend> allFriends) {
    return Expanded(
      child: _filteredFriends.isEmpty
          ? Center(
              child: Text(
                "No friends found",
                style: TextStyle(color: textColor),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 0),
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                return FriendListItem(friend: _filteredFriends[index]);
              },
            ),
    );
  }

  void _showAddFriendModal(BuildContext context, HomeController homeController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<user>>(
          future: homeController.getPotentialFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: textColor),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                "No potential friends found",
                style: TextStyle(color: textColor),
              ));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage(snapshot.data![index].profilePictureUrl),
                  ),
                  title: Text(
                    snapshot.data![index].fullName,
                    style: TextStyle(color: textColor),
                  ),
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