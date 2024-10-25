
import 'package:flutter/material.dart';
import '../controllers/pledged_gift_controllers.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PledgedGiftsPage(),
  ));
}


class PledgedGiftsPage extends StatelessWidget {
  // Example list of pledged gifts
  final List<PledgedGift> pledgedGifts = [
    PledgedGift(giftName: 'Gift Card', friendName: 'John Doe', dueDate: DateTime(2024, 12, 25)),
    PledgedGift(giftName: 'Watch', friendName: 'Jane Smith', dueDate: DateTime(2024, 11, 15)),
    PledgedGift(giftName: 'Jewelry', friendName: 'Mike Johnson', dueDate: DateTime(2024, 10, 30)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpeg', // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),
          // List of Pledged Gifts
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                return _buildGiftCard(context, pledgedGifts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the gift card with border and shadow
  Widget _buildGiftCard(BuildContext context, PledgedGift gift) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.brown, width: 1), // Brown border
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      elevation: 5, // Shadow effect
      child: ListTile(
        title: Text(gift.giftName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pledged by: ${gift.friendName}'),
            Text('Due Date: ${gift.dueDate.toLocal()}'.split(' ')[0]),
          ],
        ),
        trailing: _buildModifyButton(context, gift),
      ),
    );
  }

  // Button to modify the pledge
  Widget _buildModifyButton(BuildContext context, PledgedGift gift) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'Modify') {
          showModifyDialog(context, gift); // Call the function from the new file
        } else if (value == 'Remove') {
          // Handle removal of the gift from the pledged gifts
          print('Removing gift: ${gift.giftName}');
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Modify', 'Remove'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}


