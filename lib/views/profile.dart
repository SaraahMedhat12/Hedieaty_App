import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import 'pledged_gifts.dart';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController(); // Instantiate the controller

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
            Navigator.pop(context); // Navigate back
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
                  // Profile Image
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name
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

                  // Role (Engineer)
                  Center(
                    child: Text(
                      'Engineer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Profile details
                  _buildProfileDetail('Phone Number', _controller.phoneNumber, Icons.phone),
                  _buildProfileDetail('Birthday', '${_controller.birthday.toLocal()}'.split(' ')[0], Icons.cake),

                  SizedBox(height: 20),

                  // Button to update personal information
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showUpdateDialog(); // Show dialog to update personal information
                      },
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

                  // Notification Settings
                  Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown[900],
                    ),
                  ),
                  SwitchListTile(
                    title: Text('Receive Notifications'),
                    value: _controller.notificationsEnabled,
                    activeColor: Colors.brown,
                    onChanged: (bool value) {
                      setState(() {
                        _controller.toggleNotifications(value); // Update notification setting
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  Divider(thickness: 10, color: Colors.brown),
                  SizedBox(height: 50),

                  // Created Events Section
                  Text(
                    'Your Created Events',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown[900],
                    ),
                  ),



                  // Events List
                  _buildEventsList(),

                  SizedBox(height: 20),
                  Divider(thickness: 10, color: Colors.brown),
                  SizedBox(height: 50),

                  // Link to My Pledged Gifts Page
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

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle logout logic here
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

  // Helper widget to build profile details
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build events list
  Widget _buildEventsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
      itemCount: _controller.events.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(_controller.events[index]),
            subtitle: Text('Associated Gifts: ${_controller.associatedGifts.join(", ")}'),
          ),
        );
      },
    );
  }

  // Method to show update dialog
  void _showUpdateDialog() {
    final TextEditingController phoneController = TextEditingController(text: _controller.phoneNumber);
    final TextEditingController birthdayController = TextEditingController(text: '${_controller.birthday.toLocal()}'.split(' ')[0]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Personal Information'),
          backgroundColor: Colors.brown[50],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _controller.updatePhoneNumber(phoneController.text);
                  _controller.updateBirthday(DateTime.parse(birthdayController.text));
                });
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


