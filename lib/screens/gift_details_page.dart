import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  const GiftDetailsPage({super.key});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String? giftName, giftDescription, giftCategory;
  double? giftPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Gift Name'),
                onSaved: (value) => giftName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => giftDescription = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => giftPrice = double.tryParse(value ?? '0'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Pick image
                },
                child: const Text('Upload Image'),
              ),
              DropdownButton<String>(
                hint: const Text('Select Category'),
                onChanged: (String? newCategory) {
                  setState(() {
                    giftCategory = newCategory;
                  });
                },
                items: ['Electronics', 'Books', 'Clothing']
                    .map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // Save gift details
                  }
                },
                child: const Text('Save Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
