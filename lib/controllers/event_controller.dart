import 'package:flutter/material.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventController {
  List<Map<String, dynamic>> events = []; // Events for the logged-in user
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load events for the currently logged-in user
  Future<void> loadEventsForLoggedInUser() async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      print('Loading events for userId: $userId');
      events = List<Map<String, dynamic>>.from(await _dbHelper.getAllEventsForUser(userId)); // Ensure a mutable list
      print('Events loaded: $events');
    } else {
      print('No user logged in!');
    }
  }



  // Add an event for the currently logged-in user
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

      // Prevent duplicate entries
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
    } else {
      print('No user logged in! Cannot add event.');
    }
  }


  // Delete an event for the logged-in user
  Future<void> deleteEvent(int index) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      final eventId = events[index]['id'];
      if (eventId != null) {
        await _dbHelper.deleteEventForUser(userId, eventId);

        await loadEventsForLoggedInUser(); // Reload events after deletion
        print('Event deleted: $eventId');
      } else {
        print('Event ID is null. Cannot delete event.');
      }
    } else {
      print('No user logged in! Cannot delete event.');
    }
  }


  Future<void> editEvent(int index, String name, String category,
      String location, DateTime date) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      // Create a new map for the updated event
      final updatedEvent = Map<String, dynamic>.from(events[index]);
      updatedEvent['name'] = name;
      updatedEvent['category'] = category;
      updatedEvent['location'] = location;
      updatedEvent['date'] = date.toIso8601String();
      updatedEvent['status'] = _determineEventStatus(date);

      await _dbHelper.updateEventForUser(userId, updatedEvent);

      await loadEventsForLoggedInUser(); // Reload events after editing
      print('Event updated: $updatedEvent');
    } else {
      print('No user logged in! Cannot edit event.');
    }
  }


  // Determine event status based on the date
  String _determineEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (eventDay.isBefore(today)) {
      return 'Past';
    } else if (eventDay.isAfter(today)) {
      return 'Upcoming';
    } else {
      return 'Current';
    }
  }

  // Load events for a specific friend
  Future<List<Map<String, dynamic>>> loadEventsForFriend(String friendId) async {
    try {
      events = await _dbHelper.getAllEventsForUser(int.parse(friendId));
      print('Events for friend $friendId: $events');
      return events;
    } catch (e) {
      print('Error loading events for friend: $e');
      return [];
    }
  }

  // Sync upcoming events count from Firebase to SQLite
  Future<void> syncUpcomingEventsFromFirebase() async {
    try {
      final userId = await _getUserIdFromPrefs();
      if (userId != null) {
        final userDoc =
        await _firestore.collection('users').doc(userId.toString()).get();

        final upcomingEvents = userDoc.data()?['upcomingEvents'] ?? 0;
        await _dbHelper.updateUpcomingEventsCount(userId, upcomingEvents);
        print('Synced upcoming events count: $upcomingEvents');
      } else {
        print('No local user ID found.');
      }
    } catch (e) {
      print('Error syncing upcoming events from Firebase: $e');
    }
  }

  // Retrieve userId from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
