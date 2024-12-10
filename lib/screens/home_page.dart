import 'package:flutter/material.dart';
import 'package:hediaty/utils/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredFriendsList = []; // Replace with actual data source

  // Simulated friend list for demonstration
  final List<Map<String, dynamic>> friendsList = [
    {
      "id": 1,
      "name": "John Doe",
      "profilePictureUrl": "https://via.placeholder.com/150",
      "events": ["Birthday", "Anniversary"]
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "profilePictureUrl": "https://via.placeholder.com/150",
      "events": []
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredFriendsList = friendsList;
  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriendsList = friendsList
          .where((friend) => friend["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addFriend() {
    // Logic to add a friend
  }

  void _navigateToFriendGiftList(int friendId) {
    Navigator.pushNamed(context, '/event_list', arguments: friendId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFriend,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterFriends,
                decoration: InputDecoration(
                  hintText: "Search for friends...",
                  prefixIcon: const Icon(Icons.search, color: lightGray),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Button to create event or gift list
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_event_list');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Center(
                child: Text(
                  "Create Your Own Event/List",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Friends list
            Expanded(
              child: ListView.builder(
                itemCount: filteredFriendsList.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriendsList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend["profilePictureUrl"]),
                      ),
                      title: Text(
                        friend["name"],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGray),
                      ),
                      subtitle: Text(
                        friend["events"].isNotEmpty
                            ? "Upcoming Events: ${friend["events"].length}"
                            : "No Upcoming Events",
                        style: const TextStyle(fontSize: 14, color: lightGray),
                      ),
                      onTap: () => _navigateToFriendGiftList(friend["id"]),
                      trailing: Icon(Icons.chevron_right, color: lightGray),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
