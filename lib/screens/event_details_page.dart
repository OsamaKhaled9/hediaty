import 'package:flutter/material.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/gift_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsPage extends StatelessWidget {
  final String? eventId;

  const EventDetailsPage({Key? key, this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentEventId =
        eventId ?? ModalRoute.of(context)!.settings.arguments as String;

    final eventController = Provider.of<EventController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: StreamBuilder<Event?>(
        stream: eventController.getEventStream(currentEventId),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF2A6BFF)));
          }

          if (eventSnapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${eventSnapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          Event? event = eventSnapshot.data;

          if (event == null) {
            return Center(
              child: Text(
                "Event not found",
                style: TextStyle(fontSize: 18, color: Color(0xFF333333)),
              ),
            );
          }

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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6BFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGiftsList(currentEventId),
                  const SizedBox(height: 16),
                  Center(
                    child: CustomButton(
                      label: "Add Gift",
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/create_edit_gift',
                          arguments: {'eventId': currentEventId},
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
          _buildDetailRow(
              Icons.calendar_today, "Date", DateFormat('yyyy-MM-dd').format(event.date)),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Location", event.location),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.description, "Description", event.description),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF2A6BFF),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiftsList(String eventId) {
    return Consumer<GiftController>(
      builder: (context, giftController, _) {
        return FutureBuilder<List<Gift>>(
          future: giftController.getGiftsByEventId(eventId),
          builder: (context, giftSnapshot) {
            if (giftSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (giftSnapshot.hasError) {
              return Center(
                child: Text("Error loading gifts: ${giftSnapshot.error}"),
              );
            }

            List<Gift> gifts = giftSnapshot.data ?? [];

            if (gifts.isEmpty) {
              return const Center(
                child: Text(
                  "No gifts found for this event.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gifts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return GiftListItem(
                  gift: gift,
                  onPublish: () async {
                    await giftController.updateGiftStatus(
                      gift.id,
                      'Published',
                      null,
                    );
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      '/create_edit_gift',
                      arguments: gift,
                    );
                  },
                  onPledge: () async {
                    if (gift.status == 'Published') {
                      await giftController.updateGiftStatus(
                        gift.id,
                        'Pledged',
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
