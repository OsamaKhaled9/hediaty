import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';
import 'package:hediaty/widgets/friend_list_item.dart';
import 'package:hediaty/widgets/search_friends.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<Friend> _allFriends = []; // Holds all friends
  List<Friend> _filteredFriends = []; // Holds filtered friends for display

  void _showAddFriendModal(BuildContext context, HomeController homeController) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<user>>(
          future: homeController.getPotentialFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No potential friends found"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(snapshot.data![index].profilePictureUrl),
                  ),
                  title: Text(snapshot.data![index].fullName),
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
        _filteredFriends = friends; // Initialize with all friends
      });
    } catch (e) {
      print("Error loading friends: $e");
    }
  }

   @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<HomeController>(
                builder: (context, controller, child) {
                  return FutureBuilder<user?>(
                    future: controller.getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      user? currentUser = snapshot.data;
                      if (currentUser == null) {
                        return Center(child: Text("No user logged in"));
                      }

                      // Load friends when user is available
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
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "You have ${currentUser.fullName} upcoming events",
                                style: TextStyle(fontSize: 16),
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Friends",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterFriends, // Update list as user types
              ),
            ),

            // Friends List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _filteredFriends.isEmpty
                  ? Center(
                      child: Text("No friends found"),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        return FriendListItem(friend: _filteredFriends[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendModal(context, homeController),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
}