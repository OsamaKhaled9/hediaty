import 'package:flutter/material.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/gift_list_item.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsPage extends StatefulWidget {
  final String currentUserId;
  final String eventId;

  const EventDetailsPage({
    Key? key,
    required this.currentUserId,
    required this.eventId,
  }) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Gift> _gifts = []; // Local copy of gifts for animations

  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context, listen: false);
    final giftController = Provider.of<GiftController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        key: Key('eventDetailsText'), // Assign a key here
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: StreamBuilder<Event?>(
        stream: eventController.getEventStream(widget.eventId),
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

          final isOwner = event.userId == widget.currentUserId;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventDetailsCard(event),
                  const SizedBox(height: 16),
                  const Text(
                    "Gifts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6BFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGiftsList(context, giftController, widget.eventId, isOwner),
                  if (isOwner)
                    Center(
                      child: CustomButton(
                        label: "Add Gift",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/create_edit_gift',
                            arguments: {'eventId': widget.eventId},
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
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today, "Date", event.date.toString()),
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
        Icon(icon, color: const Color(0xFF2A6BFF)),
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

        final gifts = snapshot.data ?? [];

        // Add new items to AnimatedList
        _updateAnimatedList(gifts);

        if (_gifts.isEmpty) {
          return const Center(
            child: Text("No gifts found for this event."),
          );
        }

        return AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: _gifts.length,
          itemBuilder: (context, index, animation) {
            final gift = _gifts[index];
            return SizeTransition(
              sizeFactor: animation,
              child: GiftListItem(
                gift: gift,
                onPublish: isOwner && gift.status == "Available"
                    ? () async {
                        _updateGiftLocally(gift, index, "Published");
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
                        _updateGiftLocally(gift, index, "Pledged");
                        await giftController.updateGiftStatus(
                          gift.id,
                          "Pledged",
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                      }
                    : null,
                onPurchase: !isOwner && gift.status == "Pledged"
                    ? () async {
                        _updateGiftLocally(gift, index, "Purchased");
                        await giftController.updateGiftStatus(
                          gift.id,
                          "Purchased",
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _updateAnimatedList(List<Gift> updatedGifts) {
    final diff = updatedGifts.length - _gifts.length;

    // Add new items
    if (diff > 0) {
      for (var i = _gifts.length; i < updatedGifts.length; i++) {
        _gifts.add(updatedGifts[i]);
        _listKey.currentState?.insertItem(i);
      }
    }

    // Remove excess items
    if (diff < 0) {
      for (var i = _gifts.length - 1; i >= updatedGifts.length; i--) {
        final removedItem = _gifts.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: GiftListItem(gift: removedItem),
          ),
        );
      }
    }
  }

  void _updateGiftLocally(Gift gift, int index, String newStatus) {
    setState(() {
      _gifts[index] = gift.copyWith(status: newStatus);
    });
  }
}
