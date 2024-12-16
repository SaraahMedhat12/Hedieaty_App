import 'package:flutter/material.dart';
import '../database.dart';
import 'event_list.dart';
import 'pledged_gifts.dart';
import 'profile.dart';
import 'gift_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase.dart'; // FirebaseService

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    EventListPage(),
    PledgedGiftsPage(),
    GiftListPage(eventName: '',),
    ProfilePage(userId: 0),
  ];

  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _updatePages() async {
    final userId = await _getUserIdFromPrefs();
    setState(() {
      _pages[4] = ProfilePage(userId: userId ?? 0);
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePages();
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      final userId = await _getUserIdFromPrefs();
      setState(() {
        _pages[4] = ProfilePage(userId: userId ?? 0);
      });
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
            onPressed: () {},
          ),
        ],
      )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.brown,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.brown[200],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Pledged'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Gifts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late FirebaseService _firebaseService;
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      List<Map<String, dynamic>> friendsList = await _firebaseService.getFriends();
      setState(() {
        _friends = friendsList;
      });
    } catch (e) {
      print("Error loading friends: $e");
    }
  }

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
                    label: Text('Add a New Event/Gift List'),
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
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      final name = friend['username'] ?? 'Unknown';
                      final profilePic = friend['profilePic'] ?? 'assets/bg2.jpeg';
                      final upcomingEvents = friend['upcomingEvents'] ?? 0;

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.brown, width: 1),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(profilePic),
                            radius: 30,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          subtitle: Text(
                            upcomingEvents > 0
                                ? 'Upcoming Events: $upcomingEvents'
                                : 'No Upcoming Events',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.brown),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventListPage(friendId: friend['uid']),
                              ),
                            );
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Friend',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String username = nameController.text.trim();

                if (username.isNotEmpty) {
                  await _firebaseService.addFriendByUsername(username);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend added successfully!')),
                  );
                  _loadFriends();
                }
              },
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListPage()),
                );
              },
              child: Text('Add Event'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(eventName: ''),
                  ),
                );
              },
              child: Text('Add Gift'),
            ),
          ],
        );
      },
    );
  }
}
