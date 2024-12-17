import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PledgedGiftsPage extends StatelessWidget {
  const PledgedGiftsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final giftController = Provider.of<GiftController>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
      ),
      body: StreamBuilder<List<Gift>>(
        stream: giftController.getPledgedGifts(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<Gift> pledgedGifts = snapshot.data ?? [];

          if (pledgedGifts.isEmpty) {
            return Center(child: Text("You haven't pledged any gifts yet."));
          }

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  leading: Image.asset(gift.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(gift.name),
                  subtitle: Text("Event ID: ${gift.eventId}\nStatus: ${gift.status}"),
                  trailing: Text("\$${gift.price.toStringAsFixed(2)}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
