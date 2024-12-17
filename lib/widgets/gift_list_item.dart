import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';

class GiftListItem extends StatelessWidget {
  final Gift gift;
  final VoidCallback onPledge;

  const GiftListItem({
    Key? key,
    required this.gift,
    required this.onPledge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(gift.imagePath),
        ),
        title: Text(gift.name),
        subtitle: Text("Price: \$${gift.price.toStringAsFixed(2)}"),
        trailing: Text(
          gift.status,
          style: TextStyle(
            color: gift.status == 'Pledged' ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: gift.status == 'Available' ? onPledge : null,
      ),
    );
  }
}
