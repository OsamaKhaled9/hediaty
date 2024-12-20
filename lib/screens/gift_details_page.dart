import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftDetailsPage extends StatelessWidget {
  final String giftId;

  const GiftDetailsPage({Key? key, required this.giftId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final giftController = Provider.of<GiftController>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Details"),
      ),
      body: FutureBuilder<Gift?>(
        future: giftController.getGiftDetails(giftId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Error fetching gift details"));
          }

          final Gift gift = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift Image
                Center(
                  child: Image.asset(
                    gift.imagePath,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),
                // Gift Name
                Text(
                  gift.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // Description
                Text("Description: ${gift.description}"),
                SizedBox(height: 8),
                // Category
                Text("Category: ${gift.category}"),
                SizedBox(height: 8),
                // Price
                Text("Price: \$${gift.price.toStringAsFixed(2)}"),
                SizedBox(height: 16),
                // Gift Status
                Text(
                  "Status: ${gift.status}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gift.status == "Available" ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                // Pledge Button
                if (gift.status == "Available")
                  ElevatedButton(
                    key: Key('Pledged_gift_button'), // Add a unique key
                    onPressed: () async {
                      await giftController.pledgeGift(giftId, currentUser!.uid);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Pledge This Gift"),
                  )
                else
                  Text(
                    "This gift has already been pledged.",
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
