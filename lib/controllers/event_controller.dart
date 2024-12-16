import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier


class EventController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all events for a specific user
 Stream<List<Event>> loadEvents(String userId) {
  return _firestore
      .collection('events')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          // Pass both map and fallback id (Firestore doc.id)
          return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
}


  // Create a new event
  Future<void> createEvent(Event event) async {
  try {
    await _firestore.collection('events').doc(event.id).set(event.toJson());
    print("Event created successfully");
  } catch (e) {
    print("Error creating event: $e");
  }
}


  // Update an existing event
  Future<void> updateEvent(Event event) async {
  try {
    await _firestore.collection('events').doc(event.id).update(event.toJson());
    print("Event updated successfully");
  } catch (e) {
    print("Error updating event: $e");
  }
}


  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Stream<Event?> getEventStream(String eventId) {
  return _firestore
      .collection('events')
      .doc(eventId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          print("Firestore: Document with ID $eventId does not exist.");
          return null;
        }

        final data = doc.data();
        print("Document data: $data"); // Debugging output

        if (data == null) {
          print("Firestore: Document data is null for ID $eventId");
          return null;
        }

        try {
          // Use the 'id' field inside the document, fallback to Firestore doc.id
          final eventIdFromData = data['id'] ?? doc.id;
          return Event.fromMap(data as Map<String, dynamic>, eventIdFromData);
        } catch (e) {
          print("Error parsing Event data: $e");
          return null;
        }
      });
}




Stream<List<Gift>> getGiftsStream(String eventId) {
  return _firestore
      .collection('gifts')
      .where('eventId', isEqualTo: eventId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Gift.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  });
}


}
