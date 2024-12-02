import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
      ),
      body: ListView.builder(
        itemCount: 5, // Hardcoded for demo
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Gift $index'),
            subtitle: Text('Category: Books'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
