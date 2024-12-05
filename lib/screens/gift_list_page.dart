import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  const GiftListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
      ),
      body: ListView.builder(
        itemCount: 5, // Hardcoded for demo
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Gift $index'),
            subtitle: const Text('Category: Books'),
            trailing: Switch(
              value: true, // Hardcoded for demo
              onChanged: (bool value) {
                // Handle pledge toggle
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/gift_details');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
