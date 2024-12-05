import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Birthday Party'),
            subtitle: const Text('Status: Upcoming'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
