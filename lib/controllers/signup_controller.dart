import 'package:flutter/material.dart';
import '../views/database.dart';

class SignupControllers {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final birthdayController = TextEditingController();
  final passwordController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    passwordController.dispose();
  }

  // Create a new user and insert into the database
  Future<bool> createUser() async {
    try {
      // Prepare the user data
      Map<String, dynamic> user = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'preferences': 'Phone: ${phoneController.text.trim()}, Birthday: ${birthdayController.text.trim()}',
      };

      // Insert user data into the database
      await _dbHelper.insertUser(user);
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Check if email exists in the database
  Future<bool> isEmailRegistered(String email) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      return user != null; // Return true if user exists
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Validate user input
  String? validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    if (fieldName == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address.';
    }

    if (fieldName == 'Phone Number' && !RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number.';
    }

    if (fieldName == 'Password' && value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    if (fieldName == 'Birthday (YYYY-MM-DD)' &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'Please enter a valid date in the format YYYY-MM-DD.';
    }

    return null; // Return null if the value is valid
  }

  // Fetch all users from the database
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      return await _dbHelper.getAllUsers();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
