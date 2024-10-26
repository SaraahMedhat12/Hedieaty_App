import 'package:flutter/material.dart';

class SignupControllers {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    passwordController.dispose();
  }
}

String? validateField(String? value, String labelText) {
  if (value == null || value.isEmpty) {
    return '$labelText is required';
  }
  return null;
}
