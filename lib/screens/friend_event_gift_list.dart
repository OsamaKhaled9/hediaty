import 'package:flutter/material.dart';

class FriendEventGiftList extends StatelessWidget {
  final String eventId;
  final String friendId;

  const FriendEventGiftList({
    Key? key,
    required this.eventId,
    required this.friendId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gifts for Event"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Friend ID: $friendId",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Event ID: $eventId",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "This is the gift list page for the selected event.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to the previous screen
              },
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
