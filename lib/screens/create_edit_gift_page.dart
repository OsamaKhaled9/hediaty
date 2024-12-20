import 'package:flutter/material.dart';
import 'package:hediaty/controllers/gift_controller.dart';
import 'package:hediaty/core/models/gift.dart';
import 'package:hediaty/widgets/custom_text_field.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateEditGiftPage extends StatefulWidget {
  final Gift? gift;
  final String eventId;

  const CreateEditGiftPage({Key? key, this.gift, required this.eventId}) : super(key: key);

  @override
  _CreateEditGiftPageState createState() => _CreateEditGiftPageState();
}

class _CreateEditGiftPageState extends State<CreateEditGiftPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  // Other form fields
  late String _imagePath;
  late String _status;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing gift data or empty strings
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _descriptionController = TextEditingController(text: widget.gift?.description ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _priceController = TextEditingController(
      text: widget.gift?.price != null ? widget.gift!.price.toString() : '',
    );

    _imagePath = widget.gift?.imagePath ?? "https://img.lovepik.com/element/40202/2980.png_860.png";
    _status = widget.gift?.status ?? 'Available';
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

 void _saveGift() async {
  if (_formKey.currentState!.validate()) {
    final giftController = Provider.of<GiftController>(context, listen: false);

    final newGift = Gift(
      id: widget.gift?.id ?? const Uuid().v4(),
      eventId: widget.eventId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imagePath: _imagePath,
      status: _status,
    );

    if (widget.gift == null) {
      await giftController.addGift(newGift);
    } else {
      await giftController.updateGiftData(newGift);
    }

    // Notify listeners to refresh the UI
    giftController.refreshGifts(widget.eventId);

    Navigator.pop(context);
  }
}

  void _selectImage() {
    // Update to the predefined URL
    setState(() {
      _imagePath = "https://img.lovepik.com/element/40202/2980.png_860.png";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gift == null ? "Create Gift" : "Edit Gift",
          style: const TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "Gift Name",
                  icon: Icons.card_giftcard,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Gift name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: "Description",
                  icon: Icons.description,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Description is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _categoryController,
                  labelText: "Category",
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Category is required";
                    }
                    if (RegExp(r'\d').hasMatch(value)) {
                      return "Category cannot contain numbers";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _priceController,
                  labelText: "Price",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Price is required";
                    }
                    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                      return "Price must be a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Image Selection Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2A6BFF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Image: $_imagePath",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomButton(
                        label: "Select Image",
                        onPressed: _selectImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: "Save Gift",
                  onPressed: _saveGift,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
