import 'package:flutter/material.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase.dart'; // Import FirebaseService

class EventController {
  List<Map<String, dynamic>> events = []; // Events for the logged-in user
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService(); // Add FirebaseService instance

  final bool useFirebase = true; // Set this flag based on your requirement

  // Load events for the currently logged-in user (Firebase or Local)
  Future<void> loadEventsForLoggedInUser() async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      print('Loading events for userId: $userId');
      if (useFirebase) {
        await loadEventsFromFirebase(userId.toString());
      } else {
        events = List<Map<String, dynamic>>.from(await _dbHelper.getAllEventsForUser(userId));
        print('Events loaded: $events');
      }
    } else {
      print('No user logged in!');
    }
  }

  // Add an event for the currently logged-in user (Firebase or Local)
  Future<void> addEventForLoggedInUser(
      String name, String category, String location, DateTime date) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      String status = _determineEventStatus(date);
      Map<String, dynamic> event = {
        'name': name,
        'category': category,
        'location': location,
        'date': date.toIso8601String(),
        'status': status,
        'user_id': userId,
      };

      if (useFirebase) {
        await addEventToFirebase(userId.toString(), event);
      } else {
        final existingEvents = await _dbHelper.getAllEventsForUser(userId);
        bool isDuplicate = existingEvents.any((e) =>
        e['name'] == name &&
            e['date'] == date.toIso8601String() &&
            e['location'] == location);
        if (!isDuplicate) {
          await _dbHelper.insertEvent(event);
          if (status == 'Upcoming') {
            await _dbHelper.incrementUpcomingEvents(userId);
          }
          await loadEventsForLoggedInUser(); // Reload events after adding
          print('Event added: $event');
        } else {
          print('Duplicate event detected. Skipping insertion.');
        }
      }
    } else {
      print('No user logged in! Cannot add event.');
    }
  }

  // Delete an event for the logged-in user (Firebase or Local)
  Future<void> deleteEvent(int index) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      final eventId = events[index]['id'];
      if (eventId != null) {
        if (useFirebase) {
          await deleteEventFromFirebase(userId.toString(), eventId, events[index]['date']);
        } else {
          await _dbHelper.deleteEventForUser(userId, eventId);
          await loadEventsForLoggedInUser(); // Reload events after deletion
          print('Event deleted: $eventId');
        }
      } else {
        print('Event ID is null. Cannot delete event.');
      }
    } else {
      print('No user logged in! Cannot delete event.');
    }
  }

  // Edit an event for the logged-in user (Firebase or Local)
  Future<void> editEvent(int index, String name, String category,
      String location, DateTime date) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      final updatedEvent = Map<String, dynamic>.from(events[index]);
      updatedEvent['name'] = name;
      updatedEvent['category'] = category;
      updatedEvent['location'] = location;
      updatedEvent['date'] = date.toIso8601String();
      updatedEvent['status'] = _determineEventStatus(date);

      if (useFirebase) {
        await editEventInFirebase(userId.toString(), events[index]['id'], updatedEvent);
      } else {
        await _dbHelper.updateEventForUser(userId, updatedEvent);
        await loadEventsForLoggedInUser(); // Reload events after editing
        print('Event updated: $updatedEvent');
      }
    } else {
      print('No user logged in! Cannot edit event.');
    }
  }

  // Sync events from Firebase to SQLite
  Future<void> syncEventsFromFirebase(String userId) async {
    try {
      final eventsFromFirebase = await _firebaseService.getEventsFromFirebase(userId);
      for (final event in eventsFromFirebase) {
        final Map<String, dynamic> localEvent = {
          'name': event['name'],
          'category': event['category'] ?? '',
          'location': event['location'] ?? '',
          'date': event['date'],
          'status': _determineEventStatus(DateTime.parse(event['date'])),
          'user_id': int.parse(userId),
          'description': event['description'] ?? '',
        };

        final existingEvents = await _dbHelper.getAllEventsForUser(int.parse(userId));
        final isDuplicate = existingEvents.any((e) =>
        e['name'] == localEvent['name'] &&
            e['date'] == localEvent['date'] &&
            e['location'] == localEvent['location']);
        if (!isDuplicate) {
          await _dbHelper.insertEventForUser(int.parse(userId), localEvent);
        } else {
          print('Duplicate event detected: ${localEvent['name']}. Skipping insertion.');
        }
      }
      print("Events synced from Firebase to local database for user: $userId");
    } catch (e) {
      print("Error syncing events from Firebase: $e");
    }
  }

  // Retrieve userId from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Firebase-specific methods
  Future<void> loadEventsFromFirebase(String userId) async {
    try {
      events = await _firebaseService.getEventsFromFirebase(userId);
      print("Events loaded from Firebase for user $userId: $events");
    } catch (e) {
      print("Error loading events from Firebase: $e");
    }
  }

  Future<void> addEventToFirebase(String userId, Map<String, dynamic> event) async {
    try {
      await _firebaseService.addEventInFirebase(userId, event);
      await loadEventsFromFirebase(userId); // Reload events after adding
    } catch (e) {
      print("Error adding event to Firebase: $e");
    }
  }

  Future<void> editEventInFirebase(
      String userId, String eventId, Map<String, dynamic> updatedEvent) async {
    try {
      await _firebaseService.editEventInFirebase(userId, eventId, updatedEvent);
      await loadEventsFromFirebase(userId); // Reload events after editing
    } catch (e) {
      print("Error editing event in Firebase: $e");
    }
  }

  Future<void> deleteEventFromFirebase(String userId, String eventId, String eventDate) async {
    try {
      await _firebaseService.deleteEventFromFirebase(userId, eventId, eventDate);
      await loadEventsFromFirebase(userId); // Reload events after deletion
    } catch (e) {
      print("Error deleting event from Firebase: $e");
    }
  }

  // Helper function to determine event status
  String _determineEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    if (eventDate.isBefore(now)) return 'Past';
    if (eventDate.isAfter(now)) return 'Upcoming';
    return 'Current';
  }
}
