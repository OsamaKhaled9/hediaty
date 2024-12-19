import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/gift_list_item.dart';

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> _gifts = [];
  Map<String, String> _eventNames = {}; // Map of eventId to eventName
  bool _isLoading = true;
  String _sortBy = 'Name';

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    final giftController = Provider.of<GiftController>(context, listen: false);
    final eventController = Provider.of<EventController>(context, listen: false);
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Fetch all events created by the current user
      final events = await eventController.getEventsByUserId(currentUserId);

      // Map eventId to eventName for display purposes
      setState(() {
        _eventNames = {for (var event in events) event.id: event.name};
      });

      // Collect all gifts associated with the user's events
      final List<Gift> allGifts = [];
      for (var event in events) {
        final eventGifts = await giftController.getGiftsByEventId(event.id);
        allGifts.addAll(eventGifts);
      }

      setState(() {
        _gifts = allGifts;
        _isLoading = false;
        _sortGifts();
      });
    } catch (e) {
      print("Error loading gifts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortGifts() {
    setState(() {
      if (_sortBy == 'Name') {
        _gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'Category') {
        _gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortBy == 'Status') {
        _gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gifts'),
        backgroundColor: const Color(0xFF2A6BFF),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortGifts();
                  });
                },
                items: [
                  const DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                  const DropdownMenuItem(value: 'Category', child: Text('Sort by Category')),
                  const DropdownMenuItem(value: 'Status', child: Text('Sort by Status')),
                ],
                dropdownColor: Colors.white,
                icon: const Icon(Icons.sort, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
              ? const Center(child: Text('No gifts found.'))
              : ListView.separated(
                  itemCount: _gifts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    final eventName = _eventNames[gift.eventId] ?? 'Unknown Event';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2A6BFF),
                            ),
                          ),
                        ),
                        GiftListItem(
                          gift: gift,
                          onPublish: null, // Disable publishing in this view
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              '/create_edit_gift',
                              arguments: {'gift': gift, 'eventId': gift.eventId},
                            );
                          },
                          onPledge: null, // Disable pledging in this view
                          onPurchase: null, // Disable purchase in this view
                        ),
                      ],
                    );
                  },
                ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create_edit_gift',
            arguments: {'gift': null, 'eventId': null},
          );
        },
        backgroundColor: const Color(0xFF2A6BFF),
        child: const Icon(Icons.add),
      ),*/
    );
  }
}
