import 'package:flutter/material.dart';
import '../database.dart';
import 'event_list.dart';
import 'pledged_gifts.dart';
import 'profile.dart';
import 'gift_list.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of widgets for each page
  final List<Widget> _pages = [
    HomePageContent(), // Home page content
    EventListPage(), // Event page content
    PledgedGiftsPage(), // Pledged Gifts page content
    GiftListPage(eventName: 'Birthday Party'), // Gift list content
    ProfilePage(userId: 0), // Set default userId to 0 here
  ];

  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('Retrieved userId: $userId'); // Debugging statement
    return userId;
  }

  void _navigateToProfilePage(BuildContext context) async {
    final userId = await _getUserIdFromPrefs(); // Retrieve the userId from SharedPreferences

    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId), // Pass the userId to ProfilePage
        ),
      );
    } else {
      print('User is not logged in!');
    }
  }

  void _updatePages() async {
    final userId = await _getUserIdFromPrefs();
    setState(() {
      _pages[4] = ProfilePage(userId: userId ?? 0); // Dynamically pass userId to ProfilePage, defaulting to 0
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePages(); // Ensure ProfilePage is initialized with the userId
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) { // Assuming 4 is the index for the ProfilePage
      final userId = await _getUserIdFromPrefs();
      if (userId != null) {
        setState(() {
          _pages[4] = ProfilePage(userId: userId);
        });
      } else {
        print('User is not logged in!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text('Hedieaty - Home Page'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      )
          : null, // AppBar only appears on the home page (index 0)
      body: _pages[_selectedIndex], // Display the content of the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.brown, // Brown background
        selectedItemColor: Colors.white, // White for selected items
        unselectedItemColor: Colors.brown[200], // Lighter brown for unselected items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pledged',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed, // Ensures all icons are visible
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Sarah',
      'profilePic': 'assets/bg2.jpeg',
      'upcomingEvents': 1,
    },
    {
      'name': 'Mariam',
      'profilePic': 'assets/p3.jpeg',
      'upcomingEvents': 0,
    },
    {
      'name': 'Malak',
      'profilePic': 'assets/bg3.jpeg',
      'upcomingEvents': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendWizard(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddWizardDialog(context),
                    icon: Icon(Icons.create),
                    label: Text('Add Event or Gift'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.brown, width: 1),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(friends[index]['profilePic']),
                            radius: 30,
                          ),
                          title: Text(
                            friends[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          subtitle: Text(
                            friends[index]['upcomingEvents'] > 0
                                ? 'Upcoming Events: ${friends[index]['upcomingEvents']}'
                                : 'No Upcoming Events',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.brown),
                          onTap: () {
                            // Navigate to friend's gift list page
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendWizard(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Friend',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Friend\'s Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Friend\'s Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.brown,
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  print(
                      'Friend added: Name: ${nameController.text}, Phone: ${phoneController.text}');
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  print('Fields are empty!'); // Debugging statement
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text('Add Friend'),
            ),
          ],
        );
      },
    );
  }

  void _showAddWizardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Action',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Would you like to add an Event to your list or add a Gift?',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text('Add Event'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GiftListPage(eventName: 'Gifts')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text('Add Gift'),
            ),
          ],
        );
      },
    );
  }
}