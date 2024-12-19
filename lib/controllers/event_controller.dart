import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:flutter/foundation.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:hediaty/services/firebase_service.dart';

class EventController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
    final FirebaseService _firebaseService = FirebaseService();


  // Fetch all events for a specific user and update local database
  Stream<List<Event>> loadEvents(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) {
        final event = Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Save each event to the local database
        _databaseService.insertEvent(event);
        return event;
      }).toList();
      return events;
    });
  }

    // Fetch all events associated with a given userId.
  Future<List<Event>> getEventsByUserId(String userId) async {
    try {
      // Fetch events from Firestore where the ownerId matches the userId.
      List<Event> firestoreEvents = await _firebaseService.getEventsByUserId(userId);

      // Fetch local events from the local database where the ownerId matches the userId.
      List<Event> localEvents = await _databaseService.getEventsByUserId(userId);

      // Merge Firestore and local events, prioritizing Firestore data for conflicts.
      Map<String, Event> eventMap = {
        for (var event in localEvents) event.id: event,
      };

      for (var event in firestoreEvents) {
        eventMap[event.id] = event; // Firestore data overwrites local data if conflict exists.
      }

      return eventMap.values.toList();
    } catch (e) {
      print("Error fetching events for userId $userId: $e");
      return [];
    }
  }

  // Create a new event and add it to both Firestore and the local database
  Future<void> createEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).set(event.toJson());
      await _databaseService.insertEvent(event); // Save locally
      print("Event created successfully");
      notifyListeners();
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  // Update an existing event in both Firestore and the local database
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).update(event.toJson());
      await _databaseService.insertEvent(event); // Update locally
      print("Event updated successfully");
      notifyListeners();
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  // Delete an event from both Firestore and the local database
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      await _databaseService.deleteEvent(eventId); // Delete locally
      print("Event deleted successfully");
      notifyListeners();
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // Get a specific event stream by ID
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
      if (data == null) {
        print("Firestore: Document data is null for ID $eventId");
        return null;
      }

      try {
        final eventIdFromData = data['id'] ?? doc.id;
        final event = Event.fromMap(data as Map<String, dynamic>, eventIdFromData);
        // Update local database
        //_databaseService.insertEvent(event);
        return event;
      } catch (e) {
        print("Error parsing Event data: $e");
        return null;
      }
    });
  }

  // Fetch all gifts for a specific event from Firestore
  Stream<List<Gift>> getGiftsStream(String eventId) {
    return _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final gifts = snapshot.docs.map((doc) {
        final gift = Gift.fromMap(doc.data() as Map<String, dynamic>);
        _databaseService.insertGift(gift); // Save locally
        return gift;
      }).toList();
      return gifts;
    });
  }

  // Fetch gifts for a specific event from the local database
  Future<List<Gift>> getLocalGifts(String eventId) async {
    return await _databaseService.getGiftsByEventId(eventId);
  }

  // Fetch the count of events associated with the current user
Future<int> getEventCount(String userId) async {
  try {
    final querySnapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();

    print("Event count for userId $userId: ${querySnapshot.size}");
    return querySnapshot.size;
  } catch (e) {
    print("Error in getEventCount: $e");
    throw Exception("Error fetching event count.");
  }
}

  // Get gifts associated with an event ID from the local database
  Future<List<Gift>> getGiftsByEventId(String eventId) async {
    return await _databaseService.getGiftsByEventId(eventId);
  }
   
}
