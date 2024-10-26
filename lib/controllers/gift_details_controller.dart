import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File type

class GiftDetailsController {
  final TextEditingController giftNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? giftImagePath; // Store the image path (currently unused)
  bool isPledged = false;

  // Function to pick an image from the gallery
  /*
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      giftImagePath = image.path; // Store the image path
    }
  }
  */

  // Function to clear all fields
  void clearFields() {
    giftNameController.clear();
    descriptionController.clear();
    categoryController.clear();
    priceController.clear();
    giftImagePath = null; // Clear the image path
  }
}
