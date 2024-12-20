import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';
import 'package:hediaty/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';



class GiftController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();


  // Stream gifts locally from SQLite for a specific event
  Stream<List<Gift>> getGiftsStream(String eventId) async* {
    try {
      final List<Gift> gifts = await _databaseService.getGiftsByEventId(eventId);
      yield gifts;
    } catch (e) {
      print("Error fetching gifts from local storage: $e");
      yield [];
    }
  }

  // Add Gift locally and optionally sync to Firestore when published
  Future<void> addGift(Gift gift, {bool publish = false}) async {
    try {
      await _databaseService.insertGift(gift); // Add gift locally
      if (publish) {
        await _firebaseService.createGift(gift); // Sync with Firestore
      }
      notifyListeners();
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  // Publish all unpublished gifts for an event
  Future<void> publishGifts(String eventId) async {
    try {
      final gifts = await _databaseService.getGiftsByEventId(eventId);
      for (var gift in gifts) {
        await _firebaseService.createGift(gift);
      }
      notifyListeners();
      print("All gifts for event $eventId are published.");
    } catch (e) {
      print("Error publishing gifts: $e");
    }
  }

  // Update Gift Status (e.g., Pledge Gift)
Future<void> updateGiftStatus(String giftId, String status, String? pledgedBy) async {
  try {
    // Fetch the gift document from Firestore
    final giftDoc = await _firebaseService.getGiftById(giftId);

    if (giftDoc != null) {
      // Safely access the eventId from the gift document
      final eventId = giftDoc.eventId; // Assuming Gift class has eventId
      if (eventId != null) {
        // Fetch the event document from Firestore using eventId
        final event = await _firebaseService.getEventById(eventId);
        if (event != null) {
          final recipientUserId = event['userId']; // Owner of the event
          final currentUser = FirebaseAuth.instance.currentUser;

         if (currentUser != null) {
              final userName = currentUser.displayName ?? currentUser.email ?? "Unknown User";
              final notificationBody = status == "Pledged"
                  ? "$userName has pledged a gift!"
                  : "$userName has purchased a gift!";

              // Add the notification to Firestore
              await _firebaseService.addNotification(
                recipientUserId: recipientUserId,
                notificationBody: notificationBody,
              );
            } else {
              print("Error: No logged-in user found.");
            }
        } else {
          print("Error: Event not found for the gift.");
        }
      } else {
        print("Error: Event ID is null for the gift.");
      }

      // Update the gift in Firestore
      await _firebaseService.updateGiftStatus(giftId, status, pledgedBy);

      // Update the gift in the local database
      await _databaseService.updateGiftStatus(giftId, status, pledgedBy);
    } else {
      print("Gift document not found in Firestore. Creating it before updating...");

      // Fetch the gift from the local database
      final localGift = await _databaseService.getGiftById(giftId);

      if (localGift != null) {
        // Add the gift to Firestore
        await _firebaseService.createGift(localGift);

        // Update the gift in Firestore
        await _firebaseService.updateGiftStatus(giftId, status, pledgedBy);

        // Update the gift in the local database
        await _databaseService.updateGiftStatus(giftId, status, pledgedBy);
      } else {
        throw Exception("Gift not found locally. Unable to update.");
      }
    }

    notifyListeners();
  } catch (e) {
    print("Error updating gift status: $e");
  }
}





  // Pledge a gift if it is available
  Future<void> pledgeGift(String giftId, String userId) async {
    try {
      Gift? gift = await _firebaseService.getGiftById(giftId);

      if (gift != null && gift.status == 'Available') {
        await updateGiftStatus(giftId, 'Pledged', userId);
        print("Gift successfully pledged!");
      } else {
        print("Gift is not available for pledging.");
      }
    } catch (e) {
      print("Error pledging gift: $e");
    }
  }

  // Stream pledged gifts for a specific user
  Stream<List<Gift>> getPledgedGifts(String userId) {
    return _firebaseService.getGiftsByPledger(userId);
  }

  // Fetch gift details locally
  Future<Gift?> getGiftDetails(String giftId) async {
    try {
      return await _databaseService.getGiftById(giftId);
    } catch (e) {
      print("Error fetching gift details: $e");
      return null;
    }
  }
     // Fetch gifts for a specific event by eventId from local database
Future<List<Gift>> getGiftsByEventId(String eventId) async {
  try {
    // Fetch all gifts for the event from local and Firestore databases
    List<Gift> localGifts = await _databaseService.getGiftsByEventId(eventId);
    List<Gift> firestoreGifts = await _firebaseService.getGiftsByEventId(eventId);

    // Merge gifts: Prioritize Firestore data for conflicts
    Map<String, Gift> giftMap = {
      for (var gift in localGifts) gift.id: gift,
    };

    for (var gift in firestoreGifts) {
      giftMap[gift.id] = gift; // Firestore data overwrites local data if conflict exists
    }

    return giftMap.values.toList();
  } catch (e) {
    print("Error fetching gifts for eventId $eventId: $e");
    return [];
  }
}

   Stream<List<Gift>> getOwnerGiftsStream(String eventId) async* {
    try {
      // Fetch gifts from the local database
      Stream<List<Gift>> localGiftsStream =
          _databaseService.getGiftsByEventIdStream(eventId);

      // Fetch published gifts from Firestore to synchronize
      List<Gift> firestoreGifts =
          await _firebaseService.getGiftsByEventId(eventId);

      // Synchronize local and Firestore data
      for (Gift gift in firestoreGifts) {
        await _databaseService.insertGift(gift);
      }

      // Yield the combined local stream
      yield* localGiftsStream;
    } catch (e) {
      print("Error in getOwnerGiftsStream: $e");
      yield [];
    }
  }

  // Stream for Public Gifts (published + purchased only)
  Stream<List<Gift>> getPublicGiftsStream(String eventId) async* {
    try {
      // Fetch only published and purchased gifts from Firestore
      List<Gift> firestoreGifts = await _firebaseService.getGiftsByEventId(
        eventId,
        filterPublishedAndPurchased: true,
      );

      yield firestoreGifts;
    } catch (e) {
      print("Error in getPublicGiftsStream: $e");
      yield [];
    }
  }
  Future<void> updateGiftData(Gift updatedGift) async {
  try {
    // Update locally
    await _databaseService.updateGift(updatedGift);

    // Sync with Firestore if the status is not 'Available'
    if (updatedGift.status != 'Available') {
      await _firebaseService.updateGift(updatedGift);
    }

    notifyListeners();
  } catch (e) {
    print("Error updating gift data: $e");
    throw Exception("Failed to update gift data");
  }
}
 /// Fetch gifts for a specific user from the local database
  Future<List<Gift>> getGiftsByUserId(String userId) async {
    try {
      final db = await _databaseService.database;
      final gifts = await db.query(
        'gifts',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return gifts.map((map) => Gift.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching gifts from local database: $e");
      return [];
    }
  }

  /// Fetch gifts for a specific user from Firestore
  Future<List<Gift>> getGiftsFromFirestore(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching gifts from Firestore: $e");
      return [];
    }
  }

  /// Delete a gift both locally and from Firestore if applicable
   // Delete a gift
  Future<void> deleteGift(String giftId, String status) async {
    try {
      // Delete gift from local database
      await _databaseService.deleteGift(giftId);

      // Delete gift from Firestore if not available
      if (status != 'Available') {
        await _firebaseService.deleteGift(giftId);
      }

      notifyListeners();
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }
// Stream for listening to gift changes
  Stream<void> listenForGiftChanges(String currentUserId) {
    return _firebaseService.listenForGiftChanges(currentUserId).map((gift) {
      if (gift.status == 'Pledged' || gift.status == 'Purchased') {
        String title = 'Gift Status Changed';
        String body = gift.status == 'Pledged'
            ? 'A gift has been pledged!'
            : 'A gift has been purchased!';
        _notificationService.showNotification(
          id: gift.id.hashCode,
          title: title,
          body: body,
        );
      }
    });
  }

 // Stream real-time notifications for the current user
Stream<Map<String, dynamic>> listenForNotifications(String currentUserId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('recipientUserId', isEqualTo: currentUserId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .asyncExpand((querySnapshot) async* {
        for (var change in querySnapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            // Yield the notification details
            yield {
              'notificationBody': change.doc['notificationBody'],
              'timestamp': change.doc['timestamp'],
            };

            // Optionally display the notification locally
            NotificationService().showNotification(
              id: change.doc.id.hashCode,
              title: "New Notification",
              body: change.doc['notificationBody'],
            );
          }
        }
      });
}



}
