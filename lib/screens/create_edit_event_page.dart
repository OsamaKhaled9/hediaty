import 'package:flutter/material.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEditEventPage extends StatefulWidget {
  final Event? event;

  const CreateEditEventPage({Key? key, this.event}) : super(key: key);

  @override
  _CreateEditEventPageState createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late DateTime date;
  late String location;
  late String description;

  @override
  void initState() {
    super.initState();
    name = widget.event?.name ?? '';
    date = widget.event?.date ?? DateTime.now();
    location = widget.event?.location ?? '';
    description = widget.event?.description ?? '';
  }

  void _saveEvent() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final eventController = Provider.of<EventController>(context, listen: false);

    // Use the same ID for both Firestore document ID and the event's 'id' field
    final eventId = widget.event?.id ?? FirebaseFirestore.instance.collection('events').doc().id;

    final event = Event(
      id: eventId, // Set the Firestore document ID here
      userId: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      date: date,
      location: location,
      description: description,
    );

    if (widget.event == null) {
      await eventController.createEvent(event);
    } else {
      await eventController.updateEvent(event);
    }

    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? "Create Event" : "Edit Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Event Name"),
                onSaved: (value) => name = value!,
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                initialValue: location,
                decoration: InputDecoration(labelText: "Location"),
                onSaved: (value) => location = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: "Description"),
                onSaved: (value) => description = value!,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
