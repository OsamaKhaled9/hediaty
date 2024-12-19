import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'package:hediaty/screens/create_edit_event_page.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = Color(0xFF2A6BFF);
  final Color backgroundColor = Color(0xFFF2F2F2);
  final Color textColor = Color(0xFF333333);

  TextEditingController _searchController = TextEditingController();

  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
  final homeController = Provider.of<HomeController>(context, listen: false);
  print("Initializing page...");
  try {
    // Fetch current user
    var currentUser = await homeController.getCurrentUser();
    print("Current user: ${currentUser?.fullName}");

    if (currentUser != null) {
      // Load friends only if the user exists
      await _loadFriends(currentUser.id, homeController);
      print("Friends loaded successfully.");
    } else {
      print("No current user found.");
    }
  } catch (e) {
    print("Error initializing page: $e");
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false; // Stop loading
      });
      print("Page initialization complete.");
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

 
  // Search functionality
  void _filterFriends(String query, List<Friend> allFriends) {
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
  }


  /*void _showAddFriendModal(BuildContext context, HomeController homeController) {
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
                  title: Text(
                    snapshot.data![index].fullName, 
                    style: TextStyle(color: textColor)
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
*/

/*@override
Widget build(BuildContext context) {
  final homeController = Provider.of<HomeController>(context, listen: false);
  final eventController = Provider.of<EventController>(context, listen: false);
  bool _isFriendsLoaded = false; // Add a state variable

  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section with Gradient Background
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              AppBar(
                title: Text(
                  "Home",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),

              // User Profile Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<HomeController>(
                  builder: (context, controller, child) {
                    return FutureBuilder<user?>(
                      future: controller.getCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: primaryColor));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
                      }
                      user? currentUser = snapshot.data;
                      if (currentUser == null) {
                        return Center(child: Text("No user logged in", style: TextStyle(color: textColor)));
                      }

                      // Only load friends if not already loaded
                      if (!_isFriendsLoaded) {
                        _loadFriends(currentUser.id, homeController);
                        _isFriendsLoaded = true;
                      }
                                          return Row(
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
                                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                                    return Text("Loading events...", style: TextStyle(color: textColor));
                                  }
                                  if (eventSnapshot.hasError) {
                                    return Text("Error loading events", style: TextStyle(color: textColor));
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
                      );
                      },
                    );
                  },
                ),
              ),

              // Create Event Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateEditEventPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Center(
                    child: Text(
                      "Create Your Own Event/List",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
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
            onChanged: _filterFriends,
          ),
        ),

        // Friends List
        Expanded(
  child: _filteredFriends.isEmpty
    ? Center(
        child: Text(
          "No friends found",
          style: TextStyle(color: textColor),
        ),
      )
    : ListView.builder(
        padding: EdgeInsets.only(top: 0), // Remove top padding
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          return FriendListItem(friend: _filteredFriends[index]);
        },
      ),
)
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showAddFriendModal(context, homeController),
      backgroundColor: primaryColor,
      child: Icon(Icons.add, color: Colors.white),
    ),
    bottomNavigationBar: Footer(),
  );
}*/
 /* @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final eventController = Provider.of<EventController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section with Gradient Background
                Container(
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
                    child: FutureBuilder<user?>(
                      future: homeController.getCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error: ${snapshot.error}",
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }
                        user? currentUser = snapshot.data;
                        if (currentUser == null) {
                          return Center(
                            child: Text(
                              "No user logged in",
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }

                        return Row(
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
                                    if (eventSnapshot.connectionState == ConnectionState.waiting) {
                                      return Text("Loading events...", style: TextStyle(color: textColor));
                                    }
                                    if (eventSnapshot.hasError) {
                                      return Text("Error loading events", style: TextStyle(color: textColor));
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
                        );
                      },
                    ),
                  ),
                ),

                // Search Bar
                Padding(
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
                    onChanged: _filterFriends,
                  ),
                ),

                // Friends List
                Expanded(
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendModal(context, homeController),
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Footer(),
    );
  }*/

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
            return Center(
                child: Text(
              "Error: ${userSnapshot.error}",
              style: TextStyle(color: Colors.red),
            ));
          }
          final currentUser = userSnapshot.data;

          if (currentUser == null) {
            return Center(
                child: Text(
              "No user logged in.",
              style: TextStyle(color: textColor),
            ));
          }

          return FutureBuilder<List<Friend>>(
            future: homeController.loadFriends(currentUser.id),
            builder: (context, friendsSnapshot) {
              if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: primaryColor));
              }
              if (friendsSnapshot.hasError) {
                return Center(
                    child: Text(
                  "Error loading friends: ${friendsSnapshot.error}",
                  style: TextStyle(color: Colors.red),
                ));
              }
              final allFriends = friendsSnapshot.data ?? [];
              if (_filteredFriends.isEmpty) {
                _filteredFriends = allFriends;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(currentUser, eventController),
                  _buildSearchBar(allFriends),
                  _buildFriendsList(allFriends),
                  // ---------------- TEST BUTTON START ----------------
               Padding(
  padding: const EdgeInsets.all(16.0),
  child: ElevatedButton(
    onPressed: () async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("Error: No logged-in user.");
        return;
      }

      // Retrieve user details (assuming a `getUserById` method exists in UserController)
      final userController = Provider.of<UserController>(context, listen: false);
      final currentUser = await userController.getUserById(userId);

      if (currentUser?.isNotificationsEnabled == true) {
        // Trigger a test notification
        await NotificationService().showNotification(
          id: 1,
          title: "Test Notification",
          body: "This is a test notification.",
          payload: "test_payload",
        );
        print("Test notification sent!");
      } else {
        print("Notifications are disabled for the user.");
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
    ),
    child: Text("Send Test Notification"),
  ),
),

                // ---------------- TEST BUTTON END ----------------
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