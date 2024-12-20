import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String _sortBy = 'Name';

  String _getEventStatus(Event event) {
    final now = DateTime.now();
    final dayDifference = event.date.difference(now).inDays;

    if (dayDifference < -1) return "Past";
    if (dayDifference >= -1 && dayDifference <= 1) return "Current";
    return "Upcoming";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Upcoming":
        return Colors.amber;
      case "Current":
        return Colors.green;
      case "Past":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _sortEvents(List<Event> events) {
    if (_sortBy == 'Name') {
      events.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Date') {
      events.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortBy == 'Status') {
      events.sort((a, b) {
        final statusA = _getEventStatus(a);
        final statusB = _getEventStatus(b);

        return statusA.compareTo(statusB);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context, listen: false);
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
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
                  });
                },
                items: [
                  const DropdownMenuItem(
                    value: 'Name',
                    child: Text(
                      'Sort by Name',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'Date',
                    child: Text(
                      'Sort by Date',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'Status',
                    child: Text(
                      'Sort by Status',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.sort,
                  color: Color(0xFF2A6BFF),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: eventController.loadEvents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading events: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text(
                'No events found. Tap + to create one.',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          _sortEvents(events);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              final status = _getEventStatus(event);
              final statusColor = _getStatusColor(status);

              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    event.name,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.location} - ${DateFormat('yyyy-MM-dd').format(event.date)}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF2A6BFF),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/event_details',
                      arguments: {
                        'currentUserId': userId,
                        'eventId': event.id,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_edit_event');
        },
        backgroundColor: const Color(0xFF2A6BFF),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
