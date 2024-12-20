import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../service/auth_service.dart';
import '../controllers/gift_controller.dart'; // Import GiftController
import '../service/database.dart'; // Local database remains
import '../service/firebase.dart'; // FirebaseService import for events
import '../models/gift.dart'; // Import the Gift model here

class ProfileController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GiftController _giftController = GiftController(); // Initialize GiftController
  final FirebaseService _firebaseService = FirebaseService(); // Firebase Service

  String _selectedEventId = '';
  String username = '';
  String phoneNumber = '';
  DateTime birthday = DateTime.now();
  bool notificationsEnabled = true;
  List<String> events = [];
  List<Gift> _associatedGifts = []; // Fixed naming: added underscore for consistency

  // Getter for associated gifts
  List<Gift> get associatedGifts => _associatedGifts;

  // Initialize profile data for the logged-in user
  Future<void> loadUserProfile(int userId) async {
    try {
      // Fetch profile info from the local database
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

        // Fetch Firebase UID using username
        String? firebaseUserId = await _getFirestoreUserIdByUsername(username);

        if (firebaseUserId != null) {
          // Load events using Firebase UID
          await loadEventsFromFirebase(firebaseUserId);
        } else {
          print("Error: Firebase User ID not found for username: $username");
        }
      } else {
        print('No user data found in the local database.');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Fetch Firestore User ID by Username
  Future<String?> _getFirestoreUserIdByUsername(String username) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreUserId = snapshot.docs.first.id;
        print("Firestore User ID found: $firestoreUserId for username: $username");
        return firestoreUserId;
      } else {
        print("No Firestore user found for username: $username");
        return null;
      }
    } catch (e) {
      print("Error fetching Firestore User ID by username: $e");
      return null;
    }
  }

  // Load events from Firebase using Firebase UID
  Future<void> loadEventsFromFirebase(String firebaseUserId) async {
    try {
      final firebaseEvents = await _firebaseService.getEventsFromFirebase(firebaseUserId);

      if (firebaseEvents.isNotEmpty) {
        events = firebaseEvents.map<String>((event) => event['name'] ?? 'Unnamed Event').toList();

        // Fetch associated gifts for each event
        _associatedGifts.clear();
        for (var event in firebaseEvents) {
          final eventId = event['id']; // Assuming event['id'] is available
          final gifts = await getGiftsByEvent(eventId);
          _associatedGifts.addAll(gifts);
        }

        print("Events and gifts loaded successfully.");
      } else {
        print("No events found for Firebase User ID: $firebaseUserId");
        events = ['No events available'];
      }
    } catch (e) {
      print("Error loading events from Firebase: $e");
    }
  }


  // Fetch gifts by event ID
  Future<List<Gift>> getGiftsByEvent(String eventId) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        // Query Firestore to get the gifts for the specific event
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .get();

        // Map Firestore documents to Gift objects
        _associatedGifts = snapshot.docs.map((doc) {
          return Gift.fromMap(doc.id, doc.data());
        }).toList();

        print('Loaded ${_associatedGifts.length} gifts for event ID: $eventId');
        return _associatedGifts; // Return the fetched gifts
      } else {
        print('No user is logged in.');
        return [];
      }
    } catch (e) {
      print('Error loading gifts: $e');
      return [];
    }
  }

  // Update personal information in the local database
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

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    // Optionally save the value to Firebase or local storage
    print("Notifications Enabled: $notificationsEnabled");
  }
}
