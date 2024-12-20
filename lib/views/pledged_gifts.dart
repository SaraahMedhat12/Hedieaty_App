import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PledgedGift {
  final String giftName;
  final String friendName;
  final DateTime dueDate;
  final double price;
  final String category;

  PledgedGift({
    required this.giftName,
    required this.friendName,
    required this.dueDate,
    required this.price,
    required this.category,
  });
}

class PledgedGiftsPage extends StatelessWidget {
  PledgedGiftsPage({Key? key}) : super(key: key);

  // Fetch the current logged-in user's ID
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Stream to fetch pledged gifts
  Stream<QuerySnapshot> get _pledgedGiftsStream => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('pledged_gifts')
      .snapshots();

  // Function to fetch the friend's username dynamically
  Future<String> _fetchFriendUsername(String friendId) async {
    if (friendId.isEmpty) return 'Unknown Friend';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      return doc.data()?['username'] ?? 'Unnamed Friend';
    } catch (e) {
      print("Error fetching friend's username: $e");
      return 'Unknown Friend';
    }
  }

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
            child: Image.asset('assets/bg5.jpeg', fit: BoxFit.cover),
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
                    final giftData = pledgedGifts[index].data() as Map<String, dynamic>;

                    final giftName = giftData['giftName'] ?? giftData['name'] ?? 'Unnamed Gift';
                    final friendId = giftData['friendId'] ?? '';
                    final dueDate = (giftData['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final price = (giftData['price'] as num?)?.toDouble() ?? 0.0;
                    final category = giftData['category'] ?? 'No Category';

                    return FutureBuilder<String>(
                      future: giftData['friendName'] != null
                          ? Future.value(giftData['friendName']) // Use cached value
                          : _fetchFriendUsername(friendId),      // Fetch dynamically
                      builder: (context, friendSnapshot) {
                        final friendName = friendSnapshot.data ?? 'Unknown Friend';

                        return _buildGiftCard(
                          context,
                          PledgedGift(
                            giftName: giftName,
                            friendName: friendName,
                            dueDate: dueDate,
                            price: price,
                            category: category,
                          ),
                        );
                      },
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          gift.giftName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Pledged by: ${gift.friendName}',
            //     style: const TextStyle(fontSize: 14, color: Colors.brown)),
            Text('Due Date: ${gift.dueDate.toLocal()}'.split(' ')[0],
                style: const TextStyle(fontSize: 14, color: Colors.brown)),
            Text('Category: ${gift.category}',
                style: const TextStyle(fontSize: 14, color: Colors.brown)),
            Text('Price: \$${gift.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.brown)),
          ],
        ),
      ),
    );
  }
}
