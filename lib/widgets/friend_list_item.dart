import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(friend.friendAvatar), // Show the friend's avatar
        ),
        title: Text(
          friend.friendName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("${friend.upcomingEventsCount} upcoming events"), // Display the event count
        trailing: Icon(Icons.arrow_forward_ios), // You can modify this to navigate to friend's profile or actions
        onTap: () {
          // Navigation or any action you want to add, for now just log
          print("Tapped on ${friend.friendName}");
        },
      ),
    );
  }
}
