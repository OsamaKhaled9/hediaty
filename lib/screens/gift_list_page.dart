import 'package:flutter/material.dart';
import 'gift_details_page.dart'; // For navigating to gift details
import 'package:hediaty/db/database_helper.dart';

class GiftListPage extends StatefulWidget {
  final int eventId;
  GiftListPage({required this.eventId});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> _gifts = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  // Load gifts from the database using eventId
  _loadGifts() async {
    final gifts = await DatabaseHelper.instance.queryGiftsByEvent(widget.eventId);
    setState(() {
      _gifts = gifts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create_gift', arguments: widget.eventId);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          var gift = _gifts[index];
          return ListTile(
            title: Text(gift['gift_name']),
            subtitle: Text('Status: ${gift['status']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetailsPage(giftId: gift['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
