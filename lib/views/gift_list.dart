import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../controllers/gift_controller.dart';
import 'gift_details.dart';

void main() {
  runApp(MaterialApp(
    home: GiftListPage(eventName: 'Birthday Party'), // Initial page with eventName
  ));
}

class GiftListPage extends StatefulWidget {
  final String eventName;

  GiftListPage({required this.eventName});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _controller = GiftController();

  String _sortBy = 'name'; // Default sorting method
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _controller.loadGiftsForEvent(widget.eventName); // Load gifts for the event
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.eventName} - Gift List'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // Show a popup menu to select sorting
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  PopupMenuItem<String>(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  PopupMenuItem<String>(
                    value: 'category',
                    child: Text('Sort by Category'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text('Sort by Status'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg5.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content over the background
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                _buildGiftList(),
                SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Gift List with sorting and visual indicators
  Widget _buildGiftList() {
    List<Gift> sortedGifts = _controller.getSortedGifts(_sortBy, _sortAscending);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedGifts.length,
      itemBuilder: (context, index) {
        Gift gift = sortedGifts[index];
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          color: gift.isPledged ? Colors.brown[200] : Colors.white,
          child: ListTile(
            title: Text(
              gift.name,
              style: TextStyle(
                color: (gift.name == 'Watch' || gift.name == 'Shoes' || gift.name == 'Book')
                    ? Colors.black
                    : Colors.brown,
              ),
            ),
            subtitle: Text(
              'Category: ${gift.category}',
              style: TextStyle(color: Colors.brown),
            ),
            trailing: gift.isPledged
                ? Icon(Icons.lock, color: Colors.brown)
                : _buildGiftActions(gift),
          ),
        );
      },
    );
  }

  // Build action buttons for adding, editing, and deleting gifts
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(), // Navigate to GiftDetailsPage
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add New Gift'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build actions for each gift (Edit/Delete)
  Widget _buildGiftActions(Gift gift) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.brown),
          onPressed: () {
            if (!gift.isPledged) _showEditGiftDialog(gift);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.brown),
          onPressed: () {
            if (!gift.isPledged) {
              _controller.deleteGift(gift.id);
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  // Dialog to edit an existing gift
  void _showEditGiftDialog(Gift gift) {
    final TextEditingController nameController = TextEditingController(text: gift.name);
    final TextEditingController categoryController = TextEditingController(text: gift.category);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Gift Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                  _controller.updateGift(gift.id, nameController.text, categoryController.text);
                  setState(() {});
                  Navigator.of(context).pop();
                }
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

