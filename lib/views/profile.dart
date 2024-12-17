import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../controllers/gift_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/gift.dart';
import 'login.dart';
import 'pledged_gifts.dart';
import '../controllers/gift_controller.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  final GiftController _giftController = GiftController();


  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _controller.loadUserProfile(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bg5.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      _controller.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.brown[900],
                      ),
                    ),
                  ),
                  _buildProfileDetail('Phone Number', _controller.phoneNumber, Icons.phone),
                  _buildProfileDetail('Birthday', '${_controller.birthday.toLocal()}'.split(' ')[0], Icons.cake),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showUpdateDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text('Update Personal Information'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 10, color: Colors.brown),
                  SizedBox(height: 50),
                  Text(
                    'Your Created Events',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown[900],
                    ),
                  ),
                  _buildEventsList(),
                  SizedBox(height: 20),
                  Divider(thickness: 10, color: Colors.brown),
                  SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('My Pledged Gifts', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 10, color: Colors.brown),
                  SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Logout', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: Colors.brown[700])),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[900])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final userId = AuthService.getCurrentUser()?.uid;

    if (userId == null) {
      return Center(child: Text("Error: User not authenticated"));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _giftController.loadEventsForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading events: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Text("No events available.", style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          shrinkWrap: true, // Ensures the ListView wraps only its content
          physics: NeverScrollableScrollPhysics(), // Prevents extra scrolling
          padding: EdgeInsets.symmetric(horizontal: 8), // Adjust padding
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final eventName = event['name'] ?? 'Unnamed Event';
            final eventId = event['id'] ?? '';

            return Container(
              margin: EdgeInsets.only(bottom: 12), // Adjust spacing between items
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Card(
                elevation: 2, // Reduce elevation to make it cleaner
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    eventName.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                      fontSize: 18,
                    ),
                  ),
                  subtitle: StreamBuilder<List<Gift>>(
                    stream: _giftController.loadGiftsForEvent(eventId),
                    builder: (context, giftSnapshot) {
                      if (giftSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading gifts...', style: TextStyle(fontSize: 14));
                      }

                      final gifts = giftSnapshot.data ?? [];
                      return Text(
                        'Associated Gifts: ${gifts.isNotEmpty ? gifts.map((gift) => gift.name).join(", ") : "No gifts available"}',
                        style: TextStyle(fontSize: 14, color: Colors.brown[600]),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }




  Future<void> _loadEvents() async {
    if (_controller.events.isEmpty) {
      await _controller.loadEventsFromFirebase("your_firebase_user_id"); // Pass the user ID
      print("Events Loaded: ${_controller.events}");
    }
  }




  void _showUpdateDialog() {
    final phoneController = TextEditingController(text: _controller.phoneNumber);
    final birthdayController = TextEditingController(text: '${_controller.birthday.toLocal()}'.split(' ')[0]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Personal Information'),
          backgroundColor: Colors.brown[50],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _controller.updateProfile(
                  widget.userId,
                  newPhoneNumber: phoneController.text,
                  newBirthday: DateTime.parse(birthdayController.text),
                );
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}