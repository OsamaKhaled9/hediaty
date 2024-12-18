import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';

class GiftController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();

  /// Fetch gifts for a specific event from local storage
  Stream<List<Gift>> getGiftsStream(String eventId) async* {
    try {
      // Get local gifts first
      final List<Gift> localGifts = await _databaseService.getGiftsByEventId(eventId);

      // Fetch Firestore gifts to merge with local ones
      _firebaseService.getGiftsByEvent(eventId).listen((firestoreGifts) async {
        final mergedGifts = _mergeGifts(localGifts, firestoreGifts);
        yield mergedGifts;
      });
    } catch (e) {
      print("Error fetching gifts stream: $e");
      yield [];
    }
  }

  /// Add a new gift to local storage
  Future<void> addGift(Gift gift) async {
    try {
      await _databaseService.insertGift(gift); // Add gift locally
      notifyListeners();
    } catch (e) {
      print("Error adding gift locally: $e");
    }
  }

  /// Publish gifts to Firestore
  Future<void> publishGifts(String eventId) async {
    try {
      final List<Gift> unpublishedGifts = await _databaseService.getUnpublishedGiftsByEventId(eventId);

      for (final gift in unpublishedGifts) {
        await _firebaseService.createGift(gift); // Publish to Firestore
        await _databaseService.markGiftAsPublished(gift.id); // Update local status
      }

      print("Successfully published gifts for event $eventId");
      notifyListeners();
    } catch (e) {
      print("Error publishing gifts: $e");
    }
  }

  /// Update the status of a gift locally and sync with Firestore if necessary
  Future<void> updateGiftStatus(String giftId, String status, String? pledgedBy) async {
    try {
      await _databaseService.updateGiftStatus(giftId, status, pledgedBy); // Update locally
      await _firebaseService.updateGiftStatus(giftId, status, pledgedBy); // Sync with Firestore
      notifyListeners();
    } catch (e) {
      print("Error updating gift status: $e");
    }
  }

  /// Delete a gift locally and from Firestore if published
  Future<void> deleteGift(String giftId, {bool isPublished = false}) async {
    try {
      await _databaseService.deleteGift(giftId); // Remove locally

      if (isPublished) {
        await _firebaseService.deleteGift(giftId); // Delete from Firestore if published
      }

      notifyListeners();
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

  /// Merge local and Firestore gifts, prioritizing local unpublished gifts
  List<Gift> _mergeGifts(List<Gift> localGifts, List<Gift> firestoreGifts) {
    final Map<String, Gift> giftMap = {};

    // Add Firestore gifts
    for (final gift in firestoreGifts) {
      giftMap[gift.id] = gift;
    }

    // Overwrite with local unpublished gifts
    for (final gift in localGifts) {
      giftMap[gift.id] = gift;
    }

    return giftMap.values.toList();
  }

  /// Fetch pledged gifts for a specific user
  Stream<List<Gift>> getPledgedGifts(String userId) {
    return _firebaseService.getGiftsByPledger(userId);
  }

  /// Fetch a gift's details
  Future<Gift?> getGiftDetails(String giftId) async {
    try {
      return await _databaseService.getGiftById(giftId); // Check local first
    } catch (e) {
      print("Error fetching gift details locally: $e");
      return null;
    }
  }
}
