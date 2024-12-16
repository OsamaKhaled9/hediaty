import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/screens/friend_event_gift_list.dart'; // Import the gift list page
import 'package:hediaty/controllers/home_controller.dart';
import 'package:provider/provider.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  void _showEventModal(BuildContext context, Friend friend, HomeController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.getFriendEvents(friend.friendId), // Fetch friend's events
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            List<Map<String, dynamic>> events = snapshot.data ?? [];
            if (events.isEmpty) {
              return Center(child: Text("No upcoming events for ${friend.friendName}."));
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['eventName']),
                  subtitle: Text("${event['giftCount']} gifts"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendEventGiftList(
                          eventId: event['eventId'], // Pass the event ID
                          friendId: friend.friendId, // Pass the friend ID
                        ),
                      ),
                    );
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(friend.friendAvatar),
        ),
        title: Text(
          friend.friendName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("${friend.upcomingEventsCount} upcoming events"),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          _showEventModal(context, friend, homeController);
        },
      ),
    );
  }
}
