// pledged_gift_controller.dart
import 'package:flutter/material.dart';

// Model class for Pledged Gift
class PledgedGift {
  final String giftName;
  final String friendName;
  final DateTime dueDate;

  PledgedGift({
    required this.giftName,
    required this.friendName,
    required this.dueDate,
  });
}

// Function to show the modify dialog for a pledged gift
void showModifyDialog(BuildContext context, PledgedGift gift) {
  final TextEditingController friendController = TextEditingController(text: gift.friendName);
  final TextEditingController dueDateController = TextEditingController(text: '${gift.dueDate.toLocal()}'.split(' ')[0]);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modify Pledged Gift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: friendController,
                decoration: InputDecoration(
                  labelText: 'Friend\'s Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Updated: ${friendController.text}, Due Date: ${dueDateController.text}');
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without saving
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}
