import 'package:flutter/material.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/widgets/gift_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftListPage extends StatelessWidget {
  final String eventId;

  const GiftListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final giftController = Provider.of<GiftController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gifts"),
        backgroundColor: const Color(0xFF2A6BFF),
      ),
      body: StreamBuilder<List<Gift>>(
        stream: giftController.getGiftsStream(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          List<Gift> gifts = snapshot.data ?? [];
          if (gifts.isEmpty) {
            return const Center(child: Text("No gifts found for this event."));
          }

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return GiftListItem(
                gift: gift,
                onPublish: () async {
                  if (gift.status == 'Available') {
                    await giftController.updateGiftStatus(
                      gift.id,
                      'Published',
                      null,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gift published successfully!")),
                    );
                  }
                },
                onEdit: () {
                  Navigator.pushNamed(
                    context,
                    '/create_edit_gift',
                    arguments: gift,
                  );
                },
                onPledge: () async {
                  if (gift.status == 'Available') {
                    await giftController.updateGiftStatus(
                      gift.id,
                      'Pledged',
                      FirebaseAuth.instance.currentUser!.uid,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gift pledged successfully!")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create_edit_gift',
            arguments: null, // Pass null for creating a new gift
          );
        },
        backgroundColor: const Color(0xFF2A6BFF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
