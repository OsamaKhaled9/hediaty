import 'package:flutter/material.dart';
import 'package:hediaty/db/database_helper.dart';

class GiftDetailsPage extends StatefulWidget {
  final int giftId;
  GiftDetailsPage({required this.giftId});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _status = 'Available';

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  // Load gift details from database
  _loadGiftDetails() async {
    final gift = await DatabaseHelper.instance.queryGiftById(widget.giftId);
    setState(() {
      _nameController.text = gift['name'];
      _descriptionController.text = gift['description'];
      _priceController.text = gift['price'].toString();
      _status = gift['status'];
    });
  }

  // Save gift details
  _saveGift() async {
    final updatedGift = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'status': _status,
    };
    await DatabaseHelper.instance.updateGift(widget.giftId, updatedGift);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gift Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Gift Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            DropdownButton<String>(
              value: _status,
              onChanged: (newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: ['Available', 'Pledged']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: _saveGift,
              child: Text('Save Gift'),
            ),
          ],
        ),
      ),
    );
  }
}
