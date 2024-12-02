import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          Text('Name: John Doe'),
          ElevatedButton(
            onPressed: () {
              // Update profile
            },
            child: Text('Update Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              // View pledged gifts
            },
            child: Text('My Pledged Gifts'),
          ),
        ],
      ),
    );
  }
}
