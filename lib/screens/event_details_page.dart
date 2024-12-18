import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/custom_button.dart';

class EventDetailsPage extends StatelessWidget {
  final String? eventId;

  const EventDetailsPage({Key? key, this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
        // Use the passed eventId or extract from route arguments
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
            return Center(child: CircularProgressIndicator(color: Color(0xFF2A6BFF)));
          }

          if (eventSnapshot.hasError) {
            return Center(child: Text("Error: ${eventSnapshot.error}", style: TextStyle(color: Colors.red)));
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
                  // Event Details Section
                  _buildEventDetailsCard(event),

                  SizedBox(height: 16),

                  // Gifts Section
                  Text(
                    "Gifts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6BFF),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildGiftsList(eventController, currentEventId),

                  SizedBox(height: 16),

                  // Add Gift Button
                  Center(
                    child: CustomButton(
                      label: "Add Gift",
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/create_edit_gift',
                          arguments: null, // Pass null for creating a new gift
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A6BFF),
            ),
          ),
          SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_today, "Date",
              DateFormat('yyyy-MM-dd').format(event.date)),
          SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Location", event.location),
          SizedBox(height: 8),
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
          color: Color(0xFF2A6BFF),
          size: 20,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

    // Build Gifts List
  Widget _buildGiftsList(EventController eventController, String eventId) {
    return FutureBuilder<List<Gift>>(
      future: eventController.getGiftsByEventId(eventId), // Fetch gifts locally
      builder: (context, giftSnapshot) {
        if (giftSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (giftSnapshot.hasError) {
          return Center(
              child: Text("Error loading gifts: ${giftSnapshot.error}"));
        }

        List<Gift> gifts = giftSnapshot.data ?? [];

        if (gifts.isEmpty) {
          return Center(
              child: Text(
            "No gifts found for this event.",
            style: TextStyle(color: Colors.grey),
          ));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: gifts.length,
          separatorBuilder: (context, index) => Divider(
            color: Color(0xFFADD8E6),
            height: 1,
          ),
          itemBuilder: (context, index) {
            final gift = gifts[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              title: Text(
                gift.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Category: ${gift.category}"),
              trailing: Text(
                "\$${gift.price.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Color(0xFF2A6BFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to edit the selected gift
                Navigator.pushNamed(
                  context,
                  '/create_edit_gift',
                  arguments: gift,
                );
              },
            );
          },
        );
      },
    );
  }
}
