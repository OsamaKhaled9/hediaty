import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Birthday Party'),
            subtitle: Text('Status: Upcoming'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit event page
              },
            ),
          ),
          // More events here
        ],
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
