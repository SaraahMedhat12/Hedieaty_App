import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController eventController = EventController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await eventController.loadEventsForLoggedInUser();
    setState(() {}); // Refresh UI after loading events
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty - Event List'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _showSortOptions();
            },
          ),
        ],
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
                    onPressed: _showAddEventDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add New Event'),
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
                    itemCount: eventController.events.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.brown, width: 1),
                        ),
                        child: ListTile(
                          title: Text(
                            eventController.events[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Category: ${eventController.events[index]['category']} | Status: ${eventController.events[index]['status']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.brown),
                                onPressed: () {
                                  _showEditEventDialog(index);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.brown),
                                onPressed: () {
                                  setState(() {
                                    eventController.deleteEvent(index);
                                  });
                                },
                              ),
                            ],
                          ),
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
    String? selectedCategory;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: ['Birthday', 'Anniversary', 'Graduation']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Event Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.brown,
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedCategory != null) {
                  await eventController.addEventForLoggedInUser(
                    nameController.text,
                    selectedCategory!,
                    selectedDate,
                  );
                  _loadEvents();
                  Navigator.of(context).pop();
                } else {
                  print('Name or category is empty!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(int index) {
    TextEditingController nameController =
    TextEditingController(text: eventController.events[index]['name']);
    TextEditingController categoryController =
    TextEditingController(text: eventController.events[index]['category']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Event Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.brown,
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  await eventController.editEvent(
                    index,
                    nameController.text,
                    categoryController.text,
                  );
                  _loadEvents();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
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
                title: Text('Sort by Name'),
                onTap: () {
                  setState(() {
                    eventController.events.sort((a, b) => a['name'].compareTo(b['name']));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Category'),
                onTap: () {
                  setState(() {
                    eventController.events.sort(
                            (a, b) => a['category'].compareTo(b['category']));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Status'),
                onTap: () {
                  setState(() {
                    eventController.events.sort(
                            (a, b) => a['status'].compareTo(b['status']));
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
