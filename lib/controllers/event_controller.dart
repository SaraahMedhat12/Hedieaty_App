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
      print('Loading events for userId: $userId');
      events = await _dbHelper.getAllEventsForUser(userId);
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
      await _dbHelper.insertEvent(event);
      print('Event added: $event');
      await loadEventsForLoggedInUser(); // Reload events after adding
      print('Updated list of events after adding: $events');
    } else {
      print('No user logged in! Cannot add event.');
    }
  }

  // Edit an event for the logged-in user
  Future<void> editEvent(
      int index, String name, String category, String location, DateTime date) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      // Create a new Map to update the database
      final updatedEvent = Map<String, dynamic>.from(events[index]);
      updatedEvent['name'] = name;
      updatedEvent['category'] = category;
      updatedEvent['location'] = location;
      updatedEvent['date'] = date.toIso8601String();
      updatedEvent['status'] = _determineEventStatus(date);

      await _dbHelper.updateEventForUser(userId, updatedEvent);
      print('Event updated: $updatedEvent');
      await loadEventsForLoggedInUser(); // Reload events after editing
      print('Updated list of events after editing: $events');
    } else {
      print('No user logged in! Cannot edit event.');
    }
  }

  // Delete an event for the logged-in user
  Future<void> deleteEvent(int index) async {
    final userId = await _getUserIdFromPrefs();
    if (userId != null) {
      final eventId = events[index]['id'];
      if (eventId != null) {
        await _dbHelper.deleteEventForUser(userId, eventId);
        print('Event deleted: $eventId');
        await loadEventsForLoggedInUser(); // Reload events after deleting
        print('Updated list of events after deletion: $events');
      } else {
        print('Event ID is null. Cannot delete event.');
      }
    } else {
      print('No user logged in! Cannot delete event.');
    }
  }

  String _determineEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Strip the time component from 'now'
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day); // Strip time from 'eventDate'

    if (eventDay.isBefore(today)) {
      return 'Past';
    } else if (eventDay.isAfter(today)) {
      return 'Upcoming';
    } else {
      return 'Current'; // If the dates match exactly (ignoring time), it's 'Current'
    }
  }


  // Retrieve the userId from SharedPreferences
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
