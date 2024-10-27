import 'package:flutter/material.dart';
import '../controllers/gift_details_controller.dart';

class GiftDetailsPage extends StatefulWidget {
  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftDetailsController _controller = GiftDetailsController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedStatus = 'Available'; // Default status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Details"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
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
          // Form with top padding
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Form(
                    key: _formKey, // Assign the key to the form
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gift Name',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextFormField(
                            controller: _controller.giftNameController,
                            decoration: InputDecoration(),
                            validator: (value) => value!.isEmpty ? 'Please enter a gift name' : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Description',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextFormField(
                            controller: _controller.descriptionController,
                            decoration: InputDecoration(),
                            validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Category',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextFormField(
                            controller: _controller.categoryController,
                            decoration: InputDecoration(),
                            validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Price',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextFormField(
                            controller: _controller.priceController,
                            decoration: InputDecoration(),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
                          ),
                          SizedBox(height: 20),

                          // Image upload field
                          GestureDetector(
                            onTap: () {
                              // Image upload functionality will be implemented later
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.brown, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'Tap to upload an image',
                                  style: TextStyle(color: Colors.brown),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Text(
                            'Status',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(),
                            items: <String>['Available', 'Pledged'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue!;
                                _controller.isPledged = newValue == 'Pledged'; // Update pledge status
                                if (_controller.isPledged) {
                                  // Clear other fields if the gift is pledged
                                  _controller.clearFields();
                                }
                              });
                            },
                            validator: (value) => value == null ? 'Please select a status' : null,
                          ),

                          SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Logic to save the gift details would go here
                                    print('Gift Name: ${_controller.giftNameController.text}');
                                    print('Description: ${_controller.descriptionController.text}');
                                    print('Category: ${_controller.categoryController.text}');
                                    print('Price: ${_controller.priceController.text}');
                                    print('Is Pledged: ${_controller.isPledged}');

                                    // Reset the form
                                    _controller.clearFields();
                                    _selectedStatus = 'Available'; // Reset status
                                    _formKey.currentState!.reset(); // Reset the form state
                                    setState(() {}); // Update UI
                                  }
                                },
                                child: Text('Save Gift Details'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GiftDetailsPage(),
  ));
}
