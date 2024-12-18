import 'package:flutter/material.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/gift_list_item.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsPage extends StatelessWidget {
  final String currentUserId;
  final String eventId;

  const EventDetailsPage({
    Key? key,
    required this.currentUserId,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context, listen: false);
    final giftController = Provider.of<GiftController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: StreamBuilder<Event?>(
        stream: eventController.getEventStream(eventId),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventSnapshot.hasError) {
            return Center(
              child: Text("Error: ${eventSnapshot.error}"),
            );
          }

          Event? event = eventSnapshot.data;

          if (event == null) {
            return const Center(
              child: Text("Event not found"),
            );
          }

          final isOwner = event.userId == currentUserId;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventDetailsCard(event),
                  const SizedBox(height: 16),
                  Text(
                    "Gifts",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6BFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGiftsList(context, giftController, eventId, isOwner),
                  if (isOwner)
                    Center(
                      child: CustomButton(
                        label: "Add Gift",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/create_edit_gift',
                            arguments: {'eventId': eventId},
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDetailsCard(Event event) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A6BFF),
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow("Date", event.date.toString()),
          const SizedBox(height: 8),
          _buildDetailRow("Location", event.location),
          const SizedBox(height: 8),
          _buildDetailRow("Description", event.description),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.label, color: Color(0xFF2A6BFF)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiftsList(
      BuildContext context, GiftController giftController, String eventId, bool isOwner) {
    return StreamBuilder<List<Gift>>(
      stream: isOwner
          ? giftController.getOwnerGiftsStream(eventId)
          : giftController.getPublicGiftsStream(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        List<Gift> gifts = snapshot.data ?? [];

        if (gifts.isEmpty) {
          return const Center(
            child: Text("No gifts found for this event."),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gifts.length,
          itemBuilder: (context, index) {
            final gift = gifts[index];
            return GiftListItem(
              gift: gift,
              onPublish: isOwner && gift.status == "Available"
                  ? () async {
                      await giftController.updateGiftStatus(
                        gift.id,
                        "Published",
                        null,
                      );
                    }
                  : null,
              onEdit: isOwner && gift.status != "Purchased"
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/create_edit_gift',
                        arguments: gift,
                      );
                    }
                  : null,
              onPledge: !isOwner && gift.status == "Published"
                  ? () async {
                      await giftController.updateGiftStatus(
                        gift.id,
                        "Pledged",
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                    }
                  : null,
              onPurchase: !isOwner && gift.status == "Pledged"
                  ? () async {
                      await giftController.updateGiftStatus(
                        gift.id,
                        "Purchased",
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}
