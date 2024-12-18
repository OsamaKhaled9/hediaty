import 'package:flutter/material.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateEditGiftPage extends StatefulWidget {
  final Gift? gift;
  final String eventId; // Required to associate the gift with an event

  const CreateEditGiftPage({Key? key, this.gift, required this.eventId}) : super(key: key);

  @override
  _CreateEditGiftPageState createState() => _CreateEditGiftPageState();
}

class _CreateEditGiftPageState extends State<CreateEditGiftPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late String _imagePath;
  late String _status;

  @override
  void initState() {
    super.initState();
    // Preload form with gift data if editing
    _name = widget.gift?.name ?? '';
    _description = widget.gift?.description ?? '';
    _category = widget.gift?.category ?? '';
    _price = widget.gift?.price ?? 0.0;
    _imagePath = widget.gift?.imagePath ?? 'assets/images/default_gift.png';
    _status = widget.gift?.status ?? 'Available';
  }

  void _saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final giftController = Provider.of<GiftController>(context, listen: false);

      // Create or update gift
      final newGift = Gift(
        id: widget.gift?.id ?? const Uuid().v4(),
        eventId: widget.eventId, // Ensure the eventId is set
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        imagePath: _imagePath,
        status: _status,
      );

      if (widget.gift == null) {
        // Add a new gift
        await giftController.addGift(newGift);
      } else {
        // Update the existing gift
        newGift.id; 
        await giftController.updateGiftStatus(newGift.id, newGift.status,newGift.pledgedBy);
      }

      Navigator.pop(context); // Return to the previous page
    }
  }

  void _selectImage() async {
    // Dummy image selection for demonstration purposes
    // Replace with your image picker logic
    setState(() {
      _imagePath = 'assets/images/sample_gift.png'; // Example image path
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? "Create Gift" : "Edit Gift"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: "Gift Name"),
                  validator: (value) => value!.isEmpty ? "Enter a gift name" : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (value) => value!.isEmpty ? "Enter a description" : null,
                  onSaved: (value) => _description = value!,
                ),
                TextFormField(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: "Category"),
                  validator: (value) => value!.isEmpty ? "Enter a category" : null,
                  onSaved: (value) => _category = value!,
                ),
                TextFormField(
                  initialValue: _price > 0 ? _price.toString() : '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Price"),
                  validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                          ? "Enter a valid price"
                          : null,
                  onSaved: (value) => _price = double.parse(value!),
                ),
                SizedBox(height: 16),
                Text("Image Path: $_imagePath"),
                TextButton(
                  onPressed: _selectImage,
                  child: Text("Select Image"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveGift,
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
