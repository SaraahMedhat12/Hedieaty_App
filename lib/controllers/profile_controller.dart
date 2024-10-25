import 'package:flutter/material.dart';

class ProfileController {
  String username = 'Sarah Medhat';
  String phoneNumber = '+201011973747';
  DateTime birthday = DateTime(2002, 6, 12);
  bool notificationsEnabled = true;
  List<String> events = ['Birthday Party', 'Wedding'];
  List<String> associatedGifts = ['Gift Card', 'Watch', 'Jewelry'];

  // Method to update personal information
  void updatePhoneNumber(String newPhoneNumber) {
    phoneNumber = newPhoneNumber;
  }

  void updateBirthday(DateTime newBirthday) {
    birthday = newBirthday;
  }

  void toggleNotifications(bool isEnabled) {
    notificationsEnabled = isEnabled;
  }
}
