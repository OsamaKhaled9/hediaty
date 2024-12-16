import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context, listen: false);

    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Events"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Add sorting logic here
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Name", child: Text("Sort by Name")),
              PopupMenuItem(value: "Date", child: Text("Sort by Date")),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: eventController.loadEvents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          List<Event> events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(child: Text("No events found. Tap + to create one."));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text(
                  "${event.location} - ${event.date.toLocal().toString().split(' ')[0]}",
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/event_details',
                    arguments: event.id, // Pass eventId as a String
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_edit_event');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
