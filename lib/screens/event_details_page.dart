import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;

  const EventDetailsPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final String eventId =ModalRoute.of(context)!.settings.arguments as String;

    final eventController = Provider.of<EventController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details"),
      ),
      body: StreamBuilder<Event?>(
        stream: eventController.getEventStream(eventId),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (eventSnapshot.hasError) {
            return Center(child: Text("Error: ${eventSnapshot.error}"));
          }

          Event? event = eventSnapshot.data;

          if (event == null) {
            return Center(child: Text("Event not found"));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text("Date: ${event.date.toLocal()}".split(' ')[0]),
                    SizedBox(height: 8),
                    Text("Location: ${event.location}"),
                    SizedBox(height: 8),
                    Text("Description: ${event.description}"),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Gifts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Gift>>(
                  stream: eventController.getGiftsStream(eventId),
                  builder: (context, giftSnapshot) {
                    if (giftSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (giftSnapshot.hasError) {
                      return Center(child: Text("Error: ${giftSnapshot.error}"));
                    }

                    List<Gift> gifts = giftSnapshot.data ?? [];

                    if (gifts.isEmpty) {
                      return Center(child: Text("No gifts found for this event"));
                    }

                    return ListView.builder(
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        final gift = gifts[index];
                        return ListTile(
                          title: Text(gift.name),
                          subtitle: Text("Pledged by: ${gift.name}"),
                          trailing: Text("\$${gift.price.toStringAsFixed(2)}"),
                          onTap: () {
                            // Handle gift details navigation
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
