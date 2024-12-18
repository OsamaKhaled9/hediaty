import 'package:flutter/material.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:provider/provider.dart';

class SearchFriendsWidget extends StatefulWidget {
  const SearchFriendsWidget({Key? key}) : super(key: key);

  @override
  _SearchFriendsWidgetState createState() => _SearchFriendsWidgetState();
}

class _SearchFriendsWidgetState extends State<SearchFriendsWidget> {
  List<Friend> _allFriends = []; // Complete list of friends
  List<Friend> _filteredFriends = []; // Filtered list based on search query
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  bool _isLoadingFriends = false; // Add a state variable to track loading

Future<void> _loadFriends() async {
  // Avoid redundant calls
  if (_isLoadingFriends) return;

  final homeController = Provider.of<HomeController>(context, listen: false);
  setState(() {
    _isLoadingFriends = true; // Indicate that loading is in progress
  });

  try {
    var currentUser = await homeController.getCurrentUser();

    if (currentUser != null) {
      List<Friend> friends = await homeController.loadFriends(currentUser.id);

      // Ensure state update happens only if the widget is still mounted
      if (mounted) {
        setState(() {
          _allFriends = friends;
          _filteredFriends = friends; // Initially show all friends
          _isLoadingFriends = false; // Mark loading as completed
        });
      }
    } else {
      print("No current user found.");
    }
  } catch (e) {
    print("Error loading friends: $e");
    if (mounted) {
      setState(() {
        _isLoadingFriends = false; // Mark loading as completed even on error
      });
    }
  }
}


  void _filterFriends(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filteredFriends = _allFriends; // Show all friends if query is empty
      } else {
        _filteredFriends = _allFriends
            .where((friend) =>
                friend.friendName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Search Friends",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterFriends,
          ),
        ),
        _filteredFriends.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _query.isEmpty
                        ? "No friends to display."
                        : "No matching friends found.",
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = _filteredFriends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend.friendAvatar),
                    ),
                    title: Text(friend.friendName),
                  );
                },
              ),
      ],
    );
  }
}
