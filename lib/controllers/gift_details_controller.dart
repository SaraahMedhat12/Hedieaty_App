import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart'; // Required for File type

class GiftDetailsController {
  final TextEditingController giftNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? giftImagePath; // Store the uploaded image URL
  bool isPledged = false;

  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<String?> uploadToFirebase(File file) async {
    try {
      // Create a reference in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('gift_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');

      // Upload the file
      final uploadTask = storageRef.putFile(file);

      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null; // Return null in case of an error
    }
  }

  /// Allows the user to pick a file using the file picker.
  Future<File?> pickFile() async {
    try {
      // Open the file picker for image files
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!); // Return the selected file
      }
    } catch (e) {
      print("Error picking file: $e");
    }
    return null; // Return null if no file is selected
  }

  /// Clears all input fields and resets the image path.
  void clearFields() {
    giftNameController.clear();
    descriptionController.clear();
    categoryController.clear();
    priceController.clear();
    giftImagePath = null; // Reset the image path
  }

  /// Disposes of all TextEditingControllers.
  void dispose() {
    giftNameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
  }
}
