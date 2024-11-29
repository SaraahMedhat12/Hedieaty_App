import 'package:sqflite/sqflite.dart';
import '../views/database.dart';

class ProfileController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String username = '';
  String phoneNumber = '';
  DateTime birthday = DateTime.now();
  bool notificationsEnabled = true;
  List<String> events = ['Birthday Party', 'Wedding'];
  List<String> associatedGifts = ['Gift Card', 'Watch', 'Jewelry'];

  // Initialize profile data for the logged-in user
  Future<void> loadUserProfile(int userId) async {
    try {
      final user = await _dbHelper.getAllUsers();
      final userData = user.firstWhere((u) => u['id'] == userId);

      username = userData['name'] ?? 'Unknown';
      phoneNumber = userData['preferences'].split(',')[0].split(':')[1].trim();
      birthday = DateTime.parse(userData['preferences'].split(',')[1].split(':')[1].trim());
      // Add events and associatedGifts if needed
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

      await _dbHelper.updateUser({
        'id': userId,
        'preferences': 'Phone: $phoneNumber, Birthday: ${birthday.toIso8601String()}',
      });
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}