import 'dart:convert';

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
  String? friendUsername;

  get http => null;

  @override
  void initState() {
    super.initState();
    _fetchFriendUsername();
    _fetchEventsForFriend();
  }

  /// Fetch friend's username
  Future<void> _fetchFriendUsername() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          friendUsername = docSnapshot['username'] ?? "Unnamed Friend";
        });
      }
    } catch (e) {
      print("Error fetching friend's username: $e");
      friendUsername = "Unnamed Friend";
    }
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
            name: data['giftName'] ?? data['name'] ?? 'Unnamed Gift',
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

      final friendToken = await _getFriendNotificationToken(widget.friendId);
      // if (friendToken == null) {
      //   throw Exception("Friend's notification token not found.");
      // }

      final giftRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .doc(gift.eventId)
          .collection('gifts')
          .doc(gift.id);

      // Update gift as pledged
      await giftRef.update({
        'status': 'Pledged',
        'isPledged': true,
      });

      // Add gift to the current user's pledged_gifts collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('pledged_gifts')
          .doc(gift.id)
          .set({
        'giftName': gift.name,
        'friendName': widget.friendName,
        'friendId': widget.friendId,
        'dueDate': DateTime.now().add(Duration(days: 7)),
        'price': gift.price,
        'category': gift.category,
      });

      // Send notification to the friend
      // await _sendNotificationToFriend(friendToken, gift);

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

// Helper function to get the friend's notification token
  Future<String?> _getFriendNotificationToken(String friendId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();

      return docSnapshot.data()?['notificationToken'];
    } catch (e) {
      print("Error fetching friend's notification token: $e");
      return null;
    }
  }

// Helper function to send a notification
  Future<void> _sendNotificationToFriend(String token, Gift gift) async {
    final serverKey = 'YOUR_SERVER_KEY'; // Replace with your FCM server key
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      'to': token,
      'notification': {
        'title': 'New Gift Pledged!',
        'body': '${gift.name} has been pledged from your list.',
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'giftId': gift.id,
        'eventId': gift.eventId,
      },
    };

    try {
      final response = await http.post(url, headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
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
                          child: Text(
                              "No gifts available for this event."));
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

  Widget _buildEventDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          border: Border.all(color: Colors.brown, width: 1.5), // Brown border
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Soft shadow
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedEventId, // Currently selected value
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            border: InputBorder.none, // Removes default underline
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.brown), // Dropdown icon
          style: TextStyle(
            fontSize: 16,
            color: Colors.brown[800], // Text color
            fontWeight: FontWeight.bold,
          ),
          dropdownColor: Colors.white, // Dropdown background
          items: _events.map((event) {
            return DropdownMenuItem<String>(
              value: event['id'],
              child: Text(event['name']),
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


  Widget _buildGiftList(List<Gift> gifts) {
    return ListView.builder(
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: gift.isPledged ? Colors.brown[200] : Colors.white,
            border: Border.all(color: Colors.brown, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              gift.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.brown[800],
              ),
            ),
            subtitle: Text(
              "Category: ${gift.category}\nPrice: \$${gift.price}",
              style: TextStyle(fontSize: 14, color: Colors.brown[700]),
            ),
            trailing: gift.isPledged
                ? Icon(Icons.lock, color: Colors.brown)
                : ElevatedButton(
              onPressed: () => _pledgeGift(gift),
              child: Text("Pledge"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
