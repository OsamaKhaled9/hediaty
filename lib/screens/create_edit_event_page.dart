import 'package:flutter/material.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hediaty/widgets/custom_button.dart';

class CreateEditEventPage extends StatefulWidget {
  final Event? event;

  const CreateEditEventPage({Key? key, this.event}) : super(key: key);

  @override
  _CreateEditEventPageState createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime date;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing event data if editing
    _nameController.text = widget.event?.name ?? '';
    _locationController.text = widget.event?.location ?? '';
    _descriptionController.text = widget.event?.description ?? '';
    date = widget.event?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final eventController = Provider.of<EventController>(context, listen: false);

      // Use the same ID for both Firestore document ID and the event's 'id' field
      final eventId = widget.event?.id ?? FirebaseFirestore.instance.collection('events').doc().id;

      final event = Event(
        id: eventId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        name: _nameController.text,
        date: date,
        location: _locationController.text,
        description: _descriptionController.text,
      );

      if (widget.event == null) {
        await eventController.createEvent(event);
      } else {
        await eventController.updateEvent(event);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? "Create Event" : "Edit Event",
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Event Name",
                  labelStyle: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFADD8E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2A6BFF)),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: IgnorePointer(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(date)
                    ),
                    decoration: InputDecoration(
                      labelText: "Date",
                      labelStyle: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFADD8E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF2A6BFF)),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF2A6BFF),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  labelStyle: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFADD8E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2A6BFF)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFADD8E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2A6BFF)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: CustomButton(
                  label: "Save",
                  onPressed: _saveEvent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}