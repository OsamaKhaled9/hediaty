import 'package:flutter/material.dart';
import 'event_list_page.dart'; // Navigate to Event List Page
import 'gift_list_page.dart'; // Navigate to Gift List Page

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile info
            Text('Name: John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Email: johndoe@example.com', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            // Buttons for events and gifts
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListPage()),
                );
              },
              child: Text('My Events'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GiftListPage(eventId: 1)),
                );
              },
              child: Text('My Gifts'),
            ),
          ],
        ),
      ),
    );
  }
}
