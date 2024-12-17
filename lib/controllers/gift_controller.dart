import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/services/firebase_service.dart';

class GiftController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<Gift>> getGifts(String eventId) {
    return _firebaseService.getGiftsByEvent(eventId);
  }

  Future<void> addGift(Gift gift) async {
    await _firebaseService.createGift(gift);
    notifyListeners();
  }

  Future<void> updateGiftStatus(String giftId, String status, String? pledgedBy) async {
    await _firebaseService.updateGiftStatus(giftId, status, pledgedBy);
    notifyListeners();
  }

  Future<void> deleteGift(String giftId) async {
    await _firebaseService.deleteGift(giftId);
    notifyListeners();
  }
  Future<void> pledgeGift(String giftId, String userId) async {
  try {
    await _firebaseService.updateGiftStatus(giftId, "Pledged", userId);
    print("Gift successfully pledged!");
  } catch (e) {
    print("Error pledging gift: $e");
  }
}

// Stream of pledged gifts for a specific user
Stream<List<Gift>> getPledgedGifts(String userId) {
  return _firebaseService.getGiftsByPledger(userId);
}
Future<Gift?> getGiftDetails(String giftId) async {
  try {
    return await _firebaseService.getGiftById(giftId);
  } catch (e) {
    print("Error fetching gift details: $e");
    return null;
  }
}
}
