import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'package:hediaty/controllers/event_controller.dart';
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
  bool _isSearching = false;

  // Search logic
  List<Friend> _filterFriends(String query, List<Friend> allFriends) {
    if (query.isEmpty) {
      return allFriends;
    }
    return allFriends
        .where((friend) =>
            friend.friendName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Friends",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {}); // Trigger UI update on search
                },
              )
            : Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
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

          return Column(
            children: [
              _buildTopSection(currentUser),
              Expanded(
                child: StreamBuilder<List<Friend>>(
                  stream: homeController.getFriendsStream(currentUser.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: primaryColor));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                        "Error loading friends: ${snapshot.error}",
                        style: TextStyle(color: Colors.red),
                      ));
                    }
                    final allFriends = snapshot.data ?? [];
                    final filteredFriends =
                        _filterFriends(_searchController.text, allFriends);

                    return _buildFriendsList(filteredFriends);
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

  Widget _buildTopSection(user currentUser) {
    final eventController = Provider.of<EventController>(context, listen: false);

    return StreamBuilder<int>(
      stream: eventController.getEventCountStream(currentUser.id),
      builder: (context, snapshot) {
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
                    snapshot.connectionState == ConnectionState.waiting
                        ? Text("Loading events...",
                            style: TextStyle(color: textColor))
                        : snapshot.hasError
                            ? Text("Error loading events",
                                style: TextStyle(color: textColor))
                            : Text(
                                "You have ${snapshot.data ?? 0} events",
                                style:
                                    TextStyle(fontSize: 16, color: textColor),
                              ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendsList(List<Friend> friends) {
    return friends.isEmpty
        ? Center(
            child: Text(
              "No friends found",
              style: TextStyle(color: textColor),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.only(top: 0),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return StreamBuilder<int>(
                stream: Provider.of<EventController>(context, listen: false)
                    .getEventCountStream(friends[index].friendId),
                builder: (context, snapshot) {
                  final updatedFriend = friends[index];
                  updatedFriend.upcomingEventsCount =
                      snapshot.data ?? updatedFriend.upcomingEventsCount;
                  return FriendListItem(friend: updatedFriend);
                },
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
      builder: (BuildContext context) {
        return FutureBuilder<List<user>>(
          future: homeController.getPotentialFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: primaryColor));
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
