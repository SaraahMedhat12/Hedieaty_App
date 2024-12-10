import 'package:flutter/material.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventController {
  List<Map<String, dynamic>> events = []; // Events for the logged-in user
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Load events for the currently logged-in user
  Future<void> loadEventsForLoggedInUser() async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      print('Loading events for userId: $userId'); // Debugging statement
      events = await _dbHelper.getAllEventsForUser(userId);
      print('Events loaded: $events'); // Debugging statement
    } else {
      print('No user logged in!'); // Debugging statement
    }
  }

  // Add an event for the currently logged-in user
  Future<void> addEventForLoggedInUser(String name, String category, DateTime date) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      Map<String, dynamic> event = {
        'name': name,
        'category': category,
        'date': date.toIso8601String(),
        'status': 'Upcoming',
        'user_id': userId,
      };
      await _dbHelper.insertEvent(event);
      print('Event added: $event'); // Debugging statement
      await loadEventsForLoggedInUser(); // Reload events after adding
    } else {
      print('No user logged in! Cannot add event.'); // Debugging statement
    }
  }

  // Edit an event
  Future<void> editEvent(int index, String name, String category) async {
    final event = events[index];
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      event['name'] = name;
      event['category'] = category;
      await _dbHelper.updateEventForUser(userId, event);
      print('Event updated: $event'); // Debugging statement
      await loadEventsForLoggedInUser(); // Reload events after editing
    }
  }

  // Delete an event
  Future<void> deleteEvent(int index) async {
    final eventId = events[index]['id'];
    final userId = await _getUserIdFromPrefs();
    if (userId != null && eventId != null) {
      await _dbHelper.deleteEventForUser(userId, eventId);
      print('Event deleted: $eventId'); // Debugging statement
      await loadEventsForLoggedInUser(); // Reload events after deleting
    }
  }

  // Retrieve the userId from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
