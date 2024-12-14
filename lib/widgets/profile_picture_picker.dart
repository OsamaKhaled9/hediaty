import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  final Function(String) onAvatarSelected;

  AvatarPicker({super.key, required this.onAvatarSelected});

  // List of asset paths for avatars
  final List<String> avatarPaths = [
    'assets/profile_pics/avatar1.png',
    'assets/profile_pics/avatar2.png',
    'assets/profile_pics/avatar3.png',
    'assets/profile_pics/avatar4.png',
    'assets/profile_pics/avatar5.png',
    'assets/profile_pics/avatar6.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: avatarPaths.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(avatarPaths[index]),
            ),
            title: Text('Avatar ${index + 1}'),
            onTap: () {
              // Pass the selected avatar path back to the parent widget
              onAvatarSelected(avatarPaths[index]);
            },
          );
        },
      ),
    );
  }
}
