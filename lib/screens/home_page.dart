import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'package:hediaty/screens/create_edit_event_page.dart';
import 'package:hediaty/controllers/event_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Color Palette
  final Color primaryColor = Color(0xFF2A6BFF);
  final Color backgroundColor = Color(0xFFF2F2F2);
  final Color accentColor = Color(0xFFFFD700);
  final Color textColor = Color(0xFF333333);
  final Color lightBlueColor = Color(0xFFADD8E6);

  TextEditingController _searchController = TextEditingController();
  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];

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

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends
            .where((friend) =>
                friend.friendName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _loadFriends(String userId, HomeController controller) async {
    try {
      List<Friend> friends = await controller.loadFriends(userId);
      setState(() {
        _allFriends = friends;
        _filteredFriends = friends;
      });
    } catch (e) {
      print("Error loading friends: $e");
    }
  }

@override
Widget build(BuildContext context) {
  final homeController = Provider.of<HomeController>(context, listen: false);
  final eventController = Provider.of<EventController>(context, listen: false);
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

                    if (_allFriends.isEmpty) {
                      _loadFriends(currentUser.id, homeController);
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
                             // Event Count
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
}
}