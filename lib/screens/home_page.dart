import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/core/models/friends.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friends = Provider.of<Friends>(context).friends;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty - Home'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(friend.profilePic)),
            title: Text(friend.name),
            subtitle: Text(friend.upcomingEvents > 0 ? "Upcoming Events: ${friend.upcomingEvents}" : "No Upcoming Events"),
            onTap: () {
              Navigator.pushNamed(context, '/gift_list', arguments: friend);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_event');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
