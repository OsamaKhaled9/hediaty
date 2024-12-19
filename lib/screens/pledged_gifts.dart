import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hediaty/widgets/gift_list_item.dart';

class PledgedGiftsPage extends StatelessWidget {
  const PledgedGiftsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final giftController = Provider.of<GiftController>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Pledged Gifts",
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: StreamBuilder<List<Gift>>(
        stream: giftController.getPledgedGifts(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<Gift> pledgedGifts = snapshot.data ?? [];

          if (pledgedGifts.isEmpty) {
            return const Center(
              child: Text(
                "You haven't pledged any gifts yet.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return GiftListItem(
                gift: gift,
                onPublish: null, // No publish action in this view
                onEdit: null, // No edit action in this view
                onPledge: null, // No pledge action in this view
                onPurchase: null, // No purchase action in this view
              );
            },
          );
        },
      ),
    );
  }
}
