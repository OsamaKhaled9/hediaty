import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/user.dart'; // Ensure this import is correct
import 'package:hediaty/core/models/friend.dart'; // Import the Friend model
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/footer.dart';  // Assuming you have a footer widget
import 'package:hediaty/widgets/friend_list_item.dart';  // Assuming you have a friend list item widget

class HomePage extends StatelessWidget {
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
                    backgroundImage: NetworkImage(snapshot.data![index].profilePictureUrl),
                  ),
                  title: Text(snapshot.data![index].fullName),
                  onTap: () {
                    homeController.addFriend(snapshot.data![index].id);
                    Navigator.pop(context);  // Close the modal after adding friend
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Open a drawer or menu
          },
        ),
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
                    future: controller.getCurrentUser(), // Fetch current user data
                    builder: (context, snapshot) {
                      print(controller.getCurrentUser());

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator()); // Show loading indicator
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      user? currentUser = snapshot.data;
                      print(currentUser);

                      if (currentUser == null) {
                        return Center(child: Text("No user logged in"));
                      }

                      // Profile display section
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: currentUser.profilePictureUrl.isNotEmpty
                                ? AssetImage(currentUser.profilePictureUrl)
                                : AssetImage("assets/images/default_avatar.JPG") as ImageProvider, // Fallback to default image
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${currentUser.fullName}!", // Display user name
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "You have 0 upcoming events", // Placeholder for events count
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
                decoration: InputDecoration(
                  labelText: "Search Friends",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Handle search query
                },
              ),
            ),

            // Friends List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<HomeController>(
                builder: (context, controller, child) {
                  return FutureBuilder<user?>(
                    future: controller.getCurrentUser(), // Fetch current user data again
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator()); // Show loading indicator
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      user? currentUser = snapshot.data;

                      if (currentUser == null) {
                        return Center(child: Text("No user logged in"));
                      }

                      // Load Friends List
                      return FutureBuilder<List<Friend>>(
                        future: controller.loadFriends(currentUser.id), // Pass the userId
                        builder: (context, friendSnapshot) {
                          if (friendSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator()); // Show loading indicator
                          }

                          if (friendSnapshot.hasError) {
                            return Center(child: Text("Error: ${friendSnapshot.error}"));
                          }

                          List<Friend> friends = friendSnapshot.data ?? [];

                          if (friends.isEmpty) {
                            return Center(child: Text("No friends found"));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              return FriendListItem(friend: friends[index]); // Display each friend item
                            },
                          );
                        },
                      );
                    },
                  );
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

      // Footer Navigation
      bottomNavigationBar: Footer(),
    );
  }
}
