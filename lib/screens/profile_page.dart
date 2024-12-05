import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const Text('Name: John Doe'),
          ElevatedButton(
            onPressed: () {
              // Update profile
            },
            child: const Text('Update Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              // View pledged gifts
            },
            child: const Text('My Pledged Gifts'),
          ),
        ],
      ),
    );
  }
}
