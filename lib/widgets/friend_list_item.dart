import 'package:flutter/material.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/screens/event_details_page.dart';
import 'package:hediaty/controllers/home_controller.dart';
import 'package:provider/provider.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  // Show the modal with the list of events for a friend
  void _showEventModal(BuildContext context, Friend friend, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.getFriendEvents(friend.friendId), // Fetch events for the friend
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            List<Map<String, dynamic>> events = snapshot.data ?? [];
            print("Events found areeee :events");
            if (events.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No upcoming events for ${friend.friendName}.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "${friend.friendName}'s Events",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ListTile(
                          leading: Icon(Icons.event, color: Colors.blueAccent),
                          title: Text(event['eventName'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "Date: ${event['eventDate']}\nGifts: ${event['giftCount'] ?? 0}",
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsPage(eventId: event['eventId']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE6F2FF), // Light blue
            Colors.white,       // Transitioning to white
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(friend.friendAvatar),
        ),
        title: Text(
          friend.friendName,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: Color(0xFF2A6BFF),
          ),
        ),
        subtitle: Text(
          "${friend.upcomingEventsCount} upcoming events",
          style: TextStyle(
            color: Color(0xFF666666),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF2A6BFF),
          size: 20,
        ),
        onTap: () {
          _showEventModal(context, friend, homeController);
        },
      ),
    );
  }
}
