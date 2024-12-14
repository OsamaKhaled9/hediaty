import 'package:flutter/material.dart';
import 'package:hediaty/db/database_helper.dart';

class EventDetailsPage extends StatefulWidget {
  final int eventId;
  const EventDetailsPage({super.key, required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _status = 'Upcoming';

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  // Load event details from database
  _loadEventDetails() async {
    final event = await DatabaseHelper.instance.queryEventById(widget.eventId);
    setState(() {
      _nameController.text = event['name'];
      _descriptionController.text = event['description'];
      _locationController.text = event['location'];
      _status = event['status'];
    });
  }

  // Save changes to event
  _saveEvent() async {
    final updatedEvent = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'status': _status,
    };
    await DatabaseHelper.instance.updateEvent(widget.eventId, updatedEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            DropdownButton<String>(
              value: _status,
              onChanged: (newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: ['Upcoming', 'Current', 'Past']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: _saveEvent,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
