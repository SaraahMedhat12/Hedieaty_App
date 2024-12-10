import 'package:sqflite/sqflite.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String username = '';
  String phoneNumber = '';
  DateTime birthday = DateTime.now();
  bool notificationsEnabled = true;
  List<String> events = [];
  List<String> associatedGifts = [];

  // Initialize profile data for the logged-in user
  Future<void> loadUserProfile(int userId) async {
    try {
      final user = await _dbHelper.getUserById(userId);

      if (user != null && user.isNotEmpty) {
        // Populate profile data
        username = user['name'] ?? 'Unknown';

        final preferences = user['preferences'] ?? '';
        if (preferences.isNotEmpty) {
          final prefsList = preferences.split(',');
          if (prefsList.length > 1) {
            phoneNumber = prefsList[0].split(':')[1].trim();
            birthday = DateTime.parse(prefsList[1].split(':')[1].trim());
          }
        }

        // Fetch events for the user
        final userEvents = await _dbHelper.getAllEventsForUser(userId);
        if (userEvents != null && userEvents.isNotEmpty) {
          events = userEvents.map<String>((event) => event['name'] as String).toList(); // Map to List<String>

          // Fetch associated gifts for each event
          for (var event in userEvents) {
            if (event['id'] != null) {
              final gifts = await _dbHelper.getAllGiftsForEvent(event['id']);
              if (gifts != null && gifts.isNotEmpty) {
                associatedGifts.addAll(gifts.map<String>((gift) => gift['name'] as String).toList()); // Map to List<String>
              }
            }
          }
        } else {
          print('No events found for this user.');
          events = ['No events available'];  // Add a message indicating no events
        }
      } else {
        print('No user data found.');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Update personal information in the database
  Future<void> updateProfile(int userId, {String? newPhoneNumber, DateTime? newBirthday}) async {
    try {
      if (newPhoneNumber != null) {
        phoneNumber = newPhoneNumber;
      }
      if (newBirthday != null) {
        birthday = newBirthday;
      }

      final updatedPreferences = 'Phone: $phoneNumber, Birthday: ${birthday.toIso8601String()}';

      final result = await _dbHelper.updateUser({
        'id': userId,
        'preferences': updatedPreferences,
      });

      if (result != null && result > 0) {
        print('User profile updated successfully.');
      } else {
        print('Failed to update user profile.');
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  // Retrieve the userId from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
