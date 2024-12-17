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
      appBar: AppBar(title: Text("Gifts")),
      body: StreamBuilder<List<Gift>>(
        stream: giftController.getGifts(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          List<Gift> gifts = snapshot.data ?? [];
          if (gifts.isEmpty) {
            return Center(child: Text("No gifts found for this event."));
          }

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              return GiftListItem(
                gift: gifts[index],
                onPledge: () {
                  // Update gift status to 'Pledged'
                  giftController.updateGiftStatus(
                      gifts[index].id, 'Pledged', FirebaseAuth.instance.currentUser!.uid);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add/edit gift page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
