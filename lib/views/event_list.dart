import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friend_gift_list.dart';


class EventListPage extends StatefulWidget {
  final String? friendId; // Optional friend ID

  EventListPage({this.friendId});

  get friendName => null; // Default is null for logged-in user

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController eventController = EventController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final bool useFirebase = true;
  List<Map<String, dynamic>> _events = [];

  get event => null;


  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (widget.friendId != null && widget.friendId!.isNotEmpty) {
      // For friend's events, always load from Firebase
      await eventController.loadEventsFromFirebase(widget.friendId!);
    } else {
      // For the logged-in user, choose between Firebase and local DB
      if (useFirebase) {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await eventController.loadEventsFromFirebase(userId);
        }
      } else {
        await eventController.loadEventsForLoggedInUser();
      }
    }
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.friendId == null
              ? 'My Event List' // For the logged-in user
              : 'Friend\'s Event List', // For the friend's list
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Add New Event Button (For logged-in user only)
                if (widget.friendId == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showAddEventDialog,
                      icon: Icon(Icons.add),
                      label: Text('Add New Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                // View Friend's Gift List Button
                if (widget.friendId != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Ensure valid friendId
                        if (widget.friendId != null && widget.friendId!.isNotEmpty) {
                          print("Navigating to FriendGiftListPage...");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendGiftListPage(
                                friendId: widget.friendId!,
                                friendName: widget.friendName ?? 'Unnamed Friend',
                                eventId: null, // Event ID will be selected later in dropdown
                              ),
                            ),
                          );
                        } else {
                          print("Error: Friend ID is null or empty.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Invalid friend. Cannot navigate.")),
                          );
                        }
                      },
                      icon: Icon(Icons.card_giftcard),
                      label: Text('View Friend\'s Gift List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                // Event List
                Expanded(
                  child: eventController.events.isEmpty
                      ? Center(
                    child: Text(
                      widget.friendId == null
                          ? 'No events found. Add one now!'
                          : 'No events found for this friend.',
                      style: TextStyle(color: Colors.brown, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: eventController.events.length,
                    itemBuilder: (context, index) {
                      final event = eventController.events[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.brown, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            event['name'] ?? 'Unnamed Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                          subtitle: Text(
                            'Category: ${event['category'] ?? 'N/A'} | Status: ${event['status'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.brown[600]),
                          ),
                          trailing: widget.friendId == null
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.brown),
                                onPressed: () => _showEditEventDialog(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.brown),
                                onPressed: () async {
                                  if (useFirebase) {
                                    await eventController.deleteEventFromFirebase(
                                      _auth.currentUser!.uid,
                                      event['id'],
                                      event['date'],
                                    );
                                  } else {
                                    await eventController.deleteEvent(index);
                                  }
                                  _loadEvents();
                                },
                              ),
                            ],
                          )
                              : null, // No edit/delete for friend's events
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




  void _showAddEventDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Add New Event', style: TextStyle(color: Colors.brown)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, 'Event Name'),
                  SizedBox(height: 10),
                  _buildTextField(locationController, 'Location'),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                    items: ['Birthday', 'Anniversary', 'Graduation']
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Event Category',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildDateField(dateController, setDialogState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.brown)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      selectedCategory != null &&
                      dateController.text.isNotEmpty) {
                    if (useFirebase) {
                      await eventController.addEventToFirebase(
                        _auth.currentUser!.uid,
                        {
                          'name': nameController.text,
                          'category': selectedCategory!,
                          'location': locationController.text,
                          'date': dateController.text,
                          'description': '',
                        },
                      );
                    } else {
                      await eventController.addEventForLoggedInUser(
                        nameController.text,
                        selectedCategory!,
                        locationController.text,
                        DateTime.parse(dateController.text),
                      );
                    }
                    _loadEvents();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(TextEditingController dateController, Function setDialogState) {
    return TextField(
      controller: dateController,
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setDialogState(() {
            dateController.text =
            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Event Date',
        labelStyle: TextStyle(color: Colors.brown),
        border: OutlineInputBorder(),
      ),
    );
  }


void _showEditEventDialog(int index) {
    final event = eventController.events[index];
    TextEditingController nameController = TextEditingController(text: event['name']);
    TextEditingController locationController = TextEditingController(text: event['location']);
    TextEditingController dateController = TextEditingController(
        text: DateTime.parse(event['date']).toLocal().toString().split(' ')[0]);
    String? selectedCategory = event['category'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Event', style: TextStyle(color: Colors.brown)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Event Name',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: ['Birthday', 'Anniversary', 'Graduation']
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Event Category',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(event['date']),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          dateController.text =
                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Event Date',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.brown)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      selectedCategory != null &&
                      dateController.text.isNotEmpty) {
                    await eventController.editEvent(
                      index,
                      nameController.text,
                      selectedCategory!,
                      locationController.text,
                      DateTime.parse(dateController.text),
                    );
                    _loadEvents();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSortOptions() {
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
                    final mutableEvents = List<Map<String, dynamic>>.from(eventController.events);
                    mutableEvents.sort((a, b) => a['name'].compareTo(b['name']));
                    eventController.events = mutableEvents;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Category', style: TextStyle(color: Colors.brown)),
                onTap: () {
                  setState(() {
                    final mutableEvents = List<Map<String, dynamic>>.from(eventController.events);
                    mutableEvents.sort((a, b) => a['category'].compareTo(b['category']));
                    eventController.events = mutableEvents;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Status', style: TextStyle(color: Colors.brown)),
                onTap: () {
                  setState(() {
                    final mutableEvents = List<Map<String, dynamic>>.from(eventController.events);
                    mutableEvents.sort((a, b) => a['status'].compareTo(b['status']));
                    eventController.events = mutableEvents;
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


