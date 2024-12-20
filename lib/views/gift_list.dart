import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../service/firebase.dart';
import '../models/gift.dart';
import 'gift_details.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({Key? key, required this.eventName}) : super(key: key);

  final String eventName;

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _giftController = GiftController();
  String? _selectedEventId;
  List<Map<String, dynamic>> _events = [];
  Stream<List<Gift>>? _giftsStream;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final userId = "your_user_id"; // Replace with AuthService.getCurrentUser()?.uid
    final events = await _giftController.loadEventsForUser(userId);
    setState(() {
      _events = events;
      if (events.isNotEmpty) {
        _selectedEventId = events.first['id'];
        _giftsStream = _giftController.loadGiftsForEvent(_selectedEventId!);
      }
    });
  }

  void _onEventSelected(String? eventId) {
    setState(() {
      _selectedEventId = eventId;
      _giftsStream = _giftController.loadGiftsForEvent(eventId!);
    });
  }

  void _refreshGifts() {
    if (_selectedEventId != null) {
      setState(() {
        _giftsStream = _giftController.loadGiftsForEvent(_selectedEventId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Gift List"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: Colors.white),
            onPressed: _showGiftSortOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg5.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.brown.withOpacity(0.2),
          ),
          Column(
            children: [
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedEventId,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    items: _events.map((event) {
                      return DropdownMenuItem<String>(
                        value: event['id'],
                        child: Text(event['name'], style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: _onEventSelected,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: _selectedEventId == null
                    ? Center(child: Text("No events available.", style: TextStyle(fontSize: 18)))
                    : StreamBuilder<List<Gift>>(
                  stream: _giftsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("No gifts available.", style: TextStyle(fontSize: 18)),
                      );
                    }

                    final gifts = snapshot.data!;
                    return ListView.builder(
                      itemCount: gifts.length,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemBuilder: (context, index) {
                        final gift = gifts[index];
                        return _buildGiftCard(gift);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      eventId: _selectedEventId!,
                      existingGift: null, // null for new gifts
                      autogeneratedId: '',
                    ),
                  ),
                );
                if (result == true) {
                  _refreshGifts(); // Refresh the list after editing
                }
              },

              icon: Icon(Icons.add),
              label: Text(
                "Add New Gift",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade400),
      ),
      color: gift.isPledged ? Colors.brown.shade200 : Colors.white, // Darker for pledged
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          gift.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: gift.isPledged ? Colors.brown.shade700 : Colors.black87,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          "Category: ${gift.category}\nPrice: \\${gift.price}",
          style: TextStyle(fontSize: 14),
        ),
        trailing: gift.isPledged
            ? Icon(Icons.lock, color: Colors.brown) // Locked icon for pledged
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.brown),
              onPressed: () async {
                try {
                  final User? user = FirebaseAuth.instance.currentUser;
                  final String? userId = user?.uid;

                  if (userId == null) {
                    throw Exception("No authenticated user found.");
                  }

                  // Navigate to GiftDetailsPage to edit the gift
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftDetailsPage(
                        eventId: _selectedEventId!, // Pass the event ID
                        existingGift: {
                          'name': gift.name,
                          'category': gift.category,
                          'description': gift.description,
                          'price': gift.price,
                          'status': gift.status,
                          'isPledged': gift.isPledged,
                        },
                        autogeneratedId: gift.id, // Pass the gift ID
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    // Call the editGift method to update the gift in Firestore
                    await FirebaseService().editGift(
                      eventId: _selectedEventId!,
                      giftId: gift.id,
                      updatedGiftData: result,
                    );
                    _refreshGifts(); // Refresh the list to show updated gift
                  }
                } catch (e) {
                  print("Error editing gift: $e");
                }
              },
            ),











            IconButton(
              icon: Icon(Icons.delete, color: Colors.brown),
              onPressed: () async {
                await _giftController.deleteGift(_selectedEventId!, gift.id);
                _refreshGifts();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Sort by Name', style: TextStyle(color: Colors.brown)),
                onTap: () {
                  setState(() {
                    _giftsStream = _giftsStream!.map((gifts) {
                      gifts.sort((a, b) => a.name.compareTo(b.name));
                      return gifts;
                    }).asBroadcastStream();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Category', style: TextStyle(color: Colors.brown)),
                onTap: () {
                  setState(() {
                    _giftsStream = _giftsStream!.map((gifts) {
                      gifts.sort((a, b) => a.category.compareTo(b.category));
                      return gifts;
                    }).asBroadcastStream();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Status', style: TextStyle(color: Colors.brown)),
                onTap: () {
                  setState(() {
                    _giftsStream = _giftsStream!.map((gifts) {
                      gifts.sort((a, b) => a.status.compareTo(b.status));
                      return gifts;
                    }).asBroadcastStream();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
