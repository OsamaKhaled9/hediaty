import 'package:flutter/material.dart';
import 'package:hediaty/db/database_helper.dart';
import 'event_details_page.dart'; // For navigating to event details

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Load all events from the database
  _loadEvents() async {
    final events = await DatabaseHelper.instance.queryAllEvents();
    setState(() {
      _events = events;
    });
  }

  // Sort events based on name, category, or status
  _sortEvents(String criteria) {
    setState(() {
      _events.sort((a, b) {
        if (criteria == 'name') {
          return a['name'].compareTo(b['name']);
        } else if (criteria == 'status') {
          return a['status'].compareTo(b['status']);
        }
        return 0;
      });
    });
  }

  // Delete event
  _deleteEvent(int eventId) async {
    await DatabaseHelper.instance.deleteEvent(eventId);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create_event');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort buttons
          Row(
            children: [
              TextButton(
                onPressed: () => _sortEvents('name'),
                child: Text('Sort by Name'),
              ),
              TextButton(
                onPressed: () => _sortEvents('status'),
                child: Text('Sort by Status'),
              ),
            ],
          ),
          // Event list
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                var event = _events[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('Status: ${event['status']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(eventId: event['id']),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteEvent(event['id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
