import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';

class FriendGiftListPage extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String? eventId;

  FriendGiftListPage({
    required this.friendId,
    required this.friendName,
    this.eventId,
  });

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  String? _selectedEventId;
  Stream<List<Gift>>? _giftsStream;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEventsForFriend();
  }

  /// Fetch events for the friend
  Future<void> _fetchEventsForFriend() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      setState(() {
        _events = snapshot.docs.map((doc) {
          return {'id': doc.id, 'name': doc['name'] ?? 'Unnamed Event'};
        }).toList();

        if (_events.isNotEmpty) {
          _selectedEventId = widget.eventId ?? _events.first['id'];
          _loadGiftsForEvent(_selectedEventId!);
        }
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  /// Load gifts for the selected event
  void _loadGiftsForEvent(String eventId) {
    setState(() {
      _giftsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Gift(
            id: doc.id,
            name: data['name'] ?? 'Unnamed Gift',
            category: data['category'] ?? 'No Category',
            price: (data['price'] ?? 0.0).toDouble(),
            status: data['status'] ?? 'Available',
            isPledged: data['isPledged'] ?? false,
            eventId: eventId,
            description: data['description'] ?? '',
          );
        }).toList();
      });
    });
  }

  /// Pledge a gift
  Future<void> _pledgeGift(Gift gift) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final giftRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .doc(gift.eventId)
          .collection('gifts')
          .doc(gift.id);

      await giftRef.update({
        'status': 'Pledged',
        'isPledged': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift pledged successfully!")),
      );

      _loadGiftsForEvent(gift.eventId); // Refresh the list
    } catch (e) {
      print("Error pledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pledge gift. Try again.")),
      );
    }
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Friend's Gift List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg5.jpeg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              _buildEventDropdown(),
              Expanded(
                child: _giftsStream == null
                    ? Center(child: Text("No events available."))
                    : StreamBuilder<List<Gift>>(
                  stream: _giftsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child:
                          Text("No gifts available for this event."));
                    }
                    return _buildGiftList(snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Event dropdown widget
  Widget _buildEventDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedEventId,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            border: InputBorder.none,
          ),
          items: _events.map((event) {
            return DropdownMenuItem<String>(
              value: event['id'],
              child: Text(
                event['name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (eventId) {
            if (eventId != null) {
              _loadGiftsForEvent(eventId);
            }
          },
        ),
      ),
    );
  }


  /// Build gift list
  /// Build gift list
  Widget _buildGiftList(List<Gift> gifts) {
    return ListView.builder(
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: gift.isPledged ? Colors.brown[200] : Colors.white,
            border: Border.all(
              color: Colors.brown, // Brown border for all gifts
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              gift.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.brown[800], // Consistent brown text color
              ),
            ),
            subtitle: Text(
              "Category: ${gift.category}\nPrice: \$${gift.price}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.brown[700], // Slightly lighter brown for subtitle
              ),
            ),
            trailing: gift.isPledged
                ? Icon(Icons.lock, color: Colors.brown)
                : ElevatedButton(
              onPressed: () => _pledgeGift(gift),
              child: Text("Pledge"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }


}
