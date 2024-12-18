import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class PledgedGiftsPage extends StatelessWidget {
  PledgedGiftsPage({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _pledgedGiftsStream = FirebaseFirestore.instance
      .collection('users')
      .doc("currentUserIdHere") // Replace with the actual logged-in user ID
      .collection('pledged_gifts')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _pledgedGiftsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No pledged gifts found.",
                      style: TextStyle(fontSize: 16, color: Colors.brown),
                    ),
                  );
                }

                final pledgedGifts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: pledgedGifts.length,
                  itemBuilder: (context, index) {
                    final gift = pledgedGifts[index];
                    return _buildGiftCard(
                      context,
                      PledgedGift(
                        giftName: gift['giftName'],
                        friendName: gift['friendName'],
                        dueDate: (gift['dueDate'] as Timestamp).toDate(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCard(BuildContext context, PledgedGift gift) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.brown, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 5,
      child: ListTile(
        title: Text(gift.giftName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pledged by: ${gift.friendName}'),
            Text('Due Date: ${gift.dueDate.toLocal()}'.split(' ')[0]),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Modify') {
              _showModifyDialog(context, gift);
            } else if (value == 'Remove') {
              print('Removing gift: ${gift.giftName}');
            }
          },
          itemBuilder: (context) {
            return ['Modify', 'Remove']
                .map((choice) => PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            ))
                .toList();
          },
        ),
      ),
    );
  }

  void _showModifyDialog(BuildContext context, PledgedGift gift) {
    // Add your modify logic here
    print('Modify gift: ${gift.giftName}');
  }
}
