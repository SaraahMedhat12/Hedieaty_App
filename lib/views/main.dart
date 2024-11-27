import 'package:flutter/material.dart';
import 'database.dart';
import 'event_list.dart';
import 'pledged_gifts.dart';
import 'profile.dart';
import 'gift_list.dart';
import 'package:sqflite/sqflite.dart'; // For SQLite database operations
import 'package:path/path.dart'; // For constructing file paths

//import 'gift_details.dart';

// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: HomePage(),
//   ));
// }
//
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of widgets for each page
  List<Widget> _pages = [
    HomePageContent(), // Home page content
    EventListPage(),   // Event page content
    PledgedGiftsPage(), // Pledged Gifts page content
    GiftListPage(eventName: 'Birthday Party'), //gift list content
    // GiftDetailsPage(), //gift details content
    ProfilePage(),     // Profile page content

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // Add friend functionality (via contact list or manually)
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      )
          : null, // Only show FAB on the home page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.card_giftcard),
          //   label: 'Gift Details',
          // ),
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

// Home page content without the bottom nav bar
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
    return Stack(
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
                width: double.maxFinite,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to create new event/list page
                  },
                  icon: Icon(Icons.create),
                  label: Text('Create Your Own Event/List'),
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
                        trailing: Icon(Icons.arrow_forward_ios),
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
    );
  }
}
