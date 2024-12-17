import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  Stream<List<Event>>? _eventStream;
  List<Event> _sortedEvents = [];
  bool _isLoading = true;
  String _sortBy = 'Name';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final eventController = Provider.of<EventController>(context, listen: false);
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      _eventStream = eventController.loadEvents(userId);
      _isLoading = true;
    });

    _eventStream!.listen((events) {
      setState(() {
        _sortedEvents = events;
        _isLoading = false;
        _sortEvents();
      });
    });
  }

  void _sortEvents() {
    setState(() {
      if (_sortBy == 'Name') {
        _sortedEvents.sort((a, b) => a.name.compareTo(b.name));
      } else {
        _sortedEvents.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Events',
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortEvents();
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'Name',
                    child: Text(
                      'Sort by Name',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Date',
                    child: Text(
                      'Sort by Date',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                dropdownColor: Colors.white,
                icon: Icon(
                  Icons.sort,
                  color: Color(0xFF2A6BFF),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _sortedEvents.isEmpty
                ? Center(
                    child: Text(
                      'No events found. Tap + to create one.',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _sortedEvents.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = _sortedEvents[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFADD8E6),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            event.name,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            '${event.location} - ${event.date.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 16,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF2A6BFF),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/event_details',
                              arguments: event.id, // Pass eventId as a String
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_edit_event');
        },
        backgroundColor: Color(0xFF2A6BFF),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}