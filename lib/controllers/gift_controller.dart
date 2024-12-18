import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/services/firebase_service.dart';
import 'package:hediaty/services/database_service.dart';

class GiftController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseService _databaseService = DatabaseService();

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
      await _firebaseService.updateGiftStatus(giftId, status, pledgedBy);
      await _databaseService.updateGiftStatus(giftId, status, pledgedBy); // Update locally
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
}